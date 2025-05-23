//+------------------------------------------------------------------+
//|                                                        Delta.mq4 |
//|                           Copyright © 2008, D500       ELR       |
//|                                                                  |
//+------------------------------------------------------------------+
#include <ere\include1v2.mqh>
#property copyright "Copyright © 2008, D500."
#property indicator_separate_window
#property indicator_buffers 4

#property indicator_color1 White
#property indicator_width1 2

#property indicator_color2 Red
#property indicator_width2 2
 
#property indicator_color3 Green
#property indicator_width3 1
//#property indicator_style3 2

#property indicator_color4 Orange
#property indicator_width4 1

 
extern int PERIOD=13;
extern int PERIOD_Signal=13;
extern int PERIOD_Smooth=2;
 
double Buffer0[];
double Buffer1[];
double Buffer2[];
double Buffer3[];

string sIndiName=WindowExpertName()+(string)PERIOD_CURRENT,sComment;
//+------------------------------------------------------------------+
int init()
   {
   CleanChart();
   //SetIndexBuffer(0,Buffer0);
   //SetIndexStyle(0,DRAW_LINE);

   SetIndexBuffer(1,Buffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   //SetIndexLabel(1,"Îñíîâíîå çíà÷åíèå");
 
   //SetIndexBuffer(2,Buffer2);
   //SetIndexStyle(2,DRAW_LINE);
   //SetIndexLabel(2,"Ñèãíàëüíàÿ ëèíèÿ");
 
   //SetIndexBuffer(3,Buffer3);
   //SetIndexStyle(3,DRAW_LINE);
   return(0);
   }
   
void deinit(){
 CleanChart(sIndiName);
 CleanChart();
}
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
 CleanChart(sIndiName);
 CleanChart();
   int limit =rates_total-prev_calculated;



  
   for(int i=0;i<limit;i++)
      {
      Buffer1[i]=((High[i]+Low[i])/2)-iMA(NULL,0,PERIOD,0,1,0,i);
      /*
      if(i>0){
         if(Buffer1[i]>0 && Buffer1[i-1]<0){
            drawVLine(i,clrDarkRed,STYLE_SOLID, 1);
         }
         if(Buffer1[i]<0 && Buffer1[i-1]>0){
            drawVLine(i,clrDarkGreen,STYLE_SOLID, 1);
         }
      }
      */
   }
   /*
   for(int i=0;i<limit;i++)
      {
      Buffer0[i]=0.0;
      Buffer2[i]=iMAOnArray(Buffer1,Bars,PERIOD_Signal,0,MODE_SMA,i);
      double Sum_Buf_3 = Buffer1[i];
      if (PERIOD_Smooth<0)
         PERIOD_Smooth=0;
      Buffer3[i]=iMAOnArray(Buffer1,Bars,PERIOD_Smooth+1,0,MODE_SMA,i);   
      
      /*for (int n=1; n<=N; n++)  
         {
         Sum_Buf_3 = Sum_Buf_3 + Buffer1[i+n];
         }
      Buffer3[i] = Sum_Buf_3/(N+1);
   }
   */
   return(0);
   }
//+------------------------------------------------------------------+   