Configuration Provisioner
{
  param (
    [bool] $AttachDisk = $false
  )
  Import-DscResource -ModuleName xStorage
  
  if($AttachDisk)
  {
    Node "localhost"
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
  }
}