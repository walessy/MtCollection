//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  Red
#property indicator_color2  Blue
#property indicator_width1  1
#property indicator_width2  1


//
//
//
//
//

extern string TimeFrame   = "Current time frame";
extern int    StoKPeriod  = 14;
extern int    StoDPeriod  =  3;
extern int    StoSlowing  =  3;
extern int    StoPrice    =  0;
extern int    SignalMode  = MODE_SMA;
extern bool   Interpolate = true;

//
//
//
//
//

double sto[];
double sig[];

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
// 
//
//
//
//

int init()
{
   SetIndexBuffer(0,sto);
   SetIndexBuffer(1,sig);
   
      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         calculateValue    = TimeFrame=="calculateValue"; if (calculateValue) { return(0); }
         returnBars        = TimeFrame=="returnBars";     if (returnBars)     { return(0); }
         timeFrame         = stringToTimeFrame(TimeFrame);
      
      //
      //
      //
      //
      //
      
      IndicatorShortName(timeFrameToString(timeFrame)+" Stochastic ("+StoKPeriod+","+StoDPeriod+","+StoSlowing+")");
   return(0);
}
int deinit() { return(0); }


//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int i,limit,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { sto[0] = MathMin(limit+1,Bars-1); return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame == Period())
   {
      for(i=limit; i>=0; i--)
      {
         sto[i] = iStochastic(NULL,0,StoKPeriod,StoDPeriod,StoSlowing,SignalMode,StoPrice,MODE_MAIN  ,i);
         sig[i] = iStochastic(NULL,0,StoKPeriod,StoDPeriod,StoSlowing,SignalMode,StoPrice,MODE_SIGNAL,i);
      }         
      return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         sto[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",StoKPeriod,StoDPeriod,StoSlowing,StoPrice,SignalMode,0,y);
         sig[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",StoKPeriod,StoDPeriod,StoSlowing,StoPrice,SignalMode,1,y);
          if (timeFrame <= Period() || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;
          if (!Interpolate) continue;

          //
          //
          //
          //
          //

          datetime time = iTime(NULL,timeFrame,y);
             for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
             for(int x = 1; x < n; x++)
             {
                sto[i+x] = sto[i] + (sto[i+n] - sto[i]) * x/n;
                sig[i+x] = sig[i] + (sig[i+n] - sig[i]) * x/n;
             }               
   }         
   return(0);
   
}



//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}