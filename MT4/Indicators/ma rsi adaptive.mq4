//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  PaleVioletRed
#property indicator_color2  LimeGreen
#property indicator_color3  LimeGreen
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2

extern string TimeFrame      = "Current time frame";
extern int    RsiPeriod      = 14;
extern double Speed          = 1.2;
extern int    RsiMethod      = 0;
extern int    RsiPrice       = PRICE_CLOSE;
extern bool   Interpolate    = true;

//
//
//
//
//

double maua[];
double maub[];
double ma[];
double trend[];

string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;


//------------------------------------------------------------------
//
//------------------------------------------------------------------
// 
//
//
//
//

int init()
{
   IndicatorBuffers(4);
   SetIndexBuffer(0,ma); 
   SetIndexBuffer(1,maua);
   SetIndexBuffer(2,maub);
   SetIndexBuffer(3,trend); 

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
               
      IndicatorShortName(timeFrameToString(timeFrame)+" ma RSI adaptive ("+RsiPeriod+","+DoubleToStr(Speed,2)+" "+getRsiName(RsiMethod)+")");
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

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { ma[0] = MathMin(limit+1,Bars-1); return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame == Period())
   {
      if (trend[limit]== 1) CleanPoint(limit,maua,maub);
      for(int i=limit; i>=0; i--) 
      {
         ma[i]   = iMaRsi(RsiPrice,RsiPeriod,RsiMethod,Speed,i,0);
         maua[i] = EMPTY_VALUE;
         maub[i] = EMPTY_VALUE;
         trend[i]  = trend[i+1];
            if (ma[i]>ma[i+1]) trend[i] =  1;
            if (ma[i]<ma[i+1]) trend[i] = -1;
            if (trend[i]==1) PlotPoint(i,maua,maub,ma);
      }      
      return(0);
   }
   
   //
   //
   //
   //
   //

   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (trend[limit]==-1) CleanPoint(limit,maua,maub);
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         ma[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,Speed,RsiMethod,RsiPrice,0,y);
         trend[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiPeriod,Speed,RsiMethod,RsiPrice,3,y);
         maua[i]  = EMPTY_VALUE;
         maub[i]  = EMPTY_VALUE;

         if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;

         //
         //
         //
         //
         //

            datetime time = iTime(NULL,timeFrame,y);
               for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
               for(int k = 1; k < n; k++)
               {
                  ma[i+k]  = ma[i]  + (ma[i+n]  - ma[i] )*k/n;
               }
   }
   for (i=limit;i>=0;i--) if (trend[i]==1) PlotPoint(i,maua,maub,ma);
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

double workMaRsi[][2];

