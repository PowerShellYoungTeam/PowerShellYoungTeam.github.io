![Screenshot]( /assets/images/flats2.png)

# PowerShell Profiles, KeePass and PSBlueSky

Was listening to the PowerShell Podcast and heard about a few peps had moved over to BlueSky, also about Jeff Hick's module to interact with it.

Had a wee recce, in the github repo's README, it is suggested:

> For automation purposes, you can use the Secrets management module to store your credential. Write your own code to retrieve the credential and pass it to the module commands.

hmm... my wee bit in my profile for getting my OpenAI key should work for this!

what we need:

> - Jeff Hick's **PSBlueSky** - <https://github.com/jdhitsolutions/PSBluesky>
> 
> - Justin Grote's **SecretManagement.Keepass** - <https://github.com/JustinGrote/SecretManagement.KeePass>

## SecretManagement.Keepass

So I already had KeePass, if you don't then Grab and install KeePass from here <https://keepass.info> (It's open source so it's buckshee !!)

Install KeePass and create a Vault with master password or Keyfile (or both)

You will also create a BlueSky account from <https://bsky.app/> and store the username and password in the vault 

**NOTE:** Username is case sensitive too!, also don't be like me and put the @ sign before the username, so like **PoshYoungTeam.bsky.social**, NOT **@PoshYoungTeam.bsky.social**

**ALSO:** I found it best just to put your secrets that you want to retrieve via PowerShell in the root of the Vault, hit problems with I put them in a sub group, so best as per below screenshot.

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

## PSBlueSky

Now we need to install and import PSBlueSky module

```powershell
Install-Module -Name PSBlueSky 
Import-Module -Name PSBlueSky
```

So now we need to get the BlueSky Credentials from the vault and use it for PSBlueSky's **Start-BSkySession** cmdlet, after that you (Hopefully) should be skeeting in no time!!

So let's grab the cred's and start a session

```powershell
$BskyCreds = Get-Secret -Vault PowerShell -Name BlueSky
Start-BSkySession -Credential $BskyCreds
```

![BskySession]( /assets/images/BskySession.jpg)

and use **New-BskyPost** to send a Skeet from the CLI...

![Skeet]( /assets/images/Skeet.JPG)

Bar the usual get-help and readme on the GitHub repo, also has this more informative version of get-command -module PSblueSky: **Get-BskyModuleInfo**, which I think is pure dead brilliant!

![Bskymoduleinfo]( /assets/images/Bskymoduleinfo.jpg)

So for me, I just add this into my profile and when I start a session, I just enter my KeePass Vault password and I am ready to rock and roll!

I have set it up so it also display's my Skeets from my feed so I can see how they are doing!

(don't need the test-SecretVault, I have left it in there tho..)

```powershell
import-module PSBlueSky 
Import-Module SecretManagement.KeePass

test-SecretVault -Name PowerShell
$BskyCreds = Get-Secret -Vault PowerShell -Name BlueSky
Start-BSkySession -Credential $BskyCreds
$BskyFeeds = Get-BskyFeed 
$BskyFeeds | Where-Object { $_.Author -eq $BskyCreds.username }
```

![ProfileWorking]( /assets/images/ProfileBskyFeed.jpg)

Hope this helps :)
