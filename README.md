# Terraform · AKS + VNet + NSG (with Azure Storage backend)

This project deploys, using **Terraform**:

* **Resource Group**
* **Virtual Network (VNet)** with a dedicated **Subnet** for AKS
* **Network Security Group (NSG)** attached to the subnet
* **Azure Kubernetes Service (AKS)** with RBAC enabled, Azure CNI networking, and a VMSS-based system node pool

The project also configures a **remote backend** in **Azure Storage (Blob)** to store the **Terraform state**.

---

## 📂 Project structure

```
.
├─ backend.tf                  # Remote backend config in Azure Storage (use_azuread_auth = true)
├─ main.tf                     # RG, VNet, Subnet, NSG, and AKS cluster
├─ variables.tf                # Deployment variables
├─ outputs.tf                  # Outputs (RG, AKS, VNet/Subnet/NSG IDs)
├─ terraform.tfvars.example    # Example variable values (copy/rename to terraform.tfvars)
│
├─ main-sub.bicep              # Bicep (subscription scope): creates RG and deploys storage module
└─ stg-rg-scope.bicep          # Bicep (RG scope): creates Storage Account + Blob container "tfstate"
```

> **Note:** In `backend.tf` the backend uses **Azure AD authentication** (`use_azuread_auth = true`) to access the Storage Account. No access keys are used.

---

## ✅ Prerequisites

* **Azure CLI** (logged in with the right subscription)
* **Bicep CLI** (included with Azure CLI, run `az bicep upgrade` if needed)
* **Terraform** ≥ 1.6
* Permissions to:

  * Create **Resource Groups**, **Storage Accounts**, and **AKS clusters**
  * Assign **RBAC roles** on the Storage Account (Blob Data Contributor role)

---

## 🪣 Create the Storage Account backend (with Bicep)

We’ll use the included Bicep files to create the **Resource Group**, **Storage Account**, and the **Blob container** (`tfstate`) to hold the Terraform state.

### 1) Parameters (example)

* **Subscription**: target subscription for the backend
* **Backend RG**: `rg-tfstates` (or your choice)
* **Region**: e.g., `eastus2`
* **Storage Account name**: leave empty to auto-generate, or provide a valid one (3–24 chars, lowercase, globally unique)

### 2) Deploy the Bicep template (subscription scope)

```powershell
# Select subscription
az account set --subscription "<SUBSCRIPTION_ID>"

# Deploy main-sub.bicep at subscription scope
az deployment sub create `
  --name tf-backend-deploy `
  --location <REGION> `
  --template-file .\main-sub.bicep `
  --parameters rgName="<BACKEND_RG>" location="<REGION>" stgName="" containerName="tfstate"
```

* If `stgName=""`, the storage module will **auto-generate** a valid name.
* Outputs will include the resource group, storage account, and container.

## 🔑 Assign RBAC role to your identity

Grant your user identity the **Storage Blob Data Contributor** role on the Storage Account so Terraform can store state using Azure AD authentication:

```powershell
# Storage Account ID (scope for the role)
$scope = (az storage account show -g $rgName -n $stgName --query id -o tsv)

# Your current user object ID
$me = az ad signed-in-user show --query id -o tsv

# Assign Blob Data Contributor role
az role assignment create --assignee $me --role "Storage Blob Data Contributor" --scope $scope

---

## 🚀 Deploy the AKS cluster (Terraform)

### 1) Initialize Terraform

```powershell
cd terraform-aks-demo
terraform init -reconfigure
```

Terraform will configure the backend to use the Storage Account created earlier.

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
kubectl get pods -n kube-system -o wide
```

---

## 📊 Outputs

After deployment, Terraform provides:

* Resource Group name
* AKS cluster name
* Node resource group
* IDs of the VNet, Subnet, and NSG

---

## 🔮 Next steps for automation

* Add **CI/CD pipelines** (e.g., Azure DevOps or GitHub Actions) to automatically run `terraform plan`/`apply`.
* Configure **Terraform Cloud/Enterprise** or **remote backends** for team collaboration and state locking.
* Add **monitoring integration** (Azure Monitor, Container Insights).
* Create **additional node pools** (GPU, spot instances, etc.).
* Add **Azure Container Registry (ACR)** and grant AKS pull permissions.
* Expand Bicep modules for **multi-environment deployments** (dev, test, prod).

## 🔍 Resources visible in a clean cluster

In `kube-system` you should see:

* **coredns**
* **kube-proxy**
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

## Infrastructure deployment visualization

### 1) Deployment of the storage account to store Terraform logs.

![rgCreate](assets/rg-tfstates-create.png)
\- Creation of the resource group.

![strAccCreate](assets/storage-account-create.png)
\- Creation of the Storage Account in the previously created RG.

![armEnvVar](assets/storage-account--access-key.png)
\- Configuring the storage account access key as an environment variable.

![guiPOVstrAcc](assets/storage-account-deployed-GUI.png)
\- Azure GUI showing the deployed resource.

![containCreate](assets/container-create.png)
\- Creation of the container inside the storage account.

![guiPOVcontain](assets/storage-account-deployed-GUI.png)
\- GUI view of the container in Azure.

![logsTfstates](assets/tfstates-logs-GUI-azure.png)
\- Here you can see the logs being stored from Terraform events.

### 2) Deployment using Terraform

![terrInit](assets/terraform-init.png)
\- Command to initialize the deployment and download the providers.

Then the Terraform plan command is applied:

![terrPlan1](assets/terraform-plan-out1.png)

![terrPlan2](assets/terraform-plan-out2.png)

![terrPlan3](assets/terraform-plan-out3.png)

![terrPlan4](assets/terraform-plan-out3.png)

Then run terraform apply command:

![terrApply](assets/terraform-apply-out.png)
\- End of success message in the console after deploying the cluster.

![terrApplyVM](assets/terrafor-apply-out-GUI-azure.png)
\- Resources deployed to support the cluster.

![terrApplyAKS](assets/AKS-Vnet-NGS-deployed-GUI.png)
\- AKS cluster deployed and functional.

![kubectl](assets/kubectl-outputs.png)
\- Some kubectl commands to show the running cluster.

![clusterDeployments](assets/AKS-GUI-deployments.png)
\- Deployments visualized on Azure GUI.

![clusterPods](assets/AKS-GUI-pods.png)
\- Pods visualized on Azure GUI.