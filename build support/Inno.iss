; ============================================================================
;  Inno.iss  —  per-project InnoSetup bootstrapper
; ----------------------------------------------------------------------------
;  Scaffolded (copied) into each repo's "build support\" folder (beside the .vipb)
;  as "Inno.iss" when absent, then hand-maintained. build_vip.bat looks for it there.
;  There is NO identity to fill in - app name, version, and publisher
;  come from the build at compile time. The only per-repo edits are prerequisites
;  and extra installers (the InitializeSetup list + the two "EXTRA INSTALLERS" regions).
;
;  All values arrive at COMPILE time as /D defines from build_vip.bat:
;      /DAppName=<product name>    build spec product name (same value as TITLE)
;      /DAppVersion=<x.y.z.b>      the build number that just shipped
;      /DAppPublisher=<company>    Levylab
;      /DRepoRoot=<abs path>       repository root
;      /DBuildSupport=<abs path>   %LOCALAPPDATA%\LevyLab\build-support\ISCC (holds CodeDependencies.iss)
; ============================================================================

; Fallbacks only let the script open standalone in the Inno IDE; the real values
; always arrive via /D from build_vip.bat.
#ifndef AppName
  #define AppName "Unknown App"
#endif
#ifndef AppVersion
  #define AppVersion "0.0.0.0"
#endif
#ifndef AppPublisher
  #define AppPublisher "Levylab"
#endif
#ifndef RepoRoot
  #define RepoRoot SourcePath       ; folder containing this .iss
#endif
#ifndef BuildSupport
  #define BuildSupport SourcePath
#endif

; ---- Paths (confirmed from a real generated 7zip.bat) -----------------------
; Application build spec output:  builds\Application
; Installer   build spec output:  builds\Installer\Volume  <-- NI media; holds setup.exe
;   (the old 7z step archived "..\Installer\Volume\*" from builds\7z Install)
#define NIInstallerDir RepoRoot + "\builds\Installer\Volume"
; Where the finished bootstrapper is written (picked up by the GitHub release):
#define OutputDir      RepoRoot + "\builds\latest"

[Setup]
; AppId is nominal only (Inno requires one; it is unused because Uninstallable=no). See below.
AppId=Levylab {#AppName}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
; Thin bootstrapper: it chains the real installers below rather than installing a payload
; itself. The NI (MSI) installer owns the app files, the Add/Remove Programs entry, AND
; upgrade management (via its Upgrade Code in the .lvproj). So there is no [Files] section,
; no uninstaller, and no meaningful AppId here - same role the old 7-Zip SFX played.
; Do NOT set Uninstallable=yes: this bootstrapper installs nothing, so an uninstall entry
; here would be a phantom that removes nothing. The app uninstalls via the NI installer's
; own Add/Remove Programs entry.
DefaultDirName={autopf}\{#AppName}
DisableDirPage=yes
DisableProgramGroupPage=yes
Uninstallable=no
; The chained NI installer can report "reboot required" (exit 3010) - e.g. when a file
; was in use during an update. Do NOT surface that as a restart prompt: the old 7-Zip
; installer never did, and any deferred file replacement still completes on the next
; normal reboot. Set to "yes" to restore the prompt.
RestartIfNeededByRun=no
OutputDir={#OutputDir}
OutputBaseFilename={#AppName}_{#AppVersion}_Setup
Compression=lzma2
SolidCompression=yes
PrivilegesRequired=admin
WizardStyle=modern

; DomGries InnoDependencyInstaller (placed in %LOCALAPPDATA%\LevyLab\build-support\ISCC
; by Setup-BuildMachine.bat). Requires Inno Setup 6.4+.
#include AddBackslash(BuildSupport) + "CodeDependencies.iss"

[Files]
; The NI installer, carried inside this bootstrapper and unpacked at runtime.
; Compressed (lzma2/solid): re-compressing the NI media pays off - about 26% smaller
; (~380 MB -> ~279 MB in testing) for ~70 s of build time. Add "nocompression" to the
; flags below to trade that size back for a near-instant compile while iterating.
Source: "{#NIInstallerDir}\*"; DestDir: "{tmp}\ni"; Flags: recursesubdirs createallsubdirs ignoreversion
; ---- EXTRA INSTALLERS (per project) — bundle payloads here ------------------
; Source: "{#RepoRoot}\thirdparty\SomeCppDriver.exe"; DestDir: "{tmp}\extra"; Flags: ignoreversion
; ----------------------------------------------------------------------------

[Run]
; NI LabVIEW installer — installs app + Run-Time Engine + shortcuts, silently.
; VERIFY these flags against your installer's supported silent switches.
Filename: "{tmp}\ni\setup.exe"; Parameters: "/q /AcceptLicenses yes /r:n /disableNotificationCheck"; StatusMsg: "Installing {#AppName}..."; Flags: waituntilterminated
; ---- EXTRA INSTALLERS (per project) — run payloads here ---------------------
; Filename: "{tmp}\extra\SomeCppDriver.exe"; Parameters: "/S"; StatusMsg: "Installing driver..."; Flags: waituntilterminated
; ----------------------------------------------------------------------------

[Code]
//function InitializeSetup(): Boolean;
//begin
  // Prerequisites via InnoDependencyInstaller: installs if missing, skips if present.
//  Dependency_AddVC2013;          // <-- the VC++ 2013 redist that was going missing
  // Add more as needed, e.g.:
  //   Dependency_AddVC2015To2022;
//  Result := True;
//end;
