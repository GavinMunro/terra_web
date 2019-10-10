output "elb_hostname" {
  value = "${aws_elb.web.dns_name}"
}