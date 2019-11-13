$Computer = Get-ADComputer -Identity GBRDCWNTD001 #-Filter * -SearchBase "OU=Servers,DC=emea,DC=cbre,DC=net"
$Computers = $Computer.Name
Foreach($psitem in $Computers)
{
Get-WindowsFeature -ComputerName $psitem -Name Failover* | where InstallState -Eq Installed | select name
}
If ($Computer.Name -eq "GBRDCWNTD001") {
  'This server is GBRDCWNTD001'

  }  Else {

  'This server is not GBRDCWNTD001'

} 