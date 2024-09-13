# Documentação de Uso dos Templates de Criação de Golden Image e Atualização de Instâncias

Esta documentação fornece instruções para usar os templates CloudFormation para criar uma golden image utilizando o EC2 Image Builder e automatizar a atualização de instâncias em um Auto Scaling Group.

## Sumário

1. [Visão Geral](#visão-geral)
2. [Uso do Template de Infraestrutura](#uso-do-template-de-infraestrutura)
3. [Uso do Template de Workloads](#uso-do-template-de-workloads)
4. [Passos Adicionais](#passos-adicionais)
5. [Dicas e Troubleshooting](#dicas-e-troubleshooting)

---

## Visão Geral

Os templates CloudFormation fornecidos são projetados para:

1. **Criar uma AMI**: Configura o EC2 Image Builder para criar uma AMI com base em um componente personalizado.
2. **Atualizar Instâncias**: Configura a infraestrutura para atualizar Launch Templates e iniciar Instance Refresh em Auto Scaling Groups.
3. **Rollback Automático**: Monitora e executa rollback em caso de falhas detectadas durante a atualização.

## Uso do Template de Infraestrutura

### Passos para Implementação

1. **Preparação**:
   - Certifique-se de que o bucket S3 está criado e contém os scripts necessários.
   - Configure as IAM Roles necessárias para que as funções Lambda possam executar as ações exigidas.

2. **Envio de Scripts para o Bucket S3**:
   - Para que o Image Builder seja acionado, é necessário que arquivos `.sh` (scripts Bash) estejam presentes no bucket S3 especificado. Você pode enviar os arquivos para o bucket utilizando o seguinte comando `aws-cli`:

     ```bash
     aws s3 cp executebash/ s3://(bucket_name) --recursive
     ```

   - Alternativamente, você pode configurar uma pipeline para enviar esses arquivos automaticamente para o bucket e, após a execução do Image Builder, limpar o bucket.

3. **Criação da Stack**:
   - Utilize o AWS CLI para criar a stack da infraestrutura com o seguinte comando:

     ```bash
     aws cloudformation create-stack \
         --stack-name Ec2ImageBuilderForLambdaInvoke \
         --template-body file://template.yaml \
         --parameters file://parameters.json \
         --region sa-east-1 \
         --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
     ```

   - Preencha os parâmetros no arquivo `parameters.json` conforme necessário:
     - `EnvironmentName`: Nome do ambiente.
     - `AmazonLinux2023EcsOptimizedAmiId`: ID da AMI otimizada para ECS.
     - `BuildInstanceType`: Tipo de instância para o Image Builder.
     - `PublicSubnet`: ID da subnet pública.
     - `DefaultSecurityGroup`: ID do grupo de segurança padrão.
     - `BucketName`: Nome do bucket S3.
     - `AWSOrgID`: ID da organização.
     - `InvokeInstanceRefreshHandlerRole`: Nome da role Lambda para invocar o Instance Refresh.
     - `AccountOrganization`: ID da organização da conta.

4. **Verificação**:
   - Após a criação da stack, verifique se todos os recursos foram criados corretamente, incluindo as funções Lambda, roles IAM, regras do EventBridge, e grupos de logs do CloudWatch.

## Uso do Template de Workloads

### Passos para Implementação

1. **Preparação**:
   - Certifique-se de que o Launch Template e o Auto Scaling Group estão configurados na conta de workload.

2. **Criação da Stack**:
   - Utilize o AWS CLI para criar a stack de workloads com o seguinte comando:

     ```bash
     aws cloudformation create-stack \
         --stack-name InstanceRefreshForImageBuilder \
         --template-body file://template.yaml \
         --parameters file://parameters.json \
         --region sa-east-1 \
         --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
     ```

   - Preencha os parâmetros no arquivo `parameters.json` conforme necessário:
     - `EnvironmentName`: Nome do ambiente.
     - `SampleLaunchTemplate`: ID do modelo de inicialização (Launch Template).
     - `SampleAutoScalingGroup`: Nome do Auto Scaling Group.
     - `ImagePrefix`: Prefixo do nome da imagem (AMI).
     - `ClusterName`: Nome do cluster ECS.
     - `InfraAccount`: ID da conta de infraestrutura.

3. **Verificação**:
   - Após a criação da stack, verifique se a função Lambda foi criada corretamente e se está configurada com as permissões apropriadas.
   - Certifique-se de que o Auto Scaling Group e o Launch Template foram atualizados com a nova AMI.

## Passos Adicionais

- **Preparar a Pipeline**:
  - Configure uma pipeline para enviar os arquivos `.sh` para o bucket S3 quando necessário e para acionar a execução do EC2 Image Builder.

- **Excluir Arquivos do Bucket**:
  - Após a execução do componente do Image Builder, os arquivos `.sh` podem ser excluídos do bucket S3 para manter o bucket limpo e centralizar os scripts no repositório. Inclua o seguinte passo na configuração do componente do Image Builder:

    ```yaml
    - name: DeleteS3Object
      action: ExecuteBash
      onFailure: Abort
      maxAttempts: 3
      inputs:
        commands: 
        - aws s3 rm s3://${BucketName}-${EnvironmentName}/*
    ```

    Isso garante que, após a execução do componente, o bucket seja limpo e os arquivos sejam mantidos apenas no repositório.

- **Monitoramento**: Configure o monitoramento e alarmes no CloudWatch para verificar a saúde das instâncias e capturar eventos relacionados.
- **Testes**: Realize testes para garantir que a automação de atualização e rollback está funcionando conforme esperado.

## Dicas e Troubleshooting

- **Verifique Logs**: Se a função Lambda falhar, verifique os logs no CloudWatch para detalhes sobre o erro.
- **Permissões IAM**: Certifique-se de que as roles IAM têm as permissões corretas para acessar recursos necessários e executar ações.
- **EventBridge e CloudWatch**: Confirme se as regras e alarmes estão configurados corretamente e estão acionando eventos conforme esperado.

Para qualquer dúvida adicional ou suporte, consulte a [documentação da AWS](https://docs.aws.amazon.com) ou entre em contato com o suporte técnico da AWS.
