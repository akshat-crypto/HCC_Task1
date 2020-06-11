resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = "ap-south-1a"
  size = 1 
  
  tags = {
    Name = "tvol1"
  }
}