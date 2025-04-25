#include <ere/include1v2.mqh>
//+------------------------------------------------------------------+
//|                                          MrktObsSet12_OBV_MA.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window


#property indicator_buffers 2
#property indicator_color1 clrDodgerBlue;
#property indicator_label1 "1NomMom"
#property indicator_color2 clrRed;
#property indicator_label2 "2NonMomSig"

input int ChsnPeriod=10; 
double NomMom[],NonMomSig[];
string sIndiName=WindowExpertName()+(string)PERIOD_CURRENT,sComment;

int OnInit()
{  
   IndiGlobalIsLoaded(true);
   IndicatorBuffers(2);
   
   SetIndexBuffer(0,NomMom);
   SetIndexBuffer(1,NonMomSig);

   //EventSetTimer(1);
   //EventSetMillisecondTimer(500);
   //EventSetMillisecondTimer(1500);   
   return(INIT_SUCCEEDED);
}
void deinit(){
   IndiGlobalIsLoaded(false);
   IndiGlobalRemoveVarByString(sIndiName);
   CleanChart();
}

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
   int limit =rates_total-prev_calculated;
   //double vwap, Kama,vwapPlus1SD,vwapPlus2SD,vwapPlus3SD,vwapMinus1SD,vwapMinus2SD,vwapMinus3SD;

   bool sell=false, buy=false;
   if(prev_calculated>0) limit++;
   
   for(int i=limit-1; 1>=0; i--){
      
      NomMom[i]=iCustom(Symbol(), PERIOD_CURRENT,"\\MarketObservtionSet12\\Momentum Normalized v1",0,ChsnPeriod,ChsnPeriod,5,0,5,0,0,i);
      int period = (rates_total-i)<10?(rates_total-1):ChsnPeriod;
      NonMomSig[i]=iCustom(Symbol(), PERIOD_CURRENT,"\\MarketObservtionSet12\\Momentum Normalized v1",0,ChsnPeriod,ChsnPeriod,5,0,5,0,1,i);
   }
   
   
   return(rates_total);
  }
