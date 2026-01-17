#!/bin/bash

# Configuration
KEY_FILE="./terraform/fedora-key-auto.pem"
LOG_FILE="verification_results.log"

echo "--------------------------------------------------"
echo "🔍 STARTING POST-INSTALL VERIFICATION"
echo "--------------------------------------------------"
echo "Results will be saved to: $LOG_FILE"
echo "" > $LOG_FILE

# Get IPs from Terraform
IPS=$(terraform -chdir=terraform output -json instance_ips | jq -r '.[]')
COUNT=1

for IP in $IPS; do
    echo -n "Checking Server $COUNT ($IP)... "
    
    # 1. Test Master SSH Key (Fedora User)
    ssh -i $KEY_FILE -o ConnectTimeout=5 -o StrictHostKeyChecking=no fedora@$IP "uptime" &> /dev/null
    if [ $? -eq 0 ]; then
        KEY_STATUS="✅ SSH KEY OK"
    else
        KEY_STATUS="❌ SSH KEY FAIL"
    fi

    # 2. Test 'redhat' Password Access
    sshpass -p 'redhat' ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no redhat@$IP "whoami" &> /dev/null
    if [ $? -eq 0 ]; then
        ADMIN_STATUS="✅ ADMIN PASS OK"
    else
        ADMIN_STATUS="❌ ADMIN PASS FAIL"
    fi

    # 3. Virtualization Capability Check
    # We check for vmx (Intel) or svm (AMD) flags in cpuinfo
    VIRT_CHECK=$(ssh -i $KEY_FILE -o StrictHostKeyChecking=no fedora@$IP "egrep -c '(vmx|svm)' /proc/cpuinfo")
    if [ "$VIRT_CHECK" -gt 0 ]; then
        VIRT_STATUS="🚀 KVM READY"
    else
        VIRT_STATUS="🐌 EMULATION ONLY"
    fi

    echo "$KEY_STATUS | $ADMIN_STATUS | $VIRT_STATUS"
    echo "Server $COUNT ($IP): $KEY_STATUS | $ADMIN_STATUS | $VIRT_STATUS" >> $LOG_FILE
    
    ((COUNT++))
done

echo ""
echo "--------------------------------------------------"
echo "VERIFICATION COMPLETE. Check $LOG_FILE for details."
echo "--------------------------------------------------"