:: AddUser2Shares.cmd créé par Tlem33
:: Ce batch ajoute ou supprime un utilisateur dans le
:: système et/ou sur un ou plusieurs partages ainsi que
:: les informations d'identification pour le client.
::
:: Version 1.7 du 12-09-2026
::
:: Lire le fichier README.md pour plus d'informations.
::

@Echo Off
Cls

:: ================================================================================
::                             CONFIGURATION UTILISATEUR
:: ================================================================================
:: Entrez ici les paramètres du compte de l'utilisateur et du serveur
:: Exemple : Set "UserName=NomUtilisateur"
Set "UserName="
Set "Password="
Set "ServerName="

:: Longueur minimale exigée pour le mot de passe
Set "PasswdMinChar=8"
:: ================================================================================
:: ================================================================================

:: Définition de la taille de la fenêtre Batch (91 colonnes et 31 lignes)
Mode Con:Cols=91 Lines=31

:: Défini la page de code en Multilingual Latin 1 pour afficher correctement le
:: cadre des menus même sur des systèmes dont la page de code est différente.
Chcp 850 >nul

:: Activation de l'expansion retardée des variables
:: Permet de mettre à jour et de lire la valeur d'une variable en temps réel à l'intérieur d'un bloc de code ou d'une boucle
setlocal EnableDelayedExpansion

:: ================================================================================
:: Déclaration des variables
:: ================================================================================
:: Version du batch :
Set "Version=1.6"

:: Ajout des chemins vers System32, wbem et Powershell au path (au cas ou)
SET "PATH=%PATH%;%WINDIR%\System32;%WINDIR%\System32\wbem;%WINDIR%\System32\WindowsPowerShell\v1.0"

:: Commande Powershell mise en variable pour raccourcir le code
Set "PwrShell=Powershell.exe -NoProfile -ExecutionPolicy Unrestricted -Command"

:: Chemin et nom du fichier Log (Même nom que le script)
Set "LogFile=%~dpn0.Log"
Set "TestFile=%~dpn0.test"

:: Test d'ecriture : si le dossier du script est en lecture seule, bascule sur le Bureau de l'utilisateur
(Echo.>>"%TestFile%") 2>nul
If Not Exist "%TestFile%" (
    For /F "usebackq delims=" %%D In (`%PwrShell% "[Environment]::GetFolderPath('Desktop')"`) Do Set "DesktopPath=%%D"
    Set "LogFile=!DesktopPath!\%~n0.Log"
)
If Exist "%TestFile%" Del "%TestFile%" >Nul 2>Nul

:: Déclaration du titre de la fenêtre batch
Title==: AddUser2Shares version %version%

:: Variable de contrôle pour CMDKEY
Set "CMDKEY=1"
:: ================================================================================
:: ================================================================================

:: Demande des droits admin.
Net.exe session 1>NUL 2>NUL || (Powershell start-process """%~dpnx0""" "%*" -verb RunAs & Exit /b 1)

:: ================================================================================
:: Verification de la presence des outils necessaires
:: ================================================================================
Where PowerShell.exe >nul 2>&1
If "%Errorlevel%" EQU "1" (
	Call :WriteLog "ERREUR : Powershell n'est pas disponible sur cet ordinateur"
	Color 0C
	Echo.
	Echo PowerShell est introuvable sur ce systŠme.
	Echo Ce script ne peut pas fonctionner sans PowerShell.
	Echo.
	Call :Pause "Appuyez sur une touche pour terminer"
	Call :Quit 
)

Where cmdkey.exe >nul 2>&1
If "%Errorlevel%" EQU "1" (
	Call :WriteLog "ERREUR : CMDKEY n'est pas disponible sur cet ordinateur"
	Set "CMDKEY=0"
	Color 0E
	Echo.
	Echo CMDKEY est introuvable sur ce systŠme.
	Echo La gestion des informations d'identification ne sera pas disponible.
	Echo.
	Call :Pause "Appuyez sur une touche pour continuer"
)

:: Ecriture du démarrage dans le fichier Log
Call :WriteLog 
Call :WriteLog "Démarrage du programme %~n0 sur l'ordinateur [%ComputerName%]"

