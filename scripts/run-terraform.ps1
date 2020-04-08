$environment = "plan"

Set-Location C:\terraform

Write-Host "*********** Initialize backend"
.\terraform init -backend-config="$env:USERPROFILE\Documents\GitHub\test\$environment.tfvars"

.\terraform workspace select $environment -no-color

Write-Host ""
Write-Host "*********** Run 'plan'"
.\terraform plan --var-file="$env:USERPROFILE\Documents\GitHub\test\vars\global.tfvars" --var-file="$env:USERPROFILE\Documents\GitHub\test\vars\$environment.tfvars" --out="$env:USERPROFILE\Documents\GitHub\test\tf.plan" -input=false
 
#Write-Host ""
#Write-Host "*********** Run 'apply'"
#terraform apply -no-color -input=false -auto-approve ./tf.plan