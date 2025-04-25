//+------------------------------------------------------------------+
//|                                       First5MinBarFixed.mq4      |
//+------------------------------------------------------------------+
#property copyright "YourName"
#property link      "YourWebsite"
#property version   "1.04"
#property indicator_chart_window

input color BullishColor = Blue;  // Color for bullish bar
input color BearishColor = Red;  // Color for bearish bar

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
    Print("rates_total = ", rates_total, ", prev_calculated = ", prev_calculated);

    int start = 0; // Default to processing all bars
    if (prev_calculated > 0) // On subsequent updates
    {
        start = prev_calculated - 1; // Start from the last unprocessed bar
    }

    for (int i = start; i < rates_total; i++)
    {
        datetime barTime = time[i];
        int minute = TimeMinute(barTime);
        int hour = TimeHour(barTime);

        if (minute == 5)
        {
            string lineName = "Line_" + IntegerToString(i) + "_" + TimeToString(barTime, TIME_MINUTES);

            if (!ObjectFind(0, lineName))
            {
                bool created = ObjectCreate(0, lineName, OBJ_VLINE, 0, barTime);
                if (created)
                {
                    ObjectSetInteger(0, lineName, OBJPROP_COLOR, (close[i] > open[i]) ? BullishColor : BearishColor);
                    ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 2);
                    Print("Line created: ", lineName, " at ", TimeToString(barTime));
                }
                else
                {
                    Print("Failed to create line: ", lineName);
                }
            }
        }
    }

    // Return the total number of bars processed
    return rates_total;
}
