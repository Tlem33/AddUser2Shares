:: AddUser2Shares.cmd créé par Tlem33
:: Ce batch ajoute ou supprime un utilisateur dans le
:: système et/ou sur un ou plusieurs partages ainsi que
:: les informations d'identification pour le client.
::
:: Version 1.6 du 07-09-2026
::
:: Lire le fichier README.md pour plus d'informations.
::

@Echo Off
Mode Con:Cols=91 Lines=31
setlocal EnableDelayedExpansion
Cls

:: ================================================================================
::                             CONFIGURATION UTILISATEUR
:: ================================================================================
:: Entrez ici les paramètres du compte de l'utilisateur et du serveur
:: Exemple : Set "User=NomUtilisateur"
Set "User="
Set "Pass="
Set "Server="
:: ================================================================================
:: ================================================================================


:: ================================================================================
:: Déclaration des variables
:: ================================================================================
:: Version du batch :
Set "Version=1.6"

:: Ajout des chemins vers System32, wbem et Powershell au path (au cas ou)
SET "PATH=%PATH%;%WINDIR%\System32;%WINDIR%\System32\wbem;%WINDIR%\System32\WindowsPowerShell\v1.0"
Set "PwrShell=Powershell.exe -NoProfile -ExecutionPolicy Unrestricted -Command"

Title==: AddUser2Shares version %version%

:: Récupération du nom du groupe administrateur à partir du SID (permet l'utilisation du script sur un système d'une autre lange) :
For /F "Delims=" %%n In ('%PwrShell% "(New-Object System.Security.Principal.SecurityIdentifier('S-1-5-32-544')).Translate([System.Security.Principal.NTAccount]).Value.Split('\')[-1]"') Do Set "AdminGrp=%%n"
:: ================================================================================
:: ================================================================================

:: Demande des droits admin.
Net.exe session 1>NUL 2>NUL || (Powershell start-process """%~dpnx0""" "%*" -verb RunAs & Exit /b 1)

:: Test Si le nom de l'utilisateur est indiqué en dur, sinon demande de rentrer le nom
If "%User%" EQU "" Call :GetUserName
:: Test Si le mot de passe est indiqué en dur. Si Pass est spécifié, alors Passwd=%Pass%
If "%Pass%" NEQ "" Set "Passwd=%Pass%"

:: ===========================================
::               Menu principal
:: ===========================================
:Menu_Principal
Set "Menu=Menu_Principal"
Cls
Color 0F
Echo                         ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
Echo                         º                              º
Echo                         º      AddUser2Shares v%version%     º
Echo                         º        Menu Principal        º
Echo                         º                              º
Echo                         ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
Echo.
Echo                         Utilisateur  : %User%
Echo                         Mot de passe : %Passwd%
Echo.
Echo.
Echo   Veuillez s‚lectionner l'action … r‚aliser :
Echo.
Echo          1 - Ajouter l'utilisateur au systŠme
Echo.
Echo          2 - Supprimer l'utilisateur du systŠme
Echo.
Echo          3 - Afficher/Masquer le compte utilisateur sur l'‚cran d'ouverture de session
Echo.
Echo          4 - Ajouter l'utilisateur sur un ou plusieurs partages
Echo.
Echo          5 - Menu d'ajout des informations d'identification
Echo.
Echo          6 - Menu des raccourcis utiles
Echo.
Echo          7 - Quitter
Echo.
Choice /C 1234567 /M "Entrez votre choix : "
Set "CHOIXRESULT=%Errorlevel%"

If "%CHOIXRESULT%"=="1" Goto :AddUser
If "%CHOIXRESULT%"=="2" Goto :DelUser
If "%CHOIXRESULT%"=="3" Goto :View-Hide-User
If "%CHOIXRESULT%"=="4" Goto :Add2Share
If "%CHOIXRESULT%"=="5" Goto :Menu_Credentials
If "%CHOIXRESULT%"=="6" Goto :Menu_Utilitaires
If "%CHOIXRESULT%"=="7" Exit
Goto :%Menu%


