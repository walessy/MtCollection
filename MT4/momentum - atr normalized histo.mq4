#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  LimeGreen
#property indicator_color2  LimeGreen
#property indicator_color3  Orange
#property indicator_color4  Orange
#property indicator_color5  DarkGray
#property indicator_width1  2
#property indicator_width3  2
#property indicator_width5  2

extern int    momPeriod     = 25;
extern int    momPrice      = PRICE_CLOSE;
extern int    momSmooth     = 3;
extern int    momSmoothMode = MODE_EMA;
extern double Levels        = 5;
double mom[];
double huu[];
double hud[];
double hdd[];
double hdu[];
double slope[];

int init()
{
   IndicatorDigits(6); 
   IndicatorBuffers(6);
      SetIndexBuffer(0,huu); SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexBuffer(1,hud); SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexBuffer(2,hdd); SetIndexStyle(2,DRAW_HISTOGRAM);
      SetIndexBuffer(3,hdu); SetIndexStyle(3,DRAW_HISTOGRAM);
      SetIndexBuffer(4,mom);
      SetIndexBuffer(5,slope);
      
      SetLevelValue(0, Levels);
      SetLevelValue(1,-Levels);
      SetLevelValue(2,0);
      return(0);  
}  
int deinit() { return(0);  }  
int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //
   
   for(int i=limit; i>=0; i--)
   {
      double atr = iATR(NULL,0,momPeriod,i);
         if (atr!=0)
                mom[i] = (iMA(NULL,0,momSmooth,0,momSmoothMode,momPrice,i)-iMA(NULL,0,momSmooth,0,momSmoothMode,momPrice,i+momPeriod))/atr;
         else   mom[i] = 0;
         slope[i] = slope[i+1];
         huu[i]   = EMPTY_VALUE;
         hud[i]   = EMPTY_VALUE;
         hdd[i]   = EMPTY_VALUE;
         hdu[i]   = EMPTY_VALUE;
            if (mom[i] > mom[i+1]) slope[i] =  1;
            if (mom[i] < mom[i+1]) slope[i] = -1;
            if (slope[i]== 1 && mom[i]>0) huu[i] = mom[i];
            if (slope[i]==-1 && mom[i]>0) hud[i] = mom[i];
            if (slope[i]==-1 && mom[i]<0) hdd[i] = mom[i];
            if (slope[i]== 1 && mom[i]<0) hdu[i] = mom[i];
   }
   return(0);
}