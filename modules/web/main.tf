/* Security group for the web */
resource "aws_security_group" "web_server_sg" {
  name        = "${var.environment}-web-server-sg"
  description = "Security group for web that allows web traffic from internet"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-web-server-sg"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "web_inbound_sg" {
  name        = "${var.environment}-web-inbound-sg"
  description = "Allow HTTP from Anywhere"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-web-inbound-sg"
  }
}

/* Web servers */
resource "aws_instance" "web" {
  count             = "${var.web_instance_count}"
  ami               = "${lookup(var.amis, var.region)}"
  instance_type     = "${var.instance_type}"
  subnet_id         = "${var.private_subnet_id}"
  vpc_security_group_ids = [
    "${aws_security_group.web_server_sg.id}"
  ]
  key_name          = "${var.key_name}"
  tags = {
    Name        = "${var.environment}-web-${count.index+1}"
    Environment = "${var.environment}"
    /* Instance    = ["${aws_instance.web[count.index].host_id}"]
       cyclic dependency   */
    associate_public_ip_address = true

  }

  provisioner "local-exec" {
    command = "echo Hello, World from EC2: ${self.id}"
  }

  /*  user_data  =  "${file("${path.module}/files/user_data.sh")}"   */
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx > /var/nginx.log
              cd /var/www/html      # This nginx install defaults to serving from here
              sudo touch index.html    # This will take precedence over the existing index.nignx-debian.html
              sudo chmod o+w index.html   # slightly insecure, in prod we'd lock down file permissions better
              echo "Hello, World from EC2: " >> index.html
              EOF
}

/* Load Balancer */
resource "aws_elb" "web" {
  name            = "${var.environment}-web-lb"
  subnets         = ["${var.public_subnet_id}"]
  security_groups = ["${aws_security_group.web_inbound_sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  instances = "${aws_instance.web.*.id}"

  tags = {
    Environment = "${var.environment}"
  }
}

resource "null_resource" "instance_tags" {
  /* Connecting through the bastion requires aws_elb to have finished.  Otherwise a
     remote-exec provisioner within the aws_instance block could be used to append
     the instance id's to each index.html file using a ${self.id} ref. */

  depends_on = ["aws_instance.web"]

  /* count      = "${var.web_instance_count}"  */
  /* The dynamic behaviour for_each, new in 0.12, is not supported for inline blocks */

  provisioner "remote-exec" {
    inline = [
      "sleep 20",
      "sudo echo ${aws_instance.web[0].id} >> /var/www/html/index.html"

    ]
    connection {
      type = "ssh"
      agent = true
      user = "ubuntu"
      host = "${aws_instance.web[0].private_ip}"
      //host_key = "${file("~/.aws/aws_terraform.pub")}"
      private_key = "${file("~/.aws/aws_terraform")}"
      bastion_user = "ubuntu"
      bastion_host = "${var.bastion_ip}"
      bastion_host_key = "${file("~/.aws/aws_terraform.pub")}"
      bastion_private_key = "${file("~/.aws/aws_terraform")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 20",
      "sudo echo ${aws_instance.web[1].id} >> /var/www/html/index.html"
    ]
    connection {
      type = "ssh"
      agent = true
      user = "ubuntu"
      host = "${aws_instance.web[1].private_ip}"
      //host_key = "${file("~/.aws/aws_terraform.pub")}"
      private_key = "${file("~/.aws/aws_terraform")}"
      bastion_user = "ubuntu"
      bastion_host = "${var.bastion_ip}"
      bastion_host_key = "${file("~/.aws/aws_terraform.pub")}"
      bastion_private_key = "${file("~/.aws/aws_terraform")}"
    }
  }

}
