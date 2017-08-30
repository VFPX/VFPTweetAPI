* 2009/07/20 - Olaf Doschke
* turned these base classes to a seperate prg library
#Define ccRequestFormats 'xml','json','rss','atom'

Define Class VFPTweetAPI As Facade OlePublic
   IsAbstract    = .F.
   BaseUrl       = 'http://twitter.com/'
   RequestFormat = .NULL.
   UserAgent     = 'VFPTwitterAPI'
   RemainingHits =  0
   IsLoggedIn    = .F.
   TestResponse  = ''
   ActiveUser    = ''

   Procedure Init()
      This.AddObject('oRequest','pakRequestProxy')
      With This.oRequest
         .oFacade           = This
         .cBaseUrl          = This.BaseUrl
         .cRequestformat    = '.xml'
         .cUserAgent        = This.UserAgent
      Endwith

      This.AddObject('oAuth','pakOAuth')
      This.oAuth.oFacade = This

      This.AddObject('oStatus','pakStatuses')
      This.oStatus.oFacade = This

      This.AddObject('oEnDecode','pakEnDecode')
      This.oEnDecode.oFacade = This

      This.AddObject('oDirectMessage','pakDirectMessages')
      This.oDirectMessage.oFacade = This
      
      This.AddObject('oPersist','pakPersistDBC')
      This.oPersist.oFacade = This
      
      This.AddObject('oGUID','pakGUID')
      This.oGUID.oFacade = This
      
      This.AddObject('oTime','pakTime')
      This.oTime.oFacade = This

      This.AddObject('oFileSystem','pakFileSystem')
      This.oFileSystem.oFacade = This
      
      lcDatabasePath = Addbs(This.oFilesystem.LocalAppdataPath())+'VFPTweetAPI'
      lcDatabase = Addbs(lcDatabasePath)+'VFPTweetAPI.DBC'
      If not File(lcDatabase)
         This.oPersist.CreateDatabase(lcDatabasePath,'VFPTweetAPI')
      EndIf
      Open Database (lcDatabase) Shared
      
      Return DoDefault()
   EndProc
   
   Procedure SetActiveUser(tiUserID)
      This.oPersist.GetIdentities(tiUserID, 'curIdentities')
      If RecCount('curIdentities')>0
         This.ActiveUser = curIdentities.Screen_Name
         This.oAuth.cAccessToken = curIdentities.Access_Token
         This.oAuth.cAccessTokenSecret = curIdentities.Access_Token_Secret
         This.oAuth.cPin = curIdentities.Pin
      EndIf
   EndProc

   Procedure AuthLogin()
      This.oAuth.Login()
   EndProc
   
   Procedure AuthAccessToken()
      This.oAuth.RequestAccessToken()
   EndProc
   
   Procedure AuthLogout()
      This.oAuth.Logout()
   Endproc

   Procedure Test()
      This.oRequest.SendRequest('GET','help/test',,This,'OKCheck')
   Endproc

   Procedure PublicTimeline()
      * 20 updates from the public timeline. cached for 1 minute. Querying more often is a waste of requests
      Return This.oStatus.Timeline('statuses/public_timeline')
   Endproc

   Procedure Friendstimeline(tiSinceID As Integer, tiMaxID As Integer, tiCount As Integer, tiPage As Integer)
      * make sure user is logged in
      If Not This.oAuth.lLoggedIn
         This.oAuth.Login()
      Endif

      * last 20 updates of friends (later 200 since the last stored status of any friend)
      Return This.oStatus.Timeline('statuses/friends_timeline', .F. , tiSinceID, tiMaxID, tiCount, tiPage )
   Endproc

   Procedure OwnTimeline(tiSinceID As Integer, tiMaxID As Integer, tiCount As Integer, tiPage As Integer)
      * make sure user is logged in
      If Not This.oAuth.lLoggedIn
         This.oAuth.Login()
      Endif

      * last 20 updates of logged in user (later 200 since the last stored own status)
      Return This.oStatus.Timeline('statuses/user_timeline', .F. , tiSinceID, tiMaxID, tiCount, tiPage )
   Endproc

   Procedure UserTimeline(tiUserID As Integer, tiSinceID As Integer, tiMaxID As Integer, tiCount As Integer, tiPage As Integer)
      Local lcParams

      * make sure a userid is passed in (request with screenname is not implemented)
      If Empty(tiUserID)
         Return .F.
      Endif

      * always use user_id parameter
      lcParams = 'user_id='+Transform(tiUserID)

      * last 20 updates of some user - or friend. (later 200 since the last stored status of that user)
      Return This.oStatus.Timeline('statuses/user_timeline', lcParams, tiSinceID, tiMaxID, tiCount, tiPage)
   Endproc

   Procedure Mentions(tiSinceID As Integer, tiMaxID As Integer, tiCount As Integer, tiPage As Integer)
      Return This.oStatus.Timeline('statuses/mentions', .F. , tiSinceID, tiMaxID, tiCount, tiPage)
   Endproc

   Procedure DirectMessages(tiSinceID As Integer, tiMaxID As Integer, tiCount As Integer, tiPage As Integer)
      Return This.oDirectMessage.Timeline('direct_messages', .F. , tiSinceID, tiMaxID, tiCount, tiPage)
   Endproc

   Procedure UpdateNew(tcStatus, tiInReplyToStatusID)
      Local lcParams

      If Not This.oAuth.lLoggedIn
         This.oAuth.Login()
      Endif

      If Empty(tcStatus)
         Return .F.
      Endif

      Return This.oStatus.New(tcStatus, tiInReplyToStatusID)
   Endproc

   Procedure UpdateDispose(tiStatusID)
      Return This.oStatus.Dispose(tiStatusID)
   Endproc

   Procedure DirectMessageNew(tcMessage, tiRecipientUserID)
      Local lcParams

      If Not This.oAuth.lLoggedIn
         This.oAuth.Login()
      Endif

      If Empty(tcMessage)
         Return .F.
      Endif
      If Empty(tiRecipientUserID)
         Return .F.
      Endif
      lcParams = 'text='+This.oRequest.URLEncode(tcMessage)
      lcParams = lcParams + '&user='+Transform(tiRecipientUserID)

      Return This.oDirectMessage.New(tcMessage, tiRecipientUserID)
   Endproc

   Procedure DirectMessageDispose(tiMessageID)
      Return This.oDirectMessage.Dispose(tiMessageID)
   EndProc
   
   Procedure VerifyCredentials()
      If Not This.oAuth.lLoggedIn
         This.oAuth.Login()
      EndIf
      
      Return This.oRequest.SendRequest('GET','account/verify_credentials','',This,'IdentitiesInsert')
   EndProc

   Procedure OwnRateLimitStatus()
      If Not This.oAuth.lLoggedIn
         This.oAuth.Login()
      Endif

      Return This.IPRateLimitStatus()
   Endproc

   Procedure IPRateLimitStatus()
      Return This.oRequest.SendRequest('GET','account/rate_limit_status','',This,'RemainingHitsSet')
   Endproc

   Procedure RemainingHitsSet()
      Lparameters loResponse

      Local loXML, loNode
      loXML = loResponse.ResponseXML
      loNode = loXML.SelectSingleNode("//remaining-hits")

      This.RemainingHits = Int(Val(loNode.Text))
   Endproc

   Procedure OKCheck()
      Lparameters loResponse

      Local loXML, loNode
      loXML = loResponse.ResponseXML
      loNode = loXML.SelectSingleNode("//ok")

      This.TestResponse = loNode.Text
   EndProc
      
   Procedure IdentitiesInsert()
      Lparameters loResponse
      Local loXML, lcXML, loStatuses, loUsers, lnCount, loRecord
      
      This.oPersist.CreateUsersCursor('curUserIdentity')
      This.oPersist.CreateStatusesCursor('curUsersLastStatus')
      
      loXML = loResponse.ResponseXML
      loUsers = loXML.Selectnodes('//user')
      IF loUsers.length>0
         lcXML = loUsers.Item(0).XML
         lcXML = Strtran(lcXML,'<notifications></notifications>','<notifications>false</notifications>')
         lcXML = Strtran(lcXML,'<following></following>','<following>false</following>')
         Xmltocursor('<cursor>'+lcXML+'</cursor>','curUserIdentity',4+8192)

         loStatus = loXML.selectNodes('//status')
         IF loStatus.length>0
            Xmltocursor('<cursor>'+loStatus.Item(0).XML+'</cursor>','curUsersLastStatus',4+8192)

            Update curUsersLastStatus Set Sender_ID = curUserIdentity.ID
         ENDIF
      ENDIF
       
      This.oPersist.StoreIdentity('curUserIdentity')
      This.SetActiveUser(curUserIdentity.ID)
   EndProc
   
   Procedure RequestFormat_Assign()
      Lparameters tcFormat
      
      Do Case
         Case Vartype(tcFormat)='C' And tcFormat==''
            This.oRequest.cRequestFormat = ''
         Case Vartype(tcFormat)='C' And Inlist(Lower(tcFormat),ccRequestFormats)
            This.oRequest.cRequestFormat = '.'+tcFormat
      EndCase 
   Endproc

   Procedure RequestFormat_Access()
      Return Substr(This.oRequest.cRequestFormat,2)
   Endproc

