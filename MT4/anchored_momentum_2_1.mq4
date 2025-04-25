//+------------------------------------------------------------------+
//|                                            Anchored momentum.mq4 |
//|                                                           mladen |
//|                                                                  |
//| developed by Rudy Stefenel                                       |
//| Technical analysis of Stoctks and Commodities (TASC)             |
//| february 1998 - article : "Anchored momentum"                    |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  DeepSkyBlue
#property indicator_color2  DeepSkyBlue
#property indicator_color3  Orange
#property indicator_color4  Orange
#property indicator_color5  DarkGray
#property indicator_width1  2
#property indicator_width3  2
#property indicator_width5  3

//
//
//
//
//

enum amType
{
   typeGeneral,    // General
   typeMost,       // General with EMA
   typeGeneralEma, // Most
   typeMostEma     // Most with EMA
};
extern int          MomPeriod    = 10;
extern int          EmaPeriod    =  7;
extern int          SmaPeriod    =  7;
extern amType       MomentumType = typeMost;
extern ENUM_APPLIED_PRICE AppliedPrice = PRICE_CLOSE;

//
//
//
//
//

double Momentuu[];
double Momentud[];
double Momentdd[];
double Momentdu[];
double Momentul[];
double Buffers[];
double Buffere[];
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
   IndicatorBuffers(8);
      SetIndexBuffer(0,Momentuu);  SetIndexLabel(01,"Momentum"); SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexBuffer(1,Momentud);  SetIndexLabel(1,"Momentum"); SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexBuffer(2,Momentdd);  SetIndexLabel(2,"Momentum"); SetIndexStyle(2,DRAW_HISTOGRAM);
      SetIndexBuffer(3,Momentdu);  SetIndexLabel(3,"Momentum"); SetIndexStyle(3,DRAW_HISTOGRAM);
      SetIndexBuffer(4,Momentul);
      SetIndexBuffer(5,Buffers);
      SetIndexBuffer(6,Buffere);
      SetIndexBuffer(7,slope);
      
      //
      //
      //
      //
      //
      
      MomPeriod = MathMax(SmaPeriod,MomPeriod);
      MomPeriod = MathMax(EmaPeriod,MomPeriod);
      MomentumType = MathMax(MathMin(MomentumType,3),0);
      string type;
      switch (MomentumType)
         {
            case typeGeneral :    type = "General";          break;
            case typeGeneralEma : type = "General with EMA"; break;
            case typeMost :       type = "Most";             break;
            case typeMostEma :    type = "Most with EMA";
         }
      IndicatorShortName(type+" ("+SmaPeriod+","+EmaPeriod+","+MomPeriod+")");
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
//

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
   
   for(int i = limit; i >= 0; i--)
   {
      double price = iMA(NULL,0,1,0,MODE_SMA,AppliedPrice,i);
      int    index;

      //
      //
      //
      //
      //
      
      switch (MomentumType)
         {
            case typeGeneral :
                  index       = i+(MomPeriod-((SmaPeriod-1)/2.00));
                  Buffers[i]  = iMA(NULL,0,SmaPeriod,0,MODE_SMA,AppliedPrice,i);
                  if (Buffers[index] != 0)
                        Momentul[i] = 100.00 * (price / Buffers[index] - 1.00);
                        break;
                        
                  //
                  //
                  //
                  //
                  //
                                          
            case typeMost :                                    
                  Buffers[i]  = iMA(NULL,0,2.00*MomPeriod+1,0,MODE_SMA,AppliedPrice,i);
                  if (Buffers[i] != 0)
                        Momentul[i] = 100.00 * (price / Buffers[i] - 1.00);
                        break;

                  //
                  //
                  //
                  //
                  //
                  
            case typeGeneralEma :
                  index       = i+(MomPeriod-((SmaPeriod-1)/2.00));
                  Buffers[i]  = iMA(NULL,0,SmaPeriod,0,MODE_SMA,AppliedPrice,i);
                  Buffere[i]  = iMA(NULL,0,EmaPeriod,0,MODE_EMA,AppliedPrice,i);
                  if (Buffers[index] != 0)
                        Momentul[i] = 100.00 * (Buffere[i] / Buffers[index] - 1.00);
                        break;
                  //
                  //
                  //
                  //
                  //
                                          
            case typeMostEma :
                  Buffers[i]  = iMA(NULL,0,2.00*MomPeriod+1,0,MODE_SMA,AppliedPrice,i);
                  Buffere[i]  = iMA(NULL,0,EmaPeriod,0,MODE_EMA,AppliedPrice,i);
                  if (Buffers[i] != 0)
                        Momentul[i] = 100.00 * (Buffere[i] / Buffers[i] - 1.00);
         }
         Momentuu[i] = EMPTY_VALUE;
         Momentud[i] = EMPTY_VALUE;
         Momentdd[i] = EMPTY_VALUE;
         Momentdu[i] = EMPTY_VALUE;
         slope[i]    = slope[i+1];
         if (Momentul[i]>Momentul[i+1]) slope[i] =  1;
         if (Momentul[i]<Momentul[i+1]) slope[i] = -1;
         if (Momentul[i]>0)
         {
            if (slope[i]==1) 
                  Momentuu[i] = Momentul[i];
            else  Momentud[i] = Momentul[i];
         }
         if (Momentul[i]<0)
         {
            if (slope[i]==1) 
                  Momentdu[i] = Momentul[i];
            else  Momentdd[i] = Momentul[i];
         }
   }
   return(0);
}