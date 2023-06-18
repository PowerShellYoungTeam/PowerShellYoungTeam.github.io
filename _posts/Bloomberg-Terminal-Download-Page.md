![Screenshot]( /assets/images/redroad2.jpg)

# Webscraping Bloomberg Terminal Download Page for New Releases

> NB - this only works in Windows Powershell at the moment, in Core it throws the below error with the .ParsedHtml.getElementsByTagName and still to get to the bottom of that!

![pwsh7error]( /assets/images/BloomyCorePoshFail.jpg)

Working for an Investment Bank, one of my jobs is updating the version of Bloomberg Terminal in Config Manager and making sure our DR machines that have it update (normally they auto-update but it requires a login which I am not doing each month on most of the DR estate)

I used to check the Bloomberg download page each day of the month until the new update came out, but after the one man module making machine Adam Bacon (psDevUK) - <https://github.com/psDevUK> kindly wrote me a script that would scrape data off a webpage for another thing I asked about, I had an idea.

So using his code and a lot of playing about with regex to pull out the Month of the release from the bloomberg software update download page <https://www.bloomberg.com/professional/support/software-updates/> (I wish I did this write up sooner so I could better explain the regex bit, but it basically looks for the table row with Bloomberg Terminal - New/Upgrade Installation and then pulls out the Month text )

![BloomyDownload]( /assets/images/BloombergUpdatepage.jpg)

Here is the function below, you can also grab it from <https://github.com/PowerShellYoungTeam/Trading-Apps>

```powershell
function Get-BloombergRelease{
	<#
	.SYNOPSIS
	Function to check for new releases of Bloomberg Terminal
	by Steven Wight
	.DESCRIPTION
	Get-BloombergRelease <URL> (default https://www.bloomberg.com/professional/support/software-updates/)
	.EXAMPLE
	Get-BloombergRelease
	.Notes
	You can change and even pipe the URL, but unless Bloomberg change the URL, it's pretty pointless to be fair, more of a personal exercise me doing it. NB currently only works with Windows PowerShell
	#>

	[CmdletBinding()]
	Param
	(
		[Parameter(ValueFromPipeline=$true,Position=0)]
		$URL = 'https://www.bloomberg.com/professional/support/software-updates/'	
	)

	Begin {

		$Start = Get-Date
		Write-Verbose "Scraping $($URL) for data at $((Get-Date).ToString('yyyy-MM-dd HH:MM:ss'))"

	}

	Process {

		Write-Verbose "Extracting Data from $($URL)"
		$page = Invoke-WebRequest -Uri $URL

		#got through the page data and find the Table Row with the text we are looking for
		$TRwithData = $page.ParsedHtml.getElementsByTagName('tr') | Where-Object { $_.innerText -like "Bloomberg Terminal - New/Upgrade Installation*"}
		$HTMLwithData = $TRwithData.outerHTML

		#use regex to grab the month text, lets set the strings we need
		$firstString = '<td class="date">'
		$secondString = '</td>'

		#Regex pattern to compare two strings
		$pattern = "$firstString(.*?)$secondString"

		#Perform the match operation to grab the month string
		$ReleaseMonth = [regex]::Match($HTMLwithData,$pattern).Groups[1].Value

		if ($null -eq $ReleaseMonth){

			Write-Verbose "Can't find the Download in $($URL)"
			break

		}else{

			Write-Verbose "Found $($ReleaseMonth) Month in $($URL)"

		}
	}

End {

	$End = Get-Date

	Write-Verbose "Script finished at $((Get-Date).ToString('yyyy-MM-dd HH:MM:ss'))"
	Write-Verbose "This script took $((New-TimeSpan -Start $Start -End $End).TotalSeconds) seconds to complete"

	Return $ReleaseMonth
	}
}
```

also what I do, I stick it in my powershell profile (I put the function in the profile, you could stick it in a module you import etc...) and also add this in below it so it displays when I open a session (and also remind myself what todays date is...)

```powershell
Write-host "Today's date: $(get-date)"
Write-host "Current Bloomberg Terminal Release:"
Get-BloombergRelease
```

and everytime I open a session it will check and let me know what month's update is available

![WinPoshBloomy]( /assets/images/WinPowershellBloomy.jpg)

I would like it to provide a URL that I could open (I use Windows Terminal so should be doable) , but that is a battle for another day!!

if anyone knows how to improve it, get the download url etc... please let me know as I literally was stumbling, messing around until this worked!!
