# Run as Admin
if (! ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
       [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

# Uninstall Bonjour
choco uninstall bonjour -y


# Remove VirtualBox, OLE community VM, and OLE community box,
# only if the user agrees
$vb = Read-Host 'Are you sure you want to remove Virtualbox? (Y)es, (N)o'

if ($vb.ToUpper() -eq 'Y') {
    choco uninstall virtualbox -y
}
  
$vm = Read-Host 'Do you want to remove the virtual machine? (Y)es, (N)o'

if ($vm.ToUpper() -eq 'Y') {
    C:\HashiCorp\Vagrant\bin\vagrant.exe destroy community -f
}

$box = Read-Host 'Do you want to remove also all the files? (Y)es, (N)o'

if ($box.ToUpper() -eq 'Y') {
    C:\HashiCorp\Vagrant\bin\vagrant.exe box remove ole/jessie64 -f
}

# Only uninstall Git if the user agrees
$git = Read-Host 'Are you sure you want to remove Git? (Y)es, (N)o'

if ($git.ToUpper() -eq 'Y') {
    choco uninstall git, git.install -y
}

# Uninstall vagrant
choco uninstall vagrant -y

# Uninstall chocolatey
choco uninstall chocolatey -y

# Only uninstall Firefox if the user agrees
$ff = Read-Host 'Are you sure you want to remove Firefox? (Y)es, (N)o'

if ($ff.ToUpper() -eq 'Y') {
    choco uninstall firefox -y
}

# Remove ole--vagrant-community and chocolatey folder and subfolders
"$HOME\ole--vagrant-community", "$env:ALLUSERSPROFILE\chocolatey" | % {
    Get-ChildItem -Path $_ -Recurse | Remove-Item -Force -Recurse
    Remove-Item $_ -Force -Recurse
    }

# Close ports on network
$ff = Read-Host 'Are you sure you want your firewall to block port 5984? (Y)es, (N)o'

if ($ff.ToUpper() -eq 'Y') {
    New-NetFirewallRule -DisplayName "Block Outbound Port 5984 CouchDB/HTTP" -Direction Outbound -LocalPort 5984 -Protocol TCP -Action Block
    New-NetFirewallRule -DisplayName "Block Inbound Port 5984 CouchDB/HTTP" -Direction Inbound -LocalPort 5984 -Protocol TCP -Action Block
}

$ff = Read-Host 'Are you sure you want your firewall to block port 6984? (Y)es, (N)o'

if ($ff.ToUpper() -eq 'Y') {
    New-NetFirewallRule -DisplayName "Block Outbound Port 6984 CouchDB/HTTPS" -Direction Outbound -LocalPort 6984 -Protocol TCP -Action Block
    New-NetFirewallRule -DisplayName "Block Inbound Port 6984 CouchDB/HTTPS" -Direction Inbound -LocalPort 6984 -Protocol TCP -Action Block
}

# Remove vagrant job from Startup
Unregister-ScheduledJob VagrantUp -Force

# Remove desktop icon
Remove-Item C:\Users\*\Desktop\MyBeLL.lnk -Force