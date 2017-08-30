* libGUID
* created 2009/11/05 by Olaf Doschke - mailto:olaf.doschke@googlemail.com

Define Class pakGUID As Package
   * compilation of GUID functions
   IsAbstract = .F.

   Procedure Init()
      Declare Integer CoCreateGuid In Ole32;
         STRING @ pguid

      Declare Integer StringFromGUID2 In Ole32;
         STRING    rguid, ;
         STRING  @ lpsz,  ;
         INTEGER   cchMax

      Declare Integer CLSIDFromString In ole32;
         STRING   lpsz,  ;
         STRING @ pclsid
         
      Return DoDefault()
   Endproc

   Procedure HexGUID()
      * create GUID in a pure hex format without {}and -, needs Char(32)
      * 4DDF8EA230F5401695545B9C16FA2D91
      Return Chrtran(This.FullGUID(),'{-}','')
   Endproc

   Procedure UniqueIdentifier()
      * create GUID in the format, which SQL Server displays and returns, needs Char(36)
      * 4DDF8EA2-30F5-4016-9554-5B9C16FA2D91
      Return Chrtran(This.FullGUID(),'{}','')
   Endproc

   Procedure FullGUID()
      * create GUID in the format for a Char(38) field
      * {4DDF8EA2-30F5-4016-9554-5B9C16FA2D91}
      Local lcBuffer

      lcBuffer = Space(128)
      =StringFromGUID2( This.BinaryGUID(), @lcBuffer, Len(lcBuffer) )

      Return Left(Chrtran(lcBuffer,Chr(0),''),38)
   Endproc

   Procedure BinaryGUID()
      * create a binary Char(16) GUID
      Local lcBuffer

      lcBuffer = Space(16)+Chr(0)
      =CoCreateGuid(@lcBuffer)
      Return Left(lcBuffer,16)
   Endproc
Enddefine
