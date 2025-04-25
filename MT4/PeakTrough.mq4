//+------------------------------------------------------------------+
//|                                                       PeakTrough.mq4 |
//|                         User's Name                                 |
//+------------------------------------------------------------------+
#property strict

#include <stderror.mqh>
#include <stdlib.mqh>

input int PipThreshold = 10;       // Minimum pip distance between peaks/troughs
input int TimeFrame = 5;           // Timeframe in minutes (default: 5 minutes)
input string CSVFileName = "peaks_troughs.csv";  // CSV file for output

// Global variables
double prevHigh, prevLow;
int lastDirection = 0; // 1 for upward (peak), -1 for downward (trough), 0 for undefined

// Helper function to convert pip threshold into point value
double PipToPoints(int pips) {
    return pips * Point;
}

// Write to CSV function
void WriteToCSV(string fileName, datetime time, double price, string type) {
    int fileHandle = FileOpen(fileName, FILE_CSV | FILE_WRITE | FILE_READ, ';');
    if(fileHandle > 0) {
        FileSeek(fileHandle, 0, SEEK_END);
        FileWrite(fileHandle, TimeToString(time, TIME_DATE | TIME_MINUTES), price, type);
        FileClose(fileHandle);
    } else {
        Print("Failed to open CSV file: ", fileName);
    }
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    IndicatorShortName("Peaks and Troughs Indicator");
    
    // Initialize CSV file
    FileDelete(CSVFileName); // Delete existing CSV file if it exists
    int fileHandle = FileOpen(CSVFileName, FILE_CSV | FILE_WRITE, ';');
    if (fileHandle > 0) {
        FileWrite(fileHandle, "Time", "Price", "Type");
        FileClose(fileHandle);
    } else {
        Print("Failed to create CSV file");
    }
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
    int start = prev_calculated; // Start from where we left off
    
    // Loop through each bar
    for (int i = start; i < rates_total - 1; i++) {
        double currentHigh = high[i];
        double currentLow = low[i];
        
        // Check if this bar is a peak (higher than both adjacent bars)
        if (currentHigh - prevHigh > PipToPoints(PipThreshold) && high[i] > high[i+1]) {
            // Peak identified
            WriteToCSV(CSVFileName, time[i], currentHigh, "Peak");
            lastDirection = 1; // Set direction to peak
        }
        // Check if this bar is a trough (lower than both adjacent bars)
        else if (prevLow - currentLow > PipToPoints(PipThreshold) && low[i] < low[i+1]) {
            // Trough identified
            WriteToCSV(CSVFileName, time[i], currentLow, "Trough");
            lastDirection = -1; // Set direction to trough
        }
        
        // Update previous high and low
        prevHigh = currentHigh;
        prevLow = currentLow;
    }
    
    return(rates_total);
}

//+------------------------------------------------------------------+
