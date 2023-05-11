# Deploy to EC2 Demo

## VPC & Subnet

After updating the `main.tf` and `terraform.tfvars` files to define the necessary variables and values:

    terraform plan
    terraform apply --auto-approve

we can then check the created resource on AWS:

![image](https://github.com/ArshaShiri/DevOpsBootcampTerraformDeployToEC2/assets/18715119/8d201c3b-8f20-4f0b-a309-052f7b9e1a0c)
![image](https://github.com/ArshaShiri/DevOpsBootcampTerraformDeployToEC2/assets/18715119/e68cd7fa-2009-4088-8e76-887f7bf88af6)

Some default resources like Route table and Network ACL are created as well:
![image](https://github.com/ArshaShiri/DevOpsBootcampTerraformDeployToEC2/assets/18715119/c5a21bf3-579a-4b04-bca4-85daae4fc10d)

Route table details:
![image](https://github.com/ArshaShiri/DevOpsBootcampTerraformDeployToEC2/assets/18715119/e4cc1754-c502-4f83-9af3-3570c2128a65)

In order to connect the VPC to the internet, route table and internet gateway are defined in `main.tf` file. After applying this via terraform, we can see the new route table is created in AWS:
![image](https://github.com/ArshaShiri/DevOpsBootcampTerraformDeployToEC2/assets/18715119/25624a46-efc8-4cfa-88a7-137403ff1641)
![image](https://github.com/ArshaShiri/DevOpsBootcampTerraformDeployToEC2/assets/18715119/2de5df3f-2df7-4d9e-8586-bad43308c4c7)

Finally we need to add subnet association as well which is done in terraform as a new resoruce. After applying the new configurations, we can check the result:
![image](https://github.com/ArshaShiri/DevOpsBootcampTerraformDeployToEC2/assets/18715119/8e77d0c2-6778-4528-9faa-8dddd9eda619)


Instead of defining a new route table, we can also use the default one. The new resource is defined under `aws_default_route_table`. After applying, the results can be seen in AWS:
![image](https://github.com/ArshaShiri/DevOpsBootcampTerraformDeployToEC2/assets/18715119/76dc499e-f419-4301-8304-4a2ce3fb3b2f)
