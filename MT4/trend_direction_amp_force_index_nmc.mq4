//+------------------------------------------------------------------+
//|                                Trend direction & force index.mq4 |
//|                                                           mladen |
//|                                                                  |
//|                                                                  |
//| original metastock indicator made                                |
//| by Piotr Wojdylo                                                 |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  DimGray
#property indicator_color2  DimGray
#property indicator_color3  Red
#property indicator_maximum  1
#property indicator_minimum -1

//
//
//
//
//

extern int    trendPeriod = 20;
extern string timeFrame   = "Current time frame";

//
//
//
//
//

double   TrendBuffer[];
double   TriggBuffera[];
double   TriggBufferb[];
double   MMABuffer[];
double   SMMABuffer[];
double   TDFBuffer[];

//
//
//
//
//

datetime TimeArray[];
int      TimeFrame;
string   IndicatorFileName;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int init()
{
   IndicatorBuffers(6);
      SetIndexBuffer(0,TriggBuffera);
      SetIndexBuffer(1,TriggBufferb);
      SetIndexBuffer(2,TrendBuffer);
      SetIndexBuffer(3,MMABuffer);
      SetIndexBuffer(4,SMMABuffer);
      SetIndexBuffer(5,TDFBuffer);
      SetIndexLabel(0,NULL);
      SetIndexLabel(1,NULL);
      SetIndexLabel(2,"Trend direction & force");

   //
   //
   //
   //
   //
         
   IndicatorFileName = WindowExpertName();
   TimeFrame = stringToTimeFrame(timeFrame);      
   IndicatorShortName("Trend direction & force"+timeFrameToString(TimeFrame)+" ("+trendPeriod+")");
   return(0);
}
int deinit()
{
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int start()
{
   int counted_bars = IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
       
   //
   //
   //
   //
   //
   
   if (TimeFrame != Period())
      {
         limit = MathMax(limit,TimeFrame/Period());
         
         //
         //
         //
         //
         //
         
         for (int i=limit;i>=0;i--)
         {
            int y = iBarShift(NULL,timeFrame,Time[i]);
               TrendBuffer[i]  = iCustom(NULL,TimeFrame,IndicatorFileName,trendPeriod,2,y);
               TriggBuffera[i] =  0.05;
               TriggBufferb[i] = -0.05;
         }
         return(0);         
      }
      
   //
   //
   //
   //
   //
            
   double alpha = 2.0 /(trendPeriod+1.0); 
   for (i=limit;i>=0;i--) {
               MMABuffer[i]  = iMA(NULL,0,trendPeriod,0,MODE_EMA,PRICE_CLOSE,i);
               SMMABuffer[i] = SMMABuffer[i+1]+alpha*(MMABuffer[i]-SMMABuffer[i+1]);
                     double impetmma  = MMABuffer[i]  - MMABuffer[i+1];
                     double impetsmma = SMMABuffer[i] - SMMABuffer[i+1];
                     double divma     = MathAbs(MMABuffer[i]-SMMABuffer[i])/Point;
                     double averimpet = (impetmma+impetsmma)/(2*Point);
               TDFBuffer[i]  = divma*MathPow(averimpet,3);

               //
               //
               //
               //
               //
               
               double absValue = absHighest(TDFBuffer,trendPeriod*3,i);
               absValue = absHighest(TDFBuffer,trendPeriod*3,i);
               if (absValue > 0)
                     TrendBuffer[i] = TDFBuffer[i]/absValue;
               else  TrendBuffer[i] =   0.00;
                     TriggBuffera[i] =  0.05;
                     TriggBufferb[i] = -0.05;
      }

   //
   //
   //
   //
   //
      
   return(0);
   
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double absHighest(double& array[], int length,int shift)
{
   double result = 0.00;
   
   for (int i = length-1; i>=0; i--)
      if (result < MathAbs(array[shift+i]))
          result = MathAbs(array[shift+i]);
   return(result);          
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
   StringToUpper(tfs);
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
