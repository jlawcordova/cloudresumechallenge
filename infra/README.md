# The Cloud Resume Challenge Infrastructure
The Cloud Resume Challenge is composed of an API (app) and a static site (web). Both of these components are deployed using Terraform.

# Deploying with Terraform
You must have [Terraform installed on your machine](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

## Deploy the App
Use the Terraform configuration in the [`app` directory](./app/) to deploy the app. Initialize the directory and apply the configuration.

```
# From the infra directory
cd app
terraform init
terraform apply
```

> Provide variables if needed during `terraform apply`. See the list of available variables [in the `app` directory](./app/).

After the terraform configuration has been applied, the HTTP API URL and the project name will be in the output like the following:

```
Outputs:

app_url = "https://io09188ly9.execute-api.ap-southeast-1.amazonaws.com/"
project = "cloud-resume-challenge-immune-sunbird"
```

## Deploy the Web

The web application needs to be built before deploying the web terraform configuration. Use the `app_url` as the base API URL when [building the web](../README.md#getting-started) from the project root.

```
# From the infra/app directory
cd ../..
REACT_APP_API_BASE_URL=https://api-resume.jlawcordova.com/
npm run build --workspace=web
```

This should create a build in `web/build` that will be used for deploying.

Use the Terraform configuration in the [`web` directory](./web/) to deploy the app. Initialize the directory and apply the configuration.

```
# From the project root directory
cd infra/web
terraform init
terraform apply -var="cloud-resume-challenge-immune-sunbird"
```

> Provide the project name as an input so that the web resources will be named and tagged similarly to the app resources.

After the terraform configuration has been applied, the domain of the web CloudFront distribution will be in the output like the following:

```
Outputs:

web_url = "d2sc59are2eenn.cloudfront.net"
```

You can check the domain in your browser to see the resume being served.