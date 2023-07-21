Import-Module ActiveDirectory
Import-Module AzureAD
Import-Module ExchangeOnlineManagement

function Generate-Password {
    param (
        [Parameter(Mandatory=$true)]
        [int]$length
    )

    $chars = 'METTEZ_VOS_CARACTÈRES_ICI'
    $password = ''
    for ($i = 0; $i -lt $length; $i++) {
        $password += $chars[(Get-Random -Maximum $chars.length)]
    }

    return $password
}

function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$username,

        [Parameter(Mandatory=$true)]
        [string]$disabler
    )

    $webhookUrl = "VOTRE_URL_WEBHOOK"
    $logEntry = "{0} - L'utilisateur '{1}' a été désactivé par '{2}'" -f (Get-Date), $username, $disabler

    $body = ConvertTo-Json @{
        text = $logEntry
    }

    $params = @{
        ContentType = "application/json"
        Method = "POST"
        Body = $body
        URI = $webhookUrl
    }

    Invoke-RestMethod @params
}

do {
    $username = Read-Host -Prompt "Entrer le nom en format sAMAccountName de l'utilisateur qui sera désactivé"
    $user = Get-ADUser -Identity $username -Properties GivenName, Surname, Department, UserPrincipalName
    $username_online = $user.UserPrincipalName

    if ($user -eq $null) {
        Write-Error "L'utilisateur $username n'a pas été trouvé."
    } else {
        Write-Host "`nCET UTILISATEUR SERA DÉSACTIVÉ" -ForegroundColor Yellow
        Write-Host "Prénom: $($user.GivenName)"
        Write-Host "Nom: $($user.Surname)"
        Write-Host "Départment: $($user.Department)"
        Write-Host "Courriel: $($user.UserPrincipalName)"
        $confirmation = Read-Host -Prompt "`nEst-ce que ces informations sont correctes? (oui/non)"
    }
} until ($confirmation -eq "oui")

do {
    $managerSAM = Read-Host -Prompt "Qui sera la personne ajouté dans le message automatique de départ en format sAMAccountName?"
    $manager = Get-ADUser -Identity $managerSAM -Properties GivenName, Surname, mail, TelephoneNumber

    if ($manager -eq $null) {
        Write-Error "La personne pour les redirections de courriels $managerSAM n'a pas été trouvé."
    } else {
        $managerName = "$($manager.GivenName) $($manager.Surname)"
        $managerEmail = $manager.mail
        $managerPhone = $manager.TelephoneNumber

        Write-Host "`nCETTE PERSONNE RECEVRA LES COURRIELS EN DÉLÉGATION ET SERA AJOUTÉ DANS LE MESSAGE D'ABSENCE" -ForegroundColor Green
        Write-Host "Nom: $managerName"
        Write-Host "Email: $managerEmail"
        Write-Host "Téléphone: $managerPhone"
        $managerInfoConfirm = Read-Host -Prompt "`nEst-ce que ces informations sont correctes? (oui/non)"
    }
} until ($managerInfoConfirm -eq "oui")

do {
    $forwardEmailSAM = Read-Host -Prompt "À qui les courriels de l'utilisateur désactivé doivent-ils être transférés? (laissez ce champ vide s'il n'y a pas de transfert d'email)"
    if ($forwardEmailSAM -ne '') {
        $forwardEmailUser = Get-ADUser -Identity $forwardEmailSAM -Properties GivenName, Surname, mail
        if ($forwardEmailUser -eq $null) {
            Write-Error "La personne à qui les courriels seront transférés $forwardEmailSAM n'a pas été trouvé."
        } else {
            $forwardEmail = $forwardEmailUser.mail
            Write-Host "`nLES COURRIELS DE L'UTILISATEUR SERONT TRANSFÉRÉS À CETTE ADRESSE" -ForegroundColor Cyan
            Write-Host "Courriel: $forwardEmail"
            $forwardEmailConfirm = Read-Host -Prompt "`nEst-ce que ces informations sont correctes? (oui/non)"
        }
    } else {
        $forwardEmailConfirm = "oui"
    }

    $delegateSAMs = Read-Host -Prompt "À qui la boîte aux lettres partagée doit-elle être déléguée? (laissez ce champ vide si aucune délégation n'est nécessaire, pour plusieurs utilisateurs, séparez les noms d'utilisateur par des virgules, par exemple: jsmith,jdoe)"
    $delegateSAMs = $delegateSAMs.Split(',')
    $delegationInfoConfirm = $null
    $delegateList = @()

    if ($delegateSAMs[0] -ne '') {
        foreach ($delegateSAM in $delegateSAMs) {
            $delegateUser = Get-ADUser -Identity $delegateSAM.Trim() -Properties GivenName, Surname, mail
            if ($delegateUser -eq $null) {
                Write-Error "La personne à qui la boîte aux lettres partagée sera déléguée $delegateSAM n'a pas été trouvé."
                continue
            } else {
                $delegateEmail = $delegateUser.mail
                $delegateList += $delegateEmail
            }
        }
        Write-Host "`nLES BOÎTES AUX LETTRES PARTAGÉES SERONT DÉLÉGUÉES AUX UTILISATEURS SUIVANTS" -ForegroundColor Magenta
        Write-Host "Courriels: $($delegateList -join ', ')"
        $delegationInfoConfirm = Read-Host -Prompt "`nEst-ce que ces informations sont correctes? (oui/non)"
    } else {
        $delegationInfoConfirm = "oui"
    }
} until (($forwardEmailConfirm -eq "oui") -and ($delegationInfoConfirm -eq "oui"))

