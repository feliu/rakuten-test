#!/usr/bin/env bash

# update-stack of initial bucket containing the CloudFormation files of the infrastructure.
aws cloudformation update-stack \
 --stack-name bucket \
 --capabilities CAPABILITY_NAMED_IAM \
 --template-body file://infrastructure/bucket.yaml \
 --region eu-west-1 

aws cloudformation update-stack \
 --stack-name ecr \
 --capabilities CAPABILITY_NAMED_IAM \
 --template-body file://infrastructure/ecr.yaml \
 --region eu-west-1 

 aws s3 sync ./ s3://rakuten-infrastructure --acl bucket-owner-full-control --acl public-read --exclude='.*'

 aws cloudformation update-stack \
 --stack-name master \
 --capabilities CAPABILITY_NAMED_IAM \
 --template-body file://master.yaml \
 --region eu-west-1 