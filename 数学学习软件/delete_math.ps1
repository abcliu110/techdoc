$path = 'D:\mywork\techdoc\数学学习软件\math-explorer'
$acl = Get-Acl $path
$acl.SetOwner([System.Security.Principal.NTAccount]'Administrators')
Set-Acl -Path $path -AclObject $acl
Remove-Item -Path $path -Recurse -Force
