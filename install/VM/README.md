## 1.  Create VM with Windows 10 Pro in Azure

```bash
az group create --name k8s-vm --location northeurope
```

#### Validate 
```bash
az group deployment validate \
  --resource-group k8s-vm \
  --template-file ./azuredeploy.json

```
#### Create 
```bash
az group deployment create \
  --name k8s-window10-vm \
  --resource-group k8s-vm \
  --template-file ./azuredeploy.json

```

## 2. Enable Hyper-V  and WSL -> restart needed several times 
Enable-WindowsOptionalFeature -Online -FeatureName:Microsoft-Hyper-V -All
#### restart 
# Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart
### restart 
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
#### restart 
Invoke-WebRequest -Uri https://wsldownload.azureedge.net/Ubuntu_1604.2019.523.0_x64.appx -OutFile Ubuntu.appx -UseBasicParsing
Add-AppxPackage .\Ubuntu.appx

## 3. install git bash, Visual studio code 
Add  install-all.ps1 as VM extention.


