:: AddUser2Shares.cmd créé par Tlem33.
:: Ce batch ajoute ou supprime un utilisateur dans le
:: système et/ou sur un ou plusieurs partages. 
::
:: Version 1.0.1 du 01-06-2018
::

@Echo Off
Cls

:: ================================================================
:: Entrez ici le nom de l'utilisateur et le mot de passe à traiter.
Set User=Nom_Utilisateur
Set Passwd=Mot_De_Passe
Set FullName=Nom_Complet_Utilisateur
:: ================================================================


:: Déclaration des variables d'exécutables avec chemin.
Set SubinaclExe="%~DP0subinacl.exe"
Set IcaclsExe="%WINDIR%\System32\Icacls.exe"
Set NetExe="%WINDIR%\System32\Net.exe"
Set RegExe="%WINDIR%\System32\Reg.exe"
Set WmicExe="%WINDIR%\System32\wbem\Wmic.exe"


:: On appelle la fonction de tests
Call :Tests

:: On demande les droits admin.
Call :GetAdminRight

mode con cols=80 lines=25
:Menu
Cls
Color 0F
Echo.
Echo                         ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
Echo                         º                              º
Echo                         º      AddUser2Share Tools     º
Echo                         º                              º
Echo                         ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
Echo.
Echo.
Echo                         Utilisateur  : %User%
Echo                         Mot de passe : %Passwd%
Echo.
Echo.
Echo   Veuillez s‚lectionner l'action … r‚aliser :
Echo.
Echo          1 - Ajouter l'utilisateur au systŠme
Echo.
Echo          2 - Ajouter l'utilisateur sur un partage
Echo.
Echo          3 - Supprimer l'utilisateur
Echo.
Echo          4 - Quitter
Echo.
Echo.
Set /P Ret=Entrez votre choix (1, 2, 3) : 
If /I "%Ret%" EQU "1" Goto :AddUser
If /I "%Ret%" EQU "2" Goto :Add2Share
If /I "%Ret%" EQU "3" Goto :DelUser
If /I "%Ret%" EQU "4" Exit
Goto :Menu


:AddUser
Cls
:: Test si le compte existe déjà.
Net User "%User%">Nul 2>Nul
If %errorlevel% EQU 0 (
	Call :InfoTitle
	Echo Le Compte %User% existe d‚ja !
	Call :Pause
	Goto :Menu
)

Echo.
Echo Appuyez sur une touche pour confirmer l'ajout de l'utilisateur :
Echo.
Echo                Utilisateur  : %User%
Echo                Mot de passe : %Passwd%
Echo.
Echo Cet utilisateur sera rajouter sur ce PC et dans le groupe administrateur.
Call :Pause

:: Ajout du compte utilisateur - Pas d'expiration et ne peux pas changer le mot de passe.
%NetExe% User "%User%" "%Passwd%" /ADD /FULLNAME:"%FullName%" /EXPIRES:NEVER /PASSWORDCHG:NO
:: Ajout de l'utilisateur dans le groupe Administrateur
%NetExe% localgroup Administrateurs "%User%" /ADD
:: "%WINDIR%\System32\Net.exe" accounts /MAXPWAGE:UNLIMITED

:: Désactivation de l'expiration du mot de passe.
%WmicExe% UserAccount where Name='%User%' set PasswordExpires=False

:: Cache le compte sur l'ouverture de session.
%RegExe% ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /V "%User%" /T REG_DWORD /D "0" /F
:: Commande pour afficher le compte.
:: %RegExe% DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /V "Administrateur" /F

:: Test si l'utilisateur à bien été créé.
%NetExe% User "%User%">Nul 2>Nul
If %errorlevel% NEQ 0 (
	Call :ErrorTitle
	Echo Compte %User% non cr‚‚ !
	Echo.
	Echo V‚rifiez que vous avez lanc‚ ce programme avec les droits
	Echo Administrateur, sinon veuillez cr‚er le compte manuellement.
	Call :Pause
	Exit
)

Call :SuccessTitle
Echo L'utilisateur %User% a bien ‚t‚ ajout‚.
Call :Pause

Goto :Menu

:DelUser
Cls
:: Test si le compte existe.
Net User "%User%">Nul 2>Nul
If %errorlevel% NEQ 0 (
	Call :InfoTitle
	Echo Le Compte %User% n'existe pas !
	Call :Pause
	Goto :Menu
)

Echo.
Echo Appuyez sur une touche pour confirmer la suppression de l'utilisateur :
Echo.
Echo                Utilisateur  : %User%
Echo.
Echo.
Echo Ce compte utilisateur sera aussi supprim‚ de tous les partages du systŠme.
Call :Pause

:: Cette boucle permet de lister noms et chemins des partages au format csv et de filtrer ceux avec le "$"
For /f "Skip=2 Tokens=1,2,3 Delims=," %%a In ('wmic share get name^,path /format:csv ^| findstr /i /l /v "$"') Do (
	If "%%a" NEQ "" Call :RemoveUserOnShare "%%b" "%%c"
)

:: Suppression du compte utilisateur
Echo Suppression de l'utilisateur.
Net User "%User%" /DELETE

:: Supprime la clé de registre inutile.
Echo Suppression de la cl‚ "%User%" dans "SpecialAccounts"
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /V "%User%" /F
Echo.

:: Pause de 3 secondes.
Ping -n 3 127.0.0.1>Nul

Cls
:: On vérifie si le compte utilisateur a été supprimé.
Net User "%User%">Nul 2>Nul
If %errorlevel% EQU 0 (
	Call :ErrorTitle
	Echo Compte %User% toujours existant !
	Echo.
	Echo. Veuillez supprimer le compte manuellement.
	Call :Pause
	Exit
)

