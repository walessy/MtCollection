//+------------------------------------------------------------------------------------------------------------------+
#property description                                                                   "[!!!-MT4 X-XU-OCTAVEMATH]"
#define Version                                                                                   "[XU-OCTAVEMATH]"
//+------------------------------------------------------------------------------------------------------------------+
#property link        "https://forex-station.com/viewtopic.php?p=1295409935#p1295409935"
#property description "THIS IS A FREE INDICATOR"
#property description "                                                      "
#property description "Welcome to the World of Forex"
#property description "Let light shine out of darkness and illuminate your world"
#property description "and with this freedom leave behind your cave of denial"
#property indicator_chart_window
#include <WinUser32.mqh>

enum fonts{
font1,/*Aharoni*/ font2,/*Algerian*/ font3,/*Andalus*/ font4,/*Angsana New*/ font5,/*AngsanaUPC*/ font6,/*Aparajita*/ font7,/*Arabic Typesetting*/ font8,/*Arial Bold*/ font9,/*Arial Black*/ 
font10,/*Arial Narrow*/ font11,/*Arial Unicode MS*/ font12,/*Baskenville Old Face*/ font13,/*Batang*/ font14,/*BatangChe*/ font15,/*Bauhaus 93*/ font16,/*Bell MT*/ font17,/*Berlin Sans FB*/ font18,/*Berlin Sans FB Demi*/ font19,/*Bernard MT Condensed*/ 
font20,/*Bodoni MT Poster Compressed*/ font21,/*Book Antiqua*/ font22,/*Bookman Old Style*/ font23,/*Bookshelf Symbol 7*/ font24,/*Britannic Bold*/ font25,/*Broadway*/ font26,/*Browallia New*/ font27,/*Browa|liaUPC*/ font28,/*Brush Script MT*/ font29,/*Calibri*/ 
font30,/*Calibri Light*/ font31,/*Californian FB*/ font32,/*Cambria*/ font33,/*Cambria Math*/ font34,/*Candara*/ font35,/*Centaur*/ font36,/*Century*/ font37,/*Century Gothic*/ font38,/*Chiller*/ font39,/*Colonna MT*/ 
font40,/*Comic Sans MS*/ font41,/*Consolas*/ font42,/*Constantia*/ font43,/*Cooper Black*/ font44,/*Corbel*/ font45,/*Cordia New*/ font46,/*CordiaUPC*/ font47,/*Courier*/ font48,/*Courier New*/ font49,/*DaunPenh*/ 
font50,/*David*/ font51,/*DFKai-SB*/ font52,/*DilleniaUPC*/ font53,/*DokChampa*/ font54,/*Dotum*/ font55,/*DotumChe*/ font56,/*Ebrima*/ font57,/*Estrangelo Edessa*/ font58,/*EucrosiaUPC*/ font59,/*Euphemia*/ 
font60,/*FangSong*/ font61,/*Fixedsys*/ font62,/*Footlight MT Light*/ font63,/*Franklin Gothic Medium*/ font64,/*FrankRuehl*/ font65,/*FreesiaUPC*/ font66,/*Freestyle Script*/ font67,/*Gabriola*/ font68,/*Garamond*/ font69,/*Gautami*/ 
font70,/*Georgia*/ font71,/*Gisha*/ font72,/*Gulim*/ font73,/*GulimChe*/ font74,/*Gungsuh*/ font75,/*GungsuhChe*/ font76,/*Haettenschweiler*/ font77,/*Harlow Solid Italic*/ font78,/*Harrington*/ font79,/*High Tower Text*/ 
font80,/*Impact*/ font81,/*Informal Roman*/ font82,/*IrisUPC*/ font83,/*Iskoola Pota*/ font84,/*JasmineUPC*/ font85,/*Jokerman*/ font86,/*Juice ITC*/ font87,/*KaiTi*/ font88,/*Kalinga*/ font89,/*Kartika*/ 
font90,/*Khmer UI*/ font91,/*KodchiangUPC*/ font92,/*Kokila*/ font93,/*Kristen ITC*/ font94,/*Kunstler Script*/ font95,/*Lao UI*/ font96,/*Latha*/ font97,/*Lato*/ font98,/*Lato Light*/ font99,/*Lato Semibold*/ 
font100,/*Leelawadee*/ font101,/*Levenim MT*/ font102,/*LilyUPC*/ font103,/*Lucida Bright*/ font104,/*Lucida Calligraphy*/ font105,/*Lucida Console*/ font106,/*Lucida Fax*/ font107,/*Lucida Handwriting*/ font108,/*Lucida Sans Unicode*/ font109,/*Magneto*/ 
font110,/*Malgun Gothic*/ font111,/*Mangal*/ font112,/*Marlett*/ font113,/*Matura MT Script Capitals*/ font114,/*Meiryo*/ font115,/*Meiryo UI*/ font116,/*Microsoft Himalaya*/ font117,/*Microsoft JhengHei*/ font118,/*Microsoft New Tai Lue*/ font119,/*Microsoft PhagsPa*/ 
font120,/*Microsoft Sans Serif*/ font121,/*Microsoft Tai Le*/ font122,/*Microsoft Uighur*/ font123,/*Microsoft YaHei*/ font124,/*Microsoft Yi Baiti*/ font125,/*MingLiU*/ font126,/*MingLiU_HKSCS*/ font127,/*MingLiU_HKSCS-ExtB*/ font128,/*MingLiU-ExtB*/ font129,/*Miriam*/ 
font130,/*Miriam Fixed*/ font131,/*Mistral*/ font132,/*Modern*/ font133,/*Modern No.20*/ font134,/*Mongolian Baiti*/ font135,/*Monotype Corsiva*/ font136,/*MoolBoran*/ font137,/*MS Gothic*/ font138,/*MS Mincho*/ font139,/*MS Outlook*/ 
font140,/*MS PGothic*/ font141,/*MS PMincho*/ font142,/*MS Reference Sans Serif*/ font143,/*MS Reference Specialty*/ font144,/*MS Sans Serifv*/ font145,/*MS Serif*/ font146,/*MS UI Gothic*/ font147,/*MT Extra*/ font148,/*MV Boli*/ font149,/*Narkisim*/ 
font150,/*Niagara Engraved*/ font151,/*Niagara Solid*/ font152,/*NSimSun*/ font153,/*Nyala*/ font154,/*Old English Text MT*/ font155,/*Onyx*/ font156,/*Palatino Linotype*/ font157,/*Parchment*/ font158,/*Plantagenet Cherokee*/ font159,/*Playbill*/ 
font160,/*PMingLiU*/ font161,/*PMingLiU-ExtB*/ font162,/*Poor Richard*/ font163,/*Raavi*/ font164,/*Ravie*/ font165,/*Rod*/ font166,/*Roman*/ font167,/*Sakkal Majalla*/ font168,/*Script*/ font169,/*Segoe Print*/ 
font170,/*Segoe Script*/ font171,/*Segoe UI*/ font172,/*Segoe UI Light*/ font173,/*Segoe UI Semibold*/ font174,/*Segoe UI Symbol*/ font175,/*Shonar Bangla*/ font176,/*Showcard Gothic*/ font177,/*Shruti*/ font178,/*SimHei*/ font179,/*Simplified Arabic*/ 
font180,/*Simplified Arabic Fixed*/ font181,/*SimSun*/ font182,/*SimSun-ExtB*/ font183,/*Small Fonts*/ font184,/*Snap ITC*/ font185,/*Stencil*/ font186,/*Sylfaen*/ font187,/*Symbol*/ font188,/*System*/ font189,/*Tahoma*/ 
font190,/*Tempus Sans ITC*/ font191,/*Terminal*/ font192,/*Times New Roman*/ font193,/*Traditional Arabic*/ font194,/*Trebuchet MS*/ font195,/*Tunga*/ font196,/*Utsaah*/ font197,/*Vani*/ font198,/*Verdana*/ font199,/*Vijaya*/ 
font200,/*Viner Hand ITC*/ font201,/*Vivaldi*/ font202,/*Vladimir Script*/ font203,/*Vrinda*/ font204,/*Webdings*/ font205,/*Wide Latin*/ font206,/*Wingdings*/ font207,/*Wingdings 2*/ font208,/*Wingdings 3*/ 
};
//fonts buf
string fonts_buf[208]=
{
"Aharoni","Algerian","Andalus","Angsana New","AngsanaUPC","Aparajita","Arabic Typesetting","Arial Bold","Arial Black","Arial Narrow","Arial Unicode MS","Baskenville Old Face","Batang",
"BatangChe","Bauhaus 93","Bell MT","Berlin Sans FB","Berlin Sans FB Demi","Bernard MT Condensed","Bodoni MT Poster Compressed","Book Antiqua","Bookman Old Style","Bookshelf Symbol 7",
"Britannic Bold","Broadway","Browallia New","Browa|liaUPC","Brush Script MT","Calibri","Calibri Light","Californian FB","Cambria","Cambria Math","Candara","Centaur","Century","Century Gothic",
"Chiller","Colonna MT","Comic Sans MS","Consolas","Constantia","Cooper Black","Corbel","Cordia New","CordiaUPC","Courier","Courier New","DaunPenh","David","DFKai-SB","DilleniaUPC","DokChampa",
"Dotum","DotumChe","Ebrima","Estrangelo Edessa","EucrosiaUPC","Euphemia","FangSong","Fixedsys","Footlight MT Light","Franklin Gothic Medium","FrankRuehl","FreesiaUPC","Freestyle Script","Gabriola",
"Garamond","Gautami","Georgia","Gisha","Gulim","GulimChe","Gungsuh","GungsuhChe","Haettenschweiler","Harlow Solid Italic","Harrington","High Tower Text","Impact","Informal Roman","IrisUPC",
"Iskoola Pota","JasmineUPC","Jokerman","Juice ITC","KaiTi","Kalinga","Kartika","Khmer UI","KodchiangUPC","Kokila","Kristen ITC","Kunstler Script","Lao UI","Latha","Lato","Lato Light","Lato Semibold",
"Leelawadee","Levenim MT","LilyUPC","Lucida Bright","Lucida Calligraphy","Lucida Console","Lucida Fax","Lucida Handwriting","Lucida Sans Unicode","Magneto","Malgun Gothic","Mangal","Marlett",
"Matura MT Script Capitals","Meiryo","Meiryo UI","Microsoft Himalaya","Microsoft JhengHei","Microsoft New Tai Lue","Microsoft PhagsPa","Microsoft Sans Serif","Microsoft Tai Le","Microsoft Uighur",
"Microsoft YaHei","Microsoft Yi Baiti","MingLiU","MingLiU_HKSCS","MingLiU_HKSCS-ExtB","MingLiU-ExtB","Miriam","Miriam Fixed","Mistral","Modern","Modern No.20","Mongolian Baiti","Monotype Corsiva",
"MoolBoran","MS Gothic","MS Mincho","MS Outlook","MS PGothic","MS PMincho","MS Reference Sans Serif","MS Reference Specialty","MS Sans Serifv","MS Serif","MS UI Gothic","MT Extra","MV Boli","Narkisim",
"Niagara Engraved","Niagara Solid","NSimSun","Nyala","Old English Text MT","Onyx","Palatino Linotype","Parchment","Plantagenet Cherokee","Playbill","PMingLiU","PMingLiU-ExtB","Poor Richard","Raavi",
"Ravie","Rod","Roman","Sakkal Majalla","Script","Segoe Print","Segoe Script","Segoe UI","Segoe UI Light","Segoe UI Semibold","Segoe UI Symbol","Shonar Bangla","Showcard Gothic","Shruti","SimHei",
"Simplified Arabic","Simplified Arabic Fixed","SimSun","SimSun-ExtB","Small Fonts","Snap ITC","Stencil","Sylfaen","Symbol","System","Tahoma","Tempus Sans ITC","Terminal","Times New Roman",
"Traditional Arabic","Trebuchet MS","Tunga","Utsaah","Vani","Verdana","Vijaya","Viner Hand ITC","Vivaldi","Vladimir Script","Vrinda","Webdings","Wide Latin","Wingdings","Wingdings 2","Wingdings 3"
};

