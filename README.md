# terraform

Personal Infrastructure as Code with Terraform

## Getting started

I started this on a Windows laptop using Git Bash as my terminal so it mimics Linux.
Everything can be done with plain Windows with Command Prompt or Powershell, though.

1. [Install Terraform.](https://learn.hashicorp.com/terraform/getting-started/install.html)
2. Create a Google Cloud account.
3. [Open the console and create a Service Account for Terraform in IAM & Admin](https://console.cloud.google.com/iam-admin/serviceaccounts).
   Grant the Terraform service account the role of Project Editor.
4. Go to [IAM](https://console.cloud.google.com/iam-admin/iam) in the console.
   Grant your Terraform service account the IAM Security Admin role.
5. Create a Key for the Terraform account and download its JSON file to a private directory with restricted permissions. I used `$HOME/private`.
   Keep in mind this account has elevated permissions: treat its credentials like your own.
6. Create a shell script to set up your environment variables recognized by the GCP Terraform Provider:

    ```shell
    #!/bin/bash
    export GOOGLE_APPLICATIONS_CREDENTIALS="$HOME/private/my-project.json"
    export GOOGLE_PROJECT="my-project"
    ```

7. Use the script to set the variables.
   
   ```shell
   . ~/private/gcp.sh
   ```

8. Add provider and Terraform state and state logs buckets code.
9. Init state.
   
   ```shell
   terraform init
   ```

10. Create a Terraform deployment plan.
    
    ```
    terraform plan -out tfplan
    ```

11. Apply the plan to set up the buckets. This saves state locally for the time being.
    
    ```shell
    terraform apply "tfplan"
    ```

12. Add remote state code.
    I recommend you use a prefix that mirrors your Terraform repository path to the directory for which the state is being saved. 

    ```terraform
    terraform {
      backend "gcs" {
        bucket = "my_terraform_state_bucket"
        prefix = "terraform/gcp/global" // Prefix for this directory's state
      }
    }
    ```

13. Init state again and answer `yes` to move your state to the bucket: `terraform init`
