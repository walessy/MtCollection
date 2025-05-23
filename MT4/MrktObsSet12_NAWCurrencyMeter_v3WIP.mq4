#include <stdlib.mqh>
//+------------------------------------------------------------------+
//|                                               Currency meter.mq4 |
//+------------------------------------------------------------------+

/*
//These are chartobject names used in strength meter
CURRENCY wnd :z_ddd :c_dd :lu_d_dd :rd_ddd_ddd :idDD :#[CURR 6 char]   wnd | cWnd[Rownumber]
TREND UP	wnd :z_ddd :c_dd :lu_d_dd :rd_ddd_ddd :idDD :#[RowNumber]Trup wnd | cWnd[Rownumber]
TREND UP	wnd :z_ddd :c_dd :lu_d_dd :rd_ddd_ddd :idDD :#[RowNumber]TrDn wnd | cWnd[Rownumber]
LED UP   wnd :z_ddd :c_dd :lu_d_dd :rd_ddd_ddd :idDD :#LedIn|[Rownumber]sLED
LED DOWN wnd :z_ddd :c_dd :lu_d_dd :rd_ddd_ddd :idDD :#[Rownumber]sLED|[OBJECTNAME](ie "Window")
STRENGTH wnd :z_ddd :c_dd :lu_d_dd :rd_ddd_ddd :idDD :#strench| cWnd[Rownumber]	

EXTENDED 4 UseNAWCCIArrow2
NAWCCI   wnd :z_ddd :c_dd :lu_d_dd :rd_ddd_ddd :idDD :#ASCDIR| cWnd[Rownumber]	

arIndiProps[0]=1st integer of lu_ value
arIndiProps[1]=2nd,3rd integer of lu_ value 
arIndiProps[2]=1st,2nd,3rd integer of rd_ value
arIndiProps[3]=4th,5th,6rd integer of rd_ value
arIndiProps[4]=1st integer of z_ value
arIndiProps[5]=1st, 2nd integer c_ value
arIndiProps[6]=OBJPROP_CORNER
arIndiProps[7]=OBJPROP_COLOR
arIndiProps[8]=ObjName
arIndiProps[9]=1st,2nd,3rd integer of z_ value


gia_168[0]=
gia_168[1]=iVert
gia_168[2]=
gia_168[3]=
gia_168[4]=
gia_168[5]=
gia_168[6]=
gia_168[7]=
gia_168[8]=
gia_168[9]= objType


*/
//#include "..\\Include\\Controls\\ComboBox.mqh"
//CComboBox cmdNAWTemplate;

#property indicator_chart_window
string sIndiName=WindowExpertName();
string sIndiName2=WindowExpertName()+"_ChartID_"+IntegerToString(ChartID());

extern bool   CurrenciesWindowBelowTable = true;
extern bool   ShowCurrencies             = true;
extern bool   ShowCurrenciesSorted       = true;
extern bool   ShowSymbolsSorted          = true;
extern color  HandleBackGroundColor      = LightSlateGray;
extern color  DataTableBackGroundColor_1 = LightSteelBlue;
extern color  DataTableBackGroundColor_2 = Lavender;
extern color  CurrencysBackGroundColor   = LightSlateGray;
extern color  HandleTextColor            = White;
extern color  DataTableTextColor         = Black;
extern color  CurrencysTextColor         = White;
extern color  TrendUpArrowsColor         = MediumBlue;
extern color  TrendDownArrowsColor       = Red;
//extern ENUM_TIMEFRAMES tf1               = PERIOD_D1;
int  tf1 = Period();
extern ENUM_BASE_CORNER Corner           = CORNER_RIGHT_UPPER;
extern string DontShowThisPairs          = "";

//This allows us to change displar modes on the fly -16 modes
//Changes when user clicks on title
bool   CurrenciesWindowBelowTable2 = CurrenciesWindowBelowTable;
bool   ShowCurrencies2             = ShowCurrencies;
bool   ShowCurrenciesSorted2       = ShowCurrenciesSorted;
bool   ShowSymbolsSorted2          = ShowSymbolsSorted;

int DisplayModes[][4]={
//   {0, 0, 0, 0},
//   {1, 0, 0, 0},
//   {1, 1, 0, 0},
   {1, 1, 1, 0},
   {1, 1, 1, 1}
//   {0, 1, 0, 0},
//   {0, 1, 1, 0},
//   {0, 1, 1, 1},
//   {0, 0, 1, 0},
//   {0, 0, 1, 1},
//   {0, 0, 0, 1}
};

int DisplayMode;

/*
void SetDisplayMode(){
   CurrenciesWindowBelowTable2   =  DisplayModes[DisplayMode][0];
   ShowCurrencies2               =  DisplayModes[DisplayMode][1];
   ShowCurrenciesSorted2         =  DisplayModes[DisplayMode][2];
   ShowSymbolsSorted2            =  DisplayModes[DisplayMode][3];
   
   varDel("NAW meter symbol_Show");            
   //string n1 = "NAW meter symbol_ShowCurrenciesWindowBelowTable2"; //+DisplayModes[DisplayMode][0];
   //string n2 = "NAW meter symbol_ShowCurrencies2"; //+DisplayModes[DisplayMode][1];
   //string n3 = "NAW meter symbol_ShowCurrenciesSorted2";//+DisplayModes[DisplayMode][2];
   //string n4 = "NAW meter symbol_ShowSymbolsSorted2";//+DisplayModes[DisplayMode][3];
   
   GlobalVariableSet("NAW meter symbol_ShowCurrenciesWindowBelowTable2", DisplayModes[DisplayMode][0]);
   GlobalVariableSet("NAW meter symbol_ShowCurrencies2", DisplayModes[DisplayMode][1]);
   GlobalVariableSet("NAW meter symbol_ShowCurrenciesSorted2", DisplayModes[DisplayMode][2]);
   GlobalVariableSet("NAW meter symbol_ShowSymbolsSorted2", DisplayModes[DisplayMode][3]);
}
*/

void SetDisplayMode (int chsnDisplayMode){   

   if(chsnDisplayMode>ArraySize(DisplayModes)||chsnDisplayMode<0)
   {
      Alert("The display mode is out of ranage");
      return;
   }else{
      string gvn="NAW meter DisplayMode";
      double gvnv=chsnDisplayMode;
      GlobalVariableSet(gvn,gvnv);
      
      DisplayMode=chsnDisplayMode;  
      
      CurrenciesWindowBelowTable2=DisplayModes[chsnDisplayMode][0];
      ShowCurrencies2            =DisplayModes[chsnDisplayMode][1];
      ShowCurrenciesSorted2      =DisplayModes[chsnDisplayMode][2];
      ShowSymbolsSorted2         =DisplayModes[chsnDisplayMode][3];
   }
}

int SingleCurrclick=0;
string CurrPair2ndClick="";

int colBackGround;
int colDataTableBackGroundCol;
int colDataTableBackGroundCol2;
int colCurrencysBackGroundCol;

int colHandleTextCol;
int colDataTableTextCol;
int colCurrencysTextCol;
int colTrendUpArrowsCol;
int colTrendDownArrowsCol;
int colVWAPCrossing;
int iScreenWidth;

string arrValidSymbols[28];  //FZ symbols from market watch 

double lstSymblStrngth[10][4]; //0:strength 1:Market watch Symbol position 2:Strength IsCalculated? 4=Crossredvwap
int gia_168[9];  //temp properties?
int arIndiProps[12];
bool Result=false;
//Led Colors
int arLdClr[] = {255, 17919, 5275647, 65535, 3145645, 65280};

