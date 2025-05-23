//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                    Bigger TF Candles WeekDay KB+TT                   %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#property copyright   "© Karabas BARABAS, Tankk,   17 ноября 2019" 
#property link        ""
#property description "Построение свечей старшего периода графика," 
#property description "с возможностью выбора дня недели для отрисовки свечей." 
#property description " "
#property description "Перерисовывается! до закрытия старшего периода!"
#property description " "  ///^^^   ^^^   ^^^   ^^^   ^^^   ^^^   ^^^   ^^^"   ////   ^^^   ^^^   ^^^   ^^^   ^^^^"
#property description "Почта:  tualatine@mail.ru" 
#property version  "1.11"
//------
#property indicator_chart_window  //separate_window  //
//#property indicator_buffers 8
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                   Custom indicator ENUM settings                     %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//---
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                 Custom indicator input parameters                    %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

 ENUM_TIMEFRAMES TimeFrame  =  PERIOD_MN1;    // Период старшей свечи
extern int            HowCandles  =  42;           // Количество старшей свечи
/*extern*/ bool      DrawCurrent  =  true;   // Рисовать текущю свечу
extern bool           DrawMonday  =  true;   // Понедельник";
extern bool          DrawTuesday  =  true;   // Вторник";
extern bool        DrawWednesday  =  true;   // Среда";
extern bool         DrawThursday  =  true;   // Четверг";
extern bool           DrawFriday  =  true;   // Пятница";  
extern int TimeZoneOffset = 2; // Adjust this value based on the time zone offset (2 for summer, 1 for winter)

