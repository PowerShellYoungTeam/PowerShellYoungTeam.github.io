![Screenshot]( /assets/images/Hill_Night.png)

# Using PSBlueSky and Fun with Facets

following on from </_posts/2024-11-22-PowerShell-Profiles-KeePass-and-PSBlueSky>

## Help!

PSBlueSky has some Gucci built in help! check out these Cmdlets as well as Github help and built in Help (get-Help)

'''powershell
Open-BskyHelp # which will open a PDF version of this document in your default PDF viewer

Get-BskyModuleInfo # which will show you the module commands and has clickable links to online help(module's github page)
'''

## Start a session

you need to use the creds in your vault!

you can create a session, and if you get a timeout error, you can refresh the session.

'''powershell
Start-BskySession -credential $cred

Get-BskySession # confirm that you are connected to the session

Get-BSkySession | Update-BskySession # to update the session
'''

## Profile

so I have added a few lines into my Profile so I get prompted for my vault password, and a BlueSky session gets started etc.. (can even retrieve stuff like notifications or feed etc...)

'''powershell
import-module PSBlueSky
Import-Module SecretManagement.KeePass

$BskyCreds = Get-Secret -Vault PowerShell -Name BlueSky

Start-BSkySession -Credential $BskyCreds
Get-BskyNotification | Where-Object { $_.Date -gt (Get-Date).AddDays(-1) } | Sort-Object Date
'''

## Sending your first Skeet

very easy, and as alwys with powershell, more than one way!

'''powershell
# Posting! this was my 2nd post..

New-BskyPost -message "It works!! :)" -imagepath C:\users\Wighty\Pictures\BskyPic.PNG -ImageAlt "pic of my first PSBlueSky post" -Verbose -WhatIf

# pass as an object

$param = @{
    Message = "It works!! :)"
    ImagePath = "C:\users\Wighty\Pictures\BskyPic.PNG "
    ImageAlt = "pic of my first PSBlueSky post"
    Verbose = $true
}

New-BskyPost @param -WhatIf

# with a URL, make sure URL is surrounded by Whitespace

New-BskyPost "Cool #PowerShell tip popped up in my terminal today from Daniel Schroeder ( @deadlydog.bsky.social ). In short, watch this Github repo to stay up to date with known PwSh security vulnerabilities and breaking changes:   [PowerShell Annoucements] (https://github.com/PowerShell/Announcements) " -Verbose

# multiline post, save text as string and pass to New-BskyPost

$multiline = @"
I'm really enjoying the #PSBlueSky module. It's a great way to post to Bluesky from #PowerShell. I can't wait to see what other features are added in the future.

#PowerShell
#PSBlueSky
"@

New-BskyPost $multiline -Verbose -WhatIf
'''

## Feeds, Timelines, Notifications and reposts