string sObjectName;

//Widths?
int gia_172[21] = {15, 23, 31, 35, 43, 47, 55, 67, 75, 83, 87, 91, 95, 99, 119, 123, 127, 143, 148, 156, 164};  
//font sizes
int iFontSizes[21] = {11, 17, 23, 26, 32, 35, 41, 50, 56, 62, 65, 68, 71, 74, 89, 92, 95, 107, 110, 116, 122};

//int gia_180[21] = {};//4,5, 6, 7, 9, 10, 12, 15, 17, 19, 20, 21, 22, 23, 28, 29, 30, 34, 36, 38, 40};

int gia_184[21] = {-3, -2, -1, -1, -2, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0};

string sCurrAry[8] = {"USD","EUR","GBP","CHF","JPY","CAD","AUD","NZD"};



void init()
{
   IndiGlobalIsLoaded(true);
   int iNoOfValidSymbols;
   string symbolString;
   string sSymbolIndi = "";
   
   iScreenWidth=ChartWidthInPixels();
   colBackGround = HandleBackGroundColor;
   colDataTableBackGroundCol = DataTableBackGroundColor_1;
   colDataTableBackGroundCol2 = DataTableBackGroundColor_2;
   colVWAPCrossing = clrLightGreen;
   colCurrencysBackGroundCol = CurrencysBackGroundColor;
   colHandleTextCol = HandleTextColor;
   colDataTableTextCol = DataTableTextColor;
   colCurrencysTextCol = CurrencysTextColor;
   colTrendUpArrowsCol = TrendUpArrowsColor;
   colTrendDownArrowsCol = TrendDownArrowsColor;
   
   //GlobalVariableSet("NAW meter symbol_ShowCurrenciesWindowBelowTable2", DisplayModes[DisplayMode][0]);
   //GlobalVariableSet("NAW meter symbol_ShowCurrencies2", DisplayModes[DisplayMode][1]);
   //GlobalVariableSet("NAW meter symbol_ShowCurrenciesSorted2", DisplayModes[DisplayMode][2]);
   //GlobalVariableSet("NAW meter symbol_ShowSymbolsSorted2", DisplayModes[DisplayMode][3]);   

   if (GlobalVariableCheck("NAW meter DisplayMode")) {
      DisplayMode = GlobalVariableGet("NAW meter DisplayMode");
      SetDisplayMode(DisplayMode);
   } else {
      DisplayMode=0;
   }
  /*
   if (GlobalVariableCheck("NAW meter symbol_ShowCurrenciesWindowBelowTable2")) {
      CurrenciesWindowBelowTable2 = GlobalVariableGet("NAW meter symbol_ShowCurrenciesWindowBelowTable2");
   } else {
      // The global variable does not exist
   }
   if (GlobalVariableCheck("NAW meter symbol_ShowCurrencies2")) {
       ShowCurrencies2 = GlobalVariableGet("NAW meter symbol_ShowCurrencies2");
   } else {
      // The global variable does not exist
   }
   if (GlobalVariableCheck("NAW meter symbol_ShowCurrenciesSorted2")) {
       ShowCurrenciesSorted2 = GlobalVariableGet("NAW meter symbol_ShowCurrenciesSorted2");
   } else {
      // The global variable does not exist
   }
   if (GlobalVariableCheck("NAW meter symbol_ShowSymbolsSorted2")) {
       ShowSymbolsSorted2 = GlobalVariableGet("NAW meter symbol_ShowSymbolsSorted2");
   } else {
      // The global variable does not exist
   }
   */
   
   iNoOfValidSymbols=0;
   for (int index = 0; index < SymbolsTotal(true) ; index++)
   {
      symbolString = SymbolName(index,true);
      //if (MarketInfo(symbolString, MODE_MARGINCALCMODE) == 0.0) //ie  forex
      //{
         arrValidSymbols[index]=symbolString;
         iNoOfValidSymbols++;
      //}
      
   } 

   //Redimension the array  
   ArrayResize(arrValidSymbols, iNoOfValidSymbols);
   
   if (UninitializeReason() != REASON_CHARTCHANGE)
   {
      if (sSymbolIndi != "")
      {
         sSymbolIndi = "Some currency pairs are not available\n for calculating the indices.\n" + sSymbolIndi;
         sSymbolIndi = sSymbolIndi + "\nCalculation formula will be changed.";
         Alert(sSymbolIndi);
      }
   }
   
}

void deinit()
{

   IndiGlobalIsLoaded(false);
   CleanChart();
   
   DeletObject("Header");
   DeletObject("Window");
   DeletObject("Curs");
   DeletObject("Pows");
}

bool IsOrder(){
   for (int orderpos=OrdersTotal()-1; orderpos >= 0; orderpos--)
   {
      if (OrderSelect(orderpos, SELECT_BY_POS, MODE_TRADES))
      {
           if (OrderSymbol() == Symbol())
           {   
               return true;
           }

      }
   }
   return false;
}

