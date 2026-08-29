resource aws_key_pair my_key{
    key_name = "terra-key-ec2"
    public_key = file("terra-key-ec2.pub") #used file function so that complete key is hidden 
}

resource aws_default_vpc default{

}

resource aws_security_group my_security_group{
    name = "automate sg"
    description = "This will add a TF generated security group"
    vpc_id = aws_default_vpc.default.id #interpolation


#inbound rules
ingress{
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH open"
}

ingress{
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP open"
}

ingress{
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS open"
}

#outbound rules

egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "all access are open outbound"
}
    tags = {
        Name = "automate sg"
    }
}

# ec2 instance

resource "aws_instance" "my_instance" {
    key_name = aws_key_pair.my_key.key_name
    vpc_security_group_ids = [aws_security_group.my_security_group.id]
    instance_type = "t3.micro"
    ami = "ami-06468be052a4195a6" #ubuntu

    root_block_device {
      volume_size = 15
      volume_type = "gp3"
    }
    tags = {
        Name = "assignment-8byte"
    }
}
