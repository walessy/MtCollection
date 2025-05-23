//------------------------------------------------------------------
#property copyright   "copyright© mladen"
#property description "Volume on chart"
#property description "made by mladen"
#property link        "mladenfx@gmail.com"
//------------------------------------------------------------------

#property indicator_chart_window
#property indicator_buffers 8  // 8 buffers for the histogram and both average lines
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrOrange
#property indicator_color3  clrGray
#property indicator_color4  clrGray
#property indicator_color5  clrYellowGreen    // Color for short-term average line
#property indicator_color6  clrAntiqueWhite   // Color for long-term average line
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  2                 // Set the width for short-term average line
#property indicator_width6  2                 // Set the width for long-term average line
#property strict

extern double  Percent        = 20;               // Percent to occupy on the main chart
extern double  PercentShift   = 0;                // Percent to vertically shift on the main chart
extern string  UniqueID       = "VolumeOnChart1"; // Unique ID
extern color   NameColor      = clrGray;          // Name color
extern int     NameXPos       = 20;               // Name display X position
extern int     NameYPos       = 20;               // Name display Y position
extern int     ShortTerm_Period = 50;             // Short-term period for average line
extern int     LongTerm_Period  = 200;            // Long-term period for average line

double valuehu[], valuehnu[], valuehnd[], valuehd[], vol[], shortTermAvg[], longTermAvg[];
string shortName;

#include <ChartObjects\ChartObjectsTxtControls.mqh>
CChartObjectLabel  label;

//------------------------------------------------------------------

int init()
{
    IndicatorBuffers(8);
    SetIndexBuffer(0, valuehu);  SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 2);  // Set the histogram style and width
    SetIndexBuffer(1, valuehd);  SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 2);  // Bearish histogram
    SetIndexBuffer(2, valuehnu); SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 1);  // Neutral histogram
    SetIndexBuffer(3, valuehnd); SetIndexStyle(3, DRAW_HISTOGRAM, STYLE_SOLID, 1);  // Neutral down
    SetIndexBuffer(4, vol);      // Raw volume buffer
    SetIndexBuffer(5, shortTermAvg); SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 2);   // Short-term average line
    SetIndexBuffer(6, longTermAvg);  SetIndexStyle(6, DRAW_LINE, STYLE_SOLID, 2);   // Long-term average line

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

int deinit() 
{
    ObjectDelete(UniqueID + ":name");
    return (0);
}

//------------------------------------------------------------------

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
      
    // Initialize buffers for volumes
    for (int i = limit; i >= 0; i--)
    {
        vol[i] = (double)Volume[i];
        valuehu[i] = (Close[i] > Open[i]) ? (double)Volume[i] : 0;    // Up volume
        valuehd[i] = (Close[i] < Open[i]) ? (double)Volume[i] : 0;    // Down volume
        valuehnu[i] = (Close[i] == Open[i]) ? (double)Volume[i] : 0;  // Neutral volume
        valuehnd[i] = 0;
    }
    
    // Calculate the short-term moving average of volume
    for (int i = limit; i >= 0; i--)
    {
        if (i >= ShortTerm_Period - 1) {
            double sum = 0;
            for (int j = 0; j < ShortTerm_Period; j++) {
                sum += vol[i - j];
            }
            shortTermAvg[i] = sum / ShortTerm_Period;
        } else {
            shortTermAvg[i] = 0;
        }
    }
    
    // Calculate the long-term moving average of volume
    for (int i = limit; i >= 0; i--)
    {
        if (i >= LongTerm_Period - 1) {
            double sum = 0;
            for (int j = 0; j < LongTerm_Period; j++) {
                sum += vol[i - j];
            }
            longTermAvg[i] = sum / LongTerm_Period;
        } else {
            longTermAvg[i] = 0;
        }
    }
    
    // Label for current volume
    label.Description(shortName + " : " + DoubleToStr(Volume[0], 0));
    
    // Rescale histogram and moving average lines to fit the chart
    double min = 0;
    double max = vol[ArrayMaximum(vol, bars, 0)];
    double rng = max - min; 
    chartMin = chartMin + PercentShift * (chartMax - chartMin) / 100.0;

    for (int i = bars; i >= 0; i--)
    {
        valuehu[i] = chartMin + (valuehu[i] - min) / rng * mod;        // Up volume adjustment
        valuehd[i] = chartMin + (valuehd[i] - min) / rng * mod;        // Down volume adjustment
        valuehnu[i] = chartMin + (valuehnu[i] - min) / rng * mod;      // Neutral volume adjustment
        valuehnd[i] = chartMin;                                        // Zero base for neutral down
        shortTermAvg[i] = chartMin + (shortTermAvg[i] - min) / rng * mod;  // Short-term average line adjustment
        longTermAvg[i] = chartMin + (longTermAvg[i] - min) / rng * mod;    // Long-term average line adjustment
    }

    for (int i = 0; i < 2; i++) SetIndexDrawBegin(i, Bars - bars + 1);
    
    return (0);
}
