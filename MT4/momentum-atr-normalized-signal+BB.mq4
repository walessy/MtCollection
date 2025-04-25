#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  clrDeepSkyBlue  //PaleVioletRed
#property indicator_color2  clrGold
#property indicator_color3  clrGray
#property indicator_color4  clrGray
#property indicator_color5  clrGray
#property indicator_width1  2
#property indicator_style2  2

extern int    momPeriod         = 25;
extern int    momPrice          = PRICE_CLOSE;
extern int    momSmooth         = 3;
extern double momSmoothHot      = 0.7;
extern bool   momSmoothOriginal = false;
extern int    SignalPeriod      = 9;
extern int    SignalMethod      = MODE_SMA;
extern double Levels            = 5;
input string Comment_5="====================Bands";     //Drawing Options
input int BandsPeriod=10;
input double BandsDeviation=1.5;

double mom[];
double sig[];

double  UpperBuffer[];
double  MiddleBuffer[];
double  LowerBuffer[];

enum ENUM_BB_TRADE_SIGNAL{
   SIGNAL_BB_BUY=1,     //BUY
   SIGNAL_BB_SELL=-1,   //SELL
   SIGNAL_BB_NEUTRAL=0  //NEUTRAL
};
enum ENUM_BB_ALERT_SIGNAL{
   BB_MAIN_SIGNAL_BREAKOUT=0          
};

int init()
{
   IndicatorDigits(1); 
      SetIndexBuffer(0,mom);  SetIndexStyle(0,DRAW_LINE);
      SetIndexBuffer(1,sig);  SetIndexStyle(1,DRAW_LINE);
      SetIndexBuffer(2, UpperBuffer); 
      SetIndexBuffer(3, MiddleBuffer); 
      SetIndexBuffer(4, LowerBuffer); 
      SetLevelValue(0, Levels);
      SetLevelValue(1,-Levels);
      SetLevelValue(2,0);
      SetIndexStyle(2,DRAW_LINE);
      SetIndexStyle(3,DRAW_LINE);
      SetIndexStyle(4,DRAW_LINE);
      SetIndexDrawBegin(2,BandsPeriod);    
      SetIndexDrawBegin(3,BandsPeriod); 
      SetIndexDrawBegin(4,BandsPeriod); 
      SetIndexLabel(2,"Upper");
      SetIndexLabel(3,"Middle");
      SetIndexLabel(4,"Lower");
      
      return(0);  
}  
int deinit() { return(0);  }  
int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);

   
   for(int i=limit; i>=0; i--)
   {
      double atr    = iATR(NULL,0,momPeriod,i);
      double price1 = iMA(NULL,0,momSmooth,0,MODE_SMA,momPrice,i);
      double price2 = iMA(NULL,0,momSmooth,0,MODE_SMA,momPrice,i+momPeriod);
         if (atr!=0)
                mom[i] = (iT3(price1,momSmooth,momSmoothHot,momSmoothOriginal,i,0)-iT3(price2,momSmooth,momSmoothHot,momSmoothOriginal,i,1))/atr;
         else   mom[i] = 0;
   }
   for(i=limit; i>=0; i--) sig[i] = iMAOnArray(mom,0,SignalPeriod,0,SignalMethod,i);
   
   for(i=limit; i>=0;i--)
   {
      UpperBuffer[i]=iBandsOnArray(mom,0,BandsPeriod,BandsDeviation,0,MODE_UPPER,i);
      MiddleBuffer[i]=iBandsOnArray(mom,0,BandsPeriod,BandsDeviation,0,MODE_MAIN,i);
      LowerBuffer[i]=iBandsOnArray(mom,0,BandsPeriod,BandsDeviation,0,MODE_LOWER,i);      
   }
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workT3[][12];
double workT3Coeffs[][6];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define _c4     4
#define _alpha  5

//
//
//
//
//

double iT3(double price, double period, double hot, bool original, int i, int instanceNo=0)
{
   if (ArrayRange(workT3,0) != Bars)                ArrayResize(workT3,Bars);
   if (ArrayRange(workT3Coeffs,0) < (instanceNo+1)) ArrayResize(workT3Coeffs,instanceNo+1);

   if (workT3Coeffs[instanceNo][_period] != period)
   {
     workT3Coeffs[instanceNo][_period] = period;
        double a = hot;
            workT3Coeffs[instanceNo][_c1] = -a*a*a;
            workT3Coeffs[instanceNo][_c2] = 3*a*a+3*a*a*a;
            workT3Coeffs[instanceNo][_c3] = -6*a*a-3*a-3*a*a*a;
            workT3Coeffs[instanceNo][_c4] = 1+3*a+a*a*a+3*a*a;
            if (original)
                 workT3Coeffs[instanceNo][_alpha] = 2.0/(1.0 + period);
            else workT3Coeffs[instanceNo][_alpha] = 2.0/(2.0 + (period-1.0)/2.0);
   }
   
   //
   //
   //
   //
   //
   
   int buffer = instanceNo*6;
   int r = Bars-i-1;
   if (r == 0)
      {
         workT3[r][0+buffer] = price;
         workT3[r][1+buffer] = price;
         workT3[r][2+buffer] = price;
         workT3[r][3+buffer] = price;
         workT3[r][4+buffer] = price;
         workT3[r][5+buffer] = price;
      }
   else
      {
         workT3[r][0+buffer] = workT3[r-1][0+buffer]+workT3Coeffs[instanceNo][_alpha]*(price              -workT3[r-1][0+buffer]);
         workT3[r][1+buffer] = workT3[r-1][1+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][0+buffer]-workT3[r-1][1+buffer]);
         workT3[r][2+buffer] = workT3[r-1][2+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][1+buffer]-workT3[r-1][2+buffer]);
         workT3[r][3+buffer] = workT3[r-1][3+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][2+buffer]-workT3[r-1][3+buffer]);
         workT3[r][4+buffer] = workT3[r-1][4+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][3+buffer]-workT3[r-1][4+buffer]);
         workT3[r][5+buffer] = workT3[r-1][5+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][4+buffer]-workT3[r-1][5+buffer]);
      }

   //
   //
   //
   //
   //
   
   return(workT3Coeffs[instanceNo][_c1]*workT3[r][5+buffer] + 
          workT3Coeffs[instanceNo][_c2]*workT3[r][4+buffer] + 
          workT3Coeffs[instanceNo][_c3]*workT3[r][3+buffer] + 
          workT3Coeffs[instanceNo][_c4]*workT3[r][2+buffer]);
}