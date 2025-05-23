//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com/en/users/mtnet/portfolio"
#property version   "1.00"
#property strict
#property indicator_chart_window

input string  c0="============== Main settings =============";
input bool       MinimizePanel=true;            //Minimize panel
input int        Xcoordinate=10;                //X
input int        Ycoordinate=35;                //Y
input string  c5="============== Colors =============";
input color TextClr=clrWhite;      //Text color
input color RiskClr=C'192,0,0';      //Risk color
input color LotClr=C'0,176,240';     //Lot color
input color MarginClr=C'255,192,0';  //Margin color
input color EquityClr=C'0,176,80';   //Equity color
input color BackClr=C'64,64,64';     //Background color
int sizeTxt=11;

int width=0;
int height=0;
double dpi=1;
string _prefix="JS ";
string text[20];
double stop=100,risk=1;
long stateHide=(long)MinimizePanel;
bool trig=true;
string font="Calibri";//"Arial Bold";

int X[]=
  {
   10, //0 rectangle background
   17, //1 stoploss text,risk text,lot text,margin text,equity text
   55, //2 stoploss edit,risk edit
   163, //3 risk value,lot value,margin value,equity value
   133, //4 minimize 
   151  //5 exit
  };

int Y[]=
  {
   0,//0 rectangle background
   18,  //1 stoploss text
   10,  //2 stoploss edit
   46,  //3 risk text, risk value
   38,  //4 risk edit
   71,  //5 lot text, lot value
   96, //6 margin text, margin value
   121, //7 equity text, equity value
   0    //8 minimize,exit
  };
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   trig=true;
   IndicatorShortName("MarginCalc");
   int cnt=0;
   for(int i=ChartIndicatorsTotal(0,0);i>=0;i--)
     {
      if(ChartIndicatorName(0,0,i)=="MarginCalc") cnt++;

      if(cnt>1) {trig=false;return(INIT_FAILED);}
     }
//--- indicator buffers mapping
   width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   height=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);

   ChartSetInteger(0,CHART_FOREGROUND,0,false);
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);

   dpi=(double)TerminalInfoInteger(TERMINAL_SCREEN_DPI)/96;

   int Xt[],Yt[];
   ArrayResize(Xt,ArraySize(X)); ArrayResize(Yt,ArraySize(Y));

   for(int i=0;i<ArraySize(X);i++) Xt[i]=(int)(X[i]*dpi)+Xcoordinate;
   for(int i=0;i<ArraySize(Y);i++) Yt[i]=(int)(Y[i]*dpi)+Ycoordinate;
   if(ObjectFind(0,text[0])==-1)
      RectLabelCreate(0,"RectLabel",0,Xt[0],Yt[0]-(int)(12*dpi),
                      (int)(160*dpi),(!stateHide?(int)(150*dpi):(int)(20*dpi)),BackClr,0,CORNER_LEFT_UPPER);

   text[12]= _prefix+"minimize";
   text[13]= _prefix+"exit";

//Button_hide
   CreateButton("b"+text[12],OBJ_BUTTON,"_",Xt[4],Yt[8]-(int)(11*dpi),(int)(18*dpi),(int)(18*dpi),BackClr,clrWhite,BackClr,10,CORNER_LEFT_UPPER,false,false," ",stateHide);

