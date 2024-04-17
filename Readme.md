-> terraform init 

-> terraform plant (for dry run it will show what changes will be made)

-> terraform apply (for applying the changes)

-> terraform destroy (for destroying entire infra resource)

-> we can comment out or remove the code which we want to delete and terraform will remove that resource after terraform apply

-> in which order code is written does not matter

-> terraform state list  (list resource in state)

-> teraform state show  <resource> (shows details of resource)

->  output "server_id" {
   value = aws_instance.web-server-instance.id
} (it will show output on terminal)

-> terrafom destroy -target aws_instance.web-server-instance (will destroy specific resource)

-> variables have 3 properties 
    variable "subnet_prefix" {
        description = "cidr block for the subnet"
        default:
        type: 
}
to reference variable var.subnet_prefix

-> we can create terraform.tfvars to store variable (kinda works as .env)

-> terraform apply -var-file example.tfvars (if we have created file with other name or there are more than 1 file for variables we can choose specific file)

