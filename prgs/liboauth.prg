* libOAuth
* created 2009/07/22 by Olaf Doschke - mailto:olaf.doschke@googlemail.com
#Define ccCRLF   Chr(13)+Chr(10)
#Define cnBase64             13
#Define cnSha1                1

Define Class pakOAuth As Package
   * Makes authentication requests, signs requests
   * and maintains the login status
   cConsumerKey        = '4q2VOGXpLUkMjVtZ8mChvA'
   cConsumerSecret     = 'cDn36H1j3zOP3Asmq27ChZ6mVkxokwic3kJrABmh4w'

   cRequestToken       = ''
   cRequestTokenSecret = ''

   cAccessToken        = ''
   cAccessTokenSecret  = ''
   
   cPin                = ''

   cUrlTokenRequest    = 'oauth/request_token'
   cUrlAuthorize       = 'http://twitter.com/oauth/authorize'
   cUrlTokenAccess     = 'oauth/access_token'

   IsAbstract          = .F.
   lLoggedIn           = .F.
   
   Procedure Init()
      This.AddObject('oEnDecode','pakEnDecode')
      This.oEnDecode.oFacade = This
   EndProc

   Procedure Login()
      Local lcRequestParameters, lcBaseString, lcSignature, loRequest, lcResponse, llSuccess
      Local Array laKeyValuePairs[2]

      This.oFacade.Requestformat = ''
      * Login, Step 1 - Get an RequestToken and TokenSecret from The OAuth Service Provider (eg Twitter)
      Text To lcRequestParameters NoShow TextMerge
         oauth_consumer_key=<<This.cConsumerKey>>,
         oauth_nonce=<<This.oFacade.oGUID.HexGUID()>>,
         oauth_signature_method=HMAC-SHA1,
         oauth_timestamp=<<This.oFacade.oTime.UTCTime()-Datetime(1970,1,1,0,0,0)>>,
         oauth_version=1.0
      EndText
      lcRequestParameters = Strtran(lcRequestParameters,'         oauth_','oauth_')
      lcRequestParameters = Strtran(lcRequestParameters,','+ccCRLF,'&')
   
      loRequest = This.oFacade.oRequest.SendRequest('GET', This.cUrlTokenRequest, lcRequestParameters,This, 'return lorequest')
      Do While loRequest.ReadyState<>4
         DoEvents Force
      Enddo
      lcResponse = loRequest.ResponseText

      If Alines(laKeyValuePairs,lcResponse,2,'&')>=2
         This.cRequestToken       = Getwordnum(laKeyValuePairs[1],2,'=')
         This.cRequestTokenSecret = Getwordnum(laKeyValuePairs[2],2,'=')
         llSuccess = .T.
      Else
         This.cRequestToken       = ''
         This.cRequestTokenSecret = ''
         llSuccess = .F.
      Endif

      If llSuccess
         * Login, Step 2 - Request a PIN from the Service Provider Prompted to the User
         TEXT To lcRequestParameters NoShow TextMerge
            oauth_callback=oob,
            oauth_token=<<This.cRequestToken>>
         ENDTEXT
         lcRequestParameters = Strtran(lcRequestParameters,'            oauth_','oauth_')
         lcRequestParameters = Strtran(lcRequestParameters,','+ccCRLF,'&')

         ShellExecute(0, 'open', This.cUrlAuthorize+'?'+lcRequestParameters, '','', 1)
      Endif

      * The client now needs to ask for the PIN from the User,
      * to finally request an Access Token via RequestAccessToken
      * Only if retreiving that Access Token is succesfull the Login
      * is completed, this return value only tells about the partly success
      * of retrieving the RequestToken/RequestTokenSecret values...
      Return llSuccess
   Endproc

   Procedure RequestAccessToken()
      Local lcRequestParameters, llSuccess, lcNonce, lcTimestamp
      Local Array laKeyValuePairs[2]
      
      lcNonce = This.oFacade.oGUID.HexGUID()
      lcTimestamp = Textmerge("<<This.oFacade.oTime.UTCTime()-Datetime(1970,1,1,0,0,0)>>")

      llSuccess = .F.
      If This.oEnDecode.LuhnCheck(This.cPin)
         This.oFacade.Requestformat = ''
         * Login, Step 3 - Get an AccessToken and AcccessTokenSecret from The OAuth Service Provider (eg Twitter)
         TEXT To lcRequestParameters NoShow TextMerge
            oauth_consumer_key=<<This.cConsumerKey>>,
            oauth_nonce=<<lcNonce>>,
            oauth_signature_method=HMAC-SHA1,
            oauth_timestamp=<<lcTimestamp>>,
            oauth_token=<<This.cRequestToken>>,
            oauth_verifier=<<This.cPin>>,
            oauth_version=1.0
         ENDTEXT
         lcRequestParameters = Strtran(lcRequestParameters,'            oauth_','oauth_')
         lcRequestParameters = Strtran(lcRequestParameters,','+ccCRLF,'&')
         * lcRequestParameters = This.SignRequest('POST',This.oFacade.oRequest.cBaseUrl+This.cUrlTokenAccess, lcRequestParameters, This.cRequestToken, This.cRequestTokenSecret)
         loRequest = This.oFacade.oRequest.SendRequest('POST',This.cUrlTokenAccess,lcRequestParameters,This,'return lorequest')
         Do While loRequest.ReadyState<>4
            DoEvents Force
         Enddo
         lcResponse = loRequest.ResponseText

         If Alines(laKeyValuePairs,lcResponse,2,'&')>=2
            This.cAccessToken       = Getwordnum(laKeyValuePairs[1],2,'=')
            This.cAccessTokenSecret = Getwordnum(laKeyValuePairs[2],2,'=')
            llSuccess = .T.
         EndIf
      EndIf 

      If Not llSuccess
         This.cPin               = ''
         This.cAccessToken       = ''
         This.cAccessTokenSecret = ''
      Endif

      This.lLoggedIn = llSuccess
      This.oFacade.IsLoggedIn = This.lLoggedIn
      This.oFacade.Requestformat = 'xml'
   Endproc

   Procedure Logout()
      * there is no such thing with OAuth. A user can revoke Accesss to a client
      * eg visit http://twitter.com/account/connections and revoke access
   Endproc

   Procedure OAuthParameters()
      Lparameters tcNonce, tcTimestamp
      Local lcRequestParameters

      TEXT To lcRequestParameters NoShow TextMerge
         oauth_consumer_key=<<This.cConsumerKey>>,
         oauth_nonce=<<tcNonce>>,
         oauth_signature_method=HMAC-SHA1,
         oauth_timestamp=<<tcTimestamp>>,
         oauth_token=<<This.cAccessToken>>,
      ENDTEXT
      lcRequestParameters = Strtran(lcRequestParameters,'         oauth_','&oauth_')
      lcRequestParameters = ChrTran(lcRequestParameters,','+ccCRLF,'')
      lcRequestParameters = Substr(lcRequestParameters,2) + IIF(Empty(This.cPin),'','&oauth_verifier='+This.cPin)+'&oauth_version=1.0'
      Return lcRequestParameters
   EndProc

   Procedure SignRequest()
      Lparameters tcRequestType, tcRequestUrl, tcRequestParameters

      Local lcRequestParameters, lcBaseString, lcSignature, lnCount, lcTimestamp, lcNonce, lcOAuthParameters, lcAllParameters
      Local lcToken, lcTokenSecret, lcConsumerSecret, lcKey
      Local laKeyValuePairs[1]

   
      lcToken          = Evl(Evl(This.cAccessToken      ,This.cRequestToken)      ,'')
      lcTokenSecret    = Evl(Evl(This.cAccessTokenSecret,This.cRequestTokenSecret),'')
      lcConsumerSecret = This.cConsumerSecret

      If Not 'oauth_signature_method=' $ tcRequestParameters
         lcNonce = This.oFacade.oGUID.HexGUID()
         lcTimestamp = Textmerge("<<This.oFacade.oTime.UTCTime()-Datetime(1970,1,1,0,0,0)>>")
         lcOAuthParameters = This.OAuthParameters(lcNonce, lcTimestamp)
      Else
         lcOAuthParameters = tcRequestParameters
         tcRequestParameters = ''
      Endif

      lcAllParameters = lcOAuthParameters+Iif(Empty(tcRequestParameters),'','&')+tcRequestParameters
      Alines(laKeyValuePairs,lcAllParameters,0,'&')
      Asort(laKeyValuePairs,1,Alen(laKeyValuePairs),0)
      lcAllParameters = ''
      For lnCount = 1 To Alen(laKeyValuePairs)
         lcAllParameters = lcAllParameters + '&' + laKeyValuePairs[lnCount]
         If laKeyValuePairs[lnCount]="oauth_nonce"
            lcNonce = Substr(laKeyValuePairs[lnCount],At("=",laKeyValuePairs[lnCount])+1)
         EndIf 
         If laKeyValuePairs[lnCount]="oauth_timestamp"
            lcTimestamp = Substr(laKeyValuePairs[lnCount],At("=",laKeyValuePairs[lnCount])+1)
         EndIf 
      Endfor
      lcAllParameters = Substr(lcAllParameters,2)

      lcBaseString = tcRequestType+'&'+ ;
         This.oEnDecode.UrlEncode(tcRequestUrl)+'&'+;
         This.oEnDecode.UrlEncode(lcAllParameters)
         
      lcKey = This.oEnDecode.UrlEncode(Evl(lcConsumerSecret,''))+'&'+This.oEnDecode.UrlEncode(Evl(lcTokenSecret,''))
      lcSignature  = This.oEnDecode.HMACSHA1(lcBaseString,lcKey)
      lcSignature  = This.oEnDecode.UrlEncode(Strconv(lcSignature,cnBase64))

      Return lcOAuthParameters + Iif(Empty(tcRequestParameters),'','&') + tcRequestParameters + '&oauth_signature=' + lcSignature
   Endproc

   Procedure SetContentType(toRequest)
      toRequest.SetRequestHeader('Content-Type','application/x-www-form-urlencoded')
   Endproc

Enddefine


