/*-------------------------------------------------------------------
   Name: Xi-Sessions.mq4
   Copyright ©2010, Xaphod, http://forexwhiz.appspot.com
   
   Description: 
     Draws a Sessions channel on the chart.
      -Use multiple instances for multiple sessions.
       Set parameter 'Session_IndicatorId' to a unique string for each session_
      -Works with whole hours only. Session_OpenHour and Session_CloseHour must be at least 2 hours apart.
      -Optional vertical line and label for session open_
      -Optional vertical line and label for session close_
      -Option to extend high/low lines beyond the session end.
      -Optional session box_
      -Optional range value label and box label below the session low.
      -Optional alert when the channel range goes above a set threshold.
     
   History:
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
     BugFix_ Starting bar was off one period when Session_CloseOnHour=true
     Refactoring
   2010-06-10, Xaphod, v0.93
     Added Session high/low lines  
   2010-04-21, Xaphod, v0.92
     Added Session_CloseOnHour to select which bar to draw close on
   2010-04-20, Xaphod, v0.91
     Fixed CloseVLine_Style type was wrong
   2010-04-16 - Xaphod, v0.90
     Initial Release
   2017-04-06 added extra levels - cja  
-------------------------------------------------------------------*/
#property copyright "Copyright © 2010, Xaphod"
#property link      "http://forexwhiz.appspot.com"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 clrPaleGoldenrod
#property indicator_color2 clrPaleGoldenrod
#property indicator_style1 3
#property indicator_style2 3

#property indicator_color3 clrAqua
#property indicator_color4 clrFireBrick
#property indicator_style3 3
#property indicator_style4 3

#property indicator_color5 clrGray
#property indicator_style5 2



// Constants
#define INDICATOR_NAME "Xi-Sessions"
#define INDICATOR_VERSION "v1.00"

// Indicator parameters
extern string    Session_Info="<< Session >>";
extern string    Session_IndicatorId="LO";     // Id of this indicator instance on the chart (String!)
extern int       Session_OpenHour=09;          // Session opening hour. 
extern int       Session_CloseHour=18;         // Session closing hour. NOTE: Session closes 1 min before this hour.
extern bool      Session_CloseOnHour=true;     // True: Channel and vline on the first bar of the hour. False: On the previous bar.
extern int       Session_NrOfDays=5;           // Nr of past days to draw the session channel for
extern int       Session_MaxTimeFrame=240;     // Highest TF to show lines in 1,5,15,30,60,240,1440 etc

extern string    Range_Info="<< Session Range >>";
extern bool      Range_EnableAlarm=false;      // Alarm for when the range exceeds the range thresholdvalue
extern int       Range_AlarmThreshold=40;      // Range alarm threshold 
extern bool      Range_ShowLabel=true;         // Show label with current channel range
extern color     Range_LabelColor=Khaki;       // Show label with current channel range

extern string    OpenVLine_Info="<< Vertical line on open bar >>";
extern bool      OpenVLine_Show=true;          // Draw a vertical line to show the session open time
extern color     OpenVLine_Color=Gold;         // Color of the session open time line
extern int       OpenVLine_Style=2;            // Style of the session open time line: Value 0-4
extern int       OpenVLine_Width=1;            // Width of the session open time line
extern string    OpenVLine_Label="Session Open"; // Label for session open time line

extern string    CloseVLine_Info="<< Vertical line on close bar>>";
extern bool      CloseVLine_Show=true;         // Draw a vertical line to show the session close time
extern color     CloseVLine_Color=Gold;        // Color of the session close time line
extern int       CloseVLine_Style=2;           // Style of the session close time line: Value 0-4
extern int       CloseVLine_Width=1;           // Width of the session close time line
extern string    CloseVLine_Label="Session Close";  // Label for session close time line 

extern string    HighLowLine_Info="<< Session High/Low lines >>";
extern bool      HighLowLine_Show=true;        // Draw a vertical line to show the session close time
extern int       HighLowLine_EndTime=22;       // Time to stop drawing the line
extern color     HighLowLine_Color=Gold;       // Color of the session close time line
extern int       HighLowLine_Style=2;          // Style of the session close time line: Value 0-4
extern int       HighLowLine_Width=1;          // Width of the session close time line

extern string    Box_Info="<< Session Box >>";
extern bool      Box_Show=False;                // Draw a vertical line to show the session close time
extern bool      Box_Fill=False;                // Color the inside of the box
extern color     Box_Color=LightGray;          // Color of the session box
extern int       Box_Style=2;                  // Style of the session box lines: Value 0-4
extern int       Box_Width=1;                  // Width of the session box lines
extern string    Box_Label="LO";            // Label for session box 

// Indicator buffers
double miaHiBuffer[];
double miaLoBuffer[];
double miaHiBuffer1[];
double miaLoBuffer1[];
double midBuffer[];

