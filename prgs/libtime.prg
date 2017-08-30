* libTime
* created 2009/07/20 by Olaf Doschke - mailto:olaf.doschke@googlemail.com

#Define TIME_ZONE_ID_UNKNOWN  0
#Define TIME_ZONE_ID_STANDARD 1
#Define TIME_ZONE_ID_DAYLIGHT 2

Define Class pakTime As Package
   Procedure Init()
      Declare Integer GetTimeZoneInformation In Kernel32 ;
         STRING @ TimeZoneStruct
   Endproc

   Procedure UTCTime(ttDatetime As Datetime)
      * compute UTC Datetime of now or any datetime (interpreted as local time)
      Local lcTZStruct, lnTimezoneID, lnUTCOffset, lnDaylightBias

      ttDatetime     = Evl(ttDatetime,Datetime())
      lcTZStruct     = Space(172) && sizeof(TIME_ZONE_INFORMATION)
      lnTimezoneID   = GetTimeZoneInformation(@lcTZStruct)
      lnUTCOffset    = CToBin( Left(lcTZStruct,4),'4RS')
      lnDaylightBias = CToBin(Right(lcTZStruct,4),'4RS')

      * apply the daylight savings bias if it's not standard time
      * might need adjustment, if lnTimezoneID is TIME_ZONE_ID_UNKNOWN
      If Not lnTimezoneID = TIME_ZONE_ID_STANDARD
         lnUTCOffset = lnUTCOffset + lnDaylightBias
      Endif

      Return ttDatetime + lnUTCOffset * 60
   Endproc
Enddefine
