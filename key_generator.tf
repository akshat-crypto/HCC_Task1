provider aws {
  region = "ap-south-1"
  profile = "derek"
}


//CREATING A KEY//
resource "tls_private_key" "key_algo" {
   algorithm = "RSA"
   rsa_bits = 4096
}
output "opkey" {
  value = "tls_private_key.key_algo" 
}

//SAVING TO DRIVE//
resource "local_file" "key_store" {
   content = tls_private_key.key_algo.private_key_pem
   filename = "C://Users/Akshat/Desktop/key12.pem"
   file_permission = "0400"
}

resource "aws_key_pair" "key_gen" {
   key_name = "key12"
   public_key = tls_private_key.key_algo.public_key_openssh
}



/**/