//Button_exit
   CreateButton("b"+text[13],OBJ_BUTTON,"X",Xt[5],Yt[8]-(int)(11*dpi),(int)(18*dpi),(int)(18*dpi),BackClr,clrWhite,BackClr,10,CORNER_LEFT_UPPER);

   if(!stateHide) CreateAll();

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| deinitialization function                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(trig)
     {
      ObjectsDeleteAll(0,_prefix);
      ObjectsDeleteAll(0,"b"+_prefix);
      ObjectDelete(0,"RectLabel");

      Comment("");
     }
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
                const int &spread[])
  {
//---
   Calc();

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Calc()
  {
//"risk val";
   ObjectSetString(0,text[5],OBJPROP_TEXT,DoubleToString(AccountBalance()*risk*0.01,2));

   double lot_t=MMRisk(stop);
   MarketInfo(_Symbol,MODE_MARGINREQUIRED);


//"lot val";
   ObjectSetString(0,text[7],OBJPROP_TEXT,DoubleToString(lot_t,2));

//"margin val";
   ObjectSetString(0,text[9],OBJPROP_TEXT,DoubleToString(lot_t*MarketInfo(_Symbol,MODE_MARGINREQUIRED),2));

//"equity val";
   if(AccountEquity()!=0)
      ObjectSetString(0,text[11],OBJPROP_TEXT,DoubleToString(MarketInfo(_Symbol,MODE_MARGINREQUIRED)*lot_t/AccountEquity()*100,3));

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {

   text[0]= _prefix+"rectangle bg";
   text[1]= _prefix+"stoploss text";
   text[2]= _prefix+"stoploss edit";
   text[3]= _prefix+"risk text";
   text[4]= _prefix+"risk edit";
   text[5]= _prefix+"risk val";
   text[6]= _prefix+"lot text";
   text[7]= _prefix+"lot val";
   text[8]= _prefix+"margin text";
   text[9]= _prefix+"margin val";
   text[10]= _prefix+"equity text";
   text[11]= _prefix+"equity val";
   text[12]= _prefix+"minimize";
   text[13]= _prefix+"exit";

   if(id==CHARTEVENT_OBJECT_CLICK)
     {

      //////////////////////////// EVENT CLICK HIDE /////////////////////////////
      if(sparam=="b"+text[12])
         if(ObjectGetInteger(0,sparam,OBJPROP_STATE))
           {
            ObjectsDeleteAll(0,_prefix);
            ObjectSetInteger(0,"RectLabel",OBJPROP_YSIZE,(int)(20*dpi));
            stateHide=true;
           }
      else
        {
         stateHide=false;
         ObjectSetInteger(0,"RectLabel",OBJPROP_YSIZE,(int)(150*dpi));
         CreateAll();
         Calc();
         ChartRedraw();

        }

      //////////////////////////// EVENT CLICK EXIT /////////////////////////////
      if(sparam=="b"+text[13])
         if(ObjectGetInteger(0,sparam,OBJPROP_STATE))
           {
            ChartIndicatorDelete(0,0,"MarginCalc");
           }

     }

   if(id==CHARTEVENT_OBJECT_ENDEDIT)
     {

      /////////////////// STOPLOSS ////////////

      if(sparam==text[2])
        {
         string txt=ObjectGetString(0,sparam,OBJPROP_TEXT);
         if(StringFind(txt,",",0)!=-1) StringReplace(txt,",",".");

         double temp_t=StringToDouble(txt);
         if(temp_t>=0) 
           {
            stop=NormalizeDouble(StringToDouble(txt),0);
            ObjectSetString(0,sparam,OBJPROP_TEXT,DoubleToString(stop,0));
            Calc();
           }
         else

            ObjectSetString(0,sparam,OBJPROP_TEXT,DoubleToString(stop,0));

        }
      /////////////////// RISK  ////////////
      if(sparam==text[4])
        {
         string txt=ObjectGetString(0,sparam,OBJPROP_TEXT);
         if(StringFind(txt,",",0)!=-1) StringReplace(txt,",",".");

         double temp_t=StringToDouble(txt);
         if(temp_t>=0) 
           {
            risk=NormalizeDouble(StringToDouble(txt),3);
            ObjectSetString(0,sparam,OBJPROP_TEXT,DoubleToString(risk,3));
            Calc();
           }
         else

            ObjectSetString(0,sparam,OBJPROP_TEXT,DoubleToString(risk,3));

        }

     }

  }
//-----------------------------------------------------------------------+
//                      MM  lot depend from stoploss                     |
//-----------------------------------------------------------------------+
double MMRisk(double sl)
  {

   double  S=MarketInfo(_Symbol,MODE_TICKVALUE)/(MarketInfo(_Symbol,MODE_TICKSIZE)/MarketInfo(_Symbol,MODE_POINT)); //cost of point

   double Free;
   double One_Lot;
   double Lots;

   double Loss_t=0;

   Loss_t=stop*S;

   if(Loss_t<=0) return 0;
     {
      Free=AccountBalance();
      One_Lot=MarketInfo(_Symbol,MODE_MARGINREQUIRED);
      //Lots=NormalizeDouble(Free*MaxRisk/(100*One_Lot),2); 
      Lots=NormalizeDouble(Free*risk*0.01/Loss_t,2);

      if(Lots<MarketInfo(_Symbol,MODE_MINLOT)) {Lots=0;return(0);} //no money

      if(Lots>0) Lots=round(Lots/MarketInfo(_Symbol,MODE_LOTSTEP))*MarketInfo(_Symbol,MODE_LOTSTEP);
      if(Lots>MarketInfo(_Symbol,MODE_MAXLOT)) Lots=MarketInfo(_Symbol,MODE_MAXLOT);
     }

   if(Lots>MarketInfo(_Symbol,MODE_MAXLOT)) Lots=MarketInfo(_Symbol,MODE_MAXLOT);
   return(Lots);
  }
//+------------------------------------------------------------------+
//| draw Label                                                       |
//+------------------------------------------------------------------+
void DrawLabel(string name,string label,int size,string font_t,color clr,ENUM_BASE_CORNER c,int x,int y,string tooltip,
               int anchor=ANCHOR_LEFT)
  {
//---

   ObjectDelete(name);
   ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetString(0,name,OBJPROP_TEXT,label);
   ObjectSetString(0,name,OBJPROP_FONT,font_t);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);

   ObjectSetInteger(0,name,OBJPROP_CORNER,c);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
//--- justify textMarket
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,tooltip);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CreateRectangle(const long             chart_ID=0,
                     const string           name="Rect",
                     const int              sub_window=0,
                     const int              x=210,
                     const int              y=10,
                     const int              widt=200,
                     const int              height_t=80,
                     const color            back_clr=0x222222,
                     const ENUM_BORDER_TYPE border=BORDER_FLAT,
                     const ENUM_BASE_CORNER corner=CORNER_RIGHT_UPPER,
                     const color            clr=clrLemonChiffon,
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,
                     const int              line_width=1,
                     const bool             back=false,
                     const bool             selection=false,
                     const bool             hidden=true,
                     const long             z_order=0,
                     const bool             selected=false)
  {
   ObjectDelete(chart_ID,name);
//corner = BaseCorner;
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": Cannot create rectangle! Error = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,widt);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height_t);
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selected);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create edit field                                                |
//+------------------------------------------------------------------+

void CreateEdit(string name,ENUM_OBJECT Type,string text_t,int XDistance,int YDistance,int Width,int Height,
                color BGColor_,color InfoColor,color boarderColor,int fontsize,bool readonly=false,bool Obj_Selectable=false,string Tooltip="",ENUM_ALIGN_MODE align=ALIGN_CENTER)
  {
   ObjectCreate(0,name,Type,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,XDistance);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,YDistance);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,Width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,Height);
   ObjectSetString(0,name,OBJPROP_TEXT,text_t);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial Bold");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_COLOR,InfoColor);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,boarderColor);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,BGColor_);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,Obj_Selectable);
   ObjectSetInteger(0,name,OBJPROP_READONLY,readonly);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,1);

   ObjectSetString(0,name,OBJPROP_TOOLTIP,Tooltip);
   ObjectSetInteger(0,name,OBJPROP_ALIGN,align);

  }
