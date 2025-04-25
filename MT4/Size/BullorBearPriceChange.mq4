//+------------------------------------------------------------------+
//|                                                     TrendBox.mq4 |
//|                    Real-Time Bullish/Bearish Box Indicator       |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window


// Enum for corner selection
enum ObjectCorner
{
    Corner_TopLeft = 0,
    Corner_TopRight = 1,
    Corner_BottomLeft = 2,
    Corner_BottomRight = 3
};

// Input Parameters
input int BoxWidth = 50;          // Width of the rectangle in pixels
input color BullishColor = Lime;  // Color of the box for a bullish change
input color BearishColor = Red;   // Color of the box for a bearish change
input ObjectCorner Corner = Corner_BottomRight; 
input int DistanceFromAEdge=10;

int LeftMargin=DistanceFromAEdge;
int RightMargin=DistanceFromAEdge+BoxWidth;
int TopMargin=DistanceFromAEdge;
int BottomMargin=DistanceFromAEdge+BoxWidth;

// Global Variables
color boxColor = BullishColor;    // Default color
double lastPrice = 0;             // Last recorded price
int objID = 0;                    // Unique object ID

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    // Set the initial price and color
    lastPrice = Bid;
    boxColor = BullishColor;  // Initial color

    // Create the rectangle object
    CreateRectangle();

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Delete the rectangle when the indicator is removed
    ObjectDelete(0, "TrendBox");
}

//+------------------------------------------------------------------+
//| Create or recreate the rectangle with updated color              |
//+------------------------------------------------------------------+
void CreateRectangle()
{
    string objName = "TrendBox";

    // Delete the old rectangle (if it exists)
    ObjectDelete(0, objName);

    // Create the new rectangle object
    if (!ObjectCreate(0, objName, OBJ_RECTANGLE_LABEL, 0, 0, 0))
    {
        Print("Error creating rectangle. Error code: ", GetLastError());
        return;
    }

    // Set the properties for the rectangle
    ObjectSetInteger(0, objName, OBJPROP_CORNER, Corner);  // Top-left corner
    switch (Corner){
      case 0: //Top left
           ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, LeftMargin);
           ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, TopMargin);          
           break;
      
      case 1: //top right 
           ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, RightMargin);
           ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, TopMargin);          
           break;
      case 2: //bottom left
           ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, LeftMargin);
           ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, BottomMargin);          
           break;
      case 3:  //bottom right
           ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, RightMargin);
           ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, BottomMargin);
           break;
    }
  
    ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, 10);
    ObjectSetInteger(0, objName, OBJPROP_WIDTH, BoxWidth);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, boxColor);  // Set the color
    ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, boxColor);  // Background color
    ObjectSetInteger(0, objName, OBJPROP_BORDER_TYPE, BORDER_FLAT);  // Flat border style
    //ObjectSetInteger(0, objName, OBJPROP_BORDERCOLOR, boxColor); // Border color
}

//+------------------------------------------------------------------+
//| Custom indicator calculation function                            |
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
    // Ensure there's enough data to make the calculation
    if (rates_total < 2) return(0);

    // Check for price change
    if (lastPrice != close[0])
    {
        // Determine if the change is bullish or bearish
        if (close[0] > lastPrice)
            boxColor = BullishColor;  // Bullish change
        else if (close[0] < lastPrice)
            boxColor = BearishColor;  // Bearish change

        // Create a new rectangle with updated color
        CreateRectangle();

        // Update the last price
        lastPrice = close[0];
    }

    return(rates_total);
}
