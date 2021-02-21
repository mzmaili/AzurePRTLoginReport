<# 

.SYNOPSIS
    AzurePRTLoginReport PowerShell script.

.DESCRIPTION
    AzurePRTLoginReport.ps1 is a PowerShell script checks Azure PRT, Enterprise PRT and WHfB status.

.AUTHOR:
    Mohammad Zmaili

.PARAMETER
    SourceFolder
    Allows you to specify devices list from CSV/TXT/XLS file.
    Note: make sure that the file contacis column wiht the name of "DeviceName" that includes the device name.

.PARAMETER
    OutputFolder
    Allows you to check devices in specific OU or container.
    Note: you can check all devices by following OU parameter with "all".

.PARAMETER
    OnScreenReport
    Displays The health check result on PowerShell screen.

.PARAMETER
    ExcelReport
    Generates Excel report and saves the result into it, if this switch not selected script will generate a CSV report.


.EXAMPLE
    .\AzurePRTLoginReport.ps1
    Search for the TXT files that hold the user login information, analyse them and then, generates CSV report.

.EXAMPLE
    .\AzurePRTLoginReport.ps1 -SourceFolder "\\FileServer\UsersLogs" -OutputFolder "\\SharedFolder\AzurePRTLoginReport"
    Search for the TXT files that hold the user login information in the entered folder, analyse them and then, export CSV report to the entered shared folder location.

.EXAMPLE
    .\AzurePRTLoginReport.ps1 -ExcelReport
        Search for the TXT files that hold the user login information, analyse them and then, generates Excel report.


Output for a single device:
-----------
User Name        : User
Device Name      : HYBRID
Device ID        : xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
TpmProtected     : YES
KeyProvider      : Microsoft Platform Crypto Provider
Domain Joined    : YES
Domain Name      : DOMAIN
AzureAD Join     : YES
AzureAD PRT      : YES
Enterprise Prt   : YES
WHfB Enabled     : YES
Last Logon (UTC) : 7/13/2019 11:46:37 AM


==================================
|AzureAD PRT Login Status Report:|
==================================
Number of checked users: 3
Users with AzureAD PRT = YES: 2
Users with AzureAD PRT = NO: 1
Users with Enterprise PRT = YES: 1
Users with Enterprise PRT = NO: 2
Users with WHfB Enabled: 1
Users with WHfB Disabled: 2
#>

[cmdletbinding()]
param(
        [Parameter( Mandatory=$false)]
        [String]$SourceFolder,

        [Parameter( Mandatory=$false)]
        [String]$OutputFolder,

        [Parameter( Mandatory=$false)]
        [switch]$OnScreenReport,

        [Parameter( Mandatory=$false)]
        [switch]$ExcelReport
)

Function CheckImportExcel{
Write-Host "Checking ImportExcel Module..." -ForegroundColor Yellow
                            
    if (Get-Module -ListAvailable -Name ImportExcel) {
        Import-Module ImportExcel
        Write-Host "ImportExcel Module has imported." -ForegroundColor Green -BackgroundColor Black
        ''
    } else {
        Write-Host "ImportExcel Module is not installed." -ForegroundColor Red -BackgroundColor Black
        ''
        Write-Host "Installing ImportExcel Module....." -ForegroundColor Yellow
        Install-Module ImportExcel -Force
                                
        if (Get-Module -ListAvailable -Name ImportExcel) {                                
        Write-Host "ImportExcel Module has installed." -ForegroundColor Green -BackgroundColor Black
        Import-Module ImportExcel
        Write-Host "ImportExcel Module has imported." -ForegroundColor Green -BackgroundColor Black
        ''
        } else {
        ''
        Write-Host "Operation aborted. ImportExcel was not installed." -ForegroundColor red -BackgroundColor Black
        exit
        }
    }



}


cls

'========================================================'
Write-Host '            AzureAD PRT Login Status Report           ' -ForegroundColor Green 
'========================================================'

''
if ($SourceFolder){
    if (-not (Test-Path $SourceFolder)) {
    Write-Host "Operation aborted. The entered source folder does not exist." -ForegroundColor red -BackgroundColor Black
    exit
    }

    $SourceFolder = $SourceFolder + "\*"
}else{

    $SourceFolder = (Get-location).path
    $SourceFolder = $SourceFolder + "\*"
}
$SourceFolder1=$SourceFolder.Trim("\*")
Write-Host "Checking the source file: '$SourceFolder1' ..." -ForegroundColor Yellow
''

