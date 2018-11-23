
# Rakuten architecture stack

This reference architecture provides a set of YAML templates for deploying Rakuten test architecture ([Amazon ECS](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)) with [AWS CloudFormation](https://aws.amazon.com/cloudformation/).

## 10 steps for understanding the project.
1. VPC Basics. https://www.youtube.com/watch?v=7XnpdZF_COA&index=14&list=PLv2a_5pNAko0Mijc6mnv04xeOut443Wnk
2. Internet Gateway https://www.youtube.com/watch?v=pAOrBxZ7584&list=PLv2a_5pNAko0Mijc6mnv04xeOut443Wnk&index=15
3. Route tables https://www.youtube.com/watch?v=GrfOsWUVCfg&list=PLv2a_5pNAko0Mijc6mnv04xeOut443Wnk&index=16
4. VPC Subnets https://www.youtube.com/watch?v=KNT463WSjjY&list=PLv2a_5pNAko0Mijc6mnv04xeOut443Wnk&index=18
5. VPC Availability Zones https://www.youtube.com/watch?v=ET_CSqdGsYg&list=PLv2a_5pNAko0Mijc6mnv04xeOut443Wnk&index=19
6. Security Groups https://www.youtube.com/watch?v=-9j7BvAyb2w&list=PLv2a_5pNAko0Mijc6mnv04xeOut443Wnk&index=30
7. ECS Core concepts. https://www.youtube.com/watch?v=eq4wL2MiNqo


## Overview

 I created this architecture with automation and security in mind. The application and database are contained in a private subnet. The clients will be able to connect to the app using the load balancer. For access to the database, we will use the provided bastion host that automatically sync the public keys of the IAM users from the AWS account where its deployed.

The repository consists of a set of nested templates that deploy the following:

 - A [VPC](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Introduction.html) with public and private subnets in one region using two availability zones.
 - A pair of [NAT gateways](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-nat-gateway.html) (one in each zone) to handle outbound traffic.
 - [Application Load Balancer (ALB)](https://aws.amazon.com/elasticloadbalancing/applicationloadbalancer/)
 - For each environment (Production, Staging, Development). (For now only one environment deployed)
     - An ECS cluster
     - A Container: Debian with Flask
     -  MYSQL RDS
 - Centralized container logging with [Amazon CloudWatch Logs](http://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html).


### VPC architecture

This set of templates deploys the following network design:

| Resource | CIDR Range | Usable IPs | Description |
| --- | --- | --- | --- |
| VPC | 10.180.0.0/16 | 65,536 | The whole range used for the VPC and all subnets |
| Public Subnet | 10.180.8.0/21 | 2,041 | The public subnet in the first Availability Zone |
| Public Subnet | 10.180.16.0/21 | 2,041 | The public subnet in the second Availability Zone |
| Private Subnet | 10.180.24.0/21 | 2,041 | The production private subnet in the first Availability Zone |
| Private Subnet | 10.180.32.0/21 | 2,041 | The production private subnet in the second Availability Zone |
| Private Subnet | 10.180.40.0/21 | 2,041 | The staging private subnet in the first Availability Zone |
| Private Subnet | 10.180.48.0/21 | 2,041 | The staging private subnet in the second Availability Zone |
| Private Subnet | 10.180.56.0/21 | 2,041 | The development private subnet in the first Availability Zone |
| Private Subnet | 10.180.64.0/21 | 2,041 | The development private subnet in the second Availability Zone |


## How to reproduce the setup

1. Create the bucket used to store the CloudFormation files.

        aws cloudformation create-stack \
        --stack-name bucket \
        --capabilities CAPABILITY_NAMED_IAM \
        --template-body file://infrastructure/bucket.yaml \
        --region eu-west-1  

2. Upload the YAML files to the rakuten-infrastructure bucket to be able to deploy the multi-stack infrastructure.

        aws s3 sync ./ s3://rakuten-infrastructure --acl bucket-owner-full-control --acl public-read --exclude='.*'

3. Deploy the main stack of the app

        aws cloudformation create-stack \
        --stack-name master \
        --capabilities CAPABILITY_NAMED_IAM \
        --template-body file://master.yaml \
        --region eu-west-1 

4. The bastion host will automatically get the public key from IAM users. Add a public key to the IAM user to be able to log in on the bastion.

5. Log in the bastion. Example below.

        ssh eduard.feliu@54.72.112.230

6. Copy the file app.sql provided in the test and execute it using the MySQL client from the bastion host. The bastion host is located in the public subnet and has access to the RDS. Example below.

        [eduard.feliu@ip-10-180-10-81 ~]$ mysql --host=md1bmfwru3q7ko8.cmuor8zcenjr.eu-west-1.rds.amazonaws.com --user=root --password=12345678 -s rakutendb < app.sql
        [eduard.feliu@ip-10-180-10-81 ~]$


7. Create the ECR repository used by the Docker image that will contain the Flask App.

        aws cloudformation create-stack \
        --stack-name ecr \
        --capabilities CAPABILITY_NAMED_IAM \
        --template-body file://infrastructure/ecr.yaml \
        --region eu-west-1

8. Build and push the Docker image passing the account id and region as a parameter

        bash ./services/app/build_push_to_ecr.sh 220961139697 eu-west-1


9. In step 3, we created everything except for the ECS Service. Now that we have the database ready, Uncomment the block code found on the file infrastructure/app.yaml and update the stack.

        #   App:
        #       Type: AWS::CloudFormation::Stack
        #       Properties:
        #           TemplateURL: https://s3-eu-west-1.amazonaws.com/rakuten-infrastructure/services/app.yaml
        #           Parameters:
        #               VPC: !Ref VPC
        #               Cluster: !GetAtt ECSCluster.Outputs.Cluster
        #               Listener: !Ref Listener
        #               DNSLoadBalancer: !Ref DNSLoadBalancer
        #               ListenerPriority: 1
        #               RepositoryName: "app"
        #               MySQLHost: !GetAtt RDS.Outputs.RdsDbURL

        bash update_infra.sh

11. Use the internal DNS of the load balancer to check if the app works correctly.

        curl master-1337603368.eu-west-1.elb.amazonaws.com:5000

12. We already received the Hello world!

