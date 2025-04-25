/*-------------------------------------------------------------------
   Name: Xi-Sessions.mq4
   Copyright ©2010, Xaphod, http://www.xaphod.com
   
   Description: 
     Draws a Sessions channel on the chart.
      -Use multiple instances for multiple sessions.
       Set parameter 'Session_Id' to a unique string for each Session_
      -Works with whole hours only. Session_OpenHour and Session_CloseHour must be at least 2 hours apart.
      -Optional vertical line and label for session open.
      -Optional vertical line and label for session close.
      -Option to extend high/low lines beyond the session end.
      -Optional session Box_
      -Optional range value label and box label below the session low.
      -Optional alert when the channel range goes above a set threshold.
     
   History:
   2014-05-27, Xaphod, v1.600
     - Updated for MT4 build 600 compatibility
   2011-03-23, Xaphod, v1.00
     - Added optional session boxes
     - Moved range label below session low
   2010-09-15, Xaphod, v0.95
     - Bug fix: Lines for data between shutdown and startup not being drawn on startup
     - Bug fix: Did not show one line if there were 2 open line on the same day
     - Clear indicator buffers on init
   2010-07-22, Xaphod, v0.94
     Changed name to Xi-Sessions
     Added IndicatorId to allow multiple instances of the indicator on a chart
     BugFix. Starting bar was off one period when Session_CloseOnHour=true
     Refactoring
   2010-06-10, Xaphod, v0.93
     Added Session high/low lines  
   2010-04-21, Xaphod, v0.92
     Added Session_CloseOnHour to select which bar to draw close on
   2010-04-20, Xaphod, v0.91
     Fixed CloseVLine_Style type was wrong
   2010-04-16 - Xaphod, v0.90
     Initial Release
-------------------------------------------------------------------*/
#property copyright "Copyright © 2010, xaphod.com"
#property link      "http://www.xaphod.com"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 PaleGoldenrod
#property indicator_color2 PaleGoldenrod
#property indicator_style1 3
#property indicator_style2 3

#property strict
#property version    "1.600"
#property description "Xi-Sessions is used to draw a trading sessions channel on the chart."
#property description " "
#property description "For multiple sessions on the same chart set the parameter 'Session_Id to a unique string for each Session"
#property description " "
#property description "Limitations: Works with whole hours only. Session_OpenHour and Session_CloseHour must be at least 2 hours apart."


// Constants
#define INDICATOR_NAME "Xi-Sessions"

// Indicator parameters
extern string    Session_Settings="";          /* Session Settings */
extern string    Session_Id="LO";              /* Session: Id */// Id of this indicator instance on the chart (String!)
extern int       Session_OpenHour=09;          /* Session: OpenHour*/// Session opening hour. 
extern int       Session_CloseHour=18;         /* Session: Close Hour */ // Session closing hour. NOTE: Session closes 1 min before this hour.
extern bool      Session_CloseOnHour=true;     /* Session: Close On-The-Hour */// True: Channel and vline on the first bar of the hour. False: On the previous bar.
extern int       Session_NrOfDays=5;           /* Session: Nr-Of-Days To Show */ // Nr of past days to draw the session channel for
extern int       Session_MaxTimeFrame=240;     /* Session: Maximum TimeFrame */ // Highest TF to show lines in 1,5,15,30,60,240,1440 etc

extern string    Range_Settings=""; /* Session Range Settings */
extern bool      Range_EnableAlarm=false;      /* Session Range: Enable Alert */ // Alarm for when the range exceeds the range thresholdvalue
extern int       Range_AlarmThreshold=40;      /* Session Range: Alert Threshold */ // Range alarm threshold 
extern bool      Range_ShowLabel=true;         /* Session Range: Show Label */ // Show label with current channel range
extern color     Range_LabelColor=Khaki;       /* Session Range: Label Color */ // Show label with current channel range

