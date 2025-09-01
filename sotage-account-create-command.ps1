$RG_STATE="rg-tfstates"
$LOC="eastus2"
$STG="sttfdemoxxxxx"   # nombre único global
$CONTAINER="tfstate"

az group create -n $RG_STATE -l $LOC
az storage account create -g $RG_STATE -n $STG -l $LOC --sku Standard_LRS
az storage container create --name $CONTAINER --account-name $STG