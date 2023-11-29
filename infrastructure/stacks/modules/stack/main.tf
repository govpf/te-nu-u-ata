resource "rancher2_project" "stack" {
  name       = var.name
  cluster_id = "local"
}

resource "rancher2_user" "stack" {
  name     = var.name
  username = var.name
  password = var.secrets["rancher"]["user_password"]
  enabled  = true
}

# Create a new rancher2 global_role_binding for User
resource "rancher2_global_role_binding" "stack" {
  name           = var.name
  global_role_id = "user-base"
  user_id        = rancher2_user.stack.id
}

resource "rancher2_cluster_role_template_binding" "stack" {
  name             = var.name
  cluster_id       = "local"
  role_template_id = data.rancher2_role_template.cluster_member.id
  user_id          = rancher2_user.stack.id
}

resource "rancher2_project_role_template_binding" "stack" {
  name             = var.name
  project_id       = rancher2_project.stack.id
  role_template_id = data.rancher2_role_template.project_member.id
  user_id          = rancher2_user.stack.id
}

resource "rancher2_namespace" "stack" {
  name        = var.name
  project_id  = rancher2_project.stack.id
  description = var.name
}

resource "rancher2_secret_v2" "app" {
  cluster_id = "local"
  name       = "app"
  namespace  = rancher2_namespace.stack.id
  type       = "opaque"
  data       = var.secrets["app"]
}

resource "rancher2_secret_v2" "gravitee" {
  cluster_id = "local"
  name       = "gravitee"
  namespace  = rancher2_namespace.stack.id
  type       = "opaque"
  data       = var.secrets["gravitee"]
}

resource "rancher2_secret_v2" "database" {
  cluster_id = "local"
  name       = "database"
  namespace  = rancher2_namespace.stack.id
  type       = "opaque"
  data       = var.secrets["database"]
}

data "rancher2_role_template" "cluster_member" {
  name = "Cluster Member"
}

data "rancher2_role_template" "project_member" {
  name = "Project Member"
}
