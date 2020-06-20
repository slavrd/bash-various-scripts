#!/usr/bin/env bash
# Executes terraform with the passed command line args and appends .tfvar file named based on the current terraform workspace.

ws=$(terraform workspace show)

echo -e "\nTF WORKSPACE: \033[32m$ws\n"
sleep 2

terraform $@ -var-file="${ws}.tfvars"
