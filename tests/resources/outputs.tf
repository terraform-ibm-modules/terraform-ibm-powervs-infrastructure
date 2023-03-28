output "ssh_public_key" {
  value       = resource.tls_private_key.tls_key.public_key_openssh
  description = "SSH Public Key"
}

output "ssh_private_key" {
  value       = resource.tls_private_key.tls_key.private_key_pem
  description = "SSH Private Key"
  sensitive   = true
}
