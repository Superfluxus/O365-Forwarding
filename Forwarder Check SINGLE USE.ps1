$credentials = Get-Credential
Write-Output "Retrieving CMDlets..."
    
$Session = New-PSSession -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
    -ConfigurationName Microsoft.Exchange -Credential $credentials `
    -Authentication Basic -AllowRedirection
Import-PSSession $Session
 
$mailboxes = Get-Mailbox -ResultSize Unlimited
$domains = Get-AcceptedDomain
  
foreach ($mailbox in $mailboxes) {
  
    $forwardingSMTPAddress = $null
    Write-Host "Checking forwarding for $($mailbox.displayname) - $($mailbox.primarysmtpaddress)"
    $forwardingSMTPAddress = $mailbox.forwardingsmtpaddress
    $externalRecipient = $null
    if ($forwardingSMTPAddress) {
        $email = ($forwardingSMTPAddress -split "SMTP:")[1]
        $domain = ($email -split "@")[1]
        if ($domains.DomainName -notcontains $domain) {
            $externalRecipient = $email
        }
  
        if ($externalRecipient) {
            Write-Host "$($mailbox.displayname) - $($mailbox.primarysmtpaddress) forwards to $externalRecipient" -ForegroundColor Yellow
  
            $forwardHash = $null
            $forwardHash = [ordered]@{
                PrimarySmtpAddress = $mailbox.PrimarySmtpAddress
                DisplayName        = $mailbox.DisplayName
                ExternalRecipient  = $externalRecipient
            }
           $ruleObject = New-Object PSObject -Property $forwardHash
           $ruleObject|Format-List
           $ruleObject | Out-File C:\temp\ExternalForward.txt -Encoding utf8 -Append
        }
    }
}
Remove-PSSession -id 1

### NEED TO WORK ON EXPORTING FILE