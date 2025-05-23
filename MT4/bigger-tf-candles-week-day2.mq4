#property copyright ""
#property link      ""
#property version   "1.00"
#property strict
//load of cobblers from chatgpt
//--- input parameters
input ENUM_TIMEFRAMES TimeFrame = PERIOD_D1;  // Timeframe for candles
input bool DrawMonday   = true;              // Draw Monday candles
input bool DrawTuesday  = true;              // Draw Tuesday candles
input bool DrawWednesday= true;              // Draw Wednesday candles
input bool DrawThursday = true;              // Draw Thursday candles
input bool DrawFriday   = true;              // Draw Friday candles
input color UpCandleColor   = clrBlue;       // Color for up candles
input color DownCandleColor = clrRed;        // Color for down candles
input color NeutralCandleColor = clrGray;    // Color for neutral candles
input int LineWidth = 1;                     // Line width
input ENUM_LINE_STYLE LineStyle = STYLE_SOLID; // Line style
input bool FillCandles = true;               // Fill candles with color
input int LeftOfLeadingEdge = 50;            // Number of candles left of the leading edge to draw
input int PointsCandleLength = 50;           // Candle length threshold in points

//--- global variables
string PREF = "HTFCandle_";                  // Prefix for object names

//--- helper functions
int CustomPeriodSeconds(ENUM_TIMEFRAMES tf)
{
    switch (tf)
    {
        case PERIOD_M1:   return 60;
        case PERIOD_M5:   return 300;
        case PERIOD_M15:  return 900;
        case PERIOD_M30:  return 1800;
        case PERIOD_H1:   return 3600;
        case PERIOD_H4:   return 14400;
        case PERIOD_D1:   return 86400;
        case PERIOD_W1:   return 604800;
        case PERIOD_MN1:  return 2592000;
        default:          return 0;
    }
}

//--- main functions
int OnInit()
{
    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    for (int i = ObjectsTotal() - 1; i >= 0; i--)
    {
        string name = ObjectName(i);
        if (StringSubstr(name, 0, StringLen(PREF)) == PREF)
            ObjectDelete(name);
    }
}

int OnCalculate(const int rates_total, const int prev_calculated, 
                const datetime &time[], const double &open[], 
                const double &high[], const double &low[], 
                const double &close[], const long &tick_volume[], 
                const long &volume[], const int &spread[])
{
    // Ensure the time array is handled as a series
    ArraySetAsSeries(time, true);

    int totalBars = iBars(NULL, TimeFrame);
    int startBar = MathMax(0, totalBars - LeftOfLeadingEdge);

    for (int i = startBar; i < totalBars; i++)
    {
        datetime htTime = iTime(NULL, TimeFrame, i);
        if (htTime == 0) continue;

        int dayOfWeek = TimeDayOfWeek(htTime);
        if ((dayOfWeek == 1 && !DrawMonday) ||
            (dayOfWeek == 2 && !DrawTuesday) ||
            (dayOfWeek == 3 && !DrawWednesday) ||
            (dayOfWeek == 4 && !DrawThursday) ||
            (dayOfWeek == 5 && !DrawFriday))
            continue;

        double htOpen  = iOpen(NULL, TimeFrame, i);
        double htHigh  = iHigh(NULL, TimeFrame, i);
        double htLow   = iLow(NULL, TimeFrame, i);
        double htClose = iClose(NULL, TimeFrame, i);

        double candleLength = (htHigh - htLow) / Point;
        if (candleLength < PointsCandleLength) continue;

        color candleColor = (htClose > htOpen) ? UpCandleColor : (htClose < htOpen) ? DownCandleColor : NeutralCandleColor;

        string candleBody = PREF + IntegerToString(i) + "_Body";
        string highLine   = PREF + IntegerToString(i) + "_High";
        string lowLine    = PREF + IntegerToString(i) + "_Low";

        if (FillCandles)
        {
            if (!ObjectCreate(0, candleBody, OBJ_RECTANGLE, 0, htTime, htOpen, htTime + CustomPeriodSeconds(TimeFrame) - 1, htClose))
                Print("Failed to create body for candle ", i);
            ObjectSetInteger(0, candleBody, OBJPROP_COLOR, candleColor);
            ObjectSetInteger(0, candleBody, OBJPROP_STYLE, LineStyle);
            ObjectSetInteger(0, candleBody, OBJPROP_WIDTH, LineWidth);
        }

        if (!ObjectCreate(0, highLine, OBJ_TREND, 0, htTime, htHigh, htTime + CustomPeriodSeconds(TimeFrame) - 1, htHigh))
            Print("Failed to create high line for candle ", i);
        ObjectSetInteger(0, highLine, OBJPROP_COLOR, candleColor);
        ObjectSetInteger(0, highLine, OBJPROP_STYLE, LineStyle);
        ObjectSetInteger(0, highLine, OBJPROP_WIDTH, LineWidth);

        if (!ObjectCreate(0, lowLine, OBJ_TREND, 0, htTime, htLow, htTime + CustomPeriodSeconds(TimeFrame) - 1, htLow))
            Print("Failed to create low line for candle ", i);
        ObjectSetInteger(0, lowLine, OBJPROP_COLOR, candleColor);
        ObjectSetInteger(0, lowLine, OBJPROP_STYLE, LineStyle);
        ObjectSetInteger(0, lowLine, OBJPROP_WIDTH, LineWidth);
    }

    return rates_total;
}
