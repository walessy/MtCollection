//+------------------------------------------------------------------+
//|                                                                  |
//| "Fixing the Bollinger bands"                                     |
//| Futures magazine 05.2010, David Rooke                            }
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_chart_window
#property indicator_buffers    3
#property indicator_color1     Gold
#property indicator_color2     DimGray
#property indicator_color3     DimGray
#property indicator_style1     STYLE_DOT

//
//
//
//
//

extern int    Length                 = 20;
extern int    Price                  = PRICE_CLOSE;
extern double Deviations             = 2.0;
extern bool   UseClassicalDeviations = false; 

//
//
//
//
//

double vbc[];
double vbu[];
double vbd[];
double prices[];

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
   IndicatorBuffers(4);
   SetIndexBuffer(0, vbc); 
   SetIndexBuffer(1, vbu); 
   SetIndexBuffer(2, vbd); 
   SetIndexBuffer(3, prices); 
   return(0);
}
int deinit()
{
   return(0);
}

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
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         
   //
   //
   //
   //
   //

   for(i=limit; i>=0; i--)
   {
      prices[i] = iMA(NULL,0,1,0,MODE_SMA,Price,i);

         double tema1 = iTema(prices[i],Length,i,0);
         double tema2 = iTema(tema1    ,Length,i,3);

      vbc[i] = 2.0*tema1-tema2;

         double deviation = iDeviationPlus(prices,vbc,Length,i);

      vbu[i] = vbc[i]+deviation*Deviations;
      vbd[i] = vbc[i]-deviation*Deviations;
   }
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double wrk[][6];

double iTema(double price, int length, int i, int s=0)
{
   if (ArrayRange(wrk,0)!=Bars) ArrayResize(wrk,Bars);
   
   //
   //
   //
   //
   //
   
   double alpha = 2.0 /(1.0 + length);
   int    r = Bars-i-1;
   
   if (r < 1)
      {
         wrk[r][0+s] = price;
         wrk[r][1+s] = price;
         wrk[r][2+s] = price;
      }
   else
      {
         wrk[r][0+s] = wrk[r-1][0+s]+alpha*(price      -wrk[r-1][0+s]);
         wrk[r][1+s] = wrk[r-1][1+s]+alpha*(wrk[r][0+s]-wrk[r-1][1+s]);
         wrk[r][2+s] = wrk[r-1][2+s]+alpha*(wrk[r][1+s]-wrk[r-1][2+s]);
      }
   return(3*wrk[r][0+s] - 3*wrk[r][1+s] + wrk[r][2+s]);
}

//
//
//
//    In the original article the second method is how deviation is
//    calculated . It is a questionableble method , but if we apply
//    standard calculation the bands tend to be "spiky".That is the
//    reason to have the "UseClassicalDeviations" option
//
//
//

double iDeviationPlus(double& array[], double& ma[], int period, int i)
{
   double sum = 0;
      if (UseClassicalDeviations)
            for(int k=0; k<period; k++) sum += (array[i+k]-ma[i])  *(array[i+k]-ma[i]);
      else  for(    k=0; k<period; k++) sum += (array[i+k]-ma[i+k])*(array[i+k]-ma[i+k]);       
   return(MathSqrt(sum/period));
}