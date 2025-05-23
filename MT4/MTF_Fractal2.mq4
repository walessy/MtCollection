//+------------------------------------------------------------------+
//|                                                  MTF Fractal.mq4 |
//|                                         Copyright © 2014, TrueTL |
//|                                            http://www.truetl.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, TrueTL"
#property link      "http://www.truetl.com"
#property version "1.40"
#property indicator_chart_window
#property indicator_buffers 2

extern string  Version_140                      = "www.truetl.com";
extern ENUM_TIMEFRAMES Fractal_Timeframe        = 0;
extern int     Maxbar                           = 2000;
extern color   Up_Fractal_Color                 = Red;
extern int     Up_Fractal_Symbol                = 108;
extern color   Down_Fractal_Color               = Blue;
extern int     Down_Fractal_Symbol              = 108;
extern bool    Extend_Line                      = true;
extern bool    Extend_Line_to_Background        = true;
extern bool    Show_Validation_Candle           = true;
extern int     BuySellCancellationMode          = 0; // 0=True, 1=False, 2=VolDiff

color   Up_Fractal_Extend_Line_Color     = Up_Fractal_Color;
extern int     Up_Fractal_Extend_Width          = 0;
extern int     Up_Fractal_Extend_Style          = 2;
color   Down_Fractal_Extend_Line_Color   = Down_Fractal_Color;
extern int     Down_Fractal_Extend_Width        = 0;
extern int     Down_Fractal_Extend_Style        = 2;
extern bool    IsRay                            = 0;
double UpBuffer[], DoBuffer[], refchk, tempref, level; 

double BuyPriceLevels[1000];  // Array for price levels
double BuyPriceCounts[1000];  // Array for hit counts

double SellPriceLevels[1000]; // Array for price levels
double SellPriceCounts[1000]; // Array for hit counts

int BuyPriceSize = 0;  // To keep track of the number of price levels
int SellPriceSize = 0; // To keep track of the number of price levels

extern bool  autoChartScaling = true;
int barc;

//+------------------------------------------------------------------+
//|                                                             INIT |
//+------------------------------------------------------------------+
int init() {

   SetIndexBuffer(0,UpBuffer);
   SetIndexStyle(0,DRAW_ARROW, DRAW_ARROW, 0, Up_Fractal_Color);
   SetIndexArrow(0,Up_Fractal_Symbol);
   SetIndexBuffer(1,DoBuffer);
   SetIndexStyle(1,DRAW_ARROW, DRAW_ARROW, 0, Down_Fractal_Color);
   SetIndexArrow(1,Down_Fractal_Symbol);

   ArrayInitialize(BuyPriceLevels, 0);  // Initialize arrays
   ArrayInitialize(BuyPriceCounts, 0);
   ArrayInitialize(SellPriceLevels, 0);
   ArrayInitialize(SellPriceCounts, 0);

   return(0);
}

//+------------------------------------------------------------------+
//|                                                           DEINIT |
//+------------------------------------------------------------------+
int deinit() {
   for (int i = ObjectsTotal(); i >= 0; i--) {
      if (StringSubstr(ObjectName(i),0,12) == "MTF_Fractal_") {
         ObjectDelete(ObjectName(i));
      }
   }
   
   return(0);
}

//+------------------------------------------------------------------+
//|                                                            START |
//+------------------------------------------------------------------+
int start() {
   int i, c, dif;
   tempref =   iHigh(Symbol(), Fractal_Timeframe, 1) + 
               iHigh(Symbol(), Fractal_Timeframe, 51) + 
               iHigh(Symbol(), Fractal_Timeframe, 101);
   
   if (barc != Bars || IndicatorCounted() < 0 || tempref != refchk) {
      barc = Bars;
      refchk = tempref;
   } else
      return(0);
   
   deinit();
   
   if (Fractal_Timeframe <= Period()) Fractal_Timeframe = Period();
   
   dif = Fractal_Timeframe/Period();
   
   if (Maxbar > Bars) Maxbar = Bars-10;
   
   for(i = 0; i < Maxbar; i++) {
      if (iBarShift(NULL,Fractal_Timeframe,Time[i]) < 3) {
         UpBuffer[i] = 0;
         DoBuffer[i] = 0;
         continue;
      }
      UpBuffer[i] = iFractals(NULL,Fractal_Timeframe,1,iBarShift(NULL,Fractal_Timeframe,Time[i]));
      DoBuffer[i] = iFractals(NULL,Fractal_Timeframe,2,iBarShift(NULL,Fractal_Timeframe,Time[i]));
   }
   
   if (Extend_Line) {
      for(i = 0; i < Maxbar; i++) {
         if (UpBuffer[i] > 0) {
            level = UpBuffer[i];
            for (c = i; c > 0; c--) {
               if ((Open[c] < level && Close[c] > level) || (Open[c] > level && Close[c] < level)) 
                  break;
               if (Open[c] <= level && Close[c] <= level && Open[c-1] >= level && Close[c-1] >= level) 
                  break;
               if (Open[c] >= level && Close[c] >= level && Open[c-1] <= level && Close[c-1] <= level) 
                  break;
            }
            DrawLineOrEllipse ("H", i, c, level, Extend_Line_to_Background, Up_Fractal_Extend_Line_Color, Up_Fractal_Extend_Width, Up_Fractal_Extend_Style);
            if (Show_Validation_Candle) UpBuffer[i-2*dif] = level;
            i += dif;         
         }
      }
      
      for(i = 0; i < Maxbar; i++) {
         if (DoBuffer[i] > 0) {
            level = DoBuffer[i];
            for (c = i; c > 0; c--) {
               if ((Open[c] < level && Close[c] > level) || (Open[c] > level && Close[c] < level)) 
                  break;
               if (Open[c] <= level && Close[c] <= level && Open[c-1] >= level && Close[c-1] >= level) 
                  break;
               if (Open[c] >= level && Close[c] >= level && Open[c-1] <= level && Close[c-1] <= level) 
                  break;
            }
            DrawLineOrEllipse ("L", i, c, level, Extend_Line_to_Background, Down_Fractal_Extend_Line_Color, Down_Fractal_Extend_Width, Down_Fractal_Extend_Style);
            if (Show_Validation_Candle) DoBuffer[i-2*dif] = level;
            i += dif;
         }
      }
   }
   
   return(0);
}

