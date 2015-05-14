# Powershell script for Windows Server 2012
# Script developed on Windows Server 2012 release edition
# Installs DHCP Server Role
# Creates a DHCP Scope (lets make it 10.5.4.0/24)
# Sets DHCP reservations for the 5 servers
# Installs the DNS Server Role
# Creates A records for 3 web servers, a database server, and a caching server


# Functions go here
Function dhcp-v4reserve($address, $mac, $descrip) #only reserving in one scope, so let's hard code that here
	{
	Write-Debug "Creating Reservation for $address"
	Add-DhcpServerv4Reservation -ScopeId 'Server Stack 10_5_4_0' -IPAddress $address -ClientId $mac -Description $descrip
	}
Function dns-recorda($ipaddr, $host) #Only one zone, so let's hard code it here
	{
	Write-Debug "Creating A record for $host"
	Add-DnsServerRecordA  -IPv4Address  $ipaddr -Name $host -ZoneName "example.com" -CreatePtr
	}
	
# Script Starts Here
# Install the DHCP Server
Write-Debug "Installing DHCP Server with Management Tools"
Install-WindowsFeature -Name 'DHCP Server'
# Should we check it its installed first?  What happens if you run this command and its already installed?

#Add the DHCP Scope
Write-Debug "Adding DHCP Scope"
Add-DhcpServerv4Scope -Name 'Server Stack 10_5_4_0' -StartRange 10.5.4.2 -EndRange 10.5.4.200 -SubnetMask 255.255.255.0 -Description 'Scope for server stack on 10.5.4.0/24'

# Create the Reservations using the function

dhcp-v4reserve '10.5.4.10' 'AA-BB-CC-DD-EE-A1' 'Reservation for cache.example.com'
dhcp-v4reserve '10.5.4.11' 'AA-BB-CC-DD-EE-A2' 'Reservation for app01.example.com'
dhcp-v4reserve '10.5.4.12' 'AA-BB-CC-DD-EE-A3' 'Reservation for app02.example.com'
dhcp-v4reserve '10.5.4.13' 'AA-BB-CC-DD-EE-A4' 'Reservation for app03.example.com'
dhcp-v4reserve '10.5.4.20' 'AA-BB-CC-DD-EE-A5' 'Reservation for db01.example.com'

# Install the DNS Server
Install-WindowsFeature -Name 'DNS Server'

# Add the example.com zone
Add-DnsServerPrimaryZone -Name "example.com" -ZoneFile example.com.dns
# Add the reverse lookup zone
Add-DnsServerPrimaryZone -NetworkID 10.5.4.0/24 -ZoneFile 4.5.10.in-addr.arpa.dns

# Create the A records using the function

dns-recorda '10.5.4.10' 'cache'
dns-recorda '10.5.4.11' 'app01'
dns-recorda '10.5.4.12' 'app02'
dns-recorda '10.5.4.13' 'app03'
dns-recorda '10.5.4.14' 'db01'

Write-Debug "All Done!"
exit 0