:: Récupération du nom du groupe administrateur à partir du SID (permet l'utilisation du script sur un système d'une autre langue) :
For /F "Delims=" %%n In ('%PwrShell% ^
    "(New-Object System.Security.Principal.SecurityIdentifier('S-1-5-32-544')). " ^
    "Translate([System.Security.Principal.NTAccount]). " ^
    "Value.Split('\')[-1]"') Do Set "AdminGrp=%%n"

:: Test Si le nom de l'utilisateur est indiqué en dur, sinon demande de rentrer le nom
If "%UserName%" EQU "" (
	Call :GetUserName
) Else (
	Set "User=%Username%"
)
:: Vérification de la validité du nom (règles Microsoft)
Call :CheckUserName

:: Test Si le mot de passe est indiqué en dur. Si Pass est spécifié, alors Passwd=%Pass%
If "%Password%" NEQ "" Set "Passwd=%Password%"
:: Vérification de la validité du mot de passe
If "%Passwd%" NEQ "" Call :CheckPassword

:: ================================================================================
::                                  Menu principal
:: ================================================================================
:Menu_Principal
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
Echo                         Mot de passe : !Passwd_Hide!
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

If "%CHOIXRESULT%" EQU "1" Goto :AddUser
If "%CHOIXRESULT%" EQU "2" Goto :DelUser
If "%CHOIXRESULT%" EQU "3" Goto :View-Hide-User
If "%CHOIXRESULT%" EQU "4" Goto :Add2Share
If "%CHOIXRESULT%" EQU "5" Goto :Menu_Credentials
If "%CHOIXRESULT%" EQU "6" Goto :Menu_Utilitaires
If "%CHOIXRESULT%" EQU "7" Goto :Quit
Goto :Menu_Principal


:: ================================================================================
::                                  Menu crédentials
:: ================================================================================
:Menu_Credentials
Cls
Set "Menu=Menu_credentials"
Color 0F
Echo                         ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
Echo                         º                              º
Echo                         º      AddUser2Shares v%version%     º
Echo                         º       Menu credentials       º
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
Echo          2 - Supprimer les informations d'identification pour un serveur
Echo.
Echo          3 - Afficher la liste des informations d'identification des serveurs
Echo.
Echo          4 - Lancer l'utilitaire de gestion des informations d'identification
Echo.
Echo          5 - Menu principal
Echo.
Echo          6 - Quitter
Echo.
Choice /C 123456 /M "Entrez votre choix : "
Set "CHOIXRESULT=%Errorlevel%"

If "%CHOIXRESULT%" EQU "1" Goto :CredentialAdd
If "%CHOIXRESULT%" EQU "2" Goto :CredentialDel
If "%CHOIXRESULT%" EQU "3" Goto :CredentialView
If "%CHOIXRESULT%" EQU "4" Goto :CredentialManager
If "%CHOIXRESULT%" EQU "5" Goto :Menu_Principal
If "%CHOIXRESULT%" EQU "6" Goto :Quit
Goto :Menu_Credentials


:: ================================================================================
::                                 Menu Utilitaires
:: ================================================================================
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

If "%CHOIXRESULT%" EQU "1" Start "lusrmgr.msc" lusrmgr.msc & Goto :%Menu%
If "%CHOIXRESULT%" EQU "2" Start "fsmgmt.msc" fsmgmt.msc & Goto :%Menu%
If "%CHOIXRESULT%" EQU "3" Start "ncpa.cpl" ncpa.cpl & Goto :%Menu%
If "%CHOIXRESULT%" EQU "4" Goto :Menu_Principal
If "%CHOIXRESULT%" EQU "5" Goto :Quit
Goto :Menu_Utilitaires


:: ================================================================================
::                        Fonction d'ajout de l'utilisateur
:: ================================================================================
:AddUser
Cls
Set "Admin=0"
:: Test si le compte existe déjà.
Net.exe User "%User%">Nul 2>Nul
If "%Errorlevel%" EQU "0" (
	Call :InfoTitle
	Echo Le Compte "%User%" existe d‚ja !
	Call :Pause "Appuyez sur une touche pour revenir au menu"
	Goto :Menu_Principal
)

:: Utilise le mot de passe écrit en dur s'il existe
If "%Pass%" NEQ "" Set "Passwd=%Pass%"
:: Si le mot de passe est vide, on demande la saisie
:: Sinon on contrôle sa validité
If "%Passwd%" EQU "" (
    Call :SetPassword
) Else (
    Call :CheckPassword
    If "!PwdCheck!" NEQ "OK" Call :SetPassword
)

:: Ajout du membre %User% au groupe Administrateurs (fonctionne aussi pour d'autres langues) :
Echo.
Choice /C ON /M "Souhaitez-vous ajouter ce compte au groupe %AdminGrp% ? "
If "%Errorlevel%" EQU "1" Set "Admin=1"

Echo.
Echo.
Echo                Utilisateur    : %User%
Echo                Mot de passe   : %Passwd_Hide%
If "%Admin%" EQU "1" (
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
Choice /C ON /M "Confirmez-vous l'ajout du compte utilisateur : %User% ? "
If "%Errorlevel%" NEQ "1" Goto :Menu_Principal

:: Ajout de l'utilisateur %User% avec mot de passe %Passwd% :
Echo Creation du compte %User%
%PwrShell% ^
    "New-LocalUser " ^
    "  -Name '%User%' " ^
    "  -Description 'Utilisateur %User%' " ^
    "  -Password (ConvertTo-SecureString -AsPlainText '%Passwd%' -Force) " ^
    "  -PasswordNeverExpires:$True ; " ^
    "Add-LocalGroupMember " ^
    "  -SID 'S-1-5-32-545' " ^
    "  -Member '%User%'"

:: Ajout du membre %User% au groupe Administrateurs (fonctionne aussi pour d'autres langues) :
If "%Admin%" EQU "1" %PwrShell% "Add-LocalGroupMember -SID 'S-1-5-32-544' -Member '%User%'"

:: Test si l'utilisateur à bien été créé.
Net.exe User "%User%">Nul 2>Nul
If "%Errorlevel%" NEQ "0" (
	Call :WriteLog "Erreur lors de l'ajout de l'utilisateur !User!"
	Call :ErrorTitle
	Echo Compte "%User%" non cr‚‚ !
	Echo.
	Echo V‚rifiez que vous avez lanc‚ ce programme avec les droits
	Echo Administrateur, sinon veuillez cr‚er le compte manuellement.
	Call :Pause "Appuyez sur une touche pour revenir au menu"
	Goto :Menu_Principal
)

:: Récupération de la liste des groupes de l'utilisateur (séparés par une virgule)
For /f "delims=" %%g In ('%PwrShell% ^
    "(Get-LocalGroup | Where-Object { " ^
    "  (Get-LocalGroupMember $_.Name -ErrorAction SilentlyContinue) | " ^
    "  Where-Object { $_.Name -like ('*\' + '%User%') } " ^
    "}).Name -join ', '"') Do Set "UserGpr=%%g"

Call :WriteLog "Ajout de l'utilisateur %User% - Groupes : %UserGpr%"
Echo R‚capitulatif :
Echo.
Echo      Utilisateur  : %User%
Echo      Mot de passe : %Passwd_Hide%
Echo      Groupe(s)    : %UserGpr%
Echo.
Call :SuccessTitle
Echo L'utilisateur a bien ‚t‚ ajout‚ dans le systŠme.
Call :Pause "Appuyez sur une touche pour revenir au menu"
Set "Passwd="
Goto :Menu_Principal


:: ================================================================================
::                     Fonction de suppression de l'utilisateur
:: ================================================================================
:DelUser
Cls
:: Test si le compte existe.
Net.exe User "%User%">Nul 2>Nul
If "%Errorlevel%" NEQ "0" (
	Call :InfoTitle
	Echo Le Compte "%User%" n'existe pas !
	Call :Pause "Appuyez sur une touche pour revenir au menu"
	Goto :Menu_Principal
)

Echo.
Echo Appuyez sur une touche pour confirmer la suppression de l'utilisateur :
Echo.
Echo                Utilisateur  : %User%
Echo.
Echo.
Echo Ce compte utilisateur sera aussi supprim‚ de tous les partages du systŠme.
Choice /C ON /M "Confirmez-vous la suppression du compte utilisateur : %User% ? "
If "%Errorlevel%" NEQ "1" Goto :Menu_Principal

:: Boucle sur tous les partages (hors partages admin type C$, IPC$...)
:: On utilise ";" comme separateur plutot que "," pour eviter les soucis d'echappement
For /f "Tokens=1,2 Delims=;" %%a In ('%pwrshell% ^
    "Get-SmbShare | " ^
    "Where-Object { $_.Name -notlike '*$*' } | " ^
    "ForEach-Object { $_.Name + ';' + $_.Path }"') Do (
	If "%%a" NEQ "" Call :RemoveUserOnShare "%%a" "%%b"
)

:: Suppression du compte utilisateur
Echo.
Echo Suppression de l'utilisateur.
Net.exe User "%User%" /DELETE>Nul 2>Nul

:: Supprime la clé de registre inutile.
Echo Suppression de la cl‚ "%User%" dans "SpecialAccounts" si existante
Reg.exe DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /V "%User%" /F>Nul 2>Nul
Echo.

:: On vérifie si le compte utilisateur a été supprimé.
Net.exe User "%User%">Nul 2>Nul
If "%Errorlevel%" EQU "0" (
	Call :WriteLog "Erreur lors de la suppression de l'utilisateur !User!"
	Call :ErrorTitle
	Echo Compte "%User%" toujours existant !
	Echo.
	Echo. Veuillez supprimer le compte manuellement.
	Call :Pause "Appuyez sur une touche pour revenir au menu"
	Goto :Menu_Principal
)

Call :WriteLog "Suppression de l'utilisateur %User% et des droits associés"
Call :SuccessTitle
Echo L'utilisateur "%User%" a bien ‚t‚ supprim‚.
Call :Pause "Appuyez sur une touche pour revenir au menu"
Goto :Menu_Principal


:: ================================================================================
::                 Fonction d'affichage/masquage de l'utilisateur
:: ================================================================================
:View-Hide-User
Cls
Echo Afficher ou masquer l'utilisateur sur l'‚cran d'ouverture de session :
Echo.
Echo          Utilisateur    : %User%
Echo.
Choice /C AMQ /M "A pour afficher, M pour masquer, Q pour quitter : "
If "%Errorlevel%" EQU "2" (
	Reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /V "%User%" /T REG_DWORD /D "0" /F>Nul 2>Nul
	Call :WriteLog "Masquage du compte utilisateur %User% sur l'écran d'accueil"
	Echo Compte utilisateur %User% masqu‚.
	Timeout /T 5
)
If "%Errorlevel%" EQU "1" (
	Reg.exe DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /V "%User%" /F>Nul 2>Nul
	Call :WriteLog "Affichage du compte utilisateur %User% sur l'écran d'accueil"
	Echo Compte utilisateur %User% affich‚.
   Timeout /T 5
)
Goto :Menu_Principal


:: ================================================================================
::                     Fonction d'ajout utilisateur aux partages
:: ================================================================================
:Add2Share
Cls
Set "Count=0"
:: Test si le compte existe.
Net.exe User "%User%">Nul 2>Nul
If "%Errorlevel%" NEQ "0" (
	Call :InfoTitle
	Echo Le Compte "%User%" n'existe pas !
	Call :Pause "Appuyez sur une touche pour revenir au menu"
	Goto :Menu_Principal
)

:: Vérifie en Powershell si le SID de l'utilisateur appartient au groupe dont le SID est S-1-5-32-544
Set "RESULT=False"
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
    "} catch { Write-Output 'ERROR' }"`) Do (
    set "RESULT=%%R"
)

:: Si l'utilisateur fait partie du groupe Administrateurs
If /i "!RESULT!"=="True" (
	Call :InfoTitle
    Echo L'utilisateur %User% fait partie du groupe Administrateurs, par cons‚quent,
    Echo Il n'est pas nécessaire d'ajouter des droits sp‚cifiques suppl‚mentaires.
    Echo.
    Choice /C ON /M "Souhaitez-vous quand mˆme proc‚der … l'ajout des droits par partage ? "
    Set "CHOIXRESULT=!Errorlevel!"

    If "!CHOIXRESULT!"=="1" Cls & Color 0F
    If "!CHOIXRESULT!"=="2" Goto %Menu%
)


:: Via PowerShell, cette boucle liste les noms et les chemins des partages et filtre ceux avec le "$"
For /f "Tokens=1,2 Delims=;" %%a In ('%pwrshell% ^
    "Get-SmbShare | " ^
    "Where-Object { $_.Name -notlike '*$*' } | " ^
    "ForEach-Object { $_.Name + ';' + $_.Path }"') Do (
	If "%%a" NEQ "" Call :Add2ShareSub "%%a" "%%b"
)

:: Si aucun partage trouvé
If %Count%==0 (
	Call :ErrorTitle
	Echo Aucun partage n'a ‚t‚ trouv‚ sur ce systŠme !
	Call :Pause "Appuyez sur une touche pour revenir au menu"
	Goto :Menu_Principal
)

Echo.&Echo.
Echo Ajout de l'utilisateur "%User%" sur le/les partages termin‚.
Call :Pause "Appuyez sur une touche pour revenir au menu"
Goto :Menu_Principal


:: ================================================================================
::                      Demande d'ajout utilisateur au partage
:: ================================================================================
:Add2ShareSub
Cls & Color 0F
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
Goto :Menu_Principal


:: ================================================================================
::                          Ajoute l'utilisateur au partage
:: ================================================================================
:Add2ShareYes
:: Ajout de l'utilisateur %User% au partage %ShareName%
Echo.&Echo.
Echo Ajout de l'utilisateur "%User%" au partage "%ShareName%"
%pwrshell% ^
    "Grant-SmbShareAccess " ^
    "  -Name '%ShareName%' " ^
    "  -AccountName '%User%' " ^
    "  -AccessRight Full " ^
    "  -Force"
    
:: Ajout des droits en écriture sur le partge %SharePath%
Echo.&Echo.
Echo Attribution des droits sur le chemin du partage :
%pwrshell% ^
    "$acl = Get-Acl '%SharePath%'; " ^
    "$rule = New-Object System.Security.AccessControl.FileSystemAccessRule( " ^
    "  '%User%', " ^
    "  'FullControl', " ^
    "  ('ContainerInherit', 'ObjectInherit'), " ^
    "  'None', " ^
    "  'Allow' " ^
    "); " ^
    "$acl.AddAccessRule($rule); " ^
    "Set-Acl -Path '%SharePath%' -AclObject $acl"
    
:: Test de l'attribution des droits
Echo.&Echo.
Echo Test de l'attribution des droits :
For /f "delims=" %%r In ('%pwrshell% ^
    "if ((Get-Acl '%SharePath%').Access | Where-Object { " ^
    "  $_.IdentityReference -like '*%User%*' " ^
    "}) { 'OK' } else { 'KO' }"') Do Set "AclCheck=%%r"
    
:: Message d'information concernant l'ajout des droits pour %User%
Echo.&Echo.
If "%AclCheck%" EQU "OK" (
	Call :WriteLog "Ajout de !User! au partage !ShareName! - Dossier : !SharePath!"
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


:: ================================================================================
::                        Supprime l'utilisateur du partage
:: ================================================================================
:RemoveUserOnShare
set "ShareName=%~1"
set "SharePath=%~2"
If "%SharePath:~-1,1%"=="\" Set "SharePath=%SharePath:~0,-1%"
Echo Traitement du partage "%ShareName%" (%SharePath%)...

:: Suppression de l'utilisateur %User% sur le partage %ShareName%
Echo.&Echo.
Echo Retrait de l'utilisateur "%User%" du partage "%ShareName%"
%pwrshell% ^
    "Revoke-SmbShareAccess " ^
    "  -Name '%ShareName%' " ^
    "  -AccountName '%User%' " ^
    "  -Force " ^
    "  -Confirm:$false " ^
    "  -ErrorAction SilentlyContinue"

:: Suppression des droits pour l'utilisateur %User%  
Echo.&Echo.
Echo Retrait des droits NTFS sur le chemin du partage :
%pwrshell% ^
    "$p='%SharePath%'; " ^
    "$u='%User%'; " ^
    "If (Test-Path $p) { " ^
    "  $acl = Get-Acl $p; " ^
    "  $rules = $acl.Access | Where-Object { " ^
    "    $_.IdentityReference.Value -ieq ('.\' + $u) -or " ^
    "    $_.IdentityReference.Value -ieq $u -or " ^
    "    $_.IdentityReference.Value -like ('*\' + $u) " ^
    "  }; " ^
    "  foreach ($r in $rules) { " ^
    "    $acl.RemoveAccessRule($r) | Out-Null " ^
    "  }; " ^
    "  Set-Acl -Path $p -AclObject $acl " ^
    "}"
    
:: Test de la suppression des droits pour %User%
Echo.&Echo.
Echo Test du retrait des droits :
For /f "delims=" %%r In ('%pwrshell% ^
    "$p='%SharePath%'; " ^
    "$u='%User%'; " ^
    "$still = (Get-Acl $p).Access | Where-Object { " ^
    "  $_.IdentityReference.Value -ieq ('.\' + $u) -or " ^
    "  $_.IdentityReference.Value -ieq $u -or " ^
    "  $_.IdentityReference.Value -like ('*\' + $u) " ^
    "}; " ^
    "If ($still) { 'KO' } Else { 'OK' }"') Do Set "AclCheck=%%r"

:: Message d'information concernant la suppression des droits pour %User%
Echo.&Echo.
If "%AclCheck%"=="OK" (
	Color 0A
	Call :WriteLog "Retrait de !User! du partage !ShareName! - Dossier : !SharePath!"
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


:: ================================================================================
::                       Affichage de la liste des crédentials
:: ================================================================================
:CredentialView
Cls
:: Test de Cmdkey.exe
If "%CMDKEY%" EQU "0" Goto :CmdKeyMissing

:: Liste les credentials dans la fenêtre du batch
cmdkey.exe /list

Echo Appuyez sur une touche pour revenir au menu.
Pause>Nul
Goto :Menu_Credentials


:: ================================================================================
::                      Ouverture de la gestion des crédentials
:: ================================================================================
:CredentialManager
:: Lance l'outils de gestion des informations d'identification
Call control /name Microsoft.CredentialManager
Goto :Menu_Credentials


:: ================================================================================
::                         Fonction d'ajout des crédentials
:: ================================================================================
:CredentialAdd
Cls
:: Test de Cmdkey.exe
If "%CMDKEY%" EQU "0" Goto :CmdKeyMissing

:: Remise à zéro de InputServer
Set "InputServer="

:: Utilise la valeur de %Username% si elle est définie au début du script
If "%Username%" NEQ "" Set "User=%Username%"

:: Test Si %User% est vide, sinon demande de rentrer le nom
If "%User%" EQU "" Call :GetUserName

:: Vérification de la validité du nom (règles Microsoft)
Call :CheckUserName

:: Utilise la valeur de %Password% si elle est définie au début du script
If "%Password%" NEQ "" Set "Passwd=%Password%"

:: Test Si %Passwd% est vide, sinon demande de rentrer le mot de passe
:: Ensuite, on vérifie la syntaxe
If "%Passwd%" EQU "" (
    Call :SetPassword
) Else (
    Call :CheckPassword
    If "!PwdCheck!" NEQ "OK" Call :SetPassword
)

:: Si %Server% n'est pas indiqué au début du script, demande le nom à utiliser + vérification syntaxe
:: Sinon utilise le nom indiqué + vérification syntaxe
If "!ServerName!" EQU "" (
    Call :SetServer
) Else (
	Set "Server=!ServerName!"
    Call :CheckServer
    If "!SrvCheck!" NEQ "OK" Call :SetServer
)

:: Si 0 on retourne au menu crédentials
If "!InputServer!" EQU "0" Goto :Menu_Credentials

:: Vérification de la présence d'information existantes
Call :CheckCredential "!Server!"
If "!CredCheck!" EQU "1" (
	Color 0E
	Echo.
	Echo Des informations d'identification existent d‚j… pour "!Server!"
	Choice /C ON /M "Souhaitez-vous les remplacer par les nouvelles ? "
	If "!Errorlevel!" NEQ "1" Goto :Menu_Credentials
	Color 0F
)

:: Message récapitulatif avant exécution
Echo.
Echo     R‚capitulatif des informations d'identifications
Echo.
Echo          Utilisateur    : %User%
Echo          Mot de passe   : %Passwd_Hide%
Echo          Nom du Serveur : %Server%
Echo.

:: Demande de confirmation
Choice /C ON /M "Confirmez-vous l'ajout de ces informations d'identification ? "
If "%Errorlevel%" NEQ "1" Goto :Menu_Credentials

:: Exécution de la commande d'ajout des credentials
cmdkey.exe /add:"!Server!" /user:"!User!" /pass:"!Passwd!">Nul 2>Nul

:: Vérification de la bonne exécution de la commande
Call :CheckCredential "!Server!"
If "!CredCheck!" EQU "1" (
	Call :WriteLog "Ajout des informations d'identification pour !Server! - Utilisateur !User!"
	Color 0A
	Echo.
	Echo Op‚ration termin‚e avec succŠs
) Else (
	Color 0C
	Echo.
	Echo Erreur lors de l'ajout des informations d'identification
)

Timeout /T 10
Goto :Menu_Credentials


:: ================================================================================
::                     Fonction de suppression des crédentials
:: ================================================================================
:CredentialDel
Cls
:: Test de Cmdkey.exe
If "%CMDKEY%" EQU "0" Goto :CmdKeyMissing

:: Remise à zéro de InputServer
Set "InputServer="

:: Si %Server% n'est pas indiqué au début du script, demande le nom à utiliser + vérification syntaxe
:: Sinon utilise le nom indiqué + vérification syntaxe
If "!ServerName!" EQU "" (
    Call :SetServer
) Else (
	Set "Server=!ServerName!"
    Call :CheckServer
    If "!SrvCheck!" NEQ "OK" Call :SetServer
)

:: Si 0 on retourne au menu crédentials
If "!InputServer!" EQU "0" Goto :Menu_Credentials

:: Vérification de la présence des informations d'identification pour !Server! en Powershell
Call :CheckCredential "!Server!"
If "!CredCheck!" EQU "0" (
    Color 0E
    Echo.
    Echo Il n'existe pas d'informations d'identification pour "!Server!" sur cette machine.
    Echo.
    Echo Appuyez sur une touche pour revenir au menu
    Pause>Nul
    Goto :Menu_Credentials
)

:: Message récapitulatif avant exécution
Echo.
Echo     Suppression des informations d'identifications pour
Echo.
Echo          Utilisateur    : NA
Echo          Mot de passe   : NA
Echo          Nom du Serveur : !Server!
Echo.
Echo Confirmez-vous la suppression des informations
Choice /C ON /M "d'identification pour l'ordinateur '!Server!' ? "
If "%Errorlevel%" NEQ "1" Goto :Menu_Credentials

:: Exécution de la commande de suppression
cmdkey.exe /delete:"!Server!"> Nul 2>Nul

:: Vérification de la bonne execution de la commande
Call :CheckCredential "!Server!"
If "!CredCheck!" EQU "0" (
	Call :WriteLog "Suppression des informations d'identification pour !Server!"
	Color 0A
	Echo.
	Echo Op‚ration termin‚e avec succŠs
) Else (
	Color 0C
	Echo.
	Echo Erreur lors de la suppression
)

Timeout /T 10
Goto :Menu_Credentials


:: ================================================================================
::                           Demande du nom de utilisateur
:: ================================================================================
:GetUserName
Cls
Color 0F

:: Message d'informations
Echo La valeur "User=" n'est pas renseign‚e dans le script.
Echo.
Echo Veuillez indiquer le nom de l'utilisateur … g‚rer
Echo Max 20 caractŠres avec lettres, chiffres, point, tiret, underscore
Echo.

:: Commande de saisie du nom utilisateur
Set /P "User=Nom de l'utilisateur (0 pour quitter) : "

:: Vérification de la saisie
If "!User!" EQU "" Goto :GetUserName
If "!User!" EQU "0" Call :Quit
Exit /b


:: ================================================================================
::                       Vérification du nom de utilisateur
:: ================================================================================
:CheckUserName
:: Via Powershell, vérification de la longueur et des caractères autorisés
For /F "Usebackq Delims=" %%R In (`%pwrshell% ^
    "If ($env:User -notmatch '^[a-zA-Z0-9._-]+$') { " ^
    "  'NotAllowed' " ^
    "} Elseif ($env:User.Length -gt 20) { " ^
    "  'TOOLONG' " ^
    "} Else { " ^
    "  'OK' " ^
    "}"`) Do Set "UserCheck=%%R"

:: Si le nom de l'utilisateur contient des caractères non autorirés
If "!UserCheck!" EQU "NotAllowed" (
    Color 0C
    Echo.
    Echo Le nom d'utilisateur "!User!" contient des caractŠres non valides.
    Echo     Autoris‚s : lettres, chiffres, point, tiret, underscore
    Echo.
    Echo Appuyez sur une touche pour saisir un nouveau nom
    Pause>Nul
    Color 0F
    Set "User="
    Call :GetUserName
    Goto :CheckUserName
)

:: Si le nom de l'utilisateur est trop long (+ de 20 caractères)
If "!UserCheck!" EQU "TOOLONG" (
    Color 0C
    Echo.
    Echo Le nom d'utilisateur "!User!" ne doit pas d‚passer 20 caractŠres.
    Echo.
    Echo Appuyez sur une touche pour saisir un nouveau nom
    Pause>Nul
    Color 0F
    Set "User="
    Call :GetUserName
    Goto :CheckUserName
)
Exit /b


:: ================================================================================
::                        Demande du mot de passe utilisateur
:: ================================================================================
:SetPassword
:SetPasswordEntry
Cls
Color 0F

:: Message d'informations
Echo.
Echo Veuillez indiquer le mot de passe de l'utilisateur :
Echo     - Ne pas utiliser les caractŠres sp‚ciaux : ^< ^> ^^ ^& " ( )
Echo     - Longueur minimale !PasswdMinChar! caractŠres
Echo.

:: Commande de saisie du nom utilisateur
Set /P "User=Nom de l'utilisateur (0 pour quitter) : "

:: Vérification de la saisie
If "!Passwd!" EQU "" Goto :SetPasswordEntry
If "!Passwd!" EQU "0" Goto :Menu_Principal

:: Vérification syntaxique du mot de passe
Call :CheckPassword
If "!PwdCheck!" NEQ "OK" (
    Set "Passwd="
    Goto :SetPasswordEntry
)

:: Demande de confirmer le mot de passe	
Set /P "ConfirmPasswd=Confirmez le mot de passe "
If "!ConfirmPasswd!" EQU "" Goto :SetPasswordEntry
If "!ConfirmPasswd!" NEQ "!Passwd!" (
      Color 0C
      Echo.
      Echo Erreur lors de la v‚rification du mot de passe
      Echo Appuyez sur une touche pour recommencer.
      Pause>Nul
      Goto :SetPasswordEntry
)
Exit /B


:: ================================================================================
::                           Vérification du mot de passe
:: ================================================================================
:CheckPassword
:: Via Powershell, vérification de la longueur et des caractères autorisés
For /F "Usebackq Tokens=1,2 Delims=;" %%A In (`%pwrshell% ^
    "$pattern = '[<>&()' + [char]34 + ']'; " ^
    "If ($env:Passwd -match $pattern) { " ^
    "  'NotAllowed;' + $env:Passwd.Length " ^
    "} Elseif ($env:Passwd.Length -lt [int]$env:PasswdMinChar) { " ^
    "  'TOOSHORT;' + $env:Passwd.Length " ^
    "} Else { " ^
    "  'OK;' + $env:Passwd.Length " ^
    "}"`) Do (
    Set "PwdCheck=%%A"
    Set "PwdLen=%%B"
)

:: Construction de la chaine d'étoiles de même longueur que le mot de passe
Set "Passwd_Hide="
For /L %%i In (1,1,!PwdLen!) Do Set "Passwd_Hide=!Passwd_Hide!*"

:: Si le mot de passe contient des caractères non autorirés
If "!PwdCheck!" EQU "NotAllowed" (
    Color 0C
    Echo.
    Echo caractŠres interdits d‚tect‚s.
    Echo.
    Echo Appuyez sur une touche pour saisir un nouveau mot de passe
    Pause>Nul
    Color 0F
)

:: Si le mot de passe est trop court
If "!PwdCheck!" EQU "TOOSHORT" (
    Color 0C
    Echo.
    Echo !PasswdMinChar! caractŠres minimum !!!
    Echo.
    Echo Appuyez sur une touche pour saisir un nouveau mot de passe
    Pause>Nul
    Color 0F
)
Exit /b


:: ================================================================================
::                             Demande du nom du serveur
:: ================================================================================
:SetServer
Echo Veuillez indiquer le nom du serveur
Echo Max 15 caracteres avec lettres, chiffres, point, tiret, underscore

:: Demande le nom du serveur + Vérification syntaxe
Set /P "InputServer=0 pour revenir au menu (Par d‚faut : Serveur) : "

:: Vérification de la saisie
If "%InputServer%" EQU "0" Exit /b
If "%InputServer%" EQU "" (
	Set "Server=Serveur"
) Else (
	Set "Server=%InputServer%"
)

:: Vérification syntaxique du nom du serveur
Call :CheckServer
If "!SrvCheck!" NEQ "OK" Goto :SetServer
Exit /b


:: ================================================================================
::                          Vérification du nom du serveur
:: ================================================================================
:CheckServer
:: Via Powershell, vérification de la longueur et des caractères autorisés
For /F "Usebackq Delims=" %%R In (`%pwrshell% ^
    "If ($env:Server -notmatch '^[a-zA-Z0-9._-]+$') { " ^
    "  'NotAllowed' " ^
    "} Elseif ($env:Server.Length -gt 15) { " ^
    "  'TOOLONG' " ^
    "} Else { " ^
    "  'OK' " ^
    "}"`) Do Set "SrvCheck=%%R"

:: Si le nom contient des caractères non autorirés
If "!SrvCheck!" EQU "NotAllowed" (
    Color 0C
    Echo.
    Echo Le nom de serveur "!Server!" contient des caractŠres non valides.
    Echo     Autoris‚s : lettres, chiffres, point, tiret, underscore
    Echo.
    Echo Appuyez sur une touche pour saisir un nouveau nom
    Pause>Nul
    Color 0F
)

:: Si le nom est trop long
If "!SrvCheck!" EQU "TOOLONG" (
    Color 0C
    Echo.
    Echo Le nom de serveur "!Server!" ne doit pas d‚passer 15 caractŠres.
    Echo.
    Echo Appuyez sur une touche pour saisir un nouveau nom
    Pause>Nul
    Color 0F
)
Exit /b


:: ================================================================================
::                                CMDKEY indisponible
:: ================================================================================
:CmdKeyMissing
:: Titre ERREUR
Call :ErrorTitle

:: Message
Echo CMDKEY n'est pas disponible sur ce systŠme.
Echo Cette fonctionnalit‚ est desactiv‚e.
Echo.

:: Pause
Call :Pause "Appuyez sur une touche pour revenir au menu"
Goto :Menu_Credentials



:: ================================================================================
::                    Vérification de l'existence des credentials
::
:: Utilisation : Call :CheckCredential "NomDuServeur"
:: Retourne "CredCheck" = 1 (existe) ou 0 (n'existe pas)
:: ================================================================================
:CheckCredential
Set "CredTarget=%~1"

:: Via Powershell, vérification de l'existance de crédentials pour CredTarget (%~1)
For /F "usebackq delims=" %%R In (`%pwrshell% ^
    "$q = [char]34; " ^
    "$mdef = '[DllImport(' + $q + 'advapi32.dll' + $q + ', SetLastError=true, CharSet=CharSet.Unicode)] public static extern bool CredRead(string target, int type, int reservedFlag, out IntPtr credentialPtr);'; " ^
    "Add-Type -MemberDefinition $mdef -Name Cred -Namespace Native -ErrorAction SilentlyContinue; " ^
    "$ptr = [IntPtr]::Zero; " ^
    "$found = [Native.Cred]::CredRead($env:CredTarget, 1, 0, [ref]$ptr); " ^
    "If (-not $found) { $found = [Native.Cred]::CredRead($env:CredTarget, 2, 0, [ref]$ptr) }; " ^
    "If ($found) { '1' } Else { '0' }"`) Do Set "CredCheck=%%R"
Exit /b


:: ================================================================================
::                               Ecriture dans le Log
::
:: Utilisation :  Call :WriteLog "Message"
:: ================================================================================
:WriteLog
If "%~1" EQU "" (
	Echo. >>"%LogFile%"
) Else (
	Echo %Date% %Time% - %~1 >>"%LogFile%"
)
Exit /b


:: ================================================================================
::                                Pause avec message
::
:: Utilisation :  Call :Pause "Message"
:: ================================================================================
:Pause
Echo %~1
Echo.
Pause>NUL
Exit /b


:: ================================================================================
::                                  Titre : SUCCES
:: ================================================================================
:SuccessTitle
	@Echo  
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


:: ================================================================================
::                                  Titre : ERREUR
:: ================================================================================
:ErrorTitle
	@Echo  
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


:: ================================================================================
::                                Titre : INFORMATION
:: ================================================================================
:InfoTitle
	@Echo  
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


:: ================================================================================
::                                   Fin du script
:: ================================================================================
:Quit
Call :WriteLog "Fin d'exécution du programme %~n0"
Exit
