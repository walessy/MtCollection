//+------------------------------------------------------------------+
//|                                                     Lot_Size2.mq4 |
//|                        Example: Margin Calculation Indicator   |
//|                                                                  |
//+------------------------------------------------------------------+
#property strict
#include <stdlib.mqh>

// Class definition for MarginCalcIndicator
class MarginCalcIndicator {
private:
    int X[6];  // Array for X coordinates (size based on number of elements)
    int Y[9];  // Array for Y coordinates (size based on number of elements)

    double dpi;
    int sizeTxt;
    bool stateHide, trig;
    string _prefix;

public:
    // Constructor
    MarginCalcIndicator() {
        _prefix = "margin_calc_indicator";
        dpi = 1.0;  // Default DPI
        sizeTxt = 12;
        stateHide = false;
        trig = false;
    //}

    // Method to initialize arrays
    //void InitializeArrays() {
        X[0] = 10;   // X coordinate for rectangle background
        X[1] = 17;   // X coordinate for stoploss text, risk text, lot text
        X[2] = 55;   // X coordinate for stoploss edit, risk edit
        X[3] = 163;  // X coordinate for risk value, lot value, margin value
        X[4] = 133;  // X coordinate for minimize button
        X[5] = 151;  // X coordinate for exit button

        Y[0] = 0;    // Y coordinate for rectangle background
        Y[1] = 18;   // Y coordinate for stoploss text
        Y[2] = 10;   // Y coordinate for stoploss edit
        Y[3] = 46;   // Y coordinate for risk text, risk value
        Y[4] = 38;   // Y coordinate for risk edit
        Y[5] = 71;   // Y coordinate for lot text, lot value
        Y[6] = 96;   // Y coordinate for margin text, margin value
        Y[7] = 121;  // Y coordinate for equity text, equity value
        Y[8] = 0;    // Y coordinate for minimize, exit
    }

    // Method to create the rectangle background
    void CreateLabel() {
        ObjectCreate(0, "RectLabel", OBJ_RECTANGLE_LABEL, 0, 0, 0);
        ObjectSetInteger(0, "RectLabel", OBJPROP_XDISTANCE, X[0]);
        ObjectSetInteger(0, "RectLabel", OBJPROP_YDISTANCE, Y[0]);
        ObjectSetInteger(0, "RectLabel", OBJPROP_XSIZE, 160);  // Rectangle width
        ObjectSetInteger(0, "RectLabel", OBJPROP_YSIZE, 150);  // Rectangle height
        ObjectSetInteger(0, "RectLabel", OBJPROP_COLOR, clrBlack); // Set border color (optional)
        ObjectSetInteger(0, "RectLabel", OBJPROP_BGCOLOR, clrWhite); // Set background color
    }

    // Method to create button
    void CreateButton(string name, int type, string buttonText, int index) {
        ObjectCreate(0, name, type, 0, 0, 0);
        ObjectSetInteger(0, name, OBJPROP_XDISTANCE, X[index]);
        ObjectSetInteger(0, name, OBJPROP_YDISTANCE, Y[index]);
        ObjectSetInteger(0, name, OBJPROP_XSIZE, 100);  // Button width
        ObjectSetInteger(0, name, OBJPROP_YSIZE, 30);   // Button height
        ObjectSetString(0, name, OBJPROP_TEXT, buttonText);
        ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
        ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    }

    // Method to calculate free margin
    void CalculateMargin() {
        double FreeMargin = AccountFreeMarginCheck(_Symbol, OP_BUY, 1.0);  // Fixed signature
        Print("Free Margin: ", FreeMargin);
    }

    // Method to calculate lot size based on risk
    double CalculateLotSize(double riskAmount) {
        double FreeMargin = AccountFreeMarginCheck(_Symbol, OP_BUY, 1.0);  // Corrected
        double LotSize = FreeMargin * riskAmount;  // Example calculation
        return LotSize;
    }

    // Method to display the maximum lot size
    void DisplayMaxLotSize() {
        double maxLotSize = CalculateLotSize(0.01);  // Example risk amount
        Print("Maximum Lot Size: ", maxLotSize);
    }
};

// Global instance of the class
MarginCalcIndicator marginCalcIndicator;

// Initialization function
int OnInit() {
    //marginCalcIndicator.InitializeArrays();  // Initialize arrays in OnInit()
    marginCalcIndicator.CreateLabel();  // Create the background rectangle
    marginCalcIndicator.CreateButton("BuyButton", OBJ_BUTTON, "Buy", 1);  // Create Buy button at X[1], Y[1]
    marginCalcIndicator.CreateButton("SellButton", OBJ_BUTTON, "Sell", 2); // Create Sell button at X[2], Y[2]

    marginCalcIndicator.DisplayMaxLotSize();  // Display max lot size

    return INIT_SUCCEEDED;
}

// Deinitialization function
void OnDeinit(const int reason) {
    ObjectDelete("RectLabel");
    ObjectDelete("BuyButton");
    ObjectDelete("SellButton");
}

// Tick function
void OnTick() {
    marginCalcIndicator.CalculateMargin();
}
