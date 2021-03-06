:: AddUser2Shares.cmd cr�� par Tlem33
:: Ce batch ajoute ou supprime un utilisateur dans le
:: syst�me et/ou sur un ou plusieurs partages ainsi que
:: les informations d'identification pour le client.
::
:: Version 1.5 du 21/01/2021
:: Lire le fichier README.md pour plus d'informations.
::

@Echo Off
Cls

:: ================================================================================
::                               CONFIGURATION
:: ================================================================================
:: Entrez ici les param�tres du compte de l'utilisateur et du serveur
Set User=AdminHSF
Set Pass=HenrySchein37
Set FullName=Administrateur Henry Schein
Set Server=Serveur
:: ================================================================================

:: D�claration des variables
:: ================================================================================
:: Version :
Set Version=1.5

:: Ajout des chemins vers System32, wbem et Powershell au path (au cas ou)
SET "PATH=%PATH%;%WINDIR%\System32;%WINDIR%\System32\wbem;%WINDIR%\System32\WindowsPowerShell\v1.0"

Set SubinaclExe="%~DP0bin\subinacl.exe"
Set Title=AddUser2Shares version %version%
:: ================================================================================

:: On appelle la fonction de tests
Call :Tests

:: On demande les droits admin.
Net.exe session 1>NUL 2>NUL || (Powershell start-process """%~dpnx0""" "%*" -verb RunAs & Exit /b 1)

::mode con cols=80 lines=25
:Menu1
Cls
Color 0F
Echo                         ������������������������������ͻ
Echo                         �                              �
Echo                         �      AddUser2Shares v%version%     �
Echo                         �                              �
Echo                         ������������������������������ͼ
Echo.
Echo                         Utilisateur  : %User%
Echo                         Mot de passe : %Pass%
Echo.
Echo.
Echo   Veuillez s�lectionner l'action � r�aliser :
Echo.
Echo          1 - Ajouter l'utilisateur au syst�me
Echo.
Echo          2 - Ajouter l'utilisateur sur un partage
Echo.
Echo          3 - Supprimer l'utilisateur du syst�me
Echo.
Echo          4 - Ajout des informations d'identification
Echo.
Echo          5 - Raccourcis utiles
Echo.
Echo          6 - Quitter
Echo.
Choice /C 123456 /M "Entrez votre choix :"
If Errorlevel 6 Exit
If Errorlevel 5 Goto :Menu3
If Errorlevel 4 Goto :Menu2
If Errorlevel 3 Goto :DelUser
If Errorlevel 2 Goto :Add2Share
If Errorlevel 1 Goto :AddUser
Goto :Menu1


:Menu2
Cls
Color 0F
Echo                         ������������������������������ͻ
Echo                         �                              �
Echo                         �      AddUser2Shares v%version%     �
Echo                         �                              �
Echo                         ������������������������������ͼ
Echo.
Echo.
Echo.
Echo.
Echo.
Echo   Veuillez s�lectionner l'action � r�aliser :
Echo.
Echo          1 - Ajouter les informations d'identification pour %User%
Echo.
Echo          2 - Supprimer les informations d'identification pour %User%
Echo.
Echo          3 - Afficher la liste des informations d'identification
Echo.
Echo          4 - Lancer l'utilitaire de gestion des informations d'identification
Echo.
Echo          5 - Menu pr�c�dent
Echo.
Echo          6 - Quitter
Echo.
Choice /C 123456 /M "Entrez votre choix :"
If Errorlevel 6 Exit
If Errorlevel 5 Goto :Menu1
If Errorlevel 4 Goto :CredentialManager
If Errorlevel 3 Goto :CredentialVue
If Errorlevel 2 Goto :CredentialDel
If Errorlevel 1 Goto :CredentialAdd
Goto :Menu2

:Menu3
Cls
Color 0F
Echo                         ������������������������������ͻ
Echo                         �                              �
Echo                         �      AddUser2Shares v%version%     �
Echo                         �                              �
Echo                         ������������������������������ͼ
Echo.
Echo.
Echo.
Echo.
Echo.
Echo   Veuillez s�lectionner l'action � r�aliser :
Echo.
Echo          1 - Console de gestion des utilisateurs et groupes locaux
Echo.
Echo          2 - Console de gestion des dossiers partag�s
Echo.
Echo          3 - Connexions r�seau
Echo.
Echo          4 - Menu pr�c�dent
Echo.
Echo          5 - Quitter
Echo.
Choice /C 12345 /M "Entrez votre choix :"
If Errorlevel 5 Exit
If Errorlevel 4 Goto :Menu1
If Errorlevel 3 Start "ncpa.cpl" ncpa.cpl
If Errorlevel 2 Start "fsmgmt.msc" fsmgmt.msc
If Errorlevel 1 Start "lusrmgr.msc" lusrmgr.msc
Goto :Menu3


:CredentialVue
Cls
cmdkey.exe /list
Echo Appuyez sur une touche pour revenir au menu.
Pause>Nul
Goto :Menu2


