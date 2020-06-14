provider aws {
  region = "ap-south-1"
  profile = "derek"
}
/*
##Creating a valid key-pair##
resource "aws_key_pair" "productn_key" {
  key_name = "terakey1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAgEAh5YEN8bECdP7zZZ0DSsOuuSfBiZ8Fib63u4H+fOIzioReMOmGd8xxAqHkCuFRoEiQWV2tudM2fGwxBGXgYy9k55jhvYSI4472FwUkmTNjLaFfiGWlMji87nvzTSVjlaf4udg9BEtO2QZdr8/8d1xfHyHRlNh9+9wFO0e9mwk9b+rVDnwmEm5AWk6ok+uvQmWixtMYpZ8j/lxqxZtgmGh12gwLScqNnfTRNlQX949eiebPShNndEfqCzFFvFOuLyL7e/h2zv2IDbUSoNO7NJN84rmJoyI/0eN6cBBdKnsDV8XLI2HzxyCnMDoDj2wggocaD7Dd7kOBvQJba0nIWkRJbPrr2Z0C/0svSxaXMgPBClbPOaPKIuzU5PAIF8ESkYVbCppM2OwXnwoLFgjUFzMeI96d+uOrERTs932ClyjXTgWmimoeCY8iCQwex90GKThyHYbZap+ngqiAi4zctiuSD+k/H2RYc9JN4I+8d0viFfCn3gEBrGfPqBoCoTOK+ajqgIW6UBcUdny/Du44Y0ZbWfOaJ3tmMl4JW71TU13CE7S2Y4QP92++HLskkXBFuGsOP/UndUuVlGIpQnYKVJUYrgT/QXdZH005aQZXMHtAjQkkshLO3SpU= rsa-key-20200610"
}
*/
##Getting the output for the key created##
output "opkey" {
  value = aws_key_pair.productn_key 
}

##creating the security groups##
resource "aws_security_group" "security_group1" {
  name        = "allow_tls"
  description = "Allow TCP and SSH inbound traffic"
  vpc_id      = "vpc-7b839e13"

 ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg1"
  }
}

output "op_sg" {
  value = aws_security_group.security_group1
}

##setting variable for the key##
variable "insert_key_var" {
     type = string
//   default = "terask"
}

##launching the instance##
resource "aws_instance" "inst1" {
  ami = "ami-0e62f6b90aedfb761"
  instance_type = "t2.micro"
  key_name = var.insert_key_var
  security_groups = [ "allow_tls" ]
  tags = {
    Name = "server1"
  }
}

##outputs of the instances##
output "op_inst_ip" {
  value = aws_instance.inst1.public_ip
}

output "op_inst_az" {
  value = aws_instance.inst1.availability_zone
}

##creating the EBS volumes##
resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = aws_instance.inst1.availability_zone
  size = 1 
  
  tags = {
    Name = "tvol1"
  }
}

##checking the op of the ebs volume for the volume id##
output "ebs_volume" {
  value = aws_ebs_volume.ebs_volume
}

##attaching the ebs volume to the running instance##
resource "aws_volume_attachment" "disc_attach" {
  device_name = "/dev/sdf"
  volume_id = aws_ebs_volume.ebs_volume.id
  instance_id = aws_instance.inst1.id
}

####CREATING THE BUCKET FOR THE ABOVE INSTANCE TO STORE THE DATA####

resource "aws_s3_bucket" "bucket" {
  bucket = "task1-bucket8526"
  acl    = "public-read"

  tags = {
    Name        = "Mybucket9658582"
  }
}

output "ops3" {
  value = aws_s3_bucket.bucket
}

locals {
  s3_origin_id = "S3-Mybucket9658582"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.bucket.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"
  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some-comment"
  
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"
    forwarded_values {
    query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "allow-all"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "allow-all"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["US", "CA"]
    }
  }
  
  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "opcdn" {
  value = aws_cloudfront_distribution.s3_distribution
}
