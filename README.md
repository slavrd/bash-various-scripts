# Various simple bash scripts

A collection of different bash scripts that do not belong to a specific project.

## Install Hashicorp products

Installs hashicorp products.

`./install_hc_product.sh <product> <version> <OS> <architecture>`

## Install Golang

Installs Golang.

`./install_golang.sh <golang_version> <OS> <ARCH>`
  
## TF EXEC

Executes `terraform` passing to it all the arguments provided to the script. Also append a `-var-file` flag with filename based on the current terraform workspace e.g. `current_workspace_name.tfvars` .

`./tf_exec.sh <plan|apply>`
