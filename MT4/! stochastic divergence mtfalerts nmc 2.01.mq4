//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  clrAqua
#property indicator_color2  clrMagenta
#property indicator_color3	 clrLightSeaGreen
#property indicator_color4	 clrRed
#property indicator_level1	 80
#property indicator_level2	 20
#property indicator_maximum 100
#property indicator_minimum 0

//
//
//
//
//

extern string TimeFrame                 = "Current time frame";
extern int    StoKPeriod                = 8;
extern int    StoDPeriod                = 3;
extern int    StoSlowing                = 3;
extern int    StoPrice                  = 0;
extern int    SignalMode                = MODE_SMA;
extern int    DivergearrowSize          = 0;
extern double arrowsUpperGap            = 0.25;
extern double arrowsLowerGap            = 0.25;
extern bool   drawDivergences           = true;
extern bool   ShowClassicalDivergence   = true;
extern bool   ShowHiddenDivergence      = false;
extern bool   drawIndicatorTrendLines   = true;
extern bool   drawPriceTrendLines       = true;
extern color  divergenceBullishColor    = clrLime;
extern color  divergenceBearishColor    = clrRed;
input ENUM_LINE_STYLE cStyle            = STYLE_SOLID; // classic divergence style
input int     cWidth                    = 2;           // classic divergence width
input ENUM_LINE_STYLE hStyle            = STYLE_DOT;   // hidden divergence style
input int     hWidth                    = 0;           // hidden divergence width 
extern string drawLinesIdentificator    = "stochdiverge1";
extern bool   divergenceAlert           = true;
extern bool   divergenceAlertsMessage   = true;
extern bool   divergenceAlertsSound     = true;
extern bool   divergenceAlertsEmail     = false;
extern bool   divergenceAlertsNotify    = false;
extern string divergenceAlertsSoundName = "alert1.wav";
extern bool   alertsOn                  = true;
extern bool   alertsOnCurrent           = true;
extern bool   alertsMessage             = true;
extern bool   alertsSound               = true;
extern bool   alertsNotify              = true;
extern bool   alertsEmail               = false;
extern string soundFile                 = "alert2.wav"; 



//
//
//
//
//

double bullishDivergence[];
double bearishDivergence[];
double sto[];
double sig[];
double trend[];

//
//
//
//
//

string indicatorName;
string labelNames;

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;


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
   IndicatorBuffers(5);
   SetIndexBuffer(0,bullishDivergence); SetIndexStyle(0,DRAW_ARROW,0,DivergearrowSize); SetIndexArrow(0,233);
   SetIndexBuffer(1,bearishDivergence); SetIndexStyle(1,DRAW_ARROW,0,DivergearrowSize); SetIndexArrow(1,234); 
   SetIndexBuffer(2,sto);
   SetIndexBuffer(3,sig);
   SetIndexBuffer(4,trend);
   
      //
      //
      //
      //
      //
      
      timeFrame     = stringToTimeFrame(TimeFrame);
      labelNames    = "Stochastic_DivergenceLine "+drawLinesIdentificator+":";
      indicatorName = timeFrameToString(timeFrame)+" Stochastic ("+StoKPeriod+","+StoDPeriod+","+StoSlowing+")";
      IndicatorShortName(indicatorName);
      
      //
      //
      //
      //
      //
      
      indicatorFileName = WindowExpertName();
      calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
      returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
return(0);
}

//
//
//
//
//