if ($confirmation -eq "oui") {
    Disable-ADAccount -Identity $username
    Write-Log -username $username -disabler $env:USERNAME

    $groups = Get-ADUser -Identity $username -Properties MemberOf | Select-Object -ExpandProperty MemberOf

    foreach ($group in $groups) {
        Remove-ADGroupMember -Identity $group -Members $username -Confirm:$false
    }

} else {
    exit
}

$UPNSuffix = $user.UserPrincipalName.Split('@')[1]
switch ($UPNSuffix) {
    "compagnie1" {
        $targetOU = "OU=UNITE_ORGANISATIONNELLE_CIBLE,DC=DOMAINE_CIBLE"
        $company = "NOM_DE_LA_COMPAGNIE"
        Move-ADObject -Identity $user.DistinguishedName -TargetPath $targetOU
    }
    "compagnie2" {
        $targetOU = "OU=UNITE_ORGANISATIONNELLE_CIBLE,DC=DOMAINE_CIBLE"
        $company = "NOM_DE_LA_COMPAGNIE"
        Move-ADObject -Identity $user.DistinguishedName -TargetPath $targetOU
    }
    "compagnie3" {
        $targetOU = "OU=UNITE_ORGANISATIONNELLE_CIBLE,DC=DOMAINE_CIBLE"
        $company = "NOM_DE_LA_COMPAGNIE"
        Move-ADObject -Identity $user.DistinguishedName -TargetPath $targetOU
    }
    default {
        Write-Warning "Suffixe invalide: $UPNSuffix"
    }
}

$newPassword = ConvertTo-SecureString -AsPlainText (Generate-Password 25) -Force
Set-ADAccountPassword -Reset -NewPassword $newPassword -Identity $username

Connect-AzureAD

$azureUser = Get-AzureADUser -ObjectId $username_online

if ($azureUser -eq $null) {
    Write-Error "$username n'a pas été trouvé dans AAD."
    exit
}

Connect-ExchangeOnline

Set-Mailbox $username_online -Type Shared

for ($i = 0; $i -lt 26; $i++) {
    $mailbox = Get-Mailbox -Identity $username_online
    if ($mailbox.RecipientTypeDetails -eq "SharedMailbox") {
        Write-Host "La boite courriel de $username a été convertie en boîte partagée."
        break
    } else {
        Write-Host "En attente de la transformation de la boîte courriel de $username en boîte partagée..."
        Start-Sleep -Seconds 7
    }
}

if ($mailbox.RecipientTypeDetails -ne "SharedMailbox") {
    Write-Error "Échec de la transformation de la boîte de $username en boîte partagée."
    exit
}

$message = "Bonjour,

Veuillez prendre note que je ne travaille plus pour $company.

SVP communiquer avec $managerName au besoin à l’adresse courriel : $managerEmail ou par téléphone au $managerPhone.

Merci!"

Set-MailboxAutoReplyConfiguration -Identity $username_online -AutoReplyState Enabled -InternalMessage $message -ExternalMessage $message -ExternalAudience All

for ($i = 0; $i -lt 24; $i++) {

    $autoReplyConfig = Get-MailboxAutoReplyConfiguration -Identity $username_online

    if ($autoReplyConfig.AutoReplyState -eq "Enabled") {
        break
    } else {

        Start-Sleep -Seconds 5
    }
}

if ($autoReplyConfig.AutoReplyState -ne "Enabled") {
    Write-Warning "Échec de l'ajout du message automatisé!"
} else {

    if ($autoReplyConfig.ExternalAudience -ne "All") {
        Write-Warning "Échec de l'activation des réponses automatiques pour les utilisateurs externes!"
    } else {
        Write-Host "Réponse automatique ajoutée avec succès!"
    }
}

if ($forwardEmailSAM -ne '') {
    $forwardEmailUser = Get-ADUser -Identity $forwardEmailSAM -Properties UserPrincipalName
    $forwardEmailInternal = $forwardEmailUser.UserPrincipalName
    Set-Mailbox -Identity $username_online -ForwardingAddress $forwardEmailInternal -DeliverToMailboxAndForward $false
}

if ($delegateSAMs[0] -ne '') {
    foreach ($delegateSAM in $delegateSAMs) {
        $delegateUser = Get-ADUser -Identity $delegateSAM.Trim() -Properties UserPrincipalName
        $delegateEmail = $delegateUser.UserPrincipalName
        Add-MailboxPermission -Identity $username_online -User $delegateEmail -AccessRights FullAccess -InheritanceType All -Confirm:$false
    }
}

$azureUser = Get-AzureADUser -ObjectId $username_online | Select-Object -Property *

if ($azureUser.AssignedLicenses) {
    $licensesToRemove = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses

    foreach ($license in $azureUser.AssignedLicenses) {
        $licensesToRemove.RemoveLicenses += $license.SkuId
    }

    Set-AzureADUserLicense -ObjectId $username_online -AssignedLicenses $licensesToRemove -InformationAction SilentlyContinue
}

Disconnect-AzureAD -Confirm:$false
Disconnect-ExchangeOnline -Confirm:$false
