//+------------------------------------------------------------------+
//|                                        Stochastic Divergence.mq4 |
//|                     edited from     FX5_MACD_Divergence_V1.1.mq4 |
//|                                                              FX5 |
//|Editor: byens (byens@web.de)                        hazem@uk2.net |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2007, FX5"
#property link      "hazem@uk2.net"
//----
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 CornflowerBlue
#property indicator_color2 Red
#property indicator_color3 White
#property indicator_color4 White
#property indicator_style4 STYLE_DOT
#property indicator_level1 80
#property indicator_level2 50
#property indicator_level3 20
#property indicator_levelcolor DimGray
//----
#define arrowsDisplacement 0.0001

//---- input parameters
extern int    KPeriod                 = 5;
extern int    DPeriod                 = 3;
extern int    Slowing                 = 3;
extern bool   drawIndicatorTrendLines = true;
extern bool   drawPriceTrendLines     = true;
extern bool   displayAlert            = false;
extern bool   emailAlert              = false;
extern bool   drawBullishBearish      = true;   // New variable to control drawing vertical lines
extern color  ColorBearishTrendLines  = Gold;
extern color  ColorBullishTrendLines  = Gold;
extern int    TimeFrame               = 0;

//---- buffers
double bullishDivergence[];
double bearishDivergence[];
double macd[];
double signal[];
//----
static datetime lastAlertTime;
static string   indicatorName;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
   //---- indicators
   SetIndexStyle(0, DRAW_ARROW, 0, 2);
   SetIndexStyle(1, DRAW_ARROW, 0, 2);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexStyle(3, DRAW_LINE);
   //----   
   SetIndexBuffer(0, bullishDivergence);
   SetIndexBuffer(1, bearishDivergence);
   SetIndexBuffer(2, macd);
   SetIndexBuffer(3, signal);
   //----   
   SetIndexArrow(0, 233);
   SetIndexArrow(1, 234);
   //----
   if (TimeFrame == 0) {
      TimeFrame = Period();
   }
   indicatorName = Symbol() + " (" + GetTimeFrameStr() + "):  Stochastic_Divergence(" + KPeriod + ", " + 
                                 DPeriod + ", " + Slowing + ")";
   SetIndexDrawBegin(3, Slowing);
   IndicatorDigits(Digits + 2);
   IndicatorShortName(indicatorName);

   return (0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
   int countedBars = IndicatorCounted();
   if (countedBars < 0)
       countedBars = 0;
   CalculateIndicator(countedBars);
   return (0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void CalculateIndicator(int countedBars) {
   for (int i = Bars - countedBars; i >= 0; i--) {
       CalculateMACD(i);
       CatchBullishDivergence(i + 2);
       CatchBearishDivergence(i + 2);
       // Check for bullish/bearish crossovers and draw vertical lines
       if (drawBullishBearish) {
           CheckForCrossovers(i);
       }
   }
}

//+------------------------------------------------------------------+
//| Detect Bullish/Bearish Crossovers and Draw Vertical Lines         |
//+------------------------------------------------------------------+
void CheckForCrossovers(int i) {
   // Bullish Crossover (Signal line crosses above MACD line)
   if (signal[i] > macd[i] && signal[i - 1] <= macd[i - 1]) {
       DrawVerticalLine(Time[i], ColorBullishTrendLines, "Bullish Line");
   }

   // Bearish Crossover (Signal line crosses below MACD line)
   if (signal[i] < macd[i] && signal[i - 1] >= macd[i - 1]) {
       DrawVerticalLine(Time[i], ColorBearishTrendLines, "Bearish Line");
   }
}

//+------------------------------------------------------------------+
//| Draw Vertical Line on Chart                                       |
//+------------------------------------------------------------------+
void DrawVerticalLine(datetime time, color lineColor, string lineLabelPrefix) {
   string label = lineLabelPrefix + "_" + TimeToString(time, TIME_DATE|TIME_MINUTES);
   if (ObjectFind(label) < 0) {
       ObjectCreate(label, OBJ_VLINE, 0, time, 0);
       ObjectSet(label, OBJPROP_COLOR, lineColor);
       ObjectSet(label, OBJPROP_STYLE, STYLE_DASH);
       ObjectSet(label, OBJPROP_WIDTH, 2);
   }
}
