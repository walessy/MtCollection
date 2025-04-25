//+------------------------------------------------------------------+
//|                              BaseCurrencyCorrelationIndiComp.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

//#define PRINT10_ON //definig and adding events to charts

#ifdef PRINT10_ON
#define PRINT10(text) Print(text)
#else
#define PRINT10(text)
#endif


#define SW_MAXIMIZE     3
#define SW_RESTORE      9
#include <Winuser32.mqh>

#import "user32.dll"
#import

extern int clickDelay = 300;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
  
   EventSetMillisecondTimer(2000);
//---
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
   EventKillTimer();
//--- The first way to get a deinitialization reason code
   Print(__FUNCTION__," Deinitialization reason code = ",reason);
//--- The second way to get a deinitialization reason code
   Print(__FUNCTION__," _UninitReason = ",getUninitReasonText(_UninitReason));
//--- The third way to get a deinitialization reason code  
   Print(__FUNCTION__," UninitializeReason() = ",getUninitReasonText(UninitializeReason()));
  }
  
string getUninitReasonText(int reasonCode)
  {
   string text="";
//---
   switch(reasonCode)
     {
      case REASON_ACCOUNT:
         text="Account was changed";break;
      case REASON_CHARTCHANGE:
         text="Symbol or timeframe was changed";break;
      case REASON_CHARTCLOSE:
         text="Chart was closed";break;
      case REASON_PARAMETERS:
         text="Input-parameter was changed";break;
      case REASON_RECOMPILE:
         text="Program "+__FILE__+" was recompiled";break;
      case REASON_REMOVE:
         text="Program "+__FILE__+" was removed from chart";break;
      case REASON_TEMPLATE:
         text="New template was applied to chart";break;
      default:text="Another reason";
     }
//---
   return text;
  }
  
void OnTimer(){
   //Print("Saving symbol template.");
   ChartSaveTemplate(0,Symbol());
   ChartRedraw();
   //ChartApplyTemplate(0,Symbol());
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
      int hwnd = GetParent(WindowHandle(_Symbol, _Period));
      
      if(id>CHARTEVENT_CUSTOM)
        {
         PRINT10("Got broadcast message from a chart with id = "+(string)lparam);
        }
      else if (id==4){//THIS IS MY CUSOM DOU|BLE CLICK
      
        //beginning of: detection of a doubleclick
         static ulong ClickTimeMemory ; //static is crucial to remember ClickTimeMemory's content next time OnChartEvent() is called

         ulong ClickTime = GetTickCount() ; //GetTickCount() uses milliseconds - it's not necessary to use GetMicrosecondCount()
         
         if(ClickTime > ClickTimeMemory && ClickTime < ClickTimeMemory + clickDelay)   //the second click should appear within 300 milliseconds after the first click. That's 0.3 seconds - that's about the typical delay of the second click relative to the first click when making a doubleclick 
         {
            
            //Alert("just detected a doubleclick") ;
            
            if(!IsZoomed(hwnd)) ShowWindow(hwnd, SW_MAXIMIZE);
            else ShowWindow(hwnd, SW_RESTORE);
            }
       
         //***
       
         ClickTimeMemory = ClickTime ;            
            
         
      }
      else
        {
         //--- We read a text message in the event
         string info=sparam;
         PRINT10("Handle the user event with the ID = "+(string)id);
         //--- Display a message in a label
         //ObjectSetString(0,labelID,OBJPROP_TEXT,sparam);
         //ChartRedraw();// Forced redraw all chart objects
        }
  }
//+------------------------------------------------------------------+
