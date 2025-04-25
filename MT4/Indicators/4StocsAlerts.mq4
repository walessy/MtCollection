// Declare global variables for tracking the last checked candle
datetime last_candle_checked = 0;

// Concatenate symbol and stochastic names for global variables
string sconcat1 = StringConcatenate(Symbol(), "__Stochastic(9,3,1)_Overbought");
string sconcat2 = StringConcatenate(Symbol(), "__Stochastic(14,3,1)_Overbought");
string sconcat3 = StringConcatenate(Symbol(), "__Stochastic(40,4,1)_Overbought");
string sconcat4 = StringConcatenate(Symbol(), "__Stochastic(60,10,1)_Overbought");

string sconcat5 = StringConcatenate(Symbol(), "__Stochastic(9,3,1)_Oversold");
string sconcat6 = StringConcatenate(Symbol(), "__Stochastic(14,3,1)_Oversold");
string sconcat7 = StringConcatenate(Symbol(), "__Stochastic(40,4,1)_Oversold");
string sconcat8 = StringConcatenate(Symbol(), "__Stochastic(60,10,1)_Oversold");

// Declare global variables for tracking the start of overbought/oversold conditions
datetime overboughtStartTime = 0;
datetime oversoldStartTime = 0;

//+------------------------------------------------------------------+
//| Indicator initialization function                                |
//+------------------------------------------------------------------+
int OnInit()
{
   // Set up the indicator
   IndicatorShortName("Stochastic Alert System");
   last_candle_checked = Time[0]; // Initialize tracking for the last checked candle

   return(INIT_SUCCEEDED);
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
   // Only process on a new candle
   if (time[0] != last_candle_checked)
   {
      last_candle_checked = time[0]; // Update the last checked candle time

      // Get previous stochastic values for all indicators
      double stoch1_previous = iStochastic(NULL, 0, 9, 3, 1, MODE_SMA, 0, MODE_SIGNAL, 1);
      double stoch2_previous = iStochastic(NULL, 0, 14, 3, 1, MODE_SMA, 0, MODE_SIGNAL, 1);
      double stoch3_previous = iStochastic(NULL, 0, 40, 4, 1, MODE_SMA, 0, MODE_SIGNAL, 1);
      double stoch4_previous = iStochastic(NULL, 0, 60, 10, 1, MODE_SMA, 0, MODE_SIGNAL, 1);
      double stoch5_previous = iStochastic(NULL, 0, 120, 20, 1, MODE_SMA, 0, MODE_SIGNAL, 1);

      // Get previous stochastic values for all indicators
      double stoch1_curr = iStochastic(NULL, 0, 9, 3, 1, MODE_SMA, 0, MODE_SIGNAL, 0);
      double stoch2_curr = iStochastic(NULL, 0, 14, 3, 1, MODE_SMA, 0, MODE_SIGNAL, 0);
      double stoch3_curr = iStochastic(NULL, 0, 40, 4, 1, MODE_SMA, 0, MODE_SIGNAL, 0);
      double stoch4_curr = iStochastic(NULL, 0, 60, 10, 1, MODE_SMA, 0, MODE_SIGNAL, 0);
      double stoch5_curr = iStochastic(NULL, 0, 120, 20, 1, MODE_SMA, 0, MODE_SIGNAL, 0);
      
      // Check if all indicators are either overbought or oversold and trigger a combined alert
       // Declare the current time
      datetime currentTime = time[0];
      
      CheckForCombinedAlerts(stoch1_previous, stoch2_previous, stoch3_previous, stoch4_previous,stoch1_curr, stoch2_curr, stoch3_curr, stoch4_curr,currentTime,stoch5_previous, stoch5_curr);
   }

   return(rates_total);
}

