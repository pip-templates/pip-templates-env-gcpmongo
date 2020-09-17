# Overview

This is a built-in module to environment [pip-templates-env-master](https://github.com/pip-templates/pip-templates-env-master). 
This module stores scripts for management google cloud mongodb cluster.

# Usage

- Download this repository
- Copy *src* and *templates* folder to master template
- Add content of *.ps1.add* files to correspondent files from master template
- Add content of *config/config.db.json.add* to json config file from master template and set the required values

# Config parameters

Config variables description

| Variable | Default value | Description |
|----|----|---|
| gcp_billing_account_id | XXXXXX-XXXXXX-XXXXXX | Id of your billing account, can be get from https://console.cloud.google.com/billing |
| gcp_project_name | pip Templates | Name of google project |
| mongodb_deployment_name | pip-templates-mongodb | Name of google cloud mongodb deployment resource |
| mongodb_allowed_ips | 168.2.10.0/32,10.58.0.0/24 | List of ip addresses allowed to connect to mongodb. Splited by comma without space |
| mongodb_zone | us-east1-b | Google cloud availability zone |
| mongodb_rs_name | pip-templates-rs | Mongodb replica set name |
| mongodb_servers_count | 2 | Mongodb cluster servers count |
| mongodb_servers_machine_type | g1-small | Mongodb cluster servers machine type |
| mongodb_servers_machine_boot_disk_type | pd-standard | Mongodb cluster servers boot disk type |
| mongodb_servers_machine_boot_disk_size | 10 | Mongodb cluster servers boot disk size in GB |
| mongodb_servers_machine_disk_type | pd-standard | Mongodb cluster servers disk type |
| mongodb_servers_machine_disk_size | 1000 | Mongodb cluster servers disk size in GB |
| mongodb_servers_network | default | Name of google vpc network to deploy mongodb servers |
| mongodb_servers_subnetwork | default | Name of google vpc subnetwork to deploy mongodb servers |
| mongodb_servers_subnetwork_region | us-east1 | Region of google vpc subnetwork to deploy mongodb servers |
| mongodb_arbiters_count | 1 | Mongodb cluster arbiter machines count |
| mongodb_arbiters_machine_type | n1-standard-1 | Mongodb cluster arbiter machines type |
| mongodb_arbiters_machine_boot_disk_type | pd-standard | Mongodb cluster arbiter machines boot disk type |
| mongodb_arbiters_machine_boot_disk_size | 10 | Mongodb cluster arbiter machines boot disk size in GB |
| mongodb_arbiters_network | default | Name of google vpc network to deploy mongodb arbiters  |
| mongodb_arbiters_subnetwork | default | Name of google vpc subnetwork to deploy mongodb arbiters |
| mongodb_arbiters_subnetwork_region | us-east1 | Region of google vpc subnetwork to deploy mongodb arbiters |