void OnTimer()
  {
  
   bool IsOrder=false;
   int li_20;
   int li_28;
   
   int color_32;
   int color_36;
   int iDsplySymblIndx;
   double lda_44[8][2];
   string sLedIndx;
   int iDrawX;
   int iDrawY;
   
   varDel("NAW meter symbol_");            
   string n = "NAW meter symbol_"+Symbol();
   
   GlobalVariableSet(n,0);
           
   double ld_96;
   int iVSpc = 0;    //
   int iVSpc2 = 14;  //Initial Ypos
   
   //string ls_48 = "Curs";
   //string ls_unused_56 = "Pows";

 
   
   switch (Corner){
 
   case 0:
      iDrawX=4;
      iDrawY=0;
      break;
   case 2:
      iDrawX=4;
      iDrawY=0;
      break;
   case 1:
      iDrawX=0;//iScreenWidth-400;
      iDrawY=5;
      break;
   case 3:
      iDrawX=0;//iScreenWidth-200;
      iDrawY=50;
      break;
   
   default:
      iDrawX=4;
      iDrawY=20;
   }
   //DISPLAY TITLE
   if (ShowCurrencies2 && (!CurrenciesWindowBelowTable2))
      {
         //Create Display "window", no parent, 
         CreateChartObject("Window", 
                           "", 
                           30, 
                           iDrawX, 
                           iDrawY, 
                           18, 
                           1, 
                           0,
                           Corner, 
                           colBackGround, 
                           0, 
                           0, 
                           0
                          );
         //Writes Text Object in display window
         CreateText("hdTxt", 
                     "Window", 
                     69, 
                     "NAW Curr Meter "+Period(), 
                     "Courier new", 
                     colHandleTextCol, 
                     0, 
                     34, 
                     Corner, 
                     0, 
                     11
                   );
      }
   else
      {
         //Just creates a black rectangle baccground 
         CreateChartObject("Window", //Chart Object name
                           "", //Blank parent name
                           30, //Chart object type
                           iDrawX,  //Horizontal
                           iDrawY, //vertical
                           11, //Width
                           1,  //Height
                           0, //?
                           Corner, //corner 
                           colBackGround,  //color
                           0,  //?
                           0,  //sub window
                           0   //?
         );
         //Writes Text Object in display window aboe
         CreateText("hdTxt", //Objectname
                     "Window", //Parent Window
                     0, 
                     "NAW Curr Meter "+Period(), 
                     "Courier new", 
                     colHandleTextCol, //Font  Color
                     0, //Shift text right by tabs?
                     5, //Shift text right bt pixels?
                     Corner,
                     0, //?
                     11  //Font Size
         );
         //CreateChartObject("cmboTmplt", "Window", 30, iDrawX, iDrawY+14, 18, 1, 0,Corner, colBackGround, 0, 0, 0);
         
      }
   
 
   //vertical initial additional y for firs and subsquent rows 
   iVSpc = 2;  
   
   ArrayInitialize(lstSymblStrngth, 0);
   int NoOfSymbolsProcessed = CalculateSymbolStrengths();  //returns valid symbols
   if (ShowSymbolsSorted2) ArraySort(lstSymblStrngth, WHOLE_ARRAY, 0, MODE_DESCEND);
   
   
   int rowCounter = 0;
   string sLoadedSymbols = "";
   
   //Display symbol list and strentgh
   for (int index = 0; index < NoOfSymbolsProcessed; index++)
   {
      
      iDsplySymblIndx = lstSymblStrngth[index][1];  //Marketwatch position
      
      if (StringFind(DontShowThisPairs,arrValidSymbols[index]) < 0)
      {
      
         //1.DRAW BACKGROUND FOR ROW
         //alternate row background color

         
         if (rowCounter % 2 != 0) color_36 = colDataTableBackGroundCol; else color_36 = colDataTableBackGroundCol2;
 
         DeleteObject("cWnd" + index);
         CreateChartObject("cWnd" + index, 
                           "Window", 
                           30, 
                           0, 
                           iVSpc2 + iVSpc, //
                           11, 
                           2,  
                           0, 
                           Corner, 
                           color_36, 
                           0, 
                           0, 
                           0
          );

         //2. Displays the symbols after loading
         if (iDsplySymblIndx > -1) {
            sLoadedSymbols = StringSubstr(arrValidSymbols[iDsplySymblIndx], 0);
         } 
         else 
         {
            sLoadedSymbols = "LOADING";
         }
         //Print(sLoadedSymbols);
         CreateText(sLoadedSymbols + "wnd", 
                     "cWnd" + index, 
                     69, 
                     sLoadedSymbols, 
                     "Courier new", 
                     colDataTableTextCol, 
                     0, 
                     4, 
                     Corner, 
                     0, 
                     11
          );

         //3 DISPLAY LED AND 
         if (iDsplySymblIndx >= 0) {
            
            DeleteObject(index + "sLED");
            
            if (lstSymblStrngth[index][0] < 0.0) {
               
               //Negative Strength
               li_28 = 0;
               li_20 = -14;
               color_32 = colTrendDownArrowsCol;
               
               CreateLed(
                        index + "sLED", //ObjName
                        "Window",        //Parent
                        li_20 + 75,     //X
                        iVSpc2 + iVSpc, //Y 
                        2,  //Width 
                        0,    //font size?
                        2,    //Type
                        0,    //?
                        100,  //?
                        -lstSymblStrngth[index][0],  ////Strength
                        color_32,   //Red Led Color 
                        Corner, 
                        color_36    //Led Background Color
               );
               CreateText(index + "TrDn", "cWnd" + index, 69, StringSetChar("", 0, 'Ú'), "Wingdings", color_32, 0, 99, -2, 0, 14);
               if (lstSymblStrngth[index][0] < -99.99) CreateText("strench", "cWnd" + index, 69, "-100", "Courier new", colDataTableTextCol, 0, 122, -1, 0, 10);
               else CreateText("strench", "cWnd" + index, 69, DoubleToStr(lstSymblStrngth[index][0], 1), "Courier new", colDataTableTextCol, 0, 122, -1, 0, 10);
            
            } else {
            
               //Positive Strength
               li_28 = 0;
               li_20 = 14;
               color_32 = colTrendUpArrowsCol;
               CreateLed(
                        index + "sLED", 
                        "Window", 
                        li_20 + 75, 
                        iVSpc2 + iVSpc, 
                        2, 
                        0, 
                        2, 
                        0, 
                        100, 
                        lstSymblStrngth[index][0], 
                        color_32, 
                        Corner, 
                        color_36
               );
               CreateText(index + "TrUp", "cWnd" + index, 69, StringSetChar("", 0, 'Ù'), "Wingdings", color_32, 0, 65, -3, 0, 14);
               if (lstSymblStrngth[index][0] > 99.99) CreateText("strench", "cWnd" + index, 69, "100.0", "Courier new", colDataTableTextCol, 0, 122, -1, 0, 10);
               else CreateText("strench", "cWnd" + index, 69, DoubleToStr(lstSymblStrngth[index][0], 1), "Courier new", colDataTableTextCol, 0, 130, -1, 0, 10);
            
            }
         }
         
         iVSpc += 16;
         rowCounter++;
      }
   }
   
//------------------------------------------------
   
   if (ShowCurrencies2)
   {
      if (!CurrenciesWindowBelowTable2)
         {
            li_20 = iVSpc;
            CreateChartObject("Curs", "Window", 30, 166, 16, 7, 9, 0, colCurrencysBackGroundCol, colCurrencysBackGroundCol, 0, 0, 0);
            sLedIndx = "Led" + index;
            //li_unused_92 = gia_208[index];
            iVSpc = 0;
            for (NoOfSymbolsProcessed = 0; NoOfSymbolsProcessed < 8; NoOfSymbolsProcessed++)
               {
                  ld_96 = f0_5(sCurrAry[NoOfSymbolsProcessed]);
                  lda_44[NoOfSymbolsProcessed][0] = ld_96;
                  lda_44[NoOfSymbolsProcessed][1] = NoOfSymbolsProcessed;
               }
               
            if (ShowCurrenciesSorted2) 
               ArraySort(lda_44, WHOLE_ARRAY, 0, MODE_DESCEND);
            else 
               ArraySort(lda_44, WHOLE_ARRAY, 1, MODE_DESCEND);
            
            for (NoOfSymbolsProcessed = 0; NoOfSymbolsProcessed < 8; NoOfSymbolsProcessed++)
               {
                  ld_96 = lda_44[NoOfSymbolsProcessed][0];
                  iDsplySymblIndx = lda_44[NoOfSymbolsProcessed][1];
                  CreateText("CuCur" + NoOfSymbolsProcessed, "Curs", 69, sCurrAry[iDsplySymblIndx], "Courier new", colCurrencysTextCol, 0, 5, iVSpc + 0, 0, 11);
                  CreateText("CuDig" + NoOfSymbolsProcessed, "Curs", 69, DoubleToStr(lda_44[NoOfSymbolsProcessed][0], 1), "Courier new", colCurrencysTextCol, 0, 78, iVSpc + 1, 0, 10);
                  CreateLed("sLED" + NoOfSymbolsProcessed, "Curs", 32, iVSpc + 2, 3, 0, 0, 0, 10, ld_96, -1, colCurrencysBackGroundCol, colCurrencysBackGroundCol);
                  iVSpc += 14;
               }
         }
      else
         {
            CreateChartObject("Curs", "Window", 30, 0, iVSpc + 14, 11, 6, 0, colCurrencysBackGroundCol, colCurrencysBackGroundCol, 0, 0, 0);
            sLedIndx = "Led" + index;
            //li_unused_92 = gia_208[index];
            iVSpc = 0;
            for (NoOfSymbolsProcessed = 0; NoOfSymbolsProcessed < 8; NoOfSymbolsProcessed++)
               {
                  ld_96 = f0_5(sCurrAry[NoOfSymbolsProcessed]);
                  lda_44[NoOfSymbolsProcessed][0] = ld_96;
                  lda_44[NoOfSymbolsProcessed][1] = NoOfSymbolsProcessed;
               }
            if (ShowCurrenciesSorted2) 
               ArraySort(lda_44, WHOLE_ARRAY, 0, MODE_DESCEND);
            else 
               ArraySort(lda_44, WHOLE_ARRAY, 1, MODE_DESCEND);            
               
            for (NoOfSymbolsProcessed = 0; NoOfSymbolsProcessed < 8; NoOfSymbolsProcessed++)
               {
                  ld_96 = lda_44[NoOfSymbolsProcessed][0];
                  iDsplySymblIndx = lda_44[NoOfSymbolsProcessed][1];
                  CreateText("CuCur" + NoOfSymbolsProcessed, "Curs", 69, sCurrAry[iDsplySymblIndx], "Courier new", colCurrencysTextCol, 0, iVSpc + 3, 76, 0, 12, 0, 0, 90);
                  CreateLed(
                     "sLED" + NoOfSymbolsProcessed, 
                     "Curs", 
                     iVSpc + 1,
                     0, 
                     2, 
                     1, 
                     1, 
                     0, 
                     10, 
                     ld_96, 
                     -1, 
                     colCurrencysBackGroundCol, 
                     colCurrencysBackGroundCol
                  );
                  iVSpc += 20;
               }
         }
   }
   
   WindowRedraw();
  }
