![Screenshot]( /assets/images/port_louis.png)

# GUI Controller to run AD Report Tools

So a few weeks back my boss went on holiday, and he asked me to run some AD reports for him when he was off.

I actually made the "Scripts" that pulled these reports many moons ago.

When I looked at them and how they were all in different locations, outputting CSVs to different folders, I thought I can make this so much better (and get brownie points) !
I have been using the great resource PoshCode/PowerShellPracticeAndStyle: The Unofficial PowerShell Best Practices and Style Guide <https://github.com/PoshCode/PowerShellPracticeAndStyle> to try and improve my scripts and (try) to produce clean code.
One thing I really liked (and I was falling down badly with) was the idea of tools and controllers. So with this in mind, I created some functions that used Cmdlets from the Active Directory module <https://learn.microsoft.com/en-us/powershell/module/activedirectory/?view=windowsserver2022-ps>

These were:

  • Get-PYTALLADComputers - Function to extract all AD Computer objects for a domain into a CSV & spreadsheet
	• Get-PYTALLADusers - Function to extract all AD User objects for a domain into a CSV & spreadsheet
	• Get-PYTUserGroupMembership - Function to extract all members of AD groups populated with user AD objects with a certain string in the names details into a CSV & spreadsheet
	• Get-PYTAdminGroups - Function to extract all Admin Groups & memberships details from multiple Domains into a CSV & spreadsheet, made specifically for admin groups (can be used for others)

These functions are nothing special, ALL AD Computers and users would pull out all those objects from AD into an array, then loop through that array, putting info into a PS custom object (we have some custom properties for those objects in AD that come out as non-string objects, so I used to PS Custom object to turn them into strings for export to CSV) once the CSV has been finished (handy for other scripts to read, as not got my head fully around ImportExcel yet) we basically create a .Xlsx from it and output to our chosen folder (this case C:\temp, but easy to change as it’s a parameter that can be passed to the function.

Get-PYTUserGroupMembership literally pulls out the members of AD groups that have been populated with only User AD objects (we control access to VDI pools and certain Group Policies via these, so its handy), it extracts all the AD groups that match the search string (but aren't prefix'd with zz as that is how we mark AD groups that are to be decom'd), then loops through the groups, each group it extracts the membership, looping through the membership doing a lookup to get more information on the member and pumping into a CSV file (which you guessed it, will be made into a .Xlsx!)
Get-PYTAdminGroups is basically Get-PYTUserGroupMembership but it will also search through multiple domains! 

Parameters - PowerShell Universal <https://docs.powershelluniversal.com/automation/scripts/parameters> - This blog helped with me passing multiple domains as a parameter..

I stuck them in a module which my controller script can call!

Now I have made scripts, modules etc… before and shared them with colleagues, but not everyone loves CLI like I do, and basically a lot of people don't use them.

So I figured it was time to make the controller scripts fire up a GUI and see if that would get my colleagues to use it more.

I did some research and found these which helped massively! 

Creating a custom input box - PowerShell | Microsoft Learn <https://learn.microsoft.com/en-us/powershell/scripting/samples/creating-a-custom-input-box?view=powershell-7.3> - This was my first stop, helped me pull in the .NET framework form-building features, build the form and labels add OK/ cancel buttons!
Powershell and Forms (part 3) – Checkboxes - ServerFixes <https://serverfixes.com/powershell-checkboxes> - this helped me add the checkboxes for what scripts you want to run.

Also I found that ChatGPT was decent at building the barebones of a GUI too! 

So here is the GUI!

![GUI]( /assets/images/ADReportsGUI.png)

I have also built a much more complicated GUI controller for a Nutanix module I am making, but it's still in progress!

Right so here is how the GUI was made!
Create the form and set Title, Size and Font

```powershell
$ADReportControllerForm = New-Object System.Windows.Forms.Form
$ADReportControllerForm.Text = 'PYT AD Reports'
$ADReportControllerForm.Size = New-Object System.Drawing.Size(400,270)
$ADReportControllerForm.StartPosition = 'CenterScreen'
$ADReportControllerForm.Font = ‘Microsoft Sans Serif,10’
```

Create the label/Text

```powershell
$TextHelp = New-Object System.Windows.Forms.Label
$TextHelp.Location = New-Object System.Drawing.Point(50,20)
$TextHelp.Size = New-Object System.Drawing.Size(350,20)
$TextHelp.Text = 'Select the reports you want to run, then click RUN'
$ADReportControllerForm.Controls.Add($TextHelp)
```

You create the checkbox like below, setting them as pre checked, and giving them a text label

```powershell
$AllADCompCheckbox = New-Object System.Windows.Forms.Checkbox 
$AllADCompCheckbox.Location = New-Object System.Drawing.Size(10,50) 
$AllADCompCheckbox.Size = New-Object System.Drawing.Size(500,20)
$AllADCompCheckbox.Text = "Run All PYT AD Computers Report"
$AllADCompCheckbox.TabIndex = 0
$AllADCompCheckbox.Checked = $true
$ADReportControllerForm.Controls.Add($AllADCompCheckbox)
```

Then the Run (OK) and Cancel buttons (see Dialogue result)

```powershell
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,180)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'RUN'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$okButton.TabIndex = 4
$ADReportControllerForm.AcceptButton = $okButton
$ADReportControllerForm.Controls.Add($okButton)
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(200,180)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$cancelButton.TabIndex = 5
$ADReportControllerForm.CancelButton = $cancelButton
$ADReportControllerForm.Controls.Add($cancelButton)
```

This will make sure the GUI doesn't get hidden under your many open windows (if like me !)

```powershell
$ADReportControllerForm.Topmost = $true
```

If the OK/Run button is pressed, then we check if the checkboxes are set to true/Checked and fire the function to create that report!

```powershell
if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    if($true -eq $AllADCompCheckbox.Checked){
        Get-PYTALLADComputers -Verbose
    }
    if($true -eq $AllADUserCheckbox.Checked){
        Get-PYTALLADusers -Verbose
    }
    if($true -eq $PoolVDICheckbox.Checked){
        Get-PYTUserGroupMembership VDI_POOL -Verbose
    }
    if($true -eq $SecurityGroupCheckbox.Checked){
        Get-PYTAdminGroups -Verbose
    }
}else{
    Write-Warning "Exiting Script"
    break
}
```

Viola ! My manager can run all his AD reports at the click of a button!!

You can find the files here, and any questions, Just shout :)

<https://github.com/PowerShellYoungTeam/Active-Directory>

