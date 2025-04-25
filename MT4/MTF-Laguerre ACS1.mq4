//+------------------------------------------------------------------+
//|                                                Laguerre ACS1.mq4 |
//+------------------------------------------------------------------+
// Modified and simplified by ACS. 03-Oct-07. Added MA for Laguerre! 25-Oct-07. This code was released on 21-JUL-08 in FF.
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_minimum 0
#property indicator_maximum 1
#property indicator_width1 2
#property indicator_level1 0.70
#property indicator_level2 0.20

//---- input parameters
extern int TimeFrame =0;
extern double gamma=0.7;
extern int MaxBars=25000;
extern int MA = 2;
extern bool Interpolate = true;             // Interpolate in multi time frame?

double L0 = 0, L1 = 0, L2 = 0, L3 = 0, L0A = 0, L1A = 0, L2A = 0, L3A = 0, LRSI = 0, CU = 0, CD = 0;
double Buffer1[], dummy[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,gamma,MaxBars,MA,_buff,_ind)
//+------------------------------------------------------------------+
int init() {
   IndicatorDigits(3);
   IndicatorBuffers(2); 
   SetIndexBuffer(0,Buffer1);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,dummy);
   SetIndexBuffer(2,count);
   SetIndexStyle(1,DRAW_NONE); SetIndexLabel(1,NULL); 
   indicatorFileName=WindowExpertName();
   TimeFrame=MathMax(TimeFrame,_Period);
   string shortname=timeFrameToString(TimeFrame)+" Laguerre-ACS("+DoubleToStr(gamma,2); if (MA < 2) shortname = shortname+")"; else shortname = shortname+"-MA"+MA+")";
   IndicatorShortName(shortname);
   SetIndexLabel(0,shortname+"-"+Period()+"M");
return(0); }
//+------------------------------------------------------------------+
int deinit() { return(0); }
//+------------------------------------------------------------------+
int start() {
   int i, j, counted_bars=IndicatorCounted(); double sum1=0;
   if (counted_bars < 0) return(-1);  if (counted_bars > 0) counted_bars--;
   if (MaxBars>Bars) MaxBars=Bars; count[0] = MaxBars;
   SetIndexDrawBegin(0,Bars-MaxBars);
      if (TimeFrame != _Period)
      {
            int limit = (int)fmax(MaxBars-1,fmin(Bars-1,_mtfCall(2,0)*TimeFrame/Period()));
            for(i=limit; i>=0; i--)
            {
               int y = iBarShift(NULL,TimeFrame,Time[i]);
                  Buffer1[i] = _mtfCall(0,y);
                  
                  //
                  //
                  //
                  //
                  //
                  
                  if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                     #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                     int n,k; datetime itime = iTime(NULL,TimeFrame,y);
                        for(n = 1; (i+n)<Bars && Time[i+n] >= itime; n++) continue;	
                        for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++)
                           _interpolate(Buffer1);
               }
            return(0);
      }
   

   for(i=MaxBars-1;i>=0;i--) { sum1=0;
      L0A = L0; L1A = L1; L2A = L2; L3A = L3;
      L0 = (1 - gamma)*Close[i] + gamma*L0A;
      L1 = - gamma *L0 + L0A + gamma *L1A;
      L2 = - gamma *L1 + L1A + gamma *L2A;
      L3 = - gamma *L2 + L2A + gamma *L3A;
      CU = 0; CD = 0;
      if (L0 >= L1) CU = L0 - L1; else CD = L1 - L0;
      if (L1 >= L2) CU = CU + L1 - L2; else CD = CD + L2 - L1;
      if (L2 >= L3) CU = CU + L2 - L3; else CD = CD + L3 - L2;
      if (CU + CD != 0) LRSI = CU / (CU + CD);
      dummy[i] = LRSI;
      if (MA < 2) Buffer1[i] = dummy[i]; else { for (j=i; j < i+MA; j++) sum1 += dummy[j]; Buffer1[i] = sum1/MA; } 
   }
return(0); }
//+------------------------------------------------------------------+


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

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
