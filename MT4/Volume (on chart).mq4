//------------------------------------------------------------------
#property copyright   "copyright© mladen"
#property description "Volume on chart"
#property description "made by mladen"
#property link        "mladenfx@gmail.com"
//------------------------------------------------------------------

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrOrange
#property indicator_color3  clrGray
#property indicator_color4  clrGray
#property indicator_color5  clrYellowGreen    // Color for the average line
#property indicator_color6  clrAntiqueWhite    // Color for the average line
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  2
#property strict

//
//
//
//
//

extern double  Percent      = 20;               // Percent to occupy on the main chart
extern double  PercentShift = 0;                // Percent to vertically shift on the main chart
extern string  UniqueID     = "VolumeOnChart1"; // Unique ID
extern color   NameColor    = clrGray;          // Name color
extern int     NameXPos     = 20;               // Name display X position
extern int     NameYPos     = 20;               // Name display Y position
extern int     MA_Period    = 14;               // Moving average period

//
//
//
//
//

double valuehu[], valuehnu[], valuehnd[], valuehd[], vol[], volMA[];
string shortName;
#include <ChartObjects\ChartObjectsTxtControls.mqh> 
CChartObjectLabel  label;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
    IndicatorBuffers(6);
    SetIndexBuffer(0, valuehu);  SetIndexStyle(0, DRAW_HISTOGRAM);
    SetIndexBuffer(1, valuehd);  SetIndexStyle(1, DRAW_HISTOGRAM);
    SetIndexBuffer(2, valuehnu); SetIndexStyle(2, DRAW_HISTOGRAM);
    SetIndexBuffer(3, valuehnd); SetIndexStyle(3, DRAW_HISTOGRAM);
    SetIndexBuffer(4, vol); 
    SetIndexBuffer(5, volMA);    SetIndexStyle(5, DRAW_LINE, 0,2 );   // Set style for average line
         
    //
    //
    //
    //
    //
            
    shortName = "Volumes on chart";
    IndicatorShortName(shortName);
    label.Create(0, UniqueID + ":name", 0, NameXPos, NameYPos);
    label.Color(NameColor);
    label.Description(shortName);
    label.FontSize(7); 
    label.Font("Verdana"); 
    label.Corner(CORNER_RIGHT_LOWER);
    label.Anchor(ANCHOR_RIGHT);
    for (int i = 0; i < 2; i++) SetIndexLabel(i, shortName);
    return (0);
}

int deinit() { ObjectDelete(UniqueID + ":name"); return (0); }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int start()
{
    int counted_bars = IndicatorCounted();
    if (counted_bars < 0) return (-1);
    if (counted_bars > 0) counted_bars--;
    
    int bars = (int)MathMin(ChartGetInteger(0, CHART_WIDTH_IN_BARS), Bars - 2);
    int limit = MathMax(MathMin(Bars - counted_bars, Bars - 1), bars);
    double chartMax = ChartGetDouble(0, CHART_PRICE_MAX);
    double chartMin = ChartGetDouble(0, CHART_PRICE_MIN);
    double mod = Percent * (chartMax - chartMin) / 100.0;
      
    //
    //
    //
    //
    //

    for (int i = limit; i >= 0; i--)
    {
        vol[i] = (double)Volume[i];
        valuehu[i] = (Close[i] > Open[i]) ? (double)Volume[i] : 0;
        valuehd[i] = (Close[i] < Open[i]) ? (double)Volume[i] : 0;
        valuehnu[i] = (Close[i] == Open[i]) ? (double)Volume[i] : 0;
        valuehnd[i] = 0;
    }
    
    // Calculate the moving average of volume
    for (int i = limit; i >= 0; i--)
    {
        if (i >= MA_Period - 1) {
            double sum = 0;
            for (int j = 0; j < MA_Period; j++) {
                sum += vol[i - j];
            }
            volMA[i] = sum / MA_Period;
        } else {
            volMA[i] = 0;
        }
    }
    
    label.Description(shortName + " : " + DoubleToStr(Volume[0], 0));
      
    //
    //
    //
    //
    //
    
    double min = 0;
    double max = vol[ArrayMaximum(vol, bars, 0)];
    double rng = max - min; 
    chartMin = chartMin + PercentShift * (chartMax - chartMin) / 100.0;
    
    for (int i = bars; i >= 0; i--)
    {
        valuehu[i] = chartMin + (valuehu[i] - min) / rng * mod;
        valuehd[i] = chartMin + (valuehd[i] - min) / rng * mod;
        valuehnu[i] = chartMin + (valuehnu[i] - min) / rng * mod;
        valuehnd[i] = chartMin;
        volMA[i] = chartMin + (volMA[i] - min) / rng * mod;  // Adjust volMA for chart scaling
    }
    
    for (int i = 0; i < 2; i++) SetIndexDrawBegin(i, Bars - bars + 1);
    return (0);
}
