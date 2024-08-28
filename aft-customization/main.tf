module "lambda" {
  source = "./modules/lambda"
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

