//+------------------------------------------------------------------+
//|                                              CandleCountdown.mq4 |
//|                                                      nicholishen |
//|                                   www.reddit.com/u/nicholishenFX |
//+------------------------------------------------------------------+
#property copyright "nicholishen"
#property link      "www.reddit.com/u/nicholishenFX"
#property version   "1.00"
#property strict
#property indicator_chart_window
#include <ChartObjects\ChartObjectsTxtControls.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
CChartObjectLabel label;
int OnInit()
{
//--- indicator buffers mapping
   label.Create(0,"Timer",0,0,0);
   label.Color(clrRed);
   label.FontSize(15);
   label.Anchor(ANCHOR_RIGHT_UPPER);
   label.Corner(CORNER_RIGHT_UPPER);
   Timer();
   EventSetMillisecondTimer(100);
//---
   return(INIT_SUCCEEDED);
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
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//---
   Timer();

}
//+------------------------------------------------------------------+

datetime RemainingBarTime()
{
   datetime time[];
   CopyTime(Symbol(),Period(),0,1,time);
   return (time[0]+PeriodSeconds((ENUM_TIMEFRAMES)Period()))-TimeCurrent();
}

void Timer()
{
   RefreshRates();
   MqlDateTime t;
   TimeToStruct(RemainingBarTime(),t);
   string rem = "";
   rem += (t.day==1&&t.hour==0) ? "" : (t.hour < 10 ? "0"+string(t.hour) : string(t.hour))+":";
   rem += (t.min < 10 ? "0"+string(t.min) : string(t.min))+":";
   rem += (t.sec < 10 ? "0"+string(t.sec) : string(t.sec));
   label.Description(rem);
}