extern string    OpenVLine_Info="";            /* Session Open Vertical Line Settings */
extern bool      OpenVLine_Show=true;          /* Session Open: Show Vertical Line */ // Draw a vertical line to show the session open time
extern color     OpenVLine_Color=Gold;         /* Session Open: Vertical Line Color */ // Color of the session open time line
extern ENUM_LINE_STYLE OpenVLine_Style=2;      /* Session Open: Vertical Line Style */ // Style of the session open time line: Value 0-4
extern int       OpenVLine_Width=1;            /* Session Open: Vertical LineWidth */ // Width of the session open time line
extern string    OpenVLine_Label="Open";       /* Session Open: Vertical Line Lable*/ // Label for session open time line

extern string    CloseVLine_Info="";           /* Session Close Vertical Line Settings */
extern bool      CloseVLine_Show=true;         /* Session Close: Show Vertical Line*/ // Draw a vertical line to show the session close time
extern color     CloseVLine_Color=Gold;        /* Session Close: Vertical Line Color*/ // Color of the session close time line
extern ENUM_LINE_STYLE  CloseVLine_Style=2;    /* Session Close: Vertical Line Style */ // Style of the session close time line: Value 0-4
extern int       CloseVLine_Width=1;           /* Session Close: Vertical Line Width */ // Width of the session close time line
extern string    CloseVLine_Label="Close";     /* Session Close: Vertical Line Label */ // Label for session close time line 

extern string    HighLowLine_Info="";          /* Session High/Low Line Settings */
extern bool      HighLowLine_Show=true;        /* Session High/Low Lines: Show/Enable */ // Draw a vertical line to show the session close time
extern int       HighLowLine_EndTime=22;       /* Session High/Low Lines: End Time */ // Time to stop drawing the line
extern color     HighLowLine_Color=Gold;       /* Session High/Low Lines: Color */ // Color of the session close time line
extern ENUM_LINE_STYLE HighLowLine_Style=2;    /* Session High/Low Lines: Style */ // Style of the session close time line: Value 0-4
extern int       HighLowLine_Width=1;          /* Session High/Low Lines:  Width*/ // Width of the session close time line

extern string    Box_Info="";                  /* Session Box Settings */
extern bool      Box_Show=False;               /* Session Box: Show/Enable */  // Draw a vertical line to show the session close time
extern bool      Box_Fill=False;               /* Session Box: Fill */  // Color the inside of the box
extern color     Box_Color=LightGray;          /* Session Box: Color */ // Color of the session box
extern ENUM_LINE_STYLE  Box_Style=2;           /* Session Box: Style */ // Style of the session box lines: Value 0-4
extern int       Box_Width=1;                  /* Session Box: Width */  // Width of the session box lines
extern string    Box_Label="LO";               /* Session Box: Label */ // Label for session box 

// Indicator buffers
double miaHiBuffer[];
double miaLoBuffer[];

// Indicator module/global variables
bool mbRunOnce;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,miaHiBuffer);
   SetIndexLabel(0,Session_Id+" Session High");
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,miaLoBuffer);
   SetIndexLabel(1, Session_Id+" Session Low");
   SetIndexEmptyValue(1,EMPTY_VALUE);
   // Clear indicator buffers
   //for (int i=0; i<Bars; i++) {
   //  miaHiBuffer[i]=EMPTY_VALUE;
   //  miaLoBuffer[i]=EMPTY_VALUE;
   //}      
   //---- Set Indicator Name   
   IndicatorShortName(INDICATOR_NAME+Session_Id);
   mbRunOnce=false;   
   return(0);
}


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
  // Clear objects
  for(int i=ObjectsTotal()-1; i>-1; i--)
    if (StringFind(ObjectName(i),INDICATOR_NAME+Session_Id)>=0)  ObjectDelete(ObjectName(i));
  return(0);
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
  int iNewBars;
  int iCountedBars;   
 
  // Get unprocessed ticks
  iCountedBars=IndicatorCounted();
  if(iCountedBars < 0) return (-1);
  iNewBars=Bars-iCountedBars;
  
  if (Period()>Session_MaxTimeFrame) return(0);
  
  // Draw old sessions
  if (mbRunOnce==false || iNewBars>3) {
    DrawPreviousSessions();   
    mbRunOnce=true;
  } //endif
  
  // Draw current session
  DrawCurrentSession(iNewBars);
  
  // Exit
  return(0);
} //endfunction
//+------------------------------------------------------------------+


