#!/bin/bash
echo "Generating Server Cheat Sheet..."
echo "--------------------------------------------------" > servers.txt

# Fetch IPs and Names from Terraform state
terraform -chdir=terraform output -json instance_ips | jq -r 'to_entries[] | "\(.key) \(.value)"' | while read -r name ip; do
    # Extract the number from the name (Fedora-Node-5 -> 5)
    num=$(echo $name | awk -F'-' '{print $3}')
    
    echo "SERVER: $name" >> servers.txt
    echo "Public IP: $ip" >> servers.txt
    echo "Admin:     redhat / redhat" >> servers.txt
    echo "Unique:    user$num / password$num" >> servers.txt
    echo "--------------------------------------------------" >> servers.txt
done

echo "Done! Check 'servers.txt' for your credentials."