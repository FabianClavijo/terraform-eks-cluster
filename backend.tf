# Usa Amazon S3 como backend remoto para el estado de Terraform.
# Requiere que existan el bucket y la clave (key) dentro del bucket.
# Puedes parametrizar estos valores vía `terraform init -backend-config`:
#   terraform init -backend-config="bucket=<MI_BUCKET>" \
#                 -backend-config="key=aks-demo/terraform.tfstate" \
#                 -backend-config="region=<REGION>" \
#                 [-backend-config="dynamodb_table=<TABLA_DYNAMODB>"]
terraform {
  backend "s3" {
    bucket = "tfstate-demo-yourunique123"
    key    = "eks-demo/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "tfstate-locks"
    encrypt        = true
  }
}