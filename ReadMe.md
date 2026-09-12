# AddUser2Shares.cmd

Version 1.6 du 07/09/2026 - Par Tlem33
https://github.com/Tlem33/AddUser2Shares

*****

## DESCRIPTION :

AddUser2Shares.cmd est un utilitaire qui permet :

          - L'ajout et la suppression d'un compte utilisateur avec mot de passe.
          - D'ajouter le compte utilisateur dans le groupe Administrateurs (full accès aux partages existants).
          - L'ajout des droits nécessaires aux différents partages disponibles (pour utilisateur non admin).
          - L'ajout des informations d'identifications (credentials) pour un poste client.
          - Afficher/masquer le compte sur l'écran d'ouverture de session.
          - Lancer divers outils Windows concernant les comptes utilisateurs,
            les partages et les paramètres réseau


## UTILISATION :

Avant d'utiliser AddUser2Shares.cmd, vous pouvez éditer et modifier dans la
section "CONFIGURATION UTILISATEUR" les paramètres de configuration ci-dessous :

          User=Nom_Utilisateur               ; Nom de l'utilisateur.
          Passwd=Mot_De_Passe                ; Mot de passe de l'utilisateur
          FullName=Nom_Complet_Utilisateur   ; Nom complet de l'utilisateur
          Server=Nom_PC_Distant              ; Nom du PC distant pour les partages (il sera demandé avant validation)

Lancez AddUser2Shares, puis choisissez l'action à réaliser.

***

## SYSTEME(S) :

Testé sous :

            - Windows 8
            - Windows 10
            - Windows 11

***

## LICENCE :

Licence [MIT](https://fr.wikipedia.org/wiki/Licence_MIT)

Copyright (c) 2026 Tlem33

L'autorisation est accordée, à titre gratuit, à toute personne obtenant une copie
de ce logiciel et des fichiers de documentation associés (le « Logiciel »), de traiter
le Logiciel sans restriction, y compris, sans limitation, les droits
d'utiliser, de copier, de modifier, de fusionner, de publier, de distribuer, de sous-licencier
et/ou de vendre des copies du Logiciel, et de permettre aux personnes auxquelles le
Logiciel est fourni de le faire, sous réserve des conditions suivantes :

L'avis de copyright ci-dessus et cet avis d'autorisation doivent être inclus dans toutes
les copies ou sections substantielles du Logiciel.

LE LOGICIEL EST FOURNI « EN L'ÉTAT », SANS GARANTIE D'AUCUNE SORTE, EXPRESSE OU
IMPLICITE, Y COMPRIS MAIS SANS S'Y LIMITER, LES GARANTIES DE QUALITÉ MARCHANDE,
D'ADÉQUATION À UN USAGE PARTICULIER ET DE NON-CONTREFAÇON. EN AUCUN CAS LES
AUTEURS OU TITULAIRES DES DROITS D'AUTEUR NE POURRONT ÊTRE TENUS POUR RESPONSABLES D'UNE
RÉCLAMATION, DOMMAGES OU AUTRE RESPONSABILITÉ, QUE CE SOIT DANS LE CADRE D'UN CONTRAT,
D'UN DÉLIT OU AUTREMENT, DÉCOULANT DE, EN RELATION AVEC LE LOGICIEL OU L'UTILISATION
OU AUTRES DISPOSITIONS DU LOGICIEL.

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

21/01/2021 - Version 1.5

		- Modification de l'entête de AddUser2Shares.cmd
		- Suppression de variables inutiles
        - Remplacement de la commande Set /P par Choice
        - Ajout de l'extension des programmes (.exe) et modifications mineures

07/09/2026 - Version 1.6

		- Ajout de l'indication du menu (Principal, Crédentials, Outils)
		- Ajout systématique de l'utilisateur dans le groupe "Utilisateurs"
		- Ajout de la gestion du groupe Administrateurs par le SID (Multilingue)
		- Ajout de la demande du nom de l'utilisateur en début de script si non renseigné
		- Si non renseigné, demande du nom utilisateur, du mot de passe et du nom du serveur
		- Ajout du contrôle de l'appartenance du groupe de l'utilisateur avec l'ajout aux partages
		- Modification de l'écriture de certaines partie du code pour le rendre plus robuste
		- Ajout du contrôle de la saisie et longueur du mot de passe (8 caractères minimum)
        - Utilisation de commandes Powershell au lieu de subinacl.exe et Icalcs.exe
		- Ajout de la définition de la taille de la fenêtre principale
		- Correction sur l'affichage du titre de la fenêtre
		- Correction titre et gestion des menus
