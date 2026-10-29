; Instalador del Sistema Desktop de la Agencia Kataleya VIP (Inno Setup 6).
; Se instala para el usuario de Windows, sin permisos de administrador.
; El AppId no cambia entre versiones: así una versión nueva reemplaza a la anterior.
;
; NUEVO: durante la instalación pide la dirección de la Web API y la guarda en la variable
; de usuario KATALEYA_API, que es la que lee la aplicación (Configuracion.cs).
; Instalación silenciosa:  Instalar-Kataleya-1.0.0.exe /SILENT /API=https://mi-api.ejemplo.com/

#define Nombre "Sistema Desktop de la Agencia Kataleya VIP"
#define Version "1.0.0"
#define Ejecutable "Kataleya.Escritorio.exe"
; Dirección de la Web API. Si se compila con  ISCC /DApi=https://mi-api.ejemplo.com/  queda grabada
; en el instalador y la pantalla de la dirección no se muestra (solo Siguiente, Siguiente, Instalar).
; Si se compila sin /DApi, el asistente pregunta la dirección.
#ifndef Api
  #define Api "https://"
#endif
#define ApiPredeterminada Api

[Setup]
AppId={{3C0A6173-4C69-476F-B884-622A5495F8DF}
AppName={#Nombre}
AppVersion={#Version}
AppPublisher=Empresa Turismo VIP Kataleya SV E.I.R.L.
DefaultDirName={autopf}\Kataleya
DefaultGroupName=Kataleya
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0.17763
OutputDir=..\publicacion
OutputBaseFilename=Instalar-Kataleya-{#Version}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\{#Ejecutable}
UninstallDisplayName={#Nombre}
ChangesEnvironment=yes

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Files]
Source: "..\publicacion\win-x64\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{autoprograms}\Kataleya"; Filename: "{app}\{#Ejecutable}"
Name: "{autodesktop}\Kataleya"; Filename: "{app}\{#Ejecutable}"

[Registry]
; Variable de usuario (no necesita administrador). Se borra al desinstalar.
Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "KATALEYA_API"; ValueData: "{code:DireccionApi}"; Flags: uninsdeletevalue

; No se abre la aplicación al terminar: el instalador todavía no tiene la variable nueva en su
; entorno y la app intentaría conectarse a localhost. Se abre desde el acceso directo.

[Code]
var
  PaginaApi: TInputQueryWizardPage;

procedure InitializeWizard;
begin
  PaginaApi := CreateInputQueryPage(wpSelectDir,
    'Conexión con el servidor',
    'Dirección de la Web API de Kataleya',
    'Escriba la dirección que le entregó el equipo de desarrollo. Debe empezar con https://');
  PaginaApi.Add('Dirección:', False);
  PaginaApi.Values[0] := ExpandConstant('{param:API|{#ApiPredeterminada}}');
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := (PageID = PaginaApi.ID) and ('{#Api}' <> 'https://');
end;

function DireccionApi(Param: String): String;
var
  Texto: String;
begin
  Texto := Trim(PaginaApi.Values[0]);
  if (Texto <> '') and (Texto[Length(Texto)] <> '/') then
    Texto := Texto + '/';
  Result := Texto;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  Texto: String;
begin
  Result := True;
  if CurPageID = PaginaApi.ID then
  begin
    Texto := Lowercase(Trim(PaginaApi.Values[0]));
    if not ((Pos('https://', Texto) = 1) and (Length(Texto) > 10)) and
       not (Pos('http://localhost', Texto) = 1) and
       not (Pos('http://127.0.0.1', Texto) = 1) then
    begin
      MsgBox('Escriba una dirección completa que empiece con https://', mbError, MB_OK);
      Result := False;
    end;
  end;
end;