extern color             ColorNT  =  clrDarkOrange;   // Цвет нейтральной свечи
extern color             ColorUP  =  clrRoyalBlue;    // Цвет восходящей свечи
extern color             ColorDN  =  clrIndianRed;    // Цвет нисходящей свечи
extern int offset =2;
extern bool           BackGround  =  true;            // Заливка свечи
extern bool            CSelected  =  false;           // Выделить свечу [для копирования]
extern ENUM_LINE_STYLE    CStyle  =  STYLE_DOT;       // Стиль линий свечи
extern int                 CSize  =  2;               // Толщина линий свечи

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                     Custom indicator buffers                         %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
string PREF;
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%              Custom indicator initialization function                %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
int init() 
{
   TimeFrame = fmax(TimeFrame,_Period);    
//------ "короткое имя" для DataWindow и подокна индикатора + и/или "уникальное имя индикатора"
   //IndicatorShortName(stringMTF(TimeFrame)+"Bigger TF MONTH"+(string)HowCandles+"");   //+EnumToString(Price)
   //---
   //PREF = stringMTF(TimeFrame)+" BgTF Mnth "+(string)HowCandles+" ";     //"*"+DoubleToStr(Koef,1)+"] "; 
   PREF = "BgTF Mnth "+(string)HowCandles+" ";     //"*"+DoubleToStr(Koef,1)+"] "; 
//**************************************************************************//
//**************************************************************************//
//------
return(0);
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%              Custom indicator deinitialization function              &&&
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
///void OnDeinit(const int reason)  { ObjectsDeleteAll(0,PREF,-1,-1); }     
int deinit()  { ALL_OBJ_DELETE();  Comment("");  return(0); }
//**************************************************************************//
void ALL_OBJ_DELETE()
{
   string name;
   for (int s=ObjectsTotal()-1; s>=0; s--) {
        name=ObjectName(s);
        if (StringSubstr(name,0,StringLen(PREF))==PREF) ObjectDelete(name); }
}  
//**************************************************************************//
datetime LastBarOpenTime=0; 
//------
/*
bool NewBarTF(int period) 
{
   datetime BarOpenTime=iTime(NULL,period,0);
   if (BarOpenTime!=LastBarOpenTime) {
       LastBarOpenTime=BarOpenTime;
       return (true); } 
   else 
       return (false);
}
*/
bool NewBarTF(int period) 
{
   datetime BarOpenTime = iTime(NULL, period, 0) - 2 * 60 * 60; // Adjust the bar opening time by subtracting the offset (2 hours in this case)
   if (BarOpenTime != LastBarOpenTime) {
       LastBarOpenTime = BarOpenTime;
       return (true);
   } else {
       return (false);
   }
}

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                 Custom indicator iteration function                  %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
int start() 
{
   //int i, y, d, CountedBars=IndicatorCounted();   
   //if (CountedBars<0) return(-1);       //Стандарт+Tankk-Вариант!!!
   //if (CountedBars>0) CountedBars--;
   //int limit=fmin(Bars-CountedBars,Bars-2);  //+MAX*10*TFK
   //if (History>MAX) { limit=fmin(History,Bars-2);  if (NewBarTF(PERIOD_M1)) ALL_OBJ_DELETE(); }    //Comment(limit);
   //---
   ALL_OBJ_DELETE(); 
   //---
   int limit = (HowCandles>0) ? fmin((HowCandles-1)*TimeFrame/_Period, Bars-2) : (Bars-2)/(TimeFrame/_Period);   //: fmin((Bars-IndicatorCounted())+(48*TimeFrame/_Period),Bars-2);   //
   int zero  = (DrawCurrent) ? 0 : 1;    int mBar = (TimeFrame==_Period) ? 0 : 1;
//**************************************************************************//
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   for (int i=limit; i>=zero; i--)
    {
     int y = iBarShift(NULL,TimeFrame,Time[i],false);
     int d = iBarShift(NULL,PERIOD_D1,Time[i],false);
     //---
    // datetime timOP = iTime(NULL,TimeFrame,y);  
     //datetime timCL = iTime(NULL,TimeFrame,y) + 60*TimeFrame -mBar;   //SB = Shift one Bar  ;-))
     //datetime timOP = iTime(NULL, TimeFrame, y) - offset * 60 * 60;
     //datetime timCL = iTime(NULL, TimeFrame, y) + offset * TimeFrame - mBar - 2 * 60 * 60;
      datetime timOP = iTime(NULL, TimeFrame, y) - TimeZoneOffset * 3600;
      datetime timCL = iTime(NULL, TimeFrame, y) + (60 * TimeFrame - mBar) - TimeZoneOffset * 3600;
     
     
     datetime timMD = timOP + MathRound((60*TimeFrame)/2);
     //---
     double prOP = iOpen(NULL,TimeFrame,y);
     double prCL = iClose(NULL,TimeFrame,y);
     double prHI = iHigh(NULL,TimeFrame,y); 
     double prLO = iLow(NULL,TimeFrame,y); 
     //---
     if (TimeFrame > PERIOD_D1) 
      {
       DrawRECT(y, "Body ", timOP, prOP, timCL, prCL);
       DrawLINE(true, y, "WickHI ", timMD, prOP, prCL, prHI, prLO);
       DrawLINE(false, y, "WickLO ", timMD, prOP, prCL, prHI, prLO); 
      }
     //---
     if (TimeFrame <= PERIOD_D1) 
      {
       if (DrawMonday && TimeDayOfWeek(iTime(NULL,PERIOD_D1,d))==1) {
           DrawRECT(y, "Body Monday ", timOP, prOP, timCL, prCL);
           DrawLINE(true, y, "WickHI Monday ", timMD, prOP, prCL, prHI, prLO);
           DrawLINE(false, y, "WickLO Monday ", timMD, prOP, prCL, prHI, prLO); }
       //---
       if (DrawTuesday && TimeDayOfWeek(iTime(NULL,PERIOD_D1,d))==2) {
           DrawRECT(y, "Body Tuesday ", timOP, prOP, timCL, prCL);
           DrawLINE(true, y, "WickHI Tuesday ", timMD, prOP, prCL, prHI, prLO);
           DrawLINE(false, y, "WickLO Tuesday ", timMD, prOP, prCL, prHI, prLO); }
       //---
       if (DrawWednesday && TimeDayOfWeek(iTime(NULL,PERIOD_D1,d))==3) {
           DrawRECT(y, "Body Wednesday ", timOP, prOP, timCL, prCL);
           DrawLINE(true, y, "WickHI Wednesday ", timMD, prOP, prCL, prHI, prLO);
           DrawLINE(false, y, "WickLO Wednesday ", timMD, prOP, prCL, prHI, prLO); }
       //---
       if (DrawThursday && TimeDayOfWeek(iTime(NULL,PERIOD_D1,d))==4) {
           DrawRECT(y, "Body Thursday ", timOP, prOP, timCL, prCL);
           DrawLINE(true, y, "WickHI Thursday ", timMD, prOP, prCL, prHI, prLO);
           DrawLINE(false, y, "WickLO Thursday ", timMD, prOP, prCL, prHI, prLO); }
       //---
       if (DrawFriday && TimeDayOfWeek(iTime(NULL,PERIOD_D1,d))==5) {
           DrawRECT(y, "Body Friday ", timOP, prOP, timCL, prCL);
           DrawLINE(true, y, "WickHI Friday ", timMD, prOP, prCL, prHI, prLO);
           DrawLINE(false, y, "WickLO Friday ", timMD, prOP, prCL, prHI, prLO); } 
      }
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    }  //*конец цикла*  for (i=limit; i>=zero; i--)
//**************************************************************************//
//**************************************************************************//
//------
return(0);
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                    Bigger TF Candles WeekDay KB+TT                   %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bool DrawRECT(int i, string Name, datetime T1, double P1, datetime T2, double P2)  //, color CLR, int Style, int Size, bool Fill)
{
   string objName = PREF+Name+(string)i;  //TimeToStr(Time[i],TIME_SECONDS)+"_"+DoubleToStr(Close[i],Digits);   
   //---  // имя прямоугольника 
   //ObjectDelete(0,objName);   
   //---  //пред-удаление обектов
   if (!ObjectCreate(0,objName,OBJ_RECTANGLE, 0, T1, P1, T2, P2)) return(false);
   //---  // создаём прямоугольник по заданным координатам 
   //ObjectSetInteger(0,objName,OBJPROP_COLOR, CLR);          // цвет прямоугольника 
   ObjectSetInteger(0,objName,OBJPROP_STYLE, CStyle);         // стиль линий прямоугольника 
   ObjectSetInteger(0,objName,OBJPROP_WIDTH, CSize);          // толщина линий прямоугольника 
   ObjectSetInteger(0,objName,OBJPROP_FILL, BackGround);      // заливка прямоугольника цветом 
   ObjectSetInteger(0,objName,OBJPROP_BACK, false);           // на заднем плане 
   ObjectSetInteger(0,objName,OBJPROP_SELECTABLE, false);     // объект можно выделять
   ObjectSetInteger(0,objName,OBJPROP_SELECTED, CSelected);   // выделить для перемещений 
   ObjectSetInteger(0,objName,OBJPROP_HIDDEN, false);         // скрыт в списке объектов 
   ObjectSetInteger(0,objName,OBJPROP_ZORDER, 0);             // приоритет на нажатие мышью 
   //---
   if (P1 == P2) ObjectSetInteger(0,objName,OBJPROP_COLOR, ColorNT);
   if (P1 < P2)  ObjectSetInteger(0,objName,OBJPROP_COLOR, ColorUP);
   if (P1 > P2)  ObjectSetInteger(0,objName,OBJPROP_COLOR, ColorDN);
//------
return(true);
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                    Bigger TF Candles WeekDay KB+TT                   %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bool DrawLINE(bool HIuLO, int i, string Name, datetime T1, double pOP, double pCL, double pHI, double pLO)  //double P1, datetime T2, double P2)  //, color CLR, int Style, int Size)
{
   string objName = PREF+Name+(string)i;  //TimeToStr(Time[i],TIME_SECONDS)+"_"+DoubleToStr(Close[i],Digits);   
   //---  // имя прямоугольника 
   //ObjectDelete(0,objName);   
   //---  //пред-удаление обектов   
   if (!ObjectCreate(0,objName,OBJ_TREND, 0, T1, 0, T1, 0)) return(false);
   //---  // создаём трендовую линию по заданным координатам 
   //ObjectSetInteger(0,objName,OBJPROP_COLOR, CLR);          // цвет прямоугольника 
   ObjectSetInteger(0,objName,OBJPROP_STYLE, CStyle);         // стиль линий прямоугольника 
   ObjectSetInteger(0,objName,OBJPROP_WIDTH, CSize);          // толщина линий прямоугольника 
   ObjectSetInteger(0,objName,OBJPROP_BACK, false);           // на заднем плане 
   ObjectSetInteger(0,objName,OBJPROP_SELECTABLE, false);     // объект можно выделять
   ObjectSetInteger(0,objName,OBJPROP_SELECTED, CSelected);   // выделить для перемещений 
   ObjectSetInteger(0,objName,OBJPROP_RAY_RIGHT, false);      // продолжить луч вправо 
   ObjectSetInteger(0,objName,OBJPROP_HIDDEN, false);         // скрыт в списке объектов 
   ObjectSetInteger(0,objName,OBJPROP_ZORDER, 0);             // приоритет на нажатие мышью 
   //---
   if (HIuLO) {
       ObjectSetDouble(0,objName,OBJPROP_PRICE1, pHI);
       ObjectSetDouble(0,objName,OBJPROP_PRICE2, fmax(pOP,pCL)); }
   //---
   if (!HIuLO) {
       ObjectSetDouble(0,objName,OBJPROP_PRICE1, fmin(pOP,pCL)); 
       ObjectSetDouble(0,objName,OBJPROP_PRICE2, pLO); }
   //---
   if (pOP == pCL) ObjectSetInteger(0,objName,OBJPROP_COLOR, ColorNT);
   if (pOP < pCL)  ObjectSetInteger(0,objName,OBJPROP_COLOR, ColorUP);
   if (pOP > pCL)  ObjectSetInteger(0,objName,OBJPROP_COLOR, ColorDN);   
//------
return(true);
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                    Bigger TF Candles WeekDay KB+TT                   %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bool DrawTEXT(int i, string Name, string Text, datetime T1, double P1)
{
   string objName = PREF+Name+(string)i;  //TimeToStr(Time[i],TIME_SECONDS)+"_"+DoubleToStr(Close[i],Digits);   
   //---  // имя текста
   //ObjectDelete(0,objName);   
   //---  //пред-удаление обектов   
   if (!ObjectCreate(0,objName,OBJ_TEXT, 0, T1, P1)) return(false);
   //---  // создаём объект "Текст"  
   ObjectSetString(0,objName,OBJPROP_TEXT, Text);           // выводимый текст 
   ObjectSetString(0,objName,OBJPROP_FONT, "Arial");        // шрифт 
   ObjectSetInteger(0,objName,OBJPROP_FONTSIZE, 12);        // размер шрифта 
   ObjectSetInteger(0,objName,OBJPROP_COLOR, clrGold);      // цвет текста
   ObjectSetDouble(0,objName,OBJPROP_ANGLE, 0);             // наклон текста
   ObjectSetInteger(0,objName,OBJPROP_ANCHOR, ANCHOR_LEFT); // угол привязки текста
   ObjectSetInteger(0,objName,OBJPROP_BACK, false);         // на заднем плане 
   ObjectSetInteger(0,objName,OBJPROP_SELECTABLE, false);   // объект можно выделять
   ObjectSetInteger(0,objName,OBJPROP_SELECTED, false);     // выделить для перемещений 
   ObjectSetInteger(0,objName,OBJPROP_HIDDEN, false);       // скрыт в списке объектов 
   ObjectSetInteger(0,objName,OBJPROP_ZORDER, 0);           // приоритет на нажатие мышью 
//------
return(true);
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                    Bigger TF Candles WeekDay KB+TT                   %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
string stringMTF(int perMTF)
{  
   if (perMTF==0)      perMTF=_Period;
   if (perMTF==1)      return("M1");
   if (perMTF==5)      return("M5");
   if (perMTF==15)     return("M15");
   if (perMTF==30)     return("M30");
   if (perMTF==60)     return("H1");
   if (perMTF==240)    return("H4");
   if (perMTF==1440)   return("D1");
   if (perMTF==10080)  return("W1");
   if (perMTF==43200)  return("MN1");
   if (perMTF== 2 || 3  || 4  || 6  || 7  || 8  || 9 ||       /// нестандартные периоды для грфиков Renko
               10 || 11 || 12 || 13 || 14 || 16 || 17 || 18)  return("M"+(string)_Period);
//------
   return("Period error!");
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                    Bigger TF Candles WeekDay KB+TT                   %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%