//+------------------------------------------------------------------------------------------------------------------+
    extern int HalfOctJump                     = 0;
   extern bool AutoRefresh                     = false;//XARD: Req for Mathlines
        extern ENUM_TIMEFRAMES RefreshPeriod   = PERIOD_M15; int hWindow=0,oldBars=0;
//+------------------------------------------------------------------------------------------------------------------+
          bool showComments=false,showFrankalines=false;
          bool showMMtext=true,showMMlines=false;
   extern bool showBMtext=true,showBMlines=false;
  extern color clrFranka=clrGray;
 extern string A1="Scale: 1,2,4,8,16,32,64";
 extern string A2="HK50 & WS30 work best at 4";
 extern string A3="Gold & DAX30 works best at 8";
 extern string A4="Currencies work best at 16 or 8";
    extern int Scale=4,MMLwidth=2;
        string space="                        ";
           int ShowBars=1800,CurPeriod=0,LABELmove=1,LABELsize=14;
           int Text_MML_font = font148, Text_BML_font = font41; 
 extern string msg1="Show bml lines up to this timeframe";  
        extern ENUM_TIMEFRAMES BMLTF=PERIOD_M30;
        extern ENUM_TIMEFRAMES FrankaTF=PERIOD_H4;
      datetime time1=Time[ShowBars],time2=Time[0];  double fractal,DecNos; int BarBegin,BarEnd;  string IDx;
//template code start1
extern string             button_note1          = "------------------------------";
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_LOWER; // chart btn_corner for anchoring
extern string             btn_text              = "MATH";
extern string             btn_Font              = "Impact";
extern int                btn_FontSize          = 14;                             //btn__font size
extern color              btn_text_ON_color     = clrWhite;
extern color              btn_text_OFF_color    = C'120,120,120';
extern color              btn_background_color  = clrDarkRed;
extern color              btn_border_color      = clrDarkRed;
extern int                button_x              = 496;                                     //btn__x
extern int                button_y              = 52;                                     //btn__y
extern int                btn_Width             = 86;                                 //btn__width
extern int                btn_Height            = 26;                                //btn__height
extern string             UniqueButtonID        = "OctaveMath1";
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
//   IndicatorShortName(IndicatorName);
//   IndicatorDigits(Digits);
   
   double val;
   if (GlobalVariableGet(IndicatorName + "_visibility", val))
      show_data = val != 0;

   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = IndicatorObjPrefix + UniqueButtonID;
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
         }
      else
         {
           ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_text_OFF_color);
           deinit2();
         }
   return(0);
}
//+------------------------------------------------------------------------------------------------------------------+
   int init2(){IDx = "FX PANEL3";  IndicatorDigits(Digits); IndicatorShortName(IDx);
   if(Period()>PERIOD_W1)
     {showFrankalines=false; showMMtext=false; showMMlines=false; showBMtext=false; showBMlines=false;}
//+------------------------------------------------------------------------------------------------------------------+   
   if(AutoRefresh)  hWindow=WindowHandle(Symbol(),Period());  oldBars=iBars(NULL,RefreshPeriod);
//+------------------------------------------------------------------------------------------------------------------+
        if(StringFind  (Symbol(),"JPY",0) != -1)   DecNos=2;
   else if(StringSubstr(Symbol(),0,5)=="UKOil")    DecNos=2;
   else if(StringSubstr(Symbol(),0,6)=="BTCUSD")   DecNos=1;
   else if(StringSubstr(Symbol(),0,7)=="CHINA50")  DecNos=0;
   else if(StringSubstr(Symbol(),0,6)=="US2000")   DecNos=1;
   else if(StringSubstr(Symbol(),0,5)=="US500")    DecNos=1;
   else if(StringSubstr(Symbol(),0,6)=="ETHUSD")   DecNos=2;
   else if(StringSubstr(Symbol(),0,6)=="LTCUSD")   DecNos=3;
   else if(StringSubstr(Symbol(),0,6)=="USOUSD")   DecNos=3;
   else if(StringSubstr(Symbol(),0,6)=="SPX500")   DecNos=1;
   else if(StringSubstr(Symbol(),0,8)=="USDOLLAR") DecNos=3;
   else if(StringSubstr(Symbol(),0,5)=="JP225")    DecNos=0;
   else if(StringSubstr(Symbol(),0,4)=="HK50")     DecNos=0;
   else if(StringSubstr(Symbol(),0,5)=="DAX30")    DecNos=0;
   else if(StringSubstr(Symbol(),0,5)=="UK100")    DecNos=0;
   else if(StringSubstr(Symbol(),0,7)=="FTSE100")  DecNos=1;
   else if(StringSubstr(Symbol(),0,6)=="XAUUSD")   DecNos=1;
   else if(StringSubstr(Symbol(),0,6)=="XAGUSD")   DecNos=3;
   else if(StringSubstr(Symbol(),0,6)=="USDMXN")   DecNos=3;
   else if(StringSubstr(Symbol(),0,6)=="NDX100")   DecNos=1;
   else if(StringSubstr(Symbol(),0,5)=="#US30")    DecNos=0;
   else if(StringSubstr(Symbol(),0,4)=="US30")     DecNos=0;
   else if(StringSubstr(Symbol(),0,4)=="WS30")     DecNos=0; else DecNos=4; 
//+------------------------------------------------------------------------------------------------------------------+
   return(0);}