void start()
{
   EventSetMillisecondTimer(500);
   
}

int CalculateSymbolStrengths()
{
   double ihigh;
   double ilow;
   double iopen;
   double iclose;
   double point;
   double dbFllCndlPonts;
   double dbStrngth;
   
   
   string symbol = "";
   int arr_size = ArraySize(arrValidSymbols);
   
   ArrayResize(lstSymblStrngth, arr_size);
   
   for (int index = 0; index < arr_size; index++)
   {
      symbol = arrValidSymbols[index];
      point = MarketInfo(symbol, MODE_POINT);
      
      if (point == 0.0) {
         
         init(); 
         lstSymblStrngth[index][1] = -1;} 
      
      else {
         
         ihigh = iHigh(symbol, tf1, 0);
         ilow = iLow(symbol, tf1, 0);
         iopen = iOpen(symbol, tf1, 0);
         iclose = iClose(symbol, tf1, 0);
         
         if (iopen > iclose) {
            
            dbFllCndlPonts = (ihigh - ilow) * point;  //bearish full 
            
            if (dbFllCndlPonts == 0.0) {
               init();
               lstSymblStrngth[index][1] = -1;  //no change
               continue;
            }
            
            dbStrngth = -100.0 * ((ihigh - iclose) / dbFllCndlPonts * point);
         
         } else {
         
            dbFllCndlPonts = (ihigh - ilow) * point; //bullish full
            
            if (dbFllCndlPonts == 0.0) {
               init(); 
               lstSymblStrngth[index][1] = -1; //no change
               continue;
            }
            
            
            dbStrngth = 100.0 * ((iclose - ilow) / dbFllCndlPonts * point);
         
         }
         
         lstSymblStrngth[index][0] = dbStrngth; //strength
         lstSymblStrngth[index][1] = index; //Symbol position
         lstSymblStrngth[index][2] = 1;     //Strength IsCalculated?
      }
   }
   
   return (arr_size);
}

//---------------------------------------

int f0_6(
            string sObjName, 
            int iObjType, 
            int iLu1, 
            int iLu2, 
            int iWidth = 1, 
            int ai_24 = 1, 
            int ai_28 = 0, 
            int z1_ = 0, 
            int ai_36 = 0, 
            int iCorner = 0, 
            int iSubWindow = 0, 
            string sPrntObj = "", 
            int iColor = 16777215 //White
)
{
   int z;
   int li_80;
   string ls_112;
   int iXPos;
   
   if (iCorner != 0 && iCorner != 1) iCorner = 0;
   if (iSubWindow < 0) iSubWindow = 0;
   
   if (sPrntObj != "")
      {
      if (FoundObjName(sPrntObj))
         {
            iLu1 += arIndiProps[0];  //+1st integer of lu_ value
            iLu2 += arIndiProps[1];  //+lu value 2/3 digits
            iCorner = arIndiProps[6]; //Chart Corner
            iSubWindow = arIndiProps[8]; //Object Name
            z1_ += arIndiProps[4];  //+1st integer of z_ value
            z = arIndiProps[9] + 1; //1st,2nd,3rd integer of z_ value
         }
      }
   
   //Vertical
   gia_168[0] = iLu1;
   //Horizonntal?
   gia_168[1] = iLu2;
   
   //Width
   gia_168[2] = iLu1 + iWidth * gia_172[ai_28] - 1;
   //Height
   gia_168[3] = iLu2 + ai_24 * gia_172[ai_28] - (ai_24 * 2 - 1);
   
   //Z Order?
   gia_168[6] = z1_;
   
   gia_168[9] = iObjType;
   
   int li_84 = 1;
   int li_88 = gia_172[ai_28] - 2;
   
   int iFontSize = iFontSizes[ai_28];
   string sObjNm = "";
   string sMsgItem = "g";
   
   if (iWidth == 1 && ai_24 == 1) {
   
      gia_168[4] = 0;
      gia_168[5] = 0;
      gia_168[7] = z;
      gia_168[8] = z;
      
      sObjNm = FetchObjectName(sObjName, gia_168, sPrntObj);
      
      
 /*
 
   bool f0_4(  string sObjNm, 
            int x, 
            int y, 
            string a_text_16 = "c", 
            int a_fontsize_24 = 14, 
            int iCorner = 0, 
            color a_color_32 = 0, 
            int window = 0, 
            string a_fontname_40 = "Webdings", 
            int a_angle_48 = false)
 */     
      
      //if (!
         Result=f0_4(
                  sObjNm, 
                  gia_168[0], 
                  gia_168[1] + gia_184[ai_28], 
                  sMsgItem, 
                  iFontSize, 
                  iCorner, 
                  iColor, 
                  iSubWindow);
                 //) ;
                 //Print(GetLastError());
      
      
      if (ai_36 == iColor) return (0);
      
      gia_168[4] = 0;
      gia_168[5] = 1;
      gia_168[7] = z;
      gia_168[8] = z + 1;
      
      sObjNm = FetchObjectName(sObjName, gia_168, sPrntObj);
      
      //if (!
            Result=f0_4(sObjNm, 
                  gia_168[0] + li_84, 
                  gia_168[1] + li_84 + gia_184[ai_28], 
                  sMsgItem, 
                  iFontSize - li_84, 
                  iCorner, 
                  ai_36, 
                  iSubWindow);
      //   ) Print(GetLastError());
   
   } else {
   
      for (int li_64 = 1; li_64 < iWidth; li_64++) sMsgItem = sMsgItem + "g";
      
      for (int count_68 = 0; count_68 < ai_24; count_68++) {
         gia_168[4] = li_80 / 10;
         gia_168[5] = li_80 % 10;
         gia_168[7] = z;
         gia_168[8] = z;
         sObjNm = FetchObjectName(sObjName, gia_168, sPrntObj);
         //if (!
            Result=f0_4(sObjNm, gia_168[0], gia_168[1] + li_88 * count_68 + gia_184[ai_28], sMsgItem, iFontSize, iCorner, iColor, iSubWindow);
          //) Print(GetLastError());
         li_80++;
      }
      
      if (ai_36 == iColor) return (0);
      
      gia_168[7] = z;
      gia_168[8] = z + 1;
      
      for (count_68 = 0; count_68 < ai_24; count_68++) {
         if (iWidth > 1) {
            gia_168[4] = li_80 / 10;
            gia_168[5] = li_80 % 10;
            sObjNm = FetchObjectName(sObjName, gia_168, sPrntObj);
            ls_112 = "g";
            iXPos = iWidth / 10 + 1;
            for (int count_72 = 0; count_72 < iXPos; count_72++) ls_112 = ls_112 + "g";
            //if (!
               Result=f0_4(sObjNm, gia_168[0] + li_84, gia_168[1] + (li_88 * count_68 - count_68) + gia_184[ai_28] + ai_24, ls_112, iFontSize - li_84, iCorner, ai_36, iSubWindow);
            //) Print(GetLastError());
            li_80++;
         }
         
         gia_168[4] = li_80 / 10;
         gia_168[5] = li_80 % 10;
         
         sObjNm = FetchObjectName(sObjName, gia_168, sPrntObj);
         
         //if (!
            Result=f0_4(sObjNm, gia_168[0] + (iWidth * 2 - li_84), gia_168[1] + (li_88 * count_68 - count_68) + gia_184[ai_28] + ai_24, sMsgItem, iFontSize - li_84, iCorner, ai_36, iSubWindow);
          //) 
          //Print(GetLastError());
         
         li_80++;
      }
      
      if (ai_24 < 2) return (0);
      
      for (count_72 = 0; count_72 <= ai_24 / li_88; count_72++)
      {
      
         gia_168[4] = li_80 / 10;
         gia_168[5] = li_80 % 10;
         sObjNm = FetchObjectName(sObjName, gia_168, sPrntObj);
         //if (!
         Result=f0_4(sObjNm, gia_168[0] + iWidth * 2 - li_84, gia_168[1] + li_84 + gia_184[ai_28] + (li_88 - 1) * count_72, sMsgItem, iFontSize - li_84, iCorner, ai_36, iSubWindow);
         //) 
         //Print(GetLastError());
         li_80++;
         
         if (iWidth > 1) {
            gia_168[4] = li_80 / 10;
            gia_168[5] = li_80 % 10;
            sObjNm = FetchObjectName(sObjName, gia_168, sPrntObj);
            ls_112 = "g";
            iXPos = iWidth / 10 + 1;
            for (int count_76 = 0; count_76 < iXPos; count_76++) ls_112 = ls_112 + "g";
            //if (!
            Result=f0_4(sObjNm, gia_168[0] + li_84, gia_168[1] + li_84 + gia_184[ai_28] + (li_88 - 1) * count_72, ls_112, iFontSize - li_84, iCorner, ai_36, iSubWindow);
            //) Print(GetLastError());
            li_80++;
         }
      }
   }
   return (0);
}

