output "elb_hostname" {
  value = "${module.web.elb_hostname}"
}

output "instance_id" {
  value = "${module.web.instance_id}"
}