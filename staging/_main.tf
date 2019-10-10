provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "key" {
  key_name   = "${var.key_name}"
  public_key = "${file("staging_key.pub")}"
}

# The aws_access_key_id and aws_secret_access_key must be obtained from
# ~/.aws/credentials in the local environment.