//+------------------------------------------------------------------+
//| Create button object                                             |
//+------------------------------------------------------------------+

void CreateButton(string name,ENUM_OBJECT Type,string text_t,int XDistance,int YDistance,int Width,int Height,
                  color BGColor_,color InfoColor,color boarderColor,int fontsize,int corner=0,bool readonly=false,bool Obj_Selectable=false,string Tooltip="",bool state_t=false)
  {
   ObjectCreate(0,name,Type,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,XDistance);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,YDistance);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,Width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,Height);
   ObjectSetString(0,name,OBJPROP_TEXT,text_t);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial Bold");
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetInteger(0,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(0,name,OBJPROP_COLOR,InfoColor);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);   
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,boarderColor);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,BGColor_);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,Obj_Selectable);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,Tooltip);
   ObjectSetInteger(0,name,OBJPROP_STATE,state_t);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,1);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RectLabelCreate(const long             chart_ID=0,
                     const string           name="RectLabel",
                     const int              sub_window=0,
                     const int              x=210,
                     const int              y=10,
                     const int              widt=200,
                     const int              height_t=80,
                     const color            back_clr=0x222222,
                     const ENUM_BORDER_TYPE border=BORDER_FLAT,
                     const ENUM_BASE_CORNER corner=CORNER_RIGHT_UPPER,
                     const color            clr=clrLemonChiffon,
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,
                     const int              line_width=0,
                     const bool             back=false,
                     const bool             selection=false,
                     const bool             hidden=true,
                     const long             z_order=0)
  {
   ObjectDelete(chart_ID,name);
//corner = BaseCorner;
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": Cannot create rectangle! Error = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,widt);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height_t);
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateAll()
  {
   text[0]= _prefix+"rectangle bg";
   text[1]= _prefix+"stoploss text";
   text[2]= _prefix+"stoploss edit";
   text[3]= _prefix+"risk text";
   text[4]= _prefix+"risk edit";
   text[5]= _prefix+"risk val";
   text[6]= _prefix+"lot text";
   text[7]= _prefix+"lot val";
   text[8]= _prefix+"margin text";
   text[9]= _prefix+"margin val";
   text[10]= _prefix+"equity text";
   text[11]= _prefix+"equity val";
   text[12]= _prefix+"minimize";
   text[13]= _prefix+"exit";

   int Xt[],Yt[];
   ArrayResize(Xt,ArraySize(X)); ArrayResize(Yt,ArraySize(Y));

   for(int i=0;i<ArraySize(X);i++) Xt[i]=(int)(X[i]*dpi)+Xcoordinate;
   for(int i=0;i<ArraySize(Y);i++) Yt[i]=(int)(Y[i]*dpi)+Ycoordinate;

   DrawLabel(text[1],"Stop",sizeTxt,font,TextClr,CORNER_LEFT_UPPER,Xt[1],Yt[1],"sl");
   CreateEdit(text[2],OBJ_EDIT,DoubleToString(stop,0),Xt[2],Yt[2],(int)(50*dpi),(int)(18*dpi),clrWhite,clrBlack,clrWhite,10);

   DrawLabel(text[3],"Risk",sizeTxt,font,TextClr,CORNER_LEFT_UPPER,Xt[1],Yt[3],"risk");
   CreateEdit(text[4],OBJ_EDIT,DoubleToString(risk,2),Xt[2],Yt[4],(int)(50*dpi),(int)(18*dpi),clrWhite,clrBlack,clrWhite,10);
   DrawLabel(text[5],"0",sizeTxt,font,RiskClr,CORNER_LEFT_UPPER,Xt[3],Yt[3],"risk value",ANCHOR_RIGHT);
   DrawLabel(text[6],"Lot Size",sizeTxt,font,TextClr,CORNER_LEFT_UPPER,Xt[1],Yt[5],"lot");
   DrawLabel(text[7],"0",sizeTxt,font,LotClr,CORNER_LEFT_UPPER,Xt[3],Yt[5],"lot value",ANCHOR_RIGHT);

   DrawLabel(text[8],"Margin Cost",sizeTxt,font,TextClr,CORNER_LEFT_UPPER,Xt[1],Yt[6],"margin");
   DrawLabel(text[9],"0",sizeTxt,font,MarginClr,CORNER_LEFT_UPPER,Xt[3],Yt[6],"margin value",ANCHOR_RIGHT);

   DrawLabel(text[10],"Equity %",sizeTxt,font,TextClr,CORNER_LEFT_UPPER,Xt[1],Yt[7],"equity");
   DrawLabel(text[11],"0",sizeTxt,font,EquityClr,CORNER_LEFT_UPPER,Xt[3],Yt[7],"equity value",ANCHOR_RIGHT);

  }
//+------------------------------------------------------------------+
