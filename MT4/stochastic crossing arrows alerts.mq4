//+------------------------------------------------------------------+
//|                                                stoch crosses.mq4 |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  clrLime
#property indicator_color2  clrRed
#property strict

enum enArrowsOn
{
   arr_onKD_cross,        // Show arrows on stoch/signal cross
   arr_onK_OBOScross,     // Show arrows on stoch leaving OB/OS
   arr_onD_OBOScross      // Show arrows on stoch signal leaving OB/OS
};

input int            KPeriod         = 5;               // Stochastic K period
input int            DPeriod         = 3;               // Stochastic D period
input int            Slowing         = 3;               // Stochastic slowing
input ENUM_MA_METHOD MA_Method       = MODE_SMA;        // Stochastic ma type
input ENUM_STO_PRICE PriceField      = 0;               // Stochastic price
input enArrowsOn     arrowsOn        = arr_onKD_cross;  
input double         OverBoughtLevel = 80;              // Overbought level
input double         OverSoldLevel   = 20;              // Oversold level
input bool           alertsOn        = true;            // Alerts on true/false?
input bool           alertsOnCurrent = false;           // Alerts current bar true/false?
input bool           alertsMessage   = true;            // Alerts message true/false?
input bool           alertsSound     = false;           // Alerts sound true/false?
input bool           alertsEmail     = false;           // Alerts email true/false?
input bool           alertsNotify    = false;           // Alerts notification true/false?
input string         soundFile       = "alert2.wav";    // Alerts Sound file
input int            ArrowCodeUp     = 241;             // Arrow code up
input int            ArrowCodeDn     = 242;             // Arrow code down
input double         ArrowGapUp      = 0.5;             // Gap for arrow up        
input double         ArrowGapDn      = 0.5;             // Gap for arrow down
input int            ArrowSizeUp     = 2;               // Arrow up size
input int            ArrowSizeDn     = 2;               // Arrow down size

double CrossUp[],CrossDn[],trend[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

int OnInit()
{
   IndicatorBuffers(3);   
   SetIndexBuffer(0, CrossUp,INDICATOR_DATA);  SetIndexStyle(0,DRAW_ARROW,0,ArrowSizeUp); SetIndexArrow(0,ArrowCodeUp);
   SetIndexBuffer(1, CrossDn,INDICATOR_DATA);  SetIndexStyle(1,DRAW_ARROW,0,ArrowSizeDn); SetIndexArrow(1,ArrowCodeDn);
   SetIndexBuffer(2, trend);     
   IndicatorShortName("Stoch Cross ");
return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason){     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

int  OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i=rates_total-prev_calculated+1; if (i>=rates_total) i=rates_total-1; 
   
   //
   //
   //
         
   for (; i>=0 && !_StopFlag; i--)
   {
       double stoNow = iStochastic(NULL,0,KPeriod,DPeriod,Slowing,MA_Method,PriceField,MODE_MAIN,i);
       double stoPre = iStochastic(NULL,0,KPeriod,DPeriod,Slowing,MA_Method,PriceField,MODE_MAIN,i+1);
       double sigNow = iStochastic(NULL,0,KPeriod,DPeriod,Slowing,MA_Method,PriceField,MODE_SIGNAL,i);
       double sigPre = iStochastic(NULL,0,KPeriod,DPeriod,Slowing,MA_Method,PriceField,MODE_SIGNAL,i+1);
       switch(arrowsOn)
       {
          case arr_onK_OBOScross:          trend[i] = (stoNow>OverSoldLevel   && stoPre<OverSoldLevel)   ?  1 : 
                                                      (stoNow<OverBoughtLevel && stoPre>OverBoughtLevel) ? -1 : 0; break;
          case arr_onD_OBOScross:          trend[i] = (sigNow>OverSoldLevel   && sigPre<OverSoldLevel)   ?  1 : 
                                                      (sigNow<OverBoughtLevel && sigPre>OverBoughtLevel) ? -1 : 0; break;
          default :  if (i<rates_total-1)  trend[i] = (stoNow>sigNow && stoPre<sigPre) ?  1 : 
                                                      (stoNow<sigNow && stoPre>sigPre) ? -1 : trend[i+1];
       }              
       if (i<rates_total-1 && trend[i]!=trend[i+1])
       {
           if (trend[i] ==  1) CrossUp[i] =  low[i] - iATR(NULL,0,15,i)*ArrowGapUp;
           if (trend[i] == -1) CrossDn[i] = high[i] + iATR(NULL,0,15,i)*ArrowGapDn;
       }
    }
    
    //
    //
    //
    //
    //
    
    if (alertsOn)
    {
      int whichBar = (alertsOnCurrent) ? 0 : 1;
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(whichBar,"buy");
         if (trend[whichBar] ==-1) doAlert(whichBar,"sell");
      }         
   }
return(rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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

          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Stochastic crossing "+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(_Symbol+" Stochastic crossing ",message);
             if (alertsSound)   PlaySound(soundFile);
      }
}

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