//-----------------------------------------------------------------------------
// function: GetSessionBars()
// Description: Get nr of bars for the Session_ There can be bars missing!
//-----------------------------------------------------------------------------
int GetSessionBars(int iSessionOpen, int iSessionClose, int iShift) {
  int i;
  int iNrOfBars=0;
    
  // Get nr of bars for the Session_
  for (i=iShift; i<(Bars-iShift); i++) {    
    // Check for beginning hour
    if (TimeHour(Time[i])==iSessionOpen && TimeMinute(Time[i])==0)  {
      return(iNrOfBars);
    }
    
    // Double check to account for missing bars and weekends
    if (IsSessionActive(iSessionOpen,iSessionClose,Time[i])==false) {
      iNrOfBars--; // Break in data. Remove last bar.
      return(iNrOfBars);
    }
    
    iNrOfBars++;
  } // endfor
  // Unable to complete. Return 0.
  return(0);
}


//-----------------------------------------------------------------------------
// function: DrawCurrentSession()
// Description: Draw lines for current Session_
//-----------------------------------------------------------------------------
void DrawCurrentSession(int iNewTicks) {
  int i;
  int iNrOfBars;
  double dSessionHigh;
  double dSessionLow;
  static int iRange=0;
  static bool bRangeAlarm=false;
  static bool bSessionActive=false;
 
  if (IsSessionActive(Session_OpenHour,Session_CloseHour-1,Time[0])==true) {
    
    if (bSessionActive==false) bSessionActive=true;
    
    // Get nr of bars for the Session_ There can be bars missing!
    iNrOfBars=GetSessionBars(Session_OpenHour,Session_CloseHour-1,0);
    
    // Find the highest and lowest data for specified nr of bars
    dSessionHigh=High[iHighest(NULL,0,MODE_HIGH,iNrOfBars+1,0)];
    dSessionLow=Low[iLowest(NULL,0,MODE_LOW,iNrOfBars+1,0)];

    // Draw session lines
    for(i=0; i<=iNrOfBars; i++) {
      miaHiBuffer[i]=dSessionHigh;
      miaLoBuffer[i]=dSessionLow;
    } //endfor
    
    // Draw lines
    if (OpenVLine_Show==true) {
      DrawLine(Time[iNrOfBars],OpenVLine_Style,OpenVLine_Width,OpenVLine_Color,"Open");
      if (StringLen(OpenVLine_Label)>0)
        DrawTextLabel(Time[iNrOfBars],Session_Id+" "+OpenVLine_Label,OpenVLine_Color);
    }
    
    // Draw session box
    if (Box_Show==True) { 
      DrawBox(Time[iNrOfBars], dSessionLow, Time[0]+Period()*60, dSessionHigh,Box_Style,Box_Color,Box_Fill);
    }
     
    // Draw range text label 
    if (Range_ShowLabel==true) {
      if (Box_Show) 
        DrawRangeValue(Box_Label,PriceToPips(dSessionHigh-dSessionLow),Time[iNrOfBars/2],dSessionLow,Range_LabelColor);
      else
        DrawRangeValue("",PriceToPips(dSessionHigh-dSessionLow),Time[iNrOfBars/2],dSessionLow,Range_LabelColor);
    }
    
    // Range alert
    iRange=(int)MathRound(PriceToPips(dSessionHigh-dSessionLow));
    if (iRange>Range_AlarmThreshold && Range_EnableAlarm==true) {
      if (bRangeAlarm==false) {
        Alert(INDICATOR_NAME+Session_Id,", ",Symbol(),", Range: ",iRange);
        bRangeAlarm=true;
      } //endif
    } 
    else {
      bRangeAlarm=false;  
    } //endif
  } //endif
  else {
  
    if (bSessionActive==true) {
      bSessionActive=false;
      DrawPreviousSessions();
    }
  }
} //endfunction