if ($OutputFolder){
    if (-not (Test-Path $OutputFolder)) {
    Write-Host "Operation aborted. The entered output folder does not exist." -ForegroundColor red -BackgroundColor Black
    exit
    }

}else{
    #$OutputFolder = Get-Location
}

$global:rep =@()
$num = 0
$PRTYes=0
$PRTNo=0
$EPRTYes=0
$EPRTNo=0
$WHfBYes=0
$WHfBNo=0
$UsersLogsFolder = get-childitem -path $SourceFolder -Include *.txt
if ($UsersLogsFolder.Count -ge 1){
    ForEach($File in $UsersLogsFolder){
    $num+=1
    Write-Host "Checking User" $num "of" $UsersLogsFolder.count "..." -ForegroundColor Yellow

    $LastLogonTime = $file.LastWriteTimeUtc
    $FileContent = Get-Content ($SourceFolder+$File.name)
    
    $UserName = ($File.Name.tostring() -split "--")[0].trim()

    $DeviceName = ($File.Name.tostring() -split "--")[1].trim(".txt")

    $DeviceId = $FileContent | Select-String DeviceId
    if ($DeviceId -ne $null) { $DeviceId = ($DeviceId.tostring() -split ":")[1].trim()} else {$DeviceId = "NA"}

    $OSName = $FileContent | Select-String "OS Name"
    if ($OSName -ne $null) { $OSName = ($OSName.tostring() -split ":")[1].trim()} else {$OSName = "NA"}

    $OSVersion = $FileContent | Select-String "OS Version"
    if ($OSVersion -ne $null) { $OSVersion = ($OSVersion.tostring() -split ":")[1].trim()} else {$OSVersion = "NA"}



    $AzureAdPrtUpdateTime = $FileContent | Select-String AzureAdPrtUpdateTime
    if ($AzureAdPrtUpdateTime -ne $null) { $AzureAdPrtUpdateTime = ($AzureAdPrtUpdateTime.tostring() -split ":")[1].trim()} else {$AzureAdPrtUpdateTime = "NA"}

    $AzureAdPrtExpiryTime = $FileContent | Select-String AzureAdPrtExpiryTime
    if ($AzureAdPrtExpiryTime -ne $null) { $AzureAdPrtExpiryTime = ($AzureAdPrtExpiryTime.tostring() -split ":")[1].trim()} else {$AzureAdPrtExpiryTime = "NA"}        

    $DeviceAuthStatus  = $FileContent | Select-String DeviceAuthStatus 
    if ($DeviceAuthStatus  -ne $null) { $DeviceAuthStatus  = ($DeviceAuthStatus.tostring() -split ":")[1].trim()} else {$DeviceAuthStatus  = "NA"}        

    $TpmProtected = $FileContent | Select-String TpmProtected
    if ($TpmProtected -ne $null) { $TpmProtected = ($TpmProtected.tostring() -split ":")[1].trim()} else {$TpmProtected = "NA"}
    
    $KeyProvider = $FileContent | Select-String KeyProvider
    if ($KeyProvider -ne $null) { $KeyProvider = ($KeyProvider.tostring() -split ":")[1].trim()} else {$KeyProvider = "NA"}
    
    $DomainJoin = $FileContent | Select-String DomainJoined
    if ($DomainJoin -ne $null) { $DomainJoin = ($DomainJoin.tostring() -split ":")[1].trim()} else {$DomainJoin = "NO"}

    $DomainName = $FileContent | Select-String DomainName
    if ($DomainName -ne $null) { $DomainName = ($DomainName.tostring() -split ":")[1].trim()} else {$DomainName = "NA"}
    
    $AADJoin = $FileContent | Select-String AzureAdJoined
    if ($AADJoin -ne $null) { $AADJoin = ($AADJoin.tostring() -split ":")[1].trim()} else {$AADJoin = "NO"}

    $TenantName = $FileContent | Select-String TenantName
    if ($TenantName -ne $null) { $TenantName = ($TenantName.tostring() -split ":")[1].trim()} else {$TenantName = "NA"}

    $AADPRT = $FileContent | Select-String AzureAdPrt | select-object -First 1
    if ($AADPRT -ne $null) { $AADPRT = ($AADPRT.tostring() -split ":")[1].trim()
        if ($AADPRT -eq "YES"){
            $PRTYes+=1
            }else{
            $PRTNo+=1
            }
        } else {
        $AADPRT = "NO"
        $PRTNo+=1
        }

    $EnterprisePrt = $FileContent | Select-String EnterprisePrt | select-object -First 1
    if ($EnterprisePrt -ne $null) { $EnterprisePrt = ($EnterprisePrt.tostring() -split ":")[1].trim()
        if($EnterprisePrt -eq "YES"){
            $EPRTYes+=1
            }else{
            $EPRTNo+=1
            }
    } else {
    $EnterprisePrt = "NO"
    $EPRTNo+=1
    }
    
    $NgcSet = $FileContent | Select-String NgcSet
    if ($NgcSet -ne $null) { $NgcSet = ($NgcSet.tostring() -split ":")[1].trim()
        if($NgcSet -eq "YES"){
            $WHfBYes+=1
            }else{
            $WHfBNo+=1
            }   
    } else {$NgcSet = "NO"
        $WHfBNo+=1
    }



    $repobj = New-Object PSObject
    $repobj | Add-Member NoteProperty -Name "User Name" -Value $UserName
    $repobj | Add-Member NoteProperty -Name "Device Name" -Value $DeviceName
    $repobj | Add-Member NoteProperty -Name "Device ID" -Value $DeviceId
    $repobj | Add-Member NoteProperty -Name "OS Name" -Value $OSName
    $repobj | Add-Member NoteProperty -Name "OS Version" -Value $OSVersion
    $repobj | Add-Member NoteProperty -Name "TpmProtected" -Value $TpmProtected
    $repobj | Add-Member NoteProperty -Name "KeyProvider" -Value $KeyProvider
    $repobj | Add-Member NoteProperty -Name "Domain Joined" -Value $DomainJoin
    $repobj | Add-Member NoteProperty -Name "Domain Name" -Value $DomainName
    $repobj | Add-Member NoteProperty -Name "AzureAD Join" -Value $AADJoin
    $repobj | Add-Member NoteProperty -Name "Tenant Name" -Value $TenantName
    $repobj | Add-Member NoteProperty -Name "AzureAD PRT" -Value $AADPRT
    $repobj | Add-Member NoteProperty -Name "Azure AD PRT Update Time" -Value $AzureAdPrtUpdateTime
    $repobj | Add-Member NoteProperty -Name "Azure AD PRT Expiry Time" -Value $AzureAdPrtExpiryTime
    $repobj | Add-Member NoteProperty -Name "Device Auth Status" -Value $DeviceAuthStatus 
    $repobj | Add-Member NoteProperty -Name "Enterprise Prt" -Value $EnterprisePrt
    $repobj | Add-Member NoteProperty -Name "WHfB Enabled" -Value $NgcSet
    $repobj | Add-Member NoteProperty -Name "Last Logon (UTC)" -Value $LastLogonTime
    
    $repobj
    $global:rep += $repobj

  
    }#EndForEash

    $Date=("{0:s}" -f (get-date)).Split("T")[0] -replace "-", ""
    $Time=("{0:s}" -f (get-date)).Split("T")[1] -replace ":", ""

  if ($ExcelReport){
  CheckImportExcel
    $filerep = "AzurePRTLoginReport_" + $Date + $Time + ".xlsx"
    if ($OutputFolder) { $filerep = $OutputFolder + "\" + $filerep }
    $global:rep | Export-Excel -workSheetName "AzurePRTLoginReport" -path $filerep -ClearSheet -TableName "PRTStatusTable" -AutoSize
  }else{
    $filerep = "AzurePRTLoginReport_" + $Date + $Time + ".csv"
    if ($OutputFolder) { $filerep = $OutputFolder + "\" + $filerep }
    $global:rep | Export-Csv -path $filerep -NoTypeInformation 
  }
    
    ''
    Write-Host "=================================="
    Write-Host "|AzureAD PRT Login Status Report:|"
    Write-Host "=================================="
    Write-Host "Number of checked users:" $num
    Write-Host "Users with AzureAD PRT = YES:" $PRTYes
    Write-Host "Users with AzureAD PRT = NO:" $PRTNo
    Write-Host "Users with Enterprise PRT = YES:" $EPRTYes
    Write-Host "Users with Enterprise PRT = NO:" $EPRTNo
    Write-Host "Users with WHfB Enabled:" $WHfBYes
    Write-Host "Users with WHfB Disabled:" $WHfBNo

    ''
    $loc=Get-Location
    Write-host $filerep "report has been created on the path:" $loc -ForegroundColor green -BackgroundColor Black
    
   if ($OnScreenReport){
        $global:rep | Out-GridView -Title "User Status Checker Report"
   }

    ''

}else{
    Write-Host "Operation aborted. There is no files in the selected directory." -ForegroundColor red -BackgroundColor Black
    ''
}