:CredentialManager
Call control /name Microsoft.CredentialManager
Goto :Menu2


:CredentialAdd
Cls
If "%Server%"=="" Set Server=Serveur
Set /P Server=Veuillez indiquer le nom du serveur (Par d�faut : %Server%) :
Echo.
Echo     R�capitulatif des informations d'identifications
Echo.
Echo          Utilisateur    : %User%
Echo          Mot de passe   : %Pass%
Echo          Nom du Serveur : %Server%
Echo.
Echo Appuyez sur une touche pour confirmer l'ajout de ces informations.
Pause>Nul
cmdkey.exe /add:%Server% /user:%User% /pass:%Pass%
Echo.
Echo Op�ration termin�e.
Echo Appuyez sur une touche pour revenir au menu.
Pause>Nul
Goto Menu2


:CredentialDel
Cls
Echo.
Echo     Suppression des informations d'identifications pour
Echo.
Echo          Utilisateur    :
Echo          Mot de passe   :
Echo          Nom du Serveur : %Server%
Echo.
Echo Appuyez sur une touche pour confirmer la suppression.
Pause>Nul
cmdkey.exe /delete:%Server%
Echo.
Echo Op�ration termin�e.
Echo Appuyez sur une touche pour revenir au menu.
Pause>Nul
Goto Menu2


:AddUser
Cls
:: Test si le compte existe d�j�.
Net.exe User "%User%">Nul 2>Nul
If %errorlevel% EQU 0 (
	Call :InfoTitle
	Echo Le Compte "%User%" existe d�ja !
	Call :Pause
	Goto :Menu1
)

Echo.
Echo Appuyez sur une touche pour confirmer l'ajout de l'utilisateur :
Echo.
Echo                Utilisateur  : %User%
Echo                Mot de passe : %Pass%
Echo.
Echo Cet utilisateur sera rajouter sur ce PC et dans le groupe administrateur.
Echo.
Echo.
Echo                ������������������������������������������������ͻ
Echo                �                                                �
Echo                �   L'ajout de ce compte utilisateur n'est pas   �
Echo                �      indispenssable sur un poste station.      �
Echo                �                                                �
Echo                ������������������������������������������������ͼ
Call :Pause

:: Ajout du compte utilisateur - Pas d'expiration et ne peux pas changer le mot de passe.
Echo Ajout de l'utilisateur "%User%" :
Net.exe User "%User%" "%Pass%" /ADD /FULLNAME:"%FullName%" /EXPIRES:NEVER /PASSWORDCHG:NO
:: Ajout de l'utilisateur "%User%" dans le groupe Administrateur
Echo Ajout de l'utilisateur dans le groupe "Administrateur" :
Net.exe localgroup Administrateurs "%User%" /ADD
:: "%WINDIR%\System32\Net.exe" accounts /MAXPWAGE:UNLIMITED

:: D�sactivation de l'expiration du mot de passe.
Echo D�sactivation de l'expiration du mot de passe :
Wmic.exe UserAccount where Name='%User%' set PasswordExpires=False
Echo.

:: Cache le compte sur l'ouverture de session.
Echo Masque le compte utilisateur sur l'ouverture de session :
Reg.exe ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /V "%User%" /T REG_DWORD /D "0" /F
:: Commande pour afficher le compte.
:: Reg.exe DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /V "Administrateur" /F

:: Test si l'utilisateur � bien �t� cr��.
Net.exe User "%User%">Nul 2>Nul
If %errorlevel% NEQ 0 (
	Call :ErrorTitle
	Echo Compte "%User%" non cr�� !
	Echo.
	Echo V�rifiez que vous avez lanc� ce programme avec les droits
	Echo Administrateur, sinon veuillez cr�er le compte manuellement.
	Call :Pause
	Exit
)

Call :SuccessTitle
Echo L'utilisateur "%User%" a bien �t� ajout�.
Call :Pause
Goto :Menu1


:DelUser
Cls
:: Test si le compte existe.
Net.exe User "%User%">Nul 2>Nul
If %errorlevel% NEQ 0 (
	Call :InfoTitle
	Echo Le Compte "%User%" n'existe pas !
	Call :Pause
	Goto :Menu1
)

Echo.
Echo Appuyez sur une touche pour confirmer la suppression de l'utilisateur :
Echo.
Echo                Utilisateur  : %User%
Echo.
Echo.
Echo Ce compte utilisateur sera aussi supprim� de tous les partages du syst�me.
Call :Pause

:: Cette boucle permet de lister noms et chemins des partages au format csv et de filtrer ceux avec le "$"
For /f "Skip=2 Tokens=1,2,3 Delims=," %%a In ('wmic.exe share get name^,path /format:csv ^| findstr /i /l /v "$"') Do (
	If "%%a" NEQ "" Call :RemoveUserOnShare "%%b" "%%c"
)
Echo.

:: Suppression du compte utilisateur
Echo Suppression de l'utilisateur.
Net.exe User "%User%" /DELETE

:: Supprime la cl� de registre inutile.
Echo Suppression de la cl� "%User%" dans "SpecialAccounts"
Reg.exe DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /V "%User%" /F
Echo.

