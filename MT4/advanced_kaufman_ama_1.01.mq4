//+------------------------------------------------------------------
//|                                   Kaufman Adaptive Moving Average 
//|                                                            mladen 
//+------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1  Linen
#property indicator_color2  DeepSkyBlue
#property indicator_color3  DeepSkyBlue
#property indicator_color4  PaleVioletRed
#property indicator_color5  PaleVioletRed
#property indicator_color6  DeepSkyBlue
#property indicator_color7  PaleVioletRed
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  2

//
//
//
//
//

extern string TimeFrame        = "current time frame";
extern int    AmaPeriod        = 20;
extern int    AmaPrice         = PRICE_CLOSE;
extern double FastEnd          = 2;
extern double SlowEnd          = 30;
extern double SmoothPower      = 2;
extern double FilterDeviations = 1.0; 
extern int    FilterPeriod     = 20;
extern bool   JurikFDAdaptive  = true;
extern bool   Interpolate      = false;

extern bool   alertsOn        = false;
extern bool   alertsOnCurrent = true;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;

//
//
//
//
//

double ama[];
double amaUpa[];
double amaUpb[];
double amaDn[];
double amaDna[];
double amaDnb[];
double amaSUp[];
double amaSDn[];

//
//
//
//
//

string indicatorFileName;
int    timeFrame;
bool   returnBars;
bool   calculateValue;

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
      SetIndexBuffer(0,ama);
      SetIndexBuffer(1,amaUpa);
      SetIndexBuffer(2,amaUpb);
      SetIndexBuffer(3,amaDna);
      SetIndexBuffer(4,amaDnb);
      SetIndexBuffer(5,amaSUp); SetIndexStyle(5,DRAW_ARROW); SetIndexArrow(5,159);
      SetIndexBuffer(6,amaSDn); SetIndexStyle(6,DRAW_ARROW); SetIndexArrow(6,159);

      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
         returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
         timeFrame         = stringToTimeFrame(TimeFrame);

      //
      //
      //
      //
      //
         
   IndicatorShortName("Kaufman AMA ("+AmaPeriod+")");
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

double work[][4];
#define _lastLo 0
#define _lastHi 1
#define _trend  2
#define _trenc  3

//
//
//
//
//

