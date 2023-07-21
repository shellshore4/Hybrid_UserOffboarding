# Script de Désactivation d'Utilisateur Active Directory et Azure

Un script PowerShell destiné à désactiver des utilisateurs dans Active Directory et Azure AD, tout en réalisant diverses autres tâches associées.

## Description

Ce script est conçu pour être utilisé par un technicien. Il permet de désactiver un compte utilisateur dans Active Directory et Azure AD, de déplacer l'utilisateur vers un OU spécifique, de réinitialiser le mot de passe, de convertir la boîte aux lettres de l'utilisateur en boîte aux lettres partagée, de configurer une réponse automatique, de transférer les courriels à un autre utilisateur et de déléguer l'accès à la boîte aux lettres.

Le technicien devra entrer certaines informations et valider les réponses que le script fournira. C'est un travail en cours et il n'est pas parfait, mais j'espère qu'il sera utile à quelqu'un!

## Utilisation

Pour utiliser ce script, vous aurez besoin de PowerShell et de certains modules (ActiveDirectory, AzureAD et ExchangeOnlineManagement).

Vous devrez remplacer certains placeholders dans le script par vos informations spécifiques.

## Contributions

Contributions bienvenues! Si vous avez des suggestions pour améliorer ce script ou si vous voulez partager vos propres modifications, n'hésitez pas à le faire.

## Remarques

Soyez conscient que ce script est fourni tel quel, et je ne peux pas être tenu responsable des conséquences de son utilisation. Veuillez tester soigneusement ce script dans un environnement de test avant de l'utiliser dans un environnement de production.

Merci d'avoir pris le temps de consulter ce projet
