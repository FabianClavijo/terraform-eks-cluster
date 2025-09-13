# Terraform · AKS + VNet + NSG (with Amazon S3 backend)

This project deploys, using **Terraform**:

* **Resource Group**
* **Virtual Network (VNet)** with a dedicated **Subnet** for AKS
* **Network Security Group (NSG)** attached to the subnet
* **Azure Kubernetes Service (AKS)** with RBAC enabled, Azure CNI networking, and a VMSS-based system node pool

The project also configures a **remote backend** in **Amazon S3** (with optional **DynamoDB** locking) to store the **Terraform state**.

---

## 📂 Project structure

```
.
├─ backend.tf                  # Remote backend config in AWS S3 (opcional DynamoDB para bloqueo)
├─ main.tf                     # RG, VNet, Subnet, NSG, and AKS cluster
├─ variables.tf                # Deployment variables
├─ outputs.tf                  # Outputs (RG, AKS, VNet/Subnet/NSG IDs)
└─ terraform.tfvars.example    # Example variable values (copy/rename to terraform.tfvars)
```

> **Note:** In `backend.tf` the backend is configured for **Amazon S3**. Proporciona el bucket, la región y (opcional) la tabla de DynamoDB mediante `terraform init -backend-config`.

---

## ✅ Prerequisites

* **Azure CLI** (logged in with the right subscription)
* **AWS CLI** (configurado con credenciales para S3/DynamoDB)
* **Terraform** ≥ 1.6
* Permissions to:

  * Create **Resource Groups** and **AKS clusters** en Azure
  * Create **S3 buckets** y (opcional) **tablas de DynamoDB** en AWS

---

## 🪣 Create el backend en S3

Crea un bucket en S3 para almacenar el estado de Terraform (reemplaza los valores de ejemplo):

```bash
aws s3api create-bucket --bucket <MI_BUCKET> --region <REGION> --create-bucket-configuration LocationConstraint=<REGION>
```

(Opcional) Crea una tabla de DynamoDB para el bloqueo de estado:

```bash
aws dynamodb create-table \
  --table-name <TABLA_DYNAMODB> \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region <REGION>
```

---

## 🚀 Deploy the AKS cluster (Terraform)

### 1) Initialize Terraform

```bash
cd terraform-aks-demo
terraform init \
  -backend-config="bucket=<MI_BUCKET>" \
  -backend-config="key=aks-demo/terraform.tfstate" \
  -backend-config="region=<REGION>" \
  [-backend-config="dynamodb_table=<TABLA_DYNAMODB>"] \
  -reconfigure
```

Terraform configurará el backend para usar el bucket de S3 (y la tabla de DynamoDB si se proporciona).

### 2) Review the plan

```powershell
terraform plan -var-file="terraform.tfvars.example"
```

### 3) Apply the configuration

```powershell
terraform apply -var-file="terraform.tfvars.example" -auto-approve
```

### 4) Connect to the AKS cluster

```powershell
# Capture outputs
$rg  = terraform output -raw resource_group_name
$aks = terraform output -raw aks_name

# Get AKS credentials for kubectl
az aks get-credentials --resource-group $rg --name $aks

# Validate
kubectl get nodes -o wide
@@ -154,84 +133,25 @@ In `kube-system` you should see:
* **azure-ip-masq-agent**
* **azure-cni pods**
* **metrics-server** (if enabled)
* **omsagent/ama-**\* (if monitoring enabled)

---

## 🧹 Cleanup

To remove all resources:

```powershell
terraform destroy -var-file="terraform.tfvars.example" -auto-approve
```

---

## ✅ Conclusions

* The project deploys a complete **basic production-ready AKS infrastructure** with networking and security.
* We ran into issues with **unregistered providers**, **quotas**, and **availability zones**, all solved.
* The infrastructure is ready to extend with **ACR**, **monitoring add-ons**, or **additional node pools**.

---