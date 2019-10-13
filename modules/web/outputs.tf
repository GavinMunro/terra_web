output "elb_hostname" {
  value = "${aws_elb.web.dns_name}"
}

output "instance_ids" {
  value = "${aws_instance.web.*.id}"
}