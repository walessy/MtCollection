//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1  PaleVioletRed
#property indicator_width1  2

extern int    momPeriod     = 25;
extern int    momPrice      = PRICE_CLOSE;
extern int    momSmooth     = 8;
extern double Levels        = 5;
double mom[];

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
   IndicatorDigits(6); 
      SetIndexBuffer(0,mom);
      //SetLevelValue(0, Levels);
      //SetLevelValue(1,-Levels);
      //SetLevelValue(2,0);
      return(0);  
}  
int deinit() { return(0);  }  

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
           int limit=MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //
   
   for(int i=limit; i>=0; i--)
   {
      double atr = iATR(NULL,0,momPeriod,i);
      double pr1 = iMA(NULL,0,1,0,MODE_SMA,momPrice,i);
      double pr2 = iMA(NULL,0,1,0,MODE_SMA,momPrice,i+momPeriod);
         if (atr!=0)
                mom[i] = (iNonLagMa(pr1,momSmooth,i,0)-iNonLagMa(pr2,momSmooth,i,1))/atr;
         else   mom[i] = 0;
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

#define Pi       3.14159265358979323846264338327950288
#define _length  0
#define _len     1
#define _weight  2

double  nlm_values[2][3];
double  nlm_prices[ ][2];
double  nlm_alphas[ ][2];

//
//
//
//
//

double iNonLagMa(double price, double length, int r, int instanceNo=0)
{
   if (ArrayRange(nlm_prices,0) != Bars) ArrayResize(nlm_prices,Bars); r = Bars-r-1;
   if (ArrayRange(nlm_values,0) <  instanceNo) ArrayResize(nlm_values,instanceNo);
                               nlm_prices[r][instanceNo]=price;
   if (length<3 || r<3) return(nlm_prices[r][instanceNo]);
   
   //
   //
   //
   //
   //
   
   if (nlm_values[instanceNo][_length] != length)
   {
      double Cycle = 4.0;
      double Coeff = 3.0*Pi;
      int    Phase = length-1;
      
         nlm_values[instanceNo][_length] = length;
         nlm_values[instanceNo][_len   ] = length*4 + Phase;  
         nlm_values[instanceNo][_weight] = 0;

         if (ArrayRange(nlm_alphas,0) < nlm_values[instanceNo][_len]) ArrayResize(nlm_alphas,nlm_values[instanceNo][_len]);
         for (int k=0; k<nlm_values[instanceNo][_len]; k++)
         {
            if (k<=Phase-1) 
                 double t = 1.0 * k/(Phase-1);
            else        t = 1.0 + (k-Phase+1)*(2.0*Cycle-1.0)/(Cycle*length-1.0); 
            double beta = MathCos(Pi*t);
            double g = 1.0/(Coeff*t+1); if (t <= 0.5 ) g = 1;
      
            nlm_alphas[k][instanceNo]        = g * beta;
            nlm_values[instanceNo][_weight] += nlm_alphas[k][instanceNo];
         }
   }
   
   //
   //
   //
   //
   //
   
   if (nlm_values[instanceNo][_weight]>0)
   {
      double sum = 0;
           for (k=0; k < nlm_values[instanceNo][_len]; k++) sum += nlm_alphas[k][instanceNo]*nlm_prices[r-k][instanceNo];
           return( sum / nlm_values[instanceNo][_weight]);
   }
   else return(0);           
}