//-----------------------------------------------------------------------------
// function: DrawPreviousSessions()
// Description: Draw lines for previous days sessions in chart.
//-----------------------------------------------------------------------------
void DrawPreviousSessions() {
  int i,j;
  int iNrOfBars;
  int iCloseOnHour;
  double dSessionHigh;
  double dSessionLow;
  int iNrOfDays=0;
  datetime tEndTime;
  
  // Clear the indicator buffers
  for (i=0; i<Bars; i++) {
    miaHiBuffer[j]=EMPTY_VALUE;
    miaLoBuffer[j]=EMPTY_VALUE;   
  }
 
  // Set the closing bar. On hour bar or on previous bar.
  if (Session_CloseOnHour==True) 
    iCloseOnHour=0;
  else
    iCloseOnHour=1;
  
  // Draw asian session for old data
  i=0;
  while (i<Bars && iNrOfDays<Session_NrOfDays) {
    if (TimeHour(Time[i])==Session_CloseHour && TimeMinute(Time[i])==0) {
        
      // Get nr of bars for the Session_ There can be bars missing!
      iNrOfBars=GetSessionBars(Session_OpenHour,Session_CloseHour,i);
            
      // Find the highest and lowest data for specified nr of bars
      dSessionHigh=High[iHighest(NULL,0,MODE_HIGH,iNrOfBars,i+1)];
      dSessionLow=Low[iLowest(NULL,0,MODE_LOW,iNrOfBars,i+1)];
      
      // Draw session lines
      for(j=i+iCloseOnHour; j<=i+iNrOfBars; j++) {    
        miaHiBuffer[j]=dSessionHigh;
        miaLoBuffer[j]=dSessionLow;    
      } //endfor    
      
      // Draw lines
      if (OpenVLine_Show==true) {
        DrawLine(Time[i+iNrOfBars],OpenVLine_Style,OpenVLine_Width,OpenVLine_Color,"Open");
        if (StringLen(OpenVLine_Label)>0)
          DrawTextLabel(Time[i+iNrOfBars],Session_Id+" "+OpenVLine_Label,OpenVLine_Color);
      }
      if (CloseVLine_Show==true) {
        DrawLine(Time[i]-Period()*60*iCloseOnHour,CloseVLine_Style,CloseVLine_Width,CloseVLine_Color,"Close");
        if (StringLen(CloseVLine_Label)>0)
          DrawTextLabel(Time[i]-Period()*60*iCloseOnHour,Session_Id+" "+CloseVLine_Label,CloseVLine_Color);
      }
      
      // Draw range text label 
      if (Range_ShowLabel==true) { 
        if (Box_Show) 
          DrawRangeValue(Box_Label,PriceToPips(dSessionHigh-dSessionLow),Time[i+iNrOfBars/2],dSessionLow,Range_LabelColor);
        else
          DrawRangeValue("",PriceToPips(dSessionHigh-dSessionLow),Time[i+iNrOfBars/2],dSessionLow,Range_LabelColor);
      }
      
      // Draw session High/Low lines
      if (HighLowLine_Show==true) { 
        tEndTime=StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+(string)HighLowLine_EndTime+":00");
        DrawHLine(dSessionHigh, Time[i]-Period()*60, tEndTime, "High"+(string)(iNrOfDays+1), HighLowLine_Style, HighLowLine_Width, HighLowLine_Color);
        DrawHLine(dSessionLow, Time[i]-Period()*60, tEndTime, "Low"+(string)(iNrOfDays+1), HighLowLine_Style, HighLowLine_Width, HighLowLine_Color);
      }
      
      // Draw session box
      if (Box_Show==True) { 
        DrawBox(Time[i+iNrOfBars], dSessionLow, Time[i]-Period()*60*iCloseOnHour, dSessionHigh,Box_Style,Box_Color,Box_Fill);
      }
      
      iNrOfDays++;  
    } //endif
  i++;
  } //end while
}


