Lparameters tcPjx
Local lcPjx
lcPjx  = Iif(Vartype(tcPjx) == "C", Alltrim(tcPjx), _vfp.ActiveProject.Name)
Return PackAndCompile(lcPjx)

Procedure PackAndCompile()
   Lparameters tcProject
   Local lcXcx
   If !File(tcProject) Or Used(tcProject)
      Return .F.
   EndIf
   Use (tcProject) In Select("tabProject") Alias tabProject Again Shared
   Select tabProject
   Scan For !tabProject.Exclude And (tabProject.Type="V" Or tabProject.Type="K")
      lcXcx = Alltrim(tabProject.Name)
      If !(Substr(lcXcx,2,1)=":" Or Left(lcXcx,2)="\\")
         lcXcx = Justpath(tcProject) + lcXcx
      Endif
      If File(lcXcx)
         Use (lcXcx) In 0 Exclusive
         Pack Memo In (Juststem(lcXcx))
         Use in Select(JustStem(lcXcx))
         Compile Classlib (lcXcx)
      Endif
   Endscan
   Use In Select ("tabProject")
Endproc