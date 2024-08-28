provider "aws" {
  region = "us-east-1"
}
module "lambda" {
  source = "./modules/lambda"

  lambda_config = var.lambda_config
  environment_variables = var.environment_variables
  create_role = var.create_role
}

module "role" {
  source = "./modules/role"
}

module "events" {
  source = "./modules/eventBridge"
  loggroup = module.cloudWatchLogs.loggroup
}

module "logs" {
  source = "./modules/cloudWatchLogs"
}

module "alarms" {
  source = "./modules/cloudWatchAlarm"
  eventbridge = module.eventBridge.eventbridge
}
