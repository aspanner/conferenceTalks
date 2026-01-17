cd terraform
terraform apply -auto-approve
cd ..

export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_NOCOWS=1

ansible-playbook -i ansible/inventory.aws_ec2.yml ansible/playbook.yml --private-key=terraform/fedora-key-auto.pem

./generate_user_list.sh 