resource "aws_instance" "app" {
  count = 2

  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id = aws_subnet.public[count.index].id

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  associate_public_ip_address = true

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-app-${count.index + 1}"
  }
}