double iMaRsi(int price, int rsiPeriod, int rsiMode, double speed, int i, int instanceNo=0)
{
   if (ArrayRange(workMaRsi,0)!=Bars) ArrayResize(workMaRsi,Bars); int r = Bars-i-1;

   //
   //
   //
   //
   //
   
   double tprice = iMA(NULL,0,1,0,MODE_SMA,price,i);
      if (r<rsiPeriod)
            workMaRsi[r][instanceNo] = tprice;
      else  workMaRsi[r][instanceNo] = workMaRsi[r-1][instanceNo]+(speed*MathAbs(iRsi(tprice,rsiPeriod,rsiMode,i,instanceNo)/100.0-0.5))*(tprice-workMaRsi[r-1][instanceNo]);
   return(workMaRsi[r][instanceNo]);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

string rsiMethodNames[] = {"rsi","Wilders rsi","rsx","Cuttler RSI"};
string getRsiName(int& method)
{
   int max = ArraySize(rsiMethodNames)-1;
      method=MathMax(MathMin(method,max),0); return(rsiMethodNames[method]);
}

//
//
//
//
//

double workRsi[][26];
#define _price  0
#define _change 1
#define _changa 2

double iRsi(double price, double period, int rsiMode, int i, int instanceNo=0)
{
   if (ArrayRange(workRsi,0)!=Bars) ArrayResize(workRsi,Bars);
      int z = instanceNo*13; 
      int r = Bars-i-1;
   
   //
   //
   //
   //
   //
   
   workRsi[r][z+_price] = price;
   switch (rsiMode)
   {
      case 0:
         double alpha = 1.0/period; 
         if (r<period)
            {
               int k; double sum = 0; for (k=0; k<period && (r-k-1)>=0; k++) sum += MathAbs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
                  workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/MathMax(k,1);
                  workRsi[r][z+_changa] =                                         sum/MathMax(k,1);
            }
         else
            {
               double change = workRsi[r][z+_price]-workRsi[r-1][z+_price];
                               workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(        change  - workRsi[r-1][z+_change]);
                               workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(MathAbs(change) - workRsi[r-1][z+_changa]);
            }
         if (workRsi[r][z+_changa] != 0)
               return(50.0*(workRsi[r][z+_change]/workRsi[r][z+_changa]+1));
         else  return(50.0);
         
      //
      //
      //
      //
      //
      
      case 1 :
         workRsi[r][z+1] = iSmma(0.5*(MathAbs(workRsi[r][z+_price]-workRsi[r-1][z+_price])+(workRsi[r][z+_price]-workRsi[r-1][z+_price])),0.5*(period-1),Bars-i-1,instanceNo*2+0);
         workRsi[r][z+2] = iSmma(0.5*(MathAbs(workRsi[r][z+_price]-workRsi[r-1][z+_price])-(workRsi[r][z+_price]-workRsi[r-1][z+_price])),0.5*(period-1),Bars-i-1,instanceNo*2+1);
         if((workRsi[r][z+1] + workRsi[r][z+2]) != 0) 
               return(100.0 * workRsi[r][z+1]/(workRsi[r][z+1] + workRsi[r][z+2]));
         else  return(50);

      //
      //
      //
      //
      //

      case 2 :     
         double Kg = (3.0)/(2.0+period), Hg = 1.0-Kg;
         if (r<period) { for (k=1; k<13; k++) workRsi[r][k+z] = 0; return(50); }  

         //
         //
         //
         //
         //
      
         double mom = workRsi[r][_price+z]-workRsi[r-1][_price+z];
         double moa = MathAbs(mom);
         for (k=0; k<3; k++)
         {
            int kk = k*2;
            workRsi[r][z+kk+1] = Kg*mom                + Hg*workRsi[r-1][z+kk+1];
            workRsi[r][z+kk+2] = Kg*workRsi[r][z+kk+1] + Hg*workRsi[r-1][z+kk+2]; mom = 1.5*workRsi[r][z+kk+1] - 0.5 * workRsi[r][z+kk+2];
            workRsi[r][z+kk+7] = Kg*moa                + Hg*workRsi[r-1][z+kk+7];
            workRsi[r][z+kk+8] = Kg*workRsi[r][z+kk+7] + Hg*workRsi[r-1][z+kk+8]; moa = 1.5*workRsi[r][z+kk+7] - 0.5 * workRsi[r][z+kk+8];
         }
         if (moa != 0)
              return(MathMax(MathMin((mom/moa+1.0)*50.0,100.00),0.00)); 
         else return(50);
            
      //
      //
      //
      //
      //
      
      case 3 :
         double sump = 0;
         double sumn = 0;
         for (k=0; k<period; k++)
         {
            double diff = workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price];
               if (diff > 0) sump += diff;
               if (diff < 0) sumn -= diff;
         }
         if (sumn > 0)
               return(100.0-100.0/(1.0+sump/sumn));
         else  return(50);
   } 
   return(50);
}

//
//
//
//
//
//

double workSmma[][4];
double iSmma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= Bars) ArrayResize(workSmma,Bars);

   //
   //
   //
   //
   //

   if (r<period)
         workSmma[r][instanceNo] = price;
   else  workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
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
         first[i]  = from[i];
         second[i] = EMPTY_VALUE;
      }
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