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

## Security Group

The `aws_security_group` resource is defined for this section. Don't forget to set the `my_ip` variable to your public ip address before applying. The results can be seen in AWS:
![image](https://github.com/ArshaShiri/DevOpsBootcampTerraformDeployToEC2/assets/18715119/6940d71c-f7cc-4b1b-b107-80c93ca494c0)

Similarly, we can also define `aws_default_security_group`
![image](https://github.com/ArshaShiri/DevOpsBootcampTerraformDeployToEC2/assets/18715119/e9bf0817-4cfc-494e-b736-7f231cbf1273)

## EC2 Instance

In order to SSH in the EC2 server, we need to createa a key value pair in AWS under EC2 service:
![image](https://github.com/ArshaShiri/DevOpsBootcampTerraformDeployToEC2/assets/18715119/c78bc474-b44a-4435-bf57-22c2f5292e5c)
![image](https://github.com/ArshaShiri/DevOpsBootcampTerraformDeployToEC2/assets/18715119/e802270a-66f6-45e8-888b-5406a60aff1b)

After creaation, the private key is downloaded automatically and the key value pair can be seen in AWS:
![image](https://github.com/ArshaShiri/DevOpsBootcampTerraformDeployToEC2/assets/18715119/0a32e41f-f45d-41a2-96e3-5ccd1cceca62)

    # We need to move this file to .ssh folder
    mv server-key-pair.pem .ssh/
    
    # We also need to restrict the premisison (write premisison only) AWS will reject the connection if the premission is not set correctly.
    chmod 400 .ssh/server-key-pair.pem
    ls -l .ssh/server-key-pair.pem
    
After applying the new cofig we can see the new EC2 instance:
![image](https://github.com/ArshaShiri/DevOpsBootcampTerraformDeployToEC2/assets/18715119/57eb76f5-e7da-4cb1-b3b7-09a76dfccc49)

We can also ssh into our server:

    ssh -i .ssh/server-key-pair.pem ec2-user@{public-ip-address}

It is much better to automate key-value creation. It is demonstrated how to do so by the use of `aws_key_pair` resource and defining the corresponding variable public_key_location. The public key absolute path can be given and terraform will use the value.