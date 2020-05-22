# AzurePRTLoginReport
AzurePRTLoginReport PowerShell script checks AzureAD PRT, Enterprise PRT and Windows Hello for Business (WHfB) status of the users who logged on to Hybrid Azure AD Joined and Azure AD Joined devices.

When the user login successfully to Hybrid Azure AD device or Azure AD joined device, he acquires AzureAD PRT which is extermly important to enable Single Sign-on (SSO) and to pass Azure AD Conditional Access Policies that deals with "Hybrid Azure AD" and/or "Complaint" devices.

Azure AD PRT can be validated by running "dsregcmd /status" command as the logged on user. But coming form the fact that it is not an easy process to verify the AzureAD PRT for a huge number of users on their devices as the verification should happen under the user account.

In this article, I am  providing a solution to verify AzureAD PRT, Enterprise PRT and Windows Hello for Business (WHfB) status using a new PowerShell script I wrote.

AzurePRTLoginReport PowerShell script checks AzureAD PRT, Enterprise PRT and Windows Hello for Business (WHfB) status of the users who logged on to Hybrid Azure AD Joined and Azure AD Joined devices. After verifying the above, this PowerShell script shows the result on the Shell screen, grid view and generates CSV/Excel report.

 

#### Why is this script useful?

- To check AzureAD PRT, Enterprise PRT status for the logged on user.
- To check Windows Hello for Business (WHfB) status for the logged on user.
- To automate a schedule task that checks the logged on user status.
- To generate a friendly CSV/Excel report with the status.
- To show the result on Grid View, so you can easily search in the result. 

#### What does this script do?

- Checks AzureAD PRT status.
- Checks Enterprise PRT status.
- Checks Windows Hello for Business status.
- Generates CSV/Excel report with the result. 

 

#### Prepare the setup before executing the script:

1. Configure shared folder:

- Create a folder with the name of “UsersLogin” on the file server or the shared storage.
- Share the folder with a meaningful name (e.g. UsersLogin). 

> [!NOTE]
> Note: you can add “$” character at the end of the share name to make it hidden.

 

2. Create batch file:
- Create a batch file to be run when the user logon to his machine.
- Name the batch file with a meaningful name (e.g. UserLoginInfo.bat).
- Add the following two line commands to the batch file: 

  `dsregcmd /status > \\FileServer\UsersLogin$\%username%--%computername%.txt`  
  `systeminfo | findstr /B /C:"OS Name" /C:"OS Version" >> \\FileServer\UsersLogin$\%username%--%computername%.txt`  

    
 

3.Configure GPO:

- Open “Group Policy Management Console” on domain controller and create a new GPO with a meaningful name (e.g. UserLoginInfo).
- Edit the above created GPO, and open “User Configuration\Windows Settings\ Scripts (Logon/Logoff)”.
- Choose Logon and add the above created batch file.
 - Link the GPO to the needed OU, site or domain. 

 

#### User experience:

- Checking PRT: 

![Alt text](https://github.com/mzmaili/AzurePRTLoginReport/blob/master/1.png "Checking PRT")

- The output report: 
![Alt text](https://github.com/mzmaili/AzurePRTLoginReport/blob/master/2.png "CSV output")
 

```azurepowershell
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
