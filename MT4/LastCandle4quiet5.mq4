#property strict

// Define indicator properties
#property indicator_chart_window

// Declare a global variable to store the time of the last candle
datetime lastCandleTime;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialize the last candle time
    lastCandleTime = Time[0];

    // Draw initial line
    ObjectCreate(0, "LastCandleLine", OBJ_VLINE, 0, Time[0], 0);
    ObjectSetInteger(0, "LastCandleLine", OBJPROP_COLOR, clrRed); // Set line color to red (you can change it)

    // Return initialization result
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Delete the vertical line when the indicator is removed
    ObjectDelete(0, "LastCandleLine");
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    // Check if a new candle has formed
    if (Time[0] != lastCandleTime)
    {
        // Delete the old line
        ObjectDelete(0, "LastCandleLine");

        // Draw a vertical line on the last closed candle
        ObjectCreate(0, "LastCandleLine", OBJ_VLINE, 0, Time[0], 0);
        ObjectSetInteger(0, "LastCandleLine", OBJPROP_COLOR, clrDarkGreen); // Set line color to red (you can change it)

        // Update the last candle time
        lastCandleTime = Time[0];
    }

    // Return the number of rates
    return(rates_total);
}
//+------------------------------------------------------------------+
