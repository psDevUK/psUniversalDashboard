New-UDPage -Name "Vehicle Costs" -Icon pound_sign -Content {
    New-UDTabContainer -Tabs {
        New-UDTab -Text "Maintenence Costs" -Content {
            $Layout = '{"lg":[{"w":4,"h":18,"x":0,"y":0,"i":"grid-element-grid22","moved":false,"static":false},{"w":8,"h":18,"x":4,"y":0,"i":"grid-element-rightside1a","moved":false,"static":false}]}'
            New-UDGridLayout -Layout $Layout -Content {
                    New-UDGrid -Id "grid22" -Title "Active Vehicles" -Headers @("Vehicle_ID", "Registration") -Properties @("Vehicle_ID", "Registration") -DefaultSortColumn "Vehicle_ID" -PageSize 10  -Endpoint {
                        $Cache:ActiveVehicles2a | Select-Object "Vehicle_ID", "Registration" | Out-UDGridData
                    }
                    New-UDInput -Id "rightside1a" -Title "Vehicle Maintenance Costs" -Endpoint {
                        param(
                            [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("You need to enter a valid vehicle ID.")][ValidateLength(1, 2)][string]$VehicleID,
                            [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("The date format must be YYYY-MM-DD format.")][ValidatePattern('[0-9]{4}-[0-9]{2}-[0-9]{2}')][string]$DateLogged,
                            [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("You need to provide more information.")][ValidateLength(10, 200)][string]$InformationOnCost,
                            [Parameter(HelpMessage = "Type Of Cost")]
                            [ValidateSet("Maintenance", "M.O.T", "Repair")]$RepairType,
                            [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("You must type in something.")][string]$TotalValue

                        )
                        if (-Not(Test-Path $Root\$User)) { mkdir $Root\$User }
                        if (Test-path $Root\$User\vehcost.txt)
                        { Remove-Item -Path "$Root\$User\vehcost.txt" }
                        $VehicleID | Out-File (Join-Path $Root\$User "vehcost.txt")
                        $DateLogged | Out-File (Join-Path $Root\$User "vehcost.txt") -append
                        $InformationOnCost | Out-File (Join-Path $Root\$User "vehcost.txt") -Append
                        $RepairType | Out-File (Join-Path $Root\$User "vehcost.txt") -Append
                        $TotalValue | Out-File (Join-Path $Root\$User "vehcost.txt") -Append

                        $file = get-content $Root\$User\vehcost.txt
                        $line0 = $file[0]
                        $line1 = $file[1]
                        $line2 = $file[2]
                        $line3 = $file[3]
                        $line4 = $file[4]

                        ###Change output of Text file into something that can be imported into the SQL database.
                        $line1 = "'$line1'"
                        $line2 = "'$line2'"
                        $line3 = if ($line3 -match 'Maintenance') { $line3 -replace 'Maintenance', "1" }elseif ($line3 -match "M.O.T") { $line3 -replace "M.O.T", "2" }elseif ($line3 -match "Repair") { $line3 -replace "Repair", "3" }
                        $line4 = "'$line4'"
                        $vals = $line0 + "," + $line1 + "," + $line2 + "," + $line3 + "," + $line4
                        $costUpdate = @"
INSERT INTO FLEET.dbo.RunningCosts (Vehicle_ID,Recorded_Date,Cost_Reason,Repair_ID,Total_Amount)
VALUES ($vals)
"@
                        Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $costUpdate -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD'


                        New-UDInputAction -Toast "Thanks for completing the vehicle costs of vehicle ID:-$VehicleID" -Duration 3000
                    } -Validate

            }

        }
        New-UDTab -Text "Report Damage Costs" -Content {
            $Layout = '{"lg":[{"w":4,"h":18,"x":0,"y":0,"i":"grid-element-grid33","moved":false,"static":false},{"w":8,"h":18,"x":4,"y":0,"i":"grid-element-rightside2a","moved":false,"static":false}]}'
            New-UDGridLayout -Layout $Layout -Content {

                    New-UDGrid  -Id "grid33" -Title "Active Vehicles" -Headers @("Vehicle_ID", "Registration") -Properties @("Vehicle_ID", "Registration") -DefaultSortColumn "Vehicle_ID" -PageSize 10  -Endpoint {
                        $Cache:ActiveVehicles2a | Select-Object Vehicle_ID,Registration | Out-UDGridData
                    }


                    New-UDInput -Id "rightside2a" -Title "Vehicle Damage Costs" -Endpoint {
                        param(
                            [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("You need to enter a valid vehicle ID.")][ValidateLength(1, 2)][string]$Vehicle_ID,
                            [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("You need to provide more information.")][ValidateLength(10, 200)][string]$InformationOnDamage,
                            [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("The date format must be YYYY-MM-DD format.")][ValidatePattern('[0-9]{4}-[0-9]{2}-[0-9]{2}')][string]$DateRecorded,
                            [Parameter(Mandatory)][UniversalDashboard.ValidationErrorMessage("You must type in something.")][string]$TotalCost

                        )
                        if (-Not(Test-Path $Root\$User)) { mkdir $Root\$User }
                        if (Test-path $Root\$User\damvehcost.txt)
                        { Remove-Item -Path "$Root\$User\damvehcost.txt" }
                        $Vehicle_ID | Out-File (Join-Path $Root\$User "damvehcost.txt")
                        $InformationOnDamage | Out-File (Join-Path $Root\$User "damvehcost.txt") -append
                        $DateRecorded | Out-File (Join-Path $Root\$User "damvehcost.txt") -Append
                        $TotalCost | Out-File (Join-Path $Root\$User "damvehcost.txt") -Append

                        $file = get-content $Root\$User\damvehcost.txt
                        $line0 = $file[0]
                        $line1 = $file[1]
                        $line2 = $file[2]
                        $line3 = $file[3]


                        ###Change output of Text file into something that can be imported into the SQL database.
                        $line1 = "'$line1'"
                        $line2 = "'$line2'"
                        $line3 = "'$line3'"
                        $vals = $line0 + "," + $line1 + "," + $line2 + "," + $line3
                        $DamUpdate = @"
INSERT INTO FLEET.dbo.Damage (Vehicle_ID,Reason,Dam_Date,Dam_Cost)
VALUES ($vals)
"@
                        Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $DamUpdate -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD'


                        New-UDInputAction -Toast "Thanks for completing the damage costs of vehicle ID:-$Vehicle_ID" -Duration 3000
                    } -Validate

            }
        }
        New-UDTab -Text "Running Costs" -Content {
            $Layout = '{"lg":[{"w":2,"h":6,"x":0,"y":0,"i":"grid-element-card1","moved":false,"static":false},{"w":2,"h":2,"x":0,"y":6,"i":"grid-element-RegNo2","moved":false,"static":false},{"w":2,"h":4,"x":2,"y":0,"i":"grid-element-card3","moved":false,"static":false},{"w":2,"h":4,"x":4,"y":0,"i":"grid-element-card4","moved":false,"static":false},{"w":2,"h":4,"x":6,"y":0,"i":"grid-element-card5","moved":false,"static":false},{"w":2,"h":4,"x":8,"y":0,"i":"grid-element-card6","moved":false,"static":false},{"w":2,"h":4,"x":8,"y":15,"i":"grid-element-card6","moved":false,"static":false},{"w":2,"h":4,"x":10,"y":0,"i":"grid-element-card7","moved":false,"static":false},{"w":2,"h":4,"x":10,"y":4,"i":"grid-element-card8","moved":false,"static":false},{"w":2,"h":4,"x":10,"y":8,"i":"grid-element-card9","moved":false,"static":false},{"w":2,"h":3,"x":10,"y":12,"i":"grid-element-icon","moved":false,"static":false},{"w":8,"h":14,"x":2,"y":4,"i":"grid-element-grid","moved":false,"static":false}]}'
            New-UDGridLayout -Layout $Layout -Content {

                New-UDCard -Id "card1" -Title "Vehicle ID" -Endpoint {
                    New-UDTextbox -Placeholder 'Vehicle ID' -Id 'txtTicker2' -Icon truck
                    New-UDButton -Id 'btnSearch2' -Text 'Find' -FontColor '#FFFFFF' -Icon search -IconAlignment 'right' -OnClick {
                        $Session:Ticker2 = (Get-UDElement -Id 'txtTicker2').Attributes['value']
                        @("RegNo2", "card3", "card4", "card5", "card6", "card7", "card8", "card9", "grid" ) | Sync-UDElement
                    }
                }
                New-UDElement -Tag span -Id "RegNo2" -Endpoint { if ($Session:Ticker2 -eq $null) {
                        $Session:Ticker2 = "1"
                    }
                    $reg2 = @"
select UPPER(Registration) Registration
FROM FLEET.dbo.Vehicle
WHERE Vehicle_ID = $Session:Ticker2
"@
                    $R2 = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $reg2 -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'Registration'
                    New-UDHeading -id vec2 -Text "$R2" -Color 'black' -Size 4
                }


                New-UDCounter -Id "card3" -Format '$0,0.00' -Title "Daily Rent" -Icon money_bill_alt -TextSize Medium  -TextAlignment center  -AutoRefresh -Endpoint {
                    if ($Session:Ticker2 -eq $null) {
                        $Session:Ticker2 = "1"
                    }
                    $dailyQ = @"
select ROUND(SUM(((Rental_Cost * 12))/52)/7,2) Daily
FROM FLEET.dbo.AgreementRental
WHERE Vehicle_ID = $Session:Ticker2
"@
                    $R3 = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $dailyQ -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'Daily'
                    $R3
                }
                New-UDCounter -Id "card4" -Format '$0,0.00' -Title "Weekly Rent" -Icon money_bill_wave -TextSize Medium  -TextAlignment center  -AutoRefresh -Endpoint {
                    if ($Session:Ticker2 -eq $null) {
                        $Session:Ticker2 = "1"
                    }
                    $weeklyQ = @"
select ROUND(SUM(((Rental_Cost * 12))/52),2) Weekly
FROM FLEET.dbo.AgreementRental
WHERE Vehicle_ID = $Session:Ticker2
"@
                    $R33 = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $weeklyQ -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'Weekly'
                    $R33
                }
                New-UDCounter -Id "card5" -Format '$0,0.00' -Title "Monthly Rent" -Icon money_bill_wave_alt -TextSize Medium  -TextAlignment center  -AutoRefresh -Endpoint {
                    if ($Session:Ticker2 -eq $null) {
                        $Session:Ticker2 = "1"
                    }
                    $monthlyQ = @"
select SUM(Rental_Cost) Monthly
FROM FLEET.dbo.AgreementRental
WHERE Vehicle_ID = $Session:Ticker2
"@
                    $R44 = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $monthlyQ -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'Monthly'
                    $R44
                }
                New-UDCounter -Id "card6" -Format '$0,0.00' -Title "Yearly Rent" -Icon money -TextSize Medium  -TextAlignment center  -AutoRefresh -Endpoint {
                    if ($Session:Ticker2 -eq $null) {
                        $Session:Ticker2 = "1"
                    }
                    $yearlyQ = @"
select ROUND(SUM(Rental_Cost * 12),2) Yearly
FROM FLEET.dbo.AgreementRental
WHERE Vehicle_ID = $Session:Ticker2
"@
                    $R55 = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $yearlyQ -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'Yearly'
                    $R55
                }
                New-UDCounter -Id "card7" -Format '$0,0.00' -Title "Maintence" -Icon tools  -TextSize Medium  -TextAlignment center  -AutoRefresh -Endpoint {
                    if ($Session:Ticker2 -eq $null) {
                        $Session:Ticker2 = "1"
                    }
                    $runQ = @"
SELECT SUM(Total_Amount) Cost
  FROM [FLEET].[dbo].[RunningCosts]
WHERE Vehicle_ID = $Session:Ticker2
"@
                    $R66 = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $runQ -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'Cost'
                    $R66
                }
                New-UDCounter -Id "card8" -Format '$0,0.00' -Title "Damage" -Icon first_aid -TextSize Medium  -TextAlignment center  -AutoRefresh -Endpoint {
                    if ($Session:Ticker2 -eq $null) {
                        $Session:Ticker2 = "1"
                    }
                    $damQ = @"
SELECT SUM([Dam_Cost]) Amount
  FROM [FLEET].[dbo].[Damage]
WHERE Vehicle_ID = $Session:Ticker2
"@
                    $R123 = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $damQ -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'Amount'
                    $R123
                }
                New-UDCounter -Id "card9" -Format '$0,0.00' -Title "Rent Paid" -Icon money_bill -TextSize Medium  -TextAlignment center  -AutoRefresh -Endpoint {
                    if ($Session:Ticker2 -eq $null) {
                        $Session:Ticker2 = "1"
                    }
                    $rentQ = @"
SELECT SUM(Q4.Months * Q4.Rental_Cost) RentPaid FROM (
SELECT DATEDIFF(month,[Start_Date],GETDATE()) months
,Rental_Cost
  FROM [FLEET].[dbo].[AgreementRental]
  WHERE Vehicle_ID = $Session:Ticker2
  ) Q4
"@
                    $R66 = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $rentQ -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'RentPaid'
                    $R66
                }
New-UDCard -Id "icon" -BackgroundColor "#ffffff" -Endpoint{
                New-UDIcon -Color "#2ad639" -Icon android -Size "5x"
}
                New-UDChart -Id "grid" -Title "Statistics On Vehicle" -Type Bar -AutoRefresh -Endpoint {
                    if ($Session:Ticker2 -eq $null) {
                        $Session:Ticker2 = "1"
                    }
                    $VehStat = @"
Select UPPER(Q2.Registration) Registration
,SUM(Q2.Months * Q2.Rental) RentPaid
,SUM(Q2.DAMAGE) Damage
,SUM(Q2.Maintenance) Maintenance
 FROM (
Select V.Registration
,DATEDIFF(month,AG.[Start_Date],GETDATE()) months
,SUM(AG.Rental_Cost)Rental
,SUM(D.Dam_Cost) DAMAGE
,SUM(R.Total_Amount) Maintenance
FROM FLEET.dbo.Vehicle V LEFT JOIN
AgreementRental AG ON V.Vehicle_ID = AG.Vehicle_ID LEFT JOIN
Damage D ON V.Vehicle_ID = D.Vehicle_ID LEFT JOIN
RunningCosts R ON V.Vehicle_ID = R.Vehicle_ID
WHERE V.Vehicle_ID = $Session:Ticker2
GROUP BY V.Registration,AG.[Start_Date]
) Q2
GROUP BY Q2.Registration
"@
                    $ResultsV = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $VehStat -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD'
                    $ResultsV | ForEach-Object {
                        [PSCustomObject]@{ Registration = $_.Registration;
                            Damage                      = $_.Damage;
                            Maintenance                 = $_.Maintenance;
                            Rent                        = $_.RentPaid;
                        } } | Out-UDChartData -LabelProperty "Registration" -Dataset @(
                        New-UDChartDataset -DataProperty "Damage" -Label "Damage" -BackgroundColor 'red' -HoverBackgroundColor '#c52705'
                        New-UDChartDataset -DataProperty "Maintenance" -Label "Maintenance" -BackgroundColor 'yellow' -HoverBackgroundColor '#eae600'
                        New-UDChartDataset -DataProperty "Rent" -Label "Rent" -BackgroundColor 'green' -HoverBackgroundColor '#047302'
                    )
                }


            }

        }
        New-UDTab -Text "View Damage Costs" -Content {
            $Layout = '{"lg":[{"w":1,"h":3,"x":0,"y":0,"i":"grid-element-av1","moved":false,"static":false},{"w":10,"h":16,"x":1,"y":0,"i":"grid-element-mainc","moved":false,"static":false}]}'
            New-UDGridLayout -Layout $Layout -Content {

                New-UDMuAvatar -Id "av1" -Image "https://live.staticflickr.com/976/41988835802_1e9408fdd5_b.jpg" -Style @{width = 80; height = 80 }
                    New-UDGrid -Id "mainc" -Title "Damaged Vehicle Grid" -Headers @("Vehicle_ID", "Registration", "DepotName", "Recorded", "Cost", "Information") -Properties @("Vehicle_ID", "Registration", "DepotName", "Recorded", "Cost", "Information") -Endpoint {
                        $DamQ = @"
SELECT V.[Vehicle_ID]
      ,UPPER(V.[Registration]) Registration
      ,D.DepotName
      ,CONVERT(varchar,DAM.Dam_Date,103) Recorded
      ,DAM.Dam_Cost Cost
      ,DAM.Reason
  FROM [FLEET].[dbo].[Vehicle] V INNER JOIN
  FLEET.dbo.Damage DAM ON V.Vehicle_ID = DAM.Vehicle_ID INNER JOIN
  FLEET.dbo.Depot D ON V.Depot_ID = D.Depot_ID
"@
                        $DamData = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $DamQ -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD'

                        $DamData | ForEach-Object {
                            [PSCustomObject]@{
                                Vehicle_ID   = $_.Vehicle_ID
                                Registration = $_.Registration
                                DepotName    = $_.DepotName
                                Recorded     = $_.Recorded
                                Cost         = $_.Cost
                                Information  = $_.Reason
                            }
                        } | Out-UDGridData
                    } -AutoRefresh -RefreshInterval 20

            }

        }
        New-UDTab -Text "View Maintenance Costs" -Content {
            $Layout = '{"lg":[{"w":1,"h":3,"x":0,"y":0,"i":"grid-element-av11a","moved":false,"static":false},{"w":10,"h":16,"x":1,"y":0,"i":"grid-element-mainc1","moved":false,"static":false}]}'
            New-UDGridLayout -Layout $Layout -Content {

                New-UDMuAvatar -Id "av11a" -Image "https://www.fueloyal.com/wp-content/uploads/2016/03/Truck-Maintenance.jpg" -Style @{width = 80; height = 80 }
                    New-UDGrid -Id "mainc1" -Title "Maintenance Vehicle Grid" -Headers @("Vehicle_ID", "Registration", "DepotName", "RepairType", "Recorded", "Cost", "Information") -Properties @("Vehicle_ID", "Registration", "DepotName", "RepairType", "Recorded", "Cost", "Information") -Endpoint {
                        $MaintQ = @"
SELECT RC.[Vehicle_ID]
	  ,UPPER(V.Registration) Registration
	  ,D.DepotName
	  ,R.RepairType
      ,CONVERT(varchar,RC.[Recorded_Date],103) Recorded
      ,RC.[Cost_Reason] Reason
      ,RC.[Total_Amount] Cost
  FROM [FLEET].[dbo].[RunningCosts] RC INNER JOIN
  FLEET.dbo.Repair R ON RC.Repair_ID = R.Repair_ID INNER JOIN
  FLEET.dbo.Vehicle V ON RC.Vehicle_ID = V.Vehicle_ID INNER JOIN
  FLEET.dbo.Depot D ON V.Depot_ID = D.Depot_ID
"@
                        $MaintData = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $MaintQ -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD'

                        $MaintData | ForEach-Object {
                            [PSCustomObject]@{
                                Vehicle_ID           = $_.Vehicle_ID
                                Registration = $_.Registration
                                DepotName    = $_.DepotName
                                RepairType   = $_.RepairType
                                Recorded     = $_.Recorded
                                Cost         = $_.Cost
                                Information       = $_.Reason


                            }
                        } | Out-UDGridData
                    } -AutoRefresh -RefreshInterval 20

            }

        }
}
    }


