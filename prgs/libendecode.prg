* libEnDecode
* created 2009/10/27 by Olaf Doschke - mailto:olaf.doschke@googlemail.com
External LIBRARY vfpencryption71.fll

#Define ccCRLF   Chr(13)+Chr(10)
#Define ccUrlChars '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ$-_.~'
#Define cnBase64             13
#Define cnSha1                1

Define Class pakEnDecode As Package
   * compilation of encoding, decoding, hashing functions
   IsAbstract    = .F.

   Procedure Init()
      * thank you, Craig S. Boyd - www.sweetpotatosoftware.com
      Set Library To Locfile('..\vfpencryption71.fll') Additive
      
      Return DoDefault()
   EndProc
   
   Function UrlEncode(tcData)
      Local lcUrlEncoded, lnPos, lcChar
      lcUrlEncoded = ''

      For lnPos=1 To Len(tcData)
         lcChar = Substr(tcData,lnPos,1)
         If lcChar $ ccUrlChars
            lcUrlEncoded = lcUrlEncoded + lcChar
         Else
            lcUrlEncoded = lcUrlEncoded + '%'+Upper(Right(Transform(Asc(lcChar),'@0'),2))
         Endif
      Endfor

      Return lcUrlEncoded
   EndProc   

   Function LuhnCheck(tcDigits As String)
      Local lnLen, lnSum, lnDigit
      
      lnLen = Len(tcDigits)
      lnSum = 0
      For lnCount = 0 To lnLen-1
         lnDigit = Asc(Substr(tcDigits,lnLen-lnCount,1))-48
         If Bittest(lnCount,0)
            lnDigit = 2*lnDigit - Iif(lnDigit<5, 0, 9)
         Endif
         lnSum = lnSum + lnDigit
      Endfor
      Return (lnSum % 10) = 0
   EndProc
   
   Procedure HMACSHA1(tcMessage As String, tcKey As String)
      Return HMAC(tcMessage, tcKey, cnSha1)
   EndProc

*deprecated HMACSHA1 function
*!*   Procedure HMACSHA1(tcMessage As String, tcKey As String)
*!*      #Define cnSha1 1
*!*      Local lnIndex, lnKey, lcInner, lcOuter

*!*      If (Len(tcKey) > 64)
*!*         tcKey = Hash(tcKey,cnSha1)
*!*      Endif
*!*      tcKey = Padr(tcKey,64,Chr(0))

*!*      lcInner = ''
*!*      lcOuter = ''
*!*      For lnIndex = 1 To 64
*!*         lnKey   = Asc(Substr(tcKey,lnIndex,1))
*!*         lcInner = lcInner + Chr(Bitxor(0x36,lnKey))
*!*         lcOuter = lcOuter + Chr(Bitxor(0x5c,lnKey))
*!*      Endfor

*!*      Return Hash(lcOuter + Hash(lcInner + tcMessage, cnSha1), cnSha1)
*!*   Endproc
EndDefine

