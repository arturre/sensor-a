locals {
  enable-istio = false
}

provider "aws" {
  #please use env variables
}

data "aws_region" "current" {}
