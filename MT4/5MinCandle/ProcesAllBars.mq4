//+------------------------------------------------------------------+
//|                                       First5MinBarFixed.mq4      |
//+------------------------------------------------------------------+
#property copyright "YourName"
#property link      "YourWebsite"
#property version   "1.04"
#property indicator_chart_window

enum MY_TIMEFRAME {
    M1      =PERIOD_M1,            // One minute
    M5      =PERIOD_M5,            // Five minute
    M15     =PERIOD_M15,           // Fifteen minute
    M30     =PERIOD_M30,           // Thirty minute
    H1      =PERIOD_H1,            // One hour
    H4      =PERIOD_H4,            // Four hour
    CURRENT =PERIOD_CURRENT        // Use current timeframe, or double-click to change
}; 

input color BullishColor = clrSkyBlue;  // Color for bullish bar
input color BearishColor = clrPink;  // Color for bearish bar
input  int IntervalMinutes = 60;   // Interval to detect the first 5-minute candle
input MY_TIMEFRAME inp_timeframe = CURRENT; //Select the chart timeframe
input string SignalName="HourFirst5MinCand";
datetime BullSignal[];
datetime BearSignal[];

int OnInit()
{
    // g_timeframe = myTimeFrameToMqlTimeFrame(inp_timeframe);
    ArraySetAsSeries(BullSignal,false);
    ArraySetAsSeries(BearSignal,false);
    
    ChartSetSymbolPeriod(0, NULL, (ENUM_TIMEFRAMES) inp_timeframe);
    EventSetTimer(1); // Set timer to check every second
    return INIT_SUCCEEDED;
}

void OnTimer()
{
    datetime lastBarTime = iTime(NULL, (ENUM_TIMEFRAMES)inp_timeframe, 0);
    static datetime previousBarTime = 0;

    // Check if a new bar has started
    if (lastBarTime != previousBarTime)
    {
        int i = 0; // Index for the current bar
        int minute = TimeMinute(lastBarTime);
        int hour = TimeHour(lastBarTime);

        if ((hour * 60 + minute) % IntervalMinutes == 0)
        {
            if (iClose(NULL, (ENUM_TIMEFRAMES)inp_timeframe, 0) >
                iOpen(NULL, (ENUM_TIMEFRAMES)inp_timeframe, 0))
                DoBull(i);
            else
                DoBear(i);
        }

        previousBarTime = lastBarTime;
    }
}
int deinit()
  {
  
         for(int iObj=ObjectsTotal()-1; iObj >= 0; iObj--){
        string on = ObjectName(iObj);
        if (StringFind(on, SignalName) == 0)  ObjectDelete(on);
        }   
         EventKillTimer(); // Stop the timer
        return(0);
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
     

    int Count5MiinCan;
    datetime FiveMinBars[];
   
     int start = (prev_calculated > 0) ? prev_calculated - 1 : 0;
     // Default to processing all bars
    
    if (prev_calculated > 0) // On subsequent updates
    {
        start = prev_calculated - 1; // Start from the last unprocessed bar
    }

    for (int i = start; i < rates_total; i++)
    {
        
        datetime barTime = time[i];
        int minute = TimeMinute(barTime);
        int hour = TimeHour(barTime);

        //if (minute == 5)
        if ((hour * 60 + minute) % IntervalMinutes == 0)
        { 
            Count5MiinCan++;
            (close[i] > open[i]) ? DoBull(i): DoBear(i);;
            //FiveMinBars[Count5MiinCan]=time[i];
            //ObjectCreate(0, "LastCandleLine", OBJ_VLINE, 0,time[i], 0);
        }
        

    }
    
         //Print(Count5MiinCan + " 5min candlesfound");
         // Return the total number of bars processed
         //Print (StringConcatenate(ArraySize(BullSignal)," bull signals:","  ", ArraySize(BearSignal), " bear signals"));
       
    return rates_total;
}

bool DoBear(int i){
   string lineName = StringConcatenate(SignalName,IntegerToString(i), "_" ,TimeToString(Time[i], TIME_MINUTES));

   ArrayResize(BearSignal,ArraySize(BearSignal)+1);
   ObjectCreate(0, lineName, OBJ_VLINE, 0,Time[i], 0);
   ObjectSetInteger(0, lineName, OBJPROP_COLOR, BearishColor); // Set line color to red (you can change it)
   ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 3);
   ChartRedraw(); // Force chart refresh
   return true;
}

bool DoBull(int i){
   string lineName = StringConcatenate(SignalName,IntegerToString(i), "_" ,TimeToString(Time[i], TIME_MINUTES));
   
   ArrayResize(BullSignal,ArraySize(BullSignal)+1);
   ObjectCreate(0, lineName, OBJ_VLINE, 0,Time[i], 0);
   ObjectSetInteger(0, lineName, OBJPROP_COLOR, BullishColor); // Set line color to red (you can change it)
   ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 3);
   ChartRedraw(); // Force chart refresh

   return true;
}


