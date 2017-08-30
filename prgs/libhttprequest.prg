* libHttpRequests
* created 2009/10/22 by Olaf Doschke - mailto:olaf.doschke@googlemail.com
#Define cnReadyStateComplete 4

Define Class pakRequestProxy As Package
   * Sends HttpRequests and Redirects the Responses
   IsAbstract     = .F.

   cUserAgent     = ''
   cBaseUrl       = ''
   cRequestFormat = '.xml'
   lLoggedIn      = .F.

   Procedure Init()
      * convert values retrieved via COM to UTF-8 (codepage 65001)
      Sys(3101,65001)
      * Use a Timer to poll for responses
      This.AddObject("oTimer","RequestTimer")
      This.oTimer.Enabled = .T.
      
      Return DoDefault()
   EndProc

   Procedure SendRequest()
      Lparameters tcRequestType, tcURL, tvParams, toClient, tcCallback, tcUser, tcPassword
      Local loRequest, llAsync, lcRequestURL
     
      tcRequestType = Evl(Nvl(tcRequestType,''),'GET')
      If Not Inlist(tcRequestType,'GET','POST','HEAD','PUT','DELETE')
         tcRequestType = 'GET'
      Endif
      tcCallback = Evl(tcCallback,'ResponseReceive')

      loRequest = Createobject('MsXml2.XmlHttp')
      ComProp(loRequest,'UTF8',1)
      
      llAsync = (Vartype(toClient)='O' And Pemstatus(toClient,tcCallback,5)) Or (tcCallback == 'return lorequest')
      lcRequestURL = This.cBaseUrl+tcURL+This.cRequestFormat
      tvParams = Evl(tvParams,'')
      If PemStatus(This.oFacade.oAuth,'SignRequest',5)     
         tvParams = This.oFacade.oAuth.SignRequest(tcRequestType, lcRequestURL, tvParams)
      EndIf

      If tcRequestType=="GET" OR tcRequestType=="HEAD"
         lcRequestURL = lcRequestURL+Iif(Empty(tvParams),'','?')+tvParams
      EndIf
      
      If Empty(tcUser)
         loRequest.Open(tcRequestType, lcRequestURL, llAsync)
      Else
         loRequest.Open(tcRequestType, lcRequestURL, llAsync, tcUser, tcPassword)
      Endif
 
      If PemStatus(This.oFacade.oAuth,'SetContentType',5)          
         This.oFacade.oAuth.SetContentType(loRequest)
      EndIf
	   
      loRequest.SetRequestHeader('User-Agent',This.cUserAgent)
      
      If tcRequestType="POST"
         loRequest.Send(CreateBinary(tvParams))
      Else
         loRequest.Send(.Null.)
      EndIf
      
      If llAsync And Not (tcCallback == 'return lorequest')
         AddProperty(loRequest,'oClient',toClient)
         AddProperty(loRequest,'cCallback',tcCallback)
         This.oTimer.AddRequest(loRequest)
         Return .T.
      Endif

      Return loRequest
   Endproc

   Procedure Destroy()
      This.oTimer.Enabled = .F.
      This.RemoveObject("oTimer")
   Endproc

   Procedure DisposeAll()
      This.oTimer.DisposeRequests()
   Endproc
EndDefine

Define Class RequestTimer As Timer
   Enabled   = .T.
   Interval  = 250
   * temporarily store Requests until their Readystate turns to 4 (cnReadyStateComplete).
   oRequests = .NULL.
   
   Procedure Init()
       This.oRequests = Createobject("Collection")
   EndProc 
   
   Procedure Timer()
      This.Enabled = .F.
      * poll for Requests with ReadyState=cnReadyStateComplete
      Local lnCount, loRequest

      For lnCount = This.oRequests.Count To 1 Step -1
         loRequest = This.oRequests.Item(lnCount)
         If loRequest.ReadyState = cnReadyStateComplete
            =Evaluate('loRequest.oClient.'+loRequest.cCallback+'(loRequest)')
            This.oRequests.Remove(lnCount)
         Endif
      Endfor

      This.Enabled = .T.
   Endproc

   Procedure AddRequest()
      Lparameters toRequest
      This.oRequests.Add(toRequest)
   Endproc

   Procedure DisposeRequests()
      Local lnCount, loRequest
      For lnCount = This.oRequests.Count To 1 Step -1
         loRequest = This.oRequests.Item(lnCount)
         loRequest.Abort()
         This.oRequests.Remove(lnCount)
      Endfor
   Endproc

   Procedure Destroy()
      If Vartype(This.oRequests)='O'
         This.DisposeRequests()
      Endif
   Endproc
Enddefine
