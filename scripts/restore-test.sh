#!/bin/bash

# Simple test script to simulate failover in EKS
set -e

BACKUP_NAME=${1:-daily-backup}

echo ">>> Deleting namespace to simulate outage"
kubectl delete namespace my-app || echo "Namespace already deleted"

echo ">>> Initiating restore from backup: $BACKUP_NAME"
velero restore create --from-backup $BACKUP_NAME --wait

echo ">>> Waiting for resources to be restored
sleep 60

echo ">>> Verifying deployment status"
kubectl get pods -n my-app

echo ">>> DR Restore test completed."
