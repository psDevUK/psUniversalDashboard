New-UDAuthenticationMethod -Endpoint {
    param([PSCredential]$Credentials)
    Function Test-Credential {
        [OutputType([Bool])]

        Param (
            [Parameter(
                Mandatory = $true,
                ValueFromPipeLine = $true,
                ValueFromPipelineByPropertyName = $true
            )]
            [Alias(
                'PSCredential'
            )]
            [ValidateNotNull()]
            [System.Management.Automation.PSCredential]
            [System.Management.Automation.Credential()]
            $Credential,

            [Parameter()]
            [String]
            $Domain = $Credential.GetNetworkCredential().Domain
        )

        Begin {
            [System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.AccountManagement") |
            Out-Null

            $principalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext(
                [System.DirectoryServices.AccountManagement.ContextType]::Domain, $Domain
            )
        }

        Process {
            foreach ($item in $Credential) {
                $networkCredential = $Credential.GetNetworkCredential()

                Write-Output -InputObject $(
                    $principalContext.ValidateCredentials(
                        $networkCredential.UserName, $networkCredential.Password
                    )
                )
            }
        }
        End {
            $principalContext.Dispose()
        }
    }
    function Get-ADGroupMembers {
        <#
    .SYNOPSIS
	    Return all group members for specified groups.

    .FUNCTIONALITY
        Active Directory

    .DESCRIPTION
	    Return all group members for specified groups.   Requires .NET 3.5, does not require RSAT

    .PARAMETER Group
        One or more Security Groups to enumerate

    .PARAMETER Recurse
	    Whether to recurse groups.  Note that subgroups are NOT returned if this is true, only user accounts

        Default value is $True

    .EXAMPLE
        #Get all group members in Domain Admins or nested subgroups, only include samaccountname property
	    Get-ADGroupMembers "Domain Admins" | Select-Object -ExpandProperty samaccountname

    .EXAMPLE
        #Get members for objects returned by Get-ADGroupMembers
        Get-ADGroupMembers -group "Domain Admins" | Get-Member
    #>
        [cmdletbinding()]
        Param(
            [Parameter(Position = 0, ValueFromPipeline = $true)]
            [string[]]$group = 'Domain Admins',

            [bool]$Recurse = $true
        )

        Begin {
            #Add the .net type
            $type = 'System.DirectoryServices.AccountManagement'
            Try {
                Add-Type -AssemblyName $type -ErrorAction Stop
            }
            Catch {
                Throw "Could not load $type`: Confirm .NET 3.5 or later is installed"
                Break
            }

            #set up context type
            # use the 'Machine' ContextType if you want to retrieve local group members
            # http://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.contexttype.aspx
            $ct = [System.DirectoryServices.AccountManagement.ContextType]::Domain
        }

        Process {
            #List group members
            foreach ($GroupName in $group) {
                Try {
                    $grp = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($ct, $GroupName)

                    #display results or warn if no results
                    if ($grp) {
                        $grp.GetMembers($Recurse)
                    }
                    else {
                        Write-Warning "Could not find group '$GroupName'"
                    }
                }
                Catch {
                    Write-Error "Could not obtain members for $GroupName`: $_"
                    Continue
                }
            }
        }
        End {
            #cleanup
            $ct = $grp = $null
        }
    }
    ### Replace "YOUR_SECURITY_GROUP_NAME with the Active Direcotry Security Group you created for this dashboard
    if ((Test-Credential -Credential $Credentials)) {
        if (Get-ADGroupMembers "YOUR_SECURITY_GROUP_NAME" | Where-Object { $_.SamAccountName -match $Credentials.UserName }) {
            New-UDAuthenticationResult -Success -UserName $Credentials.UserName
        }
    }
    New-UDAuthenticationResult -ErrorMessage "Invalid credentials, or security group issue. Please contact IT if problem persists"
}