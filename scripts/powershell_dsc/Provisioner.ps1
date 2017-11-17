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
    if($AttachDisk)
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
        DestinationPath = "c:\chef\hash"
      }

      File appJson
      {
        Ensure = "Present"
        DestinationPath = "c:\chef\hash\app.json"
        Contents = (ConvertTo-Json $app_json)
      }
    }
  }
}