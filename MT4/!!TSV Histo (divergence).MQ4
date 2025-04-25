// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=65882

//+------------------------------------------------------------------+
//|                               Copyright ?2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+
//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 10
#property indicator_label1  "TSV Strong up"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrLimeGreen
#property indicator_width1  3

#property indicator_label2  "TSV Weak up"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrLimeGreen

#property indicator_label3  "TSV Strong down"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrPaleVioletRed
#property indicator_width3  3

#property indicator_label4  "TSV weak down"
#property indicator_type4   DRAW_HISTOGRAM
#property indicator_color4  clrPaleVioletRed

#property indicator_label5  "TSV"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDarkGray
#property indicator_width5  3

#property indicator_label6  "TSV Signal"
#property indicator_type6   DRAW_LINE
#property indicator_style6  STYLE_DOT
#property indicator_color6  clrWhite
#property indicator_color7  clrLimeGreen
#property indicator_color8  clrLimeGreen
#property indicator_color9  clrOrangeRed
#property indicator_color10 clrOrangeRed

 
input int            TsvPeriod                      = 14;                 // Tsv period  
enum  enMaTypes
      {
         ma_sma,     // Simple moving average
         ma_ema,     // Exponential moving average
         ma_smma,    // Smoothed MA
         ma_lwma,    // Linear weighted MA
};
input enMaTypes       TsvMaMode                     = ma_sma;             // Tsv Ma type
input int             SigPeriod                     = 10;                 // TSV signal period
input enMaTypes       SigMaMode                     = ma_ema;             // TSV signal ma mode
extern bool            divergenceVisible            = false;              // Should the divergence be visible
extern bool            divergenceOnValuesVisible    = true;               // Divergence lines on macd visible?
extern bool            divergenceOnChartVisible     = true;               // Divergence lines on main chart visible?
extern bool            DivergenceArrowOnFirst       = false;              // Divergence arrows on first mtf bar?
extern int             DivergearrowSize             = 1;                  // Divergence arrows size
extern double          DivergencearrowsUpperGap     = .05;                // Upper Gap between divergence arrows and indicator line
extern double          DivergencearrowsLowerGap     = .05;                // Lower Gap between divergence arrows and indicator line
extern bool            ShowClassicalDivergence      = true;               // Classical divergence visible
extern bool            ShowHiddenDivergence         = true;               // Hidden divergence visible
extern color           divergenceBullishColor       = clrLimeGreen;       // Bullish divergences color
extern color           divergenceBearishColor       = clrOrangeRed;       // Bearish divergences color
extern int             ClassicDivergenceUpArrowCode = 233;                // classical divergence up arrow code
extern int             ClassicDivergenceDnArrowCode = 234;                // classical divergence dn arrow code
extern int             HiddenDivergenceUpArrowCode  = 159;                // hidden divergence up arrow code
extern int             HiddenDivergenceDnArrowCode  = 159;                // hidden divergence dn arrow code
extern string          divergenceUniqueID           = "tsv div";          // Unique ID for divergence lines
 
double huu[],hud[],hdd[],hdu[],val[],sig[],cbulld[],hbulld[],cbeard[],hbeard[],valh[]; 
string shortName;

//------------------------------------------------------------------
//
//------------------------------------------------------------------

