# Bootstrap EC2 instances for Kubernetes

Creates:
  - 1 VPC (172.16.0.0/16) in eu-central-1 region (Frankfurt)
  - 3 public subnets (per AZ)
  - 3 private subnets (per AZ)
  - 3 Elastic IPs
  - 3 NAT gateways (per AZ) in public subnets
  - 3 bastion hosts (per AZ) in public subnets
  - 3 control hosts (Kubernetes control plane) (per AZ) in private subnets
  - 3 ingress hosts (per AZ) in public subnets
  - desired number of worker hosts (per AZ) in private subnets 

# Install prerequisites:
  - Terraform [0.12.x](https://releases.hashicorp.com/terraform/0.12.21/terraform_0.12.21_linux_amd64.zip) 
  - Ansible 2.9.x

Install pip packages (Ansible + Boto)

```sh
pip install -r requirements.txt
```

Copy tfvars example, use your own variables and run terraform

```sh
export AWS_ACCESS_KEY_ID="myaccesskey"
export AWS_SECRET_ACCESS_KEY="mysecretkey"
export EC2_INI_PATH=/path/to/this/repo/ansible/ec2.ini

cp main.tfvars.example main.tfvars
terraform apply -var-file="main.tfvars"
```

**Variables:**
  - `vpc_config:`
    - `name:` VPC name. Default `myvpc`
    - `public_key:` your SSH public key. Default is unusable.
    - `allowed_ssh:` list of networks with allowed SSH access. Default `["0.0.0.0/0"]`
    - `allowed_web:` list of networks with allowed Web access. Default `["0.0.0.0/0"]`
  - `bastion_config:`
    - `image_id:` AMI ID. Default is CentOS 7 `ami-04cf43aca3e6f3de3`
    - `instance_type:` EC2 instance type. Default `t2.micro`
    - `volume_size:` root volume size (Gb). Default `8`
    - `volume_type:` root volume type. Default `gp2`
    - `group:` value of `group` tag. Used in dynamic inventory. Default `bastion`
  - `ingress_config:`
    - `image_id:` AMI ID. Default is CentOS 7 `ami-04cf43aca3e6f3de3`
    - `instance_type:` EC2 instance type. Default `t2.micro`
    - `volume_size:` root volume size (Gb). Default `30`
    - `volume_type:` root volume type. Default `gp2`
    - `group:` value of `group` tag. Used in dynamic inventory. Default `ingress`
  - `control_config:`
    - `image_id:` AMI ID. Default is CentOS 7 `ami-04cf43aca3e6f3de3`
    - `instance_type:` EC2 instance type. Default `t2.micro` (not production)
    - `volume_size:` root volume size (Gb). Default `80`
    - `volume_type:` root volume type. Default `gp2` (not production)
    - `group:` value of `group` tag. Used in dynamic inventory. Default `control`
  - `worker_config:`
    - `image_id:` AMI ID. Default is CentOS 7 `ami-04cf43aca3e6f3de3`
    - `instance_type:` EC2 instance type. Default `t2.micro` (not production)
    - `volume_size:` root volume size (Gb). Default `160`
    - `volume_type:` root volume type. Default `gp2`
    - `worker_count:` workers count. Deploys `count` per AZ. Default `0`
    - `group:` value of `group` tag. Used in dynamic inventory. Default `worker`

Get one of your `bastions` public IP address and paste following to `~/.ssh/config`. Replace `1.2.3.4` with your bastion IP.

```sh
Host 172.16.*.*
  User centos
  IdentityFile ~/.ssh/ansible_rsa
  ProxyCommand ssh -W %h:%p 1.2.3.4
Host 1.2.3.4
  User centos
  IdentityFile ~/.ssh/ansible_rsa
  ForwardAgent yes
```
