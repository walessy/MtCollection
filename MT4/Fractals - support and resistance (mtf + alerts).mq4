#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  clrRed
#property indicator_color2  clrBlue
#property indicator_width1  2
#property indicator_width2  2
#property strict

//
//
//
//
//
extern ENUM_TIMEFRAMES    TimeFrame        = PERIOD_CURRENT;   // Time frame to use
extern int                FractalPeriod    = 5;                // Fractal period: 5 = built in fractal
extern ENUM_APPLIED_PRICE PriceHigh        = PRICE_HIGH;       // Price high
extern ENUM_APPLIED_PRICE PriceLow         = PRICE_LOW;        // Price low
extern bool               alertsOn         = false;            // Turn alerts on?
extern bool               alertsOnCurrent  = false;            // Alerts on still opened bar?
extern bool               alertsMessage    = true;             // Alerts should display message?
extern bool               alertsSound      = false;            // Alerts should play a sound?
extern bool               alertsNotify     = false;            // Alerts should send a notification?
extern bool               alertsEmail      = false;            // Alerts should send an email?
extern string             soundFile        = "alert2.wav";     // Sound file



double v1[],v2[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,FractalPeriod,PriceHigh,PriceLow,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,_buff,_ind)
  
int init()
{
   IndicatorBuffers(4);
   SetIndexBuffer(0,v1);  SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,159); SetIndexLabel(0,"Resistance");
   SetIndexBuffer(1,v2);  SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,159); SetIndexLabel(1,"Support");
   SetIndexBuffer(2,trend);
   SetIndexBuffer(3,count);
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period); 
     
   IndicatorShortName(timeFrameToString(TimeFrame)+"  Fractals - adjustable price S_R");
return(0);
}

//
//
//
//
//

int start()
{
   int i,k,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1); count[0]=limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(3,0)*TimeFrame/_Period));
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     v1[i] = _mtfCall(0,y);
                     v2[i] = _mtfCall(1,y);                                                
                }
     return(0);
     }
     
     //
     //
     //
     //
     //
     
     int half = FractalPeriod/2;    
     for(i=limit; i>=0; i--) 
     {
        bool   found     = true;
         double compareTo = iMA(NULL,0,1,0,MODE_SMA,PriceHigh,i);
         for (k=1; k<=half && (i+k)<Bars; k++)
            {
               if ((i+k)<Bars && iMA(NULL,0,1,0,MODE_SMA,PriceHigh,i+k)> compareTo) { found=false; break; }
               if ((i-k)>=0   && iMA(NULL,0,1,0,MODE_SMA,PriceHigh,i-k)>=compareTo) { found=false; break; }
            }
         if (found) v1[i] = iMA(NULL,0,1,0,MODE_SMA,PriceHigh,i);
         else       v1[i] = v1[i+1];

         //
         //
         //
         //
         //
      
         found     = true;
         compareTo = iMA(NULL,0,1,0,MODE_SMA,PriceLow,i);
         for (k=1; k<=half&& (i+k)<Bars; k++)
            {
               if ((i+k)<Bars && iMA(NULL,0,1,0,MODE_SMA,PriceLow,i+k)< compareTo) { found=false; break; }
               if ((i-k)>=0   && iMA(NULL,0,1,0,MODE_SMA,PriceLow,i-k)<=compareTo) { found=false; break; }
            }
         if (found) v2[i] = iMA(NULL,0,1,0,MODE_SMA,PriceLow,i);  
         else       v2[i] = v2[i+1];
         trend[i] = (i<Bars-1) ? (Close[i]>v1[i]) ? 1 : (Close[i]<v2[i]) ? -1 : trend[i+1] : 0;
         
   }
   if (alertsOn)
   {
       int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
        if (trend[whichBar] != trend[whichBar+1])
        if (trend[whichBar] == 1)
              doAlert(" breaking up");
        else  doAlert(" breaking down");       
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

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
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

           message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Fractal Support and Resistance ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(_Symbol+" Fractal Support and Resistance ",message);
             if (alertsSound)   PlaySound(soundFile);
      }
}


  
