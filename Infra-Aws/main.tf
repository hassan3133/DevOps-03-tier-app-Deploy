

/******************************************
	VPC configuration
 *****************************************/

module "VPC" {
  source = "./VPC/"

  aws_region          = var.aws_region
  public_subnets_cidr = var.public_subnets_cidr


}

module "EKS" {
  source = "./EKS/"

  aws_region          = var.aws_region
  subnet_ids          = module.VPC.subnet_ids

}
