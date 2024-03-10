﻿# Create-Certificate v0.4
#
# @author:    Martin Willing
# @copyright: Copyright (c) 2023-2024 Martin Willing at InfoGuard AG, Computer Security Incident Response Team (CSIRT). All rights reserved.
# @contact:   Any feedback or suggestions are always welcome and much appreciated - martin.willing@infoguard.ch
# @url:       https://infoguard.ch/
# @date:      2024-03-02
#
#
# ██╗███╗   ██╗███████╗ ██████╗  ██████╗ ██╗   ██╗ █████╗ ██████╗ ██████╗      █████╗  ██████╗ 
# ██║████╗  ██║██╔════╝██╔═══██╗██╔════╝ ██║   ██║██╔══██╗██╔══██╗██╔══██╗    ██╔══██╗██╔════╝ 
# ██║██╔██╗ ██║█████╗  ██║   ██║██║  ███╗██║   ██║███████║██████╔╝██║  ██║    ███████║██║  ███╗
# ██║██║╚██╗██║██╔══╝  ██║   ██║██║   ██║██║   ██║██╔══██║██╔══██╗██║  ██║    ██╔══██║██║   ██║
# ██║██║ ╚████║██║     ╚██████╔╝╚██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝    ██║  ██║╚██████╔╝
# ╚═╝╚═╝  ╚═══╝╚═╝      ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝     ╚═╝  ╚═╝ ╚═════╝ 
#
#
# Changelog:
# Version 0.1
# Release Date: 2023-10-13
# Initial Release
#
# Version 0.2
# Release Date: 2023-11-13
# Added: FriendlyName Parameter
# Fixed: Other minor fixes and improvements
#
# Version 0.3
# Release Date: 2024-01-15
# Fixed: Thumbprint
#
# Version 0.4
# Release Date: 2024-03-02
# Added: Archive Creation (.zip)
#
#
#############################################################################################################################################################################################
#############################################################################################################################################################################################

#region Declarations

# Declarations

# FriendlyName
$FriendlyName = "" # Enter Case Number (or Company Name) --> e.g. IR-xxx or CA-xxx

#endregion Declarations

#############################################################################################################################################################################################

#region Header

# Output Directory
$OUTPUT_FOLDER = "$env:USERPROFILE\Desktop\Certificate"

# Flush Output Directory
if (Test-Path "$OUTPUT_FOLDER")
{
    Get-ChildItem -Path "$OUTPUT_FOLDER" -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse
    New-Item "$OUTPUT_FOLDER" -ItemType Directory -Force | Out-Null
}
else 
{
    New-Item "$OUTPUT_FOLDER" -ItemType Directory -Force | Out-Null
}

# Create a record of your PowerShell session to a text file
Start-Transcript -Path "$OUTPUT_FOLDER\Transcript.txt"

# Logo
$Logo = @"
██╗███╗   ██╗███████╗ ██████╗  ██████╗ ██╗   ██╗ █████╗ ██████╗ ██████╗      █████╗  ██████╗ 
██║████╗  ██║██╔════╝██╔═══██╗██╔════╝ ██║   ██║██╔══██╗██╔══██╗██╔══██╗    ██╔══██╗██╔════╝ 
██║██╔██╗ ██║█████╗  ██║   ██║██║  ███╗██║   ██║███████║██████╔╝██║  ██║    ███████║██║  ███╗
██║██║╚██╗██║██╔══╝  ██║   ██║██║   ██║██║   ██║██╔══██║██╔══██╗██║  ██║    ██╔══██║██║   ██║
██║██║ ╚████║██║     ╚██████╔╝╚██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝    ██║  ██║╚██████╔╝
╚═╝╚═╝  ╚═══╝╚═╝      ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝     ╚═╝  ╚═╝ ╚═════╝ 
"@

Write-Output ""
Write-Output "$Logo"
Write-Output ""

# Header
Write-Output "Create-Certificate v0.3 - Automated Creation of Self-Signed Certificate for Microsoft Graph API"
Write-Output "(c) 2023-2024 Martin Willing at InfoGuard AG, Computer Security Incident Response Team (CSIRT)"
Write-Output ""

