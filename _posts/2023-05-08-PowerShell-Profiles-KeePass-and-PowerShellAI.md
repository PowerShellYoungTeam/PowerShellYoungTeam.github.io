![Screenshot]( /assets/images/Hill_Night.png)

# PowerShell Profiles, KeePass and PowerShell AI (ChatGPT/OpenAI)

I was asked over the weekend on Twitter if I could share how I setup my PowerShell profile to pull my OpenAI API key from a KeePass vault so you can start using the PowerShell AI module straight away!

Apologies if this comes across as a notes dump or a user guide written by your IT department, cos that what is basically is!! :)

> Right first things first! Let's download the modules we need!
> 
> - Doug Finke's **PowerShellAI** - <https://github.com/dfinke/PowerShellAI>
> 
> - Justin Grote's **SecretManagement.Keepass** - <https://github.com/JustinGrote/SecretManagement.KeePass>

## SecretManagement.Keepass

So I already had KeePass, if you don't then Grab and install KeePass from here <https://keepass.info> (It's open source so it's buckshee !!)

Install KeePass and create a Vault with master password or Keyfile (or both)

You will also need to get your OpenAI API key from <https://beta.openai.com/account/api-keys> and store it your vault 

**NOTE:** I found it best just to put your secrets that you want to retrieve via PowerShell in the root of the Vault, hit problems with I put them in a subfolder, so best as per below screenshot.

![VaultPicRoot]( /assets/images/VaultPicRoot.jpg)

To install the SecretManagement.Keepass module just download from the PowerShell gallery. 

```powershell
Install-Module -Name SecretManagement.KeePass
```

Import the module (Import-module SecretManagement.KeePass) and then you need to register the vault so the module knows where and how to access it (below is for a master password only vault, there is a -keyfile argument you can use for keyfiles)

```powershell
Register-KeepassSecretVault -Path <Path to Keepass Vault> -UseMasterPassword
```

![registerVault]( /assets/images/registervault.jpg)

You can use Test-SecretVault to check if it worked (will return Boolean) like below

```powershell
Test-SecretVault -Name <Name of vault>
```

![TestSecVault]( /assets/images/Testsecvault.jpg)

## PowerShellAI

Now we need to install and import PowerShellAI module

```powershell
Install-Module -Name PowerShellAI 
Import-Module -Name PowerShellAI
```

So now we need to get the API key from the vault and use it for PowerShellAI's Set-OpenAIKey cmdlet, after that you (Hopefully) should be cooking with gas!!

So for me, I just add this into my profile and when I start a session, I just enter my KeePass Vault password and I am ready to rock and roll!

(don't need the test-SecretVault, I have left it in there tho..)

```powershell
import-module PowerShellAI
Import-Module SecretManagement.KeePass


test-SecretVault -Name PowerShell
$CHatGPTAPIKEY = Get-Secret -Vault PowerShell -Name ChatGPTAPIKEY
set-OpenAIKey $CHatGPTAPIKEY
Get-GPT3Completion 'Get me a random quote'
```

![ProfileWorking]( /assets/images/ProfileWorking.jpg)
