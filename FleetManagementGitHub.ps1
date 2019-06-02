###Example Dashboard###
function Invoke-Sqlcmd2 {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$ServerInstance,
        [Parameter(Position = 1, Mandatory = $false)]
        [string]$Database,
        [Parameter(Position = 2, Mandatory = $false)]
        [string]$Query,
        [Parameter(Position = 3, Mandatory = $false)]
        [string]$Username,
        [Parameter(Position = 4, Mandatory = $false)]
        [string]$Password,
        [Parameter(Position = 5, Mandatory = $false)]
        [Int32]$QueryTimeout = 600,
        [Parameter(Position = 6, Mandatory = $false)]
        [Int32]$ConnectionTimeout = 15,
        [Parameter(Position = 7, Mandatory = $false)]
        [ValidateScript( { test-path $_ })]
        [string]$InputFile,
        [Parameter(Position = 8, Mandatory = $false)]
        [ValidateSet("DataSet", "DataTable", "DataRow")]
        [string]$As = "DataRow"
    )

    if ($InputFile) {
        $filePath = $(resolve-path $InputFile).path
        $Query = [System.IO.File]::ReadAllText("$filePath")
    }

    $conn = new-object System.Data.SqlClient.SQLConnection

    if ($Username)
    { $ConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Connect Timeout={4}" -f $ServerInstance, $Database, $Username, $Password, $ConnectionTimeout }
    else
    { $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerInstance, $Database, $ConnectionTimeout }

    $conn.ConnectionString = $ConnectionString

    #Following EventHandler is used for PRINT and RAISERROR T-SQL statements. Executed when -Verbose parameter specified by caller
    if ($PSBoundParameters.Verbose) {
        $conn.FireInfoMessageEventOnUserErrors = $true
        $handler = [System.Data.SqlClient.SqlInfoMessageEventHandler] { Write-Verbose "$($_)" }
        $conn.add_InfoMessage($handler)
    }

    $conn.Open()
    $cmd = new-object system.Data.SqlClient.SqlCommand($Query, $conn)
    $cmd.CommandTimeout = $QueryTimeout
    $ds = New-Object system.Data.DataSet
    $da = New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
   [void]$da.fill($ds)
    $conn.Close()
    switch ($As) {
        'DataSet' { Write-Output ($ds) }
        'DataTable' { Write-Output ($ds.Tables) }
        'DataRow' { Write-Output ($ds.Tables[0]) }
    }

}
###Import the module if not imported already
Import-Module -Name UniversalDashboard
###Stop any running dashboards so no conflict with port numbers
Get-UDDashboard | Stop-UDDashboard
########Using Two separate files as lots of cached variables used throughout dashboard
$Endpoint1 = . (Join-Path $PSScriptRoot "PagesGitHub\EndPoint.ps1")
$Endpoint2 = . (Join-Path $PSScriptRoot "PagesGitHub\EndPoint2.ps1")
#####Bring in some variable to use throughout the script
$Root = $PSScriptRoot
$Init = New-UDEndpointInitialization -Variable "Root" -Function 'Invoke-Sqlcmd2'
###Setup NavBar and Navbar links
$NavBarLinks = @((New-UDLink -Text "Log a support call" -Url "http://yourhelpdesk.com" -Icon help))
$Link = New-UDLink -Text 'Your Company Website' -Url 'http://www.yourcompany.com' -Icon globe
$Footer = New-UDFooter -Copyright 'Designed by Your Name' -Links $Link
$theme = . (Join-Path $Root "PagesGitHub\Theme.ps1")
$FormLogin = . (Join-Path $Root "PagesGitHub\FormLogin.ps1")
$LoginPage = New-UDLoginPage -AuthenticationMethod $FormLogin -LoginFormFontColor "#ffffff" -LoginFormBackgroundColor "#4392f1" -PageBackgroundColor '#FFFFFF' -Logo (New-UDImage -Url "https://www.designevo.com/res/templates/thumb_small/bright-blue-kaleidoscope.png") -Title "Your Company Fleet Management System" -WelcomeText "Your Company Fleet Management" -LoadingText "Please wait..." -LoginButtonFontColor "#FFFFFF" -LoginButtonBackgroundColor "#FF6666"
$HomePage = . (Join-Path $Root "PagesGitHub\HomePage.ps1")
$CostPage = . (Join-Path $Root "PagesGitHub\CostPage.ps1")
$StatusPage = . (Join-Path $Root "PagesGitHub\StatusPage.ps1")
$StatisticsPage = . (Join-Path $Root "PagesGitHub\StatisticsPage.ps1")
$SitePage = . (Join-Path $Root "PagesGitHub\SitePage.ps1")
$Dashboard = New-UDDashboard -Title "FLEET MANAGEMENT SYSTEM" -Pages @(
    $HomePage,
    $CostPage,
    $StatusPage,
    $StatisticsPage,
    $SitePage
) -NavBarLogo (New-UDImage -Url "https://img.icons8.com/color/2x/android-tablet.png") -NavbarLinks $NavBarLinks -Theme $theme -Footer $Footer -NavBarColor "#4392f1" -NavBarFontColor "#000000" -EndpointInitialization $Init -LoginPage $LoginPage
Start-UDDashboard -Dashboard $Dashboard -Port 8088 -AllowHttpForLogin -Endpoint @($Endpoint1,$Endpoint2) -AutoReload
