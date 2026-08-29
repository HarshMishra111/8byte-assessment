terraform {
  backend "s3" {
    bucket       = "data-storage-bucket-myapp"
    key          = "terraform-webapp/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = true
  }
}