resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "${var.prefix}-key" # Create the key to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create a .pem file to your computer!!
    command = <<-EOT
      echo '${tls_private_key.pk.private_key_pem}' > ${path.module}/secrets/${self.key_name}.pem
      chmod 400 ${path.module}/secrets/'${self.key_name}.pem'
    EOT
  }
}