:: Pause de 3 secondes.
Ping -n 2 127.0.0.1>Nul

:: On v�rifie si le compte utilisateur a �t� supprim�.
Net.exe User "%User%">Nul 2>Nul
If %errorlevel% EQU 0 (
	Call :ErrorTitle
	Echo Compte "%User%" toujours existant !
	Echo.
	Echo. Veuillez supprimer le compte manuellement.
	Call :Pause
	Exit
)

Call :SuccessTitle
Echo L'utilisateur "%User%" a bien �t� supprim�.
Call :Pause
Goto :Menu1


:Add2Share
Cls
:: Test si le compte existe.
Net.exe User "%User%">Nul 2>Nul
If %errorlevel% NEQ 0 (
	Call :InfoTitle
	Echo Le Compte "%User%" n'existe pas !
	Call :Pause
	Goto :Menu1
)

:: Cette boucle permet de lister noms et chemins des partages au format csv et de filtrer ceux avec le "$"
For /f "Skip=2 Tokens=1,2,3 Delims=," %%a In ('wmic.exe share get name^,path /format:csv ^| findstr /i /l /v "$"') Do (
	If "%%a" NEQ "" Call :Add2Share "%%b" "%%c"
)

:: Si aucun partage trouv�
If %Count%==0 (
	Call :ErrorTitle
	Echo Aucun partage n'a �t� trouv� sur ce syst�me !
	Call :Pause
	Exit
)

Echo.&Echo.
Echo Ajout de l'utilisateur "%User%" sur le/les partages termin�.
Call :Pause
Goto :Menu1


:Add2Share
:: Compte le nombre de partage trouv�
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
Choice /C on /M "Ajouter l'utilisateur "%User%" au partage ci-dessus ? "
If ERRORLEVEL 2 Goto :Eof
If ERRORLEVEL 1 Goto :Add2ShareYes
Goto :YesOrNo


:Add2ShareYes
Echo.&Echo.
Echo Ajout de l'utilisateur "%User%" au partage "%ShareName%"
%SubinaclExe% /share "%ShareName%" /grant="%User%"=F

Echo.&Echo.
Echo Attribution des droits sur le chemin du partage :
Icacls.exe "%SharePath%" /Grant "%User%":(OI)(CI)F /C

Echo.&Echo.
Echo Test de l'attribution des droits :
Icacls.exe "%SharePath%"|Findstr "%User%"

Echo.&Echo.
If %ERRORLEVEL% EQU 0 (
	Color 0A
	Echo                  �������������������������������������������ͻ
	Echo                  �                                           �
	Echo                  �        Droits attribu�s avec succ�s       �
	Echo                  �                                           �
	Echo                  �������������������������������������������ͼ
) Else (
	Color 0C
	Echo                  �������������������������������������������ͻ
	Echo                  �                                           �
	Echo                  �     Echec de l'attribution des droits     �
	Echo                  �                                           �
	Echo                  �������������������������������������������ͼ
)
Goto :Eof


:RemoveUserOnShare
Echo Test si l'utilisateur "%User%" a des droits sur le partage %1
Icacls.exe "%SharePath%"|Findstr "%User%"
If %ERRORLEVEL% EQU 1 Goto :Eof

Cls
Echo Suppression des droits pour "%User%" sur le dossier %2 du partage %1 :
Echo.

Set SharePath=%~2
:: Astuce pour supprimer le backslash sur partage racine (x:\ => x:)
If "%SharePath:~-1,1%"=="\" Set SharePath=%SharePath:~0,-1%

Echo Suppression de l'utilisateur sur le partage :
%SubinaclExe% /share "%ShareName%" /revoke="%User%"
Echo.
Echo Suppression des droits de l'utilisateur sur le dossier :
Icacls.exe "%SharePath%" /remove "%User%" /T
Echo.
Goto :Eof


:Tests
:: Fonctions pour les tests divers avant ex�cution.
If Not Exist %SubinaclExe% (
	Call :ErrorTitle
	Echo Le programme Subinacl.exe n'a pas �t� trouv�.
	Echo Celui-ci est n�cessaire pour l'ajout aux partages.
	Call :Pause
	Exit
)
Goto :Eof


:SuccessTitle
	@Echo 
	Color 0A
	Echo.
	Echo.
	Echo                              ��������������������ͻ
	Echo                              �       SUCCES       �
	Echo                              ��������������������ͼ
	Echo.
	Echo.
	Echo.
Goto :Eof


:ErrorTitle
	@Echo 
	Color 0C
	Echo.
	Echo.
	Echo                              ��������������������ͻ
	Echo                              �       ERREUR       �
	Echo                              ��������������������ͼ
	Echo.
	Echo.
	Echo.
Goto :Eof


:InfoTitle
	@Echo 
	Color 0E
	Echo.
	Echo.
	Echo                              ���������������������ͻ
	Echo                              �     INFORMATION     �
	Echo                              ���������������������ͼ
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


:Eof