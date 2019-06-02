New-UDPage -Name "YourSite" -Icon building -Content {
    New-UDTabContainer -Tabs {

   New-UDTab -Text "Enter Mileage" -Content {
            $Layout = '{"lg":[{"w":8,"h":13,"x":0,"y":0,"i":"grid-element-card11bran","moved":false,"static":false},{"w":4,"h":13,"x":8,"y":0,"i":"grid-element-card22bran","moved":false,"static":false}]}'
            New-UDGridLayout -Layout $Layout -Content {
                    New-UDGrid -Id "card11bran" -Title "Active YourSite Vehicles" -Headers @("Vehicle_ID", "HireCompany", "Registration", "Weight", "Status", "EngineType", "Active", "Round_Name") -Properties @("Vehicle_ID", "HireCompany", "Registration", "Weight", "Status", "EngineType", "Active", "Round_Name") -DefaultSortColumn "Vehicle_ID" -PageSize 7  -Endpoint {

                        $Cache:YourSiteVehicles | Select-Object "Vehicle_ID", "Agreement", "HireCompany", "Registration", "Weight","Status", "EngineType", "Active", "Round_Name" | Out-UDGridData
                    } -AutoRefresh -RefreshInterval 15
                    New-UDInput -Id "card22bran" -Title "Enter Week-Ending Mileage" -Endpoint {
                          param([Parameter(HelpMessage = "Measurement Value")][ValidateSet("Kilometres", "Miles")]$measurement,
                              [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("The vehicle ID you entered is invalid.")][ValidatePattern('[0-9]{1}|[0-9]{2}')][ValidateLength(1, 2)][string]$Vehicle_ID,
                            [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("The date format must be YYYY-MM-DD format.")][ValidatePattern('[0-9]{4}-[0-9]{2}-[0-9]{2}')][string]$Weekending,
                            [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("You must type in a Mileage value.")][string]$DistanceValue
                          )
                        if (-Not(Test-Path $Root\$User)) { mkdir $Root\$User }
                        if (Test-path $Root\$User\Mileage.txt)
                        { Remove-Item -Path "$Root\$User\Mileage.txt" }
                        $Vehicle_ID | Out-File (Join-Path $Root\$User "Mileage.txt")
                        if ($measurement -match 'Miles'){ $distance = 'Milage'}else{$distance = 'Kilometres'}
                        $distance | Out-File (Join-Path $Root\$User "Mileage.txt") -Append
                        $Weekending | Out-File (Join-Path $Root\$User "Mileage.txt") -Append
                        $DistanceValue | Out-File (Join-Path $Root\$User "Mileage.txt") -Append
                        $file = get-content $Root\$User\Mileage.txt
                        $line0 = $file[0]
                        $line1 = $file[1]
                        $line2 = $file[2]
                        $line3 = $file[3]
                        $line1 = "'$line1'"
                        $line2 = "'$line2'"
                        $fini = $line0 +  "," + $line2+ "," + $line3
                    if ($line1 -match 'Milage') {
                        $RecCheck = @"
SELECT COUNT(M_ID) num FROM FLEET.dbo.Milage WHERE Vehicle_ID = $line0 AND Recorded_M_Date = $line2
"@
                        $EntryMID = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $RecCheck -Username 'YOUR_USERNAME' -Password 'YOUR_USERNAME' | select-object -ExpandProperty 'num'
                        if ($EntryMID -gt 0) {
                            $newQ = @"
SELECT M_ID num FROM FLEET.dbo.Milage WHERE Vehicle_ID = $line0 AND Recorded_M_Date = $line2
"@
                            $newEntryMID = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $newQ -Username 'YOUR_USERNAME' -Password 'YOUR_USERNAME' | select-object -ExpandProperty 'num'
                            $insertMileage = @"
UPDATE FLEET.dbo.Milage
SET Milage = $line3
,Recorded_M_Date = $line2
WHERE M_ID = $newEntryMID
"@
                            Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $insertMileage -Username 'YOUR_USERNAME' -Password 'YOUR_USERNAME'
                        }
                        else {
                            $insertMileage = @"
INSERT INTO FLEET.dbo.Milage(Vehicle_ID,Recorded_M_date,Milage)
VALUES($fini)
"@
                            Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $insertMileage -Username 'YOUR_USERNAME' -Password 'YOUR_USERNAME'
                        }


                    }
                    elseif ($line1 -match 'Kilometres') {
                        $RecCheck2 = @"
SELECT COUNT(M_ID) num2 FROM FLEET.dbo.Milage WHERE Vehicle_ID = $line0 AND Recorded_M_Date = $line2
"@
                        $EntryMID2 = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $RecCheck2 -Username 'YOUR_USERNAME' -Password 'YOUR_USERNAME' | select-object -ExpandProperty 'num2'
                        if ($EntryMID2 -gt 0) {
                            $newQ2 = @"
SELECT M_ID num FROM FLEET.dbo.Milage WHERE Vehicle_ID = $line0 AND Recorded_M_Date = $line2
"@
                            $newEntryMID2 = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $newQ2 -Username 'YOUR_USERNAME' -Password 'YOUR_USERNAME' | select-object -ExpandProperty 'num'
                            $insertMileage2 = @"
UPDATE FLEET.dbo.Milage
SET Kilometres = $line3
,Recorded_M_Date = $line2
WHERE M_ID = $newEntryMID2
"@
                            Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $insertMileage2 -Username 'YOUR_USERNAME' -Password 'YOUR_USERNAME'
                        }
                        else {
                            $insertMileage2 = @"
INSERT INTO FLEET.dbo.Milage(Vehicle_ID,Recorded_M_date,Kilometres)
VALUES($fini)
"@
                            Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $insertMileage2 -Username 'YOUR_USERNAME' -Password 'YOUR_USERNAME'
                        }
                    }
                       New-UDInputAction -Toast "Thank you the information for vehicle ID $Vehicle_ID has now been updated" -Duration 3000
                    } -Validate

                }
            }
        New-UDTab -Text "Preventative Checks" -Content {
            $Layout = '{"lg":[{"w":9,"h":13,"x":0,"y":0,"i":"grid-element-leftbra","moved":false,"static":false},{"w":3,"h":13,"x":10,"y":0,"i":"grid-element-rightbra","moved":false,"static":false}]}'
            New-UDGridLayout -Layout $Layout -Content {
                    New-UDGrid -Id "leftbra" -Title "Listing YourSite Depot Vehicles To Check" -Headers @("Vehicle_ID", "HireCompany", "Registration", "Weight", "Status", "EngineType", "Active", "Round_Name") -Properties @("Vehicle_ID", "HireCompany", "Registration", "Weight", "Status", "EngineType", "Active", "Round_Name") -DefaultSortColumn "Vehicle_ID" -PageSize 7  -Endpoint {
                        $Cache:YourSiteVehicles | Select-Object "Vehicle_ID", "Agreement", "HireCompany", "Registration", "Weight", "Status", "EngineType", "Active", "Round_Name" | Out-UDGridData
                    } -AutoRefresh -RefreshInterval 15


                    New-UDInput -Id "rightbra" -Title "Complete Checks" -Endpoint {
                        param(
                            [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("The vehicle ID you entered is invalid.")][ValidateLength(1, 2)][string]$Vehicle_ID,
                            [Parameter(HelpMessage = "Select Preventative Measure")][ValidateSet("Vehicle Service", "Fridge Service","Loler Service", "M.O.T","Tacho Calibration","Tyre Check")]$Check_Type,
                            [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("The date format must be YYYY-MM-DD format.")][ValidatePattern('[0-9]{4}-[0-9]{2}-[0-9]{2}')][string]$Date_Check_Completed
                        )
                        if (-Not(Test-Path $Root\$User)) { mkdir $Root\$User }
                        if (Test-path $Root\$User\preventative.txt)
                        { Remove-Item -Path "$Root\$User\preventative.txt" }
                        $Vehicle_ID | Out-File (Join-Path $Root\$User "preventative.txt")
                        $Check_Type | Out-File (Join-Path $Root\$User "preventative.txt") -Append
                        $Date_Check_Completed | Out-File (Join-Path $Root\$User "preventative.txt") -Append
                        $results = Get-Content $Root\$User\preventative.txt
                        $line0 = $results[0]
                        $line1 = $results[1]
                        $line2 = $results[2]
                        $line2 = "'$line2'"
                    if ($line1 -match 'Vehicle Service') {
                        $initialq = @"
SELECT COUNT([Vehicle_Service]) Tyre_Check
  FROM [FLEET].[dbo].[Preventative]
  where Vehicle_ID = $line0
"@
                        $testnum = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $initialq -Username YOUR_USERNAME -Password YOUR_USERNAME| select-object -ExpandProperty Tyre_Check
                        if ($testnum -eq 0) {
                            $PreQuery = @"
INSERT INTO FLEET.dbo.Preventative(Vehicle_ID,Vehicle_Service)
VALUES($line0,$line2)
"@
                            Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $PreQuery -Username YOUR_USERNAME -Password YOUR_PASSWORD
                        }
                        else {
                            $check1 = @"
SELECT [PMI_ID]
  FROM [FLEET].[dbo].[Preventative]
  WHERE Vehicle_ID = $line0 AND Vehicle_Service IS NOT NULL
"@
                            $PMI_ID = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $check1 -Username YOUR_USERNAME -Password YOUR_USERNAME| select-object -ExpandProperty PMI_ID
                            $UpdateQ = @"
UPDATE FLEET.dbo.Preventative
SET Vehicle_Service = $line2
where PMI_ID = $PMI_ID
"@
                            Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $UpdateQ -Username YOUR_USERNAME -Password YOUR_PASSWORD
                        }
                    }
                    elseif ($line1 -match 'Fridge Service') {
                        $initialq = @"
SELECT COUNT([Fridge_Service]) Tyre_Check
  FROM [FLEET].[dbo].[Preventative]
  where Vehicle_ID = $line0
"@
                        $testnum = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $initialq -Username YOUR_USERNAME -Password YOUR_USERNAME| select-object -ExpandProperty Tyre_Check
                        if ($testnum -eq 0) {
                            $PreQuery = @"
INSERT INTO FLEET.dbo.Preventative(Vehicle_ID,Fridge_Service)
VALUES($line0,$line2)
"@
                            Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $PreQuery -Username YOUR_USERNAME -Password YOUR_PASSWORD
                        }
                        else {
                            $check1 = @"
SELECT [PMI_ID]
  FROM [FLEET].[dbo].[Preventative]
  WHERE Vehicle_ID = $line0 AND Fridge_Service IS NOT NULL
"@
                            $PMI_ID = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $check1 -Username YOUR_USERNAME -Password YOUR_USERNAME| select-object -ExpandProperty PMI_ID
                            $UpdateQ = @"
UPDATE FLEET.dbo.Preventative
SET Fridge_Service = $line2
where PMI_ID = $PMI_ID
"@
                            Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $UpdateQ -Username YOUR_USERNAME -Password YOUR_PASSWORD
                        }
                    }
                    elseif ($line1 -match "Loler Service") {
                        $initialq = @"
SELECT COUNT([Loler_Service]) Tyre_Check
  FROM [FLEET].[dbo].[Preventative]
  where Vehicle_ID = $line0
"@
                        $testnum = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $initialq -Username YOUR_USERNAME -Password YOUR_USERNAME| select-object -ExpandProperty Tyre_Check
                        if ($testnum -eq 0) {
                            $PreQuery = @"
INSERT INTO FLEET.dbo.Preventative(Vehicle_ID,Loler_Service)
VALUES($line0,$line2)
"@
                            Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $PreQuery -Username YOUR_USERNAME -Password YOUR_PASSWORD
                        }
                        else {
                            $check1 = @"
SELECT [PMI_ID]
  FROM [FLEET].[dbo].[Preventative]
  WHERE Vehicle_ID = $line0 AND Loler_Service IS NOT NULL
"@
                            $PMI_ID = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $check1 -Username YOUR_USERNAME -Password YOUR_USERNAME| select-object -ExpandProperty PMI_ID
                            $UpdateQ = @"
UPDATE FLEET.dbo.Preventative
SET Loler_Service = $line2
where PMI_ID = $PMI_ID
"@
                            Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $UpdateQ -Username YOUR_USERNAME -Password YOUR_PASSWORD
                        }
                    }
                    elseif ($line1 -match 'M.O.T') {
                        $initialq = @"
SELECT COUNT([MOT]) Tyre_Check
  FROM [FLEET].[dbo].[Preventative]
  where Vehicle_ID = $line0
"@
                        $testnum = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $initialq -Username YOUR_USERNAME -Password YOUR_USERNAME| select-object -ExpandProperty Tyre_Check
                        if ($testnum -eq 0) {
                            $PreQuery = @"
INSERT INTO FLEET.dbo.Preventative(Vehicle_ID,MOT)
VALUES($line0,$line2)
"@
                            Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $PreQuery -Username YOUR_USERNAME -Password YOUR_PASSWORD
                        }
                        else {
                            $check1 = @"
SELECT [PMI_ID]
  FROM [FLEET].[dbo].[Preventative]
  WHERE Vehicle_ID = $line0 AND MOT IS NOT NULL
"@
                            $PMI_ID = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $check1 -Username YOUR_USERNAME -Password YOUR_USERNAME| select-object -ExpandProperty PMI_ID
                            $UpdateQ = @"
UPDATE FLEET.dbo.Preventative
SET MOT = $line2
where PMI_ID = $PMI_ID
"@
                            Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $UpdateQ -Username YOUR_USERNAME -Password YOUR_PASSWORD
                        }

                    }
                    elseif ($line1 -match 'Tacho Calibration') {
                        $initialq = @"
SELECT COUNT([Tacho_Calibration]) Tyre_Check
  FROM [FLEET].[dbo].[Preventative]
  where Vehicle_ID = $line0
"@
                        $testnum = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $initialq -Username YOUR_USERNAME -Password YOUR_USERNAME| select-object -ExpandProperty Tyre_Check
                        if ($testnum -eq 0) {
                            $PreQuery = @"
INSERT INTO FLEET.dbo.Preventative(Vehicle_ID,Tacho_Calibration)
VALUES($line0,$line2)
"@
                            Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $PreQuery -Username YOUR_USERNAME -Password YOUR_PASSWORD
                        }
                        else {
                            $check1 = @"
SELECT [PMI_ID]
  FROM [FLEET].[dbo].[Preventative]
  WHERE Vehicle_ID = $line0 AND Tacho_Calibration IS NOT NULL
"@
                            $PMI_ID = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $check1 -Username YOUR_USERNAME -Password YOUR_USERNAME| select-object -ExpandProperty PMI_ID
                            $UpdateQ = @"
UPDATE FLEET.dbo.Preventative
SET Tacho_Calibration = $line2
where PMI_ID = $PMI_ID
"@
                            Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $UpdateQ -Username YOUR_USERNAME -Password YOUR_PASSWORD
                        }
                    }
                    elseif ($line1 -match 'Tyre Check') {
                        $initialq = @"
SELECT COUNT([Tyre_Check]) Tyre_Check
  FROM [FLEET].[dbo].[Preventative]
  where Vehicle_ID = $line0
"@
                        $testnum = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $initialq -Username YOUR_USERNAME -Password YOUR_USERNAME| select-object -ExpandProperty Tyre_Check
                        if ($testnum -eq 0) {
                            $PreQuery = @"
INSERT INTO FLEET.dbo.Preventative(Vehicle_ID,Tyre_Check)
VALUES($line0,$line2)
"@
                            Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $PreQuery -Username YOUR_USERNAME -Password YOUR_PASSWORD
                        }
                        else {
                            $check1 = @"
SELECT [PMI_ID]
  FROM [FLEET].[dbo].[Preventative]
  WHERE Vehicle_ID = $line0 AND Tyre_Check IS NOT NULL
"@
                            $PMI_ID = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $check1 -Username YOUR_USERNAME -Password YOUR_USERNAME| select-object -ExpandProperty PMI_ID
                            $UpdateQ = @"
UPDATE FLEET.dbo.Preventative
SET Tyre_Check = $line2
where PMI_ID = $PMI_ID
"@
                            Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $UpdateQ -Username YOUR_USERNAME -Password YOUR_PASSWORD
                        }
                    }
                        New-UDInputAction -Toast "Thank you $Check_Type for vehicle ID $Vehicle_ID now completed"
                    } -Validate


            }

        }

        }
    }