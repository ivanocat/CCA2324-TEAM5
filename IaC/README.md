# Infrastructure creation
## Pre-requisites
If not done previously, create a remote backend for the Terraform state locking (see this [README.md](./init-backend/README.md)). But, as the prior document says, it is not necessary since the backend **is already created**.

## Steps

1. Initialize the working directory containing Terraform configuration files:

```bash
    terraform init
```

2. Preview the changes that Terraform plans to make to the infrastructure:

```bash
    terraform plan
```

3. Execute the actions proposed in a Terraform plan. The `-auto-approve` flag skips interactive approval of plan before applying:

```bash
    terraform apply -auto-approve
```


## Expected infrastructure
The following image shows the infrastructure that comprises the project:

![Infrastructure of the project](../images/Infrastructure.drawio.png "Infrastructure of the project")