:: ===========================================
::              Menu crédentials
:: ===========================================
:Menu_Credentials
Cls
Set "Menu=Menu_credentials"
Color 0F
Echo                         ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
Echo                         º                              º
Echo                         º      AddUser2Shares v%version%     º
Echo                         º       Menu cr‚dentials       º
Echo                         º                              º
Echo                         ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
Echo.
Echo.
Echo.
Echo.
Echo.
Echo   Veuillez s‚lectionner l'action … r‚aliser :
Echo.
Echo          1 - Ajouter les informations d'identification pour %User%
Echo.
Echo          2 - Supprimer les informations d'identification pour %User%
Echo.
Echo          3 - Afficher la liste des informations d'identification
Echo.
Echo          4 - Lancer l'utilitaire de gestion des informations d'identification
Echo.
Echo          5 - Menu principal
Echo.
Echo          6 - Quitter
Echo.
Choice /C 123456 /M "Entrez votre choix : "
Set "CHOIXRESULT=%Errorlevel%"

If "%CHOIXRESULT%"=="1" Goto :CredentialAdd
If "%CHOIXRESULT%"=="2" Goto :CredentialDel
If "%CHOIXRESULT%"=="3" Goto :CredentialVue
If "%CHOIXRESULT%"=="4" Goto :CredentialManager
If "%CHOIXRESULT%"=="5" Goto :Menu_Principal
If "%CHOIXRESULT%"=="6" Exit
Goto :%Menu%


:: ===========================================
::              Menu Utilitaires
:: ===========================================
:Menu_Utilitaires
Cls
Set "Menu=Menu_utilitaires"
Color 0F
Echo                         ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
Echo                         º                              º
Echo                         º      AddUser2Shares v%version%     º
Echo                         º       Menu Utilitaires       º
Echo                         º                              º
Echo                         ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
Echo.
Echo.
Echo.
Echo.
Echo.
Echo   Veuillez s‚lectionner l'action … r‚aliser :
Echo.
Echo          1 - Console de gestion des utilisateurs et groupes locaux
Echo.
Echo          2 - Console de gestion des dossiers partag‚s
Echo.
Echo          3 - Connexions r‚seau
Echo.
Echo          4 - Menu principal
Echo.
Echo          5 - Quitter
Echo.
Choice /C 12345 /M "Entrez votre choix : "
Set "CHOIXRESULT=%Errorlevel%"

If "%CHOIXRESULT%"=="1" Start "lusrmgr.msc" lusrmgr.msc & Goto :Menu_Utilitaires
If "%CHOIXRESULT%"=="2" Start "fsmgmt.msc" fsmgmt.msc & Goto :Menu_Utilitaires
If "%CHOIXRESULT%"=="3" Start "ncpa.cpl" ncpa.cpl & Goto :Menu_Utilitaires
If "%CHOIXRESULT%"=="4" Goto :Menu_Principal
If "%CHOIXRESULT%"=="5" Exit
Goto :%Menu%


:: ===========================================
::    Affichage de la liste des crédentials
:: ===========================================
:CredentialVue
Cls
cmdkey.exe /list
Echo Appuyez sur une touche pour revenir au menu.
Pause>Nul
Goto :%Menu%


:: ===========================================
::   Ouverture de la gestion des crédentials
:: ===========================================
:CredentialManager
Call control /name Microsoft.CredentialManager
Goto :%Menu%


:: ===========================================
::      Fonction d'ajout des crédentials
:: ===========================================
:CredentialAdd
Cls
If "%Pass%" NEQ "" Set "Passwd=%Pass%"
If "%User%" EQU "" Call :GetUserName
If "%Passwd%" EQU "" Call :SetPassword
If "%Server%" EQU "" Call :GetServerName

