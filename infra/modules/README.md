# The Cloud Resume Challenge App Terraform Module

This module deploys the API application for [The Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/aws/) on AWS. This module is composed of DynamoDB tables, a Lambda function and an HTTP API Gateway.

![app infrastructure diagram](/docs/app-infra-diagram.png)

Additionally, CloudWatch alarms trigger Amazon SNS email notifications when errors occur on the API gateway and the lambda function.