int deinit()
{
   int length=StringLen(labelNames);
   for(int i=ObjectsTotal()-1; i>=0; i--)
   {
      string name = ObjectName(i);
      if(StringSubstr(name,0,length) == labelNames)  ObjectDelete(name);   
   }
   return(0);
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int i,limit,counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars)  { bullishDivergence[0] = limit+1; return(0); }
   
   //
   //
   //
   //
   //
   
   if (calculateValue || timeFrame == Period())
   {     
     for (i=limit; i>=0; i--)
     {
        sto[i] = iStochastic(NULL,0,StoKPeriod,StoDPeriod,StoSlowing,SignalMode,StoPrice,MODE_MAIN  ,i);
        sig[i] = iStochastic(NULL,0,StoKPeriod,StoDPeriod,StoSlowing,SignalMode,StoPrice,MODE_SIGNAL,i);
          trend[i] = trend[i+1];
          if (sto[i]>sig[i]) trend[i]= 1;
          if (sto[i]<sig[i]) trend[i]=-1;
          if (drawDivergences)
          {
            CatchBullishDivergence(i);
            CatchBearishDivergence(i);
          }        
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
     for (i=limit;i>=0;i--)
     {
        int y = iBarShift(NULL,timeFrame,Time[i]);
           sto[i]                 = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",StoKPeriod,StoDPeriod,StoSlowing,StoPrice,SignalMode,DivergearrowSize,arrowsUpperGap,arrowsLowerGap,drawDivergences,ShowClassicalDivergence,ShowHiddenDivergence,drawIndicatorTrendLines,drawPriceTrendLines,divergenceBullishColor,divergenceBearishColor,cStyle,cWidth,hStyle,hWidth,drawLinesIdentificator,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,2,y); 
           sig[i]                 = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",StoKPeriod,StoDPeriod,StoSlowing,StoPrice,SignalMode,DivergearrowSize,arrowsUpperGap,arrowsLowerGap,drawDivergences,ShowClassicalDivergence,ShowHiddenDivergence,drawIndicatorTrendLines,drawPriceTrendLines,divergenceBullishColor,divergenceBearishColor,cStyle,cWidth,hStyle,hWidth,drawLinesIdentificator,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,3,y); 
           bullishDivergence[i]   = EMPTY_VALUE;
           bearishDivergence[i]   = EMPTY_VALUE;

           int firstBar = iBarShift(NULL,0,iTime(NULL,timeFrame,y));
           if (i==firstBar)
           {
             bullishDivergence[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",StoKPeriod,StoDPeriod,StoSlowing,StoPrice,SignalMode,DivergearrowSize,arrowsUpperGap,arrowsLowerGap,drawDivergences,ShowClassicalDivergence,ShowHiddenDivergence,drawIndicatorTrendLines,drawPriceTrendLines,divergenceBullishColor,divergenceBearishColor,cStyle,cWidth,hStyle,hWidth,drawLinesIdentificator,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,0,y);
             bearishDivergence[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",StoKPeriod,StoDPeriod,StoSlowing,StoPrice,SignalMode,DivergearrowSize,arrowsUpperGap,arrowsLowerGap,drawDivergences,ShowClassicalDivergence,ShowHiddenDivergence,drawIndicatorTrendLines,drawPriceTrendLines,divergenceBullishColor,divergenceBearishColor,cStyle,cWidth,hStyle,hWidth,drawLinesIdentificator,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,1,y); 
           }
      }
      manageAlerts();                
return(0);
}

//
//
//
//
//

void CatchBullishDivergence(int shift)
{
   shift++;
         bullishDivergence[shift] = EMPTY_VALUE;
            ObjectDelete(labelNames+"l"+DoubleToStr(Time[shift],0));
            ObjectDelete(labelNames+"l"+"os" + DoubleToStr(Time[shift],0));            
   if(!IsIndicatorLow(shift)) return;  

   //
   //
   //
   //
   //
      
   int currentLow = shift;
   int lastLow    = GetIndicatorLastLow(shift+1);
   if (sto[currentLow] > sto[lastLow] && Low[currentLow] < Low[lastLow])
   {
     if (ShowClassicalDivergence)
     {
        bullishDivergence[currentLow] = sto[currentLow] - arrowsLowerGap * iATR(NULL,0,20,currentLow);
        if (drawPriceTrendLines)    DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow],    divergenceBullishColor,cStyle,cWidth);
        if (drawIndicatorTrendLines)DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],sto[currentLow],sto[lastLow],divergenceBullishColor,cStyle,cWidth); // solid
        if (divergenceAlert)        DisplayAlert("Classical bullish divergence",currentLow);  
     }
                        
   }
     
   //
   //
   //
   //
   //
        
   if (sto[currentLow] < sto[lastLow] && Low[currentLow] > Low[lastLow])
   {
     if (ShowHiddenDivergence)
     {
        bullishDivergence[currentLow] = sto[currentLow] - arrowsLowerGap * iATR(NULL,0,20,currentLow);
        if (drawPriceTrendLines)     DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow],     divergenceBullishColor, hStyle,hWidth); // dot
        if (drawIndicatorTrendLines) DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],sto[currentLow], sto[lastLow],divergenceBullishColor, hStyle,hWidth);
        if (divergenceAlert)         DisplayAlert("Reverse bullish divergence",currentLow); 
     }
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void CatchBearishDivergence(int shift)
{
   shift++; 
         bearishDivergence[shift] = EMPTY_VALUE;
            ObjectDelete(labelNames+"h"+DoubleToStr(Time[shift],0));
            ObjectDelete(labelNames+"h"+"os" + DoubleToStr(Time[shift],0));            
   if(IsIndicatorPeak(shift) == false) return;
   int currentPeak = shift;
   int lastPeak = GetIndicatorLastPeak(shift+1);

   //
   //
   //
   //
   //
      
   if (sto[currentPeak] < sto[lastPeak] && High[currentPeak]>High[lastPeak])
   {
     if (ShowClassicalDivergence)
     {
        bearishDivergence[currentPeak] = sto[currentPeak] + arrowsUpperGap * iATR(NULL,0,20,currentPeak);
        if (drawPriceTrendLines)     DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak],  divergenceBearishColor,cStyle,cWidth); // solid
        if (drawIndicatorTrendLines) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],sto[currentPeak],sto[lastPeak],divergenceBearishColor,cStyle,cWidth); // solid
        if (divergenceAlert)         DisplayAlert("Classical bearish divergence",currentPeak);
     } 
                        
   }
   
   //
   //
   //
   //
   //

   if (sto[currentPeak] > sto[lastPeak] && High[currentPeak] < High[lastPeak])
   {
     if (ShowHiddenDivergence)
     {
        bearishDivergence[currentPeak] = sto[currentPeak] + arrowsUpperGap * iATR(NULL,0,20,currentPeak);
        if (drawPriceTrendLines)     DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak],  divergenceBearishColor, hStyle,hWidth); // dot
        if (drawIndicatorTrendLines) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],sto[currentPeak],sto[lastPeak],divergenceBearishColor, hStyle,hWidth);
        if (divergenceAlert)         DisplayAlert("Reverse bearish divergence",currentPeak);
     }
                         
   }   
}

