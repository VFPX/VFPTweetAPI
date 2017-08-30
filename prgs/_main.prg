Clear All
CLEAR
ON SHUTDOWN Quit

If _vfp.StartMode=0
   Cd Justpath(Sys(16,0))
Endif
Do _loader

LOCAL loMainform
loMainform = CREATEOBJECT("frmAPITest")
loMainform.Show()

READ EVENTS