//----------------------------------------------

int CreateText(string sObjctNm, string sParentObject, int iObjType, string sTxtToDsply, string sFntFc, int iFontColor, bool ai_40 = TRUE, 
               int ai_44 = 0, int iColor = 0, int ai_52 = 0, int iFontSize = 0, int iCorner = 0, int ai_64 = 0, int ai_68 = 0) {
   
   int li_unused_108;
   double ld_112;
   double ld_120;
   int lia_72[19] = {10, 14, 20, 26, 32, 35, 41, 50, 56, 62, 65, 68, 71, 74, 77, 86, 89, 92, 95};
   int lia_76[7] = {0, 3, 2, 3, 2, 3, 4};
   int li_80 = 0;
   int li_84 = 0;
   int li_88 = 0;
   int li_unused_92 = 0;
   int li_96 = 0;
   int li_100 = 0;
   int li_unused_104 = 0;
   
   if (sParentObject != "")
   {
      if (FoundObjName(sParentObject))
      {
         iCorner = arIndiProps[6]; //OBJPROP_CORNER
         ai_64 = arIndiProps[8]; //ObjName
         li_80 = arIndiProps[0]; //1st integer of lu_ value
         li_84 = arIndiProps[1]; //2nd,3rd integer of lu_ value 
         li_88 = arIndiProps[2]; //1st,2nd,3rd integer of rd_ value
         li_96 += arIndiProps[4] + 1; //1st integer of z_ value
         li_100 = arIndiProps[9] + 1; //1st,2nd,3rd integer of z_ value
         //iCorner = arIndiProps[6]; //OBJPROP_CORNER
         ai_64 = arIndiProps[8]; //ObjName
         li_unused_108 = arIndiProps[5];//1st, 2nd integer c_ value
         
         if (iFontSize == 0) iFontSize = lia_72[ai_52];
         
         if (ai_40) {
            ld_112 = StringLen(sTxtToDsply) * iFontSize / 1.6;
            ld_120 = li_88 - li_80;
            ai_44 = li_80 + (ld_120 - ld_112) / 2.0 + ai_44;
            iColor = li_84 + lia_76[ai_52];
            if (sFntFc == "Webdings") {
               if (ai_52 == 0) {
                  iFontSize = 11;
                  ai_44 = li_80;
                  iColor = li_84 - 3;
               } else {
                  iFontSize = 20;
                  ai_44 = li_80 - 2;
                  iColor = li_84 - 4;
               }
            } else {
               if (sFntFc == "Wingdings") {
                  iFontSize = 11;
                  ai_44 = li_80 + 1;
                  iColor = li_84 + 2;
               }
            }
         } else {
            ai_44 += li_80;
            iColor += li_84;
         }
      }
   }
   
   gia_168[0] = ai_44;
   gia_168[1] = iColor;
   gia_168[6] = li_96;

   gia_168[7] = li_100;
   gia_168[8] = li_100;

   gia_168[9] = iObjType;
   
   sObjctNm = FetchObjectName(sObjctNm, gia_168, sParentObject);
   
   if (!f0_4(sObjctNm, ai_44, iColor, sTxtToDsply, iFontSize, iCorner, iFontColor, ai_64, sFntFc, ai_68)) return (GetLastError());
   
   return (0);
}

