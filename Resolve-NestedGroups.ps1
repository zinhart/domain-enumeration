# THIS SCRIPT MUST BE RUN FROM A DOMAIN JOINED ACCOUNT (or atleast an account with valid kerberos tickets so that we are in the security context of a domain)
<# Generate LDAP Provider Path That will input into the Directory Searcher
The LDAP Provider Path has the form of LDAP://HostName[:PortNumber][/DistinguishedName].
We will also include the Primary Domain Controller(PDC) as this DC will have the most up to date information about user login and authentication.
#>
function Resolve-NestedGroups {
  param (
    [Parameter(Mandatory=$true, HelpMessage="Enter the groups DISTINGUISHED NAME")]
      [string] $DN #Distinguished name
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
  $Searcher.filter="(&(objectClass=group)(memberof:1.2.840.113556.1.4.1941:=$DN))"
  $Result = $Searcher.FindAll()
  Foreach($obj in $Result)
  {
    $obj.Properties.member
  }
}
