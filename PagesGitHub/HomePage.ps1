New-UDPage -Name "Home" -Icon home -Content {
    New-UDTabContainer -Tabs {
        New-UDTab -Text "Welcome" -Content {
            New-UDColumn -SmallSize 6 -MediumSize 6 -LargeSize 6 -SmallOffset 3 -Content {
                New-UDCard -Title "Fleet Management System" -Image (New-UDImage -Url "https://www.designevo.com/res/templates/thumb_small/bright-blue-kaleidoscope.png" ) -Text "This is the new fleet management system that internal IT have designed. This will be used to input and display statistical data of the vehicles that Your Company manage. The menus on each page within this application will be tabbed along the top for the main category menu you have selected. The main menu categories can be accessed in the top left hand corner of this dashboard using the hamburger menu."

            }
            New-UDColumn -SmallSize 6 -MediumSize 6 -LargeSize 6 -Content {
                New-UDCollapsible -Popout -Items {
                    New-UDCollapsibleItem -Title "Complete Control" -Icon map_pin -BackgroundColor "#4392f1" -Content {
                        New-UDHeading -Color "#ffffff" -Text "Allowing you to manage all vehicles for Your Company, across all of the depots Your Company manage."
                    }
                    New-UDCollapsibleItem -Title "Centrally managed" -Icon balance_scale -BackgroundColor "#4392f1" -Content {
                        New-UDHeading -Color "#ffffff" -Text "Allowing multiple people to access and edit the data at the same time."
                    }
                    New-UDCollapsibleItem -Title "Ease of access" -Icon internet_explorer -BackgroundColor "#4392f1" -Content {
                        New-UDHeading -Color "#ffffff" -Text "Always available always running 24 hours 7 days a week "
                    }
                    New-UDCollapsibleItem -Title "Secure Site" -Icon empire -BackgroundColor "#4392f1" -Content {
                        New-UDHeading -Color "#ffffff" -Text "Only allowing designated access to this dashboard via a security group in Active Directory"
                    }
                    New-UDCollapsibleItem -Title "No more Excel" -Icon exclamation_circle -BackgroundColor "#4392f1" -Content {
                        New-UDHeading -Color "#ffffff" -Text "No more formulas to rely on to populate the data with, all data is dynamically presented"
                    }
                }
            }
               New-UDColumn -Endpoint {
                while ($true) {
                    $DateTime = Get-Date
                    #update the digital clock
                    Set-UDElement -Id "digital" -Broadcast -Content { $DateTime.ToLongTimeString() }
                    Start-Sleep -Seconds 1
                }
            }
            New-UDRow -Columns {
                New-UDColumn -SmallSize 12 -MediumSize 12 -LargeSize 12 -Content {
                    New-UDHeading -Size 3 -Content {
                        New-UDElement -Tag "div" -Id "digital" -Attributes @{ textAlign = "center" }
                    }
                   }
            }

        }
        New-UDTab -Text "New Vehicle" -Content {
            $Layout = '{"lg":[{"w":7,"h":14,"x":2,"y":0,"i":"grid-element-inputid","moved":false,"static":false}]}'

            New-UDGridLayout -Layout $Layout -Content {
                New-UDInput -Id "inputid" -Title "New Vehicle Input" -Endpoint {
                    param(
                        [Parameter(HelpMessage = "Vehicle Agreement")]
                        [ValidateSet("Spot Rent", "Contract Rent", "Owned")]$hire,
                        [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("The registration number you entered is invalid.")][ValidateLength(7, 7)][string]$RegistrationNumber,
                        [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("You must type in something.")][string]$Make,
                        [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("You must type in something.")][string]$Model,
                        [Parameter(HelpMessage = "Select Weight")][ValidateSet("0.5 tonne", "3.5 tonne", "5 tonne", "7.2 tonne", "7.5 tonne", "12 tonne", "15 tonne", "26 tonne")]$Weight,
                        [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("You must type in something.")][string]$BodyType,
                        [Parameter(Mandatory)][string]$Value,
                        [Parameter(HelpMessage = "Engine Type")][ValidateSet("Euro 1", "Euro 2", "Euro 3", "Euro 4", "Euro 5", "Euro 6", "Euro 7")]$EngineType,
                        [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("You must type in something.")][string]$HireCompany,
                        [Parameter(HelpMessage = "Select Depot")][ValidateSet("YourSite","YourSite2","YourSite3")]$DepotName,
                        [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("The date format must be YYYY-MM-DD format.")][ValidatePattern('[0-9]{4}-[0-9]{2}-[0-9]{2}')][string]$StartDate,
                        [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("The date format must be YYYY-MM-DD format.")][ValidatePattern('[0-9]{4}-[0-9]{2}-[0-9]{2}')][string]$EndDate
                    )
                    if (-Not(Test-Path $Root\$User)) { mkdir $Root\$User }
                    if (Test-path $Root\$User\output.txt)
                    { Remove-Item -Path "$Root\$User\output.txt" }
                    $hire | Out-File (Join-Path $Root\$User "output.txt")
                    $RegistrationNumber | Out-File (Join-Path $Root\$User "output.txt") -Append
                    $Make | Out-File (Join-Path $Root\$User "output.txt") -Append
                    $Model | Out-File (Join-Path $Root\$User "output.txt") -Append
                    $Weight | Out-File (Join-Path $Root\$User "output.txt") -Append
                    $BodyType | Out-File (Join-Path $Root\$User "output.txt") -Append
                    $Value | Out-File (Join-Path $Root\$User "output.txt") -Append
                    $Status | Out-File (Join-Path $Root\$User "output.txt") -Append
                    $EngineType | Out-File (Join-Path $Root\$User "output.txt") -Append
                    $HireCompany | Out-File (Join-Path $Root\$User "output.txt") -Append
                    $DepotName | Out-File (Join-Path $Root\$User "output.txt") -Append
                    $file = get-content $Root\$User\output.txt
                    $line0 = $file[0]
                    $line1 = $file[1]
                    $line2 = $file[2]
                    $line3 = $file[3]
                    $line4 = $file[4]
                    $line5 = $file[5]
                    $line6 = $file[6]
                    $line7 = $file[7]
                    $line8 = $file[8]
                    $line9 = $file[9]
                    ###Change output of Text file into something that can be imported into the SQL database.
                    $line0 = if ($line0 -match "Spot Rent") { $line0 -replace "Spot Rent", "1" }elseif ($line0 -match "Contract Rent") { $line0 -replace "Contract Rent", "2" }else { $line0 -replace "Owned", "3" }
                    $line1 = "'$line1'"
                    $line2 = "'$line2'"
                    $line3 = "'$line3'"
                    $line4 = if ($line4 -match "0.5 tonne") { $line4 -replace "0.5 tonne", "1" }elseif ($line4 -match "3.5 tonne") { $line4 -replace "3.5 tonne", "2" }elseif ($line4 -match "5 tonne") { $line4 -replace "5 tonne", "3" }elseif ($line4 -match "7.2 tonne") { $line4 -replace "7.2 tonne", "4" }elseif ($line4 -match "7.5 tonne") { $line4 -replace "7.5 tonne", "5" }elseif ($line4 -match "12 tonne") { $line4 -replace "12 tonne", "6" }elseif ($line4 -match "15 tonne") { $line4 -replace "15 tonne", "7" }elseif ($line4 -match "26 tonne") { $line4 -replace "26 tonne", "8" }
                    $line5 = "'$line5'"
                    $line6 = "'$line6'"
                    $line7 = if ($line7 -match "Euro 1") { $line7 -replace "Euro 1", "1" }elseif ($line7 -match "Euro 2") { $line7 -replace "Euro 2", "2" }elseif ($line7 -match "Euro 3") { $line7 -replace "Euro 3", "3" }elseif ($line7 -match "Euro 4") { $line7 -replace "Euro 4", "4" }elseif ($line7 -match "Euro 5") { $line7 -replace "Euro 5", "5" }elseif ($line7 -match "Euro 6") { $line7 -replace "Euro 6", "6" }elseif ($line7 -match "Euro 7") { $line7 -replace "Euro 7", "7" }
                    $line8 = "'$line8'"
                    $line9 = if ($line9 -match "Brandon") { $line9 -replace "Brandon", "1" }elseif ($line9 -match "Bristol") { $line9 -replace "Bristol", "2" }elseif ($line9 -match "Chehsunt") { $line9 -replace "Cheshunt", "3" }elseif ($line9 -match "Kent") { $line9 -replace "Kent", "4" }elseif ($line9 -match "Kirby & West") { $line9 -replace "Kirby & West", "5" }elseif ($line9 -match "Southampton") { $line9 -replace "Southampton", "6" }elseif ($line9 -match "Bridge-End") { $line9 -replace "Bridge-End", "7" }
                    $finished = $line0 + "," + $line1 + "," + $line2 + "," + $line3 + "," + $line4 + "," + $line5 + "," + $line6 + "," + "1" + "," + $line7 + "," + "1" + "," + $line8 + "," + $line9

                    $query1 = @"
INSERT INTO FLEET.dbo.Vehicle (Hire_ID,Registration,Make,Model,Weight_ID,Body_Type,Value,Status_ID,Engine_ID,Active_ID,HireCompany,Depot_ID)
VALUES ($finished)
"@


                    Invoke-Sqlcmd2 -ServerInstance braeforge-sql2 -Database FLEET -Query $query1 -Username 'innov8_innview' -Password 'innov8_innview'
                    if (Test-path $Root\$User\sedate.txt)
                    { Remove-Item -Path "$Root\$User\sedate.txt" }
                    $StartDate | Out-File (Join-Path $Root\$User "sedate.txt")
                    $EndDate | Out-File (Join-Path $Root\$User "sedate.txt") -Append
                    $RegistrationNumber | Out-File (Join-Path $Root\$User "sedate.txt") -Append
                    $fileSD = get-content $Root\$User\sedate.txt
                    $SD = $fileSD[2]
                    $nSD = "'$SD'"
                    $star = $fileSD[0]
                    $en = $fileSD[1]
                    $start = "'$star'"
                    $end = "'$en'"
                    $QRegNum = @"
 select Vehicle_ID
FROM FLEET.dbo.Vehicle
WHERE Registration = $nSD
"@
                    $iRegnum = Invoke-Sqlcmd2 -ServerInstance braeforge-sql2 -Database FLEET -Query $QRegNum -Username innov8_innview -Password innov8_innview | select-object Vehicle_ID
                    $QRegNum2 = @"
  INSERT INTO FLEET.dbo.AgreementRental(Vehicle_ID,[Start_Date],End_Date)
VALUES ($($iRegNum.Vehicle_ID),$start,$end)
"@
                    Invoke-Sqlcmd2 -ServerInstance braeforge-sql2 -Database FLEET -Query $QRegNum2 -Username innov8_innview -Password innov8_innview

                    New-UDInputAction -Toast "Thanks for completing the vehicle registration of $RegistrationNumber" -Duration 3000
                } -Validate

            }


        }
        New-UDTab -Text "Set Distance Allowance" -Content {
            $Layout = '{"lg":[{"w":6,"h":16,"x":0,"y":0,"i":"grid-element-gridcard","moved":false,"static":false},{"w":4,"h":12,"x":7,"y":0,"i":"grid-element-mileageAllowance","moved":false,"static":false}]}'
            New-UDGridLayout -Layout $Layout -Content {
                    New-UDGrid -Id "gridcard" -Title "Set The Distance Allowance On A Vehicle ID" -Headers @("Vehicle_ID", "Agreement", "Registration", "EngineType", "MileageAllowance" ) -Properties @("Vehicle_ID", "Agreement", "Registration", "EngineType", "MileageAllowance" ) -DefaultSortColumn "Vehicle_ID"  -PageSize 10  -Endpoint {
                        $Cache:MilageAllowance | Select-Object "Vehicle_ID", "Agreement", "Registration", "EngineType", "MileageAllowance" | Out-UDGridData
                    } -AutoRefresh -RefreshInterval 20


                    New-UDInput  -Id "mileageAllowance" -Title "Enter Total Distance Allowed" -Content {
                        New-UDInputField -Type 'textbox' -Name 'Vehicle_ID' -Placeholder 'Enter Vehicle ID'
                        New-UDInputField -Type 'textbox' -Name 'MileageAllowed' -Placeholder 'Allowed Distance' } -Endpoint {
                        param($Vehicle_ID, $MileageAllowed)
                        if (-Not(Test-Path $Root\$User)) { mkdir $Root\$User }
                        if (Test-path $Root\$User\MileageAllowed.txt)
                        { Remove-Item -Path "$Root\$User\MileageAllowed.txt" }
                        $MileageAllowed | Out-File (Join-Path $Root\$User "MileageAllowed.txt")
                        $ma = Get-Content $Root\$User\MileageAllowed.txt
                        $line = $ma
                        $line = "'$line'"
                        $allowedQ = @"
IF EXISTS (SELECT * FROM FLEET.dbo.AgreementRental WHERE Vehicle_ID = $Vehicle_ID)
BEGIN
    UPDATE FLEET.dbo.AgreementRental
    SET Milage_Allowance = $line
    WHERE Vehicle_ID = $Vehicle_ID
END
ELSE
BEGIN
   INSERT INTO FLEET.dbo.AgreementRental(Vehicle_ID,Milage_Allowance)
   VALUES ($Vehicle_ID,$line)
END
"@
                        Invoke-Sqlcmd2 -ServerInstance braeforge-sql2 -Database FLEET -Query $allowedQ -Username innov8_innview -Password innov8_innview
                        New-UDInputAction -Toast "Vehicle ID $Vehicle_ID has now set the distance allowance of $MileageAllowed" -Duration 3000
                    }

            }

        }
        New-UDTab -Text "Assign Vehicle To Round" -Content {
            $Layout = '{"lg":[{"w":7,"h":16,"x":0,"y":0,"i":"grid-element-card1aa","moved":false,"static":false},{"w":4,"h":13,"x":7,"y":0,"i":"grid-element-card2aa","moved":false,"static":false}]}'
            New-UDGridLayout -Layout $Layout -Content {

New-UDGrid -Id "card1aa" -Title "Assign Vehicle To Round" -Headers @("Vehicle_ID", "HireCompany", "Registration", "EngineType", "DepotName", "Round_Name") -Properties @("Vehicle_ID", "HireCompany", "Registration", "EngineType", "DepotName", "Round_Name") -DefaultSortColumn "Vehicle_ID" -PageSize 10  -Endpoint {
                        $Cache:VehiclesNoRound2 | Select-Object "Vehicle_ID", "Agreement", "HireCompany", "Registration", "EngineType", "DepotName", "Round_Name" | Out-UDGridData
                    } -AutoRefresh -RefreshInterval 20

                    New-UDInput -Id "card2aa" -Title "Assign Vehicle ID to Food Round" -Content {
                        New-UDInputField -Type 'textbox' -Name 'Vehicle_ID33' -Placeholder 'Enter Vehicle ID'
                        New-UDInputField -Type 'textbox' -Name 'FoodRound2' -Placeholder 'Enter Food Round' } -Endpoint {
                        param($Vehicle_ID33, $FoodRound2)
                        $line = $FoodRound2
                        $line = "'$line'"
                        $foodQuery33 = @"
IF EXISTS (SELECT * FROM FLEET.dbo.FoodRound WHERE Vehicle_ID = $Vehicle_ID33)
BEGIN
UPDATE FLEET.dbo.FoodRound
SET Round_Name = $line
WHERE Vehicle_ID = $Vehicle_ID33
END
ELSE
BEGIN
INSERT INTO FLEET.dbo.FoodRound(Vehicle_ID, Round_Name)
VALUES ($Vehicle_ID33,$line)
END
"@
                        Invoke-Sqlcmd2 -ServerInstance braeforge-sql2 -Database FLEET -Query $foodQuery33 -Username innov8_innview -Password innov8_innview
                        New-UDInputAction -Toast "Vehicle ID $Vehicle_ID33 has now been added to $line" -Duration 3000
                    }

            }
        }
        New-UDTab -Text "Rental Costs" -Content {
            $Layout = '{"lg":[{"w":7,"h":16,"x":0,"y":0,"i":"grid-element-card1","moved":false,"static":false},{"w":4,"h":13,"x":7,"y":0,"i":"grid-element-card2","moved":false,"static":false}]}'
            New-UDGridLayout -Layout $Layout -Content {
                    New-UDGrid -Id "card1" -Title "Showing Active Vehicles To Assign Rental Cost" -Headers @("Vehicle_ID", "HireCompany", "Registration", "StatusName", "EngineType", "DepotName", "Rental_Cost") -Properties @("Vehicle_ID", "HireCompany", "Registration", "StatusName", "EngineType", "DepotName", "Rental_Cost") -DefaultSortColumn "Vehicle_ID" -PageSize 10  -Endpoint {
                        $Cache:Rent | Select-Object "Vehicle_ID", "HireCompany", "Registration", "StatusName", "EngineType", "DepotName", "Rental_Cost" | Out-UDGridData
                    } -AutoRefresh


                    New-UDInput -Id "card2" -Title "Enter the Monthly Rent Amount" -Content {
                        New-UDInputField -Type 'textbox' -Name 'Vehicle_ID' -Placeholder 'Enter Vehicle ID'
                        New-UDInputField -Type 'textbox' -Name 'Rental' -Placeholder 'Enter Monthly Rent' } -Endpoint {
                        param($Vehicle_ID, $Rental)
                        if (-Not(Test-Path $Root\$User)) { mkdir $Root\$User }
                        if (Test-path $Root\$User\Rental.txt)
                        { Remove-Item -Path "$Root\$User\Rental.txt" }
                        $Rental | Out-File (Join-Path $Root\$User "Rental.txt")
                        $rent = Get-Content $Root\$User\Rental.txt
                        $line = $rent
                        $line = "'$line'"
                        $RenQuery = @"
IF EXISTS (SELECT * FROM FLEET.dbo.AgreementRental WHERE Vehicle_ID = $Vehicle_ID)
BEGIN
    UPDATE FLEET.dbo.AgreementRental
    SET Rental_Cost = $line
    WHERE Vehicle_ID = $Vehicle_ID
END
ELSE
BEGIN
   INSERT INTO FLEET.dbo.AgreementRental(Vehicle_ID,Rental_Cost)
   VALUES ($Vehicle_ID,$line)
END
"@
                        Invoke-Sqlcmd2 -ServerInstance braeforge-sql2 -Database FLEET -Query $RenQuery -Username innov8_innview -Password innov8_innview
                        New-UDInputAction -Toast "Vehicle ID $Vehicle_ID has now been updated with $Rental" -Duration 3000
                    }

            }

        }
    }
}