int CreateLed(
            string iObjNme, 
            string iObjPntNme, 
            int iHori, 
            int iVert,
            int iParamWidth = 1, 
            int ai_28 = 1, 
            int iLedTyp = 0, 
            double ad_36 = 0.0, 
            double ad_44 = 1.0, //
            double dSymblStrngth = 1.0, 
            int iLedColor = -1, 
            int iCorner = -1, 
            int iLedBckGrndCol = -1)
{

   int iWidth,iHeight,li_88,z1,li_96,li_100,li_104,li_112,li_116,li_188,li_192;
   
   if (iObjPntNme == "")
   {
      if (iCorner < 0) iCorner = 0;
      if (iLedBckGrndCol < 0) iLedBckGrndCol = 16777215;
   }
   else
   {
      if (!FoundObjName(iObjPntNme)) return (-1);
      if (iCorner < 0) iCorner = 0;
      if (iLedBckGrndCol < 0) iLedBckGrndCol = 16777215;
      z1 = arIndiProps[4] + 1;  //1st integer of z_ value
   }
   
   if (ai_28 > 2) ai_28 = 2;
   if (iParamWidth  > 8) iParamWidth  = 8;
   if (iLedTyp > 3) iLedTyp = 3;
   if (iLedTyp < 0) iLedTyp = 0;
   
  
   switch (iLedTyp) {
   case 0:  //Horizontal Led
      iWidth = iParamWidth ;
      iHeight = 1;
      break;
   case 1:  //
      iWidth = 1;
      iHeight = iParamWidth ;
      break;
   case 2:
      iWidth = iParamWidth ;
      iHeight = 1;
      break;
   case 3:
      iWidth = 1;
      iHeight = iParamWidth ;
   }

   CreateChartObject(iObjNme, iObjPntNme, 30, iHori, iVert, iWidth, iHeight, ai_28, iCorner, iLedBckGrndCol, z1);
   
   FoundObjName(iObjNme);
   int li_120 = arIndiProps[6]; //cORNER

   switch (iLedTyp) {
   case 0:  //currency pair strength
      
      switch (ai_28) {
      case 0:
  
         //if (li_120 != 1) break;
         li_96 = arIndiProps[2] - arIndiProps[0] - 1;
         li_100 = 17;
         li_104 = 9;
         li_112 = 5 * iWidth;
         li_116 = 180;
         break;
      case 1:

         if (li_120 != 1) break;
         li_96 = arIndiProps[2] - arIndiProps[0] - 1;
         li_100 = 17;
         li_104 = 9;
         li_112 = iWidth * 8 - li_88;
         li_116 = 180;
         break;
      case 2:

         if (li_120 != 1) break;
         li_96 = arIndiProps[2] - arIndiProps[0] - 1;
         li_100 = 28;
         li_104 = 15;
         li_112 = 5 * iWidth;
         li_116 = 180;
      }
      break;
   
   case 1:  //CURR STRENGH
      switch (ai_28) {
      case 0:
         if (iHeight > 6) li_88++;
         if (li_120 == 0) {
            li_96 = -3;
            li_100 = arIndiProps[3] - arIndiProps[1];
            li_104 = 9;
            li_112 = 5 * iHeight - li_88;
            li_116 = 90;
         }
         if (li_120 != 1) break;
         li_96 = -3;
         li_100 = arIndiProps[3] - arIndiProps[1] - 1;
         li_104 = 9;
         li_112 = 5 * iHeight - li_88;
         li_116 = 270;
         break;
      case 1:
         if (li_120 == 0) {
            li_96 = -3;
            li_100 = arIndiProps[3] - arIndiProps[1];
            li_104 = 9;
            li_112 = 7 * iHeight - 1;
            li_116 = 90;
         }
         if (li_120 != 1) break;
         li_96 = -3;
         li_100 = arIndiProps[3] - arIndiProps[1] - 1;
         li_104 = 9;
         li_112 = 7 * iHeight - 1;
         li_116 = 270;
         break;
      case 2:
         if (li_120 == 0) {
            li_96 = -6;
            li_100 = arIndiProps[3] - arIndiProps[1];
            li_104 = 14;
            li_112 = 7 * iHeight - (iHeight + iHeight / 4);
            li_116 = 90;
         }
         if (li_120 != 1) break;
         li_96 = -6;
         li_100 = arIndiProps[3] - arIndiProps[1] + 1;
         li_104 = 14;
         li_112 = 7 * iHeight - (iHeight + iHeight / 4);
         li_116 = 270;
      }
      break;
     
   case 2:
      switch (ai_28) {
      case 0:
         if (li_120 == 1) {
            li_96 = 2;
            li_100 = -2;
            li_104 = 9;
            li_112 = 5 * iWidth - 1;
            li_116 = 0;
         }
         if (li_120 != 0) break;
         li_96 = arIndiProps[2] - arIndiProps[0];
         li_100 = 17;
         li_104 = 9;
         li_112 = 5 * iWidth - 1;
         li_116 = 180;
         break;
      case 1:
         if (li_120 == 1) {
            li_96 = 2;
            li_100 = -2;
            li_104 = 9;
            li_112 = iWidth * 8 - li_88;
            li_116 = 0;
         }
         if (li_120 != 0) break;
         li_96 = arIndiProps[2] - arIndiProps[0];
         li_100 = 17;
         li_104 = 9;
         li_112 = iWidth * 8 - li_88;
         li_116 = 180;
         break;
      case 2:
         if (li_120 == 1) {
            li_96 = 1;
            li_100 = -5;
            li_104 = 15;
            li_112 = 5 * iWidth;
            li_116 = 0;
         }
         if (li_120 != 0) break;
         li_96 = arIndiProps[2] - arIndiProps[0] - 1;
         li_100 = 28;
         li_104 = 15;
         li_112 = 5 * iWidth;
         li_116 = 180;
      }
      break;
      

   }
   
   double ld_172 = (ad_44 - ad_36) / MathAbs(li_112);
   string ls_180 = "";
   for (int count_72 = 0; count_72 < li_112; count_72++) {
      if (dSymblStrngth <= ad_36 + ld_172 * count_72) break;
      ls_180 = ls_180 + "|";
   }
   if (iLedColor < 0) {
      li_188 = ArraySize(arLdClr) - 1;
      li_192 = count_72 / (li_112 / li_188);
      if (li_192 > li_188) li_192 = li_188;
      iLedColor = arLdClr[li_192];
   }
   CreateText("LedIn", iObjNme, 69, ls_180, "Arial black", iLedColor, 0, li_96, li_100, 0, li_104, 0, 0, li_116);
   if (ai_28 > 0) {
      if (iLedTyp == 1 || iLedTyp == 3) li_96 += ai_28 - 1 + 8;
      else li_100 += 8;
      CreateText("LedIn", iObjNme, 69, ls_180, "Arial black", iLedColor, 0, li_96, li_100, 0, li_104, 0, 0, li_116);
   }
   return (0);
}

//------------------------------------------------------------------
//Format
//wnd:z_XXXXXXYYYYYYZZZZZZ:c_XXXXXX:lu_XXXXXX_XXXXXX:rd_XXXXXX_XXXXXX:idXXXXXXYYYYYY:#XXXXXX|XXXXXX
string FetchObjectName(string as_0, int &aia_8[10], string sObjectType = "chart")
{
   //string ls_unused_20 = "";
   //if (as_12 == "") as_12 = "chart";
   return (StringConcatenate("wnd:", 
                             "z_", 
                             aia_8[6], 
                             StringSetChar("", 0, aia_8[7] + 97), 
                             StringSetChar("", 0, aia_8[8] + 97), 
                             ":", 
                             "c_", 
                             aia_8[9], 
                             ":",
                             "lu_", 
                             aia_8[0], 
                             "_", 
                             aia_8[1], 
                             ":", 
                             "rd_", 
                             aia_8[2], 
                             "_", 
                             aia_8[3], 
                             ":", 
                             "id", 
                             aia_8[4], 
                             "", 
                             aia_8[5], 
                             ":", 
                             "#", 
                             as_0, 
                             "|", 
                             sObjectType)
            );
}

//------------------------------------------------------------------

int CreateChartObject(  string sObjNm, string sPrntObj, int sObjTyp, 
                        int iHor = 0, int iVert = 0, int iWidth = 1, 
                        int iHeight = 1, int ai_36 = 1, int iCorner = 0, 
                        int iColor = 16777215, int ai_48 = 0, int iSubWindow = 0, 
                        int ai_56 = 0) 
{
   
   string ls_60,ls_68;
   
   switch (sObjTyp)
   {
   case 30:
 
      f0_6(sObjNm, sObjTyp, iHor, iVert, iWidth, iHeight, ai_36, ai_48, iColor, iSubWindow, ai_56, sPrntObj, iCorner);
      break;

   default:
      return (0);
   }
   return (1);
}

