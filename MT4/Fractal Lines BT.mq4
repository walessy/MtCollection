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
int     Fractal_Timeframe                = 0;
extern int     Maxbar                           = 2000;
extern color   Up_Fractal_Color                 = clrRed;
extern int     Up_Fractal_Symbol                = 108;
extern color   Down_Fractal_Color               = clrBlue;
extern int     Down_Fractal_Symbol              = 108;
extern bool    Extend_Line                      = true;
extern bool    Extend_Line_to_Background        = true;
extern bool    Show_Validation_Candle           = true;
extern color   Up_Fractal_Extend_Line_Color     = clrPink;
extern int     Up_Fractal_Extend_Width          = 0;
extern int     Up_Fractal_Extend_Style          = 2;
extern color   Down_Fractal_Extend_Line_Color   = clrDodgerBlue;
extern int     Down_Fractal_Extend_Width        = 0;
extern int     Down_Fractal_Extend_Style        = 2;
//button template start1; copy and paste
extern string             button_note1          = "------------------------------";
extern int                btn_Subwindow         = 0;
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER; 
extern string             btn_text              = "FRACTAL";
extern string             btn_Font              = "Arial";
extern int                btn_FontSize          = 9;                        
extern color              btn_text_ON_color     = clrWhite;
extern color              btn_text_OFF_color    = clrRed;
extern color              btn_background_color  = clrDimGray;
extern color              btn_border_color      = clrBlack;
extern int                button_x              = 20;                                   
extern int                button_y              = 13;                                   
extern int                btn_Width             = 60;                                
extern int                btn_Height            = 20;                               
extern string             UniqueButtonID        = "FractalLines";
extern string             button_note2          = "------------------------------";

bool show_data = true, recalc    = true;
string indicatorFileName, IndicatorName, IndicatorObjPrefix,buttonId;
//button template end1; copy and paste

double UpBuffer[], DoBuffer[], refchk, tempref, level;
int barc;
//+------------------------------------------------------------------------------------------------------------------+
//button template start2; copy and paste
string GenerateIndicatorName(const string target) 
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}
//+------------------------------------------------------------------------------------------------------------------+
int OnInit()
{
   IndicatorName = GenerateIndicatorName(btn_text);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   
   double val;
   if (GlobalVariableGet(IndicatorName + "_visibility", val))
      show_data = val != 0;

   indicatorFileName = WindowExpertName();
   
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = IndicatorObjPrefix + UniqueButtonID+(btn_text);
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);
   
   init2();
return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason) { 
     ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
     deinit2();
}
//+------------------------------------------------------------------+
void createButton(string buttonID,string buttonText,int width2,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
{
      ObjectDelete    (0,buttonID);
      ObjectCreate    (0,buttonID,OBJ_BUTTON,btn_Subwindow,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width2);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString (0,buttonID,OBJPROP_FONT,font);
      ObjectSetString (0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,btn_corner);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
}
//+------------------------------------------------------------------+
void handleButtonClicks()
{
   if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
   {
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
      recalc = true;
   }
}
//+------------------------------------------------------------------------------------------------------------------+
void OnChartEvent(const int id, 
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   handleButtonClicks();
   if (id==CHARTEVENT_OBJECT_CLICK && ObjectGet(sparam,OBJPROP_TYPE)==OBJ_BUTTON)
   
   for (int banzai=0; banzai<indicator_buffers; banzai++)
     SetIndexStyle(banzai,DRAW_ARROW);
     
   if (show_data)
      {
       ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_text_ON_color); 
       start();
      }
      else
      {
        ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_text_OFF_color);
        for (int banzai2=0; banzai2<indicator_buffers; banzai2++)
            SetIndexStyle(banzai2,DRAW_NONE);
        deinit2();
      }
}
//button template end2; copy and paste
//+------------------------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                             INIT |
//+------------------------------------------------------------------+

int init2() {

   SetIndexBuffer(0,UpBuffer);
   SetIndexStyle(0,DRAW_ARROW, DRAW_ARROW, 0, Up_Fractal_Color);
   SetIndexArrow(0,Up_Fractal_Symbol);
   SetIndexBuffer(1,DoBuffer);
   SetIndexStyle(1,DRAW_ARROW, DRAW_ARROW, 0, Down_Fractal_Color);
   SetIndexArrow(1,Down_Fractal_Symbol);
   
   return(0);
}

//+------------------------------------------------------------------+
//|                                                           DEINIT |
//+------------------------------------------------------------------+

int deinit2() {
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
/*   
   if (barc != Bars || IndicatorCounted() < 0 || tempref != refchk) {
      barc = Bars;
      refchk = tempref;
   } else
      return(0);
*/   
   deinit2();
   
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
            DrawLine ("H", i, c, level, Extend_Line_to_Background, Up_Fractal_Extend_Line_Color, Up_Fractal_Extend_Width, Up_Fractal_Extend_Style);
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
            DrawLine ("L", i, c, level, Extend_Line_to_Background, Down_Fractal_Extend_Line_Color, Down_Fractal_Extend_Width, Down_Fractal_Extend_Style);
            if (Show_Validation_Candle) DoBuffer[i-2*dif] = level;
            i += dif;
         }
      }
   }
   
   return(0);
}
//+------------------------------------------------------------------+
//|                                                        DRAW LINE |
//+------------------------------------------------------------------+

void DrawLine (string dir, int i, int c, double lev, bool back, color col, int width, int style) {
   ObjectCreate("MTF_Fractal_"+dir+i,OBJ_TREND,0,0,0,0,0);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_TIME1,iTime(Symbol(),Period(),i));
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_PRICE1,lev);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_TIME2,iTime(Symbol(),Period(),c));
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_PRICE2,lev);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_RAY,0);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_BACK,back);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_COLOR,col);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_WIDTH,width);
   ObjectSet("MTF_Fractal_"+dir+i,OBJPROP_STYLE,style);
}