flowchart LR
    subgraph ONPREM["On-prem Datacenter"]
        USERS["Application Clients / Legacy Services"]
        SOURCE["On-prem PostgreSQL / MySQL / Oracle DB"]
        FW["On-prem Firewall / Router"]
        CGW["Customer Gateway (CGW)"]
    end

    subgraph AWS["AWS Landing Zone - Workload Account"]
        subgraph VPC["VPC: 10.20.0.0/16"]
            subgraph APPNET["App Subnets: 10.20.10.0/24, 10.20.11.0/24"]
                APP["EKS / EC2 App Tier"]
            end

            subgraph DBNET["DB Subnets: 10.20.20.0/24, 10.20.21.0/24"]
                RDS["Amazon RDS PostgreSQL"]
                KMS["KMS Encryption Key"]
            end

            subgraph DMSNET["DMS Subnets: 10.20.30.0/24, 10.20.31.0/24"]
                DMS["AWS DMS Replication Instance"]
            end

            VGW["AWS Virtual Private Gateway (VGW)"]
            SGAPP["App Security Group"]
            SGDB["RDS Security Group"]
            SGDMS["DMS Security Group"]
            RT["Private Route Tables"]
            NACL["Network ACLs"]
        end

        CW["CloudWatch / Metrics / Alarms"]
        SM["Secrets Manager"]
        STATE["Terraform State (split by layer)"]
    end

    USERS --> SOURCE
    SOURCE --> FW
    FW --> CGW
    CGW --> VGW
    VGW --> RT
    RT --> DMS
    RT --> RDS

    SOURCE -->|Full Load + CDC| DMS
    DMS -->|Continuous Replication| RDS

    APP -->|Reads/Writes after cutover| RDS
    APP --> SGAPP
    SGAPP --> SGDB
    SGDB --> RDS

    DMS --> SGDMS
    SGDMS --> DMS
    DMS --> CW
    RDS --> CW
    RDS --> KMS
    SM --> RDS
    STATE --> AWS



# Production Runbook: On-prem to AWS RDS Migration with DMS and Site-to-Site VPN

## 1. Project readiness checklist
- [ ] Confirm source database engine, version, and compatibility with target RDS
- [ ] Confirm target PostgreSQL version is supported
- [ ] Confirm application can tolerate short cutover window
- [ ] Confirm rollback strategy exists before migration starts
- [ ] Identify all schemas and tables to migrate
- [ ] Confirm data volume and growth rate
- [ ] Confirm network connectivity from AWS to on-prem
- [ ] Confirm security team review is complete
- [ ] Confirm change window with stakeholders
- [ ] Confirm ownership of final cutover and rollback

## 2. Landing zone checklist
- [ ] Create or confirm workload account
- [ ] Confirm VPC is created in private networking model
- [ ] Confirm app, DB, and DMS subnets are reserved
- [ ] Confirm private route tables are configured
- [ ] Confirm no public route exists for DB/DMS subnets
- [ ] Confirm NACLs are restricted to approved traffic only
- [ ] Confirm VPC flow logs are enabled
- [ ] Confirm tagging standard is applied
- [ ] Confirm Terraform state is split by layer
- [ ] Confirm S3 backend + DynamoDB locking are in use

## 3. Network and VPN checklist
- [ ] Create AWS VPC
- [ ] Create app private subnet(s)
- [ ] Create DB private subnet(s)
- [ ] Create DMS private subnet(s)
- [ ] Create AWS Virtual Private Gateway
- [ ] Create Customer Gateway using on-prem public IP
- [ ] Create Site-to-Site VPN connection
- [ ] Configure on-prem firewall/router for IPsec
- [ ] Allow UDP 500
- [ ] Allow UDP 4500
- [ ] Allow ESP (Protocol 50)
- [ ] Add route from on-prem CIDR to AWS VPC CIDR
- [ ] Add route from AWS VPC CIDR to on-prem CIDR
- [ ] Validate tunnel is UP
- [ ] Validate IPsec SA and route propagation
- [ ] Confirm DMS subnet can reach on-prem source DB over VPN
- [ ] Confirm RDS subnet can reach DMS and app tiers only

