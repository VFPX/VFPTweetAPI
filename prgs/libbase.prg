* libBase
* created 2009/07/19 by Olaf Doschke - mailto:olaf.doschke@googlemail.com

Define Class Facade As _Custom
Enddefine

Define Class Package As _Custom
   oFacade = .Null.
Enddefine

Define Class _Custom As Custom
   IsAbstract = .T.

   Procedure Init()
      * don't create abstract classes
      Return Not This.IsAbstract
   Endproc

   * hide away unneeded properties and methods from OLE intellisense.
   * They're still available, especially .Init(), .Destroy(), .Parent, etc.,
   * but they are protected to avoid wrong usage from OLE automation
   * (notice, that VFPTwitterAPI class is designed as OlePublic)
   Protected AddObject       ;
      ,      AddProperty     ;
      ,      BaseClass       ;
      ,      Class           ;
      ,      ClassLibrary    ;
      ,      Comment         ;
      ,      ControlCount    ;
      ,      Controls        ;
      ,      Destroy         ;
      ,      Error           ;
      ,      Format          ;
      ,      Height          ;
      ,      HelpContextID   ;
      ,      Init            ;
      ,      Left            ;
      ,      Name            ;
      ,      Newobject       ;
      ,      Objects         ;
      ,      Parent          ;
      ,      ParentClass     ;
      ,      Picture         ;
      ,      ReadExpression  ;
      ,      ReadMethod      ;
      ,      RemoveObject    ;
      ,      ResetToDefault  ;
      ,      SaveAsClass     ;
      ,      ShowWhatsThis   ;
      ,      Tag             ;
      ,      Top             ;
      ,      WhatsThisHelpID ;
      ,      Width           ;
      ,      WriteExpression ;
      ,      WriteMethod
Enddefine