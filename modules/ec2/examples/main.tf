module "computo" {
  source = "../"

  instance_name     = "ejemplo-ec2"
  instance_type     = "t2.micro"
  subnet_id         = "subnet-xxxxxxxxx"
  security_group_id = "sg-xxxxxxxxx"
}

output "instance_ip" {
  value = module.computo.instance_ip
}