Echo.
Echo     R‚capitulatif des informations d'identifications
Echo.
Echo          Utilisateur    : %User%
Echo          Mot de passe   : %Passwd%
Echo          Nom du Serveur : %Server%
Echo.
Echo Appuyez sur une touche pour confirmer l'ajout de ces informations.
Pause>Nul
cmdkey.exe /add:%Server% /user:%User% /pass:%Passwd%
Echo.
Echo Op‚ration termin‚e.
Echo Appuyez sur une touche pour revenir au menu.
Pause>Nul
Goto :%Menu%


:: ===========================================
::   Fonction de suppression des crédentials
:: ===========================================
:CredentialDel
Cls
Echo.
Echo     Suppression des informations d'identifications pour
Echo.
Echo          Utilisateur    : NA
Echo          Mot de passe   : NA
Echo          Nom du Serveur : %Server%
Echo.
Echo Appuyez sur une touche pour confirmer la suppression.
Pause>Nul
cmdkey.exe /delete:%Server%
Echo.
Echo Op‚ration termin‚e.
Echo Appuyez sur une touche pour revenir au menu.
Pause>Nul
Goto :%Menu%


:: ===========================================
::      Fonction d'ajout de l'utilisateur
:: ===========================================
:AddUser
Cls
Set "Admin=0"
:: Test si le compte existe déjà.
Net.exe User "%User%">Nul 2>Nul
If %errorlevel% EQU 0 (
	Call :InfoTitle
	Echo Le Compte "%User%" existe d‚ja !
	Call :Pause "Appuyez sur une touche pour revenir au menu"
	Goto :%Menu%
)
:: Demande du mot de passe (si %Pass% = "")
If "%Pass%" NEQ "" Set "Passwd=%Pass%"
If "%Passwd%" EQU "" Call :SetPassword

