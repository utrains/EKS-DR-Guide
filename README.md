# **Project Resume: EKS Disaster Recovery Implementation**

### **Objective**

Design and implement a **cross-region Disaster Recovery (DR) strategy** for an existing EKS-based production environment. The goal is to ensure **minimal downtime and data loss** in the event of a regional failure by enabling automated restoration of workloads, data, and infrastructure in a secondary AWS region.

### **Scope**

* Backup and replication of Kubernetes resources and EBS volumes.
* Infrastructure as Code (IaC) deployment of a standby EKS cluster in a secondary region.
* Restore orchestration for both infrastructure and applications.
* Validation through automated or manual DR simulation tests.

### **Current Environment**

* **Primary Region Tools**:

  * EKS, EBS, S3, EFS
  * AWS Backup
  * AWS DataSync
  * Kubernetes-native workloads

* **Current DR Approach**:

  * Single-region backup using AWS Backup and DataSync
  * No automated cross-region failover or cluster recovery


Now let's go through it.

## 1. Epic Name

> **"Implementation of Cross-Region Disaster Recovery Strategy for EKS Workloads"**


## 2. Acceptance Criteria

* All persistent volumes (EBS) are backed up and replicated to another AWS region at least once per day.
* Kubernetes manifests (Deployments, Services, etc.) are exported, versioned, and restorable in a secondary EKS cluster.
* A script or pipeline is available to rebuild a fully functional cluster in another region, including secrets, volumes, and network configurations.
* A documented procedure for disaster simulation testing is implemented and validated.
* The entire process can be triggered via CI/CD or manually.


## 3. EKS Disaster Recovery Architecture (Multi-region)

![image](https://github.com/user-attachments/assets/5a8e3f8c-f0fa-4210-aecd-b3e3c51c9ad1)

* **AWS Backup**: for EBS and RDS volumes
* **Velero**: for Kubernetes-native backups (ConfigMaps, Secrets, PVCs, etc.)
* **S3 cross-region replication**: to sync backups to the failover region
* **Terraform/Helm**: for infrastructure-as-code and automation

## 4. EKS Disaster Recovery (DR) Strategy 

### Overview
This project implements a cross-region Disaster Recovery (DR) solution for Kubernetes workloads hosted on Amazon EKS. The design ensures that in case of a regional outage, critical workloads and data can be restored in a secondary AWS region.

### a. Backup & Replication
- **Velero**: Backup and restore Kubernetes resources and persistent volumes.
- **AWS Backup**: Schedule and manage EBS volume backups.
- **S3 with cross-region replication**: Store Velero backups and replicate them to the target region.

### b. Infrastructure as Code
- **Terraform**: Provision EKS clusters and related infrastructure in the secondary region.

### c. DR Orchestration
- **GitHub Actions / Jenkins Pipelines**: Trigger automated failover and restore operations.

## 5. Setup Instructions

### Step 1: Install Velero in Primary Region
```bash
velero install \
  --provider aws \
  --plugins velero/velero-plugin-for-aws:v1.7.0 \
  --bucket eks-velero-backup \
  --backup-location-config region=us-east-1 \
  --snapshot-location-config region=us-east-1 \
  --secret-file ./velero-credentials-aws
```

### Step 2: Schedule Daily Backups
```bash
velero create schedule daily-backup \
  --schedule="0 1 * * *" \
  --include-namespaces my-app \
  --ttl 168h
```

### Step 3: Enable S3 Cross-Region Replication
Use a replication rule in the S3 bucket settings to replicate Velero backups to the secondary region.

### Step 4: Terraform Deployment in Secondary Region
Provision standby infrastructure (see `terraform/` folder).

### Step 5: Restore in Secondary Region
```bash
velero restore create --from-backup daily-backup-2025-07-01-01-00
```

## 6. Files Included
- `scripts/restore-test.sh`: Script to simulate and test recovery.
- `terraform/`: Contains Terraform modules to deploy EKS and supporting resources.
- `.github/workflows/failover.yml`: GitHub Actions pipeline to trigger DR restoration.

## 7. Testing the DR Plan
Use the script and pipeline provided to:
- Delete a namespace or simulate outage
- Restore the namespace from Velero backups in another region
- Validate application health and data integrity

## Conclusion

You have been through our Disaster Recovery (DR) strategy using an active-passive model across two AWS regions. The primary EKS cluster operates in Region A, while a standby cluster is provisioned in Region B and kept in sync through automation. To ensure application state and data integrity, we use Velero to back up Kubernetes resources and persistent volumes (EBS). These backups are stored in an S3 bucket with cross-region replication enabled to the standby region. On the infrastructure side, the entire secondary environment is defined using Terraform, allowing for consistent and repeatable provisioning of the failover cluster. Additionally, we leverage a CI/CD pipeline (GitHub Actions) to automate the failover process. This includes deploying infrastructure, configuring Velero, and triggering the restore from the most recent backup. 
