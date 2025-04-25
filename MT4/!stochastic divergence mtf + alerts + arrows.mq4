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

extern ENUM_TIMEFRAMES   TimeFrame      = PERIOD_CURRENT;    // Time frame
extern int    StoKPeriod                = 8;
extern int    StoDPeriod                = 3;
extern int    StoSlowing                = 3;
extern ENUM_STO_PRICE    StoPrice       = STO_CLOSECLOSE;
extern ENUM_MA_METHOD    SignalMode     = MODE_SMA;
extern int    DivergearrowSize          = 0;
extern double arrowsUpperGap            = 0.25;
extern double arrowsLowerGap            = 0.25;
input bool    DivArrowOnFirst           = true; //Divergence arrow on first mtf bar
extern bool   drawDivergences           = true;
extern bool   ShowClassicalDivergence   = true;
extern bool   ShowHiddenDivergence      = false;
extern bool   drawIndicatorTrendLines   = true;
extern bool   drawPriceTrendLines       = true;
extern color  divergenceBullishColor    = clrLime;
extern color  divergenceBearishColor    = clrRed;
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
input bool    arrowsVisible             = false;             // Arrows visible true/false?
input bool    arrowsOnNewest            = false;             // Arrows drawn on newest bar of higher time frame bar true/false?
input string  arrowsIdentifier          = "sto Arrows1";     // Unique ID for arrows
input double  arrowsUpGap               = 0.5;               // Upper arrow gap
input double  arrowsDnGap               = 0.5;               // Lower arrow gap
input color   arrowsUpColor             = clrBlue;           // Up arrow color
input color   arrowsDnColor             = clrCrimson;        // Down arrow color
input int     arrowsUpCode              = 221;               // Up arrow code
input int     arrowsDnCode              = 222;               // Down arrow code
input int     arrowsUpSize              = 2;                 // Up arrow size
input int     arrowsDnSize              = 2;                 // Down arrow size
input bool    Interpolate               = true;              // Interpolate in mtf mode?



//
//
//
//
//

