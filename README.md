# RideShare Pro — Production Kubernetes Deployment on AWS EKS

A production-grade microservices rideshare platform deployed on Amazon EKS, demonstrating enterprise Kubernetes patterns including multi-AZ high availability, automated secret management, horizontal pod autoscaling, and full infrastructure-as-code with Terraform.

---

## Table of contents

- [Architecture overview](#architecture-overview)
- [System components](#system-components)
- [Infrastructure](#infrastructure)
- [Prerequisites](#prerequisites)
- [Repository structure](#repository-structure)
- [Deployment guide](#deployment-guide)
- [Secret management](#secret-management)
- [Ingress and routing](#ingress-and-routing)
- [Autoscaling](#autoscaling)
- [Observability](#observability)
- [Destroying infrastructure](#destroying-infrastructure)
- [Screenshots](#screenshots)

---

## Architecture overview

```
                        Internet
                           │
                    ┌──────▼──────┐
                    │  Route 53   │
                    │  DNS / CNAME│
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │    NGINX    │
                    │   Ingress   │
                    │(LoadBalancer│
                    └──────┬──────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
   ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐
   │   Rider     │  │   Driver    │  │    Trip     │
   │   Service   │  │   Service   │  │   Service   │
   └──────┬──────┘  └──────┬──────┘  └──────┬──────┘
          │                │                │
          └────────────────┼────────────────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
   ┌──────▼──────┐  ┌──────▼──────┐        │
   │   Aurora    │  │ ElastiCache │        │
   │ PostgreSQL  │  │    Redis    │        │
   └─────────────┘  └─────────────┘        │
                                    ┌──────▼──────┐
                                    │  Matching   │
                                    │   Service   │
                                    └─────────────┘
```

**Traffic flow:**
```
User → GoDaddy DNS → AWS LoadBalancer → NGINX Ingress Controller
     → Path-based routing → Individual microservices
     → AWS Aurora PostgreSQL (persistent data)
     → AWS ElastiCache Redis (real-time data, sessions)
```

---

## System components

### Backend microservices

| Service | Language | Port | Database | Description |
|---|---|---|---|---|
| Rider Service | TypeScript | 3001 | Aurora (`rider_db`) | Rider profiles, ride requests, auth |
| Driver Service | TypeScript | 3003 | Aurora (`driver_db`) | Driver profiles, vehicle management |
| Trip Service | Python | 3005 | Aurora (`trip_db`) + Redis | Trip lifecycle management |
| Matching Service | Go | 3004 | Aurora (`matching_db`) + Redis | Real-time driver-rider matching |
| Email Service | Python | 3002 | — | Transactional emails via Azure |
| Frontend | Next.js | 3000 | — | Rider-facing web application |

### Cluster-level tooling

| Tool | Namespace | Purpose |
|---|---|---|
| NGINX Ingress Controller | `ingress-nginx` | Traffic routing and TLS termination |
| cert-manager | `cert-manager` | Automated TLS certificates via Let's Encrypt |
| External Secrets Operator | `external-secrets` | Sync AWS Secrets Manager → K8s secrets |

### AWS managed services

| Service | Purpose |
|---|---|
| Amazon EKS | Managed Kubernetes control plane |
| Aurora PostgreSQL | Managed relational database |
| ElastiCache Redis | Managed in-memory cache and pub/sub |
| AWS Secrets Manager | Centralized secret storage |
| ECR | Container image registry |
| ALB | Load balancer for NGINX ingress |

---

## Infrastructure

All infrastructure is managed with Terraform and deployed via HCP Terraform Cloud.

### VPC layout

```
VPC: 10.0.0.0/16
├── Public subnets (EKS nodes, ALB)
│   ├── 10.0.1.0/24 — eu-north-1a
│   └── 10.0.2.0/24 — eu-north-1b
└── Private subnets (Aurora, ElastiCache)
    ├── 10.0.3.0/24 — eu-north-1a
    └── 10.0.4.0/24 — eu-north-1b
```

### EKS cluster

- **Cluster name:** `teleios-divine-dev-eks`
- **Version:** 1.33+
- **Node group:** `t3.medium`, 2 nodes, multi-AZ
- **OIDC provider:** enabled for IRSA
- **API access:** public + private endpoints

### Terraform modules

```
├── networking/aws-vpc      VPC, subnets, IGW, NAT Gateway, route tables
├── compute/aws-eks         EKS cluster, node group, IAM roles, OIDC, ALB
├── compute/aws-ec2         EC2 instances with ASG and launch templates
├── data/aws-rds            Aurora PostgreSQL cluster with subnet group
├── data/aws-redis          ElastiCache Redis replication group
└── storage/aws-s3          S3 buckets with versioning and lifecycle policies
```

---

## Prerequisites

- [Terraform CLI](https://developer.hashicorp.com/terraform/install) v1.0+
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- [Helm](https://helm.sh/docs/intro/install/) installed
- [Docker](https://docs.docker.com/get-docker/) installed
- HCP Terraform account with access to `teleios-devops` organization
- AWS account with appropriate IAM permissions

---

## Repository structure

```
e-commerce-infrastructure-aws/
│
├── terraform.tf              # HCP Terraform backend + all provider configs
├── variables.tf              # Root variable declarations
├── terraform.tfvars          # Active environment values
├── outputs.tf                # Infrastructure outputs
│
├── vpc.tf                    # Networking module call
├── eks.tf                    # EKS module call
├── ec2.tf                    # EC2 module call
├── rds.tf                    # RDS module call
├── redis.tf                  # Redis module call
├── s3.tf                     # S3 module call
├── secrets.tf                # AWS Secrets Manager — all service credentials
├── iam.tf                    # IRSA role for External Secrets Operator
├── helm.tf                   # Helm releases: ESO, cert-manager, NGINX
├── external-secrets.tf       # SecretStore + ExternalSecret per service
├── manifests.tf              # kubectl_manifest — applies all k8s YAML files
│
├── networking/aws-vpc/       # VPC module
├── compute/aws-eks/          # EKS module
├── compute/aws-ec2/          # EC2 module
├── data/aws-rds/             # Aurora RDS module
├── data/aws-redis/           # ElastiCache Redis module
├── storage/aws-s3/           # S3 module
│
└── k8s/                      # Git submodule → rideshare-k8s-manifests
    ├── applications/
    │   ├── rider-service/
    │   ├── driver-service/
    │   ├── trip-service/
    │   ├── matching-service/
    │   ├── email-service/
    │   ├── rideshare-frontend/
    │   └── db-init/
    └── platform/
        ├── ingress/
        ├── autoscaling/
        └── security/
```

---

## Deployment guide

### 1. Clone the repository with submodules

```bash
git clone --recurse-submodules https://github.com/ijeawele-divine/e-commerce-infrastructure-aws.git
cd e-commerce-infrastructure-aws
```

### 2. Authenticate with HCP Terraform

```bash
terraform login
terraform init
```

### 3. Configure sensitive variables in HCP Terraform

Go to **HCP Terraform → workspace → Variables** and add these as sensitive Terraform variables:

| Variable | Description |
|---|---|
| `master_username` | Aurora PostgreSQL master username |
| `master_password` | Aurora PostgreSQL master password |
| `jwt_secret` | JWT signing secret for auth services |
| `google_client_id` | Google OAuth client ID |
| `google_client_secret` | Google OAuth client secret |
| `azure_email_connection_string` | Azure Communication Services connection string |
| `sender_email` | Email sender address |
| `mapbox_access_token` | Mapbox API token for maps |

Add these as sensitive environment variables:

| Variable | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |
| `AWS_DEFAULT_REGION` | AWS region (eu-north-1) |

### 4. Deploy

Push to GitHub — HCP Terraform detects the push and triggers a plan automatically:

```bash
git add .
git commit -m "deploy rideshare platform"
git push origin main
```

Review the plan in HCP Terraform UI and click **Confirm & Apply**.

### 5. What gets deployed in one apply

```
1.  VPC, subnets, NAT Gateway, security groups
2.  EKS cluster + node group + OIDC provider
3.  Aurora PostgreSQL + ElastiCache Redis
4.  S3 buckets
5.  AWS Secrets Manager secrets (all service credentials)
6.  IAM role for External Secrets Operator (IRSA)
7.  Kubernetes namespaces
8.  Helm: External Secrets Operator → cert-manager → NGINX Ingress
9.  ClusterSecretStore + ExternalSecret per service
10. All application manifests (deployments, services, HPAs)
11. Cluster autoscaler + pod disruption budgets
12. Ingress rules + TLS certificate via Let's Encrypt
```

### 6. Configure DNS

After apply completes get the LoadBalancer hostname:

```bash
kubectl get svc -n ingress-nginx
```

Add a CNAME record in your DNS provider:
- **Name:** `rideshare`
- **Value:** `<LoadBalancer hostname>`

### 7. Initialize databases

After first deployment run the db-init job to create all databases:

```bash
kubectl logs job/db-init
```

If needed run migrations manually per service:

```bash
kubectl exec -it deployment/driver-service -- node /app/dist/migrations/createTable.js
kubectl exec -it deployment/rider-service -- node /app/dist/migrations/createTable.js
```

---

## Secret management

Secrets flow from Terraform → AWS Secrets Manager → External Secrets Operator → Kubernetes secrets → pods.

```
terraform.tfvars / HCP Terraform variables
          ↓
    secrets.tf creates secrets in AWS Secrets Manager
          ↓
    external-secrets.tf creates ExternalSecret resources
          ↓
    ESO syncs secrets into Kubernetes (refreshInterval: 1h)
          ↓
    Pods consume via envFrom.secretRef
```

Each service has its own secret in Secrets Manager:

| Secret name | Service |
|---|---|
| `teleios-divine-dev-rider-service` | Rider service |
| `teleios-divine-dev-driver-service` | Driver service |
| `teleios-divine-dev-trip-service` | Trip service |
| `teleios-divine-dev-matching-service` | Matching service |
| `teleios-divine-dev-email-service` | Email service |
| `teleios-divine-dev-frontend` | Frontend |

To force a secret sync:
```bash
kubectl annotate externalsecret rider-aws-secret \
  force-sync=$(date +%s) --overwrite
```

---

## Ingress and routing

All traffic enters through the NGINX Ingress Controller. Two ingress resources handle routing:

**API ingress** (`rideshare-api`) — routes to backend services:

| Path | Service | Port |
|---|---|---|
| `/api/v1/riders/.*` | rider-service | 80 |
| `/api/v1/drivers/.*` | driver-service | 80 |
| `/api/v1/trip/.*` | trip-service | 80 |
| `/api/trips/.*` | trip-service | 80 |
| `/fares/.*` | trip-service | 80 |
| `/api/v1/matching/.*` | matching-service | 80 |
| `/api/v1/email/.*` | email-service | 80 |
| `/ws/.*` | trip-service | 3006 |

**Frontend ingress** (`rideshare-frontend`) — catches all remaining traffic:

| Path | Service | Port |
|---|---|---|
| `/` | rideshare-frontend | 80 |

TLS is handled automatically by cert-manager using Let's Encrypt production issuer.

---

## Autoscaling

### Horizontal Pod Autoscaler

All stateless services have HPA configured:

| Service | Min replicas | Max replicas | CPU target |
|---|---|---|---|
| Rider service | 1 | 3 | 50% |
| Driver service | 1 | 3 | 50% |
| Trip service | 1 | 3 | 50% |
| Matching service | 1 | 3 | 50% |
| Email service | 1 | 3 | 50% |
| Frontend | 1 | 3 | 50% |

### Cluster autoscaler

The cluster autoscaler scales EKS node groups based on pending pod demand. Configured via `k8s/platform/autoscaling/cluster-autoscaler.yaml`.

---

## Observability

Check pod status:
```bash
kubectl get pods
kubectl get pods -w
```

View service logs:
```bash
kubectl logs -l app=rider-service -f
kubectl logs -l app=driver-service -f
kubectl logs -l app=trip-service -f
kubectl logs -l app=matching-service -f
```

Check ingress:
```bash
kubectl describe ingress rideshare-api
kubectl describe ingress rideshare-frontend
```

Check certificates:
```bash
kubectl get certificate
kubectl describe certificate tls-rideshare
```

Check secrets sync status:
```bash
kubectl get externalsecrets
kubectl describe externalsecret rider-aws-secret
```

Check HPA:
```bash
kubectl get hpa
```

---

## Destroying infrastructure

> All resources must be destroyed immediately after verifying deployment per project requirements.

### 1. Empty S3 buckets

```bash
aws s3 rm s3://teleios-divine-dev-assets --recursive
aws s3 rm s3://teleios-divine-dev-logs --recursive
```

### 2. Queue destroy in HCP Terraform

Go to **workspace → Settings → Destruction and Deletion → Queue Destroy Plan** → confirm.

### 3. Verify clean teardown

```bash
aws s3 ls | grep teleios
aws eks describe-cluster --name teleios-divine-dev-eks --region eu-north-1
aws elasticache describe-replication-groups --region eu-north-1
```

All commands should return no results.

---

## Screenshots

### HCP Terraform — successful apply
![HCP Terraform apply](./screenshots/01-hcp-terraform-apply.png)

### EKS cluster
![EKS cluster](./screenshots/02-eks-cluster.png)

### EKS node group
![Node group](./screenshots/03-node-group.png)

### All pods running
![Pods running](./screenshots/04-pods-running.png)

### VPC and subnets
![VPC](./screenshots/05-vpc.png)

### Aurora PostgreSQL
![RDS](./screenshots/06-rds.png)

### ElastiCache Redis
![Redis](./screenshots/07-elasticache.png)

### AWS Secrets Manager
![Secrets Manager](./screenshots/08-secrets-manager.png)

### NGINX Ingress + TLS certificate
![Ingress](./screenshots/09-ingress-certificate.png)

### Application live
![Application](./screenshots/10-application-live.png)

### Terraform destroy complete
![Destroy](./screenshots/11-destroy-complete.png)