//-------------------------------------

int FoundObjName(string sObjName)
{
   
   int iSubSrtPos,iCharPos ,iSubSubSrtPos;
   string strChartObjectName; //name_20;
 
   //Search all chart objects of all specified types, in this case all
   //https://docs.mql4.com/objects/objectstotal
   //https://docs.mql4.com/objects/objectname
   //https://docs.mql4.com/constants/objectconstants/enum_object
   for (int obj_index = ObjectsTotal(); obj_index >= 0; obj_index--)
   {
      //Get the name of chart object
      strChartObjectName = ObjectName(obj_index);
      
      //Get location of find string in search string
      iCharPos = StringFind(strChartObjectName, sObjName);
      
      //Found the object - now getting string representation
      if (iCharPos  >= 0)
      {
         
         if (iCharPos != StringFind(strChartObjectName, "|") + 1)
         {
            //Look for "z_"
            iSubSrtPos = StringFind(strChartObjectName, "z_") + 2;
            arIndiProps[4] = StrToInteger(StringSubstr(strChartObjectName, iSubSrtPos, 1));
            arIndiProps[9] = StrToInteger(StringGetChar(StringSubstr(strChartObjectName, iSubSrtPos + 3, 1), 0));
            
            //Look for ":c_"
            iSubSrtPos = StringFind(strChartObjectName, ":c_") + 3;
            arIndiProps[5] = StrToInteger(StringSubstr(strChartObjectName, iSubSrtPos, 2));
            
            //Look for "lu_"
            iSubSrtPos = StringFind(strChartObjectName, "lu_") + 3;
            iSubSubSrtPos = StringFind(strChartObjectName, "_", iSubSrtPos);     
            arIndiProps[0] = StrToInteger(StringSubstr(strChartObjectName, iSubSrtPos, iSubSubSrtPos - iSubSrtPos));
            
            
            //Look for ":"
            iSubSrtPos = StringFind(strChartObjectName, ":", iSubSubSrtPos);
            arIndiProps[1] = StrToInteger(StringSubstr(strChartObjectName, iSubSubSrtPos + 1, iSubSrtPos - iSubSubSrtPos + 1));
            
            //Look for "rd_"
            iSubSrtPos = StringFind(strChartObjectName, "rd_") + 3;
            iSubSubSrtPos = StringFind(strChartObjectName, "_", iSubSrtPos);
            arIndiProps[2] = StrToInteger(StringSubstr(strChartObjectName, iSubSrtPos, iSubSubSrtPos - iSubSrtPos));
            
            //Look for ":"
            iSubSrtPos = StringFind(strChartObjectName, ":", iSubSubSrtPos);
            arIndiProps[3] = StrToInteger(StringSubstr(strChartObjectName, iSubSubSrtPos + 1, iSubSrtPos - iSubSubSrtPos + 1));
            
            
            arIndiProps[6] = ObjectGet(strChartObjectName, OBJPROP_CORNER);
            arIndiProps[7] = ObjectGet(strChartObjectName, OBJPROP_COLOR);
            arIndiProps[8] = ObjectFind(strChartObjectName);
            
            //Get Nanme 
            sObjectName = StringSubstr(strChartObjectName, StringFind(strChartObjectName, "|") + 1);
            
            return (1);
         }
      }

   }
   //Clean up
   ArrayInitialize(arIndiProps, -1);
   iSubSrtPos = 0;
   
   return (0);
}

//-----------------------------

void DeletObject(string as_0)
{
   int li_12,li_16,li_64,li_68;
   string name_28,ls_44,ls_72;
   string lsa_52[5000];
   string lsa_56[5000];
   string ls_80;
   int li_60 = GetTickCount();
   
   for (int li_8 = ObjectsTotal() - 1; li_8 >= 0; li_8--)
   {
      name_28 = ObjectName(li_8);
      if (StringFind(name_28, "wnd:") >= 0) {
         if (StringFind(name_28, "#" + as_0) > 0) {ObjectDelete(name_28);continue;}
         if (StringFind(name_28, "|" + as_0) > 0)
            {
               li_64 = StringFind(name_28, "#") + 1;
               li_68 = StringFind(name_28, "|" + as_0) - li_64;
               lsa_52[li_12] = StringSubstr(name_28, li_64, li_68);
               li_12++;
               ObjectDelete(name_28);
               continue;
            }
         lsa_56[li_16] = name_28;
         li_16++;
      }
   }
   ArrayResize(lsa_56, li_16);
   for (li_8 = 0; li_8 < li_12; li_8++) {
      ls_72 = "|" + lsa_52[li_8];
      for (int index_20 = 0; index_20 < li_16; index_20++) {
         name_28 = lsa_56[index_20];
         if (name_28 != "") {
            if (StringFind(name_28, ls_72) >= 0) {
               li_64 = StringFind(name_28, "#") + 1;
               li_68 = StringFind(name_28, ls_72) - li_64;
               ls_80 = StringSubstr(name_28, li_64, li_68);
               if (ls_44 != ls_80) {
                  ls_44 = ls_80;
                  lsa_52[li_12] = ls_44;
                  li_12++;
               }
               lsa_56[index_20] = "";
               ObjectDelete(name_28);
            }
         }
      }
   }
}

void DeleteObject(string as_0, bool ai_8 = TRUE)
{
   int objs_total = 0;
   string name = "";
   if (ai_8) {
      for (objs_total = ObjectsTotal(); objs_total >= 0; objs_total--) {
         name = ObjectName(objs_total);
         if (StringFind(name, as_0) >= 0) ObjectDelete(name);
      }
   } else {
      for (objs_total = ObjectsTotal(); objs_total >= 0; objs_total--) {
         name = ObjectName(objs_total);
         if (StringFind(name, "#" + as_0) >= 0) ObjectDelete(name);
      }
   }
}



bool f0_4(  string sObjNm, 
            int x, 
            int y, 
            string a_text_16 = "c", 
            int a_fontsize_24 = 14, 
            int iCorner = 0, 
            color a_color_32 = 0, 
            int subWindow = 0, 
            string a_fontname_40 = "Webdings", 
            int a_angle_48 = 0)
{
   
   if (subWindow > WindowsTotal() - 1) subWindow = WindowsTotal() - 1;
   
   if (StringLen(sObjNm) < 1) return (false);
   
   color textColor=clrNONE;
   if(IsOrder()){
      //textColor =clrRed;
      textColor = a_color_32;
   }
   else{
      textColor = a_color_32;
   }
   string FontFace="";
   int FontSize;
   if(a_text_16==Symbol()){
      //FontFace=a_fontname_40;   
      FontFace="Arial Bold";
      FontSize=(a_fontsize_24)-1;
   }
   else{
      FontSize=(a_fontsize_24);
      FontFace=a_fontname_40; 
   }
   
   ObjectDelete(sObjNm);
   ObjectCreate(sObjNm, OBJ_LABEL, subWindow, 0, 0);
   ObjectSet(sObjNm, OBJPROP_XDISTANCE, x);
   ObjectSet(sObjNm, OBJPROP_YDISTANCE, y);
   ObjectSet(sObjNm, OBJPROP_CORNER, 0);
   ObjectSet(sObjNm, OBJPROP_BACK, FALSE);
   ObjectSet(sObjNm, OBJPROP_ANGLE, a_angle_48);
   ObjectSetText(sObjNm, a_text_16, FontSize, FontFace, textColor);
   return (false);
}