//+------------------------------------------------------------------------------------------------------------------+
   int deinit2(){CleanUpOnIsle9(); Comment(" "); return(0);}//End deinit
//+----OnCalculate Function------------------------------------------------------------------------------------------+
/*
   int OnCalculate(const int rates_total,
                   const int prev_calculated,
                   const datetime &time[],
                   const double &open[],
                   const double &high[],
                   const double &low[],
                   const double &close[],
                   const long &tick_volume[],
                   const long &volume[],
                   const int &spread[]){
                   */
int start2()
{                   
//+---AutoRefresh----------------------------------------------------------------------------------------------------+
   if(AutoRefresh){if(oldBars<iBars(NULL,RefreshPeriod) && hWindow!=0){int message;  switch(Period()){
   case     1: message= 33137; break;  case     5: message= 33138; break;  case    15: message= 33139; break;
   case    30: message= 33140; break;  case    60: message= 33135; break;  case   240: message= 33136; break;
   case  1440: message= 33134; break;  case 10080: message= 33141; break;  default: message= 33137; break;}
   PostMessageA (hWindow,WM_COMMAND,33141,0);  PostMessageA (hWindow,WM_COMMAND,message,0);
   oldBars=iBars(NULL,RefreshPeriod);}}//End AutoRefresh
//+------------------------------------------------------------------------------------------------------------------+
   BarBegin=iBarShift(NULL,0,time1-Period()*60);  BarEnd=iBarShift(NULL,0,time2);
//+----DETERMINE FRACTAL---------------------------------------------------------------------------------------------+ 
   double price=NormalizeDouble(MarketInfo(Symbol(),MODE_BID),Digits);
   if(price<=250000 && price>25000) fractal=100000; else
   if(price<=25000 && price>2500) fractal=10000;  else
   if(price<=2500 && price>250) fractal=1000;   else
   if(price<=250 && price>25) fractal=100;    else
   if(price<=25 && price>12.5) fractal=12.5;  else
   if(price<=12.5 && price>6.25) fractal=12.5;  else
   if(price<=6.25 && price>3.125) fractal=6.25;  else
   if(price<=3.125 && price>1.5625) fractal=3.125;  else
   if(price<=1.5625 && price>0.390625) fractal=1.5625;  else
   if(price<=0.390625 && price>0) fractal=0.1953125;
   //XARD: Auto settings
   if(StringFind  (Symbol(),"JPY",0) != -1)        Scale=16;
   else if(StringSubstr(Symbol(),0,6)=="BTCUSD")   Scale=0;
   else if(StringSubstr(Symbol(),0,5)=="US500")    Scale=32;
   else if(StringSubstr(Symbol(),0,6)=="USOUSD")   Scale=1;
   else if(StringSubstr(Symbol(),0,6)=="UsaInd")   Scale=32;
   else if(StringSubstr(Symbol(),0,4)=="HK50")     Scale=4;
   else if(StringSubstr(Symbol(),0,5)=="JP225")    Scale=0;
   else if(StringSubstr(Symbol(),0,7)=="FTSE100")  Scale=8;
   else if(StringSubstr(Symbol(),0,6)=="XAUUSD")   Scale=4;
   else if(StringSubstr(Symbol(),0,6)=="NDX100")   Scale=8;
   else if(StringSubstr(Symbol(),0,6)=="US2000")   Scale=4;
   else if(StringSubstr(Symbol(),0,6)=="ASX200")   Scale=8;
   else if(StringSubstr(Symbol(),0,5)=="DAX30")    Scale=8;
   else if(StringSubstr(Symbol(),0,5)=="#US30")    Scale=32;
   else if(StringSubstr(Symbol(),0,4)=="US30")     Scale=32;
   else if(StringSubstr(Symbol(),0,4)=="WS30")     Scale=32; else Scale=32;
//+------------------------------------------------------------------------------------------------------------------+
   double mm0,mml1,mml2,mml3,mml4,mml5,mml6,mml7,mml8,mml9,mml10,mml11,mml12,mml13;
   double mml12bm1,mml12bm2,mml12bm3,mml12bm4,mml12bm5,mml12bm6,mml12bm7;
   double mml11bm1,mml11bm2,mml11bm3,mml11bm4,mml11bm5,mml11bm6,mml11bm7;
   double mml10bm1,mml10bm2,mml10bm3,mml10bm4,mml10bm5,mml10bm6,mml10bm7;
   double mml9bm1,mml9bm2,mml9bm3,mml9bm4,mml9bm5,mml9bm6,mml9bm7;
   double mml8bm1,mml8bm2,mml8bm3,mml8bm4,mml8bm5,mml8bm6,mml8bm7;
   double mml7bm1,mml7bm2,mml7bm3,mml7bm4,mml7bm5,mml7bm6,mml7bm7;
   double mml6bm1,mml6bm2,mml6bm3,mml6bm4,mml6bm5,mml6bm6,mml6bm7;
   double mml5bm1,mml5bm2,mml5bm3,mml5bm4,mml5bm5,mml5bm6,mml5bm7;
   double mml4bm1,mml4bm2,mml4bm3,mml4bm4,mml4bm5,mml4bm6,mml4bm7;
   double mml3bm1,mml3bm2,mml3bm3,mml3bm4,mml3bm5,mml3bm6,mml3bm7;
   double mml2bm1,mml2bm2,mml2bm3,mml2bm4,mml2bm5,mml2bm6,mml2bm7;
   double mml1bm1,mml1bm2,mml1bm3,mml1bm4,mml1bm5,mml1bm6,mml1bm7;
   double mml33m0,mml66m0,mml33m1,mml66m1,mml33m2,mml66m2,mml33m3,mml66m3;
   double mml33m4,mml66m4,mml33m5,mml66m5,mml33m6,mml66m6,mml33m7,mml66m7;
   double mml33m8,mml66m8,mml33m9,mml66m9,mml33m10,mml66m10,mml33m11,mml66m11;
//+----MML Octave Algorithm------------------------------------------------------------------------------------------+
     mm0=(MathFloor(price/(fractal/Scale))*(fractal/Scale))+(HalfOctJump*(fractal/Scale)/2);
//+------------------------------------------------------------------------------------------------------------------+
    mml1=mm0-((fractal/(Scale*8))*2);
    mml2=mm0-((fractal/(Scale*8))*1);
    mml3=mm0+((fractal/(Scale*8))*0);
    mml4=mm0+((fractal/(Scale*8))*1);
    mml5=mm0+((fractal/(Scale*8))*2);
    mml6=mm0+((fractal/(Scale*8))*3);
    mml7=mm0+((fractal/(Scale*8))*4);
    mml8=mm0+((fractal/(Scale*8))*5);
    mml9=mm0+((fractal/(Scale*8))*6);
   mml10=mm0+((fractal/(Scale*8))*7);
   mml11=mm0+((fractal/(Scale*8))*8);
   mml12=mm0+((fractal/(Scale*8))*9);
   mml13=mm0+((fractal/(Scale*8))*10);
    CleanUpOnIsle9();
//+----showMML FUNCTION----------------------------------------------------------------------------------------------+
   if(showMMtext){
   MMLtext(IDx+"Xard01",space+"+2/8th "+DoubleToStr(mml13,DecNos),clrRed,       mml13,0);
   MMLtext(IDx+"Xard02",space+"+1/8th "+DoubleToStr(mml12,DecNos),clrOrangeRed, mml12,0);
   MMLtext(IDx+"Xard03",space+"8/8th  "+DoubleToStr(mml11,DecNos),clrDodgerBlue,mml11,0);
   MMLtext(IDx+"Xard04",space+"7/8th  "+DoubleToStr(mml10,DecNos),clrGold,      mml10,0);
   MMLtext(IDx+"Xard05",space+"6/8th  "+DoubleToStr(mml9,DecNos),clrHotPink,    mml9,0);
   MMLtext(IDx+"Xard06",space+"5/8th  "+DoubleToStr(mml8,DecNos),clrLimeGreen,  mml8,0);
   MMLtext(IDx+"Xard07",space+"4/8th  "+DoubleToStr(mml7,DecNos),clrSnow,       mml7,0);
   MMLtext(IDx+"Xard08",space+"3/8th  "+DoubleToStr(mml6,DecNos),clrLimeGreen,  mml6,0);
   MMLtext(IDx+"Xard09",space+"2/8th  "+DoubleToStr(mml5,DecNos),clrHotPink,    mml5,0);
   MMLtext(IDx+"Xard10",space+"1/8th  "+DoubleToStr(mml4,DecNos),clrGold,       mml4,0);
   MMLtext(IDx+"Xard11",space+"0/8th  "+DoubleToStr(mml3,DecNos),clrDodgerBlue, mml3,0);
   MMLtext(IDx+"Xard12",space+"-1/8th "+DoubleToStr(mml2,DecNos),clrOrangeRed,  mml2,0);
   MMLtext(IDx+"Xard13",space+"-2/8th "+DoubleToStr(mml1,DecNos),clrRed,        mml1,0);}
   //+----
   if(showMMlines){ 
   PlotMML(IDx+"Xard20",mml13,mml13,clrRed,0);
   PlotMML(IDx+"Xard21",mml12,mml12,clrOrangeRed,0);
   PlotMML(IDx+"Xard22",mml11,mml11,clrDodgerBlue,0);
   PlotMML(IDx+"Xard23",mml10,mml10,clrGold,0);
   PlotMML(IDx+"Xard24",mml9,mml9,clrHotPink,0);
   PlotMML(IDx+"Xard25",mml8,mml8,clrLimeGreen,0);
   PlotMML(IDx+"Xard26",mml7,mml7,clrSnow,0);
   PlotMML(IDx+"Xard27",mml6,mml6,clrLimeGreen,0);
   PlotMML(IDx+"Xard28",mml5,mml5,clrHotPink,0);
   PlotMML(IDx+"Xard29",mml4,mml4,clrGold,0);
   PlotMML(IDx+"Xard30",mml3,mml3,clrDodgerBlue,0);
   PlotMML(IDx+"Xard31",mml2,mml2,clrOrangeRed,0);
   PlotMML(IDx+"Xard32",mml1,mml1,clrRed,0);}
//+----BML Octave mml12----------------------------------------------------------------------------------------------+
   mml12bm1 = mml12+((fractal/(Scale*64))*1);
   mml12bm2 = mml12+((fractal/(Scale*64))*2);
   mml12bm3 = mml12+((fractal/(Scale*64))*3);
   mml12bm4 = mml12+((fractal/(Scale*64))*4);
   mml12bm5 = mml12+((fractal/(Scale*64))*5);
   mml12bm6 = mml12+((fractal/(Scale*64))*6);
   mml12bm7 = mml12+((fractal/(Scale*64))*7);
//+----BML Octave mml11
   mml11bm1 = mml11+((fractal/(Scale*64))*1);
   mml11bm2 = mml11+((fractal/(Scale*64))*2);
   mml11bm3 = mml11+((fractal/(Scale*64))*3);
   mml11bm4 = mml11+((fractal/(Scale*64))*4);
   mml11bm5 = mml11+((fractal/(Scale*64))*5);
   mml11bm6 = mml11+((fractal/(Scale*64))*6);
   mml11bm7 = mml11+((fractal/(Scale*64))*7);
//+----BML Octave mml10
   mml10bm1 = mml10+((fractal/(Scale*64))*1);
   mml10bm2 = mml10+((fractal/(Scale*64))*2);
   mml10bm3 = mml10+((fractal/(Scale*64))*3);
   mml10bm4 = mml10+((fractal/(Scale*64))*4);
   mml10bm5 = mml10+((fractal/(Scale*64))*5);
   mml10bm6 = mml10+((fractal/(Scale*64))*6);
   mml10bm7 = mml10+((fractal/(Scale*64))*7);
//+----BML Octave mml9
   mml9bm1 = mml9+((fractal/(Scale*64))*1);
   mml9bm2 = mml9+((fractal/(Scale*64))*2);
   mml9bm3 = mml9+((fractal/(Scale*64))*3);
   mml9bm4 = mml9+((fractal/(Scale*64))*4);
   mml9bm5 = mml9+((fractal/(Scale*64))*5);
   mml9bm6 = mml9+((fractal/(Scale*64))*6);
   mml9bm7 = mml9+((fractal/(Scale*64))*7);
//+----BML Octave mml8
   mml8bm1 = mml8+((fractal/(Scale*64))*1);
   mml8bm2 = mml8+((fractal/(Scale*64))*2);
   mml8bm3 = mml8+((fractal/(Scale*64))*3);
   mml8bm4 = mml8+((fractal/(Scale*64))*4);
   mml8bm5 = mml8+((fractal/(Scale*64))*5);
   mml8bm6 = mml8+((fractal/(Scale*64))*6);
   mml8bm7 = mml8+((fractal/(Scale*64))*7);
//+----BML Octave mml7
   mml7bm1 = mml7+((fractal/(Scale*64))*1);
   mml7bm2 = mml7+((fractal/(Scale*64))*2);
   mml7bm3 = mml7+((fractal/(Scale*64))*3);
   mml7bm4 = mml7+((fractal/(Scale*64))*4);
   mml7bm5 = mml7+((fractal/(Scale*64))*5);
   mml7bm6 = mml7+((fractal/(Scale*64))*6);
   mml7bm7 = mml7+((fractal/(Scale*64))*7);
//+----BML Octave mml6
   mml6bm1 = mml6+((fractal/(Scale*64))*1);
   mml6bm2 = mml6+((fractal/(Scale*64))*2);
   mml6bm3 = mml6+((fractal/(Scale*64))*3);
   mml6bm4 = mml6+((fractal/(Scale*64))*4);
   mml6bm5 = mml6+((fractal/(Scale*64))*5);
   mml6bm6 = mml6+((fractal/(Scale*64))*6);
   mml6bm7 = mml6+((fractal/(Scale*64))*7);
//+----BML Octave mml5
   mml5bm1 = mml5+((fractal/(Scale*64))*1);
   mml5bm2 = mml5+((fractal/(Scale*64))*2);
   mml5bm3 = mml5+((fractal/(Scale*64))*3);
   mml5bm4 = mml5+((fractal/(Scale*64))*4);
   mml5bm5 = mml5+((fractal/(Scale*64))*5);
   mml5bm6 = mml5+((fractal/(Scale*64))*6);
   mml5bm7 = mml5+((fractal/(Scale*64))*7);
//+----BML Octave mml4
   mml4bm1 = mml4+((fractal/(Scale*64))*1);
   mml4bm2 = mml4+((fractal/(Scale*64))*2);
   mml4bm3 = mml4+((fractal/(Scale*64))*3);
   mml4bm4 = mml4+((fractal/(Scale*64))*4);
   mml4bm5 = mml4+((fractal/(Scale*64))*5);
   mml4bm6 = mml4+((fractal/(Scale*64))*6);
   mml4bm7 = mml4+((fractal/(Scale*64))*7);
//+----BML Octave mml3
   mml3bm1 = mml3+((fractal/(Scale*64))*1);
   mml3bm2 = mml3+((fractal/(Scale*64))*2);
   mml3bm3 = mml3+((fractal/(Scale*64))*3);
   mml3bm4 = mml3+((fractal/(Scale*64))*4);
   mml3bm5 = mml3+((fractal/(Scale*64))*5);
   mml3bm6 = mml3+((fractal/(Scale*64))*6);
   mml3bm7 = mml3+((fractal/(Scale*64))*7);
//+----BML Octave mml2
   mml2bm1 = mml2+((fractal/(Scale*64))*1);
   mml2bm2 = mml2+((fractal/(Scale*64))*2);
   mml2bm3 = mml2+((fractal/(Scale*64))*3);
   mml2bm4 = mml2+((fractal/(Scale*64))*4);
   mml2bm5 = mml2+((fractal/(Scale*64))*5);
   mml2bm6 = mml2+((fractal/(Scale*64))*6);
   mml2bm7 = mml2+((fractal/(Scale*64))*7);
//+----BML Octave mml1
   mml1bm1 = mml1+((fractal/(Scale*64))*1);
   mml1bm2 = mml1+((fractal/(Scale*64))*2);
   mml1bm3 = mml1+((fractal/(Scale*64))*3);
   mml1bm4 = mml1+((fractal/(Scale*64))*4);
   mml1bm5 = mml1+((fractal/(Scale*64))*5);
   mml1bm6 = mml1+((fractal/(Scale*64))*6);
   mml1bm7 = mml1+((fractal/(Scale*64))*7);
//+----FKL Franka lines
   mml33m0 = mml1+((mml2-mml1)*.333);
   mml66m0 = mml1+((mml2-mml1)*.666);
   mml33m1 = mml2+((mml3-mml2)*.333);
   mml66m1 = mml2+((mml3-mml2)*.666);
   mml33m2 = mml3+((mml4-mml3)*.333);
   mml66m2 = mml3+((mml4-mml3)*.666);
   mml33m3 = mml4+((mml5-mml4)*.333);
   mml66m3 = mml4+((mml5-mml4)*.666);
//+---
   mml33m4 = mml5+((mml6-mml5)*.333);
   mml66m4 = mml5+((mml6-mml5)*.666);
   mml33m5 = mml6+((mml7-mml6)*.333);
   mml66m5 = mml6+((mml7-mml6)*.666);
   mml33m6 = mml7+((mml8-mml7)*.333);
   mml66m6 = mml7+((mml8-mml7)*.666);
   mml33m7 = mml8+((mml9-mml8)*.333);
   mml66m7 = mml8+((mml9-mml8)*.666);
//+---
   mml33m8 = mml9+((mml10-mml9)*.333);
   mml66m8 = mml9+((mml10-mml9)*.666);
   mml33m9 = mml10+((mml11-mml10)*.333);
   mml66m9 = mml10+((mml11-mml10)*.666);
   mml33m10 = mml11+((mml12-mml11)*.333);
   mml66m10 = mml11+((mml12-mml11)*.666);
   mml33m11 = mml12+((mml12-mml11)*.333);
   mml66m11 = mml12+((mml12-mml11)*.666);
//+----showFKL FUNCTION----------------------------------------------------------------------------------------------+   
   if(showFrankalines){if(_Period<=FrankaTF){
   PlotFKL(IDx+"Xard501",mml33m0,mml33m0,clrFranka,0);
   PlotFKL(IDx+"Xard502",mml66m0,mml66m0,clrFranka,0);
   PlotFKL(IDx+"Xard503",mml33m1,mml33m1,clrFranka,0);
   PlotFKL(IDx+"Xard504",mml66m1,mml66m1,clrFranka,0);
   PlotFKL(IDx+"Xard505",mml33m2,mml33m2,clrFranka,0);
   PlotFKL(IDx+"Xard506",mml66m2,mml66m2,clrFranka,0);
   PlotFKL(IDx+"Xard507",mml33m3,mml33m3,clrFranka,0);
   PlotFKL(IDx+"Xard508",mml66m3,mml66m3,clrFranka,0);
//+---
   PlotFKL(IDx+"Xard601",mml33m4,mml33m4,clrFranka,0);
   PlotFKL(IDx+"Xard602",mml66m4,mml66m4,clrFranka,0);
   PlotFKL(IDx+"Xard603",mml33m5,mml33m5,clrFranka,0);
   PlotFKL(IDx+"Xard604",mml66m5,mml66m5,clrFranka,0);
   PlotFKL(IDx+"Xard605",mml33m6,mml33m6,clrFranka,0);
   PlotFKL(IDx+"Xard606",mml66m6,mml66m6,clrFranka,0);
   PlotFKL(IDx+"Xard607",mml33m7,mml33m7,clrFranka,0);
   PlotFKL(IDx+"Xard608",mml66m7,mml66m7,clrFranka,0);
//+---
   PlotFKL(IDx+"Xard701",mml33m8,mml33m8,clrFranka,0);
   PlotFKL(IDx+"Xard702",mml66m8,mml66m8,clrFranka,0);
   PlotFKL(IDx+"Xard703",mml33m9,mml33m9,clrFranka,0);
   PlotFKL(IDx+"Xard704",mml66m9,mml66m9,clrFranka,0);
   PlotFKL(IDx+"Xard705",mml33m10,mml33m10,clrFranka,0);
   PlotFKL(IDx+"Xard706",mml66m10,mml66m10,clrFranka,0);
   PlotFKL(IDx+"Xard707",mml33m11,mml33m11,clrFranka,0);
   PlotFKL(IDx+"Xard708",mml66m11,mml66m11,clrFranka,0);}}
//+----showMML FUNCTION----------------------------------------------------------------------------------------------+   
   if(showBMlines){//if(_Period<=BMLTF){
//+----BML Octave mml12----------------------------------------------------------------------------------------------+
   PlotBML(IDx+"Xard241",mml12bm7,mml12bm7,clrGold,0);
   PlotBML(IDx+"Xard242",mml12bm6,mml12bm6,clrHotPink,0);
   PlotBML(IDx+"Xard243",mml12bm5,mml12bm5,clrLimeGreen,0);
   PlotBML(IDx+"Xard244",mml12bm4,mml12bm4,clrSnow,0);
   PlotBML(IDx+"Xard245",mml12bm3,mml12bm3,clrLimeGreen,0);
   PlotBML(IDx+"Xard246",mml12bm2,mml12bm2,clrHotPink,0);
   PlotBML(IDx+"Xard247",mml12bm1,mml12bm1,clrGold,0);
//+----BML Octave mml11----------------------------------------------------------------------------------------------+
   PlotBML(IDx+"Xard261",mml11bm7,mml11bm7,clrGold,0);
   PlotBML(IDx+"Xard262",mml11bm6,mml11bm6,clrHotPink,0);
   PlotBML(IDx+"Xard263",mml11bm5,mml11bm5,clrLimeGreen,0);
   PlotBML(IDx+"Xard264",mml11bm4,mml11bm4,clrSnow,0);
   PlotBML(IDx+"Xard265",mml11bm3,mml11bm3,clrLimeGreen,0);
   PlotBML(IDx+"Xard266",mml11bm2,mml11bm2,clrHotPink,0);
   PlotBML(IDx+"Xard267",mml11bm1,mml11bm1,clrGold,0);
//+----BML Octave mml10----------------------------------------------------------------------------------------------+
   PlotBML(IDx+"Xard221",mml10bm7,mml10bm7,clrGold,0);
   PlotBML(IDx+"Xard222",mml10bm6,mml10bm6,clrHotPink,0);
   PlotBML(IDx+"Xard223",mml10bm5,mml10bm5,clrLimeGreen,0);
   PlotBML(IDx+"Xard224",mml10bm4,mml10bm4,clrSnow,0);
   PlotBML(IDx+"Xard225",mml10bm3,mml10bm3,clrLimeGreen,0);
   PlotBML(IDx+"Xard226",mml10bm2,mml10bm2,clrHotPink,0);
   PlotBML(IDx+"Xard227",mml10bm1,mml10bm1,clrGold,0);
//+----BML Octave mml9-----------------------------------------------------------------------------------------------+
   PlotBML(IDx+"Xard201",mml9bm7,mml9bm7,clrGold,0);
   PlotBML(IDx+"Xard202",mml9bm6,mml9bm6,clrHotPink,0);
   PlotBML(IDx+"Xard203",mml9bm5,mml9bm5,clrLimeGreen,0);
   PlotBML(IDx+"Xard204",mml9bm4,mml9bm4,clrSnow,0);
   PlotBML(IDx+"Xard205",mml9bm3,mml9bm3,clrLimeGreen,0);
   PlotBML(IDx+"Xard206",mml9bm2,mml9bm2,clrHotPink,0);
   PlotBML(IDx+"Xard207",mml9bm1,mml9bm1,clrGold,0);
//+----BML Octave mml8-----------------------------------------------------------------------------------------------+
   PlotBML(IDx+"Xard181",mml8bm7,mml8bm7,clrGold,0);
   PlotBML(IDx+"Xard182",mml8bm6,mml8bm6,clrHotPink,0);
   PlotBML(IDx+"Xard183",mml8bm5,mml8bm5,clrLimeGreen,0);
   PlotBML(IDx+"Xard184",mml8bm4,mml8bm4,clrSnow,0);
   PlotBML(IDx+"Xard185",mml8bm3,mml8bm3,clrLimeGreen,0);
   PlotBML(IDx+"Xard186",mml8bm2,mml8bm2,clrHotPink,0);
   PlotBML(IDx+"Xard187",mml8bm1,mml8bm1,clrGold,0);
//+----BML Octave mml7-----------------------------------------------------------------------------------------------+
   PlotBML(IDx+"Xard161",mml7bm7,mml7bm7,clrGold,0);
   PlotBML(IDx+"Xard162",mml7bm6,mml7bm6,clrHotPink,0);
   PlotBML(IDx+"Xard163",mml7bm5,mml7bm5,clrLimeGreen,0);
   PlotBML(IDx+"Xard164",mml7bm4,mml7bm4,clrSnow,0);
   PlotBML(IDx+"Xard165",mml7bm3,mml7bm3,clrLimeGreen,0);
   PlotBML(IDx+"Xard166",mml7bm2,mml7bm2,clrHotPink,0);
   PlotBML(IDx+"Xard167",mml7bm1,mml7bm1,clrGold,0);
//+----BML Octave mml6-----------------------------------------------------------------------------------------------+
   PlotBML(IDx+"Xard141",mml6bm7,mml6bm7,clrGold,0);
   PlotBML(IDx+"Xard142",mml6bm6,mml6bm6,clrHotPink,0);
   PlotBML(IDx+"Xard143",mml6bm5,mml6bm5,clrLimeGreen,0);
   PlotBML(IDx+"Xard144",mml6bm4,mml6bm4,clrSnow,0);
   PlotBML(IDx+"Xard145",mml6bm3,mml6bm3,clrLimeGreen,0);
   PlotBML(IDx+"Xard146",mml6bm2,mml6bm2,clrHotPink,0);
   PlotBML(IDx+"Xard147",mml6bm1,mml6bm1,clrGold,0);
//+----BML Octave mml5-----------------------------------------------------------------------------------------------+
   PlotBML(IDx+"Xard121",mml5bm7,mml5bm7,clrGold,0);
   PlotBML(IDx+"Xard122",mml5bm6,mml5bm6,clrHotPink,0);
   PlotBML(IDx+"Xard123",mml5bm5,mml5bm5,clrLimeGreen,0);
   PlotBML(IDx+"Xard124",mml5bm4,mml5bm4,clrSnow,0);
   PlotBML(IDx+"Xard125",mml5bm3,mml5bm3,clrLimeGreen,0);
   PlotBML(IDx+"Xard126",mml5bm2,mml5bm2,clrHotPink,0);
   PlotBML(IDx+"Xard127",mml5bm1,mml5bm1,clrGold,0);
//+----BML Octave mml4-----------------------------------------------------------------------------------------------+
   PlotBML(IDx+"Xard101",mml4bm7,mml4bm7,clrGold,0);
   PlotBML(IDx+"Xard102",mml4bm6,mml4bm6,clrHotPink,0);
   PlotBML(IDx+"Xard103",mml4bm5,mml4bm5,clrLimeGreen,0);
   PlotBML(IDx+"Xard104",mml4bm4,mml4bm4,clrSnow,0);
   PlotBML(IDx+"Xard105",mml4bm3,mml4bm3,clrLimeGreen,0);
   PlotBML(IDx+"Xard106",mml4bm2,mml4bm2,clrHotPink,0);
   PlotBML(IDx+"Xard107",mml4bm1,mml4bm1,clrGold,0);
//+----BML Octave mml3-----------------------------------------------------------------------------------------------+
   PlotBML(IDx+"Xard81",mml3bm7,mml3bm7,clrGold,0);
   PlotBML(IDx+"Xard82",mml3bm6,mml3bm6,clrHotPink,0);
   PlotBML(IDx+"Xard83",mml3bm5,mml3bm5,clrLimeGreen,0);
   PlotBML(IDx+"Xard84",mml3bm4,mml3bm4,clrSnow,0);
   PlotBML(IDx+"Xard85",mml3bm3,mml3bm3,clrLimeGreen,0);
   PlotBML(IDx+"Xard86",mml3bm2,mml3bm2,clrHotPink,0);
   PlotBML(IDx+"Xard87",mml3bm1,mml3bm1,clrGold,0);
//+----BML Octave mml2-----------------------------------------------------------------------------------------------+
   PlotBML(IDx+"Xard61",mml2bm7,mml2bm7,clrGold,0);
   PlotBML(IDx+"Xard62",mml2bm6,mml2bm6,clrHotPink,0);
   PlotBML(IDx+"Xard63",mml2bm5,mml2bm5,clrLimeGreen,0);
   PlotBML(IDx+"Xard64",mml2bm4,mml2bm4,clrSnow,0);
   PlotBML(IDx+"Xard65",mml2bm3,mml2bm3,clrLimeGreen,0);
   PlotBML(IDx+"Xard66",mml2bm2,mml2bm2,clrHotPink,0);
   PlotBML(IDx+"Xard67",mml2bm1,mml2bm1,clrGold,0);
//+----BML Octave mml1-----------------------------------------------------------------------------------------------+
   PlotBML(IDx+"Xard41",mml1bm7,mml1bm7,clrGold,0);
   PlotBML(IDx+"Xard42",mml1bm6,mml1bm6,clrHotPink,0);
   PlotBML(IDx+"Xard43",mml1bm5,mml1bm5,clrLimeGreen,0);
   PlotBML(IDx+"Xard44",mml1bm4,mml1bm4,clrSnow,0);
   PlotBML(IDx+"Xard45",mml1bm3,mml1bm3,clrLimeGreen,0);
   PlotBML(IDx+"Xard46",mml1bm2,mml1bm2,clrHotPink,0);
   PlotBML(IDx+"Xard47",mml1bm1,mml1bm1,clrGold,0);}//}
//+-----
   if(showBMtext){//if(_Period<=BMLTF){
   BMLtext(IDx+"Xard251",space+"7/8th  "+DoubleToStr(mml12bm7,DecNos),clrGold,      mml12bm7,0);
   BMLtext(IDx+"Xard252",space+"6/8th  "+DoubleToStr(mml12bm6,DecNos),clrHotPink,   mml12bm6,0);
   BMLtext(IDx+"Xard253",space+"5/8th  "+DoubleToStr(mml12bm5,DecNos),clrLimeGreen, mml12bm5,0);
   BMLtext(IDx+"Xard254",space+"4/8th  "+DoubleToStr(mml12bm4,DecNos),clrSnow,      mml12bm4,0);
   BMLtext(IDx+"Xard255",space+"3/8th  "+DoubleToStr(mml12bm3,DecNos),clrLimeGreen, mml12bm3,0);
   BMLtext(IDx+"Xard256",space+"2/8th  "+DoubleToStr(mml12bm2,DecNos),clrHotPink,   mml12bm2,0);
   BMLtext(IDx+"Xard257",space+"1/8th  "+DoubleToStr(mml12bm1,DecNos),clrGold,      mml12bm1,0);
//+-----
   BMLtext(IDx+"Xard271",space+"7/8th  "+DoubleToStr(mml11bm7,DecNos),clrGold,      mml11bm7,0);
   BMLtext(IDx+"Xard272",space+"6/8th  "+DoubleToStr(mml11bm6,DecNos),clrHotPink,   mml11bm6,0);
   BMLtext(IDx+"Xard273",space+"5/8th  "+DoubleToStr(mml11bm5,DecNos),clrLimeGreen, mml11bm5,0);
   BMLtext(IDx+"Xard274",space+"4/8th  "+DoubleToStr(mml11bm4,DecNos),clrSnow,      mml11bm4,0);
   BMLtext(IDx+"Xard275",space+"3/8th  "+DoubleToStr(mml11bm3,DecNos),clrLimeGreen, mml11bm3,0);
   BMLtext(IDx+"Xard276",space+"2/8th  "+DoubleToStr(mml11bm2,DecNos),clrHotPink,   mml11bm2,0);
   BMLtext(IDx+"Xard277",space+"1/8th  "+DoubleToStr(mml11bm1,DecNos),clrGold,      mml11bm1,0);
//+-----
   BMLtext(IDx+"Xard231",space+"7/8th  "+DoubleToStr(mml10bm7,DecNos),clrGold,      mml10bm7,0);
   BMLtext(IDx+"Xard232",space+"6/8th  "+DoubleToStr(mml10bm6,DecNos),clrHotPink,   mml10bm6,0);
   BMLtext(IDx+"Xard233",space+"5/8th  "+DoubleToStr(mml10bm5,DecNos),clrLimeGreen, mml10bm5,0);
   BMLtext(IDx+"Xard234",space+"4/8th  "+DoubleToStr(mml10bm4,DecNos),clrSnow,      mml10bm4,0);
   BMLtext(IDx+"Xard235",space+"3/8th  "+DoubleToStr(mml10bm3,DecNos),clrLimeGreen, mml10bm3,0);
   BMLtext(IDx+"Xard236",space+"2/8th  "+DoubleToStr(mml10bm2,DecNos),clrHotPink,   mml10bm2,0);
   BMLtext(IDx+"Xard237",space+"1/8th  "+DoubleToStr(mml10bm1,DecNos),clrGold,      mml10bm1,0);
//+-----
   BMLtext(IDx+"Xard211",space+"7/8th  "+DoubleToStr(mml9bm7,DecNos),clrGold,      mml9bm7,0);
   BMLtext(IDx+"Xard212",space+"6/8th  "+DoubleToStr(mml9bm6,DecNos),clrHotPink,   mml9bm6,0);
   BMLtext(IDx+"Xard213",space+"5/8th  "+DoubleToStr(mml9bm5,DecNos),clrLimeGreen, mml9bm5,0);
   BMLtext(IDx+"Xard214",space+"4/8th  "+DoubleToStr(mml9bm4,DecNos),clrSnow,      mml9bm4,0);
   BMLtext(IDx+"Xard215",space+"3/8th  "+DoubleToStr(mml9bm3,DecNos),clrLimeGreen, mml9bm3,0);
   BMLtext(IDx+"Xard216",space+"2/8th  "+DoubleToStr(mml9bm2,DecNos),clrHotPink,   mml9bm2,0);
   BMLtext(IDx+"Xard217",space+"1/8th  "+DoubleToStr(mml9bm1,DecNos),clrGold,      mml9bm1,0);
//+-----
   BMLtext(IDx+"Xard191",space+"7/8th  "+DoubleToStr(mml8bm7,DecNos),clrGold,      mml8bm7,0);
   BMLtext(IDx+"Xard192",space+"6/8th  "+DoubleToStr(mml8bm6,DecNos),clrHotPink,   mml8bm6,0);
   BMLtext(IDx+"Xard193",space+"5/8th  "+DoubleToStr(mml8bm5,DecNos),clrLimeGreen, mml8bm5,0);
   BMLtext(IDx+"Xard194",space+"4/8th  "+DoubleToStr(mml8bm4,DecNos),clrSnow,      mml8bm4,0);
   BMLtext(IDx+"Xard195",space+"3/8th  "+DoubleToStr(mml8bm3,DecNos),clrLimeGreen, mml8bm3,0);
   BMLtext(IDx+"Xard196",space+"2/8th  "+DoubleToStr(mml8bm2,DecNos),clrHotPink,   mml8bm2,0);
   BMLtext(IDx+"Xard197",space+"1/8th  "+DoubleToStr(mml8bm1,DecNos),clrGold,      mml8bm1,0);
//+-----
   BMLtext(IDx+"Xard171",space+"7/8th  "+DoubleToStr(mml7bm7,DecNos),clrGold,      mml7bm7,0);
   BMLtext(IDx+"Xard172",space+"6/8th  "+DoubleToStr(mml7bm6,DecNos),clrHotPink,   mml7bm6,0);
   BMLtext(IDx+"Xard173",space+"5/8th  "+DoubleToStr(mml7bm5,DecNos),clrLimeGreen, mml7bm5,0);
   BMLtext(IDx+"Xard174",space+"4/8th  "+DoubleToStr(mml7bm4,DecNos),clrSnow,      mml7bm4,0);
   BMLtext(IDx+"Xard175",space+"3/8th  "+DoubleToStr(mml7bm3,DecNos),clrLimeGreen, mml7bm3,0);
   BMLtext(IDx+"Xard176",space+"2/8th  "+DoubleToStr(mml7bm2,DecNos),clrHotPink,   mml7bm2,0);
   BMLtext(IDx+"Xard177",space+"1/8th  "+DoubleToStr(mml7bm1,DecNos),clrGold,      mml7bm1,0);
//+-----
   BMLtext(IDx+"Xard151",space+"7/8th  "+DoubleToStr(mml6bm7,DecNos),clrGold,      mml6bm7,0);
   BMLtext(IDx+"Xard152",space+"6/8th  "+DoubleToStr(mml6bm6,DecNos),clrHotPink,   mml6bm6,0);
   BMLtext(IDx+"Xard153",space+"5/8th  "+DoubleToStr(mml6bm5,DecNos),clrLimeGreen, mml6bm5,0);
   BMLtext(IDx+"Xard154",space+"4/8th  "+DoubleToStr(mml6bm4,DecNos),clrSnow,      mml6bm4,0);
   BMLtext(IDx+"Xard155",space+"3/8th  "+DoubleToStr(mml6bm3,DecNos),clrLimeGreen, mml6bm3,0);
   BMLtext(IDx+"Xard156",space+"2/8th  "+DoubleToStr(mml6bm2,DecNos),clrHotPink,   mml6bm2,0);
   BMLtext(IDx+"Xard157",space+"1/8th  "+DoubleToStr(mml6bm1,DecNos),clrGold,      mml6bm1,0);
//+-----
   BMLtext(IDx+"Xard131",space+"7/8th  "+DoubleToStr(mml5bm7,DecNos),clrGold,      mml5bm7,0);
   BMLtext(IDx+"Xard132",space+"6/8th  "+DoubleToStr(mml5bm6,DecNos),clrHotPink,   mml5bm6,0);
   BMLtext(IDx+"Xard133",space+"5/8th  "+DoubleToStr(mml5bm5,DecNos),clrLimeGreen, mml5bm5,0);
   BMLtext(IDx+"Xard134",space+"4/8th  "+DoubleToStr(mml5bm4,DecNos),clrSnow,      mml5bm4,0);
   BMLtext(IDx+"Xard135",space+"3/8th  "+DoubleToStr(mml5bm3,DecNos),clrLimeGreen, mml5bm3,0);
   BMLtext(IDx+"Xard136",space+"2/8th  "+DoubleToStr(mml5bm2,DecNos),clrHotPink,   mml5bm2,0);
   BMLtext(IDx+"Xard137",space+"1/8th  "+DoubleToStr(mml5bm1,DecNos),clrGold,      mml5bm1,0);
//+-----
   BMLtext(IDx+"Xard111",space+"7/8th  "+DoubleToStr(mml4bm7,DecNos),clrGold,      mml4bm7,0);
   BMLtext(IDx+"Xard112",space+"6/8th  "+DoubleToStr(mml4bm6,DecNos),clrHotPink,   mml4bm6,0);
   BMLtext(IDx+"Xard113",space+"5/8th  "+DoubleToStr(mml4bm5,DecNos),clrLimeGreen, mml4bm5,0);
   BMLtext(IDx+"Xard114",space+"4/8th  "+DoubleToStr(mml4bm4,DecNos),clrSnow,      mml4bm4,0);
   BMLtext(IDx+"Xard115",space+"3/8th  "+DoubleToStr(mml4bm3,DecNos),clrLimeGreen, mml4bm3,0);
   BMLtext(IDx+"Xard116",space+"2/8th  "+DoubleToStr(mml4bm2,DecNos),clrHotPink,   mml4bm2,0);
   BMLtext(IDx+"Xard117",space+"1/8th  "+DoubleToStr(mml4bm1,DecNos),clrGold,      mml4bm1,0);
//+-----
   BMLtext(IDx+"Xard91",space+"7/8th  "+DoubleToStr(mml3bm7,DecNos),clrGold,      mml3bm7,0);
   BMLtext(IDx+"Xard92",space+"6/8th  "+DoubleToStr(mml3bm6,DecNos),clrHotPink,   mml3bm6,0);
   BMLtext(IDx+"Xard93",space+"5/8th  "+DoubleToStr(mml3bm5,DecNos),clrLimeGreen, mml3bm5,0);
   BMLtext(IDx+"Xard94",space+"4/8th  "+DoubleToStr(mml3bm4,DecNos),clrSnow,      mml3bm4,0);
   BMLtext(IDx+"Xard95",space+"3/8th  "+DoubleToStr(mml3bm3,DecNos),clrLimeGreen, mml3bm3,0);
   BMLtext(IDx+"Xard96",space+"2/8th  "+DoubleToStr(mml3bm2,DecNos),clrHotPink,   mml3bm2,0);
   BMLtext(IDx+"Xard97",space+"1/8th  "+DoubleToStr(mml3bm1,DecNos),clrGold,      mml3bm1,0);
//+-----
   BMLtext(IDx+"Xard71",space+"7/8th  "+DoubleToStr(mml2bm7,DecNos),clrGold,      mml2bm7,0);
   BMLtext(IDx+"Xard72",space+"6/8th  "+DoubleToStr(mml2bm6,DecNos),clrHotPink,   mml2bm6,0);
   BMLtext(IDx+"Xard73",space+"5/8th  "+DoubleToStr(mml2bm5,DecNos),clrLimeGreen, mml2bm5,0);
   BMLtext(IDx+"Xard74",space+"4/8th  "+DoubleToStr(mml2bm4,DecNos),clrSnow,      mml2bm4,0);
   BMLtext(IDx+"Xard75",space+"3/8th  "+DoubleToStr(mml2bm3,DecNos),clrLimeGreen, mml2bm3,0);
   BMLtext(IDx+"Xard76",space+"2/8th  "+DoubleToStr(mml2bm2,DecNos),clrHotPink,   mml2bm2,0);
   BMLtext(IDx+"Xard77",space+"1/8th  "+DoubleToStr(mml2bm1,DecNos),clrGold,      mml2bm1,0);
//+-----
   BMLtext(IDx+"Xard51",space+"7/8th  "+DoubleToStr(mml1bm7,DecNos),clrGold,      mml1bm7,0);
   BMLtext(IDx+"Xard52",space+"6/8th  "+DoubleToStr(mml1bm6,DecNos),clrHotPink,   mml1bm6,0);
   BMLtext(IDx+"Xard53",space+"5/8th  "+DoubleToStr(mml1bm5,DecNos),clrLimeGreen, mml1bm5,0);
   BMLtext(IDx+"Xard54",space+"4/8th  "+DoubleToStr(mml1bm4,DecNos),clrSnow,      mml1bm4,0);
   BMLtext(IDx+"Xard55",space+"3/8th  "+DoubleToStr(mml1bm3,DecNos),clrLimeGreen, mml1bm3,0);
   BMLtext(IDx+"Xard56",space+"2/8th  "+DoubleToStr(mml1bm2,DecNos),clrHotPink,   mml1bm2,0);
   BMLtext(IDx+"Xard57",space+"1/8th  "+DoubleToStr(mml1bm1,DecNos),clrGold,      mml1bm1,0);}//}
//+------------------------------------------------------------------------------------------------------------------+
   if(showComments){Comment("\n\n\n\n\n\n   Fractal: ",DoubleToStr(fractal,DecNos),"\n   Scale: ",Scale,
   "\n   MajorMMI = Fractal/Scale: ",(fractal/Scale),"\n   minorMMI = Fractal/Scale/8: ",
   (fractal/Scale/8),"\n    babyMMI = Fractal/Scale/8/8: ",(fractal/Scale/8/8));}
//+------------------------------------------------------------------------------------------------------------------+
   return(0);}//End OnCalculate 
