variable "region" {
  default     = ""
  description = "The cluster region"
}

variable "cluster-name" {
  default     = "eks-test"
  description = "The EKS cluster name"
}

variable "vpc-cidr" {
  default     = "10.0.0.0/16"
  description = "The cidr bloack range for VPC network"
}

variable "aws-account-id" {
  default     = ""
  description = "AWS account ID"
}

variable "instance-type" {
  default     = "m4.large"
  description = "Instance type for work nodes"
}

variable "access_key" {
  default     = ""
  description = "AWS access key"
}

variable "secret_key" {
  default     = ""
  description = "AWS secret key"
}

variable "cluster-size" {
  default     = 2
  description = "The number of worker nodes"
}

variable "max-size" {
  default     = 2
  description = "Max number of work nodes"
}

variable "min-size" {
  default     = 1
  description = "Min number of worker nodes"
}
