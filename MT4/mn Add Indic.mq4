//+------------------------------------------------------------------+
//|                                                 mn Add Indic.mq4 |
//+------------------------------------------------------------------+
#property copyright "mn"
#include <stdlib.mqh>
#include <stderror.mqh>

#property indicator_chart_window
#import "user32.dll"
  int RegisterWindowMessageW(string MessageName);
  int SendMessageW(int hwnd, int msg, int wparam, char &Name[]);
   void keybd_event(int VirtualKey, int ScanCode, int Flags, int ExtraInfo);
#import

extern string mTemp0 = "REMOVE",
              mTemp1 = "ATR",
              mTemp2 = "Stochastic",
              mTemp3 = "RSI",
              mTemp4 = "RSI",
              mTemp5 = "CCI",
              mTemp6 = "MACD",
              mTemp7 = "RSI",
              mTemp8 = "RSI",
              mTemp9 = "RSI",
              mTemp10 = "RSI",
              mTemp11 = "RSI";
extern color  mButtonCol = clrCornflowerBlue,
              mTextCol = clrBlack;             
              
string mInd[12];              
                          
//+------------------------------------------------------------------+
void OnInit()
  {
      mInd[0] = mTemp0;
      mInd[1] = mTemp1;
      mInd[2] = mTemp2;
      mInd[3] = mTemp3;
      mInd[4] = mTemp4;
      mInd[5] = mTemp5;
      mInd[6] = mTemp6;
      mInd[7] = mTemp7;
      mInd[8] = mTemp8;
      mInd[9] = mTemp9;
      mInd[10] = mTemp10;
      mInd[11] = mTemp11;

    CreateBoxes();
        
    return;
  }
  
//+------------------------------------------------------------------+
int deinit()
  {
   string mObj;
   for(int m = ObjectsTotal()-1; m >= 0; m--)
    {
      mObj = ObjectName(m);
      if(StringSubstr(mObj, 0, 2) == "m.")
       ObjectDelete(mObj);
    }
   
   return(0);
  }

//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {   
    for(int x = 0; x < 12; x++)
      {
       string mTem = "m.B" +x;
       if(sparam == mTem) 
        { 
          if(ObjectGetInteger(0, mTem, OBJPROP_STATE))
            {
              ObjectSetInteger(0, mTem, OBJPROP_BGCOLOR, clrYellow);
              ObjectSetInteger(0, mTem, OBJPROP_STATE, false);
              callIndic(x);
              ObjectSetInteger(0, mTem, OBJPROP_SELECTED, false);
              ObjectSetInteger(0, mTem, OBJPROP_BGCOLOR, mButtonCol);
            }
         }
     }

  }
  
//+------------------------------------------------------------------+
int start()
  {


   return(0);
  }

//+------------------------------------------------------------------+
void callIndic(int m)
 {
   string name = mInd[m];
   char name2[];
   StringToCharArray(name , name2);
   string mName = ChartIndicatorName(0, 1, 0);
   int mW = ChartWindowFind(0, mName);
   if(mW >= 0)
     {
       bool res = ChartIndicatorDelete(0, 1, mName);
     }
 
   int hWnd = WindowHandle(Symbol(), Period());
   int MessageNumber = RegisterWindowMessageW("MetaTrader4_Internal_Message");
   keybd_event(13, 0, 0, 0);
   keybd_event(27, 0, 0, 0);
   int r = SendMessageW(hWnd, MessageNumber, 15, name2);
}

//+------------------------------------------------------------------+
void CreateBoxes()
 {
   int mHdist = 102, mVdist = 5;
   
   for(int i = 0; i < 12; i++)
     {
         ObjectCreate("m.B"+i, OBJ_BUTTON, 0, 0, 0); 
         ObjectSetInteger(0, "m.B"+i, OBJPROP_XSIZE, 70);       
         ObjectSetInteger(0, "m.B"+i, OBJPROP_YSIZE, 18);       
         ObjectSetString(0, "m.B"+i, OBJPROP_FONT, "Times");
         ObjectSetString(0, "m.B"+i, OBJPROP_TEXT, " ");
         ObjectSetInteger(0, "m.B"+i, OBJPROP_COLOR, mTextCol);
         ObjectSetInteger(0, "m.B"+i, OBJPROP_BGCOLOR, mButtonCol);
         ObjectSetInteger(0, "m.B"+i, OBJPROP_FONTSIZE, 8);       
         ObjectSetInteger(0, "m.B"+i, OBJPROP_SELECTABLE, false);     
         ObjectSet("m.B"+i, OBJPROP_YDISTANCE, mVdist);
         ObjectSet("m.B"+i, OBJPROP_XDISTANCE, 2 + mHdist * i + 2); 
         /*
         if(i > 5)
           {
             ObjectSet("m.B"+i, OBJPROP_YDISTANCE, mVdist + 25);
             ObjectSet("m.B"+i, OBJPROP_XDISTANCE, 2 + mHdist * (i - 6) + 2);
           }
           */
         ObjectSetString(0, "m.B"+i, OBJPROP_TEXT, mInd[i]);
     } // for i

    return; 
 }

//+------------------------------------------------------------------+

 
 
   