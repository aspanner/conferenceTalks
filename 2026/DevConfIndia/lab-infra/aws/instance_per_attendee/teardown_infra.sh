#!/bin/bash

# --- Configuration ---
TF_DIR="./terraform"
LOG_FILE="./teardown_$(date +%Y%m%d_%H%M%S).log"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' 

echo "--------------------------------------------------"
echo "🔍 ANALYZING INFRASTRUCTURE SCALE..."

# Dynamically count instances from Terraform output
INSTANCE_COUNT=$(terraform -chdir=$TF_DIR output -json instance_ips | jq '. | length')

if [ "$INSTANCE_COUNT" -eq 0 ] || [ -z "$INSTANCE_COUNT" ]; then
    echo -e "${YELLOW}⚠️  No managed instances found in Terraform state.${NC}"
    exit 0
fi

# Calculate stats for the warning
TOTAL_VCPU=$((INSTANCE_COUNT * 96))
TOTAL_RAM_GB=$((INSTANCE_COUNT * 192))
EST_COST_PER_HOUR=$(echo "$INSTANCE_COUNT * 4.08" | bc)

echo -e "${RED}⚠️  WARNING: TEARDOWN INITIATED${NC}"
echo -e "Count:      ${YELLOW}$INSTANCE_COUNT Bare Metal Instances${NC}"
echo -e "Resources:  $TOTAL_VCPU vCPUs | $TOTAL_RAM_GB GB RAM"
echo -e "Burn Rate:  ~$EST_COST_PER_HOUR USD/hour"
echo "--------------------------------------------------"

read -p "Confirm destruction of $INSTANCE_COUNT nodes? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Teardown aborted."
    exit 1
fi

echo "🛑 DESTROYING RESOURCES..."
terraform -chdir=$TF_DIR destroy -auto-approve | tee -a "$LOG_FILE"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "✅ ${GREEN}Infrastructure successfully cleared.${NC}"
    # Cleanup local sensitive files
    rm -f "$TF_DIR/fedora-key-auto.pem"
    echo "🧹 Local PEM key removed for security."
else
    echo -e "❌ ${RED}Destroy failed. Check $LOG_FILE immediately!${NC}"
fi