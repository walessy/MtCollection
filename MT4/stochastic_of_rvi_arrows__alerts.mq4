//+------------------------------------------------------------------+
//|                                                          RVI.mq4 |
//|                                                                  |
//+------------------------------------------------------------------+
#property  copyright ""
#property  link      ""

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  Green
#property indicator_color2  OrangeRed

//
//
//
//
//

extern int    RVIPeriod        = 10;
extern int    StoPeriod        = 32;
extern int    StoSlowing       = 9;
extern bool   alertsOn         = true;
extern bool   alertsOnCurrent  = true;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = false;
extern bool   alertsNotify     = true;
extern bool   alertsEmail      = true;
extern string soundFile        = "alert2.wav"; 
extern bool   ShowArrows       = true;
extern string arrowsIdentifier = "StochRvi arrows1";
extern double arrowsUpperGap   = 1.0;
extern double arrowsLowerGap   = 1.0;
extern color  arrowsUpColor    = Lime;
extern color  arrowsDnColor    = Orange;

//
//
//
//
//

double stochRvi[];
double stochRviSignal[];
double rvi[];
double buffer1[];
double buffer2[];
double trend[];

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
   IndicatorBuffers(6);
      SetIndexBuffer(0,stochRvi);
      SetIndexBuffer(1,stochRviSignal);
      SetIndexBuffer(2,rvi);
      SetIndexBuffer(3,buffer1);
      SetIndexBuffer(4,buffer2);
      SetIndexBuffer(5,trend);
   IndicatorShortName("StochasticRVI");
   return(0);
}
int deinit()
{ 
   deleteArrows();  
return(0);
}

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
      buffer1[i] = ((Close[i]-Open[i])+2*(Close[i+1]-Open[i+1])+2*(Close[i+2]-Open[i+2])+(Close[i+3]-Open[i+3]))/6;
      buffer2[i] = ((High[i]-Low[i])  +2*(High[i+1]-Low[i+1])  +2*(High[i+2]-Low[i+2])  +(High[i+3]-Low[i+3])  )/6;
      
      //
      //
      //
      //
      //
      
      double num   = 0.0; 
      double denom = 0.0;
         for(int k=0; k<RVIPeriod; k++)
         {
            num   += buffer1[i+k];
            denom += buffer2[i+k];
         }
         if(denom!=0.0)
               rvi[i] = num/denom;
         else  rvi[i] = 0.0;
         
         //
         //
         //
         //
         //
         
         stochRvi[i]       = iStoch(rvi[i],rvi[i],rvi[i],StoPeriod,StoSlowing,i,0);
         stochRviSignal[i] = (stochRvi[i]+2*stochRvi[i+1]+2*stochRvi[i+2]+stochRvi[i+3])/6; 
         trend[i] = trend[i+1];
         if (stochRvi[i]>stochRviSignal[i]) trend[i] = 1;
         if (stochRvi[i]<stochRviSignal[i]) trend[i] =-1;
         
         //
         //
         //
         //
         //
         
         if (ShowArrows)
         {
            deleteArrow(Time[i]);
            if (trend[i]!=trend[i+1])
            {
              if (trend[i] == 1) drawArrow(i,arrowsUpColor,241,false);
              if (trend[i] ==-1) drawArrow(i,arrowsDnColor,242,true);
            }
         }
   
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
      if (trend[whichBar] != trend[whichBar+1])
      if (trend[whichBar] == 1)
            doAlert("crossing signal up");
      else  doAlert("crossing signal down");       
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

double workSto[][5];
#define _hi 0
#define _lo 1
#define _re 2
#define _ma 3
#define _mi 4
double iStoch(double priceR, double priceH, double priceL, int period, int slowing, int i, int instanceNo=0)
{
   if (ArrayRange(workSto,0)!=Bars) ArrayResize(workSto,Bars); i = Bars-i-1; instanceNo *= 5;
   
   //
   //
   //
   //
   //
   
   workSto[i][_hi+instanceNo] = priceH;
   workSto[i][_lo+instanceNo] = priceL;
   workSto[i][_re+instanceNo] = priceR;
   workSto[i][_ma+instanceNo] = priceH;
   workSto[i][_mi+instanceNo] = priceL;
      for (int k=1; k<period && (i-k)>=0; k++)
      {
         workSto[i][_mi+instanceNo] = MathMin(workSto[i][_mi+instanceNo],workSto[i-k][instanceNo+_lo]);
         workSto[i][_ma+instanceNo] = MathMax(workSto[i][_ma+instanceNo],workSto[i-k][instanceNo+_hi]);
      }                   
      double sumlow  = 0.0;
      double sumhigh = 0.0;
      for(k=0; k<slowing; k++)
      {
         sumlow  += workSto[i-k][_re+instanceNo]-workSto[i-k][_mi+instanceNo];
         sumhigh += workSto[i-k][_ma+instanceNo]-workSto[i-k][_mi+instanceNo];
      }

   //
   //
   //
   //
   //
   
   if(sumhigh!=0.0) 
         return(100.0*sumlow/sumhigh);
   else  return(0);    
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
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

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Stochastic of Rvi ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Stochastic of Rvi "),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
  
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}

//
//
//
//
//

void deleteArrows()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}

//
//
//
//
//

void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
}





