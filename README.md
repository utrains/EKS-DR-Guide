## **Project Resume: EKS Disaster Recovery Implementation**

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


### **Deliverables**

1. **Epic Definition**

   * Project name, acceptance criteria, and measurable success indicators

2. **User Stories**

   * Structured tasks covering backup, replication, restoration, and testing

3. **Reference Architecture**

   * Multi-region EKS DR architecture with AWS-native and open-source tooling

4. **Automation Scripts**

   * Velero setup for Kubernetes backups
   * Terraform scripts for EKS re-provisioning
   * AWS Backup plans and replication configuration

5. **Testing & Validation**

   * Disaster recovery simulation runbook
   * Documentation of RTO (Recovery Time Objective) and RPO (Recovery Point Objective)


### **Success Criteria**

* Full recovery of applications and infrastructure in a new region within targeted RTO and RPO.
* Automated, auditable backup and replication processes.
* Documented, repeatable, and tested DR procedures.

Now let's go through it.

## 1. Epic Name

> **"Implementation of Cross-Region Disaster Recovery Strategy for EKS Workloads"**


## 2. Acceptance Criteria

* All persistent volumes (EBS) are backed up and replicated to another AWS region at least once per day.
* Kubernetes manifests (Deployments, Services, etc.) are exported, versioned, and restorable in a secondary EKS cluster.
* A script or pipeline is available to rebuild a fully functional cluster in another region, including secrets, volumes, and network configurations.
* A documented procedure for disaster simulation testing is implemented and validated.
* The entire process can be triggered via CI/CD or manually.


## 3. Initial User Stories

**US01 — EBS Volume Backup:**

> As an SRE, I want to automate the backup and cross-region replication of EBS volumes to ensure the availability of critical data in the event of a disaster.

**US02 — Kubernetes Resource Backup:**

> As an SRE, I want to use Velero to back up Kubernetes resources into a versioned S3 bucket to allow quick restoration.

**US03 — Automated Cluster Re-creation in Secondary Region:**

> As an SRE, I want to redeploy an identical EKS cluster in another region via Terraform, including worker nodes, to guarantee a fast recovery.

**US04 — Automated Restoration in Recovery Region:**

> As an SRE, I want to orchestrate the restoration of my Kubernetes and EBS backups in a remote cluster.

**US05 — Manual DR Simulation Test:**

> As an SRE, I want to trigger an on-demand disaster recovery test and receive a report on recovery time and data integrity.

## 4. EKS Disaster Recovery Architecture (Multi-region)

![image](https://github.com/user-attachments/assets/5a8e3f8c-f0fa-4210-aecd-b3e3c51c9ad1)

* **AWS Backup**: for EBS and RDS volumes
* **Velero**: for Kubernetes-native backups (ConfigMaps, Secrets, PVCs, etc.)
* **S3 cross-region replication**: to sync backups to the failover region
* **Terraform/Helm**: for infrastructure-as-code and automation

## 5. Automation Scripts (Velero + AWS Backup)

### Velero Installation (with AWS Plugin)

```bash
velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.7.0 \
    --bucket eks-velero-backup \
    --backup-location-config region=us-east-1 \
    --snapshot-location-config region=us-east-1 \
    --secret-file ./velero-credentials-aws
```

### Daily Backup Schedule

```bash
velero create schedule daily-backup \
  --schedule="0 1 * * *" \
  --include-namespaces my-app \
  --ttl 168h
```

### Restore in Secondary Cluster

```bash
velero restore create --from-backup daily-backup-2025-07-01-01-00
```

### AWS Backup Plan (Terraform Snippet)

```hcl
resource "aws_backup_plan" "eks_ebs_plan" {
  name = "eks-ebs-backup-plan"

  rule {
    rule_name         = "daily"
    target_vault_name = aws_backup_vault.eks_vault.name
    schedule          = "cron(0 1 * * ? *)"
    lifecycle {
      delete_after = 30
    }
  }
}
```

## Additional Deliverables

You can also provide the student with:

* A `README.md` file documenting the full DR approach
* Scripts for testing restoration
* Terraform module for building the secondary cluster
* An example GitHub Actions or Jenkins pipeline for triggering failover and recovery

