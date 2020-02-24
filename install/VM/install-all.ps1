# Installing docker desktop CE

https://stackoverflow.com/questions/41471819/installing-docker-with-script-on-windows/54038523#54038523

# First Download the installer (wget is slow...)
# wget https://download.docker.com/win/stable/Docker%20for%20Windows%20Installer.exe -OutFile docker-installer.exe

(New-Object System.Net.WebClient).DownloadFile('https://download.docker.com/win/stable/Docker%20for%20Windows%20Installer.exe', 'docker-installer.exe')
# Install
start-process -wait docker-installer.exe " install --quiet"

# Clean-up
rm docker-installer.exe

# Run
start-process "$env:ProgramFiles\docker\Docker\Docker for Windows.exe"

write-host "Done with Docker for windows."

## TODO problem with permission
Add-LocalGroupMember -Group "docker-users" -Member "admink8s"
#### net localgroup "docker-users" "admink8s" /add

# installing azure CLI 
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; 

Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'

write-host "Done with Azure Cli."

# installing VSC 

# https://social.technet.microsoft.com/wiki/contents/articles/35780.visual-studio-code-getting-started-with-powershell.aspx

Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?LinkID=623230'  -OutFile 'C:\Temp\VSCodeSetup-stable.exe' ; 
Start-Process -FilePath 'C:\Temp\VSCodeSetup-stable.exe' -ArgumentList '/SILENT /LOG=".\VSCodeSetup.log"' ; 

write-host "Done with Visual Studio Code."

### TODO adding extentions

Start-Process  -FilePath 'C:\Program Files (x86)\Microsoft VS Code\Code.exe' -ArgumentList '--install-extension ms-azuretools.vscode-docker'
Start-Process  -FilePath 'C:\Program Files (x86)\Microsoft VS Code\Code.exe' -ArgumentList '--install-extension ms-vscode.azure-account'
Start-Process  -FilePath 'C:\Program Files (x86)\Microsoft VS Code\Code.exe' -ArgumentList '--install-extension ms-vscode.azurecli'
Start-Process  -FilePath 'C:\Program Files (x86)\Microsoft VS Code\Code.exe' -ArgumentList '--install-extension ms-kubernetes-tools.vscode-kubernetes-tools'
Start-Process  -FilePath 'C:\Program Files (x86)\Microsoft VS Code\Code.exe' -ArgumentList '--install-extension ms-vscode-remote.remote-wsl'
Start-Process  -FilePath 'C:\Program Files (x86)\Microsoft VS Code\Code.exe' -ArgumentList '--install-extension redhat.vscode-yaml'

#### code --install-extension ms-azuretools.vscode-docker
#### code --install-extension ms-vscode.azure-account
#### code --install-extension ms-vscode.azurecli
#### code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
#### code --install-extension ms-vscode-remote.remote-wsl
#### code --install-extension redhat.vscode-yaml

# Installing GIT - OK 

# https://www.robvit.com/automation/install-git-with-powershell-on-windows/

function CheckAndInstallGit {

    Param(
        [string]$Repo,
        [string]$TempDir

    )
    
    try {

        git

    } Catch {
    
        Write-host "Git not available on your device. " -ForegroundColor Yellow
        Write-host ": Downloading and installing git..." -ForegroundColor Yellow
        $InstallGit = $True
    }

    If($InstallGit){
  
        $releases = "https://api.github.com/repos/$repo/git/releases"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $Response = (Invoke-WebRequest -Uri $releases -UseBasicParsing | ConvertFrom-Json)

        $DownloadUrl = $Response.assets | where{$_.name -match "-64-bit.exe" -and $_.name -notmatch "rc"} | sort created_at -Descending | select -First 1


        If(!(test-path $TempDir))
        {
              New-Item -ItemType Directory -Force -Path $TempDir | out-null
        }

        # --- Download the file to the current location
        Write-host "Trying to download $($repo) on your Device.." -ForegroundColor Yellow

        Try{
            $OutputPath = "$TempDir\$($DownloadUrl.name)"
            Invoke-RestMethod -Method Get -Uri $DownloadUrl.browser_download_url -OutFile $OutputPath -ErrorAction Stop
        
        } Catch {
            Write-host $_.exception.message
            Write-host "Failed to install Git on your laptop, download and install GIT Manually." -ForegroundColor Red
            Write-host "Download Location: https://gitforwindows.org/" -ForegroundColor Yellow 
        
        }
        
        Write-host "Trying to install GIT on your Device.." -ForegroundColor Yellow

        Try{
            $arguments = "/SILENT"
            Start-Process $OutputPath $arguments -Wait -ErrorAction Stop
        } Catch {
            Write-host $_.exception.message
            Write-host "Failed to install Git on your laptop, download and install GIT Manually." -ForegroundColor Red
            Write-host "Download Location: https://gitforwindows.org/" -ForegroundColor Yellow 
        }

    } Else {
        Write-host "Git is already installed, no action needed." -ForegroundColor Green
    }


}

CheckAndInstallGit -Repo "git-for-windows" -TempDir "c:\temp"

write-host "Done with Git for windows."


