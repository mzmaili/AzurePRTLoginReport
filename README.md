# AzurePRTLoginReport
AzurePRTLoginReport PowerShell script checks AzureAD PRT, Enterprise PRT and Windows Hello for Business (WHfB) status of the users who logged on to Hybrid Azure AD Joined and Azure AD Joined devices.

When the user login successfully to Hybrid Azure AD device or Azure AD joined device, he acquires AzureAD PRT which is extermly important to enable Single Sign-on (SSO) and to pass Azure AD Conditional Access Policies that deals with "Hybrid Azure AD" and/or "Complaint" devices.

Azure AD PRT can be validated by running "dsregcmd /status" command as the logged on user. But coming form the fact that it is not an easy process to verify the AzureAD PRT for a huge number of users on their devices as the verification should happen under the user account.

In this article, I am  providing a solution to verify AzureAD PRT, Enterprise PRT and Windows Hello for Business (WHfB) status using a new PowerShell script I wrote.

AzurePRTLoginReport PowerShell script checks AzureAD PRT, Enterprise PRT and Windows Hello for Business (WHfB) status of the users who logged on to Hybrid Azure AD Joined and Azure AD Joined devices. After verifying the above, this PowerShell script shows the result on the Shell screen, grid view and generates CSV/Excel report.

 

# Why is this script useful?

- To check AzureAD PRT, Enterprise PRT status for the logged on user.
- To check Windows Hello for Business (WHfB) status for the logged on user.
- To automate a schedule task that checks the logged on user status.
- To generate a friendly CSV/Excel report with the status.
- To show the result on Grid View, so you can easily search in the result. 

# What does this script do?

- Checks AzureAD PRT status.
- Checks Enterprise PRT status.
- Checks Windows Hello for Business status.
- Generates CSV/Excel report with the result. 

 

# Prepare the setup before executing the script:

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

 

User experience:

- Checking PRT: 

![Alt text](https://github.com/mzmaili/AzurePRTLoginReport/blob/master/1.png "Checking PRT")

- The output report: 
![Alt text](https://github.com/mzmaili/AzurePRTLoginReport/blob/master/2.png "CSV output")
 
