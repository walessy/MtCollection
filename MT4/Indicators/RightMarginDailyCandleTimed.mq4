//+------------------------------------------------------------------+
//|                                                     DayBar.mq4   |
//|                         Custom Indicator                         |
//+------------------------------------------------------------------+
#property copyright "YourName"
#property indicator_chart_window

// Input parameters
input color BullishColor = Lime;
input color BearishColor = Red;
input color OpenLineColor = DodgerBlue;
input color CloseLineColor = Orange;

// Function to delete all objects from the chart
void ObjectsDelete() {
   int totalObjects = ObjectsTotal(0);
   for (int i = totalObjects - 1; i >= 0; i--) {
      string objName = ObjectName(0, i);
      ObjectDelete(0, objName);
   }
}

void OnInit() {
   // Initialization function
   ObjectsDelete(); // Remove old objects
   Print("DayBar Indicator Initialized");
}

void OnDeinit(const int reason) {
   // Cleanup function
   ObjectsDelete(); // Remove all objects
   Print("DayBar Indicator Deinitialized");
}

void OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                 const double &open[], const double &high[], const double &low[], const double &close[],
                 const long &tick_volume[], const long &volume[], const int &spread[]) {
   // Get the total number of daily bars
   int totalBars = iBars(NULL, PERIOD_D1);
   if (totalBars <= 0) return; // Safety check

   for (int i = 0; i < MathMin(totalBars, 5); i++) { // Process last 5 daily bars
      string rectName = "DayRect_" + i;
      string openLineName = "DayOpen_" + i;
      string closeLineName = "DayClose_" + i;

      datetime dayStartTime = iTime(NULL, PERIOD_D1, i); // Get the start time of the daily bar
      if (dayStartTime == 0) continue; // Skip invalid data

      double high = iHigh(NULL, PERIOD_D1, i); // Daily high
      double low = iLow(NULL, PERIOD_D1, i); // Daily low
      double open = iOpen(NULL, PERIOD_D1, i); // Daily open
      double close = iClose(NULL, PERIOD_D1, i); // Daily close

      // Define rectangle properties
      color rectColor = close >= open ? BullishColor : BearishColor;

      // Create/update rectangle for the day bar (from high to low)
      if (!ObjectFind(0, rectName)) {
         ObjectCreate(0, rectName, OBJ_RECTANGLE, 0, dayStartTime, high, dayStartTime + 86400, low);
         ObjectSetInteger(0, rectName, OBJPROP_COLOR, rectColor);
         ObjectSetInteger(0, rectName, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, rectName, OBJPROP_WIDTH, 1);
      } else {
         ObjectMove(0, rectName, 0, dayStartTime, high);
         ObjectMove(0, rectName, 1, dayStartTime + 86400, low);
      }

      // Create/update open line
      if (!ObjectFind(0, openLineName)) {
         ObjectCreate(0, openLineName, OBJ_HLINE, 0, 0, open);
         ObjectSetInteger(0, openLineName, OBJPROP_COLOR, OpenLineColor);
         ObjectSetInteger(0, openLineName, OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, openLineName, OBJPROP_WIDTH, 1);
      } else {
         ObjectSetDouble(0, openLineName, OBJPROP_PRICE1, open);
      }

      // Create/update close line
      if (!ObjectFind(0, closeLineName)) {
         ObjectCreate(0, closeLineName, OBJ_HLINE, 0, 0, close);
         ObjectSetInteger(0, closeLineName, OBJPROP_COLOR, CloseLineColor);
         ObjectSetInteger(0, closeLineName, OBJPROP_STYLE, STYLE_DASH);
         ObjectSetInteger(0, closeLineName, OBJPROP_WIDTH, 1);
      } else {
         ObjectSetDouble(0, closeLineName, OBJPROP_PRICE1, close);
      }
   }
}
