* libPersist
* created 2009/11/03 by Olaf Doschke - mailto:olaf.doschke@googlemail.com

Define Class pakPersistDBC As pakPersistData
   IsAbstract = .F.

   Procedure CreateDatabase(tcPath as String, tcDatabaseName as String)
      If Not Directory(tcPath)
         MkDir (tcPath)
      EndIf
      Cd (tcPath)
      Create Database (tcDatabaseName)
      
      Create Table tabUsers                         ;
            (ID                              N(15)  ;
            ,Name                            M      ;
            ,Screen_Name                     M      ;
            ,Location                        M      ;
            ,Description                     M      ;
            ,Profile_Image_URL               M      ;
            ,URL                             M      ;
            ,Protected                       L      ;
            ,Followers_Count                 N(12)  ;
            ,Profile_Background_Color        C( 6)  ;
            ,Profile_Text_Color              C( 6)  ;
            ,Profile_Link_Color              C( 6)  ;
            ,Profile_Sidebar_Fill_Color      C( 6)  ;
            ,Profile_Sidebar_Border_Color    C( 6)  ;
            ,Friends_Count                   N(12)  ;
            ,Created_At                      C(40)  ;
            ,Favourites_Count                N(12)  ;
            ,UTC_Offset                      N(10)  ;
            ,Time_Zone                       C(40)  ;
            ,Profile_Background_Image_Url    M      ;
            ,Profile_Background_Tile         L      ;
            ,Statuses_Count                  N(12)  ;
            ,Notifications                   L      ;
            ,Geo_Enabled                     L      ;
            ,Verified                        L      ;
            ,Last_Changed                    T      ;
            ,Primary Key ID TAG xpID                ;
            )

      Create Table tabIdentities                    ;
            (ID                              I Autoinc ;
            ,User_ID                         N(15)  ;
            ,Pin                             C( 6)  ;
            ,Access_Token                    M      ;
            ,Access_Token_Secret             M      ;
            ,Last_Changed                    T      ;
            ,Primary Key ID TAG xpID                ;
            )
      Index On User_ID Tag xfUser
            
      Create Table tabFriends                       ;
            (ID                              I Autoinc ;
            ,User_ID                         N(15)  ;
            ,Friend_ID                       N(15)  ;
            ,Last_Changed                    T      ;
            ,Primary Key ID TAG xpID                ;
            )

      Create Table tabFollowers                     ;
            (ID                              I Autoinc ;
            ,User_ID                         N(15)  ;
            ,Follower_ID                     N(15)  ;
            ,Last_Changed                    T      ;
            ,Primary Key ID TAG xpID                ;
            )

      Create Table tabStatuses                      ;
            (ID                              N(15)  ;
            ,Text                            M      ;
            ,Created_At                      C(40)  ;
            ,Sender_ID                       N(15)  ;
            ,Source                          M      ;
            ,Truncated                       L      ;
            ,In_Reply_To_Status_ID           N(15)  ;
            ,In_Reply_To_User_ID             N(15)  ;
            ,Favorited                       L      ;
            ,Geo                             M      ;
            ,LastChanged                     T      ;
            ,Primary Key ID TAG xpID                ;
            )
            
      Create Table tabDirectMessages                ;
            (Id                              N(15)  ;
            ,Text                            M      ;
            ,Created_At                      C(40)  ;
            ,Sender_ID                       N(15)  ;
            ,Recipient_ID                    N(15)  ;
            ,LastChanged                     T      ;
            ,Primary Key ID TAG xpID                ;
            )

      Create Table tabFavoritedststatuses           ;
            (Id                              I Autoinc ;
            ,Status_ID                       N(15)  ;
            ,Faved_By_ID                     N(15)  ;
            ,LastChanged                     T      ;
            ,Primary Key ID TAG xpID                ;
            )
            
      Close Database
   EndProc 

   Procedure StoreIdentity(tcAliasUser As String)
      This.StoreUser(tcAliasUser)
      
      Use tabIdentities In Select('tabIdentities') Again Shared
      Select tabIdentities
      If Seek(tabUsers.ID,'tabIdentities','xfUser')
         Replace Next 1;
            Pin With This.oFacade.oAuth.cPin ;
           ,Access_Token With This.oFacade.oAuth.cAccessToken ;
           ,Access_Token_Secret With This.oFacade.oAuth.cAccessTokenSecret ;
           In tabIdentities
      Else
         Insert Into tabIdentities ;
            (User_ID      ;
            ,Pin          ;
            ,Access_Token ;
            ,Access_Token_Secret ;
            )             ;
         Values           ;
            (loUser.ID    ;
            ,This.oFacade.oAuth.cPin ;
            ,This.oFacade.oAuth.cAccessToken ;
            ,This.oFacade.oAuth.cAccessTokenSecret ;
            )
      EndIf
   EndProc
   
   Procedure StoreUser(tcAliasUser As String)
      Local loUser
      Select (tcAliasUser)
      Scatter Memo Name loUser

      Use tabUsers In Select('tabUsers') Again Shared
      If Seek(&tcAliasUser..ID,'tabUsers','xpID')
         Gather Name loUser MEMO
      Else
         Insert Into tabUsers FROM Name loUser
      EndIf
   EndProc
   
   Procedure StoreStatus(tcAliasStatus As String)
      Local loStatus
      Select (tcAliasStatus)
      Scatter Memo Name loStatus

      Use tabStatuses In Select('tabStatuses') Again Shared
      If Seek(&tcAliasStatus..ID,'tabStatuses','xpID')
         Gather Name loStatus MEMO
      Else
         Insert Into tabStatuses FROM Name loStatus
      EndIf
   EndProc
   
   Procedure GetIdentities(tiUserID, tcAliasIdentities As String)
      Use tabUsers In Select('tabUsers') Again Shared
      Use tabIdentities In Select('tabIdentities') Again Shared

      Select tabUsers.*, tabIdentities.Pin, tabIdentities.Access_Token, tabIdentities.Access_Token_Secret ;
         From tabIdentities Left Join tabUsers On tabIdentities.User_ID = tabUsers.ID ;
         WHERE tabUsers.ID = tiUserID OR tiUserID=-1 ;
         Into Cursor (tcAliasIdentities)
   EndProc    