//+----PLOTMML FUNCTION----------------------------------------------------------------------------------------------+
   void PlotMML(string name1,double value,double value1,double line_color,double style){
   double  valueN=NormalizeDouble(value,Digits);
   double valueN1=NormalizeDouble(value1,Digits);
         bool res=ObjectCreate(name1,OBJ_TREND,0,time1,valueN,time2,valueN1);
                     ObjectSet(name1,OBJPROP_WIDTH,MMLwidth);
                     ObjectSet(name1,OBJPROP_RAY,false);
                     ObjectSet(name1,OBJPROP_BACK,true);
            ObjectSetInteger(0,name1,OBJPROP_SELECTABLE,false);
            ObjectSetInteger(0,name1,OBJPROP_SELECTED,false);
             ObjectSetString(0,name1,OBJPROP_TOOLTIP,"\n");
                     ObjectSet(name1,OBJPROP_COLOR,line_color);
                    ObjectMove(name1,0,time1,valueN);}
//+----PLOTBML FUNCTION----------------------------------------------------------------------------------------------+
   void PlotBML(string name2,double value,double value1,double line_color,double style){
   double  valueN=NormalizeDouble(value,Digits);
   double valueN1=NormalizeDouble(value1,Digits);
         bool res=ObjectCreate(name2,OBJ_TREND,0,time1,valueN,time2,valueN1);
                     ObjectSet(name2,OBJPROP_WIDTH,1);
                     ObjectSet(name2,OBJPROP_STYLE,1);
                     ObjectSet(name2,OBJPROP_RAY,false);
                     ObjectSet(name2,OBJPROP_BACK,true);
            ObjectSetInteger(0,name2,OBJPROP_SELECTABLE,false);
            ObjectSetInteger(0,name2,OBJPROP_SELECTED,false);
             ObjectSetString(0,name2,OBJPROP_TOOLTIP,"\n");
                     ObjectSet(name2,OBJPROP_COLOR,line_color);}
