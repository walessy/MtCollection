//+------------------------------------------------------------------+
//|                                       First5MinBarFixed.mq5      |
//+------------------------------------------------------------------+
#property copyright "YourName"
#property link      "YourWebsite"
#property version   "1.04"
#property indicator_chart_window

enum MY_TIMEFRAME {
    M1      = PERIOD_M1,           // One minute
    M5      = PERIOD_M5,           // Five minute
    M15     = PERIOD_M15,          // Fifteen minute
    M30     = PERIOD_M30,          // Thirty minute
    H1      = PERIOD_H1,           // One hour
    H4      = PERIOD_H4,           // Four hour
    CURRENT = PERIOD_CURRENT       // Use current timeframe
};

input color BullishColor = clrSkyBlue;    // Color for bullish bar
input color BearishColor = clrPink;      // Color for bearish bar
input int IntervalMinutes = 60;          // Interval to detect the first 5-minute candle
input MY_TIMEFRAME inp_timeframe = CURRENT; // Select the chart timeframe
input string SignalName = "HourFirst5MinCand";

datetime BullSignal[];
datetime BearSignal[];

double DummyBuffer[]; // Dummy buffer for indicator compatibility

int OnInit()
{
    ArraySetAsSeries(BullSignal, false);
    ArraySetAsSeries(BearSignal, false);

    ChartSetSymbolPeriod(0, NULL, (ENUM_TIMEFRAMES)inp_timeframe);
    SetIndexBuffer(0, DummyBuffer);
    IndicatorSetString(INDICATOR_SHORTNAME, "First5MinBar");
    EventSetTimer(1); // Set timer to check every second
    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
    for (int iObj = ObjectsTotal(0) - 1; iObj >= 0; iObj--)
    {
        string objName = ObjectName(0, iObj);
        if (StringFind(objName, SignalName) == 0)
            ObjectDelete(0, objName);
    }
    EventKillTimer(); // Stop the timer
}

void OnTimer()
{
    datetime lastBarTime = iTime(NULL, (ENUM_TIMEFRAMES)inp_timeframe, 0);
    static datetime previousBarTime = 0;

    // Check if a new bar has started
    if (lastBarTime != previousBarTime)
    {
        MqlDateTime dt;
        TimeToStruct(lastBarTime, dt);
        int minute = dt.min;
        int hour = dt.hour;

        if ((hour * 60 + minute) % IntervalMinutes == 0)
        {
            if (iClose(NULL, (ENUM_TIMEFRAMES)inp_timeframe, 0) > 
                iOpen(NULL, (ENUM_TIMEFRAMES)inp_timeframe, 0))
                DoBull(lastBarTime);
            else
                DoBear(lastBarTime);
        }

        previousBarTime = lastBarTime;
    }
}

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
    int start = (prev_calculated > 0) ? prev_calculated - 1 : 0;

    for (int i = start; i < rates_total; i++)
    {
        datetime barTime = time[i];
        MqlDateTime dt;
        TimeToStruct(barTime, dt);
        int minute = dt.min;
        int hour = dt.hour;

        if ((hour * 60 + minute) % IntervalMinutes == 0)
        {
            if (close[i] > open[i])
                DoBull(barTime);
            else
                DoBear(barTime);
        }
        DummyBuffer[i] = 0.0; // Fill dummy buffer
    }
    return rates_total;
}

bool DoBear(datetime time)
{
    string lineName = StringFormat("%s_Bear_%s", SignalName, TimeToString(time, TIME_MINUTES));
    if (!ObjectCreate(0, lineName, OBJ_VLINE, 0, time, 0))
        return false;

    ObjectSetInteger(0, lineName, OBJPROP_COLOR, BearishColor);
    ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 1);
    ChartRedraw();
    return true;
}

bool DoBull(datetime time)
{
    string lineName = StringFormat("%s_Bull_%s", SignalName, TimeToString(time, TIME_MINUTES));
    if (!ObjectCreate(0, lineName, OBJ_VLINE, 0, time, 0))
        return false;

    ObjectSetInteger(0, lineName, OBJPROP_COLOR, BullishColor);
    ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 1);
    ChartRedraw();
    return true;
}
