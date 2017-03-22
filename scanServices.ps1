#specify computer(s) that you want service info from
$computers = 'computer1','computer2'

#make sure there is a directory to store secure creds in
if(!(Test-Path -Path C:\temp )){
    New-Item -ItemType Directory -Force -Path C:\temp
}

#receive creds from user and store as variable
#$username = "you@yourcompany.com"
$username = read-host -promprt "Please enter your username"

#Create a file to store your email password
if(!(Test-Path -Path C:\temp\securestring.txt )){
    read-host -assecurestring "Please enter your password" | convertfrom-securestring | out-file C:\temp\securestring.txt
}
$password = cat C:\temp\securestring.txt | convertto-securestring
$mycreds = new-object -typename System.Management.Automation.PSCredential `
         -argumentlist $username, $password

foreach($computer in $computers) {
    #perform actual service info collection
    $NonDefaultServices = Get-WMIObject Win32_Service -computer $computer -credential $mycreds | where {
        $_.Caption -notmatch "Windows" -and $_.PathName -notmatch "Windows" -and $_.PathName -notmatch "policyhost.exe" -and $_.Name -ne "LSM" -and $_.PathName -notmatch "OSE.EXE" -and $_.PathName -notmatch "OSPPSVC.EXE" -and $_.PathName -notmatch "Microsoft Security Client"
    }

    write-host "Non Default Services on $computer are:"
    foreach($s in $NonDefaultServices){
        $s.DisplayName
        $s.PathName
        $s.StartName
        $s.State
        write-host "==================================================================================================="
        write-host " "

    }
    write-host "///////////////////////////////////////////////////////////////////////////////////////////////////////"
}


<#
More info on services from https://powershelladministrator.com/2014/04/28/get-all-non-default-windows-services/

$NonDefaultServices.DisplayName # Service Display Name (full name)
$NonDefaultServices.PathName # Service Executable
$NonDefaultServices.StartMode # Service Startup mode
$NonDefaultServices.StartName # Service RunAs Account
$NonDefaultServices.State # Service State (running/stopped etc)
$NonDefaultServices.Status # Service Status
$NonDefaultServices.Started # Service Started status
$NonDefaultServices.Description # Service Description
#>
