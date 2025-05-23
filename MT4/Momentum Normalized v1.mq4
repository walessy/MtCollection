//+------------------------------------------------------------------+
//|                                       Momentum_Normalized_v1.mq4 |
//|                                  Copyright © 2008, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Forex-.com "
#property link      "http://www.forex-tsd.com/"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DodgerBlue
#property indicator_width1 2
#property indicator_color2 Tomato
#property indicator_style2 2
#property indicator_maximum 100
#property indicator_minimum -100
#property indicator_level1 0
//---- input parameters
extern int Price        =  0;
extern int MomPeriod    = 14;
extern int NormPeriod   =100;
extern int SmoothPeriod =  5;
extern int Smooth_Mode  =  0;
extern int SignalPeriod =  5;
extern int Signal_Mode  =  0;
//---- buffers
double NormMomBuffer[];
double SignalBuffer[];
double MomBuffer[];

double MaxMom, MinMom;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   //string short_name;
//---- 1 additional buffer used for counting.
   IndicatorBuffers(3);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,NormMomBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,SignalBuffer);
   SetIndexBuffer(2,MomBuffer);
   
//---- name for DataWindow and indicator subwindow label
   //short_name="Momentum Normalized("+Price+","+MomPeriod+","+NormPeriod+")";
   //IndicatorShortName(short_name);
   //SetIndexLabel(0,short_name);
   //SetIndexLabel(1,"Signal");
//----
   SetIndexDrawBegin(0,NormPeriod+MomPeriod+SmoothPeriod);
   SetIndexDrawBegin(1,NormPeriod+MomPeriod+SignalPeriod+SmoothPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Momentum_Normalized_v1                                           |
//+------------------------------------------------------------------+
int start()
{
   int i,limit,counted_bars=IndicatorCounted();
//----
   if ( counted_bars < 0 ) return(-1);
   if ( counted_bars ==0 ) limit=Bars-1;
   if ( counted_bars < 1 ) 
   
   for( i=1;i<MomPeriod+NormPeriod+SignalPeriod+SmoothPeriod;i++) 
   {
   NormMomBuffer[Bars-i]=0;    
   SignalBuffer[Bars-i]=0;  
   }
   
   if(counted_bars>0) limit=Bars-counted_bars-1;
     
   for( i=limit; i>=0; i--)
   {
      if(i > Bars-MomPeriod-SmoothPeriod) MomBuffer[i]=0;
      else
      MomBuffer[i]=iMA(NULL,0,SmoothPeriod,0,Smooth_Mode,Price,i) - iMA(NULL,0,SmoothPeriod,0,Smooth_Mode,Price,i+MomPeriod);
    
   MaxMom=-1000000;MinMom = 1000000;
      
      for( int k=0;k < NormPeriod;k++)
      {
      MaxMom = MathMax(MaxMom,MomBuffer[i+k]);
      MinMom = MathMin(MinMom,MomBuffer[i+k]);        
      }
      
   if (MaxMom-MinMom > 0) NormMomBuffer[i]=200*((MomBuffer[i]-MinMom)/(MaxMom-MinMom)-0.5);   
   else NormMomBuffer[i] = 0;
   }
   
   for( i=limit; i>=0; i--)
   SignalBuffer[i] = iMAOnArray(NormMomBuffer,0,SignalPeriod,0,Signal_Mode,i);      
//----
   return(0);
}
//+------------------------------------------------------------------+