//-----------------------------------------------------------------------------
// function: DrawRangeValue()
// Description: Draw range text label below the high channel line
//-----------------------------------------------------------------------------
int DrawRangeValue(string sLabel, double dRange, datetime tTime, double dPrice, color cTextColor) {
  double tTextPos=0;
  string sLineId;
  string sRange;
  
  if (StringLen(sLabel)>0)
    sRange=sLabel+" "+DoubleToStr(dRange,PipDigits());
  else
    sRange=DoubleToStr(dRange,PipDigits());
  sLineId=INDICATOR_NAME+Session_Id+"_Range_"+TimeToStr(tTime,TIME_DATE );
  
  if (ObjectFind(sLineId)>=0 ) ObjectDelete(sLineId);      
  ObjectCreate(sLineId, OBJ_TEXT, 0, tTime, dPrice); 
  ObjectSet(sLineId, OBJPROP_BACK, false);
  ObjectSetText(sLineId, sRange , 8, "Arial", cTextColor);
  return(0);
}


//-----------------------------------------------------------------------------
// function: IsSessionActive()
// Description: Check if session is open. If DST is enabled add 1hr to the market time
//-----------------------------------------------------------------------------
int IsSessionActive(int iSessionOpen, int iSessionClose, datetime dBarTime) {
   int iBarHour; 
   int iBarMinute;
   bool bResult;
   iBarHour = TimeHour(dBarTime);
   iBarMinute = TimeMinute(dBarTime);
      
   // Check if market is open.
   if (iSessionOpen<iSessionClose) { 
      if (iBarHour>=iSessionOpen && iBarHour<=iSessionClose) 
        bResult=true; // Open & close before midnight
      else 
        bResult=false;
   }   
   else {  
     if (iBarHour>=iSessionOpen || iBarHour<=iSessionClose) 
       bResult=true; // Open before midnight and close after midnight
     else 
       bResult=false;
   }
   return(bResult);     
}


//-----------------------------------------------------------------------------
// function: DrawLine()
// Description: Draw a horizontal line at specific price
//----------------------------------------------------------------------------- 
int DrawLine(datetime tTime, int iLineStyle, int iLineWidth, color cLineColor, string sId) {
  string sLineId;
  
  // Set Line object ID  
  sLineId=INDICATOR_NAME+Session_Id+"_"+sId+"_"+TimeToStr(tTime,TIME_DATE )+"_"+(string)TimeHour(tTime);
  
  // Draw line
  if (ObjectFind(sLineId)>=0 ) ObjectDelete(sLineId);
  ObjectCreate(sLineId, OBJ_TREND, 0, tTime, 0, tTime, 10); 
  //ObjectCreate(sLineId, OBJ_VLINE, 0, tTime, 0); 
  ObjectSet(sLineId, OBJPROP_STYLE, iLineStyle);     
  ObjectSet(sLineId, OBJPROP_WIDTH, iLineWidth);
  ObjectSet(sLineId, OBJPROP_BACK, true);
  ObjectSet(sLineId, OBJPROP_COLOR, cLineColor);    
  return(0);
}


