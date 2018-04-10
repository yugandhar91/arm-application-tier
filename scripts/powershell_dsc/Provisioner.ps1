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
      File C_Chef
      {
        Type = "Directory"
        Ensure = "Present"
        DestinationPath = "c:\chef"
      }

      File C_Chef_Hash
      {
        Type = "Directory"
        Ensure = "Present"
        DestinationPath = "c:\chef\hash"
      }
      
      $app_json_contents = "{ ```"role_id```":```"$RoleID```", ```"secret_id```":```"$SecretID```" }"
      $SetScript = @"
        `$app_json = "$app_json_contents"
        `$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding `$False
        [System.IO.File]::WriteAllLines("c:\chef\hash\app.json", `$app_json, `$Utf8NoBomEncoding)
"@
      $TestScript = @"
        `$app_json = "$app_json_contents"
        if(-not (Test-Path "c:\chef\hash\app.json"))
        {
          return `$false
        }
        return ((Get-content "c:\chef\hash\app.json") -join '') -eq "$app_json_contents"
"@
      Script BatFile
      {
        SetScript = [Scriptblock]::Create($SetScript)
        TestScript = [Scriptblock]::Create($TestScript)
        GetScript = { @{BatFileExists = (Test-Path "c:\chef\hash\app.json" )} }
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