# This script installs Windows Subsystem for Linux and installs Ubuntu
# WSL install steps are based on the steps here: https://learn.microsoft.com/en-us/windows/wsl/install-manual
#
$is_build = $args[0] -eq "build"


$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$is_admin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (!$is_admin){
	echo "You need to run this script as an Administrator"
	exit 1
}

$vmp_installed=Get-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -Online | Where -Property State -Match -Value Enabled
$wsl_installed=Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online | Where -Property State -Match -Value Enabled

if ( !$vmp_installed -or !$wsl_installed ) 
{
	echo "Enabling Windows Subsystem for Linux (WSL)"
	dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
	echo "Enabling Virtual Machine Platform"
	dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
	echo "Restart this VM to finish enabling these features"
	exit 0
}
else
{
	$wsl_update_installed = Get-Package -Name 'Windows Subsystem for Linux Update' -MinimumVersion 5.10.16 -erroraction Ignore
	if (!$wsl_update_installed){
		echo "Downloading required package - Windows Subsystem for Linux Update"
		$ProgressPreference = 'SilentlyContinue'
		Invoke-WebRequest -Uri https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile wsl_update_x64.msi -UseBasicParsing
		echo "Installing wsl_update_x64.msi..."
		Start-Process msiexec.exe -Wait -ArgumentList '/I wsl_update_x64.msi /quiet'
	}
	echo "Setting default WSL version to WSL2"
	wsl --set-default-version 2

	if ($is_build){
		$ubuntu_pkg = Get-AppPackage -Name CanonicalGroupLimited.UbuntuonWindows

		if(!$ubuntu_pkg){
			if(!(Test-Path -Path .\Ubuntu.appx -PathType Leaf)){
				echo "Downloading Ubuntu WSL app"
				$ProgressPreference = 'SilentlyContinue'
				Invoke-WebRequest -Uri https://aka.ms/wslubuntu2004 -OutFile Ubuntu.appx -UseBasicParsing
				echo "Finished Downloading"
			}
			echo "Installing Ubuntu WSL app"
			Add-AppxPackage Ubuntu.appx
		}
		echo "Setting up Ubuntu"
		ubuntu.exe install --root
		if(!(Test-Path -Path .\wsl-setup.tar -PathType Leaf)){
			echo "Downloading ubuntu-wsl.tar (customisations scripts)"
			$ProgressPreference = 'SilentlyContinue'
			Invoke-WebRequest -Uri http://ieatreposvr01.athtem.eei.ericsson.se/wsl/wsl-setup.tar -OutFile wsl-setup.tar -UseBasicParsing
			echo "Finished Downloading"
		}
		echo "Extracting wsl-setup.tar to /tmp in Ubuntu"
		tar xvf wsl-setup.tar -C \\wsl$\Ubuntu\var\tmp\
		echo "Make setup scripts executable"
		wsl -d Ubuntu chmod 755 /var/tmp/setup.bsh /var/tmp/create-mqueue.sh /var/tmp/user-setup.bsh
		echo "Running setup script in Ubuntu"
		wsl -d Ubuntu /var/tmp/setup.bsh
		echo "Exporting Ubuntu to ubuntu-wsl.tar"
		wsl --export Ubuntu ubuntu-wsl.tar
		echo "Removing Ubuntu on Windows package"
		$ubuntu_pkg = Get-AppPackage -Name CanonicalGroupLimited.UbuntuonWindows
		Remove-AppxPackage $ubuntu_pkg.PackageFullName
		
	} else {
		echo "Configuring Ubuntu for user"
		if(!(Test-Path -Path $env:userprofile\WSL\ -PathType Container)){
			echo "Create directory $env:userprofile\WSL\"
			mkdir $env:userprofile\WSL\
		}
		if(!(Test-Path -Path .\ubuntu-wsl.tar -PathType Leaf)){
				echo "Downloading ubuntu-wsl.tar (WSL image)"
				$ProgressPreference = 'SilentlyContinue'
				Invoke-WebRequest -Uri http://ieatreposvr01.athtem.eei.ericsson.se/wsl/ubuntu-wsl.tar -OutFile ubuntu-wsl.tar -UseBasicParsing
				echo "Finished Downloading"
		}
		echo "Importing WSL from ubuntu-wsl.tar"
		wsl --import Ubuntu $env:userprofile\WSL\ ubuntu-wsl.tar
		echo "Running user setup script"
		wsl -d Ubuntu /var/tmp/user-setup.bsh $env:UserName
		echo "Shutting down Ubuntu"
		wsl -t Ubuntu
	}
	echo "Finished"
}

