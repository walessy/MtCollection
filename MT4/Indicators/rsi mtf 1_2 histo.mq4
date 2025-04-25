//------------------------------------------------------------------
//
//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  clrSilver
#property indicator_color2  clrDodgerBlue
#property indicator_color3  clrSandyBrown
#property indicator_width2  2
#property indicator_width3  2
#property indicator_minimum 0
#property indicator_maximum 1
#property strict

extern ENUM_TIMEFRAMES    timeFrame = 0;           // Time frame to use
extern ENUM_APPLIED_PRICE rsiPrice  = PRICE_CLOSE; // Rsi price
extern int                rsiPeriod = 40;          // Rsi period
extern int                rsiLevel  = 50;          // Rsi level to check (must be >= 50 and <=100)
extern bool               Interpolate = true;      // Interpolate in mtf mode

double histou[],histod[],histon[];
string indicatorFileName;
bool   returnBars;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

int init()
{
   SetIndexBuffer(0,histon); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,histou); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,histod); SetIndexStyle(2,DRAW_HISTOGRAM);
      indicatorFileName = WindowExpertName();
      returnBars        = timeFrame == -99;
      timeFrame         = MathMax(timeFrame,_Period);
   return(0);
}
int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
            int limit=MathMin(Bars-counted_bars,Bars-1);
            if (returnBars) { histon[0] = limit+1; return(0); }
            if (timeFrame!=Period()) limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,-99,0,0)*timeFrame/Period()));

   //
   //
   //
   //
   //

   for(int i=limit; i>=0; i--)
     {
         int y = iBarShift(NULL,timeFrame,Time[i]);
            double rsi = iRSI(NULL,timeFrame, rsiPeriod, rsiPrice, y);
         histon[i] = EMPTY_VALUE;            
         histou[i] = EMPTY_VALUE;            
         histod[i] = EMPTY_VALUE;            
         double rsistate = 0;
            if (rsi >     rsiLevel) rsistate =  1;
            if (rsi < 100-rsiLevel) rsistate = -1;
            if (rsistate==  1) histou[i] = 1;
            if (rsistate== -1) histod[i] = 1;
            if (rsistate==  0) histon[i] = 1;
   }
   return(0);
}