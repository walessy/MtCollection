//+------------------------------------------------------------------------------------------------------------------------------------------------------+
//|                                                                                                                                         ClickMax.mq4 |
//|                                                                                                                           Copyright(c) 2016 MaryJane |
//+------------------------------------------------------------------------------------------------------------------------------------------------------+
#property copyright "Copyright (c) 2016, MaryJane"
#property version "2.0"
#property description "Double click to change maximize/collapse chart"
#property description "\nV2.0 modified by Tamir Sasson"
#property description "- Added option for a triple click"
#property description "- Added delay time setting between clicks"

#property strict
#property indicator_chart_window
// Changes made by Tamir Sasson, 11/05/2017
//+--- INPUT PARAMETERS ---------------------------------------------------------------------------------------------------------------------------------+
input uint clickDelay = 300; //Delay time between clicks (ms)
input bool TripleClick = false; //Triple click instead of double click
//+------------------------------------------------------------------------------------------------------------------------------------------------------+
// --- CONSTANTS
#define SW_MAXIMIZE     3
#define SW_RESTORE      9
//+------------------------------------------------------------------------------------------------------------------------------------------------------+
// --- LIBRARIES
#include <Winuser32.mqh>
//+------------------------------------------------------------------------------------------------------------------------------------------------------+
// --- DLLs
#import "user32.dll"
#import
//+------------------------------------------------------------------------------------------------------------------------------------------------------+
// --- PROGRAM
//+------------------------------------------------------------------------------------------------------------------------------------------------------+
int      OnInit                     () {
 
	if(!IsDllsAllowed()) {
	   
	   Alert("You have to allow DLLs for ClickMax to work");
	   return INIT_FAILED; 
	
	} else return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------------------------------------------------------------------------------------------+
void     OnDeinit                   (const int Reason) {}
//+------------------------------------------------------------------------------------------------------------------------------------------------------+
int      OnCalculate                (const int rates_total,
                                     const int prev_calculated,
                                     const datetime &time[],
                                     const double &open[],
                                     const double &high[],
                                     const double &low[],
                                     const double &close[],
                                     const long &tick_volume[],
                                     const long &volume[],
                                     const int &spread[]) {

   // ---------------------------------------------------------------------------------------------------------------------------------------------------+
   // (mandatory to have this in an indicator)                                                                                                                                        |
   // ---------------------------------------------------------------------------------------------------------------------------------------------------+
   
   return 0;
}
//+------------------------------------------------------------------------------------------------------------------------------------------------------+
void     OnChartEvent               (const int id, const long &lparam, const double &dparam, const string &sparam) {

   
   static uint clicktime      = GetTickCount();
   static int  clickcount     = 0;  //TAMIR 11052017
   bool        doubleclick    = false;
         
   int hwnd = GetParent(WindowHandle(_Symbol, _Period));
   
   if(id == CHARTEVENT_CLICK) {
      if(GetTickCount() - clicktime < clickDelay) clickcount++;   //TAMIR 11052017 - count number of clicks
      else clickcount = 0;
      if((TripleClick && clickcount==2) || 
        (!TripleClick && clickcount==1))    //TAMIR 11052017 - differtiate between double and triple clicks
         doubleclick = true;
      clicktime = GetTickCount();
      
      if(doubleclick) {
         
         if(!IsZoomed(hwnd)) ShowWindow(hwnd, SW_MAXIMIZE);
         else ShowWindow(hwnd, SW_RESTORE);
         clickcount     = 0;
      }
   }
}
//+------------------------------------------------------------------------------------------------------------------------------------------------------+