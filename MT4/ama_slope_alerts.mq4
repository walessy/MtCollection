//+------------------------------------------------------------------+
//|                                                    AMA SLOPE.mq4 |
//|                                                          Kalenzo |
//|                                     bartlomiej.gorski@gmail.com  |
//| I used the idea of P.Kauffman and code from KAMA                 |
//| made by © 2004, by konKop,wellx                                  |
//+------------------------------------------------------------------+
#property copyright "Kalenzo"
#property link      "bartlomiej.gorski@gmail.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Green
#property indicator_level1 0

//---- input parameters
extern int       periodAMA=9;
extern int       nfast=2;
extern int       nslow=30;
extern double    G=2.0;
extern int       trigger = 2;
extern color     triggerPlus = Green;
extern color     triggerMinus = Red;

extern string note             = "turn on Alert = true; turn off = false";
extern bool   alertsOn         = true;
extern bool   alertsOnCurrent  = true;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = true;
extern bool   alertsNotify     = false;
extern bool   alertsEmail      = false;
extern string soundfile        = "alert2.wav";
//---- buffers
double kAMAbuffer[];
double kAMAbuffer2[];
double trend[];

double amahisto1[];
double amahisto2[];
//+------------------------------------------------------------------+

int    cbars=0, prevbars=0, prevtime=0;

double slowSC,fastSC;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(5);
   SetIndexStyle(0,DRAW_LINE,0,1);
   SetIndexBuffer(0,kAMAbuffer);
   SetIndexStyle(1,DRAW_LINE,0,1);
   SetIndexBuffer(1,kAMAbuffer2);
   
   SetIndexStyle(2,DRAW_HISTOGRAM,0,1);
   SetIndexBuffer(2,amahisto1);
   SetIndexStyle(3,DRAW_HISTOGRAM,0,1);
   SetIndexBuffer(3,amahisto2);
   SetIndexBuffer(4,trend);
 
   IndicatorDigits(4);
   IndicatorShortName("AMA SLOPE");
   
   

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   drawLine((trigger*Point),"Trigger+", triggerPlus);
   drawLine((-trigger*Point),"Trigger-", triggerMinus);
   
   int    i,pos=0;
   double noise=0.000000001,AMA,AMA0,signal,ER;
   double dSC,ERSC,SSC,ddK;
   
   if (prevbars==Bars) return(0);
    
   slowSC=(2.0 /(nslow+1));
   fastSC=(2.0 /(nfast+1));

   cbars=IndicatorCounted();

   if (Bars<=(periodAMA+2)) return(0);
   if (cbars<0) return(-1);
   if (cbars>0) cbars--;
   pos=Bars-periodAMA-2;
   AMA0=Close[pos+1];
   while (pos>=0)
     {
      if(pos==Bars-periodAMA-2) AMA0=Close[pos+1];
      signal=MathAbs(Close[pos]-Close[pos+periodAMA]);
      noise=0.000000001;
      for(i=0;i<periodAMA;i++)
       {
        noise=noise+MathAbs(Close[pos+i]-Close[pos+i+1]);
       }
      ER =signal/noise;
      dSC=(fastSC-slowSC);
      ERSC=ER*dSC;
      SSC=ERSC+slowSC;
      AMA=AMA0+(MathPow(SSC,G)*(Close[pos]-AMA0));
      

      ddK=(AMA-AMA0);
      kAMAbuffer[pos]=ddK;     
      
      if(ddK<0)
      kAMAbuffer2[pos]=ddK; 
      trend[pos] = trend[pos+1];    
      
      if(ddK<0)
      {
         amahisto1[pos] = ddK;
         amahisto2[pos] = 0;
         trend[pos] =-1;
      }
      else
      {
         amahisto2[pos] = ddK;
         amahisto1[pos] = 0;  
         trend[pos] = 1;
      }
      
      AMA0=AMA;
      pos--;
     }
     
     if (alertsOn)
     {
       if (alertsOnCurrent)
            int whichBar = 0;
       else     whichBar = 1;
       if (trend[whichBar] != trend[whichBar+1])
       if (trend[whichBar] == 1)
             doAlert("Buy");
       else  doAlert("Sell");       
   }
prevbars=Bars;
return(0);
}

void drawLine(double lvl,string name, color Col)
{
         if(ObjectFind(name) == 0)
         {
            ObjectCreate(name, OBJ_HLINE, WindowFind("AMA SLOPE") , Time[0], lvl,Time[0],lvl);
            ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
            ObjectSet(name, OBJPROP_COLOR, Col);
            ObjectSet(name,OBJPROP_WIDTH,1);
         }
         else
         {
            ObjectDelete(name);
            ObjectCreate(name, OBJ_HLINE, WindowFind("AMA SLOPE") , Time[0], lvl,Time[0],lvl);
            ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
            ObjectSet(name, OBJPROP_COLOR, Col);
            ObjectSet(name,OBJPROP_WIDTH,1);
         }
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

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," AMA SLOPE ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," AMA SLOPE "),message);
             if (alertsSound)   PlaySound(soundfile);
      }
}
      
          