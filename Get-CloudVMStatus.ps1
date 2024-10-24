function Get-CloudVMStatus {
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
