Configuration AttachedDisk
{
  Import-DscResource -ModuleName xStorage

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