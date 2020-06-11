provide aws {
   region = "ap-south-1"
   profile = "derek"
}

resource "aws_key_pair" "productn_key" {
  key_name = "terakey1"
  public_key = "${tls_private_key.klaus.public_key_openssh}"
}