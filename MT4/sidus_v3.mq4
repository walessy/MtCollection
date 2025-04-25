//+------------------------------------------------------------------+
//|                                    Sidus v.3 Entry Indicator.mq4 |
//|                                                                  |
//|                                                   Ideas by Sidus |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Aqua
#property indicator_color4 Yellow
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 3  
#property indicator_width4 3   

//
//
//
//
//

extern int       FastEMA   = 15;//14
extern int       SlowEMA   = 34;//21
extern string    ex        = "0=SMA,1=EMA,2=SSMA,3=LWMA";
extern int       mamode    = MODE_LWMA;
extern string    ex2       = "0=Close,1=Open,2=High,3=Low";
extern string    ex2a      = "4=Median,5=Typical,6=Weighted";
extern int       maprice   = PRICE_CLOSE;
extern int       RSIPeriod = 8;//17
extern bool      Alerts    = false;

//
//
//
//
//

double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double trend[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorBuffers(5);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3); SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(2,233);
   SetIndexBuffer(3,ExtMapBuffer4); SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,234);
   SetIndexBuffer(4,trend);
   return(0);
}
int deinit() { return(0); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int limit;
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit=MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //
   
   for(int i=limit; i>=0; i--)
   {
      ExtMapBuffer1[i] = iMA(NULL,0,FastEMA,0,mamode,maprice,i);
      ExtMapBuffer2[i] = iMA(NULL,0,SlowEMA,0,mamode,maprice,i);
      ExtMapBuffer3[i] = EMPTY_VALUE;
      ExtMapBuffer4[i] = EMPTY_VALUE;
      trend[i]         = trend[i+1];

      //
      //
      //
      //
      //
      
      double dist = iATR(NULL,0,20,i);
      double rsi  = iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE, i);
      double diff = (ExtMapBuffer1[i]-ExtMapBuffer2[i]);

         if (diff>0 && rsi>50) trend[i] =  1;
         if (diff<0 && rsi<50) trend[i] = -1;
         if (trend[i]!=trend[i+1])
            if (trend[i]==1)
                  ExtMapBuffer3[i] = ExtMapBuffer1[i]-dist;
            else  ExtMapBuffer4[i] = ExtMapBuffer1[i]+dist;
   }

   //
   //
   //
   //
   //
   
   if(Alerts)
   if (trend[0]!=trend[i+1])
   {
         if (trend[0]==1)
               simpleAlert("Entry point: buy at "+Ask+"!!");
         else  simpleAlert("Entry point: sell at "+Bid+"!!");
   }
   return(0);
}

//
//
//
//
//

void simpleAlert(string doWhat)
{
   static datetime previousTime;
   static string   previousMessage;
   
   if (previousTime != Time[0] || doWhat != previousMessage)
   {
      previousTime    = Time[0];
      previousMessage =  doWhat;
         PlaySound("alert.wav");
         Alert(doWhat);
   }
}