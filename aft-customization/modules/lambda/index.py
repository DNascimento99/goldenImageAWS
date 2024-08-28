import boto3
from botocore.exceptions import ClientError
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)
asg_client = boto3.client('autoscaling')

def get_launch_template_id_by_name(ec2_client, name):
    response = ec2_client.describe_launch_templates(
        LaunchTemplateNames=[name]
    )
    templates = response.get('LaunchTemplates', [])
    if not templates:
        raise Exception(f"Launch Template com nome {name} não encontrado")
    
    return templates[0]['LaunchTemplateId']

def get_latest_ami_with_prefix(ec2_client, region, prefix, infra_account):
    response = ec2_client.describe_images(
        Filters=[
            {'Name': 'name', 'Values': [f'{prefix}*']},
            {'Name': 'state', 'Values': ['available']}
        ],
        Owners= [infra_account]
    )
    images = sorted(response['Images'], key=lambda x: x['CreationDate'], reverse=True)
    if not images:
        raise Exception(f"Nenhuma AMI encontrada com o prefixo {prefix}")
    
    return images[0]['ImageId']

def update_launch_templates(region, launch_template_name, latest_ami_id):
    ec2_client = boto3.client(service_name='ec2', region_name=region)
    launch_template_id = get_launch_template_id_by_name(ec2_client, launch_template_name)

    # Obtendo o ID AMI atual
    versions = ec2_client.describe_launch_template_versions(
        LaunchTemplateId=launch_template_id,
        Versions=['$Latest']
    )

    if len(versions["LaunchTemplateVersions"]) != 1:
        raise Exception("Mais de 1 versão de modelo retornada. Algo deu errado")

    current_ami_id = versions["LaunchTemplateVersions"][0]["LaunchTemplateData"]["ImageId"]

    # Se o latest_ami_id for diferente do current_ami_id, crie uma nova versão do modelo de inicialização com o novo ami
    if latest_ami_id == current_ami_id:
        logger.info(f"A versão atual do modelo de inicialização para {launch_template_id} está atualizada")
    else:
        logger.info(f"Atualizando o modelo de inicialização {launch_template_id} com {latest_ami_id}")
        ec2_client.create_launch_template_version(
            LaunchTemplateId=launch_template_id,
            SourceVersion="$Latest",
            LaunchTemplateData={
                "ImageId": latest_ami_id
            }
        )

def set_asg_launch_template_version(asg_name, lt_name, version):
    try:
        # Obtém o ID do Launch Template usando o nome
        ec2_client = boto3.client('ec2')
        lt_id = get_launch_template_id_by_name(ec2_client, lt_name)
        
        response = asg_client.update_auto_scaling_group(
            AutoScalingGroupName=asg_name,
            LaunchTemplate={
                'LaunchTemplateId': lt_id,
                'Version': version
            }
        )
        logging.info("Set launch template: {} version for asg: {} to {}".format(
            lt_id, asg_name, version))
        return response
    except ClientError as e:
        logging.error('Error setting launch template version to {}'.format(version))
        raise e

def trigger_auto_scaling_instance_refresh(asg_name, lt_name, strategy="Rolling", min_healthy_percentage=90, instance_warmup=300):
    try:
        ec2_client = boto3.client('ec2')
        lt_id = get_launch_template_id_by_name(ec2_client, lt_name)
        
        response = asg_client.start_instance_refresh(
            AutoScalingGroupName=asg_name,
            Strategy=strategy,
            Preferences={
                'MinHealthyPercentage': min_healthy_percentage,
                'InstanceWarmup': instance_warmup,
                'AutoRollback': True,
                'AlarmSpecification': {
                    'Alarms': [
                        os.environ['CloudWatchAlarmName']
                    ]
                }
            },
            DesiredConfiguration={
                'LaunchTemplate': {
                    'LaunchTemplateId': lt_id,
                    'Version': '$Latest'
                }
            }
        )
        logging.info("Triggered Instance Refresh {} for Auto Scaling group {}".format(response['InstanceRefreshId'], asg_name))
    except ClientError as e:
        logging.error("Unable to trigger Instance Refresh for Auto Scaling group {}".format(asg_name))
        raise e

def lambda_handler(event, context):
    region = os.environ['RegionName']
    asg_name = os.environ['AutoScalingGroupName']
    lt_name = os.environ['LaunchTemplateName']
    ami_prefix = os.environ['ImagePrefixName']
    infra_account= os.environ['InfraAccountID']
    
    try:
        # Passo 1: Obter a AMI mais recente com o prefixo especificado
        latest_ami_id = get_latest_ami_with_prefix(boto3.client('ec2', region_name=region), region, ami_prefix, infra_account)

        # Passo 2: Atualizar o Launch Template com a nova AMI, se necessário
        update_launch_templates(region, lt_name, latest_ami_id)
        
        # Passo 3: Atualizar o Auto Scaling Group para usar a nova versão do Launch Template
        set_asg_launch_template_version(asg_name, lt_name, '3')
        
        # Passo 4: Iniciar o processo de Instance Refresh para atualizar as instâncias no ASG
        trigger_auto_scaling_instance_refresh(asg_name, lt_name)
        
        return "Success"
    except ClientError as e:
        logging.error("Error during the update and refresh process: {}".format(e))
        return "Error during the update and refresh process: {}".format(e)   