//+------------------------------------------------------------------+
//| Function to check if all stochastic indicators are overbought/oversold |
//+------------------------------------------------------------------+
void CheckForCombinedAlerts(double stoch1, double stoch2, double stoch3, double stoch4,double stoch1Curr, double stoch2Curr, double stoch3Curr, double stoch4Curr,datetime currentTime,double stoch5, double stoch5Curr)
{
   string message = "";
   string symbol = Symbol();  // Get the current symbol
   string timeframe = Period();  // Get the current timeframe

   // Convert the timeframe to a readable format
   string timeframe_string = TimeFrameToString(timeframe);

   // Check if all global variables for overbought exist
   //if (GlobalVariableCheck(sconcat1) && GlobalVariableCheck(sconcat2) &&
   //    GlobalVariableCheck(sconcat3) && GlobalVariableCheck(sconcat4))
   //{
      // If all stochastic values are overbought (>= 80)
      
      if (
            (stoch1Curr >= stoch5Curr && stoch2Curr >= stoch5Curr && stoch3Curr >= stoch5Curr && stoch4Curr >= stoch5Curr)&&
            (stoch3 < stoch5 )
         )
      {     
         message = StringFormat("%s (%s) stocchastics up!", symbol, timeframe_string);
         Alert(message);
         Print(message);  // Print to the log for debugging
         
               // If this is the start of the overbought condition, save the current time
         if (overboughtStartTime == 0)
            overboughtStartTime = currentTime;

         WriteAlertToFile(message);
         //DrawHorizontalLineAtCurrentPrice("PriceLine", clrBlue, 1);
         DrawStochasticHighlight("StochasticsUp", overboughtStartTime, currentTime, 80, 100, clrRed);
         // Set the color with transparency (e.g., 128 for 50% transparency)
         ObjectSetInteger(0, "StochasticsUp", OBJPROP_COLOR, clrRed & 0x80FFFFFF);
      }
       else{
         // Remove rectangle if not overbought
         ObjectDelete("StochasticsUp");
         oversoldStartTime = 0;
      }     
      //--------------------------------------------------------------------------------------------------
      if (
            (stoch1Curr <= stoch5Curr && stoch2Curr <= stoch5Curr && stoch3Curr <= stoch5Curr && stoch4Curr <= stoch5Curr)&&
            (stoch3 > stoch5 )
      )
      {     
         message = StringFormat("%s (%s) stocchastics down!", symbol, timeframe_string);
         Alert(message);
         Print(message);  // Print to the log for debugging
         
               // If this is the start of the overbought condition, save the current time
         if (overboughtStartTime == 0)
            overboughtStartTime = currentTime;

         WriteAlertToFile(message);
         //DrawHorizontalLineAtCurrentPrice("PriceLine", clrBlue, 1);
         DrawStochasticHighlight("StochasticsDown", overboughtStartTime, currentTime, 80, 100, clrRed);
         // Set the color with transparency (e.g., 128 for 50% transparency)
         ObjectSetInteger(0, "StochasticsDown", OBJPROP_COLOR, clrRed & 0x80FFFFFF);
      }
       else{
         // Remove rectangle if not overbought
         ObjectDelete("StochasticsDown");
         oversoldStartTime = 0;
      }   
      //--------------------------------------------------------------------------------------------------
      if((stoch5<20 &&stoch5Curr>=20)||(stoch5>80&&stoch5Curr<=80)){
          message = StringFormat("%s (%s) iTrend change?", symbol, timeframe_string);
         Alert(message);
         Print(message);  // Print to the log for debugging
         
               // If this is the start of the overbought condition, save the current time
         if (overboughtStartTime == 0)
            overboughtStartTime = currentTime;

         WriteAlertToFile(message);
         //DrawHorizontalLineAtCurrentPrice("PriceLine", clrBlue, 1);
         DrawStochasticHighlight("TrendChange", overboughtStartTime, currentTime, 80, 100, clrRed);
         // Set the color with transparency (e.g., 128 for 50% transparency)
         ObjectSetInteger(0, "TrendChange", OBJPROP_COLOR, clrRed & 0x80FFFFFF);     
      }
      else{
         // Remove rectangle if not overbought
         ObjectDelete("TrendChange");
         oversoldStartTime = 0;
      }
      //----------------------------------------------------------------------------------------------------        
      
      if (stoch1 >= 80 && stoch2 >= 80 && stoch3 >= 80 && stoch4 >= 80)
      {
         message = StringFormat("%s (%s) is Overbought on all stochastics!", symbol, timeframe_string);
         Alert(message);
         Print(message);  // Print to the log for debugging
         
               // If this is the start of the overbought condition, save the current time
         if (overboughtStartTime == 0)
            overboughtStartTime = currentTime;

         WriteAlertToFile(message);
         //DrawHorizontalLineAtCurrentPrice("PriceLine", clrBlue, 1);
         DrawStochasticHighlight("OverboughtRect", overboughtStartTime, currentTime, 80, 100, clrRed);
         // Set the color with transparency (e.g., 128 for 50% transparency)
         ObjectSetInteger(0, "OverboughtRect", OBJPROP_COLOR, clrRed & 0x80FFFFFF);
      }
      else{
         // Remove rectangle if not overbought
         ObjectDelete("OverboughtRect");
         oversoldStartTime = 0;
      }

   //}

   // Check if all global variables for oversold exist
   //if (GlobalVariableCheck(sconcat5) && GlobalVariableCheck(sconcat6) &&
   //    GlobalVariableCheck(sconcat7) && GlobalVariableCheck(sconcat8))
   //{
      // If all stochastic values are oversold (<= 20)
      if (stoch1 <= 20 && stoch2 <= 20 && stoch3 <= 20 && stoch4 <= 20)
      {
         message = StringFormat("%s (%s) is Oversold on all stochastics!", symbol, timeframe_string);
         Alert(message);
         Print(message);  // Print to the log for debugging
         
         if (oversoldStartTime == 0)
            oversoldStartTime = currentTime;

         WriteAlertToFile(message);
         //DrawHorizontalLineAtCurrentPrice("PriceLine", clrBlue, 1);
         DrawStochasticHighlight("OversoldRect", oversoldStartTime, currentTime, 0, 20, clrBlue);
         // Set the color with transparency (e.g., 128 for 50% transparency)
         ObjectSetInteger(0, "OversoldRect", OBJPROP_COLOR, clrBlue & 0x80FFFFFF);
      }
      else{
         overboughtStartTime = 0;
         ObjectDelete("OversoldRect");
      }
   //}
}