# Creation date (ISO 8601)
$CreationDate = [datetime]::Now.ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")
Write-Output "Creation date: $CreationDate UTC"
Write-Output ""

#endregion Header

#############################################################################################################################################################################################

#region Certificate

# Generate Self-Signed Certificate
Write-Output "[Info]  Generating Self-Signed Certificate for Microsoft Graph API ..."
Write-Output "[Info]  CaseNumber: $FriendlyName"
$CertName = "InfoGuard_IR-App"
$NotAfter = (Get-Date).AddMonths(1) # Expires in one month
$Cert = New-SelfSignedCertificate -Subject "CN=$CertName" -FriendlyName "$FriendlyName" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256 -NotAfter $NotAfter

# Thumbprint
$Thumbprint = (Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object {$_.Subject -match "CN=$CertName"} | Sort-Object NotBefore | Select-Object Thumbprint -Last 1).Thumbprint
Write-Output "[Info]  Thumbprint: $Thumbprint"

# Start date
$StartDate = (Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object {$_.Subject -match "CN=$CertName"} | Where-Object {$_.Thumbprint -match "$Thumbprint"} | Select-Object -ExpandProperty NotBefore).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")

# Expires
$EndDate = (Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object {$_.Subject -match "CN=$CertName"} | Where-Object {$_.Thumbprint -match "$Thumbprint"} | Select-Object -ExpandProperty NotAfter).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")
Write-Output "[Info]  Valid from $StartDate UTC until $EndDate UTC"

# Export Self-Signed Certificate (Public Key)
$FilePath = "$OUTPUT_FOLDER\Public"
$FileName = "$CertName.cer"
New-Item "$FilePath" -ItemType Directory -Force | Out-Null
Export-Certificate -Cert $Cert -FilePath "$FilePath\$FileName" | Out-Null
Write-Output "[Info]  Successfully exported to: $FilePath\$FileName"

# Archive Creation
if (Test-Path "$FilePath\$FileName")
{
    Compress-Archive -Path "$FilePath\$FileName" -DestinationPath "$FilePath\$CertName.zip"
}

# Stop logging
Write-Host ""
Stop-Transcript
Start-Sleep 1

#endregion Certificate

#############################################################################################################################################################################################

# List Certificate(s) for 'InfoGuard_IR-App'
# Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object {$_.Subject -match "CN=InfoGuard_IR-App"} | Select-Object Thumbprint,Subject,NotBefore,NotAfter,FriendlyName | Sort-Object NotBefore

# Delete Self-Signed Certificate from Current User Certificate Store (or use Certificate Manager-Tool (GUI) --> certmgr.msc)
# Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object {$_.Subject -match "CN=InfoGuard_IR-App"} | Where-Object {$_.Thumbprint -match "<Thumbprint>"} | Remove-Item

# Authenticate w/ Certificate
# Connect-MgGraph -TenantId "<TenantId>" -AppId "<AppId>" -CertificateThumbprint "<CertificateThumbprint>"
# Connect-MgGraph -TenantId "<TenantId>" -AppId "<AppId>" -CertificateThumbprint "<CertificateThumbprint>" -NoWelcome

# Export the generated certificate with a private key to a password protected PFX file
# $CertPassword = ConvertTo-SecureString -String "<CertPassword>" -Force -AsPlainText
# Export-PfxCertificate -Cert "Cert:\CurrentUser\My\<CertificateThumbprint>" -FilePath "$env:USERPROFILE\Desktop\InfoGuard_IR-App.pfx" -Password $CertPassword | Out-Null

# Add PFX file to the Certificate Store on a different computer
# $CertPassword = ConvertTo-SecureString -String "<CertPassword>" -Force -AsPlainText
# Import-PfxCertificate -FilePath "$env:USERPROFILE\Desktop\InfoGuard_IR-App.pfx" -CertStoreLocation Cert:\CurrentUser\My -Password $CertPassword
