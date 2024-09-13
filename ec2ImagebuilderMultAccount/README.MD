# Automação para Criação de Golden Image Utilizando EC2 Image Builder

Este documento descreve o processo de criação de uma golden image utilizando o EC2 Image Builder e a automação da aplicação dessa imagem em instâncias do Auto Scaling Group que servem a um Cluster ECS. O objetivo é garantir que novas AMIs sejam implantadas de forma automatizada e segura, com rollback automático em caso de falhas.

## Sumário

1. [Visão Geral](#visão-geral)
2. [Criação do Componente EC2 Image Builder](#criação-do-componente-ec2-image-builder)
3. [Template para Conta de Infraestrutura](#template-para-conta-de-infraestrutura)
4. [Template para Contas de Workloads](#template-para-contas-de-workloads)
5. [Pré-requisitos](#pré-requisitos)
6. [Referências](#referências)

---

## Visão Geral

O processo de criação da golden image envolve os seguintes passos:

1. **Criação da AMI**: Utiliza o EC2 Image Builder para criar uma AMI com base em um componente personalizado.
2. **Automatização da Atualização**: Um Lambda é acionado para atualizar o Launch Template dos recursos e iniciar a atualização das instâncias.
3. **Rollback Automático**: Em caso de falhas, um alarme do CloudWatch aciona um rollback para a versão anterior da AMI.

![Diagrama do Processo](diagrama-multAccount.PNG)

---

## Criação do Componente EC2 Image Builder

O componente do EC2 Image Builder define as ações realizadas durante a construção da imagem. O objetivo do componente é automatizar a instalação e configuração de softwares necessários, como o Apache web server, e executar scripts específicos.

### Objetivo do Componente

1. **Criar e Executar Scripts**: Configura um script bash para executar outros scripts localizados em um diretório específico.
2. **Criar Diretório**: Cria um diretório no sistema de arquivos para armazenar e executar scripts.
3. **Baixar Arquivos do S3**: Baixa arquivos necessários de um bucket S3 e os coloca no diretório criado.
4. **Executar Scripts**: Executa scripts de configuração após a criação do diretório e o download dos arquivos.

---

## Template para Conta de Infraestrutura

Este template CloudFormation configura a infraestrutura para atualizar automaticamente as AMIs em um Auto Scaling Group. Inclui uma função Lambda que atualiza o Launch Template dos recursos e inicia o Instance Refresh.  
[Recursos para as contas de infraestrutura](ec2ImageBuilder/template.yaml)

### Recursos Incluídos

- **Lambda Function**: `InvokeLambdaHandler` - Automatiza a atualização do Launch Template e inicia o Instance Refresh.
- **IAM Role**: `InvokeHandlerLambdaRole` - Permite que a função Lambda invoque funções em outras contas e execute ações necessárias.
- **IAM Role**: `InvokeInstanceRefreshHandlerRole` - Permite que a função Lambda atualize o Launch Template e inicie o Instance Refresh.
- **EventBridge Rule**: `EventBridgeForEventsS3` - Captura eventos de erro de serviços e tarefas no ECS.
- **CloudWatch Log Group**: `LogGroupforCollectEventsOfServiceECS` - Armazena eventos capturados pelo EventBridge.
- **CloudWatch Alarm**: `EventBridgeAlarmForEventsECS` - Aciona um rollback em caso de falhas detectadas durante o processo de atualização.

---

## Template para Contas de Workloads

Este template é utilizado nas contas de workloads para associar a nova AMI aos Auto Scaling Groups e realizar o Instance Refresh.  
[Recursos para contas de workloads](lambdaForInstanceRefresh//template.yaml)

### Recursos Incluídos

- **Auto Scaling Group**: Configurado para utilizar o Launch Template com a nova AMI.
- **ECS Cluster**: Configuração do cluster para garantir que os serviços estejam saudáveis após o Instance Refresh.

---

## Pré-requisitos

- **Bucket S3**: Certifique-se de que o bucket S3 necessário está criado e contém os arquivos de script e configuração.
- **IAM Roles**: As roles necessárias para as funções Lambda devem estar configuradas com as permissões adequadas.
- **EventBridge e CloudWatch**: Configure as regras e alarmes necessários para monitorar e responder a falhas durante o processo de atualização.

---

## Referências

- [Documentação EC2 Image Builder](https://docs.aws.amazon.com/imagebuilder/latest/userguide/what-is-image-builder.html)
- [CloudFormation Template Syntax](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-reference.html)
- [Automação de Atualização com Auto Scaling Groups e ECS](https://docs.aws.amazon.com/autoscaling/latest/userguide/what-is-auto-scaling.html)