//------------------------------------

double f0_5(string as_0)
{
   double point_20;
   int li_36;
   string ls_40;
   double ld_48;
   double ld_56;
   int count_8 = 0;
   double ld_ret_12 = 0;
   int timeframe_28 = 1440;
   
   for (int index_32 = 0; index_32 < ArraySize(arrValidSymbols); index_32++)
   {
      li_36 = 0;
      ls_40 = arrValidSymbols[index_32];
      if (as_0 == StringSubstr(ls_40, 0, 3) || as_0 == StringSubstr(ls_40, 3, 3)) {
         point_20 = MarketInfo(ls_40, MODE_POINT);
         if (point_20 == 0.0) {init(); continue;}
         
         ld_48 = (iHigh(ls_40, timeframe_28, 0) - iLow(ls_40, timeframe_28, 0)) * point_20;
         if (ld_48 == 0.0) {init(); continue;}
         ld_56 = 100.0 * ((MarketInfo(ls_40, MODE_BID) - iLow(ls_40, timeframe_28, 0)) / ld_48 * point_20);
         if (ld_56 > 3.0)  li_36 = 1;
         if (ld_56 > 10.0) li_36 = 2;
         if (ld_56 > 25.0) li_36 = 3;
         if (ld_56 > 40.0) li_36 = 4;
         if (ld_56 > 50.0) li_36 = 5;
         if (ld_56 > 60.0) li_36 = 6;
         if (ld_56 > 75.0) li_36 = 7;
         if (ld_56 > 90.0) li_36 = 8;
         if (ld_56 > 97.0) li_36 = 9;
         count_8++;
         if (as_0 == StringSubstr(ls_40, 3, 3)) li_36 = 9 - li_36;
         ld_ret_12 += li_36;
      }
   }
   if (count_8 > 0) ld_ret_12 /= count_8; else ld_ret_12 = 0;
   return (ld_ret_12);
}

//https://docs.mql4.com/basis/function/events
#define KEY_NUMPAD_5       12
#define KEY_LEFT           37
#define KEY_UP             38
#define KEY_RIGHT          39
#define KEY_DOWN           40
#define KEY_NUMLOCK_DOWN   98
#define KEY_NUMLOCK_LEFT  100
#define KEY_NUMLOCK_5     101
#define KEY_NUMLOCK_RIGHT 102
#define KEY_NUMLOCK_UP    104

void OnChartEvent(const int id,         // Event identifier  
                  const long& lparam,   // Event parameter of long type
                  const double& dparam, // Event parameter of double type
                  const string& sparam) // Event parameter of string type
{

   //int iChartid;
   switch (id){
   case CHARTEVENT_OBJECT_CLICK :
      string pattern = "id";
      int start = StringFind(sparam, pattern);
      int end = start + StringLen(pattern) - 1;
      
      
        
   Print("id:"+id);
   Print("lparam:"+lparam);
   Print("dparam:"+dparam);
   Print("sparam:"+sparam);
   
   
   
      if (start >= 0) {
  
         // Extract the two digits
         string matchedDigits = StringSubstr(sparam, end + 1, 2);
         int convertedDigits = StringToInteger(matchedDigits);
         Print(convertedDigits);
         switch(convertedDigits){
         case 7: //load a different symbol
            int iSymbolCharPos = StringFind(sparam, ":#");
            //Global Prime FX
            string  sCurrSym=StringSubstr(sparam,iSymbolCharPos+2,6);
       
            //BitByte Crypto
            //wnd:z_1??:c_0:lu_4_35:rd_164_64:id07:#AVAXUSDTwnd|cWnd1
            //int iSymbolCharPos2 = StringFind(sparam, "wnd|")-4;
            //string  sCurrSym=StringSubstr(sparam,iSymbolCharPos+2,(iSymbolCharPos2-iSymbolCharPos)+2);
            
            ChartSetSymbolPeriod(0, sCurrSym, Period());

            varDel("NAW meter symbol_");            
            string n = "NAW meter symbol_"+Symbol();
            
            GlobalVariableSet(n,0);


            //ChartApplyTemplate(0, sCurrSym+"_1");
            break;
         case 2: //change display modes
            DisplayMode++;
            if (DisplayMode >= ArrayRange(DisplayModes,0)) {
                DisplayMode = 0;
            }
            SetDisplayMode(DisplayMode);
            Print("DisplayMode: ", DisplayMode);
         
         //2 symbol seelect selelct chart WIP            
         case 4:
         case 5:
         //int SingleCurrclick=0;
         //string CurrPair2ndClick=""; 
              SingleCurrclick++;
              if(SingleCurrclick==2){
               SingleCurrclick=0;
              }
              //Print(sparam + ";"+dparam);
/*
bool   CurrenciesWindowBelowTable2 = CurrenciesWindowBelowTable;
bool   ShowCurrencies2             = ShowCurrencies;
bool   ShowCurrenciesSorted2       = ShowCurrenciesSorted;
bool   ShowSymbolsSorted2          = ShowSymbolsSorted;
*/   
         default:break;
         ;
         }         
          
      } else {
          // Pattern not found
          Print("Pattern not found");
      }     

      
      //Add signal to Global Vars
      //Print("SIGNAL RAISED");
      //GlobalVariableTemp(sIndiName+"_CHNG_SYMBL_"+sCurrSym); //Create if not exist
      //GlobalVariableSet(sIndiName2+"_CHANGESYMBOLTO_"+sCurrSym,1);
   }
  

  }


int ChartWidthInPixels(const long chart_ID=0)
  {
//--- prepare the variable to get the property value
   long result=-1;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetInteger(chart_ID,CHART_WIDTH_IN_PIXELS,0,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return((int)result);
  }
  
  
void IndiGlobalIsLoaded(bool IsLoaded){

   //Check for existence of global should can prevent init block running multple times and get deleted upon deinit
    if(IsLoaded){
         //////Print("NO GLOBAL");
        GlobalVariableTemp(sIndiName2); //Create if not exist
        GlobalVariableSet(sIndiName2,1);

    } 
    else{
      GlobalVariableSet(sIndiName2,0);

      for(int i=0;i<=GlobalVariablesTotal(); i++){
            if(StringFind(GlobalVariableName(i),sIndiName2,0)!=-1){
               //Print("ere");
               GlobalVariableDel(GlobalVariableName(i));
            }
      }
    }
}

void CleanChart(){
   int Window=0;
   string x;

   for(int i=ObjectsTotal(ChartID(),Window,-1)-1;i>=0;i--){
         
         //Print(ObjectName(i) + "," + sIndiName);
         x=ObjectName(i);
         if(StringFind(x,sIndiName2,0)!=-1){
            ObjectDelete(ObjectName(i));
         }
   }
}

string varDel(string sVarPrefix)
{
    string text;
    int nVar = GlobalVariablesTotal();
    
    for (int jVar = 0; jVar < nVar; jVar++) {
	string sVarName = GlobalVariableName(jVar);
	int x = StringFind(sVarName, sVarPrefix);
	if (x >= 0) {
	    GlobalVariableDel(sVarName);
	}
    }
    
    return(text);
}