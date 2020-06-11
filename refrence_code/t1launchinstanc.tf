provider "aws" {
  region = "us-west-2"
  profile = "derek"
}

resource "aws_instance" "webserver" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name 
  security_groups
  subnet_id

  tags = {
    Name = "HelloWorld"
  }
}