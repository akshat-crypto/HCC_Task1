provider "aws" {
	region = "ap-south-1"
	profile = "derek"
}
resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = "ap-south-1a"
  size = 1 
  
  tags = {
    Name = "tvol1"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "task1key"
  public_key = ""
}
