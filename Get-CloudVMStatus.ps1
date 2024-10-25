function Get-CloudVMStatus {
    <#
    .SYNOPSIS
        Get the status of virtual machines across Azure, AWS and GCP.

    .DESCRIPTION
        This command retrieves the status information of Azure (virtual machine) /AWS (EC2 Instance) / GCP (Compute Engine)

    .NOTES
        Author: Naveen Kumar (https://www.linkedin.com/in/tnaveen-kumar/)

    .EXAMPLE
        PS C:\> Get-DbaMaxMemory -SqlInstance sqlcluster, sqlserver2012

        Get memory settings for instances "sqlcluster" and "sqlserver2012". Returns results in megabytes (MB).

    .EXAMPLE
        [21.77 sec] > Get-CloudVMStatus
        Please select a cloud provider:
        1. Azure Virtual Machines
        2. AWS EC2 Instances
        3. GCP Compute Engine
        Enter the number (1 for Azure, 2 for AWS, 3 for GCP): 2
        Fetching AWS EC2 Instances...
        Enter the AWS region: us-east-1
        EC2 Instance ID: i-03b12b2485b9d7 | Status: stopped
        EC2 Instance ID: i-0cc329cb7984dd | Status: stopped
        EC2 Instance ID: i-09e19c12b74f70 | Status: stopped
        EC2 Instance ID: i-09622afcfe0967 | Status: stopped
    .EXAMPLE
        [4.36 sec] > Get-CloudVMStatus
        Please select a cloud provider:
        1. Azure Virtual Machines
        2. AWS EC2 Instances
        3. GCP Compute Engine
        Enter the number (1 for Azure, 2 for AWS, 3 for GCP): 3
        Fetching GCP Compute Engine Instances...
        Enter the GCP Project ID: gcp-lab-4

        Name    Status
        ----    ------
        demo-vm TERMINATED
    #>

    $cloudOptions = @(
        "Azure (Virtual Machines)",
        "AWS (EC2 Instances)",
        "GCP (Compute Engine)"
    )

    Write-Host "Please select a cloud provider:"
    for ($i = 0; $i -lt $cloudOptions.Count; $i++) {
        Write-Host "$($i + 1). $($cloudOptions[$i])"
    }

    $choice = Read-Host "Enter the number (1 for Azure, 2 for AWS, 3 for GCP)"

    switch ($choice) {
        1 {
            Write-Host "Fetching Azure Virtual Machines..."
            
            $resourceGroup = Read-Host "Enter the Azure Resource Group"

            if (-not $resourceGroup) {
                Write-Host "Resource Group is mandatory for Azure." -ForegroundColor Red
                return
            }

            $vms = Get-AzVM -ResourceGroupName $resourceGroup -Status | Select-Object Name, PowerState

            if ($vms) {
                $vms | ForEach-Object {
                    $vmStatus = $_.PowerState -replace "PowerState/", ""
                    Write-Host ("VM Name: {0} | Status: {1}" -f $_.Name, $vmStatus)
                }
            } else {
                Write-Host "No Azure VMs found in Resource Group: $resourceGroup."
            }
        }
        2 {

            Write-Host "Fetching AWS EC2 Instances..."

            $region = Read-Host "Enter the AWS region"

            if (-not $region) {
                Write-Host "Region is mandatory for AWS." -ForegroundColor Red
                return
            }

            $instances = (Get-EC2Instance -Region $region).Instances | Select-Object InstanceId, State

            if ($instances) {
                $instances | ForEach-Object {
                    Write-Host ("EC2 Instance ID: {0} | Status: {1}" -f $_.InstanceId, $_.State.Name)
                }
            } else {
                Write-Host "No AWS EC2 instances found in Region: $region."
            }
        }
        3 {
            Write-Host "Fetching GCP Compute Engine Instances..."

            $projectID = Read-Host "Enter the GCP Project ID"

            if (-not $projectID) {
                Write-Host "Project ID is mandatory for GCP." -ForegroundColor Red
                return
            }

            $instances = Get-GceInstance -Project $projectID | Select-Object Name,Status | Out-String

            if ($instances) {
                Write-Host $instances
            } else {
                Write-Host "No GCP Compute Engine instances found in Project ID: $projectID."
            }
        }
        default {
            Write-Host "Invalid selection. Please choose 1, 2, or 3." -ForegroundColor Red
        }
    }
}
# Run the function
#Get-CloudVMStatus
