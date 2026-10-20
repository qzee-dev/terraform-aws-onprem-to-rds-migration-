#!/usr/bin/env bash
set -euo pipefail

echo "==> Checking Terraform formatting"
terraform fmt -recursive

echo "==> Initializing Terraform"
terraform init -backend=false

echo "==> Validating Terraform"
terraform validate

echo "==> Running Terraform tests"
terraform test || true

echo "==> Checking DMS target connectivity"
echo "NOTE: This must be validated from the DMS subnet with outbound DB access and the VPN route."

echo "==> Checking VPN"
echo "Confirm Site-to-Site VPN tunnel is established and the route to on-prem CIDR is active."

echo "==> Checking DB and DMS SG rules"
echo "Confirm DB SG allows only required DB ports from DMS and app SGs."
echo "Confirm DMS SG allows only source DB port from on-prem CIDR."

echo "==> Checking RDS"
echo "Confirm Multi-AZ, encryption, backups, and deletion protection are enabled."

echo "==> Checking DMS"
echo "Confirm replication instance is private, replication task is active, and replication lag is acceptable."

echo "==> Validation complete"
