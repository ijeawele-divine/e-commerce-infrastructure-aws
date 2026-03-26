locals {
  redis_endpoint = module.redis.redis_primary_endpoint
  redis_url      = "redis://${module.redis.redis_primary_endpoint}:6379"
  db_url_base    = "postgresql://${var.master_username}:${var.master_password}@${module.rds.rds_endpoint}:5432"
}

resource "aws_secretsmanager_secret" "rider_service" {
  name                    = "teleios-divine-${var.environment}-rider-service"
  recovery_window_in_days = 0
  tags                    = { Environment = var.environment }
}

resource "aws_secretsmanager_secret_version" "rider_service" {
  secret_id = aws_secretsmanager_secret.rider_service.id
  secret_string = jsonencode({
    NODE_ENV             = "production"
    PORT                 = "3001"
    JWT_SECRET           = var.jwt_secret
    JWT_EXPIRES_IN       = "7d"
    FRONTEND_URL         = "https://rideshare.ijeaweledivine.online"
    GOOGLE_CLIENT_ID     = var.google_client_id
    GOOGLE_CLIENT_SECRET = var.google_client_secret
    RIDER_SERVICE_URL    = "http://rider-service:80"
    TRIP_SERVICE_URL     = "http://trip-service:80"
    DATABASE_URL         = "${local.db_url_base}/rider_db"
    REDIS_HOST           = local.redis_endpoint
    REDIS_PORT           = "6379"
    REDIS_PASSWORD       = ""
    EMAIL_SERVICE_URL    = "http://email-service:80"
  })
  depends_on = [module.rds, module.redis]
}

resource "aws_secretsmanager_secret" "driver_service" {
  name                    = "teleios-divine-${var.environment}-driver-service"
  recovery_window_in_days = 0
  tags                    = { Environment = var.environment }
}

resource "aws_secretsmanager_secret_version" "driver_service" {
  secret_id = aws_secretsmanager_secret.driver_service.id
  secret_string = jsonencode({
    NODE_ENV          = "production"
    PORT              = "3003"
    JWT_SECRET        = var.jwt_secret
    JWT_EXPIRES_IN    = "7d"
    FRONTEND_URL      = "https://rideshare.ijeaweledivine.online"
    RIDER_SERVICE_URL = "http://rider-service:80"
    TRIP_SERVICE_URL  = "http://trip-service:80"
    DATABASE_URL      = "${local.db_url_base}/driver_db"
    REDIS_HOST        = local.redis_endpoint
    REDIS_PORT        = "6379"
    REDIS_PASSWORD    = ""
    EMAIL_SERVICE_URL = "http://email-service:80"
  })
  depends_on = [module.rds, module.redis]
}

resource "aws_secretsmanager_secret" "trip_service" {
  name                    = "teleios-divine-${var.environment}-trip-service"
  recovery_window_in_days = 0
  tags                    = { Environment = var.environment }
}

resource "aws_secretsmanager_secret_version" "trip_service" {
  secret_id = aws_secretsmanager_secret.trip_service.id
  secret_string = jsonencode({
    PORT            = "3005"
    DEBUG           = "False"
    ALLOWED_ORIGINS = "https://rideshare.ijeaweledivine.online"
    DATABASE_URL    = "${local.db_url_base}/trip_db"
    REDIS_URL       = local.redis_url
    REDIS_TLS       = "false"
  })
  depends_on = [module.rds, module.redis]
}

resource "aws_secretsmanager_secret" "matching_service" {
  name                    = "teleios-divine-${var.environment}-matching-service"
  recovery_window_in_days = 0
  tags                    = { Environment = var.environment }
}

resource "aws_secretsmanager_secret_version" "matching_service" {
  secret_id = aws_secretsmanager_secret.matching_service.id
  secret_string = jsonencode({
    NODE_ENV         = "production"
    PORT             = "3004"
    TRIP_SERVICE_URL = "http://trip-service:80/api/trips"
    DATABASE_URL     = "${local.db_url_base}/matching_db"
    REDIS_URL        = local.redis_url
    REDIS_TLS        = "false"
  })
  depends_on = [module.rds, module.redis]
}

resource "aws_secretsmanager_secret" "email_service" {
  name                    = "teleios-divine-${var.environment}-email-service"
  recovery_window_in_days = 0
  tags                    = { Environment = var.environment }
}

resource "aws_secretsmanager_secret_version" "email_service" {
  secret_id     = aws_secretsmanager_secret.email_service.id
  secret_string = jsonencode({
    AZURE_EMAIL_CONNECTION_STRING = var.azure_email_connection_string
    SENDER_EMAIL                  = var.sender_email
  })
}

resource "aws_secretsmanager_secret" "frontend" {
  name                    = "teleios-divine-${var.environment}-frontend"
  recovery_window_in_days = 0
  tags                    = { Environment = var.environment }
}

resource "aws_secretsmanager_secret_version" "frontend" {
  secret_id     = aws_secretsmanager_secret.frontend.id
  secret_string = jsonencode({
    NEXT_PUBLIC_DRIVER_SERVICE_URL   = "https://rideshare.ijeaweledivine.online/driver"
    NEXT_PUBLIC_RIDER_SERVICE_URL    = "https://rideshare.ijeaweledivine.online/rider"
    NEXT_PUBLIC_TRIP_SERVICE_URL     = "https://rideshare.ijeaweledivine.online/api/trips"
    NEXT_PUBLIC_MATCHING_SERVICE_URL = "https://rideshare.ijeaweledivine.online/matching"
    NEXT_PUBLIC_TRIP_WS_URL          = "wss://rideshare.ijeaweledivine.online"
    NEXT_PUBLIC_MAPBOX_ACCESS_TOKEN  = var.next_public_mapbox_access_token
    NEXT_PUBLIC_WS_URL               = "wss://rideshare.ijeaweledivine.online/ws"
  })
}