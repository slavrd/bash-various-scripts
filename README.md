# Various simple bash scripts

## Install Hashicorp products

`./install_hc_product.sh <product> <version> <OS> <architecture>`

## Install Golang

`./install_golang.sh <golang_version> <OS> <ARCH>`
  
## Install Golang

Executes `terraform` passing to it all the arguments provided to the script. Also append a `-var-file` flag with filename based on the current terraform workspace e.g. `current_workspace_name.tfvars`

`./tf_exec.sh <plan|apply>`