//-----------------------------------------------------------------------------
// function: DrawTextLabel()
// Description: Draw a text label for a line
//-----------------------------------------------------------------------------
int DrawTextLabel(datetime tTime, string sLabel, color cLineColor) {
  double tTextPos=0;
  string sLineLabel="";
  string sLineId;
  
  // Set Line object ID  
  sLineId=INDICATOR_NAME+Session_Id+"_"+sLabel+"_"+TimeToStr(tTime,TIME_DATE )+"_"+(string)TimeHour(tTime);
  
  //Set position of text label
  tTextPos=WindowPriceMin()+(WindowPriceMax()-WindowPriceMin())/2;
  //PrintD("tTextPos: "+tTextPos);
  // Draw or text label  
  if (ObjectFind(sLineId)>=0 ) ObjectDelete(sLineId);      
  ObjectCreate(sLineId, OBJ_TEXT, 0, tTime, tTextPos);    
  ObjectSet(sLineId, OBJPROP_ANGLE, 90);
  ObjectSet(sLineId, OBJPROP_BACK, true);
  ObjectSetText(sLineId, sLabel , 8, "Arial", cLineColor);
 
  return(0);
}


//-----------------------------------------------------------------------------
// function: DrawHLine()
// Description: Draw a horizontal line at specific price
//----------------------------------------------------------------------------- 
int DrawHLine(double dPrice, datetime tStart, datetime tEnd, string sLineId, int iLineStyle, int iLineWidth, color cLineColor) {
  
  // Set Line object ID  
  sLineId=INDICATOR_NAME+Session_Id+"_"+sLineId;
  
  // Draw line
  if (ObjectFind(sLineId)>=0 ) ObjectDelete(sLineId);
  ObjectCreate(sLineId, OBJ_TREND, 0, tStart, dPrice, tEnd, dPrice); 
  ObjectSet(sLineId, OBJPROP_STYLE, iLineStyle);     
  ObjectSet(sLineId, OBJPROP_WIDTH, iLineWidth);
  ObjectSet(sLineId, OBJPROP_BACK, true);
  ObjectSet(sLineId, OBJPROP_RAY, false);  
  ObjectSet(sLineId, OBJPROP_COLOR, cLineColor);    
  return(0);
}


//-----------------------------------------------------------------------------
// function: DrawBox()
// Description: Draw a box
//----------------------------------------------------------------------------- 
void DrawBox(datetime tTime1, double dPrice1, datetime tTime2, double dPrice2, int iStyle=STYLE_SOLID, color cBox=LightGray, bool bFill=False ) {
  string sName=INDICATOR_NAME+Session_Id+"_"+TimeToStr(tTime1);  
  if (ObjectFind(sName)<0 ) {
    // Create Box
    ObjectCreate(sName, OBJ_RECTANGLE, 0, tTime1, dPrice1, tTime2, dPrice2); 
    ObjectSet(sName, OBJPROP_STYLE, iStyle);     
    ObjectSet(sName, OBJPROP_WIDTH, 1);
    ObjectSet(sName, OBJPROP_BACK, bFill);
    ObjectSet(sName, OBJPROP_COLOR, cBox);
  }
  else {
    // Move Box
    ObjectSet(sName, OBJPROP_TIME1 , tTime1);
    ObjectSet(sName, OBJPROP_PRICE1, dPrice1);
    ObjectSet(sName, OBJPROP_TIME2 , tTime2);
    ObjectSet(sName, OBJPROP_PRICE2, dPrice2);
  }
  
  return;
}


//-----------------------------------------------------------------------------
// function: PriceToPips()
// Description: Convert a proce difference to pips.
//-----------------------------------------------------------------------------
double PriceToPips(double dPrice) {

  if (Digits==2 || Digits==3) 
    return(dPrice/0.01); 
  else if (Digits==4 || Digits==5) 
    return(dPrice/0.0001); 
  else
    return(dPrice);            
  
  return(dPrice);
} // end funcion()


//-----------------------------------------------------------------------------
// function: PipDigits()
// Description: Digits of the pips
//-----------------------------------------------------------------------------
int PipDigits() {

 if (Digits==3 || Digits==5) 
    return(1); 
  else if (Digits==2 || Digits==4) 
    return(0); 
  else
    return(0);            
} // end funcion()