int OnInit()
{
   IndicatorBuffers(11);
   SetIndexBuffer(0, huu   ,INDICATOR_DATA); 
   SetIndexBuffer(1, hud   ,INDICATOR_DATA); 
   SetIndexBuffer(2, hdd   ,INDICATOR_DATA);
   SetIndexBuffer(3, hdu   ,INDICATOR_DATA);
   SetIndexBuffer(4, val   ,INDICATOR_DATA);
   SetIndexBuffer(5, sig   ,INDICATOR_DATA);
   SetIndexBuffer(6, cbulld,INDICATOR_DATA);  SetIndexStyle(6, DRAW_ARROW,0,DivergearrowSize); SetIndexArrow(6, ClassicDivergenceUpArrowCode);
   SetIndexBuffer(7, hbulld,INDICATOR_DATA);  SetIndexStyle(7, DRAW_ARROW,0,DivergearrowSize); SetIndexArrow(7, HiddenDivergenceUpArrowCode);
   SetIndexBuffer(8, cbeard,INDICATOR_DATA);  SetIndexStyle(8, DRAW_ARROW,0,DivergearrowSize); SetIndexArrow(8, ClassicDivergenceDnArrowCode);
   SetIndexBuffer(9, hbeard,INDICATOR_DATA);  SetIndexStyle(9, DRAW_ARROW,0,DivergearrowSize); SetIndexArrow(9, HiddenDivergenceDnArrowCode);
   SetIndexBuffer(10,valh);
   
   shortName = divergenceUniqueID+" Time Segmented Volume";
   
   IndicatorSetString(INDICATOR_SHORTNAME,shortName);
return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) 
{
   int tlookForLength = StringLen(divergenceUniqueID);
   for (int i=ObjectsTotal()-1; i>=0; i--) 
   {
       string name = ObjectName(i);  if (StringSubstr(name,0,tlookForLength) == divergenceUniqueID) ObjectDelete(name);
   }
}

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
   int i=rates_total-prev_calculated+1; if (i>=rates_total) i=rates_total-1;
  
   //
   //
   //
   
   for (; i>=0 && !_StopFlag; i--)
   {
       double tem = (close[i]>close[i+1]) ?     tick_volume[i] * (close[i]-close[i+1]) :
                    (close[i]<close[i+1]) ? -1* tick_volume[i] * (close[i+1]-close[i]) : 0;
       val[i]  = iCustomMa(TsvMaMode,tem   ,TsvPeriod,i,rates_total,0)*TsvPeriod;  
       sig[i]  = iCustomMa(SigMaMode,val[i],SigPeriod,i,rates_total,1);  
       valh[i] = (i<rates_total-1) ? (val[i]>0) ? (val[i]>val[i+1]) ? 0 : 1 : (val[i]<val[i+1]) ? 2 : 3 : 0;
       huu[i] = (valh[i] == 0) ? val[i] : EMPTY_VALUE;
       hud[i] = (valh[i] == 1) ? val[i] : EMPTY_VALUE;
       hdd[i] = (valh[i] == 2) ? val[i] : EMPTY_VALUE;
       hdu[i] = (valh[i] == 3) ? val[i] : EMPTY_VALUE;
       if (divergenceVisible)
       {
          CatchBullishDivergence(val,i);
          CatchBearishDivergence(val,i);
       }   
   }
return(rates_total);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------

string getAverageName(int method)
{
      switch(method)
      {
         case ma_ema:    return("EMA");
         case ma_lwma:   return("LWMA");
         case ma_sma:    return("SMA");
         case ma_smma:   return("SMMA");
      }
return("");      
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------

#define _maInstances 2
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances
#define _maWorkBufferx3 3*_maInstances

double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo=0)
{
   r = bars-r-1;
   switch (mode)
   {
      case ma_sma   : return(iSma(price,(int)ceil(length),r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)ceil(length),r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)ceil(length),r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//

double workSma[][_maWorkBufferx1];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo+0] = price;
   double avg = price; int k=1;  for(; k<period && (r-k)>=0; k++) avg += workSma[r-k][instanceNo+0];  
   return(avg/(double)k);
}

//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= _bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo] = price;
   if (r>1 && period>1)
          workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= _bars) ArrayResize(workLwma,_bars);
   
   workLwma[r][instanceNo] = price; if (period<=1) return(price);
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------

void CatchBullishDivergence(double& values[], int i)
{
   i++;
            cbulld[(int)fmin(i,Bars-1)] = EMPTY_VALUE;
            hbulld[(int)fmin(i,Bars-1)] = EMPTY_VALUE;
            ObjectDelete(divergenceUniqueID+"l"+ DoubleToStr(Time[(int)fmin(i,Bars-1)],0));
            ObjectDelete(divergenceUniqueID+"l"+"os" + DoubleToStr(Time[(int)fmin(i,Bars-1)],0));            
   if (!IsIndicatorLow(values,(int)fmin(i,Bars-1))) return;  

   //
   //
   //
   
   int currentLow = i;
   int lastLow    = GetIndicatorLastLow(values,i+1);
      if (currentLow>=0 && currentLow<Bars && lastLow>=0) 
      if (values[currentLow] > values[lastLow] && Low[currentLow] < Low[lastLow])
      {
        if (ShowClassicalDivergence)
        {
          cbulld[currentLow] = values[currentLow] - DivergencearrowsLowerGap*iATR(NULL,0,10,i);
          if(divergenceOnChartVisible)  DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow],          divergenceBullishColor,STYLE_SOLID);
          if(divergenceOnValuesVisible) DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],values[currentLow],values[lastLow],divergenceBullishColor,STYLE_SOLID);
        }
      }
      
      if (currentLow>=0 && currentLow<Bars && lastLow>=0) 
      if (values[currentLow] < values[lastLow] && Low[currentLow] > Low[lastLow])
      {
        if (ShowHiddenDivergence)
        {
          hbulld[currentLow] = values[currentLow] - DivergencearrowsLowerGap*iATR(NULL,0,10,i);
          if(divergenceOnChartVisible)  DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow],           divergenceBullishColor, STYLE_DOT);
          if(divergenceOnValuesVisible) DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],values[currentLow],values[lastLow], divergenceBullishColor, STYLE_DOT);
        }
      }
}

