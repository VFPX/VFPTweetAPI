* libFileSystem
* created 2009/11/02 by Olaf Doschke - mailto:olaf.doschke@googlemail.com

#Define CSIDL_COMMON_APPDATA 0x0023
#Define CSIDL_LOCAL_APPDATA 0x001C
#Define SHGFP_TYPE_CURRENT 0
#Define SHGFP_TYPE_DEFAULT 1

#Define FOLDERID_LocalAppData '{F1B32785-6FBA-4FCF-9D55-7B8E7F157091}'
#Define FOLDERID_ProgramData  '{62AB5D82-FDC1-4DC3-A9DD-070D1D495D97}'

Define Class pakFileSystem As Package
   * compilation of file system functions
   IsAbstract    = .F.

   Procedure Init()
      Declare SHORT SHGetFolderPath In Shell32;
         INTEGER   hwndOwner, ;
         INTEGER   nFolder,   ;
         INTEGER   hToken,    ;
         INTEGER   dwFlags,   ;
         STRING  @ pszPath

      If Os(3)>="6" && since Vista
         Declare Integer CLSIDFromString In Ole32;
            STRING    lpsz,      ;
            STRING  @ pclsid

         Declare SHORT SHGetKnownFolderPath In Shell32;
            STRING    rfid,      ;
            INTEGER   dwFlags,   ;
            INTEGER   hToken,    ;
            INTEGER @ pszPath

         Declare CoTaskMemFree In Ole32 ;
            INTEGER Hmem
      EndIf
      
      Return DoDefault()
   Endproc

   Procedure LocalAppdataPath()
      Local lcFolder, lcClSID, lnPtrPath, lnCount

      lcFolder = Space(1024)
      lcClSID = Space(16)

      If Os(3)<"6" && before Vista
         SHGetFolderPath(_vfp.HWnd, CSIDL_LOCAL_APPDATA, 0, SHGFP_TYPE_CURRENT, @lcFolder)
         lcFolder = Addbs(Left(lcFolder,At(Chr(0),lcFolder)-1))
      Else
         CLSIDFromString(Strconv(FOLDERID_LocalAppData,5),@lcClSID)
         lnPtrPath = 0
         SHGetKnownFolderPath(lcClSID, 0, 0, @lnPtrPath)
         lnCount  = 0
         lcFolder = ""
         Do While Not (Right(lcFolder,2)==Chr(0)+Chr(0))
            lcFolder = lcFolder + Sys(2600,lnPtrPath+lnCount,1)
            lnCount  = lnCount + 1
         Enddo
         CoTaskMemFree(lnPtrPath)
         lcFolder = Strconv(lcFolder,6)
      Endif

      Return lcFolder
   Endproc

   Procedure CommonAppdataPath()
      Local lcFolder, lcClSID, lnPtrPath, lnCount

      lcFolder = Space(1024)
      lcClSID = Space(16)

      If Os(3)<"6" && before Vista
         SHGetFolderPath(_vfp.HWnd, CSIDL_COMMON_APPDATA , 0, SHGFP_TYPE_CURRENT, @lcFolder)
         lcFolder = Addbs(Left(lcFolder,At(Chr(0),lcFolder)-1))
      Else
         CLSIDFromString(Strconv(FOLDERID_ProgramData,5),@lcClSID)
         lnPtrPath = 0
         SHGetKnownFolderPath(lcClSID, 0, 0, @lnPtrPath)
         lnCount  = 0
         lcFolder = ""
         Do While Not (Right(lcFolder,2)==Chr(0)+Chr(0))
            lcFolder = lcFolder + Sys(2600,lnPtrPath+lnCount,1)
            lnCount  = lnCount + 1
         Enddo
         CoTaskMemFree(lnPtrPath)
         lcFolder = Strconv(lcFolder,6)
      Endif

      Return lcFolder
   Endproc

Enddefine
