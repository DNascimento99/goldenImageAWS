module "lambda" {
  source = "./modules/lambda"
}

module "role" {
  source = "./modules/role"
}

module "events" {
  source = "./modules/eventBridge"
}

module "logs" {
  source = "./modules/cloudWatchLogs"
}

module "alarms" {
  source = "./modules/cloudWatchAlarm"
}

