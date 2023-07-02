# K8S lab on GCP

The goald of this repository is to provide the necessary files and documentation to easily deploy a K8S cluster on GKE:

* taking advantage of the GCP Free Tier as much as possible
* following the GKE/K8S hardening configurations (as much as possible)

By default, it will deploy a one node cluster (with on `e2-medium` spot instance as the only worker node) in `us-east1-b` zone.

## Requirements

* `gcloud`
* `terraform`

## Setup of the GCP project

1. Execute this command with your newly created project ID:

   ```bash
   ./init.sh $PROJECT_ID
   ```

2. Change the values in the newly created `terraform.tfvars` to match your configuration.

3. `terraform apply` and enjoy.

## Switch between classic K8S cluster vs Autopilot cluster

1. In `terraform.tfvars`, switch `enable_autopilot` to the desired.
2. `terraform apply` and enjoy.

## Disabled features for enhanced security

* GKE Sandbox (uses gVisor to run your containers and better isolate them from the host)
* Disable master public endpoint (not done here for simplicity - you have to set up a bastion otherwise)

## TODO

* OPA
* Network Policies
* Example charts