int start()
{
   int i,k,r,limit,counted_bars=IndicatorCounted();
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { ama[0] = limit+1; return(0); }
           if (ArrayRange(work,0)!=Bars) ArrayResize(work,Bars);

   //
   //
   //
   //
   //
   
   if (calculateValue || timeFrame == Period())
   {
      if (work[Bars-limit-1][_trenc]== 1 && work[Bars-limit-2][_trend] ==  1) CleanPoint(limit,amaUpa,amaUpb);
      if (work[Bars-limit-1][_trenc]==-1 && work[Bars-limit-2][_trend] == -1) CleanPoint(limit,amaDna,amaDnb);
      for(i=limit, r=Bars-i-1; i>=0; i--,r++)
      {
         ama[i]    = iKama(AmaPeriod,FastEnd,SlowEnd,AmaPrice,SmoothPower,JurikFDAdaptive,i);
         amaUpa[i] = EMPTY_VALUE;
         amaUpb[i] = EMPTY_VALUE;
         amaDna[i] = EMPTY_VALUE;
         amaDnb[i] = EMPTY_VALUE;
         amaSUp[i] = EMPTY_VALUE;
         amaSDn[i] = EMPTY_VALUE;
         
         //
         //
         //
         //
         //
                  
            double stddev = 0;
               if (FilterDeviations>0)
               {
                  double avgdiff = 0;
                     for (k=0; k<FilterPeriod; k++) avgdiff += MathAbs(ama[i+k]-ama[i+k+1]);                    avgdiff /= FilterPeriod;
                     for (k=0; k<FilterPeriod; k++) stddev  += MathPow(MathAbs(ama[i+k]-ama[i+k+1])-avgdiff,2); stddev  /= FilterPeriod;
               }
            double filter = FilterDeviations * MathPow(stddev,0.5);

         //
         //
         //
         //
         //

            work[r][_trenc]  = 0;
            work[r][_trend]  = work[r-1][_trend];
            work[r][_lastLo] = work[r-1][_lastLo];
            work[r][_lastHi] = work[r-1][_lastHi];

               if (ama[i]-ama[i+1] > filter) { work[r][_trend] =  1; if (work[r-1][_trend] !=  1) work[r][_lastLo] = ama[i+1]; }
               if (ama[i+1]-ama[i] > filter) { work[r][_trend] = -1; if (work[r-1][_trend] != -1) work[r][_lastHi] = ama[i+1]; }
               if (work[r][_trend] == 1 && ama[i]>ama[i+1] && (ama[i]-work[r][_lastLo])>filter && work[r][_lastLo]>0) work[r][_trenc] =  1;
               if (work[r][_trend] ==-1 && ama[i]<ama[i+1] && (work[r][_lastHi]-ama[i])>filter && work[r][_lastHi]>0) work[r][_trenc] = -1;
               if (!calculateValue)
               {
                  if (work[r][_trenc] ==  1 && work[r-1][_trend] ==  1) PlotPoint(i,amaUpa,amaUpb,ama);
                  if (work[r][_trenc] == -1 && work[r-1][_trend] == -1) PlotPoint(i,amaDna,amaDnb,ama);
                  if (work[r][_trend] != work[r-1][_trend])
                  {
                     if (work[r][_trend] == 1) amaSUp[i] = ama[i];
                     if (work[r][_trend] ==-1) amaSDn[i] = ama[i];
                  }               
               }
               else { amaSUp[i] = work[r][_trend]; amaSDn[i] = work[r][_trenc]; }                  
      }    
      manageAlerts();
      return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (work[Bars-limit-1][_trenc]== 1 && work[Bars-limit-2][_trend] ==  1) CleanPoint(limit,amaUpa,amaUpb);
   if (work[Bars-limit-1][_trenc]==-1 && work[Bars-limit-2][_trend] == -1) CleanPoint(limit,amaDna,amaDnb);
   for(i=limit, r=Bars-i-1; i>=0; i--,r++)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         ama[i]          = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",AmaPeriod,AmaPrice,FastEnd,SlowEnd,SmoothPower,FilterDeviations,FilterPeriod,JurikFDAdaptive,0,y);
         work[r][_trend] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",AmaPeriod,AmaPrice,FastEnd,SlowEnd,SmoothPower,FilterDeviations,FilterPeriod,JurikFDAdaptive,5,y);
         work[r][_trenc] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",AmaPeriod,AmaPrice,FastEnd,SlowEnd,SmoothPower,FilterDeviations,FilterPeriod,JurikFDAdaptive,6,y);
         amaUpa[i] = EMPTY_VALUE;
         amaUpb[i] = EMPTY_VALUE;
         amaDna[i] = EMPTY_VALUE;
         amaDnb[i] = EMPTY_VALUE;
         amaSUp[i] = EMPTY_VALUE;
         amaSDn[i] = EMPTY_VALUE;
            
         //
         //
         //
         //
         //
      
         if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;
              interpolate(ama,iTime(NULL,timeFrame,iBarShift(NULL,timeFrame,Time[i])),i);
   }
   for(i=limit, r=Bars-i-1; i>=0; i--,r++)
   {
      if (work[r][_trenc] ==  1 && work[r-1][_trend] ==  1) PlotPoint(i,amaUpa,amaUpb,ama);
      if (work[r][_trenc] == -1 && work[r-1][_trend] == -1) PlotPoint(i,amaDna,amaDnb,ama);
      if (work[r][_trend] != work[r-1][_trend])
      {
         if (work[r][_trend]== 1) amaSUp[i] = ama[i];
         if (work[r][_trend]==-1) amaSDn[i] = ama[i];
      }               
   }      
   
   //
   //
   //
   //
   //
   
   manageAlerts(); 
   return(0);
}
  

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

