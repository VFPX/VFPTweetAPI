* loads framework classes
If Not DBused('metadata')
   If _vfp.StartMode=0
      Cd JustPath(Sys(16,Program(-1)))+'..\data\metadata'
   EndIf
   Open Database metadata.dbc Shared
EndIf

If _vfp.StartMode=0
   Use metadata!paths In Select('paths')
   Select paths
   Scan
      Set Path To (paths.vPath) Additive
   EndScan
EndIf

Use metadata!libsandprgs In Select('libsandprgs')
Select libsandprgs
Scan
   Do Case 
      Case JustExt(libsandprgs.vName) == 'prg'
         Set Procedure To (libsandprgs.vName) Additive 
      Case JustExt(libsandprgs.vName) == 'vcx'
         Set Classlib To (libsandprgs.vName) Additive 
   EndCase
EndScan

Use in Select('paths')
Use in Select('libsandprgs')