Enddefine

Define Class pakDirectMessages As pakGeneralStatuses
   * cares for all DirectMessage related Twitter API requests
   IsAbstract      = .F.
   cStoreStatus    = 'StoreDirectMessage'
   cStatusXPath    = '//direct_message'
   cRequestNew     = 'direct_messages/new'
   cRequestDispose = 'direct_messages/destroy/'
Enddefine

Define Class pakStatuses As pakGeneralStatuses
   * cares for all Status (normal Twwets) related Twitter API requests
   IsAbstract      = .F.
   cStatusXPath    = '//status'
   cRequestNew     = 'statuses/update'
   cRequestDispose = 'statuses/destroy/'
Enddefine

Define Class pakGeneralStatuses As Package
   Protected cStatusAlias, cStatusXPath, cRequestNew, cRequestDispose

   cStoreStatus    = 'StoreStatus'
   cStatusXPath    = ''
   cRequestNew     = ''
   cRequestDispose = ''

   Procedure Timeline(tcURL As String, tcParams As String, tiSinceID As Integer, tiMaxID As Integer, tiCount As Integer, tiPage As Integer, tcResponseEvent As String)
      tcParams = Evl(tcParams,'')

      If Not Empty(tiSinceID)
         tcParams = tcParams + '&since_id='+Transform(tiSinceID)
      Endif
      If Not Empty(tiMaxID)
         tcParams = tcParams + '&max_id='+Transform(tiMaxID)
      Endif
      If Not Empty(tiCount)
         tcParams = tcParams + '&count='+Transform(tiCount)
      Endif
      If Not Empty(tiPage)
         tcParams = tcParams + '&page='+Transform(tiPage)
      EndIf
      
      This.oFacade.RequestFormat='xml'
      Return This.oFacade.oRequest.SendRequest('GET',tcURL,tcParams,This,'StatusInsert')
   Endproc

   Procedure New(tcStatus, tiInReplyToStatusID)
      Local lcParams, lcInReplyToScreenName
      lcParams = 'status='+This.oFacade.oEnDecode.URLEncode(tcStatus)

      If Vartype(tiInReplyToStatusID)="N" And !Empty(tiInReplyToStatusID)
         lcParams = lcParams + '&in_reply_to_status_id='+Transform(tiInReplyToStatusID)
      Endif

      This.oFacade.RequestFormat = 'xml'
      Return This.oFacade.oRequest.SendRequest('POST',This.cRequestNew, lcParams, This, 'StatusInsert')
   Endproc

   Procedure Dispose(tiStatusID)
      This.oFacade.RequestFormat = 'xml'
      Return This.oFacade.oRequest.SendRequest('DELETE',This.cRequestDispose+Transform(tiStatusID), This, 'StatusDelete')
   Endproc

   Procedure StatusInsert()
      Lparameters loResponse
      Local loXML, lcXML, loStatuses, loUsers, lnCount, loRecord, lcStoreMethod
      
      * using cursors to store status und user data temporarily.
      This.oFacade.oPersist.CreateUsersCursor("curUsersTemp")
      This.oFacade.oPersist.CreateStatusesCursor("curStatusesTemp")
      This.oFacade.RemainingHits = Int(Val(loResponse.getResponseHeader('X-RateLimit-Remaining')))

      loXML = loResponse.ResponseXML

      loStatuses = loXML.Selectnodes(This.cStatusXPath)
      loUsers = loXML.Selectnodes(This.cStatusXPath+'/user')

      * PROBLEM: flag 1024 in the last XMLTOCURSOR parameter does not work,
      * maybe as a side effect of SYS(3101,65001)
      For lnCount = 0 To loStatuses.Length-1
         lcXML = loStatuses.Item(lnCount).XML
         Xmltocursor('<cursor>'+lcXML+'</cursor>','curStatusesTemp',4+8192)
      Endfor
      For lnCount = 0 To loUsers.Length-1
         lcXML = loUsers.Item(lnCount).XML
         lcXML = Strtran(lcXML,'<notifications></notifications>','<notifications>false</notifications>')
         lcXML = Strtran(lcXML,'<following></following>','<following>false</following>')
         Xmltocursor('<cursor>'+lcXML+'</cursor>','curUsersTemp',4+8192)
      Endfor

      * persisting temp cursors to a database
      Select curUsersTemp
      Scan
         This.oFacade.oPersist.StoreUser('curUsersTemp')
      Endscan

      Select curStatusesTemp
      Scan
         lcStoreMethod = This.cStoreStatus
         This.oFacade.oPersist.&lcStoreMethod.('curStatusesTemp')
      Endscan

      Use In Select('curUsersTemp')
      Use In Select('curStatusesTemp')
   Endproc

   Procedure StatusDelete()
      Lparameters loResponse
      Local loXML, loStatusID, lnCount

      If !Used(This.cStatusAlias) And !Empty(This.cStatusAlias)
         Return
      Endif

      loXML = loResponse.ResponseXML
      loStatusID = loXML.SelectSingleNode(This.cStatusXPath+'//id')

      Delete From (This.cStatusAlias) Where Id Between Val(loStatusID.Text)-.5 And Val(loStatusID.Text)+.5
   Endproc
Enddefine
