provider "aws" {}

variable "ami" {
  default = "ami-759bc50a"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "vpc_security_group_ids" {
  type = "list"
}
variable "subnet_id" {}

resource "aws_instance" "example" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"
  subnet_id = "${var.subnet_id}"
}
