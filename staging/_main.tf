provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "key" {
  key_name   = "${var.key_name}"
  public_key = "${file("~/.aws/aws_terraform.pub")}"  #"aws_terraform.pub"
}

# The aws_access_key_id and aws_secret_access_key must be obtained from
# the AWS CLI location ~/.aws/credentials in the local environment.