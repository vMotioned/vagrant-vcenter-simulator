<#
.SYNOPSIS
	vCenter Server Appliance Simulator vagrant & packer configuration script for deployment on VMware Workstation
.DESCRIPTION
	This script will first take the vCSA .OVA for and convert it to VMX. The output from this gets saved in the 'Output' directory. It then uses Packer to build a vagrant box from the generated VMX file.

	It does require the VMware 'plugin' for VMware Workstation, which is not free.

	[execution instructions]
.PARAMETER OVAPath
	This is the full UNC path, including the filename of the .OVA
.INPUTS
	System.String
.OUTPUTS
	N/A
.EXAMPLE

.NOTES

	TODO:
	[+] clean up use of variables that specify script directory; figure out a fix or mandata local dir execution

	#TAG:PUBLIC

	GitHub:	 https://github.com/vScripter
	Twitter:  @vScripter
	Email:	 kevin@vMotioned.com

[-------------------------------------DISCLAIMER-------------------------------------]
 All script are provided as-is with no implicit
 warranty or support. It's always considered a best practice
 to test scripts in a DEV/TEST environment, before running them
 in production. In other words, I will not be held accountable
 if one of my scripts is responsible for an RGE (Resume Generating Event).
 If you have questions or issues, please reach out/report them on
 my GitHub page. Thanks for your support!
[-------------------------------------DISCLAIMER-------------------------------------]

.LINK
	https://github.com/vScripter
#>

[CmdletBinding()]
param (
	[Parameter(Position = 0,
			   Mandatory = $true,
			   HelpMessage = 'This should be the full UNC path, including .OVA file name, of the desired .OVA file')]
	[validatescript({ Test-Path -LiteralPath $_ -Type Leaf })]
	[System.String]$OVAPath
)

BEGIN {

	function Get-ScriptDirectory {
		if ($hostinvocation -ne $null) {
			Split-Path $hostinvocation.MyCommand.path
		} else {
			Split-Path $script:MyInvocation.MyCommand.Path
		} # end if/else
	}# end function Get-ScriptDirectory

	$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
	$scriptDirectory = Get-ScriptDirectory
	$jsonFileName = 'vcenter-55-simulator.json'

	Write-Verbose -Message 'Checking for ovftool'
	try {
		ovftool.exe -v | Out-Null
	} catch {
		Write-Warning -Message "ovftool not installed or not defined in PATH environmental variable. $_"
		Write-Warning -Message 'Exiting script'
		Exit
	} # end try/catch

	Write-Verbose -Message 'Checking for packer (this may take a few seconds)'
	try {
		packer.exe version | Out-Null
	} catch {
		Write-Warning -Message "Packer not installed or not defined in PATH environmental variable. $_"
		Write-Warning -Message 'Exiting script'
		Exit
	} # end try/catch

} # end BEGIN block

PROCESS {

	Write-Verbose -Message 'Starting ovftool execution'
	$vmxOutputFile = "$scriptDirectory\build\vcsa-55-sim.vmx"
	try {
		ovftool.exe -tt=vmx $ovaPath $vmxOutputFile
	} catch {
		Write-Warning -Message "ovftool error: $_"
	}

	if (-not(Test-Path -LiteralPath $vmxOutputFile -Type Leaf)) {
		Write-Warning -Message '.VMX file was not created as part of ovftool execution'
		Write-Warning -Message 'Exiting script'
		Exit
	}

	Write-Verbose -Message 'Starting packer execution'
	packer.exe build "$scriptDirectory\$JSONFileName"

} # end PROCESS block

END {
	Write-Verbose -Message 'Execution Complete!'
} # end END block