fairly straightforward, although you may want to filter somehow (if you don't want to fill you terminal)

'''powershell
# Feeds, Timelines Notifications and reposts

Get-BskyFeed -Verbose # get your feed (good to filter down by date or limit)

#jeff hicks tip for tips!!

Get-BskyFeed -UserName steviecoaster.dev | Where-Object text -match 'Pwsh Tip of the day' -ov w | Sort-Object -Property Date -Descending | Format-List -Property text -GroupBy date

Get-BskyFeed | Where-Object { $_.Text -match "PowerShell|Pwsh"  } # filter by atext, keywords

Get-BskyFeed | where-object { $_.Author -eq $BskyCreds.Username} | Sort-Object Liked # get my most liked skeets

Get-BskyTimeline -Verbose # get your timeline (good to filter down by time or limit)

#get timeline and filter by skeets containing the word "PowerShell" or "Pwsh" or by date
Get-BskyTimeline | Where-Object { $_.Text -match "PowerShell|Pwsh" } # filter by text
Get-BskyTimeline | Where-Object { $_.Date -gt (Get-Date).AddDays(-1) } # filter by date (yesterday)

Get-BskyNotification -Verbose # get your notifications with clickable links to the post

# filter by date (yesterday)
Get-BskyNotification | Where-Object { $_.Date -gt (Get-Date).AddDays(-1) } # filter by date (yesterday)

# reposting, need non -default properties URI and CID

Get-BskyTimeline | Where-Object { $_.Text -match "PowerShell|Pwsh" } | Select-Object Author,Date,Text,URI, CID | Publish-BskyPost -whatif

# countdown to PowerShell Wednesday
# Calculate time until 1900 GMT and create a requote (from Copilot)
$timeToGo = [math]::Ceiling(((Get-Date "19:00:00Z").ToUniversalTime() - (Get-Date).ToUniversalTime()).TotalMinutes)
Get-BskyFeed | Where-Object { $_.Text -match "#PowerShellWednesday"  }   | Select-Object -First 1 | Select-Object Author,Date,Text,URI,CID | Publish-BskyPost -Quote "only $timeToGo minutes until #PowerShellWednesday" -WhatIf

# reposting, need non -default properties URI and CID
Get-BskyFeed | Where-Object { $_.Text -match "#PowerShellWednesday"  }   |  Select-Object -First 1 | Select-Object Author,Date,Text,URI,CID | Publish-BskyPost -Quote "Live reposting during a demo, what can go wrong" -WhatIf
'''

## Users

How to interact with user via PSBlueSKy (also keep an eye on your follower count)

'''PowerShell
# User Stuff

Find-BskyUser -UserName "jsnover.com"  # find anyone with PowerShell in their username and Description

Find-BskyUser -UserName "powershell" | Select-Object username # use this to get a list of usernames for demo purposes :)

Get-BskyProfile # Get your profile/bio or pass another users username

Get-BskyFollowers # get your followers

# see how big the Young Team is

$YoungTeamers = Get-BskyFollowers
Write-Output "You have $($YoungTeamers.Count) muckers in the Young Team"

# let's make a list of the Young Team
Write-Output "The PowerShell Young Team:"; $YoungTeamers | Select-Object username | Sort-Object username | Format-Table -AutoSize

#Let's visit the Young Team

#get the path to my MSedge.exe
$EdgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$YoungTeamers | ForEach-Object { Start-Process $EdgePath $_.URL }

Get-BskyFollowing # get who you are following , could be useful for a follow list

# see who you are following
Get-BskyFollowing | Select-Object username | Sort-Object username | Format-Table -AutoSize

# Following, Unfollowing and blocking badies!

New-BskyFollow "PoshYoungTeam.bsky.social" -WhatIf

#or get pipy with it

Get-BskyProfile "PoshYoungTeam.bsky.social"  | New-BskyFollow -passthru -whatif

#remove people from your follow list

Remove-BskyFollow "PoshYoungTeam.bsky.social" -WhatIf

#or get pipy with it

Get-BskyProfile "PoshYoungTeam.bsky.social" | Remove-BskyFollow -passthru -WhatIf

#blocking

Get-BskyBlockedUser # get who you have blocked

Block-BskyUser -UserName "baduser" -WhatIf

Unblock-BskyUser -UserName "baduser" -WhatIf
'''
## Resources

• GitHub - PSBlueSky - https://github.com/jdhitsolutions/PSBluesky
Bluesky API Documentation - [HTTP Reference | Bluesky  ](https://docs.bsky.app/docs/category/http-reference)

https://github.com/jdhitsolutions/PSBluesky/discussions - checking this out for other uses!!!

https://github.com/jdhitsolutions/PSBluesky/discussions/35 - mdgrs - taskbar notifications!!!

https://github.com/jdhitsolutions/PSBluesky/discussions/28 - tip of the day

I've shared the ways I'm using the PSBlueSky #PowerShell module in the repo's Discussion section. How are you using
the module? jeffhicks bluesky https://bsky.app/profile/did:plc:ohgsqpfsbocaaxusxqlgfvd7/post/3li3j3yqxbh23

and see what people say here:

Jeff Brown Tech @jeffbrowntech.bsky.social

Using it in Azure Functions to call it from a Logic App for posting new blogs and videos to social.

## Fun With Facets

how it started... https://bsky.app/profile/did:plc:k54achhksfhvlp5jd3rzv32h/post/3lj45s5ctjt22

https://bsky.app/profile/blowdart.me/post/3lj4lgcug2g22 - shots fired

https://bsky.app/profile/blowdart.me/post/3lj4ln6er5c2l - cool site to see message json - by @natalie.sh https://atp.tools/at:/did:plc:hfgp6pj3akhqxntgqwramlbg/app.bsky.feed.post/3lj4lgcug2g22

https://github.com/jdhitsolutions/PSBluesky/blob/main/functions/New-PSBlueSkyPost.ps1 - picked througfh this and found _newFacetLink in helpers

https://github.com/jdhitsolutions/PSBluesky/blob/main/functions/helpers.ps1

pulled into funkyFacets and removed ref to custom _verbose function

found this very helpful too - https://docs.bsky.app/blog/create-post

this was cool in helping me figure out JSON too: https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/richtext/facet.json

https://docs.bsky.app/docs/advanced-guides/post-richtext - this for the facet bit, but piggy backing of psbluesky was easier!

Barry let me know about hashtags

https://bsky.app/profile/blowdart.me/post/3lj4mo6cyas2l

me going back to basics and sending a post via invoke-restmethod https://bsky.app/profile/did:plc:k54achhksfhvlp5jd3rzv32h/post/3lj4rdci6mv2r

https://bsky.app/profile/blowdart.me/post/3lj6s5brnw22i - got it working :) for mentions

got it working for hashtags -https://bsky.app/profile/did:plc:k54achhksfhvlp5jd3rzv32h/post/3lj6ticjmk62j