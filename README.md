
# AdAsia architecture stack

This reference architecture provides a set of YAML templates for deploying Rakuten test architecture ([Amazon ECS](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)) with [AWS CloudFormation](https://aws.amazon.com/cloudformation/).

## 10 steps for understanding the project.
1. VPC Basics. https://www.youtube.com/watch?v=7XnpdZF_COA&index=14&list=PLv2a_5pNAko0Mijc6mnv04xeOut443Wnk
2. Internet Gateway https://www.youtube.com/watch?v=pAOrBxZ7584&list=PLv2a_5pNAko0Mijc6mnv04xeOut443Wnk&index=15
3. Route tables https://www.youtube.com/watch?v=GrfOsWUVCfg&list=PLv2a_5pNAko0Mijc6mnv04xeOut443Wnk&index=16
4. VPC Subnets https://www.youtube.com/watch?v=KNT463WSjjY&list=PLv2a_5pNAko0Mijc6mnv04xeOut443Wnk&index=18
5. VPC Availability Zones https://www.youtube.com/watch?v=ET_CSqdGsYg&list=PLv2a_5pNAko0Mijc6mnv04xeOut443Wnk&index=19
6. Security Groups https://www.youtube.com/watch?v=-9j7BvAyb2w&list=PLv2a_5pNAko0Mijc6mnv04xeOut443Wnk&index=30
7. ECS Core concepts. https://www.youtube.com/watch?v=eq4wL2MiNqo
8. Docker on AWS - the right way. https://www.youtube.com/watch?v=ncN47QMt7nw
9. Check the ref. architecure for ECS. Try to understand the project. Run the sample. https://github.com/aws-samples/ecs-refarch-cloudformation


## Overview

![infrastructure-overview](images/architecture_overview.png)


The repository consists of a set of nested templates that deploy the following:

 - A [VPC](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Introduction.html) with public and private subnets in one region using two availability zones.
 - A pair of [NAT gateways](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-nat-gateway.html) (one in each zone) to handle outbound traffic.
 - [Application Load Balancer (ALB)](https://aws.amazon.com/elasticloadbalancing/applicationloadbalancer/) host-based routes for each ECS service to route the inbound traffic to the correct service.
 - For each environment (Production, Staging, Development)
     - An ECS cluster ( Depends on the VPC ).
     - A container inside EC2: Debian with Flask
     -  MYSQL RDS
 - Centralized container logging with [Amazon CloudWatch Logs](http://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html).

## Stack details

| Template | Description |
| --- | --- | 
| [master.yaml](master.yaml) | This is the master template - deploy it to CloudFormation and it includes all of the others automatically. |
| [infrastructure/vpc.yaml](infrastructure/vpc.yaml) | This template deploys a VPC with a pair of public and private subnets spread across two Availability Zones. It deploys an [Internet gateway](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Internet_Gateway.html), with a default route on the public subnets. It deploys a pair of NAT gateways (one in each zone), and default routes for them in the private subnets. |
| [infrastructure/database.yaml](infrastructure/database.yaml) | This template deploys an RDS inside a private subnet of the VPC. |
| [infrastructure/security-groups.yaml](infrastructure/security-groups.yaml) | This template contains the [security groups](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_SecurityGroups.html) required by the entire stack. They are created in a separate nested template, so that they can be referenced by all of the other nested templates. |
| [infrastructure/load-balancers.yaml](infrastructure/load-balancers.yaml) | This template deploys an ALB to the public subnets, which exposes the various ECS services. It is created in in a separate nested template, so that it can be referenced by all of the other nested templates and so that the various ECS services can register with it. |
| [infrastructure/ecs-cluster.yaml](infrastructure/ecs-cluster.yaml) | This template deploys an ECS cluster to the private subnets. |


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

1. Lorem ipsum dium