//+------------------------------------------------------------------+
//|                                                  LaguerreRSI.mq4 |
//|                                                                  |
//| a variation on the LAguerre RSI theme                            |
//| solves some problems with low lag smoothing                      |
//+------------------------------------------------------------------+

#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  LimeGreen
#property indicator_color2  Orange
#property indicator_color3  Orange
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2

//
//
//
//
//

enum prices
{
   pr_close,   // Close
   pr_open,    // Open
   pr_high,    // High
   pr_low,     // Low
   pr_median,  // Median
   pr_typical, // Typical
   pr_weighted // Weighted
};

extern double LaguerreGamma   = 0.7;
extern prices LaguerrePrice   = pr_close; 
extern int    RSIDataLevel    = 0;
extern int    RSIPeriod       = 8;
extern bool   Smooth          = true;
extern bool   alertsOn        = true;
extern bool   alertsOnCurrent = false;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = false;
extern bool   alertsNotify    = false;
extern bool   alertsEmail     = false;
extern string soundFile       = "alert2.wav";

//
//
//
//
//

double RSI[];
double RSIda[];
double RSIdb[];
double L0[];
double L1[];
double L2[];
double L3[];
double LR[];
double slope[];

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
   IndicatorBuffers(9);
	SetIndexBuffer(0, RSI);   SetIndexLabel(0,"Laguerre RSI");
	SetIndexBuffer(1, RSIda); SetIndexLabel(1,"Laguerre RSI");
	SetIndexBuffer(2, RSIdb); SetIndexLabel(2,"Laguerre RSI");
   SetIndexBuffer(3, L0);
   SetIndexBuffer(4, L1);
   SetIndexBuffer(5, L2);
   SetIndexBuffer(6, L3);
   SetIndexBuffer(7, LR);
   SetIndexBuffer(8, slope);
         RSIDataLevel = MathMax(MathMin(RSIDataLevel,2),0);
   IndicatorShortName("Laguerre RSI variation ("+DoubleToStr(LaguerreGamma, 2)+","+RSIDataLevel+","+RSIPeriod+")");
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

int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit;

   if (counted_bars<0) return(-1);
   if (counted_bars>0) counted_bars--;
          limit = MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //
   
   if (slope[limit] == -1) ClearPoint(limit,RSIda,RSIdb);
   for (i=limit; i>=0; i--)
   {
		double Price=iMA(NULL,0,1,0,MODE_SMA,(int)LaguerrePrice,i);
		
		L0[i] = (1.0 - LaguerreGamma)*Price + LaguerreGamma*L0[i+1];
		L1[i] = -LaguerreGamma*L0[i] + L0[i+1] + LaguerreGamma*L1[i+1];
		L2[i] = -LaguerreGamma*L1[i] + L1[i+1] + LaguerreGamma*L2[i+1];
		L3[i] = -LaguerreGamma*L2[i] + L2[i+1] + LaguerreGamma*L3[i+1];

      //
      //
      //
      //
      //
      		
         double cu = 0;
         double cd = 0;
         for (int k=0; k<RSIPeriod; k++)
            {
               double diff;
               switch (RSIDataLevel) 
               {
                  case 0: diff = L0[i+k]-L1[i+k]; break;
                  case 1: diff = L1[i+k]-L2[i+k]; break;
                  case 2: diff = L2[i+k]-L3[i+k]; break;
               }                  
               if (diff > 0) cu += diff;
               if (diff < 0) cd -= diff;
            }

         //
         //
         //
         //
         //
         
         if ((cu+cd)!=0)
               LR[i] = 0.5*((cu-cd)/(cu+cd)+1);
         else  LR[i] = 0;
         if (Smooth)
               RSI[i] = (LR[i] + 2.0*LR[i+1] + LR[i+2])/4.0;
         else  RSI[i] = LR[i];               
         slope[i] = slope[i+1];
            if (RSI[i]>RSI[i+1]) slope[i] =  1;
            if (RSI[i]<RSI[i+1]) slope[i] = -1;
            if (slope[i] == -1) PlotPoint(i,RSIda,RSIdb,RSI);
	}
   
   //
      //
      //
      //
      //
      
      if (alertsOn)
      {
        if (alertsOnCurrent)
             int whichBar = 0;
        else     whichBar = 1; 
        if (slope[whichBar] != slope[whichBar+1])
        if (slope[whichBar] == 1)
              doAlert("sloping up");
        else  doAlert("sloping down");       
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

void ClearPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}
void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            {  first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  {  second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     {   first[i] = from[i];                          second[i] = EMPTY_VALUE; }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Laguerre rsi variation ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Laguerre rsi variation "),message);
             if (alertsSound)   PlaySound(soundFile);
      }
}
