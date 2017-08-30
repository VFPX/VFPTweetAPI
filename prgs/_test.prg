* +------+
* ! Test !
* +------+

* This is just a small test case, that gives some hints on using this API facade.
* It's not a full unit test.
* It's not thorouhghly testing all methods available.

#Define ccCRLF Chr(13)+Chr(10)

Clear All
Clear

If _vfp.StartMode=0
   Cd Justpath(Sys(16,0))
Endif
Do _loader.prg

Public goVFPTweetAPI
goVFPTweetAPI = Createobject('VFPTweetAPI')

With goVFPTweetAPI

   * .PublicTimeline()
   .SetActiveUser(-1)
   If Empty(.ActiveUser)
      If .AuthLogin()
         .oAuth.cPin = Inputbox('enter Pin:','Pin','')
         .AuthAccessToken()
         .VerifyCredentials()
      Else
         MessageBox('Unfortunately the first step of the login (oauth/request_token) already failed.')
      EndIf
   EndIf
   
   If NOT Empty(.ActiveUser)
      .Mentions()
      .FriendsTimeline()
      * .UpdateNew(Strconv('Testing the VFPTweetAPI - test passed.',9))
      MessageBox('A first test is passed. You now find some data in '+ccCRLF+;
      Dbc()+ccCRLF+;
      'and in the datasession.'+ccCRLF+ccCRLF+;
      'The VFPTweetapi is still instanciated as public variable goVFPTweetAPI.',0,'VFPTweetAPI')
      Set
      Select tabIdentities
      Browse Nowait
      Select tabUsers
      Browse Nowait
   EndIf
Endwith