//+------------------------------------------------------------------+
//| Draw Line or Ellipse based on BuySellCancellationMode            |
//+------------------------------------------------------------------+
void DrawLineOrEllipse (string dir, int i, int c, double lev, bool back, color col, int width, int style) {
   int buyIndex = FindOrInsertPriceLevel(lev, BuyPriceLevels, BuyPriceCounts, BuyPriceSize);
   int sellIndex = FindOrInsertPriceLevel(lev, SellPriceLevels, SellPriceCounts, SellPriceSize);

   if(BuySellCancellationMode == 1) { // Mode 1: Skip if both buy and sell levels exist
      if (BuyPriceCounts[buyIndex] > 0 && SellPriceCounts[sellIndex] > 0) {
         return;
      }
   }

   if(BuySellCancellationMode == 2) { // Mode 2: Draw ellipse based on volume difference
      double buyVol = BuyPriceCounts[buyIndex];
      double sellVol = SellPriceCounts[sellIndex];
      double volDiff = MathAbs(buyVol - sellVol);
      double radius = volDiff; //MathLog(volDiff + 1) * 10; // Logarithm to scale radius
      color ellipseColor = (buyVol > sellVol) ? Up_Fractal_Color : Down_Fractal_Color;

      // Draw ellipse at closing point of the candle
      string ellipseName = "MTF_Fractal_Ellipse_" + i + "_" + dir;
      ObjectCreate(ellipseName, OBJ_ELLIPSE, 0, Time[i], Close[i] - radius * Point, Time[i], Close[i] + radius * Point);
      ObjectSet(ellipseName, OBJPROP_COLOR, ellipseColor);
      ObjectSet(ellipseName, OBJPROP_WIDTH, 2); // Set ellipse border width
      return;
   }

   // Default or Mode 0: Draw lines
   ObjectCreate("MTF_Fractal_"+dir+i,OBJ_TREND,0,0,0,0,0);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_TIME1,iTime(Symbol(),Period(),i));
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_PRICE1,lev);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_TIME2,iTime(Symbol(),Period(),c));
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_PRICE2,lev);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_RAY,IsRay);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_BACK,back);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_COLOR,col);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_WIDTH,width);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_STYLE,style);

   // Increment the appropriate hit count
   if(col == Up_Fractal_Color) {
      BuyPriceCounts[buyIndex]++;
      Print("Buy Level Hit Count: ", BuyPriceCounts[buyIndex]);
   } else if(col == Down_Fractal_Color) {
      SellPriceCounts[sellIndex]++;
      Print("Sell Level Hit Count: ", SellPriceCounts[sellIndex]);
   }
}

//+------------------------------------------------------------------+
//| Find or insert price level                                       |
//+------------------------------------------------------------------+
int FindOrInsertPriceLevel(double level, double &levels[], double &counts[], int &size) {
   int low = 0, high = size - 1, mid;
   
   while(low <= high) {
      mid = (low + high) / 2;
      if(levels[mid] == level)
         return mid;  // Found the level
      else if(levels[mid] < level)
         low = mid + 1;
      else
         high = mid - 1;
   }
   
   // If not found, insert it at the correct position
   for(int j = size; j > low; j--) {
      levels[j] = levels[j-1];
      counts[j] = counts[j-1];
   }
   
   levels[low] = level;
   counts[low] = 0;  // Initialize the hit count to 0
   size++;
   
   return low;  // Return the index of the newly inserted level
}