//
//
//
//
//

bool IsIndicatorPeak(int shift)
{
   if(sto[shift] >= sto[shift+1] && sto[shift] > sto[shift+2] && sto[shift] > sto[shift-1])
       return(true);
   else 
       return(false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

bool IsIndicatorLow(int shift)
{
   if(sto[shift] <= sto[shift+1] && sto[shift] < sto[shift+2] && sto[shift] < sto[shift-1])
       return(true);
   else 
       return(false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

int GetIndicatorLastPeak(int shift)
{
    for(int i = shift+5; i < Bars; i++)
    {
       if(sto[i] >= sto[i+1] && sto[i] > sto[i+2] && sto[i] >= sto[i-1] && sto[i] > sto[i-2])
         return(i);
    }
return(-1);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

int GetIndicatorLastLow(int shift)
{
    for (int i = shift+5; i < Bars; i++)
    {
       if (sto[i] <= sto[i+1] && sto[i] < sto[i+2] && sto[i] <= sto[i-1] && sto[i] < sto[i-2])
         return(i);
}
     
return(-1);
}

//
//
//
//
//

void DisplayAlert(string doWhat, int shift)
{
    string dmessage;
    static datetime lastAlertTime;
    if(shift <= 2 && Time[0] != lastAlertTime)
    {
      dmessage =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Stochastic ",doWhat);
          if (divergenceAlertsMessage) Alert(dmessage);
          if (divergenceAlertsNotify)  SendNotification(dmessage);
          if (divergenceAlertsEmail)   SendMail(StringConcatenate(Symbol()," Stochastic "),dmessage);
          if (divergenceAlertsSound)   PlaySound(divergenceAlertsSoundName); 
          lastAlertTime = Time[0];
    }
}

//
//
//
//
//

void DrawPriceTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style, int lineWidth)
{
    string label = labelNames+first+"os"+DoubleToStr(t1,0);
      ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, 0, t1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, 0);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
         ObjectSet(label, OBJPROP_WIDTH, lineWidth);
}

//
//
//
//
//

void DrawIndicatorTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style, int lineWidth)
{
    int indicatorWindow = WindowFind(indicatorName);
    if (indicatorWindow < 0) return;
    
    //
    //
    //
    //
    //
    
    string label = labelNames+first+DoubleToStr(t1,0);
      ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, indicatorWindow, t1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, 0);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
         ObjectSet(label, OBJPROP_WIDTH, lineWidth);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   tfs = StringUpperCase(tfs);
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

string StringUpperCase(string str)
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(whichBar,"crossing signal up");
         if (trend[whichBar] ==-1) doAlert(whichBar,"crossing signal down");
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

           message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Stochastic ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(), Period(), " Stochastic "),message);
             if (alertsSound)   PlaySound(soundFile);
      }
}



