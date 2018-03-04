Configuration Provisioner
{
  param (
    [bool] $AttachDisk = $false,
    [bool] $WriteVault = $false,
    [string] $RoleID = "this_is_a_role_id",
    [string] $SecretID = "this_is_a_secret_id"
  )

  Import-DscResource -ModuleName xStorage

  Node "localhost"
  {
    $Disk2PartitionStyle = Get-Disk | ?{ $_.Number -eq 2 } | %{ $_.PartitionStyle }
    if($AttachDisk -and ($Disk2PartitionStyle -eq 'raw'))
    {
      xWaitforDisk Disk2
      {
        DiskId = 2
        RetryIntervalSec = 20
        RetryCount = 30
      }

      xDisk ADDataDisk {
        DiskId = 2
        DriveLetter = "F"
        DependsOn = "[xWaitForDisk]Disk2"
      }
    }
    if($WriteVault)
    {
      $app_json = @{
        "role_id"=$RoleID;
        "secret_id"=$SecretID;
      }

      File hcvConfigFolder
      {
        Type = "Directory"
        Ensure = "Present"
        DestinationPath = "c:\chef\hash\app.json"
      }
      
      Script BatFile
      {
        SetScript = {
          (ConvertTo-Json $app_json) | Set-Content -Path "c:\chef\hash\app.json"  -Encoding UTF8 -Force
        }
        TestScript = {
          if(-not (Test-Path "c:\chef\hash\app.json"))
          {
            return $false
          }
          return ((Get-content "c:\chef\hash\app.json") -join "`n") -eq (ConvertTo-Json $app_json)
        }
        GetScript = { @{BatFileExists = (Test-Path "c:\chef\hash\app.json" )} }
      }

      Script ScriptExample
      {
          SetScript = 
          { 
              $encoding = New-Object System.Text.UTF8Encoding
              [System.IO.File]::WriteAllText("C:\chef\hash\app.json", (ConvertTo-Json $app_json), $encoding)
          }
          TestScript = {
              if(-not (Test-Path "c:\chef\hash\app.json"))
              {
                  return $false
              }
              $jsonOnDisk = ConvertFrom-Json ((Get-content "c:\chef\hash\app.json") -join "`n")
              return ($app_json.role_id -eq $jsonOnDisk.role_id -and $app_json.secret_id -eq $jsonOnDisk.secret_id)
          }
          GetScript = {
              $app_json_exists = (Test-Path "c:\chef\hash\app.json")
              if($app_json_exists)
              {
                  return @{ Result = "" }
              }
              @{ Result = (Get-Content "C:\chef\hash\app.json") } 
          }          
      }
    }

    $date = (Get-Date)
    File timestamp
    {
      Ensure = "Present"
      DestinationPath = "c:\dsclog.txt"
      Contents = "Last DSC converge: $date"
    }
  }
}