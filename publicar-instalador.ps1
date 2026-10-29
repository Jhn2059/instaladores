# Arma el instalador de Kataleya en tu propia PC (Windows 10/11 x64).
# Requisitos: .NET 10 SDK, workload maui (se instala solo) e Inno Setup 6.
# Uso (desde la raíz del proyecto):
#   powershell -ExecutionPolicy Bypass -File instalador\publicar-instalador.ps1 -Api https://tu-api.ejemplo.com/
# Con -Api la dirección queda grabada y el tester solo hace Siguiente, Siguiente, Instalar.
param([string]$Api = '')
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

Write-Host '1/3 Instalando workload MAUI (solo la primera vez)...'
dotnet workload install maui

Write-Host '2/3 Publicando la aplicación (autocontenida, no exige instalar .NET)...'
if (Test-Path publicacion\win-x64) { Remove-Item publicacion\win-x64 -Recurse -Force }
dotnet publish Kataleya.Escritorio\Kataleya.Escritorio.csproj -c Release `
  -f net10.0-windows10.0.19041.0 -r win-x64 --self-contained true `
  -p:WindowsPackageType=None -p:WindowsAppSDKSelfContained=true -o publicacion\win-x64

Write-Host '3/3 Armando el instalador con Inno Setup...'
$iscc = @(
  "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
  "${env:ProgramFiles}\Inno Setup 6\ISCC.exe",
  "${env:LOCALAPPDATA}\Programs\Inno Setup 6\ISCC.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $iscc) { throw 'No encuentro Inno Setup 6. Descárgalo de https://jrsoftware.org/isdl.php' }
if ($Api) { & $iscc "/DApi=$Api" instalador\kataleya.iss } else { & $iscc instalador\kataleya.iss }

Write-Host 'Listo: publicacion\Instalar-Kataleya-1.0.0.exe'