//+------------------------------------------------------------------+
//| Function to convert timeframe to readable string                  |
//+------------------------------------------------------------------+
string TimeFrameToString(int timeframe)
{
   switch(timeframe)
   {
      case PERIOD_M1: return "1 Minute";
      case PERIOD_M5: return "5 Minutes";
      case PERIOD_M15: return "15 Minutes";
      case PERIOD_M30: return "30 Minutes";
      case PERIOD_H1: return "1 Hour";
      case PERIOD_H4: return "4 Hours";
      case PERIOD_D1: return "Daily";
      case PERIOD_W1: return "Weekly";
      case PERIOD_MN1: return "Monthly";
      default: return "Unknown";
   }
}

// Function to write an alert message to a file, ensuring each message is on a new line
void WriteAlertToFile(string message)
{
    // Get the current date and time
    datetime currentTime = TimeCurrent();
    string fullDate = TimeToStr(currentTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS); // Full date and time
    
    /*
    string row = "something to write\n";
      int fH = FileOpen(fName,FILE_READ|FILE_WRITE);
      FileSeek(fH,0,SEEK_END); 
      FileWriteString(fH, row, StringLen(row) );
      FileClose(fH);
     */ 
     
    // Open the file for appending (so previous data is not overwritten)
    //int fileHandle = FileOpen(StringConcatenate(Symbol(),Period(),"alerts_log.txt"), FILE_WRITE | FILE_CSV | FILE_READ | FILE_ANSI);
    int fileHandle = FileOpen(StringConcatenate("alerts_log.txt"),FILE_WRITE | FILE_CSV | FILE_READ | FILE_ANSI);
    if (fileHandle != INVALID_HANDLE)
    {
        FileSeek(fileHandle,0,SEEK_END); 
        // Write the full date and message to the file (each FileWrite adds a new line)
        //FileWrite(fileHandle, fullDate + "," + message);
        
       message=fullDate + ","+message+"\r\n";
        FileWriteString(fileHandle, message, StringLen(message) );
        
        // Close the file
        FileClose(fileHandle);
    }
    else
    {
        Print("Error opening file for writing alerts.");
    }
}

// Function to draw rectangle highlighting overbought/oversold regions
void DrawStochasticHighlight(string name, datetime timeStart, datetime timeEnd, double priceLow, double priceHigh, color fillColor)
{
   if (ObjectFind(name) == -1) // Create new rectangle if it doesn't exist
   {
      ObjectCreate(name, OBJ_RECTANGLE, 0, timeStart, priceLow, timeEnd, priceHigh);
   }
   ObjectSet(name, OBJPROP_TIME1, timeStart); // Set start time
   ObjectSet(name, OBJPROP_PRICE1, priceLow); // Set low price (below stochastic 20)
   ObjectSet(name, OBJPROP_TIME2, timeEnd);   // Set end time
   ObjectSet(name, OBJPROP_PRICE2, priceHigh);// Set high price (above stochastic 80)
   ObjectSetInteger(0, name, OBJPROP_COLOR, fillColor); // Set color
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID); // Set solid style
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1); // Set width
   ObjectSetInteger(0, name, OBJPROP_BACK, true); // Send to background
}
