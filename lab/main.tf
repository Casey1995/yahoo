module "project_yahoo" {
	source = "../modules"
	str_kms_alias = ""
	str_env       = "lab"
	map_tags      = merge(local.map_tags)
	str_application = "simple-app"
	vpc_cidr  = "10.0.0.0/16"
	subnet_config = []
	handshake = []
}
