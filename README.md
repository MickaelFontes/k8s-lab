# K8S lab on GCP

The goald of this repo is to provide the necessary files and documentation to easily deploy a K8S cluster on GKE:

* taking advantage of the GCP Free Tier as much as possible
* following the GKE/K8S hardening configurations (as much as possible)

## Requirements

* `gcloud`
* `terraform`

## Setup of the GCP project

Activate the following APIs

* 

Create the Terraform State Bucket

Add the bucket to the Terraform file and apply another time

## Disabled features for enhanced security

* GKE Sandbox (uses gVisor to run your containers and isolate them from the host)
* Disable master public endpoint (for simplicity - you have to set up a bastion otherwise)

## TODO

* OPA
* Network Policies
