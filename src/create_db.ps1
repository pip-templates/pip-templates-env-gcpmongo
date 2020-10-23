#!/usr/bin/env pwsh

param
(
    [Alias("c", "Path")]
    [Parameter(Mandatory=$true, Position=0)]
    [string] $ConfigPath,
    [Alias("p")]
    [Parameter(Mandatory=$false, Position=1)]
    [string] $Prefix
)

$ErrorActionPreference = "Stop"

# Load support functions
$path = $PSScriptRoot
if ($path -eq "") { $path = "." }
. "$($path)/../lib/include.ps1"
$path = $PSScriptRoot
if ($path -eq "") { $path = "." }

# Read config and resources
$config = Read-EnvConfig -Path $ConfigPath
$resources = Read-EnvResources -Path $ConfigPath

# Select or create project
if ($resources.gcp_project_id -ne $null) {
    # Select existing project
    $currProjectId = gcloud config get-value project
    if ($currProjectId -ne $resources.gcp_project_id){
        gcloud config set project $($resources.gcp_project_id)
        if ($lastExitCode -eq 0) {
            Write-Host "Project with id $($resources.gcp_project_id) selected."
        }
    }
} else {
    # Create new project
    $resources.gcp_project_id = "$($config.gcp_project_name)".Replace(" ","-").ToLower()
    $create = Read-Host "Do you want to create a new GCP project with id [$($resources.gcp_project_id)]? (y/n)"
    if ($create.ToLower() -eq "y") {
        gcloud projects create $resources.gcp_project_id --name="$($config.gcp_project_name)"
        if ($lastExitCode -eq 0) {
            Write-Host "Project $($config.gcp_project_name) successfully created."
            $resources.gcp_project_number = $(gcloud projects list --format=json --filter="projectId:$($resources.gcp_project_id)" | ConvertFrom-Json).projectNumber
            gcloud config set project $($resources.gcp_project_id)

            # Link new project to billing account
            gcloud alpha billing accounts projects link $resources.gcp_project_id --billing-account="$($config.gcp_billing_account_id)"
        }
    } else {
        Write-Error "Project creation aborded and 'gcp_project_id' is missing in resource file..."
    }
}

# Set config values
Build-EnvTemplate -InputPath "$($path)/../templates/mongodb_config.yaml" `
    -OutputPath "$($path)/../temp/mongodb_config.yaml" -Params1 $config -Params2 $resources

# Create mongodb deployment
gcloud deployment-manager deployments create $config.mongodb_deployment_name --config "$path/../temp/mongodb_config.yaml"

if ($lastExitCode -ne 0) {
    Write-Error "Failed to create mongodb cluster. Watch logs above"
}

# Check firewall to access mongodb
if ($(gcloud compute firewall-rules list --format=json --filter="name:$($resources.gcp_project_id)-allow-mongodb").ToString() -eq "[]") {
    # Create firewall to access mongodb
    Write-Host "Creating firewall rule $($resources.gcp_project_id)-allow-mongodb..."
    gcloud compute --project="$($resources.gcp_project_id)" firewall-rules create "$($resources.gcp_project_id)-allow-mongodb" `
        --description="Access to default mongodb port" `
        --direction=INGRESS `
        --priority=1000 `
        --network=default `
        --action=ALLOW `
        --rules=tcp:27017 `
        --source-ranges="$($config.mongodb_allowed_ips)" `
        --target-tags="$($config.mongodb_deployment_name)-deployment"
} 

# Get mongodb endpoint
$resources.db_endpoint = $(gcloud compute instances list --format=json --filter="name:$($config.mongodb_deployment_name)-servers-vm-0" | ConvertFrom-Json).networkInterfaces.accessConfigs.natIP

# Write resources
Write-EnvResources -Path $ConfigPath -Resources $resources
