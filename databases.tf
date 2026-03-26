resource "postgresql_database" "rider_db" {
  name  = "rider_db"
  owner = var.master_username
  depends_on = [module.rds]
}

resource "postgresql_database" "driver_db" {
  name  = "driver_db"
  owner = var.master_username
  depends_on = [module.rds]
}

resource "postgresql_database" "trip_db" {
  name  = "trip_db"
  owner = var.master_username
  depends_on = [module.rds]
}

resource "postgresql_database" "matching_db" {
  name  = "matching_db"
  owner = var.master_username
  depends_on = [module.rds]
}