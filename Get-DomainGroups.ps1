<# 
THIS SCRIPT MUST BE RUN FROM A DOMAIN JOINED ACCOUNT (or atleast an account with valid kerberos tickets so that we are in the security context of a domain)
Generate LDAP Provider Path That will input into the Directory Searcher
The LDAP Provider Path has the form of LDAP://HostName[:PortNumber][/DistinguishedName].
We will also include the Primary Domain Controller(PDC) as this DC will have the most up to date information about user login and authentication.
#>
function Get-DomainGroups {
	param (
		[Parameter(Mandatory=$false,HelpMessage="Enumerate all groups in the domain")]
		[switch]$All,
		[Parameter(Mandatory=$false,HelpMessage="Enumerate members of a Singular Group")]
		[string] $GroupName,
 		[Parameter(Mandatory=$false,HelpMessage="Add Verbosity(i.e apply FL to properties)")]   
		[switch]$V
		)
	$domainObj =[System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
	$PDC = ($domainObj.PdcRoleOwner).Name
	$SearchString = "LDAP://"
	$SearchString += $PDC + "/"
	$DistinguishedName = "DC=$($domainObj.Name.Replace('.', ',DC='))"
	$SearchString += $DistinguishedName
	$Searcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]$SearchString)
	$objDomain = New-Object System.DirectoryServices.DirectoryEntry
	$Searcher.SearchRoot = $objDomain
	if($All -eq $true)
	{
	$Searcher.filter="(objectClass=Group)"
	$Result = $Searcher.FindAll()
	Foreach($obj in $Result)
	{
		$obj.Properties.name
	}
	}
	elseif (![string]::IsNullOrEmpty($GroupName)) 
	{
	$Searcher.filter="(name=$Groupname)"
	$Result = $Searcher.FindAll()
		Foreach($obj in $Result)
		{
			Foreach($prop in $obj.Properties)
			{
        if ($V -eq $true) { $prop | Format-List }
        else { $prop }
			}
			Write-Host "------------------------"
		}
	}
	else {
		Write-Host 'Specify -All switch or supply a group name'
	}
}

