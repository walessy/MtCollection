//+------------------------------------------------------------------+
//|                                                   DebugFirstBar.mq4 |
//+------------------------------------------------------------------+
#property copyright "YourName"
#property link      "YourWebsite"
#property version   "1.01"
#property indicator_chart_window

// Input settings
input color BullishColor = Blue;  // Color for bullish bar
input color BearishColor = Red;  // Color for bearish bar

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("DebugFirstBar initialized.");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                             |
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
    // Debug: Confirm rates being processed
    Print("rates_total = ", rates_total, ", prev_calculated = ", prev_calculated);

    // Determine the starting point
    int start = prev_calculated;
    if (prev_calculated == 0) // First run, process all historical data
    {
        start = 0;
        Print("Processing all historical data...");
    }
    else
    {
        Print("Processing new bars only...");
    }

    // Process bars from the determined start point
    for (int i = start; i < rates_total; i++)
    {
        int minute = TimeMinute(time[i]);
        int hour = TimeHour(time[i]);

        // Debug: Print details of each bar
        Print("Processing bar: time = ", TimeToString(time[i]), ", open = ", open[i], ", close = ", close[i]);

        // Identify the first 5-minute bar of each hour
        if (minute == 5)
        {
            string lineName = "Line_" + IntegerToString(hour) + "_" + TimeToString(time[i], TIME_MINUTES);

            if (!ObjectFind(0, lineName))
            {
                // Draw a vertical line for the first 5-minute bar
                bool created = ObjectCreate(0, lineName, OBJ_VLINE, 0, time[i]);
                if (created)
                {
                    ObjectSetInteger(0, lineName, OBJPROP_COLOR, (close[i] > open[i]) ? BullishColor : BearishColor);
                    ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 1);

                    // Debug: Confirm successful creation
                    Print("Line created: ", lineName, " at ", TimeToString(time[i]));
                }
                else
                {
                    // Debug: Log failed creation
                    Print("Failed to create line: ", lineName);
                }
            }
        }
    }

    // Return the total number of bars processed
    return(rates_total);
}
