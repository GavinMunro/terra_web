output "elb_hostname" {
  value = "${aws_elb.web.dns_name}"
}

output "instance_id" {
  value = "${aws_instance.web.*.id}"
        /* aws_instance.web[count.index].id  */
}