## 4. Security checklist
- [ ] RDS is not publicly accessible
- [ ] DMS instance is not publicly accessible
- [ ] Security groups are least privilege
- [ ] DMS SG allows only on-prem DB port from source CIDR
- [ ] RDS SG allows only DMS SG and app SG
- [ ] App SG allows only application traffic
- [ ] No 0.0.0.0/0 is allowed on DB or DMS
- [ ] Network ACLs allow minimum required traffic
- [ ] Secrets are stored in AWS Secrets Manager or vault
- [ ] KMS key is enabled and rotation is configured
- [ ] Encryption at rest is enabled on all database storage
- [ ] TLS is enforced where supported
- [ ] IAM is least privilege

## 5. Target database setup checklist
- [ ] Create RDS subnet group
- [ ] Create RDS PostgreSQL instance
- [ ] Enable Multi-AZ
- [ ] Enable storage encryption
- [ ] Configure KMS key
- [ ] Enable backups
- [ ] Configure backup retention window
- [ ] Set maintenance window
- [ ] Enable deletion protection
- [ ] Set final snapshot behavior
- [ ] Configure monitoring and alarms
- [ ] Confirm security groups are correct
- [ ] Validate from app tier or DMS subnet

## 6. DMS setup checklist
- [ ] Create DMS replication subnet group
- [ ] Create DMS replication instance in private subnet
- [ ] Set instance class and storage
- [ ] Enable Multi-AZ if required
- [ ] Ensure instance is private only
- [ ] Create source endpoint for on-prem database
- [ ] Create target endpoint for AWS RDS
- [ ] Use SSL if supported
- [ ] Validate endpoints
- [ ] Create replication task with full-load + CDC
- [ ] Enable task logging
- [ ] Enable validation
- [ ] Monitor replication lag
- [ ] Keep DMS running during migration validation

## 7. Migration execution checklist
- [ ] Start full-load task
- [ ] Monitor task status and logs
- [ ] Validate initial schema sync
- [ ] Validate row counts on critical tables
- [ ] Validate checksum parity on key tables
- [ ] Resolve data type mismatches
- [ ] Validate application connectivity to RDS
- [ ] Start CDC mode and keep running
- [ ] Keep app on on-prem while data catches up
- [ ] Monitor replication lag closely
- [ ] Run final data validation
- [ ] Confirm there is no significant drift

## 8. Cutover checklist
- [ ] Pause app writes if necessary
- [ ] Confirm replication lag is near zero
- [ ] Confirm app can connect to RDS
- [ ] Confirm there are no unresolved DMS errors
- [ ] Switch application connection strings to RDS
- [ ] Re-enable application traffic
- [ ] Monitor application health and DB metrics
- [ ] Keep DMS running for 24–72 hours after cutover
- [ ] Confirm DB performance and app stability
- [ ] Keep rollback plan ready

## 9. Post-cutover stabilization checklist
- [ ] Monitor replication lag
- [ ] Monitor RDS CPU, memory, storage, and connections
- [ ] Monitor application error rate and latency
- [ ] Monitor CloudWatch alarms
- [ ] Confirm backups and snapshots are configured
- [ ] Confirm encryption keys are valid
- [ ] Confirm Security Groups are stable
- [ ] Validate no public route or public DB exposure
- [ ] Archive logs and migration reports
- [ ] Close out change request

## 10. Rollback checklist
- [ ] Confirm old on-prem database remains available
- [ ] Confirm backup or snapshot exists
- [ ] Confirm rollback contact path is known
- [ ] Revert app connection strings to on-prem
- [ ] Stop or disable DMS task
- [ ] Restore from snapshot if required
- [ ] Validate app and DB health
- [ ] Confirm no application data was lost
- [ ] Document rollback decision and timing





