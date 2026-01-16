This is the infrastructure provisioning and config for our hands on lab:
Carry Your Cluster with You: Bootable OS Image with Pre-Baked MicroShift & Workloads
- Workshop Duration: 75 minutes
- Hands-on: ~40–45 minutes
- Audience: Engineers, Architects, Consultants, Edge Practitioners
- Authors: (Your Name + Co-Speakers)
- Git Repo for Hands-on: https://github.com/hsirsulw/airgapped-microshift-deployment-centos/blob/main/README.md

```
pip install boto3

export AWS_ACCESS_KEY_ID="your_key"
export AWS_SECRET_ACCESS_KEY="your_secret"
export AWS_DEFAULT_REGION="us-east-1"

```
lab-infra/
├── terraform/
│   ├── main.tf          # Main infrastructure code
│   ├── variables.tf     # Configurable variables
│   └── outputs.tf       # Data to pass to Ansible
└── ansible/
    ├── ansible.cfg      # Ansible settings
    ├── inventory.aws_ec2.yml # Dynamic inventory config
    └── playbook.yml     # Configuration tasks

Check that the dynamic invetory is working via 
```
ansible-inventory -i ansible/inventory.aws_ec2.yml --graph
```
then run the playbook:
```
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_NOCOWS=1

ansible-playbook -i ansible/inventory.aws_ec2.yml ansible/playbook.yml --private-key=terraform/fedora-key-auto.pem
```
To login use

```
ssh -i terraform/fedora-key-auto.pem fedora@<SERVER_IP>
```
or
```
ssh redhat@<SERVER_IP>
```