double bullishDivergence[];
double bearishDivergence[];
double sto[];
double sig[];
double trend[],count[];
string indicatorFileName,indicatorName,labelNames;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,StoKPeriod,StoDPeriod,StoSlowing,StoPrice,SignalMode,DivergearrowSize,arrowsUpperGap,arrowsLowerGap,DivArrowOnFirst,drawDivergences,ShowClassicalDivergence,ShowHiddenDivergence,drawIndicatorTrendLines,drawPriceTrendLines,divergenceBullishColor,divergenceBearishColor,drawLinesIdentificator,divergenceAlert,divergenceAlertsMessage,divergenceAlertsSound,divergenceAlertsEmail,divergenceAlertsNotify,divergenceAlertsSoundName,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpGap,arrowsDnGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,_buff,_ind)

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
   IndicatorBuffers(6);
   SetIndexBuffer(0,bullishDivergence); SetIndexStyle(0,DRAW_ARROW,0,DivergearrowSize); SetIndexArrow(0,233);
   SetIndexBuffer(1,bearishDivergence); SetIndexStyle(1,DRAW_ARROW,0,DivergearrowSize); SetIndexArrow(1,234); 
   SetIndexBuffer(2,sto);
   SetIndexBuffer(3,sig);
   SetIndexBuffer(4,trend);
   SetIndexBuffer(5,count);
   
      indicatorFileName = WindowExpertName();
      TimeFrame         = fmax(TimeFrame,_Period); 
      labelNames    = "Stochastic_DivergenceLine "+drawLinesIdentificator+":";
      indicatorName = timeFrameToString(TimeFrame)+" Stochastic ("+StoKPeriod+","+StoDPeriod+","+StoSlowing+")";
      IndicatorShortName(indicatorName);
     
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
   ObjectsDeleteAll(0,arrowsIdentifier+":");
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

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
int i,counted_bars=prev_calculated;
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(rates_total-counted_bars,rates_total-1); count[0]=limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(rates_total-1,_mtfCall(5,0)*TimeFrame/_Period));
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,time[i]);
                  int x = y;
                  if (DivArrowOnFirst)
                        {  if (i<rates_total-1) x = iBarShift(NULL,TimeFrame,time[i+1]);               }
                  else  {  if (i>0)             x = iBarShift(NULL,TimeFrame,time[i-1]); else x = -1;  }
                     sto[i] = _mtfCall(2,y);
                     sig[i] = _mtfCall(3,y);
                     bullishDivergence[i]  = bearishDivergence[i] = EMPTY_VALUE;
                     if (x!=y)
                     {
                       bullishDivergence[i] = _mtfCall(0,y);
                       bearishDivergence[i] = _mtfCall(1,y);
                     }
                 
                     //
                     //
                     //
                     
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,time[i-1]))) continue;
                        #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                        int n,k; datetime itime = iTime(NULL,TimeFrame,y);
                           for(n = 1; (i+n)<rates_total && time[i+n] >= itime; n++) continue;	
                           for(k = 1; k<n && (i+n)<rates_total && (i+k)<rates_total; k++)  
                           {
                              _interpolate(sto);
                              _interpolate(sig);  
                           }                   
              }        
     return(rates_total);
     }
     
     //
     //
     //
      
     for (i=limit; i>=0; i--)
     {
        sto[i] = iStochastic(NULL,0,StoKPeriod,StoDPeriod,StoSlowing,SignalMode,StoPrice,MODE_MAIN  ,i);
        sig[i] = iStochastic(NULL,0,StoKPeriod,StoDPeriod,StoSlowing,SignalMode,StoPrice,MODE_SIGNAL,i);
          trend[i] = trend[i+1];
          if (sto[i]>sig[i]) trend[i]= 1;
          if (sto[i]<sig[i]) trend[i]=-1;
          if (drawDivergences) { CatchBullishDivergence(i); CatchBearishDivergence(i); } 
          
          if (arrowsVisible)
          {
            string lookFor = arrowsIdentifier+":"+(string)Time[i]; if (ObjectFind(0,lookFor)==0) ObjectDelete(0,lookFor);                    
            if (i<(Bars-1) && trend[i] != trend[i+1])
            {
               if (trend[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,arrowsUpSize,false);
               if (trend[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode,arrowsDnSize, true);
            }
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
        if (drawPriceTrendLines)    DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow],    divergenceBullishColor,STYLE_SOLID);
        if (drawIndicatorTrendLines)DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],sto[currentLow],sto[lastLow],divergenceBullishColor,STYLE_SOLID);
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
        if (drawPriceTrendLines)     DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow],     divergenceBullishColor, STYLE_DOT);
        if (drawIndicatorTrendLines) DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],sto[currentLow], sto[lastLow],divergenceBullishColor, STYLE_DOT);
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
        if (drawPriceTrendLines)     DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak],  divergenceBearishColor,STYLE_SOLID);
        if (drawIndicatorTrendLines) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],sto[currentPeak],sto[lastPeak],divergenceBearishColor,STYLE_SOLID);
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
        if (drawPriceTrendLines)     DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak],  divergenceBearishColor, STYLE_DOT);
        if (drawIndicatorTrendLines) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],sto[currentPeak],sto[lastPeak],divergenceBearishColor, STYLE_DOT);
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

void DrawPriceTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
    string label = labelNames+first+"os"+DoubleToStr(t1,0);
      ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, 0, t1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, 0);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
         ObjectSet(label, OBJPROP_WIDTH, 2);
}

//
//
//
//
//

void DrawIndicatorTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
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
         ObjectSet(label, OBJPROP_WIDTH, 2);
}

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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
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

          message =  StringConcatenate(_Symbol," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Stochastic ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(_Symbol+" Stochastic ",message);
             if (alertsSound)   PlaySound(soundFile);
      }
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------

void drawArrow(int i,color theColor,int theCode, int theSize, bool up)
{
   string name = arrowsIdentifier+":"+(string)Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //

      datetime atime = Time[i]; if (arrowsOnNewest) atime += PeriodSeconds(_Period)-1;       
      ObjectCreate(name,OBJ_ARROW,0,atime,0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_WIDTH,theSize);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsDnGap * gap);
}




