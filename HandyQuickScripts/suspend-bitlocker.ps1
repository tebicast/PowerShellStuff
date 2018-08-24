##Suspends Bitlocker for 15 reboots, mounts "key" in c: drive
Suspend-BitLocker -MountPoint "C:" -RebootCount 15
##Resumes Bitlocker
Resume-BitLocker -MountPoint "C:"