// Indicator module/global variables
bool mbRunOnce;
 

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {

  
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,miaHiBuffer);
   SetIndexLabel(0,"Asian Session High");
   SetIndexEmptyValue(0,EMPTY_VALUE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,miaLoBuffer);
   SetIndexLabel(1, "Asian Session Low");
   SetIndexEmptyValue(1,EMPTY_VALUE);
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,miaHiBuffer1);
   SetIndexLabel(2,"Asian Session High x2");
   SetIndexEmptyValue(2,EMPTY_VALUE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,miaLoBuffer1);
   SetIndexLabel(3, "Asian Session Low x2");
   SetIndexEmptyValue(3,EMPTY_VALUE);
   
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,midBuffer);
   SetIndexLabel(4,"Asian Session High x2");
   SetIndexEmptyValue(4,EMPTY_VALUE);
   // Clear indicator buffers
   for (int i=0; i<Bars; i++) {
     miaHiBuffer[i]=EMPTY_VALUE;
     miaLoBuffer[i]=EMPTY_VALUE;
     miaHiBuffer1[i]=EMPTY_VALUE;
     miaLoBuffer1[i]=EMPTY_VALUE;
     midBuffer[i]=EMPTY_VALUE;
   }      
   //---- Set Indicator Name   
   IndicatorShortName(INDICATOR_NAME+Session_IndicatorId+" "+INDICATOR_VERSION);
   mbRunOnce=false;   
   return(0);
}


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
  // Clear objects
  for(int i=ObjectsTotal()-1; i>-1; i--)
    if (StringFind(ObjectName(i),INDICATOR_NAME+Session_IndicatorId)>=0)  ObjectDelete(ObjectName(i));
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
// Description: Get nr of bars for the session_ There can be bars missing!
//-----------------------------------------------------------------------------
int GetSessionBars(int iSessionOpen, int iSessionClose, int iShift) {
  int i;
  int iNrOfBars=0;
    
  // Get nr of bars for the session_
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
  // Unable to complete_ Return 0.
  return(0);
}


