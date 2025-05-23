//+------------------------------------------------------------------------------------------------------------------+
#property description                                                                                      "[XU-VWAP]"
#define Version                                                                                            "[XU-VWAP]"
//+------------------------------------------------------------------------------------------------------------------+
#property link        "https://forex-station.com/viewtopic.php?p=1295409935#p1295409935"
#property description "THIS IS A FREE INDICATOR"
#property description "                                                      "
#property description "Welcome to XARD UNIVERSE"
#property description "Let light shine out of darkness and illuminate your world"
#property description "and with this freedom leave behind your cave of denial"
#property indicator_chart_window
#property indicator_buffers 7
   extern string Indicator                  = Version;  string ID;
//+------------------------------------------------------------------------------------------------------------------+
          string VWAPTfInfo   = "use H4, D1, W1, MN1";
          string VWAPTf       = "W1";
      extern int NumVWAPTf    = 4;
   extern string DayStartTime = "00:00";
    extern color ClrVWAP      = C'255,225,0',ClrSD=Silver;
      extern int VWAPWidth    = 3,StyleSD=STYLE_DASH;  int giVWAPTf;  double gdVWMA[];
   double BuffUpperSD3[],BuffUpperSD2[],BuffUpperSD1[],BuffVWAP[],BuffLowerSD1[],BuffLowerSD2[],BuffLowerSD3[];
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68338
//+------------------------------------------------------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------------------------------------------------------+
// not for sale, rent, auction, nor lease
// button_note1,btn_corner,btn_text,btn_Font,btn_FontSize,btn_text_ON_color,btn_text_OFF_color,btn_background_color,btn_border_color,button_x,button_y,btn_Width,btn_Height,button_note2,
//template code start1  
   extern string             button_note1          = "------------------------------";
   extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_LOWER; // chart btn_corner for anchoring
   extern string             btn_text              = "VWAP";
   extern string             btn_Font              = "Impact";
   extern int                btn_FontSize          = 14;                //btn__font size
   extern color              btn_text_ON_color     = clrWhite;
   extern color              btn_text_OFF_color    = C'120,120,120';
   extern color              btn_background_color  = clrDarkRed;
   extern color              btn_border_color      = clrDarkRed;
   extern int                button_x              = 342;               //btn__x
   extern int                button_y              = 25;                //btn__y
   extern int                btn_Width             = 60;                //btn__width
   extern int                btn_Height            = 25;                //btn__height
   extern string             button_note2          = "------------------------------";

   bool                      show_data             = true;
   string IndicatorName, IndicatorObjPrefix;
//template code end1

//+------------------------------------------------------------------------------------------------------------------+
   string GenerateIndicatorName(const string target) //don't change anything here
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
   string buttonId;

   int OnInit()
   {
   IndicatorName = GenerateIndicatorName(btn_text);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   
   double val;
   if (GlobalVariableGet(IndicatorName + "_visibility", val))
      show_data = val != 0;

   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = IndicatorObjPrefix + "XU_VWAP2020";
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_XDISTANCE, button_x);

// put init() here
   init2();
   return(INIT_SUCCEEDED);
   }
//+------------------------------------------------------------------------------------------------------------------+
//don't change anything here
   void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
   {
      ObjectDelete    (ChartID(),buttonID);
      ObjectCreate    (ChartID(),buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_YSIZE,height);
      ObjectSetString (ChartID(),buttonID,OBJPROP_FONT,font);
      ObjectSetString (ChartID(),buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_CORNER,btn_corner);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_HIDDEN,1);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_YDISTANCE,9999);
   }
//+------------------------------------------------------------------------------------------------------------------+
   int deinit()
   {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);

//put deinit() here
   deinit2();
	return(0);
   }
//+------------------------------------------------------------------------------------------------------------------+
//don't change anything here
   bool recalc = true;

   void handleButtonClicks()
   {
   if (ObjectGetInteger(ChartID(), buttonId, OBJPROP_STATE))
   {
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
      recalc = true;
      start();
   }
   }
//+------------------------------------------------------------------------------------------------------------------+
   void OnChartEvent(const int id, //don't change anything here
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
   {
   handleButtonClicks();
   }
//+------------------------------------------------------------------------------------------------------------------+
   int start()
   {
   handleButtonClicks();
   recalc = false;
   //put start () here
   start2();
      if (show_data)
         {
           ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_text_ON_color);
           for (int banzai=0; banzai<indicator_buffers; banzai++)
               SetIndexStyle(banzai,DRAW_LINE);
         }
      else
         {
           ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_text_OFF_color);
           for (int banzai2=0; banzai2<indicator_buffers; banzai2++)
               SetIndexStyle(banzai2,DRAW_NONE);
         }
   return(0);
   }
//+------------------------------------------------------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------------------------+
   int init2(){ID = "XU VWAP"; IndicatorShortName(ID);
   if(Period()<=PERIOD_M30){VWAPTf="D1";}
   if(Period()==PERIOD_H1){VWAPTf="W1";}
   if(Period()>=PERIOD_H4){VWAPTf="MN1";}
//+-----
   int i;  giVWAPTf = getTfByName(VWAPTf);
   SetIndexStyle(3,DRAW_LINE,0,VWAPWidth,ClrVWAP);
   for(i=0;i<7;i++){SetIndexEmptyValue(i,0);
   if(i==3) continue;
//+-----
   SetIndexStyle(i,DRAW_LINE,0,2,ClrSD);}
   SetIndexBuffer(0,BuffUpperSD3);
   SetIndexBuffer(1,BuffUpperSD2);   
   SetIndexBuffer(2,BuffUpperSD1);   
   SetIndexBuffer(3,BuffVWAP);
   SetIndexBuffer(4,BuffLowerSD1);
   SetIndexBuffer(5,BuffLowerSD2);
   SetIndexBuffer(6,BuffLowerSD3);  return(0);}