Call :SuccessTitle
Echo L'utilisateur %User% a bien ‚t‚ supprim‚.
Call :Pause
Goto :Menu


:Add2Share
Cls
:: Test si le compte existe.
Net User "%User%">Nul 2>Nul
If %errorlevel% NEQ 0 (
	Call :InfoTitle
	Echo Le Compte %User% n'existe pas !
	Call :Pause
	Goto :Menu
)

:: Cette boucle permet de lister noms et chemins des partages au format csv et de filtrer ceux avec le "$"
For /f "Skip=2 Tokens=1,2,3 Delims=," %%a In ('wmic share get name^,path /format:csv ^| findstr /i /l /v "$"') Do (
	If "%%a" NEQ "" Call :Add2Share "%%b" "%%c"
)

:: Si aucun partage trouvé
If %Count%==0 (
	Call :ErrorTitle
	Echo Aucun partage n'a ‚t‚ trouv‚ sur ce systŠme !
	Call :Pause
	Exit
)

Echo.&Echo.
Echo Ajout de l'utilisateur %User% sur le/les partages termin‚.
Call :Pause
Goto :Menu


:Add2Share
:: Compte le nombre de partage trouvé
Set /A Count+=1
Set lng=0
Set ShareName=%~1
Set SharePath=%~2

:: Astuce pour supprimer le backslash sur partage racine (x:\ => x:)
If "%SharePath:~-1,1%"=="\" Set SharePath=%SharePath:~0,-1%

:YesOrNo
Cls
Color 0F
Echo Nom du partage    : %ShareName%
Echo Chemin du partage : %SharePath%
Echo.
Set /P Ret=  Ajouter l'utilisateur %User% au partage ci-dessus (o/n)? 
Echo.
If /I "%Ret%" EQU "o" Goto :Add2ShareYes
If /I "%Ret%" EQU "n" Goto :Eof
Goto :YesOrNo

:Add2ShareYes
Echo.&Echo.
Echo Ajout de l'utilisateur %User% au partage "%ShareName%"
%SubinaclExe% /share "%ShareName%" /grant="%User%"=F

Echo.&Echo.
Echo Attribution des droits sur le chemin du partage :
%IcaclsExe% "%SharePath%" /Grant "%User%":(OI)(CI)F /C

Echo.&Echo.
Echo Test de l'attribution des droits :
%IcaclsExe% "%SharePath%"|Findstr "%User%"

Echo.&Echo.
If %ERRORLEVEL% EQU 0 (
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
Echo.&Echo.
Echo V‚rifiez les messages ci-dessus pour connaitre les d‚tails de l'op‚ration.
Call :Pause
Goto :Eof


:RemoveUserOnShare
Echo Test si l'utilisateur "%User%" a des droits sur le partage %1
%IcaclsExe% "%SharePath%"|Findstr "%User%"
If %ERRORLEVEL% EQU 1 Goto :Eof

Cls
Echo Suppression des droits pour "%User%"
Echo sur le dossier %2 du partage %1

Set SharePath=%~2
:: Astuce pour supprimer le backslash sur partage racine (x:\ => x:)
If "%SharePath:~-1,1%"=="\" Set SharePath=%SharePath:~0,-1%

%IcaclsExe% "%SharePath%" /remove "%User%" /T
Echo.
Goto :Eof


:Tests
:: Fonctions pour les tests divers avant exécution.
If Not Exist %SubinaclExe% (
	Call :ErrorTitle
	Echo Le programme Subinacl.exe n'a pas ‚t‚ trouv‚.
	Echo Celui-ci est n‚cessaire pour l'ajout aux partages.
	Call :Pause
	Exit
)
Goto :Eof

:SuccessTitle
	@Echo  
	Cls
	Color 0A
	Echo.
	Echo.
	Echo                              ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	Echo                              º       SUCCES       º
	Echo                              ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
	Echo.
	Echo.
	Echo.
Goto :Eof


:ErrorTitle
	@Echo  
	Cls
	Color 0C
	Echo.
	Echo.
	Echo                              ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	Echo                              º       ERREUR       º
	Echo                              ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
	Echo.
	Echo.
	Echo.
Goto :Eof


:InfoTitle
	Cls
	Color 0E
	Echo.
	Echo.
	Echo                              ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	Echo                              º     INFORMATION     º
	Echo                              ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
	Echo.
	Echo.
	Echo.
Goto :Eof


:Pause
::Echo. & Echo. & Echo. & Echo.
Echo Appuyez sur une touche pour continuer ou quitter.
Echo.
Pause>NUL
Goto :Eof


:GetAdminRight
:-------------------------------------
REM --> Contrôle des permissions (Version 29/02/2016).
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> Si erreur, pas de droits Admin ...
If '%errorlevel%' NEQ '0' (
    Echo Demande des privileges administratifs ...
    Ping -n 2 127.0.0.1>NUL
    Goto UACPrompt
) Else ( Goto GotAdmin )

:UACPrompt
    Rem CHCP 1250 est utilisé pour les machines dont le 8.3 est désactivé et pour copier les accents.
    CHCP 1250>NUL
    Echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\Getadmin.vbs"
    Echo UAC.ShellExecute "cmd.exe","^/c" ^& """%~s0 %~s1""", "", "runas", 1 >> "%temp%\GetAdmin.vbs"

    Cscript //Nologo "%temp%\GetAdmin.vbs"
    Exit
    ::Exit /B 1

:GotAdmin
    If Exist "%temp%\GetAdmin.vbs" (Del "%temp%\GetAdmin.vbs")
    Pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

:Eof