void interpolate(double& buffer[], datetime time, int i)
{
   for (int n = 1; (i+n) < Bars && Time[i+n] >= time; n++) continue;
   
   //
   //
   //
   //
   //
   
   if (buffer[i] == EMPTY_VALUE || buffer[i+n] == EMPTY_VALUE) n=-1;
               double increment = (buffer[i+n] - buffer[i])/ n;
   for (int k = 1; k < n; k++)     buffer[i+k] = buffer[i] + k*increment;
}


//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i]   = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]   = from[i];
         second[i]  = EMPTY_VALUE;
      }
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (work[Bars-whichBar-1][_trend] != work[Bars-whichBar-2][_trend])
      {
         if (work[Bars-whichBar-1][_trend] == 1) doAlert(whichBar,"up");
         if (work[Bars-whichBar-1][_trend] ==-1) doAlert(whichBar,"down");
      }         
   }
}   

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Kaufman ama trend changed to ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"Kaufman ama"),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}


//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
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


//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//

double workAma[][2];
#define _diff 0
#define _kama 1

//
//
//
//
//

double iKama(int period, double fast, double slow, int priceType, double power, bool JurikFD, int i)
{
   if (ArrayRange(workAma,0)!=Bars) ArrayResize(workAma,Bars);

   double price = iMA(NULL,0,1,0,MODE_SMA,priceType,i); int r = Bars-i-1; if (r<period) return(price);
   double fastend = (2.0 /(fast + 1));
   double slowend = (2.0 /(slow + 1));
   
   //
   //
   //
   //
   //

      if (JurikFD) double efratio = MathMin(2.0-iJurikFractalDimension(period,2,i),1.0);
      else
      {
         double signal = MathAbs(price-iMA(NULL,0,1,0,MODE_SMA,priceType,i+period));
         double noise  = 0;
            workAma[r][_diff] = MathAbs(price-iMA(NULL,0,1,0,MODE_SMA,priceType,i+1));
            for (int k=0; k<period; k++) 
                  noise += workAma[r-k][_diff];

            //
            //
            //
            //
            //

            if (noise != 0)
                  efratio = signal/noise;
            else  efratio = 1;
      }
      double smooth = MathPow(efratio*(fastend-slowend)+slowend,power);
             workAma[r][_kama] = workAma[r-1][_kama] + smooth*(price-workAma[r-1][_kama]);

   //
   //
   //
   //
   //
      
   return(workAma[r][_kama]);
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

double workFd[][2];
#define _smlRange 0
#define _smlSumm  1

//
//
//
//
//

double iJurikFractalDimension(int size, int count,int i)
{
   if (size<=1) return(0.5);
   if (ArrayRange(workFd,0)!=Bars) ArrayResize(workFd,Bars);

   int window1  = size*(count-1);
   int window2  = size* count;
   int r        = Bars-i-1;

   //
   //
   //
   //
   //

      workFd[r][_smlRange] = iFdRange(size,i);
      workFd[r][_smlSumm]  = workFd[r-1][_smlSumm]+workFd[r][_smlRange];
      
      if ((Bars-i)>window1)
      {
         workFd[r][_smlSumm] -= workFd[r-window1][_smlRange];
         if (workFd[r][_smlSumm]!=0)
               return(2.0-MathLog(iFdRange(window2,i)/(workFd[r][_smlSumm]/window1))/MathLog(count));
         else  return(0.5);  
      }
      else return(0.5);
}
double iFdRange(int size,int i) { return(MathMax(Close[size+i],High[ArrayMaximum(High,size,i)])-MathMin(Close[size+i],Low[ArrayMinimum(Low,size,i)])); }   