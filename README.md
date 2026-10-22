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



Here is your AWS Site-to-Site VPN configuration summarized in simple English, step by step, using the real Terraform resource names and AWS configuration names.

## Step-by-step configuration

Step 1: Create the Customer Gateway

Terraform resource: `aws_customer_gateway`

- `ip_address` — public IP of the external VPN device.
- `bgp_asn` — ASN for the customer gateway.
- `type` — `ipsec.1`.
- `tags` — resource labels.

Purpose: Tell AWS where your external VPN device is located.

Step 2: Create the AWS VPN Gateway

Terraform resource: `aws_vpn_gateway`

- `vpc_id` — ID of your AWS VPC.
- `tags` — resource labels.

Purpose: Create the AWS-side gateway and attach it to your VPC.

Step 3: Create the VPN Connection

Terraform resource: `aws_vpn_connection`

- `vpn_gateway_id` — AWS VPN gateway ID.
- `customer_gateway_id` — customer gateway ID.
- `type` — `ipsec.1`.
- `static_routes_only` — `true`.

Purpose: Connect the two gateways and configure static routing.

Step 4: Configure VPN Tunnel Security

Terraform arguments inside `aws_vpn_connection`

- `tunnel1_ike_versions` / `tunnel2_ike_versions` — IKE version.
- `tunnel1_phase1_*` / `tunnel2_phase1_*` — Phase 1 security settings.
- `tunnel1_phase2_*` / `tunnel2_phase2_*` — Phase 2 security settings.
- Encryption algorithms — protect data confidentiality.
- Integrity algorithms — verify data integrity.
- DH groups — key exchange.
- Lifetimes — when security associations are renewed.

Purpose: Secure both VPN tunnels. Ensure all settings are supported by AWS and the external VPN device.

Step 5: Define the Static VPN Route

Terraform resource: `aws_vpn_connection_route`

- `destination_cidr_block` — external network CIDR.
- `vpn_connection_id` — VPN connection ID.
- `static_routes` — static routes declared in `aws_vpn_connection`.

Purpose: Tell AWS which external network is reachable through the VPN. Check your configuration for duplicate route declarations.

Step 6: Configure VPC Route Tables

Terraform resource, if managed in code: `aws_route`

- `route_table_id` — route table to update.
- `destination_cidr_block` — external network CIDR.
- `gateway_id` — virtual private gateway ID.

Purpose: Direct traffic for the external CIDR to the VPN gateway. Also configure the external network's return route to the AWS VPC CIDR.

Step 7: Configure Security and the External Device

AWS settings and external VPN device configuration

- `aws_security_group` — permit required traffic.
- `aws_network_acl` — check subnet-level traffic rules.
- External VPN device — configure tunnel peers, IPsec settings and routes.
- Database firewall and permissions — allow the required connection.

Purpose: Make sure the traffic is permitted on both sides.

Step 8: Export VPN Details

Terraform outputs: `output`

- `vpn_connection_id`
- `tunnel1_ip`
- `tunnel2_ip`

Purpose: Retrieve the VPN connection ID and AWS tunnel endpoint IPs.

Step 9: Validate and Test

Run these Terraform commands:

bash
```
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
```

Then check tunnel status, routes and connectivity between the permitted private IP addresses.

## Real names to remember

| Purpose | Actual Terraform/AWS name |
| --- | --- |
| External VPN endpoint definition | `aws_customer_gateway` |
| AWS-side VPN gateway | `aws_vpn_gateway` |
| VPN connection | `aws_vpn_connection` |
| Static VPN route | `aws_vpn_connection_route` |
| VPC route table entry | `aws_route` |
| VPC security rules | `aws_security_group` |
| Subnet network ACL | `aws_network_acl` |
| Return route on external device | External router/VPN device configuration |
| Retrieve deployed values | `output` |

Remember the order: Customer Gateway → VPN Gateway → VPN Connection → Tunnel Security → Static Routes → VPC Route Tables → Security Rules → Outputs → Connectivity Testing.

Your VPN is not fully operational just because Terraform creates the connection. You must also configure the external VPN device, the VPC route tables and the return route.
