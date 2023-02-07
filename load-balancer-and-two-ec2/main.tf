terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "eu-central-1"
}

resource "aws_instance" "nginx_server" {
  count = 2
  ami           = "ami-06c39ed6b42908a36"
  instance_type = "t2.micro"
  key_name = "z-palca"
  
  tags = {
    Name = "nginx-instance"
  }

user_data = <<-EOF
#!/bin/bash
amazon-linux-extras install -y nginx1
yum clean metadata
yum -y install nginx
echo "bar - $HOSTNAME" > /usr/share/nginx/html/index.html
systemctl start nginx
systemctl enable nginx
EOF


}

resource "aws_elb" "nginx_elb" {
    name = "nginx-elb"
    security_groups = [ "sg-0633becb08e8d5d03" ]
    subnets = [ "subnet-002b60ac457ad4388" ]

    listener {
      instance_port = 80
      instance_protocol = "http"
      lb_port = 80
      lb_protocol = "http"
    }
  instances = aws_instance.nginx_server.*.id

}

output "elb_dns_name" {
    value = aws_elb.nginx_elb.dns_name
}
