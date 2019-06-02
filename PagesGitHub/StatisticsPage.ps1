New-UDPage -Name "Vehicle Statistics" -Icon chart_line -Content {
            $Layout = '{"lg":[{"w":2,"h":5,"x":0,"y":0,"i":"grid-element-c1","moved":false,"static":false},{"w":2,"h":5,"x":2,"y":0,"i":"grid-element-c2","moved":false,"static":false},{"w":2,"h":5,"x":4,"y":0,"i":"grid-element-c3","moved":false,"static":false},{"w":2,"h":4,"x":6,"y":0,"i":"grid-element-c4","moved":false,"static":false},{"w":2,"h":4,"x":8,"y":0,"i":"grid-element-c5","moved":false,"static":false},{"w":2,"h":4,"x":10,"y":0,"i":"grid-element-c6","moved":false,"static":false},{"w":2,"h":5,"x":0,"y":5,"i":"grid-element-c7","moved":false,"static":false},{"w":2,"h":5,"x":2,"y":5,"i":"grid-element-c8","moved":false,"static":false},{"w":2,"h":5,"x":4,"y":5,"i":"grid-element-c9","moved":false,"static":false},{"w":2,"h":5,"x":0,"y":9,"i":"grid-element-c10","moved":false,"static":false},{"w":2,"h":5,"x":2,"y":9,"i":"grid-element-c11","moved":false,"static":false},{"w":2,"h":5,"x":4,"y":9,"i":"grid-element-c12","moved":false,"static":false},{"w":6,"h":10,"x":6,"y":4,"i":"grid-element-chart","moved":false,"static":false}]}'
            New-UDGridLayout -Layout $Layout -Content {
                 New-UDChart -Type Line -Id 'chart' -Title "Week-Ending Recorded Distance" -FontColor "#033584" -Endpoint {
                    if ($Session:Ticker -eq $null) {
                        $Session:Ticker = "1"
                    }
            $MorKquery = @"
SELECT COUNT(Milage) Miles
  FROM [FLEET].[dbo].[Milage]
  WHERE Vehicle_ID = $Session:Ticker
"@
            $gridQ = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $MorKquery -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'Miles'
            if ($gridQ -gt 0) {
                $GridQuery = @"
SELECT convert(varchar,[M].[Recorded_M_date],103) [Date]
      ,[M].[Milage] [Mileage]
  FROM [FLEET].[dbo].[Milage] M
  WHERE M.Vehicle_ID = $Session:Ticker
  ORDER BY M.Recorded_M_date
"@
                $q1 = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $GridQuery -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD'
                $q1 | select-object Date, Mileage | Out-UDChartData -LabelProperty "Date" -DataProperty "Mileage" -Dataset @(
                    New-UDChartDataset -DataProperty "Mileage" -Label "Miles Recorded")
            }
            elseif ($gridQ -eq 0) {
                $GridQuery2 = @"
SELECT convert(varchar,[M].[Recorded_M_date],103) [Date]
      ,[M].[KiloMetres]
  FROM [FLEET].[dbo].[Milage] M
  WHERE M.Vehicle_ID = $Session:Ticker
  ORDER BY M.Recorded_M_date
"@
                $q12 = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $GridQuery2 -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD'
                $q12 | select-object Date, Kilometres | Out-UDChartData -LabelProperty "Date" -DataProperty "Kilometres" -Dataset @(
                    New-UDChartDataset -DataProperty "Kilometres" -Label "Kilometres Recorded")

            }

                    } -AutoRefresh
                New-UDCard -Id "c1" -Title "Vehicle ID" -Endpoint {
                    New-UDTextbox -Placeholder 'Vehicle ID' -Id 'txtTicker' -Icon truck
                    New-UDButton -Id 'btnSearch' -Text 'Search' -Icon search -IconAlignment 'left' -OnClick {
                        $Session:Ticker = (Get-UDElement -Id 'txtTicker').Attributes['value']
                        @("chart","vec","RegNo","c2","c3","c4","c5","c6","c7","c8","c9","c10","c11","c12") | Sync-UDElement
                    }
                }
                New-UDCard -Id "c2" -Title "Registration Number"  -TextSize Large -TextAlignment center -Endpoint {
                    New-UDElement -Tag span -Id "RegNo" -Endpoint { if ($Session:Ticker -eq $null) {
                            $Session:Ticker = "1"
                        }
                        $reg = @"
select UPPER(Registration) Registration
FROM FLEET.dbo.Vehicle
WHERE Vehicle_ID = $Session:Ticker
"@
                        $R = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $reg -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'Registration'
                       New-UDHeading -id vec -Text "$R" -Color 'white' -Size 5
                    }
                }
                  New-UDCounter -Id "c3" -Title "Distance Left" -TextSize Medium  -TextAlignment center -Icon truck_loading  -AutoRefresh -Endpoint {
                    if ($Session:Ticker -eq $null) {
                            $Session:Ticker = "1"
                        }
                        $left2 = @"
Select SUM(Q3.Allowance - Q3.Distance) AS TOGO FROM (
Select CASE WHEN Q2.Miles IS NULL THEN Q2.KiloMetres
WHEN Q2.KiloMetres IS NULL THEN Q2.Miles
END AS Distance
,Q2.Allowance
 FROM (
select SUM(M.Milage) Miles
,SUM(M.Kilometres) KiloMetres
,A.Milage_Allowance as Allowance
FROM FLEET.dbo.Milage M INNER JOIN
FLEET.dbo.AgreementRental A ON M.Vehicle_ID = A.Vehicle_ID
WHERE M.Vehicle_ID = $Session:Ticker
GROUP BY A.Milage_Allowance
)Q2 ) Q3
"@
                        $R87 = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $left2 -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'TOGO'
                        $R87
                    }
                New-UDCounter -Id "c4" -Title "Total Distance" -TextSize Medium -TextAlignment center -Icon running  -AutoRefresh -Endpoint {
 if ($Session:Ticker -eq $null) {
$Session:Ticker = "1"
                        }
                        $distance = @"
Select CASE WHEN Q2.Miles IS NULL THEN Q2.KiloMetres
WHEN Q2.KiloMetres IS NULL THEN Q2.Miles
END AS Distance
 FROM (
select SUM(Milage) Miles
,SUM(Kilometres) KiloMetres
FROM FLEET.dbo.Milage
WHERE Vehicle_ID = $Session:Ticker
) Q2
"@
                        $R1 = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $distance -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'Distance'
                        $R1
                    }
               New-UDCounter -Id "c5" -Format '$0,0.00' -Title "Total Costs" -TextSize Medium -TextAlignment center -Icon money  -AutoRefresh -Endpoint {
                    if ($Session:Ticker -eq $null) {
                            $Session:Ticker = "1"
                        }
                        $costs = @"
Select SUM(Damage + Running) TOTAL
FROM (
SELECT D.Vehicle_ID
      ,SUM(D.Dam_Cost) Damage
      ,SUM(R.Total_Amount) Running
  FROM [FLEET].[dbo].[Damage] D LEFT JOIN
  FLEET.dbo.RunningCosts R ON D.Vehicle_ID = R.Vehicle_ID
  WHERE D.Vehicle_ID = $Session:Ticker
  GROUP BY D.Vehicle_ID
  ) Q2
"@
                        $R2 = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $costs -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'TOTAL'
                        $R2
                    }
                New-UDCounter -Id "c6" -Title "Next MOT Due" -TextSize Medium  -TextAlignment center -Icon calendar_day -AutoRefresh -Endpoint {
                    if ($Session:Ticker -eq $null) {
                            $Session:Ticker = "1"
                        }
            $costs2 = @"
                        Select * FROM (
Select  DATEDIFF(DAY,GETDATE(), Q2.NewMOT) DaysLeft
   FROM (
  SELECT DATEADD(year, 1,MOT) NewMOT
  FROM [FLEET].[dbo].[Preventative]
  WHERe Vehicle_ID = $Session:Ticker
  ) as Q2
  ) as Q3 WHERE Q3.DaysLeft IS NOT NULL
"@
                        $R7 = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $costs2 -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'DaysLeft'
                        $R7
                    }
                        New-UDCounter -Id "c7" -Title "Next Loler Check" -TextSize Medium  -TextAlignment center -Icon truck_monster  -AutoRefresh -Endpoint {
                    if ($Session:Ticker -eq $null) {
                            $Session:Ticker = "1"
                        }
            $loler = @"
Select * FROM (
  Select  DATEDIFF(DAY,GETDATE(), Q2.NewLoler) DaysLeft
   FROM (
  SELECT DATEADD(year, 1,Loler_Service) NewLoler
  FROM [FLEET].[dbo].[Preventative]
  WHERe Vehicle_ID = $Session:Ticker
  ) as Q2
  ) as Q3 WHERE Q3.DaysLeft IS NOT NULL
"@
                        $R77= Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $loler -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'DaysLeft'
                        $R77
                    }
                      New-UDCounter -Id "c8" -Title "Next Tacho Service" -TextSize Medium  -TextAlignment center -Icon tachometer  -AutoRefresh -Endpoint {
                    if ($Session:Ticker -eq $null) {
                            $Session:Ticker = "1"
                        }
            $tacho = @"
Select * FROM (
  Select  DATEDIFF(DAY,GETDATE(), Q2.NewTacho) DaysLeft
   FROM (
  SELECT DATEADD(year, 2,Tacho_Calibration) NewTacho
  FROM [FLEET].[dbo].[Preventative]
  WHERe Vehicle_ID = $Session:Ticker
  ) as Q2
  ) as Q3 WHERE Q3.DaysLeft IS NOT NULL
"@
                        $R777= Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $tacho -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'DaysLeft'
                        $R777
                    }
                         New-UDCounter -Id "c9" -Title "Next Vehicle Service" -TextSize Medium  -TextAlignment center -Icon truck_pickup  -AutoRefresh -Endpoint {
                    if ($Session:Ticker -eq $null) {
                            $Session:Ticker = "1"
                        }
            $service = @"
Select * FROM (
  Select  DATEDIFF(DAY,GETDATE(), Q2.NewService) DaysLeft
   FROM (
  SELECT DATEADD(week, 6,Vehicle_Service) NewService
  FROM [FLEET].[dbo].[Preventative]
  WHERe Vehicle_ID = $Session:Ticker
  ) as Q2
  ) as Q3 WHERE Q3.DaysLeft IS NOT NULL
"@
                        $R77777= Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $service -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'DaysLeft'
                        $R77777
                    }
                          New-UDCounter -Id "c10" -Title "Next Tyre Checks" -TextSize Medium  -TextAlignment center -Icon wrench  -AutoRefresh -Endpoint {
                    if ($Session:Ticker -eq $null) {
                            $Session:Ticker = "1"
                        }
            $tyre = @"
Select * FROM (
  Select  DATEDIFF(DAY,GETDATE(), Q2.NewTyre) DaysLeft
   FROM (
  SELECT DATEADD(week, 4,Tyre_Check) NewTyre
  FROM [FLEET].[dbo].[Preventative]
  WHERe Vehicle_ID = $Session:Ticker
  ) as Q2
  ) as Q3 WHERE Q3.DaysLeft IS NOT NULL
"@
                        $R777777= Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $tyre -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'DaysLeft'
                        $R777777
                    }
                        New-UDCounter -Id "c11" -Title "Next Fridge Service" -TextSize Medium  -TextAlignment center -Icon truck_moving  -AutoRefresh -Endpoint {
                    if ($Session:Ticker -eq $null) {
                            $Session:Ticker = "1"
                        }
            $fridge = @"
Select * FROM (
  Select  DATEDIFF(DAY,GETDATE(), Q2.NewFridge) DaysLeft
   FROM (
  SELECT DATEADD(month, 6,Fridge_Service) NewFridge
  FROM [FLEET].[dbo].[Preventative]
  WHERe Vehicle_ID = $Session:Ticker
  ) as Q2
  ) as Q3 WHERE Q3.DaysLeft IS NOT NULL
"@
                        $R7777777= Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $fridge -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'DaysLeft'
                        $R7777777
                    }
                                       New-UDCounter -Id "c12" -Title "Contract Expires In" -TextSize Medium  -TextAlignment center -Icon temperature_high  -AutoRefresh -Endpoint {
                    if ($Session:Ticker -eq $null) {
                            $Session:Ticker = "1"
                        }
                        $contract = @"
   Select DATEDIFF(DAY,GETDATE(), End_Date) DaysLeft FROM FLEET.dbo.AgreementRental
  WHERe Vehicle_ID = $Session:Ticker
"@
                        $R77777777 = Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $contract -Username 'YOUR_USERNAME' -Password 'YOUR_PASSWORD' | select-object -ExpandProperty 'DaysLeft'
                        $R77777777
                    }
            }

}