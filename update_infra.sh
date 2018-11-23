#!/usr/bin/env bash

 aws s3 sync ./ s3://rakuten-infrastructure --acl bucket-owner-full-control --acl public-read --exclude='.*'

 aws cloudformation update-stack \
 --stack-name master \
 --capabilities CAPABILITY_NAMED_IAM \
 --template-body file://master.yaml \
 --region eu-west-1 