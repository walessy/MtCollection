//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Create a button at the bottom middle of the chart
   CreateToggleButton();

   // Set the initial state (candles visible)
   ChartRedraw();
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Create a button                                                  |
//+------------------------------------------------------------------+
void CreateToggleButton()
{
   int width = 100;   // Button width
   int height = 30;   // Button height
   int x = (ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) / 2) - (width / 2);   // X-coordinate for center
   int y = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS) - height - 10;        // Y-coordinate for bottom
   
   // Create the button
   if (!ObjectCreate(0, "ToggleCandleButton", OBJ_BUTTON, 0, 0, 0))
   {
      Print("Failed to create the button!");
      return;
   }

   // Set button properties
   ObjectSetInteger(0, "ToggleCandleButton", OBJPROP_CORNER, 0);
   ObjectSetInteger(0, "ToggleCandleButton", OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, "ToggleCandleButton", OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, "ToggleCandleButton", OBJPROP_XSIZE, width);
   ObjectSetInteger(0, "ToggleCandleButton", OBJPROP_YSIZE, height);
   ObjectSetString(0, "ToggleCandleButton", OBJPROP_TEXT, "Toggle Candles");
   ObjectSetInteger(0, "ToggleCandleButton", OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, "ToggleCandleButton", OBJPROP_BACK, true);
   ObjectSetInteger(0, "ToggleCandleButton", OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, "ToggleCandleButton", OBJPROP_BORDER_TYPE, BORDER_RAISED);
   ObjectSetInteger(0, "ToggleCandleButton", OBJPROP_COLOR, clrBlack);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Delete the button when the script is removed
   ObjectDelete(0, "ToggleCandleButton");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Check if the button was clicked
   if (ObjectGetInteger(0, "ToggleCandleButton", OBJPROP_STATE) == 1)
   {
      static bool candles_visible = true;
      
      // Toggle candle visibility
      candles_visible = !candles_visible;
      if (candles_visible)
      {
         // Show candlesticks by setting colors back to original
         ObjectSetInteger(0, "CandleOutline", OBJPROP_COLOR, clrBlack);
         ObjectSetInteger(0, "BullCandle", OBJPROP_COLOR, clrWhite);
         ObjectSetInteger(0, "BearCandle", OBJPROP_COLOR, clrRed);
      }
      else
      {
         // Hide candlesticks by setting them to the background color
         color bgColor = ChartGetInteger(0, CHART_COLOR_BACKGROUND);
         ObjectSetInteger(0, "CandleOutline", OBJPROP_COLOR, bgColor);
         ObjectSetInteger(0, "BullCandle", OBJPROP_COLOR, bgColor);
         ObjectSetInteger(0, "BearCandle", OBJPROP_COLOR, bgColor);
      }

      // Update the button text to reflect the new state
      if (candles_visible)
         ObjectSetString(0, "ToggleCandleButton", OBJPROP_TEXT, "Hide Candles");
      else
         ObjectSetString(0, "ToggleCandleButton", OBJPROP_TEXT, "Show Candles");

      // Reset the button state to avoid multiple toggles
      ObjectSetInteger(0, "ToggleCandleButton", OBJPROP_STATE, 0);
      
      // Redraw the chart to apply changes
      ChartRedraw();
   }
}