//-----------------------------------------------------------------------------
// function: DrawCurrentSession()
// Description: Draw lines for current session_
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
    
    // Get nr of bars for the session_ There can be bars missing!
    iNrOfBars=GetSessionBars(Session_OpenHour,Session_CloseHour-1,0);
    
    // Find the highest and lowest data for specified nr of bars
    dSessionHigh=High[iHighest(NULL,0,MODE_HIGH,iNrOfBars+1,0)];
    dSessionLow=Low[iLowest(NULL,0,MODE_LOW,iNrOfBars+1,0)];

    // Draw session lines
    for(i=0; i<=iNrOfBars; i++) {
      miaHiBuffer[i]=dSessionHigh;
      miaLoBuffer[i]=dSessionLow;
      miaHiBuffer1[i]=dSessionHigh+(dSessionHigh-dSessionLow);
      miaLoBuffer1[i]=dSessionLow-(dSessionHigh-dSessionLow);
      midBuffer[i]=dSessionLow+(dSessionHigh-dSessionLow)/2;
    } //endfor
    
    // Draw lines
    if (OpenVLine_Show==true) {
      DrawLine(Time[iNrOfBars],OpenVLine_Style,OpenVLine_Width,OpenVLine_Color,"Open");
      if (StringLen(OpenVLine_Label)>0)
        DrawTextLabel(Time[iNrOfBars],OpenVLine_Label,OpenVLine_Color);
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
    iRange=PriceToPips(dSessionHigh-dSessionLow);
    if (iRange>Range_AlarmThreshold && Range_EnableAlarm==true) {
      if (bRangeAlarm==false) {
        Alert(INDICATOR_NAME+Session_IndicatorId,", ",Symbol(),", Range: ",iRange);
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
  //string sLineId;
  //string sRange;
  datetime tEndTime;
  
  // Clear the indicator buffers
  for (i=0; i<Bars; i++) {
    miaHiBuffer[j]=EMPTY_VALUE;
    miaLoBuffer[j]=EMPTY_VALUE;   
    miaHiBuffer1[j]=EMPTY_VALUE;
    miaLoBuffer1[j]=EMPTY_VALUE;
    midBuffer[i]=EMPTY_VALUE;   
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
        
      // Get nr of bars for the session_ There can be bars missing!
      iNrOfBars=GetSessionBars(Session_OpenHour,Session_CloseHour,i);
            
      // Find the highest and lowest data for specified nr of bars
      dSessionHigh=High[iHighest(NULL,0,MODE_HIGH,iNrOfBars,i+1)];
      dSessionLow=Low[iLowest(NULL,0,MODE_LOW,iNrOfBars,i+1)];
      
      // Draw session lines
      for(j=i+iCloseOnHour; j<=i+iNrOfBars; j++) {    
        miaHiBuffer[j]=dSessionHigh;
        miaLoBuffer[j]=dSessionLow;    
       miaHiBuffer1[j]=dSessionHigh+(dSessionHigh-dSessionLow);
       miaLoBuffer1[j]=dSessionLow-(dSessionHigh-dSessionLow);
       midBuffer[j]=dSessionLow+(dSessionHigh-dSessionLow)/2; 
      } //endfor    
      
      // Draw lines
      if (OpenVLine_Show==true) {
        DrawLine(Time[i+iNrOfBars],OpenVLine_Style,OpenVLine_Width,OpenVLine_Color,"Open");
        if (StringLen(OpenVLine_Label)>0)
          DrawTextLabel(Time[i+iNrOfBars],OpenVLine_Label,OpenVLine_Color);
      }
      if (CloseVLine_Show==true) {
        DrawLine(Time[i]-Period()*60*iCloseOnHour,CloseVLine_Style,CloseVLine_Width,CloseVLine_Color,"Close");
        if (StringLen(CloseVLine_Label)>0)
          DrawTextLabel(Time[i]-Period()*60*iCloseOnHour,CloseVLine_Label,CloseVLine_Color);
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
        tEndTime=StrToTime(TimeToStr(Time[i],TIME_DATE)+" "+HighLowLine_EndTime+":00");
        DrawHLine(dSessionHigh, Time[i]-Period()*60, tEndTime, "High"+iNrOfDays+1, HighLowLine_Style, HighLowLine_Width, HighLowLine_Color);
        DrawHLine(dSessionLow, Time[i]-Period()*60, tEndTime, "Low"+iNrOfDays+1, HighLowLine_Style, HighLowLine_Width, HighLowLine_Color);
        
        DrawHLine(dSessionHigh+(dSessionHigh-dSessionLow), Time[i]-Period()*60, tEndTime, "High"+iNrOfDays+2, HighLowLine_Style, HighLowLine_Width, HighLowLine_Color);
        DrawHLine(dSessionLow-(dSessionHigh-dSessionLow), Time[i]-Period()*60, tEndTime, "Low"+iNrOfDays+2, HighLowLine_Style, HighLowLine_Width, HighLowLine_Color);
     
        DrawHLine(dSessionLow+(dSessionHigh-dSessionLow)/2, Time[i]-Period()*60, tEndTime, "Mid"+iNrOfDays+2, HighLowLine_Style, HighLowLine_Width, HighLowLine_Color);
 
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
int DrawRangeValue(string sLabel, double dRange, double tTime, double dPrice, color cTextColor) {
  double tTextPos=0;
  string sLineId;
  string sRange;
  
  if (StringLen(sLabel)>0)
    sRange=sLabel+" "+DoubleToStr(dRange,PipDigits());
  else
    sRange=DoubleToStr(dRange,PipDigits());
  sLineId=INDICATOR_NAME+Session_IndicatorId+"_Range_"+TimeToStr(tTime,TIME_DATE );
  
  if (ObjectFind(sLineId)>=0 ) ObjectDelete(sLineId);      
  ObjectCreate(sLineId, OBJ_TEXT, 0, tTime, dPrice); 
  ObjectSet(sLineId, OBJPROP_BACK, false);
  ObjectSetText(sLineId, sRange , 8, "Arial", cTextColor);
  return(0);
}


//-----------------------------------------------------------------------------
// function: IsSessionActive()
// Description: Check if session is open_ If DST is enabled add 1hr to the market time
//-----------------------------------------------------------------------------
int IsSessionActive(int iSessionOpen, int iSessionClose, datetime dBarTime) {
   int iBarHour; 
   int iBarMinute;
   bool bResult;
   iBarHour = TimeHour(dBarTime);
   iBarMinute = TimeMinute(dBarTime);
      
   // Check if market is open_
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
int DrawLine(double tTime, int iLineStyle, int iLineWidth, color cLineColor, string sId) {
  string sLineId;
  
  // Set Line object ID  
  sLineId=INDICATOR_NAME+Session_IndicatorId+"_"+sId+"_"+TimeToStr(tTime,TIME_DATE )+"_"+TimeHour(tTime);
  
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
int DrawTextLabel(double tTime, string sLabel, color cLineColor) {
  double tTextPos=0;
  string sLineLabel="";
  string sLineId;
  //color cTextColor;
  
  // Set Line object ID  
  sLineId=INDICATOR_NAME+Session_IndicatorId+"_"+sLabel+"_"+TimeToStr(tTime,TIME_DATE )+"_"+TimeHour(tTime);
  
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
  sLineId=INDICATOR_NAME+Session_IndicatorId+"_"+sLineId;
  
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
int DrawBox(datetime tTime1, double dPrice1, datetime tTime2, double dPrice2, int iStyle=STYLE_SOLID, color cBox=LightGray, bool bFill=False ) {
  string sName=INDICATOR_NAME+Session_IndicatorId+"_"+TimeToStr(tTime1);  
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
  return(0);
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
} // end funcion()


//-----------------------------------------------------------------------------
// function: PipDigits()
// Description: Digits of the pips
//-----------------------------------------------------------------------------
double PipDigits() {

 if (Digits==3 || Digits==5) 
    return(1); 
  else if (Digits==2 || Digits==4) 
    return(0); 
  else
    return(0);            
} // end funcion()