//+----PLOTFKL FUNCTION----------------------------------------------------------------------------------------------+
   void PlotFKL(string name3,double value,double value1,double line_color,double style){
   double  valueN=NormalizeDouble(value,Digits);
   double valueN1=NormalizeDouble(value1,Digits);
         bool res=ObjectCreate(name3,OBJ_TREND,0,time1,valueN,time2,valueN1);
                     ObjectSet(name3,OBJPROP_WIDTH,1);
                     ObjectSet(name3,OBJPROP_STYLE,4);
                     ObjectSet(name3,OBJPROP_RAY,false);
                     ObjectSet(name3,OBJPROP_BACK,true);
            ObjectSetInteger(0,name3,OBJPROP_SELECTABLE,false);
            ObjectSetInteger(0,name3,OBJPROP_SELECTED,false);
             ObjectSetString(0,name3,OBJPROP_TOOLTIP,"\n");
                     ObjectSet(name3,OBJPROP_COLOR,line_color);}
//+----MMLtext FUNCTION----------------------------------------------------------------------------------------------+
   void MMLtext(string label1,string text,color color1,double ad1,int ai1){
         if(ObjectFind(label1)!=0) ObjectDelete(label1); 
          ObjectCreate(label1,OBJ_TEXT,0,0,0);
            ObjectMove(label1,0,Time[0+LABELmove],ad1+ai1+(Point*1.));
         ObjectSetText(label1,text,LABELsize,fonts_buf[Text_MML_font],color1);//clrSnow);
    ObjectSetInteger(0,label1,OBJPROP_SELECTABLE,false);
    ObjectSetInteger(0,label1,OBJPROP_SELECTED,false);
     ObjectSetString(0,label1,OBJPROP_TOOLTIP,"\n");
             ObjectSet(label1,OBJPROP_BACK,true);}
//+----BMLtext FUNCTION----------------------------------------------------------------------------------------------+
   void BMLtext(string label2,string text,color color1,double ad1,int ai1){
         if(ObjectFind(label2)!=0) ObjectDelete(label2); 
          ObjectCreate(label2,OBJ_TEXT,0,0,0);
            ObjectMove(label2,0,Time[0+LABELmove],ad1+ai1+(Point*1.));
         ObjectSetText(label2,text,LABELsize-1,fonts_buf[Text_BML_font],color1);//clrSnow);//color1);
    ObjectSetInteger(0,label2,OBJPROP_SELECTABLE,false);
    ObjectSetInteger(0,label2,OBJPROP_SELECTED,false);
     ObjectSetString(0,label2,OBJPROP_TOOLTIP,"\n");
             ObjectSet(label2,OBJPROP_BACK,true);}
//+----CLEAN CHART FUNCTION------------------------------------------------------------------------------------------+
   void CleanUpOnIsle9(){string namex; for(int g=ObjectsTotal()-1; g>=0; g--){namex=ObjectName(g);
   if(StringSubstr(namex,0,StringLen(IDx))==IDx) {ObjectDelete(namex);}}}//EOF
//+----END OF FILE---------------------------------------------------------------------------------------------------+