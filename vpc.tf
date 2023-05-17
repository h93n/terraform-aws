resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "sub_net" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "sub-public"
  }
}

resource "aws_internet_gateway" "gate_way" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "gateway_in"
  }
}

resource "aws_route_table" "route_t" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "route_table"
  }
}

resource "aws_route" "defaul_route" {
  route_table_id         = aws_route_table.route_t.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gate_way.id
}

resource "aws_route_table_association" "table_route" {
  subnet_id      = aws_subnet.sub_net.id
  route_table_id = aws_route_table.route_t.id
}

resource "aws_security_group" "sec_group" {
  name        = "security_g"
  description = "my security group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "key_pai" {
  key_name   = "newkeypai"
  public_key = file("~/.ssh/newkey.pub")
}

data "aws_ami" "my_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "instance" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.my_ami.id
  key_name               = aws_key_pair.key_pai.id
  vpc_security_group_ids = [aws_security_group.sec_group.id]
  subnet_id              = aws_subnet.sub_net.id
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }
  tags = {
    Name = "instance"
  }

  provisioner "local-exec" {
    command = templatefile("ssh.tpl", {
      hostname     = self.public_ip,
      user         = "ec2-user",
      identityfile = "~/.ssh/newkey"
    })
    interpreter = ["bash", "-c"]
  }

}


