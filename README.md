# terrask8s

(terra-skates) Create a Kubernetes cluster on AWS, where you manage the nodes, with Terraform.

## Why terrask8s

### For you

If you are preparing for the Certified Kubernetes Application Developer (CKAD) or a similar exam from the Linux Foundation / Cloud Native Computing Foundation, this repository can stand up the AWS infrastructure so you can focus on the exam itself.

**A word of caution on managed services:** Large cloud providers offer managed Kubernetes services (Amazon EKS, Azure AKS, etc.) where they manage the underlying nodes for you. For production workloads, a managed service is almost always cheaper, more resilient, and easier to operate than self-managed nodes.

This repository is for learning. If you want to understand what's happening underneath the hood, this is a good place to start.

### For me

A job interview came up for a Terraform and AWS DevOps position. I had done both for years, but had recently been working with different technology and my Terraform was rusty. The best way to get unrusty is to build something.

I've done Terraform, Ansible, and Kubernetes in past jobs, so why not build a Terraform repository that creates a Kubernetes cluster? There may be room for Ansible in configuration management down the road, but the MVP focuses on Terraform.

---

## Setup

### 1. Bootstrap

Before anything else, you need to create the S3 bucket and DynamoDB table that Terraform will use to store state and coordinate locks. This lives in its own isolated directory to avoid the chicken-and-egg problem of Terraform managing the very resources it depends on.

```bash
cd bootstrap
terraform init
terraform apply
```

See [bootstrap/README.md](bootstrap/README.md) for full details, including how to back up the bootstrap state and how to tear it down later.

After `apply` completes, Terraform will print a `project_s3_configuration` output. Keep it — you'll need it in the next step.

### 2. Configure dev/main.tf

Open `dev/main.tf` and uncomment the `backend "s3"` block, filling in the values from the `project_s3_configuration` output from the bootstrap step:

```hcl
backend "s3" {
    bucket         = "<your-bucket>"
    key            = "global/k8s/terraform.tfstate"
    region         = "<your-region>"
    dynamodb_table = "terraform-lock"
    encrypt        = true
}
```

Also uncomment and set the AWS region in the `provider "aws"` block.

### 3. Deploy

```bash
cd dev
terraform init
terraform apply
```

---

## Tear-down

### 1. Destroy main infrastructure *(coming soon)*

### 2. Tear down bootstrap

Once all main infrastructure is destroyed, follow the tear-down instructions in [bootstrap/README.md](bootstrap/README.md).
