#include <ere\include1v2.mqh>

//+------------------------------------------------------------------+
//|                                         MrktObsSet12_VWAPMTF.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 clrBlueViolet
#property indicator_width1 3

input ENUM_TIMEFRAMES TimeFrame       = PERIOD_M1;  // Time frame to use
input int N=20;
input int Shift=0;
//#define _vwap(_tf,_buff,_ind) iCustom(NULL,_tf,"MarketObservtionSet12\\MrktObsSet12_VWAP",N,Shift,PRICE_CLOSE,1.0,1.5,2.0,_buff,_ind)
#define _vwap(_tf,_buff,_ind) iCustom(NULL,_tf,"ere\\2SimpleVWAP_noSD",_buff,_ind)
double Buffer1[];

string sIndiName=WindowExpertName()+"_"+(string)TimeFrame+"_"+(string)N;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorShortName(sIndiName);
//--- indicator buffers mapping
    IndiGlobalIsLoaded(true);
    SetIndexBuffer(0 , Buffer1);
//---
   return(INIT_SUCCEEDED);
  }
void deinit(){
   IndiGlobalIsLoaded(false);
   IndiGlobalRemoveVarByString(sIndiName);
   CleanChart();
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
   //double vwap;
   int limit =rates_total-prev_calculated;//thelimit;
   if(prev_calculated>0) limit++;
   //limit=20;
      
   for(int i=limit-1; 1>=0; i--){
   
      int period = (rates_total-i)<14?(rates_total-1):14;
      Buffer1[i] = _vwap(TimeFrame,0,i);
      
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
