//+------------------------------------------------------------------+
//|                               Force index volatility bands_0.mq4 |
//|                                       Copyright 2021, PuguForex. |
//|                          https://www.mql5.com/en/users/puguforex |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, PuguForex."
#property link      "https://www.mql5.com/en/users/puguforex"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 7

#property indicator_label1  "Force index"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSilver
#property indicator_width1  3

#property indicator_label2  "Slope up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_width2  3

#property indicator_label3  "Slope up"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_width3  3


#property indicator_label4  "Slope down"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_width4  3

#property indicator_label5  "Slope down"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_width5  3

#property indicator_label6  "Upper band"
#property indicator_type6   DRAW_LINE
#property indicator_style6  STYLE_DASH
#property indicator_color6  clrSilver
#property indicator_width6  1

#property indicator_label7  "Lower band"
#property indicator_type7   DRAW_LINE
#property indicator_style7  STYLE_DASH
#property indicator_color7  clrSilver
#property indicator_width7  1

#property indicator_level1       0.0
#property indicator_levelcolor   clrSilver
#property indicator_levelstyle   STYLE_DASH

input int            inpForcePeriod =  13;         // Force index period
input ENUM_MA_METHOD inpForceMethod =  MODE_EMA;   // Force index smoothing method
input int            inpBandsPeriod =  89;         // Bands period
input ENUM_MA_METHOD inpBandsMethod =  MODE_EMA;   // Bands smoothing method
input double         inpBandsMultip =  0.21;       // Bands multiplier

double val[],valua[],valub[],valda[],valdb[],valup[],valdn[],valfr[],valvl[],valc[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(10);
//--- indicator buffers mapping
   SetIndexBuffer(0,val    ,INDICATOR_DATA);
   SetIndexBuffer(1,valua  ,INDICATOR_DATA);
   SetIndexBuffer(2,valub  ,INDICATOR_DATA);
   SetIndexBuffer(3,valda  ,INDICATOR_DATA);
   SetIndexBuffer(4,valdb  ,INDICATOR_DATA);
   SetIndexBuffer(5,valup  ,INDICATOR_DATA);
   SetIndexBuffer(6,valdn  ,INDICATOR_DATA);
   SetIndexBuffer(7,valfr  ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,valvl  ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,valc   ,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Force index volatility bands(%s,%s)",
                              IntegerToString(inpForcePeriod),IntegerToString(inpBandsPeriod)));
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
   int limit = prev_calculated ? rates_total-prev_calculated : rates_total-1;
//---
   for(int i=limit;  i>=0  && !_StopFlag; i--)
     {
      valfr[i] =  i<rates_total-1 ? (close[i]-close[i+1])*tick_volume[i] : (close[i]-open[i])*tick_volume[i];
      valvl[i] =  (high[i]-low[i] +  (i<rates_total-1 ? (close[i+1]<low[i])*(low[i]-close[i+1])  +  (close[i+1]>high[i])*(close[i+1]-high[i]) : 0)) *  tick_volume[i];
     }
   for(int i=limit;  i>=0  && !_StopFlag; i--)
     {
      val[i]         =  iMAOnArray(valfr,WHOLE_ARRAY,inpForcePeriod,0,inpForceMethod,i);
      double   vol   =  iMAOnArray(valvl,WHOLE_ARRAY,inpBandsPeriod,0,inpBandsMethod,i);
      
      valup[i] =  inpBandsMultip   *  vol;
      valdn[i] =  inpBandsMultip   * -vol;
      
      valc[i]  =  val[i]>valup[i] ? 1 : val[i]<valdn[i] ? -1 : 0;
      
      valua[i] =  valc[i]>0 ? val[i] : EMPTY_VALUE;   valub[i] =  EMPTY_VALUE;
      valda[i] =  valc[i]<0 ? val[i] : EMPTY_VALUE;   valdb[i] =  EMPTY_VALUE;
      
      PlotColorLine(val,valua,valub,valc,valc[i]>0,valc[i]==0,i,rates_total);
      PlotColorLine(val,valda,valdb,valc,valc[i]<0,valc[i]==0,i,rates_total); 
     }        
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
//---
   
  }
//+------------------------------------------------------------------+
void  PlotColorLine(double &index1[], double &index2a[], double &index2b[], const double &trend[], const bool plot, const bool clean, const int &i, const int &rates_total)
   {
    if(i<rates_total-2 && trend[i]!=trend[i+1])
    {
     if(clean)
       {
        if(index2a[i+1]!=EMPTY_VALUE   && index2b[i+1]==EMPTY_VALUE) {  index2b[i] = index1[i];                          }
        if(index2b[i+1]!=EMPTY_VALUE)                                {  index2a[i+1]=EMPTY_VALUE; index2a[i]=index1[i];  }
       }
     else if(plot)
       {
        if(index2b[i+1]!=EMPTY_VALUE)     index2b[i] = index1[i];
        else                           {  index2a[i+1] = index1[i+1]; index2a[i+2] = EMPTY_VALUE;  }
       }  
    }
   } 