:: Ajout du membre %User% au groupe Administrateurs (fonctionne aussi pour d'autres langues) :
Choice /C ON /M "Souhaitez-vous ajouter ce compte au groupe %AdminGrp% ? "
If "%Errorlevel%" == "1" Set "Admin=1"

Echo.
Echo Appuyez sur une touche pour confirmer l'ajout de l'utilisateur :
Echo.
Echo                Utilisateur    : %User%
Echo                Mot de passe   : %Passwd%
If "%Admin%" == "1" (
Echo                Administrateur : Oui
) Else (
Echo                Administrateur : Non
)
Echo.
Echo.
Echo                ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
Echo                º                                                º
Echo                º   L'ajout de ce compte utilisateur n'est pas   º
Echo                º       indispensable sur un poste client        º
Echo                º                                                º
Echo                ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
Echo.
Echo.
Call :Pause "Appuyez sur une touche pour ajouter le compte utilisateur : %User%"

:: Ajout de l'utilisateur %User% avec mot de passe %Passwd% :
Echo Creation du compte %User%
%PwrShell% "New-LocalUser -Name '%User%' -Description 'Utilisateur %User%' -Password (ConvertTo-SecureString -AsPlainText '%Passwd%' -Force) -PasswordNeverExpires:$True ; Add-LocalGroupMember -SID 'S-1-5-32-545' -Member '%User%'"

:: Ajout du membre %User% au groupe Administrateurs (fonctionne aussi pour d'autres langues) :
If "%Admin%" == "1" %PwrShell% "Add-LocalGroupMember -SID 'S-1-5-32-544' -Member '%User%'"

:: Test si l'utilisateur à bien été créé.
Net.exe User "%User%">Nul 2>Nul
If %errorlevel% NEQ 0 (
	Call :ErrorTitle
	Echo Compte "%User%" non cr‚‚ !
	Echo.
	Echo V‚rifiez que vous avez lanc‚ ce programme avec les droits
	Echo Administrateur, sinon veuillez cr‚er le compte manuellement.
	Call :Pause "Appuyez sur une touche pour revenir au menu"
	Goto :%Menu%
)

:: Récupération de la liste des groupes de l'utilisateur (séparés par une virgule)
For /f "delims=" %%g In ('%PwrShell% "(Get-LocalGroup | Where-Object { (Get-LocalGroupMember $_.Name -ErrorAction SilentlyContinue) | Where-Object { $_.Name -like ('*\'+'%User%') } }).Name -join ', '"') Do Set "UserGpr=%%g"

Echo R‚capitulatif :
Echo.
Echo      Utilisateur  : %User%
Echo      Mot de passe : %Passwd%
Echo      Groupe(s)    : %UserGpr%
Echo.
Call :SuccessTitle
Echo L'utilisateur a bien ‚t‚ ajout‚ dans le systŠme.
Call :Pause "Appuyez sur une touche pour revenir au menu"
Set "Passwd="
Goto :%Menu%


:: ===========================================
::   Fonction de suppression de l'utilisateur
:: ===========================================
:DelUser
Cls
:: Test si le compte existe.
Net.exe User "%User%">Nul 2>Nul
If %errorlevel% NEQ 0 (
	Call :InfoTitle
	Echo Le Compte "%User%" n'existe pas !
	Call :Pause "Appuyez sur une touche pour revenir au menu"
	Goto :%Menu%
)

Echo.
Echo Appuyez sur une touche pour confirmer la suppression de l'utilisateur :
Echo.
Echo                Utilisateur  : %User%
Echo.
Echo.
Echo Ce compte utilisateur sera aussi supprim‚ de tous les partages du systŠme.
Call :Pause "Appuyez sur une touche pour valider la suppression du compte %User%"

:: Boucle sur tous les partages (hors partages admin type C$, IPC$...)
:: On utilise ";" comme separateur plutot que "," pour eviter les soucis d'echappement
For /f "Tokens=1,2 Delims=;" %%a In ('%pwrshell% "Get-SmbShare | Where-Object { $_.Name -notlike '*$*' } | ForEach-Object { $_.Name + ';' + $_.Path }"') Do (
	If "%%a" NEQ "" Call :RemoveUserOnShare "%%a" "%%b"
)
Echo.

:: Suppression du compte utilisateur
Echo Suppression de l'utilisateur.
Net.exe User "%User%" /DELETE>Nul 2>Nul

:: Supprime la clé de registre inutile.
Echo Suppression de la cl‚ "%User%" dans "SpecialAccounts" si existante
Reg.exe DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /V "%User%" /F>Nul 2>Nul
Echo.

:: On vérifie si le compte utilisateur a été supprimé.
Net.exe User "%User%">Nul 2>Nul
If %errorlevel% EQU 0 (
	Call :ErrorTitle
	Echo Compte "%User%" toujours existant !
	Echo.
	Echo. Veuillez supprimer le compte manuellement.
	Call :Pause "Appuyez sur une touche pour revenir au menu"
	Goto :%Menu%
)

Call :SuccessTitle
Echo L'utilisateur "%User%" a bien ‚t‚ supprim‚.
Call :Pause "Appuyez sur une touche pour revenir au menu"
Goto :%Menu%


:: ================================================
::   Fonction d'affichage/masquage de l'utilisateur
:: ================================================
:View-Hide-User
Echo.
Echo          Utilisateur    : %User%
Echo.
Choice /C AM /M "Appuyez sur A pour afficher ou M pour masquer l'utilisateur sur l'‚cran d'ouverture de session : "
If Errorlevel 2 (
	Reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /V "%User%" /T REG_DWORD /D "0" /F>Nul 2>Nul
	Echo Compte utilisateur %User% masqu‚.
)
If "%Errorlevel%"=="1" (
	Reg.exe DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /V "%User%" /F>Nul 2>Nul
	Echo Compte utilisateur %User% affich‚.
)
Timeout /T 5
Goto :%Menu%


:: ===========================================
::   Fonction d'ajout utilisateur aux partages
:: ===========================================
:Add2Share
Cls
Set "Count=0"
:: Test si le compte existe.
Net.exe User "%User%">Nul 2>Nul
If %errorlevel% NEQ 0 (
	Call :InfoTitle
	Echo Le Compte "%User%" n'existe pas !
	Call :Pause "Appuyez sur une touche pour revenir au menu"
	Goto :%Menu%
)

:: Appel PowerShell : verifie si le SID de l'utilisateur appartient au groupe dont le SID est S-1-5-32-544
Set RESULT=False
For /f "usebackq delims=" %%R In (`%pwrshell% ^
    "try { " ^
    "  $ntAccount = New-Object System.Security.Principal.NTAccount('%User%'); " ^
    "  $userSid = $ntAccount.Translate([System.Security.Principal.SecurityIdentifier]); " ^
    "  $adminSid = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-32-544'); " ^
    "  $isMember = $false; " ^
    "  $adminGroup = [ADSI]('WinNT://./' + ($adminSid.Translate([System.Security.Principal.NTAccount])).Value.Split('\')[-1] + ',group'); " ^
    "  $members = @($adminGroup.Invoke('Members')); " ^
    "  foreach ($m in $members) { " ^
    "    $mSid = New-Object System.Security.Principal.SecurityIdentifier(([byte[]]$m.GetType().InvokeMember('objectSID','GetProperty',$null,$m,$null)), 0); " ^
    "    if ($mSid.Value -eq $userSid.Value) { $isMember = $true; break } " ^
    "  } " ^
    "  Write-Output $isMember " ^
    "} catch { Write-Output 'ERROR' }"`) do (
    set "RESULT=%%R"
)

If /i "!RESULT!"=="True" (
	Call :InfoTitle
    Echo L'utilisateur %User% fait partie du groupe Administrateurs, par cons‚quent,
    Echo Il n'est pas nécessaire d'ajouter des droits sp‚cifiques suppl‚mentaires.
    Echo.
    Choice /C ON /M "Souhaitez-vous quand mˆme proc‚der … l'ajout des droits par partage ? "
    Set "CHOIXRESULT=!Errorlevel!"

    If "!CHOIXRESULT!"=="1" Cls & Color OF
    If "!CHOIXRESULT!"=="2" Goto %menu%
)


:: Cette boucle liste noms et chemins des partages via PowerShell et filtre ceux avec le "$"
For /f "Tokens=1,2 Delims=;" %%a In ('%pwrshell% "Get-SmbShare | Where-Object { $_.Name -notlike '*$*' } | ForEach-Object { $_.Name + ';' + $_.Path }"') Do (
	If "%%a" NEQ "" Call :Add2ShareSub "%%a" "%%b"
)

:: Si aucun partage trouvé
If %Count%==0 (
	Call :ErrorTitle
	Echo Aucun partage n'a ‚t‚ trouv‚ sur ce systŠme !
	Call :Pause "Appuyez sur une touche pour revenir au menu"
	Goto :%Menu%
)

Echo.&Echo.
Echo Ajout de l'utilisateur "%User%" sur le/les partages termin‚.
Call :Pause "Appuyez sur une touche pour revenir au menu"
Goto :%Menu%


:: ======================================
:: Demande d'ajout utilisateur au partage
:: ======================================
:Add2ShareSub
Cls
Color 0F
:: Compte le nombre de partage trouvé
Set /A Count+=1
Set "ShareName=%~1"
Set "SharePath=%~2"

:: Astuce pour supprimer le backslash sur partage racine (x:\ => x:)
If "%SharePath:~-1,1%"=="\" Set "SharePath=%SharePath:~0,-1%"

Echo Nom du partage    : %ShareName%
Echo Chemin du partage : %SharePath%
Echo.
Choice /C on /M "Ajouter l'utilisateur "%User%" au partage ci-dessus ? "
Set "CHOIXRESULT=%Errorlevel%"

If "%CHOIXRESULT%"=="1" Goto :Add2ShareYes
If "%CHOIXRESULT%"=="2" Exit /B
Goto :%Menu%


:: ===================================
::   Ajoute l'utilisateur au partage
:: ===================================
:Add2ShareYes
Echo.&Echo.
Echo Ajout de l'utilisateur "%User%" au partage "%ShareName%"
::%SubinaclExe% /share "%ShareName%" /grant="%User%"=F
%pwrshell% "Grant-SmbShareAccess -Name '%ShareName%' -AccountName '%User%' -AccessRight Full -Force"

Echo.&Echo.
Echo Attribution des droits sur le chemin du partage :
::Icacls.exe "%SharePath%" /Grant "%User%":(OI)(CI)F /C
%pwrshell% "$acl=Get-Acl '%SharePath%';$rule=New-Object System.Security.AccessControl.FileSystemAccessRule('%User%','FullControl',('ContainerInherit','ObjectInherit'),'None','Allow');$acl.AddAccessRule($rule);Set-Acl -Path '%SharePath%' -AclObject $acl"

Echo.&Echo.
Echo Test de l'attribution des droits :
::Icacls.exe "%SharePath%"|Findstr "%User%"
For /f "delims=" %%r In ('%pwrshell% "if((Get-Acl '%SharePath%').Access | Where-Object { $_.IdentityReference -like '*%User%*' }){'OK'}else{'KO'}"') Do Set "AclCheck=%%r"

Echo.&Echo.
If "%AclCheck%" EQU "OK" (
	Color 0A
	Echo                  ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	Echo                  º                                           º
	Echo                  º        Droits attribu‚s avec succ‚s       º
	Echo                  º                                           º
	Echo                  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
) Else (
	Color 0C
	Echo                  ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	Echo                  º                                           º
	Echo                  º     Echec de l'attribution des droits     º
	Echo                  º                                           º
	Echo                  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
)
Exit /b


:: ===================================
::  Supprime l'utilisateur du partage
:: ===================================
:RemoveUserOnShare
set "ShareName=%~1"
set "SharePath=%~2"
If "%SharePath:~-1,1%"=="\" Set "SharePath=%SharePath:~0,-1%"
Echo Traitement du partage "%ShareName%" (%SharePath%)...

Echo.&Echo.
Echo Retrait de l'utilisateur "%User%" du partage "%ShareName%"
%pwrshell% "Revoke-SmbShareAccess -Name '%ShareName%' -AccountName '%User%' -Force -Confirm:$false -ErrorAction SilentlyContinue"

Echo.&Echo.
Echo Retrait des droits NTFS sur le chemin du partage :
%pwrshell% "$p='%SharePath%';$u='%User%';if(Test-Path $p){$acl=Get-Acl $p;$rules=$acl.Access | Where-Object { $_.IdentityReference.Value -ieq (('.\'+$u)) -or $_.IdentityReference.Value -ieq $u -or $_.IdentityReference.Value -like ('*\'+$u) };foreach($r in $rules){$acl.RemoveAccessRule($r) | Out-Null};Set-Acl -Path $p -AclObject $acl}"

Echo.&Echo.
Echo Test du retrait des droits :
For /f "delims=" %%r In ('%pwrshell% "$p='%SharePath%';$u='%User%';$still=(Get-Acl $p).Access | Where-Object { $_.IdentityReference.Value -ieq (('.\'+$u)) -or $_.IdentityReference.Value -ieq $u -or $_.IdentityReference.Value -like ('*\'+$u) };if($still){'KO'}else{'OK'}"') Do Set "AclCheck=%%r"

Echo.&Echo.
If "%AclCheck%"=="OK" (
	Color 0A
	Echo                  ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	Echo                  º                                           º
	Echo                  º         Droits retir‚s avec succ‚s        º
	Echo                  º                                           º
	Echo                  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
) Else (
	Color 0C
	Echo                  ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	Echo                  º                                           º
	Echo                  º         Echec du retrait des droits       º
	Echo                  º                                           º
	Echo                  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
)
Exit /b


:: ===================================
::    Demande du nom de utilisateur
:: ===================================
:GetUserName
Echo La valeur "User=" est non renseign‚e dans le script.
Echo.
Set /P "User=Veuillez indiquer le nom de l'utilisateur … g‚rer (0 pour quitter) : "
If "!User!" EQU "" Cls & Goto :GetUserName
If "!User!" EQU "0" Exit
Exit /b


:: ===================================
:: Demande du mot de passe utilisateur
:: ===================================
:SetPassword
Cls
Color 0F

:: Demande du mot de passe
Echo.
Echo Veuillez indiquer le mot de passe de l'utilisateur (0 pour revenir au menu principal) :
Echo     - Ne pas utiliser les caractŠres sp‚ciaux : ^< ^> ^^ ^& " ( )
Echo     - Longueur minimale 8 caractŠres
Echo.
Set /P "Passwd=Entrez le mot de passe : " 
If "!Passwd!" EQU "" Goto :SetPassword
If "!Passwd!" EQU "0" Goto %menu%

:: Test des caracteres interdits et de la longueur du mot de passe via PowerShell
For /F "Usebackq Delims=" %%R In (`%pwrshell% ^
    "$pattern = '[<>&()' + [char]34 + ']'; " ^
    "If ($env:Passwd -match $pattern) { " ^
    "  'NotAllowed' " ^
    "} Elseif ($env:Passwd.Length -lt 8) { " ^
    "  'TOOSHORT' " ^
    "} Else { " ^
    "  'OK' " ^
    "}"`) Do Set "PwdCheck=%%R"

If "!PwdCheck!" EQU "NotAllowed" (
    Color 0C
    Echo CaractŠres interdits d‚tect‚s.
    Echo.
    Echo Appuyez sur une touche pour recommencer
    Pause>Nul
    Color 0F
     Set "Passwd="
    Goto :SetPassword
)
If "!PwdCheck!" EQU "TOOSHORT" (
    Color 0C
    Echo.
    Echo 8 CaractŠres minimum !!!
    Echo.
    Echo Appuyez sur une touche pour recommencer
    Pause>Nul
    Color 0F
    Cls
    Set "Passwd="
    Goto :SetPassword
)

:: Vérification du mot de passe	
Set /P "ConfirmPasswd=Confirmez le mot de passe "
If "!ConfirmPasswd!" EQU "" Goto :SetPasswordConfirm
If "!ConfirmPasswd!" NEQ "!Passwd!" (
      Color 0C
      Echo.
      Echo Erreur lors de la v‚rification du mot de passe
      Echo Appuyez sur une touche pour recommencer.
      Pause>Nul
      Goto :SetPassword
)
Exit /B


:: Demande du nom du serveur pour les crédentials. Si vide, utilise "Serveur"
:GetServerName
Set "Server=Serveur"
Set /P "Server=Veuillez indiquer le nom du serveur (Par d‚faut : %Server%) : "
Exit /b


:: Titre : SUUCES
:SuccessTitle
	@Echo 
	Color 0A
	Echo.
	Echo.
	Echo                              ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	Echo                              º       SUCCES       º
	Echo                              ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
	Echo.
	Echo.
	Echo.
Exit /b


:: Titre : ERREUR
:ErrorTitle
	@Echo 
	Color 0C
	Echo.
	Echo.
	Echo                              ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	Echo                              º       ERREUR       º
	Echo                              ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
	Echo.
	Echo.
	Echo.
Exit /b


:: Titre : INFORMATION
:InfoTitle
	@Echo 
	Color 0E
	Echo.
	Echo.
	Echo                              ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	Echo                              º     INFORMATION     º
	Echo                              ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
	Echo.
	Echo.
	Echo.
Exit /b


:: Pause avec message
:Pause
Echo %~1
::Echo Appuyez sur une touche pour continuer ou quitter.
Echo.
Pause>NUL
Exit /b