//+------------------------------------------------------------------------------------------------------------------+
   int deinit2(){return(0);}
//+------------------------------------------------------------------------------------------------------------------+
   int start2(){if(Period() >= giVWAPTf) return(0);
   int counted_bars = IndicatorCounted(),i,iBarVWAPTf,iStartBar,iLimit,iNumBars;
   double dVWMA,dSD;  datetime dtVWAPTf;
   if(counted_bars<0) return(-1);
   if(Period() >= giVWAPTf) return(-1);
   if(counted_bars>0) counted_bars--;
   iLimit = Bars-counted_bars; iBarVWAPTf = NumVWAPTf-1;
   if(giVWAPTf == PERIOD_D1){
   if(createDt(Time[0], DayStartTime) > Time[0]){
         iBarVWAPTf++;
         dtVWAPTf = iTime(NULL, giVWAPTf, iBarVWAPTf);
         dtVWAPTf = createDt(dtVWAPTf, DayStartTime);}
    else dtVWAPTf = createDt(dtVWAPTf, DayStartTime);}
    else dtVWAPTf = iTime(NULL, giVWAPTf, iBarVWAPTf);
//+-----
   iStartBar = iBarShift(NULL, 0, dtVWAPTf);      
   if(Time[iStartBar] < dtVWAPTf) iStartBar--;
   iLimit = MathMin(iLimit, iStartBar);         
//+-----
   for(i=iLimit;i>=0;i--){
   if(giVWAPTf == PERIOD_D1){dtVWAPTf = createDt(Time[i], DayStartTime);
   if(dtVWAPTf > Time[i]) dtVWAPTf -= PERIOD_D1*60;} else {
     iBarVWAPTf = iBarShift(NULL, giVWAPTf, Time[i]);
       dtVWAPTf = iTime(NULL, giVWAPTf, iBarVWAPTf);}
      iStartBar = iBarShift(NULL, 0, dtVWAPTf);
   if(Time[iStartBar] < dtVWAPTf) iStartBar--;                          
       iNumBars = (iStartBar-i)+1;
          dVWMA = getVWMA(iNumBars,i);             
   if(iNumBars <=1) continue;
            dSD = getStdDev(dVWMA,iNumBars,i); 
    BuffVWAP[i] = dVWMA;           
   if(ClrSD == CLR_NONE) continue;
//+-----
     BuffUpperSD1[i] = BuffVWAP[i] + (1.0 * dSD);
     BuffUpperSD2[i] = BuffVWAP[i] + (2.0 * dSD);
     BuffUpperSD3[i] = BuffVWAP[i] + (3.0 * dSD);
     BuffLowerSD1[i] = BuffVWAP[i] - (1.0 * dSD);
     BuffLowerSD2[i] = BuffVWAP[i] - (2.0 * dSD);
     BuffLowerSD3[i] = BuffVWAP[i] - (3.0 * dSD);}  return(0);}
//+------------------------------------------------------------------------------------------------------------------+
   datetime createDt(datetime date, string time){return(StrToTime(TimeToStr(date,TIME_DATE)+" "+time));}
//+------------------------------------------------------------------------------------------------------------------+
   double getVWMA(int period, int shift){double Sum=0,Weight=0;
   for(int i = shift; i < (shift + period); i++){Weight+= Volume[i];
      Sum += getAppliedPrice(PRICE_TYPICAL, i)*Volume[i];}
   if(Weight>0) double vwma = Sum/Weight;  else vwma = 0;  return(vwma);}
//+------------------------------------------------------------------------------------------------------------------+
   double getStdDev(double mean, int period, int shift){double sum, val, sumvol;  
   for(int i = shift; i < (shift+period); i++){sumvol += Volume[i];     
      val = getAppliedPrice(PRICE_TYPICAL, i) - mean;
      val *= val;  sum += (Volume[i]) * val;}  
   if(sumvol>0) return(MathSqrt(sum/sumvol)); else return(0.0);}
//+------------------------------------------------------------------------------------------------------------------+
   int getTfByName(string tfname){int p;
        if (tfname == "MN1") p = PERIOD_MN1;
   else if (tfname == "W1" ) p = PERIOD_W1;
   else if (tfname == "D1" ) p = PERIOD_D1;
   else if (tfname == "H4" ) p = PERIOD_H4;
   else if (tfname == "H1" ) p = PERIOD_H1;
   else if (tfname == "M30") p = PERIOD_M30;
   else if (tfname == "M15") p = PERIOD_M15;
   else if (tfname == "M5" ) p = PERIOD_M5;
   else if (tfname == "M1" ) p = PERIOD_M1;  else p = Period();  return(p);}
//+------------------------------------------------------------------------------------------------------------------+
   double getAppliedPrice(int nAppliedPrice, int nIndex){double dPrice;
   switch(nAppliedPrice){
      case 0:  dPrice=Close[nIndex];                                  break;
      case 1:  dPrice=Open[nIndex];                                   break;
      case 2:  dPrice=High[nIndex];                                   break;
      case 3:  dPrice=Low[nIndex];                                    break;
      case 4:  dPrice=(High[nIndex]+Low[nIndex])/2.0;                 break;
      case 5:  dPrice=(High[nIndex]+Low[nIndex]+Close[nIndex])/3.0;   break;
      case 6:  dPrice=(High[nIndex]+Low[nIndex]+2*Close[nIndex])/4.0; break;
      default: dPrice=0.0;}  return(dPrice);}
//+------------------------------------------------------------------------------------------------------------------+