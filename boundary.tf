resource "boundary_scope" "org" {
  scope_id                 = "global"
  name                     = "TF_Boundary"
  description              = "Terraform Boundary Organization"
  auto_create_default_role = true
  auto_create_admin_role   = true
}

resource "boundary_scope" "project" {
  name             = "TF_Boundary_Servers"
  description      = "Manage all machines in the TF_Boundary project"
  scope_id                 = boundary_scope.org.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_host_catalog_static" "production" {
  name        = "production"
  description = "all hosts in production"
  scope_id    = boundary_scope.project.id
}

resource "boundary_host_static" "app_server_one" {
  name            = "server_one"
  description     = "Private app servers"
  address         = aws_instance.server.private_ip
  host_catalog_id = boundary_host_catalog_static.production.id
}

resource "boundary_host_static" "app_server_two" {
  name            = "server_two"
  description     = "One of two of the app servers"
  address         = aws_instance.alt_server.public_ip
  host_catalog_id = boundary_host_catalog_static.production.id
}


resource "boundary_host_set_static" "app_servers" {
  name            = "app_servers"
  description     = "Host set for the app servers"
  host_catalog_id = boundary_host_catalog_static.production.id
  host_ids = [
      boundary_host_static.app_server_two.id
  ]
}

resource "boundary_host_set_static" "app_servers_private" {
  name            = "app_servers_private"
  description     = "Host set for the private app servers"
  host_catalog_id = boundary_host_catalog_static.production.id
  host_ids = [
      boundary_host_static.app_server_one.id
  ]
}

resource "boundary_target" "app_server" {
  type                     = "tcp"
  name                     = "app_server"
  description              = "an instance of an app server accessed via SSH"
  scope_id                 = boundary_scope.project.id
  session_connection_limit = -1
  default_port             = 22
  host_source_ids = [
    boundary_host_set_static.app_servers.id
  ]
}

resource "boundary_target" "app_server_private" {
  type                     = "tcp"
  name                     = "app_server_private"
  description              = "an instance of a private app server accessed via SSH"
  scope_id                 = boundary_scope.project.id
  session_connection_limit = -1
  default_port             = 22
  host_source_ids = [
    boundary_host_set_static.app_servers_private.id
  ]
  worker_filter = "\"worker\" in \"/tags/type\""
}

resource "boundary_auth_method" "password" {
  name        = "tf_boundary_auth_method"
  description = "Password auth method for the TF_Boundary org"
  type        = "password"
  scope_id    = boundary_scope.org.id
}

resource "boundary_account_password" "user_account" {
  name           = "generic_user_account"
  description    = "Generic User password account"
  type           = "password"
  login_name     = "genericuser" # must be all lower case alphanumeric and hyphens or periods
  password       = "hilarious"
  auth_method_id = boundary_auth_method.password.id
}

resource "boundary_user" "generic_user" {
  name        = "generic_user"
  description = "A generic user"
  account_ids = [
     boundary_account_password.user_account.id
  ]
  scope_id    = boundary_scope.org.id
}

resource "boundary_group" "generic_group" {
  name        = "generic_group"
  description = "A generic group with generic permissions"
  member_ids  = [
    boundary_user.generic_user.id
  ]
  scope_id    = boundary_scope.org.id
}

resource "boundary_role" "read-only" {
  name            = "read-only"
  description     = "Role with read-only permission"
  scope_id        = boundary_scope.org.id
  principal_ids   = [
    boundary_user.generic_user.id
  ]
  grant_strings   = ["id=*;type=*;actions=read,list"]
}

resource "random_id" "boundary_worker_token" {
  byte_length = 8
}

resource "boundary_worker" "worker_one" {
  scope_id = boundary_scope.project.id
  name = "worker_one"
  description = "first of the self managed workers"
  # worker_generated_auth_token = random_id.boundary_worker_token.id
}