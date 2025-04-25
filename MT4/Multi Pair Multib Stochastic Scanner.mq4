//+------------------------------------------------------------------+
//|                                                      StochasticScanner.mq4 |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                       https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2024"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue // Color for %K line
#property indicator_color2 Red  // Color for %D line

// Define stochastic settings
const int stochSettings[4][3] = { {9, 3, 1}, {14, 3, 1}, {40, 4, 1}, {60, 10, 1} };
const int numSettings = ArraySize(stochSettings);

// List of currency pairs to scan
string currencyPairs[] = {"USDJPY", "EURUSD", "GBPUSD", "USDCHF", "AUDUSD", "NZDUSD", "USDCAD", "USDJPY"}; // Adjust as needed
const int numPairs = ArraySize(currencyPairs);

// Indicator buffers
double BufferK[];
double BufferD[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Initialization code
   IndicatorBuffers(2); // Define two indicator buffers
   SetIndexBuffer(0, BufferK);
   SetIndexBuffer(1, BufferD);
   
   // Set index labels and styles
   SetIndexStyle(0, DRAW_LINE);
   SetIndexLabel(0, "%K");
   SetIndexStyle(1, DRAW_LINE);
   SetIndexLabel(1, "%D");
   
   // Name the indicator
   IndicatorShortName("Stochastic Scanner");
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
                const long &spread[])
  {
   // Check if there are enough bars
   if (rates_total < 1)
      return (0);

   // Loop through currency pairs
   for(int i = 0; i < numPairs; i++)
     {
      string symbol = currencyPairs[i];
      for(int j = 0; j < numSettings; j++)
        {
         int kPeriod = stochSettings[j][0];
         int kSmooth = stochSettings[j][1];
         int dSmooth = stochSettings[j][2];
         
         // Retrieve stochastic values for current symbol
         double stochK = iStochastic(symbol, 0, kPeriod, kSmooth, dSmooth, MODE_SMA, 0, MODE_MAIN, 0);
         double stochD = iStochastic(symbol, 0, kPeriod, kSmooth, dSmooth, MODE_SMA, 0, MODE_SIGNAL, 0);
         
         // Generate alert based on conditions
         if((stochK < 20 && stochD < 20) || (stochK > 80 && stochD > 80))
           {
            Alert("Stochastic Alert for ", symbol, ": K: ", DoubleToString(stochK, 2), " D: ", DoubleToString(stochD, 2));
           }
        }
     }
   return (rates_total);
  }
//+------------------------------------------------------------------+
