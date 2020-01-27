output "Instance" {
    value = {
        SSH = "ssh -i ~/keys/${var.key_pair}.pem ubuntu@${aws_instance.simple-server.public_ip}"
    }
}
