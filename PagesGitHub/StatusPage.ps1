New-UDPage -Name "Vehicle Status" -Icon truck -Content {
    New-UDTabContainer -Tabs {
        New-UDTab -Text "List Active Vehicles" -Content {
            New-UDColumn -SmallSize 12 -MediumSize 12 -LargeSize 12 {

                New-UDGrid -Title "Showing All Active Vehicles In The Database" -Headers @("Vehicle_ID", "Agreement", "Registration", "Make", "Weight", "StatusName", "EngineType", "DepotName", "Round_Name", "Active") -Properties @("Vehicle_ID", "Agreement", "Registration", "Make", "Weight", "StatusName", "EngineType", "DepotName", "Round_Name", "Active") -DefaultSortColumn "Vehicle_ID" -PageSize 15  -Endpoint {
                    $Cache:ActiveV | Select-Object "Vehicle_ID", "Agreement", "Registration", "Make", "Weight", "StatusName", "EngineType", "DepotName", "Round_Name", "Active" | Out-UDGridData
                } -AutoRefresh -RefreshInterval 35
            }
        }
        New-UDTab -Text "List Inactive Vehicles" -Content {
            New-UDColumn -SmallSize 12 -MediumSize 12 -LargeSize 12 {

                New-UDGrid -Title "Showing All Inactive Vehicles In The Database" -Headers @("Vehicle_ID", "Agreement", "Registration", "Make", "Weight", "StatusName", "EngineType", "DepotName", "Round_Name", "Active") -Properties @("Vehicle_ID", "Agreement", "Registration", "Make", "Weight", "StatusName", "EngineType", "DepotName", "Round_Name", "Active") -DefaultSortColumn "Vehicle_ID" -PageSize 7  -Endpoint {
                    $Cache:UNActiveV | Select-Object "Vehicle_ID", "Agreement", "Registration", "Make", "Weight", "StatusName", "EngineType", "DepotName", "Round_Name", "Active" | Out-UDGridData
                } -AutoRefresh -RefreshInterval 35
            }

        }
        New-UDTab -Text "Change Status Of Vehicle" -Content {
            $Layout = '{"lg":[{"w":6,"h":16,"x":0,"y":0,"i":"grid-element-left12","moved":false,"static":false},{"w":3,"h":14,"x":6,"y":0,"i":"grid-element-middle1","moved":false,"static":false},{"w":3,"h":14,"x":9,"y":0,"i":"grid-element-right12ab","moved":false,"static":false}]}'

            New-UDGridLayout -Layout $Layout -Content {
                   New-UDGrid -Id "left12" -Title "Showing All Vehicles" -Headers @("Vehicle_ID", "Agreement", "Registration", "EngineType", "Status", "Active") -Properties @("Vehicle_ID", "Agreement", "Registration", "EngineType", "Status", "Active") -DefaultSortColumn "Vehicle_ID" -PageSize 12 -Endpoint {
                        $Cache:StatusChange | Select-Object "Vehicle_ID", "Agreement", "Registration", "EngineType", "Status", "Active" | Out-UDGridData
                    } -AutoRefresh -RefreshInterval 15

                    New-UDInput -Id "middle1" -Title "Remove A Vehicle" -Content {
                        New-UDInputField -Type 'textbox' -Name 'Vehicle_ID1a' -Placeholder 'Enter the vehicle ID'
                        New-UDInputField -Type 'checkbox' -Name 'Remove' -Placeholder "Remove Vehicle"
                        New-UDInputField -Type 'checkbox' -Name 'Keep' -Placeholder "Keep Vehicle"
                    } -Endpoint {
                        param($Vehicle_ID1a, $Remove,$Keep)
                        if ($Remove -eq $true){$RemoveKeep = 2}
                        elseif ($Keep -eq $true) {$RemoveKeep = 1}
                        $statQuery2 = @"
UPDATE FLEET.dbo.Vehicle
SET Active_ID = $RemoveKeep
WHERE Vehicle_ID = $Vehicle_ID1a
"@
                        Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $statQuery2 -Username YOURUSERNAME -Password YOURPASSWORD
                        New-UDInputAction -Toast "Vehicle ID $Vehicle_ID1a has now been updated." -Duration 3000
                    }

                    New-UDInput -Id "right12ab" -Title "Change Vehicle Status" -Content {
                        New-UDInputField -Type 'textbox' -Name 'Vehicle_ID3a' -Placeholder 'Enter the vehicle ID'
                        New-UDInputField -Type 'radioButtons' -Name 'ChangeStatus2as' -Placeholder @("Active", "Spare", "Off Road", "Repair") -Values @("5", "6", "7", "8")

                    } -Endpoint {
                        param($Vehicle_ID3a, $ChangeStatus2as)

                        $statQuery = @"
UPDATE FLEET.dbo.Vehicle
SET Status_ID = $ChangeStatus2as
WHERE Vehicle_ID = $Vehicle_ID3a
"@

                        Invoke-Sqlcmd2 -ServerInstance YOUR_SQL_SERVER -Database FLEET -Query $statQuery -Username YOUR_USERNAME -Password YOUR_PASSWORD

                        New-UDInputAction -Toast "Vehicle ID $Vehicle_ID3a has now been updated." -Duration 3000
                    }


            }
        }
    }
}