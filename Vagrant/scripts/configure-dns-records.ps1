# Simple script to add hosts to dc dns records 

# Add Caldera Server
Add-DnsServerResourceRecordA -Name "caldera" -ZoneName "windomain.local" -IPv4Address "192.168.38.66" -TimeToLive 01:00:00
