provider "aws" {
  region = "us-east-1"
}

module "lambda_function" {
  source        = "./modules/lambda"
  lambda_config = var.lambda_config
  environment   = var.environment
}