//
//
//

void CatchBearishDivergence(double& values[], int i)
{
   i++; 
            cbeard[(int)fmin(i,Bars-1)] = EMPTY_VALUE;
            hbeard[(int)fmin(i,Bars-1)] = EMPTY_VALUE;
            ObjectDelete(divergenceUniqueID+"h"+DoubleToStr(Time[(int)fmin(i,Bars-1)],0));
            ObjectDelete(divergenceUniqueID+"h"+"os" + DoubleToStr(Time[(int)fmin(i,Bars-1)],0));            
   if (IsIndicatorPeak(values,(int)fmin(i,Bars-1)) == false) return;

   //
   //
   //
      
   int currentPeak = i;
   int lastPeak = GetIndicatorLastPeak(values,i+1);
      if (currentPeak>=0 && currentPeak<Bars && lastPeak>=0) 
      if (values[currentPeak] < values[lastPeak] && High[currentPeak]>High[lastPeak])
      {
        if (ShowClassicalDivergence)
        {
          cbeard[currentPeak] = values[currentPeak] + DivergencearrowsUpperGap*iATR(NULL,0,10,i);
          if (divergenceOnChartVisible)  DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak],        divergenceBearishColor,STYLE_SOLID);
          if (divergenceOnValuesVisible) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],values[currentPeak],values[lastPeak],divergenceBearishColor,STYLE_SOLID);
        }
      }
      if (currentPeak>=0 && currentPeak<Bars && lastPeak>=0) 
      if (values[currentPeak] > values[lastPeak] && High[currentPeak] < High[lastPeak])
      {
        if (ShowHiddenDivergence)
        {
          hbeard[currentPeak] = values[currentPeak] + DivergencearrowsUpperGap*iATR(NULL,0,10,i);
          if (divergenceOnChartVisible)  DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak],         divergenceBearishColor, STYLE_DOT);
          if (divergenceOnValuesVisible) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],values[currentPeak],values[lastPeak], divergenceBearishColor, STYLE_DOT);
        }
      }
}

//
//
//

bool IsIndicatorPeak(double& values[], int i) { return(values[i] >= values[(int)fmin(i+1,Bars-1)] && values[i] > values[(int)fmin(i+2,Bars-1)] && values[i] > values[(int)fmax(i-1,0)]); }
bool IsIndicatorLow( double& values[], int i) { return(values[i] <= values[(int)fmin(i+1,Bars-1)] && values[i] < values[(int)fmin(i+2,Bars-1)] && values[i] < values[(int)fmax(i-1,0)]); }

int GetIndicatorLastPeak(double& values[], int shift)
{
   for(int i = shift+5; i<Bars && (i+2)<(Bars-1) && (i-2)>=0; i++)
         if (values[i] >= values[i+1] && values[i] > values[i+2] && values[i] >= values[i-1] && values[i] > values[i-2]) return(i);
   return(-1);
}
int GetIndicatorLastLow(double& values[], int shift)
{
   for(int i = shift+5; i<Bars && (i+2)<(Bars-1) && (i-2)>=0; i++)
         if (values[i] <= values[i+1] && values[i] < values[i+2] && values[i] <= values[i-1] && values[i] < values[i-2]) return(i);
   return(-1);
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------

void DrawPriceTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
   string   label = divergenceUniqueID+first+"os"+DoubleToStr(t1,0);
   ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, 0, t1+Period()*60-1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, false);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
}
void DrawIndicatorTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
   int indicatorWindow = WindowFind(shortName);
   if (indicatorWindow < 0) return;
   string label = divergenceUniqueID+first+DoubleToStr(t1,0);
   ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, indicatorWindow, t1+Period()*60-1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, false);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
}






