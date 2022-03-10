# THIS SCRIPT MUST BE RUN FROM A DOMAIN JOINED ACCOUNT
<# Generate LDAP Provider Path That will input into the Directory Searcher
The LDAP Provider Path has the form of LDAP://HostName[:PortNumber][/DistinguishedName].
We will also include the Primary Domain Controller(PDC) as this DC will have the most up to date information about user login and authentication.
#>
$domainObj =[System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$PDC = ($domainObj.PdcRoleOwner).Name
$SearchString = "LDAP://"
$SearchString += $PDC + "/"
$DistinguishedName = "DC=$($domainObj.Name.Replace('.', ',DC='))"
$SearchString += $DistinguishedName
<# The samAccountType is an attribute that all user, computer, and group objects have. We will filter users with 0x30000000 (decimal 805306368).
#>
$Searcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]$SearchString)
$objDomain = New-Object System.DirectoryServices.DirectoryEntry
$Searcher.SearchRoot = $objDomain
$Searcher.filter="samAccountType=805306368"
$Result = $Searcher.FindAll()
Foreach($obj in $Result)
{
	Foreach($prop in $obj.Properties)
	{
		$prop
	}
	Write-Host "------------------------"
}