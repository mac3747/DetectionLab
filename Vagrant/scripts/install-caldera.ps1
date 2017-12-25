add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@

$directory = "C:\Program Files\cagent"
$conf_url = "https://192.168.38.66:8888/conf.yml"
$conf_output = "C:\Program Files\cagent\conf.yml"
$cagent_url = "https://github.com/mitre/caldera-agent/releases/download/v0.1.0/cagent.exe"
$cagent_output = "C:\Program Files\cagent\cagent.exe"
$start_time = Get-Date

[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
New-Item -ItemType directory -Path $directory
Invoke-WebRequest -Uri $conf_url -OutFile $conf_output
Invoke-WebRequest -Uri $cagent_url -OutFile $cagent_output
cd $directory
.\cagent.exe --startup auto install
.\cagent.exe start

powershell -command Enable-NetFirewallRule -DisplayName "'File and Printer Sharing (SMB-In)'"
powershell -command Enable-NetFirewallRule -DisplayName "'Remote Scheduled Tasks Management (RPC)'"
reg add hklm\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest\ /v UseLogonCredential /t REG_DWORD /d 1


