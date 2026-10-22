# terraform-aws-onprem-to-rds-migration-

# On-prem to AWS RDS migration with DMS and Site-to-Site VPN

This repository contains a production-oriented AWS migration design for moving a database from on-prem into AWS RDS with minimal downtime using AWS Database Migration Service (DMS) and Site-to-Site VPN.

## Architecture

- On-prem source database connects to AWS over private IPsec VPN
- VPC carries private app, DB, and DMS traffic only
- DMS runs in a private subnet
- Target RDS is created in a private DB subnet
- DMS performs full load + CDC
- App cutover happens after validation and near-zero-downtime final sync
- Routing and security are locked down to private-only access

## Production standards included

- Private subnets only
- No public RDS
- No public DMS
- No public app access
- Encryption at rest
- KMS for DB encryption
- Multi-AZ RDS
- DMS replication instance in private subnet
- VPC flow logs
- NACL hardening
- Security groups restricted by CIDR and subnet
- Site-to-Site VPN with strong IPsec policy
- CloudWatch alarms
- Backup retention and deletion protection
- IAM least privilege
- Tagging and environment naming

## Network model

- VPC: 10.20.0.0/16
- App subnets: 10.20.10.0/24, 10.20.11.0/24
- DB subnets: 10.20.20.0/24, 10.20.21.0/24
- DMS subnets: 10.20.30.0/24, 10.20.31.0/24
- On-prem CIDR: 10.10.0.0/16
- VPN tunnel routes: 10.10.0.0/16 <-> 10.20.0.0/16

## Migration strategy

Use DMS in:
- full-load + CDC mode  : Full load + CDC lets you migrate the existing database while capturing ongoing changes,
- validate data before cutover
- pause app writes only during final catch-up
- cut over app connection to RDS
- monitor replication lag and health
- keep DMS running briefly after cutover for validation
- rollback by switching app traffic back to on-prem

## Required on-prem configuration

Your on-prem firewall/router must allow:
- UDP 500
- UDP 4500
- ESP (protocol 50)
- route to 10.20.0.0/16 via VPN
- the AWS VPN public IPs must be allowed inbound

## Important notes

- There is no true zero-downtime migration without app-aware dual-write or blue-green app deployment.
- The practical production-target migration is near-zero downtime.
- Use app-level cutover control and a rollback plan.

## Terraform flow

1. Deploy VPC network
2. Deploy VPN gateway and customer gateway
3. Create route tables and NACLs
4. Create RDS target
5. Create DMS replication instance and endpoints
6. Run DMS task in full-load + CDC
7. Validate
8. Perform final cutover
9. Monitor and then retire DMS

## Validation script

Use the provided `scripts/validate-migration.sh` after network and infrastructure setup.
