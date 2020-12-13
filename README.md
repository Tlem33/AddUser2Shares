# AddUser2Shares.cmd

Version 1.4 du 13/12/2020 - Par Tlem33
https://github.com/Tlem33/AddUser2Shares

***

## DESCRIPTION :

AddUser2Shares.cmd est un utilitaire qui permet :

          - L'ajout d'un utilisateur administrateur avec mot de passe
          - L'ajout des droits nécessaires aux différents partages disponiblent.
          - L'ajout des informations d'identifications (credentials) pour un poste client.

AddUser2Shares nécessite l'utilisation de l'utilitaire Microsoft ["subinacl.exe"](https://www.microsoft.com/en-us/download/confirmation.aspx?id=23510) à placer dans le sous dossier \bin

          +---AddUser2Shares
              AddUser2Shares.cmd
              LisezMoi.md
              README.md
              +---bin
                  subinacl.exe

## UTILISATION :

Avant d'utiliser AddUser2Shares.cmd, vous pouvez éditer et modifier les paramètres de configuration ci-dessous :

		User=AdminHSF                 ; Nom de l'utilisateur.
		Passwd=HenrySchein37          ; Mot de passe de l'utilisateur
		FullName=Administrateur HSF   ; Nom complet de l'utilisateur
		Server=Serveur                ; Nom du serveur (il sera demandé avant validation)

Lancez le AddUser2Shares, puis choisissez l'action à réaliser.

***

## SYSTEME(S) :

Testé sous :

            - Windows 7
            - Windows 8
            - Windows 10

***

## LICENCE :

Licence [MIT](https://fr.wikipedia.org/wiki/Licence_MIT)

Droit d'auteur (c) 2020 Tlem33

Une autorisation est accordée, gratuitement, à toute personne obtenant une copie de ce logiciel
et des fichiers de documentation associés (le «logiciel»), afin de traiter le logiciel sans restriction,
y compris et sans s’y limiter, les droits d’utilisation, de copie, de modification, de fusion, publiez,
distribuez, sous-licence et/ou vendez des copies du logiciel, et pour permettre aux personnes
auxquelles le logiciel est fourni, selon les conditions suivantes:

La notification du droit d’auteur ci-dessus et cette notification de permission doivent être incluses
dans toutes les copies ou portions substantielles du Logiciel.

LE LOGICIEL EST FOURNI « EN L’ÉTAT » SANS GARANTIE OU CONDITION D’AUCUNE SORTE, EXPLICITE OU IMPLICITE
NOTAMMENT, MAIS SANS S’Y LIMITER LES GARANTIES OU CONDITIONS RELATIVES À SA QUALITÉ MARCHANDE,
SON ADÉQUATION À UN BUT PARTICULIER OU AU RESPECT DES DROITS DE PARTIES TIERCES. EN AUCUN CAS LES
AUTEURS OU LES TITULAIRES DES DROITS DE COPYRIGHT NE SAURAIENT ÊTRE TENUS RESPONSABLES POUR TOUT
DÉFAUT, DEMANDE OU DOMMAGE, Y COMPRIS DANS LE CADRE D’UN CONTRAT OU NON, OU EN LIEN DIRECT OU
INDIRECT AVEC L’UTILISATION DE CE LOGICIEL.

---

## HISTORIQUE :

01/06/2018 - Version 1.0

		- Première version.


17/08/2018 - Version 1.1

		- Correction sur la suppression du compte sur le partage.
		- Ajout des messages d'information sur les commandes.
		- Suppression du format de fenêtre définit.

02/09/2018 - Version 1.2

		- Ajout du fichier LisezMoi.txt.
		- Ajout du numéro de version + affichage de la version dans le titre.

15/03/2020 - Version 1.3

		- Remplacement de la fonction de demande d'élévation des droits.
		- Ajout d'un menu pour la gestion des informations d'identification (pour le poste client).
		- Ajout du nom et version du batch dans le titre de la fenêtre.

13/12/2020 - Version 1.4

		- Ajout du fichier README.MD
		- LisezMoi.txt devient LisezMoi.md
		- Déplacement du binaire dans le sous dossier \bin

