* WinAPI declarations of API functions used in other libraries

Function CoCreateGuid(tcBuffer)
   Declare INTEGER CoCreateGuid In Ole32;
      STRING @ pguid

   Return CoCreateGuid(@tcBuffer)
Endfunc

Function StringFromGUID2(tcGUID, tcBuffer, tnMaxlen)
   Declare INTEGER StringFromGUID2 In Ole32;
      STRING    rguid, ;
      STRING  @ lpsz,  ;
      INTEGER   cchMax

   Return StringFromGUID2(tcGUID, @tcBuffer, tnMaxlen)
EndFunc

Function CLSIDFromString(tcGUID, tcCLSID)
   DECLARE INTEGER CLSIDFromString IN Ole32;
      STRING   lpsz,  ;
      STRING @ pclsid
   Return CLSIDFromString(tcGUID, @tcCLSID)
EndFunc

Function ShellExecute(tnWinHandle, tcOperation, tcFilename, tcParameters, tcDirectory, tnShowWindow)
   Declare INTEGER ShellExecute In Shell32;
      INTEGER nWinHandle,  ;
      STRING  cOperation,  ;
      STRING  cFileName,   ;
      STRING  cParameters, ;
      STRING  cDirectory,  ;
      INTEGER nShowWindow

   Return ShellExecute(tnWinHandle, tcOperation, tcFilename, tcParameters, tcDirectory, tnShowWindow)
Endfunc

Function GetTimeZoneInformation(tcTimeZoneStruct)
   Declare INTEGER GetTimeZoneInformation In Kernel32 ;
      STRING @ TimeZoneStruct

   Return GetTimeZoneInformation(tcTimeZoneStruct)
Endfunc

Function InternetGetConnectedState(tcFlags, tiReserved)
   Declare SHORT InternetGetConnectedState In wininet;
      INTEGER @ lpdwFlags, ;
      INTEGER   dwReserved

   Return InternetGetConnectedState(tcFlags, tiReserved)
Endfunc

Function SHGetFolderPath(tnHwndOwner, tnFolder, tnToken, tnFlags, tcPath)
   Declare SHORT SHGetFolderPath In Shell32;
      INTEGER   hwndOwner, ;
      INTEGER   nFolder,   ;
      INTEGER   hToken,    ;
      INTEGER   dwFlags,   ;
      STRING  @ pszPath

   Return SHGetFolderPath(tnHwndOwner, tnFolder, tnToken, tnFlags, @tcPath)
EndFunc

Function SHGetKnownFolderPath(tcKnownFolderID, tnFlags, tnToken, tnPtrPath)
   Declare SHORT SHGetKnownFolderPath In Shell32;
      STRING    rfid,      ;
      INTEGER   dwFlags,   ;
      INTEGER   hToken,    ;
      INTEGER @ pszPath
      
   Return SHGetKnownFolderPath(tcKnownFolderID, tnFlags, tnToken, @tnPtrPath)
EndFunc

Function CoTaskMemFree(tnPtr)
   Declare CoTaskMemFree in Ole32 ;
      INTEGER hMem
   CoTaskMemFree(tnPtr)
EndFunc
 
Function GetLastError()
   Declare INTEGER GetLastError In Kernel32
   
   Return GetLastError()
Endfunc
