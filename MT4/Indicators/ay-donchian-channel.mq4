//+------------------------------------------------------------------+
//|                                          ay-donchian-channel.mq4 |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Goldenrod
#property indicator_color2 Goldenrod
#property indicator_color3 DarkTurquoise


double BuffH[], BuffL[], BuffM[];
double PrevH, PrevL;
//---- input parameters
extern int       per =20;
extern string    tfInfo   = "0:Curr tf, H1:60, H4:240, DAILY: 1440, WEEKLY: 10080, MONTHLY: 43200";
extern int       tf  = 0;
extern bool      modehilo = true;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
  if (tf < Period() && tf > 0 ) return(-1);
  
//---- indicators
  SetIndexBuffer(0, BuffH); 
  SetIndexBuffer(1, BuffL);
  SetIndexBuffer(2, BuffM);

  for (int i=0; i<3; i++)
   SetIndexStyle(i, DRAW_LINE);  
  
  
  SetIndexLabel(0, "High DC");
  SetIndexLabel(1, "Low DC");
  SetIndexLabel(2, "Mid DC");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
   //---- check for possible errors
   if(counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   //---- main loop
   for(int i=limit; i>=0; i--)
   {
      int shifttf        = iBarShift(NULL, tf, Time[i]);
      if (modehilo)
      {
         double hh          = iHigh(NULL, tf, iHighest(NULL, tf, MODE_HIGH, per, shifttf+1));
         double ll          = iLow (NULL, tf, iLowest (NULL, tf, MODE_LOW,  per, shifttf+1));
      }else{
         hh          = iClose(NULL, tf, iHighest(NULL, tf, MODE_CLOSE, per, shifttf+1));
         ll          = iClose(NULL, tf, iLowest (NULL, tf, MODE_CLOSE, per, shifttf+1));      
      }
      
      BuffH[i]= hh;
      BuffL[i]= ll;
      BuffM[i]= ll + 0.5*(hh-ll);
      

   }
   return(0);
  }
//+------------------------------------------------------------------+