EndDefine

Define Class pakPersistData As Package
   * persists data into a database
   
   Procedure CreateDatabase()
   EndProc 
   
   Procedure StoreIdentity()
   EndProc

   Procedure StoreUser()
   EndProc

   Procedure StoreStatus()
   EndProc
   
   Procedure CreateUsersCursor(tcAlias as String)
      Use In Select(tcAlias)
      
      Create Cursor (tcAlias)                       ;
            (ID                              N(15)  ;
            ,Name                            M      ;
            ,Screen_Name                     M      ;
            ,Location                        M      ;
            ,Description                     M      ;
            ,Profile_Image_URL               M      ;
            ,URL                             M      ;
            ,Protected                       L      ;
            ,Followers_Count                 N(12)  ;
            ,Profile_Background_Color        C( 6)  ;
            ,Profile_Text_Color              C( 6)  ;
            ,Profile_Link_Color              C( 6)  ;
            ,Profile_Sidebar_Fill_Color      C( 6)  ;
            ,Profile_Sidebar_Border_Color    C( 6)  ;
            ,Friends_Count                   N(12)  ;
            ,Created_At                      C(40)  ;
            ,Favourites_Count                N(12)  ;
            ,UTC_Offset                      N(10)  ;
            ,Time_Zone                       C(40)  ;
            ,Profile_Background_Image_Url    M      ;
            ,Profile_Background_Tile         L      ;
            ,Statuses_Count                  N(12)  ;
            ,Notifications                   L NULL ;
            ,Following                       L      ;
            ,Geo_Enabled                     L      ;
            ,Verified                        L      ;
            ,Last_Changed                    T      ;
            )   
   EndProc

   Procedure CreateStatusesCursor(tcAlias as String)
      Use In Select(tcAlias)
      
      Create Cursor (tcAlias)                       ;
            (ID                              N(15)  ;
            ,Text                            M      ;
            ,Created_At                      C(40)  ;
            ,Sender_ID                       N(15)  ;
            ,Source                          M      ;
            ,Truncated                       L      ;
            ,In_Reply_To_Status_ID           N(15)  ;
            ,In_Reply_To_User_ID             N(15)  ;
            ,In_Reply_To_Screen_Name         M      ;
            ,Geo                             M      ;
            ,LastChanged                     T      ;
            )
   EndProc

   Procedure CreateDirectMessagesCursor(tcAlias as String)
      Use In Select(tcAlias)
      
      Create Cursor (tcAlias)                       ;
            (Id                              N(15)  ;
            ,Text                            M      ;
            ,Created_At                      C(40)  ;
            ,Sender_ID                       N(15)  ;
            ,Recipient_ID                    N(15)  ;
            ,Sender_Screen_Name              M      ;
            ,Recipient_Screen_Name           M      ;
            ,LastChanged                     T      ;
            )
   EndProc
   
   Procedure GetIdentities()
   EndProc 
   
   Procedure GetUser(tiID)
   EndProc
   
   Procedure GetStatus(tiID)
   EndProc
   
   Procedure GetDirectMessage(tiID)
   EndProc
   
Enddefine


