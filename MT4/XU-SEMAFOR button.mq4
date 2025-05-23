//+------------------------------------------------------------------------------------------------------------------+
#property description                                                                                   "[XU-SEMAFOR]"
#define Version                                                                                         "[XU-SEMAFOR]"
//+------------------------------------------------------------------------------------------------------------------+
#property link        "https://forex-station.com/viewtopic.php?p=1295409935#p1295409935"
#property description "THIS IS A FREE INDICATOR"
#property description "                                                      "
#property description "Welcome to XARD UNIVERSE"
#property description "Let light shine out of darkness and illuminate your world"
#property description "and with this freedom leave behind your cave of denial"
#property indicator_chart_window
#property indicator_buffers 10
extern string Indicator                  = Version;  string ID;  extern int maxBars=5000;
//+------------------------------------------------------------------------------------------------------------------+
extern string STR01                      = "<<<==== [01] SEMA Settings ====>>>";
  extern bool showSEMA1                  = true,showSEMA2=true,showSEMA3=true,showSEMA4=true,showSEMA5=true;
extern double Period1                    = 18,Period2=36,Period3=882,Period4=126,Period5=126,deltazz,myPoint;
       string Dev_Step_1                 = "0,5",Dev_Step_2="0,5",Dev_Step_3="0,5",Dev_Step_4="0,5",Dev_Step_5="0,5";
   extern int S1size                     = 5,S2size=5,S3size=15,S4size=12,S5size=8;
   extern int S1kod                      = 108,S2kod=108,S3kod=110,S4kod=108,S5kod=217,S6kod=218;      
//template code start1
extern string             button_note1          = "------------------------------";
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_LOWER; // chart btn_corner for anchoring
extern string             btn_text              = "SEMAFOR";
extern string             btn_Font              = "Impact";
extern int                btn_FontSize          = 14;                             //btn__font size
extern color              btn_text_ON_color     = clrWhite;
extern color              btn_text_OFF_color    = C'120,120,120';
extern color              btn_background_color  = clrDarkRed;
extern color              btn_border_color      = clrDarkRed;
extern int                button_x              = 460;                                     //btn__x
extern int                button_y              = 26;                                     //btn__y
extern int                btn_Width             = 86;                                 //btn__width
extern int                btn_Height            = 26;                                //btn__height
extern string             button_note2          = "------------------------------";

bool                      show_data             = true;
string IndicatorName, IndicatorObjPrefix;
//template code end1
          int APer,BPer,CPer,DPer,EPer,Dev1,Stp1,Dev2,Stp2,Dev3,Stp3,Dev4,Stp4,Dev5,Stp5,Type;
       double ABufUp[],ABufDn[],BBufUp[],BBufDn[],CBufUp[],CBufDn[],DBufUp[],DBufDn[],EBufUp[],EBufDn[];
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
   buttonId = IndicatorObjPrefix + "XU_SEMAFOR2020";
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
int Buf=-1;
//+---SMALLRED DOT---------------------------------------------------------------------------------------------------+
   if(showSEMA1)    Type=DRAW_ARROW; else Type=DRAW_NONE;
   Buf+=1; SetIndexStyle(Buf,Type);
   Buf+=1; SetIndexStyle(Buf,Type);
//+---SMALLBLUE DOT--------------------------------------------------------------------------------------------------+
   if(showSEMA2)    Type=DRAW_ARROW; else Type=DRAW_NONE;
   Buf+=1; SetIndexStyle(Buf,Type);
   Buf+=1; SetIndexStyle(Buf,Type);
//+---DODGERBLUE SQUARE----------------------------------------------------------------------------------------------+
   if(showSEMA3)    Type=DRAW_ARROW; else Type=DRAW_NONE;
   Buf+=1; SetIndexStyle(Buf,Type);
   Buf+=1; SetIndexStyle(Buf,Type);
//+---ROYALBLUE & CRIMSON TURNING POINTS-----------------------------------------------------------------------------+
   if(showSEMA4)    Type=DRAW_ARROW; else Type=DRAW_NONE;
   Buf+=1; SetIndexStyle(Buf,Type);
   Buf+=1; SetIndexStyle(Buf,Type);
//+---WHITE ARROWS---------------------------------------------------------------------------------------------------+
   if(showSEMA5)    Type=DRAW_ARROW; else Type=DRAW_NONE;
   Buf+=1; SetIndexStyle(Buf,Type);
   Buf+=1; SetIndexStyle(Buf,Type);
//+------------------------------------------------------------------------------------------------------------------+
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
//+----OnInit Function-----------------------------------------------------------------------------------------------+
   int init2(){int Buff=10,Buf=-1; IndicatorBuffers(Buff);
   ID = "b"; IndicatorDigits(Digits); IndicatorShortName(ID);
//+------------------------------------------------------------------------------------------------------------------+ 
   if(Period1>0) APer=MathCeil(Period1*Period()); else APer=0;
   if(Period2>0) BPer=MathCeil(Period2*Period()); else BPer=0;
   if(Period3>0) CPer=MathCeil(Period3*Period()); else CPer=0;
   if(Period4>0) DPer=MathCeil(Period4*Period()); else DPer=0;
   if(Period5>0) EPer=MathCeil(Period5*Period()); else EPer=0;
//+---SMALLRED DOT---------------------------------------------------------------------------------------------------+
   if(showSEMA1)    Type=DRAW_ARROW; else Type=DRAW_NONE;
   if(Period1>0){int cU=clrCrimson, cD=clrCrimson;
   Buf+=1; SetIndexBuffer(Buf,ABufUp); SetIndexStyle(Buf,Type,0,S1size,cU);
           SetIndexArrow(Buf,S1kod);   SetIndexEmptyValue(Buf,0.0);
   Buf+=1; SetIndexBuffer(Buf,ABufDn); SetIndexStyle(Buf,Type,0,S1size,cD);
           SetIndexArrow(Buf,S1kod);   SetIndexEmptyValue(Buf,0.0);}
//+---SMALLBLUE DOT--------------------------------------------------------------------------------------------------+
   if(showSEMA2)    Type=DRAW_ARROW; else Type=DRAW_NONE;
   if(Period2>0){cU=clrDodgerBlue; cD=clrDodgerBlue;
   Buf+=1; SetIndexBuffer(Buf,BBufUp); SetIndexStyle(Buf,Type,0,S2size,cU);
           SetIndexArrow(Buf,S2kod);   SetIndexEmptyValue(Buf,0.0);
   Buf+=1; SetIndexBuffer(Buf,BBufDn); SetIndexStyle(Buf,Type,0,S2size,cD);
           SetIndexArrow(Buf,S2kod);   SetIndexEmptyValue(Buf,0.0);}
//+---DODGERBLUE SQUARE----------------------------------------------------------------------------------------------+
   if(showSEMA3)    Type=DRAW_ARROW; else Type=DRAW_NONE;
   if(Period3>0){cU=C'209,58,150'; cD=C'58,150,209';
   Buf+=1; SetIndexBuffer(Buf,CBufUp); SetIndexStyle(Buf,Type,0,S3size,cU);
           SetIndexArrow(Buf,S3kod);   SetIndexEmptyValue(Buf,0.0);
   Buf+=1; SetIndexBuffer(Buf,CBufDn); SetIndexStyle(Buf,Type,0,S3size,cD);
           SetIndexArrow(Buf,S3kod);   SetIndexEmptyValue(Buf,0.0);}
//+---ROYALBLUE & CRIMSON TURNING POINTS-----------------------------------------------------------------------------+
   if(showSEMA4)    Type=DRAW_ARROW; else Type=DRAW_NONE;
   if(Period4>0){cU=clrBlue; cD=clrRed;
   Buf+=1; SetIndexBuffer(Buf,DBufUp); SetIndexStyle(Buf,Type,0,S4size,cU);
           SetIndexArrow(Buf,S4kod);   SetIndexEmptyValue(Buf,0.0);
   Buf+=1; SetIndexBuffer(Buf,DBufDn); SetIndexStyle(Buf,Type,0,S4size,cD);
           SetIndexArrow(Buf,S4kod);   SetIndexEmptyValue(Buf,0.0);}
//+---WHITE ARROWS---------------------------------------------------------------------------------------------------+
   if(showSEMA5)    Type=DRAW_ARROW; else Type=DRAW_NONE;
   if(Period5>0){ cU=clrDeepSkyBlue; cD=C'255,140,255';
   Buf+=1; SetIndexBuffer(Buf,EBufUp); SetIndexStyle(Buf,Type,0,S5size,cU);
           SetIndexArrow(Buf,S5kod);   SetIndexEmptyValue(Buf,0.0);
   Buf+=1; SetIndexBuffer(Buf,EBufDn); SetIndexStyle(Buf,Type,0,S5size,cD);
           SetIndexArrow(Buf,S6kod);   SetIndexEmptyValue(Buf,0.0);}
//+------------------------------------------------------------------------------------------------------------------+
   int CDev=0,CSt=0,Mass[],C=0;
   if(IntFromStr(Dev_Step_1,C,Mass)==1){Stp1=Mass[1]; Dev1=Mass[0];}
   if(IntFromStr(Dev_Step_2,C,Mass)==1){Stp2=Mass[1]; Dev2=Mass[0];}
   if(IntFromStr(Dev_Step_3,C,Mass)==1){Stp3=Mass[1]; Dev3=Mass[0];}
   if(IntFromStr(Dev_Step_4,C,Mass)==1){Stp4=Mass[1]; Dev4=Mass[0];}
   if(IntFromStr(Dev_Step_5,C,Mass)==1){Stp5=Mass[1]; Dev5=Mass[0];}
//+------------------------------------------------------------------------------------------------------------------+
   if(Buff != Buf+1) Print("*******Buffer MisMatch!!!   ",Buff," ",Buf);
   for(int Bufx=0;Bufx<indicator_buffers;Bufx++){SetIndexLabel(Bufx,NULL);}  return(INIT_SUCCEEDED);}//End OnInit
//+----deinit Function-----------------------------------------------------------------------------------------------+
   int deinit2(){CleanUpOnIsle1(); return(0);}//End deinit
//+----OnCalculate Function------------------------------------------------------------------------------------------+
int start2()
                   {
//+------------------------------------------------------------------------------------------------------------------+
   int limit,counted_bars=IndicatorCounted(); if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--; limit=Bars-counted_bars; if(limit>maxBars){limit=maxBars;}
//+------------------------------------------------------------------------------------------------------------------+
   if(Period1>0) CountZZ(ABufUp,ABufDn,Period1,Dev1,Stp1);
   if(Period2>0) CountZZ(BBufUp,BBufDn,Period2,Dev2,Stp2);
   if(Period3>0) CountZZ(CBufUp,CBufDn,Period3,Dev3,Stp3);
   if(Period4>0) CountZZ(DBufUp,DBufDn,Period4,Dev4,Stp4);
   if(Period5>0) CountZZ(EBufUp,EBufDn,Period5,Dev5,Stp5);
//+------------------------------------------------------------------------------------------------------------------+
   return(0);}//End OnCalculate
//+----Clean Chart Function------------------------------------------------------------------------------------------+
   void CleanUpOnIsle1(){string namem; for(int m=ObjectsTotal()-1; m>=0; m--){namem=ObjectName(m);
   if(StringSubstr(namem,0,StringLen(ID))==ID) {ObjectDelete(namem);}}}//EOF
//+----END OF FILE---------------------------------------------------------------------------------------------------+
   int CountZZ(double& ExtMapBufferUp[],double& ExtMapBufferDn[],int Depth,int ExtDeviation,int ExtBackstep){
   int shiftZZ,back,lasthighpos,lastlowpos; double val,res,curlow,curhigh,lasthigh,lastlow;
   for(shiftZZ=Bars-Depth; shiftZZ>=0; shiftZZ--){val=Low[iLowest(NULL,0,MODE_LOW,Depth,shiftZZ)];
   if(val==lastlow) val=0.0;  else { lastlow=val;
   if((Low[shiftZZ]-val)>(ExtDeviation*myPoint)) val=0.0;  else {
   for(back=1; back<=ExtBackstep; back++){res=ExtMapBufferUp[shiftZZ+back];
   if (res!=0.0) res = res+deltazz;
   if((res!=0.0)&&(res>val)) ExtMapBufferUp[shiftZZ+back]=0.0;}}}
   if(val==0.0) ExtMapBufferUp[shiftZZ]=0.0; else ExtMapBufferUp[shiftZZ]=val-deltazz;
//--- high
   val=High[iHighest(NULL,0,MODE_HIGH,Depth,shiftZZ)];
   if(val==lasthigh) val=0.0;  else { lasthigh=val;
   if((val-High[shiftZZ])>(ExtDeviation*myPoint)) val=0.0; else {
   for(back=1; back<=ExtBackstep; back++){ res=ExtMapBufferDn[shiftZZ+back];
   if(res!=0.0) res = res-deltazz;
   if((res!=0.0)&&(res<val)) ExtMapBufferDn[shiftZZ+back]=0.0;}}}
   if(val==0.0) ExtMapBufferDn[shiftZZ]=0.0; else ExtMapBufferDn[shiftZZ]=val+deltazz;}
//--- final cutting
   lasthigh=-1;  lasthighpos=-1;  lastlow=-1;  lastlowpos=-1;
   for(shiftZZ=Bars-Depth; shiftZZ>=0; shiftZZ--){ curlow=ExtMapBufferUp[shiftZZ];
   if(curlow != 0.0) curlow = curlow+deltazz;    curhigh=ExtMapBufferDn[shiftZZ];
   if(curhigh != 0.0) curhigh = curhigh-deltazz;
   if((curlow==0.0)&&(curhigh==0.0)) continue;
//---
   if(curhigh!=0.0){if(lasthigh>0.0){
   if(lasthigh<curhigh) ExtMapBufferDn[lasthighpos]=0.0; else ExtMapBufferDn[shiftZZ]=0.0;}
//---
   if(lasthigh<curhigh || lasthigh<0.0){lasthigh=curhigh; lasthighpos=shiftZZ;} lastlow=-1;}
   if(curlow!=0.0){if(lastlow>0.0){
   if(lastlow>curlow) ExtMapBufferUp[lastlowpos]=0.0; else ExtMapBufferUp[shiftZZ]=0.0;}
//---
   if((curlow<lastlow)||(lastlow<0.0)){lastlow=curlow; lastlowpos=shiftZZ;} lasthigh=-1;}}
   for(shiftZZ=Bars-1; shiftZZ>=0; shiftZZ--){
   if(shiftZZ>=Bars-Depth) ExtMapBufferUp[shiftZZ]=0.0; else {break;}} return(0);}
//+------------------------------------------------------------------------------------------------------------------+
   int Str2Massive(string VStr,int& M_Count,int& VMass[]){int val=StrToInteger(VStr); if(val>0){M_Count++;
   int mc=ArrayResize(VMass,M_Count); if(mc==0)return(-1); VMass[M_Count-1]=val; return(1);} else return(0);}
//+------------------------------------------------------------------------------------------------------------------+
   int IntFromStr(string ValStr,int& M_Count, int& VMass[]){if(StringLen(ValStr)==0) return(-1);
   string SS=ValStr; int NP=0; string CS; M_Count=0; ArrayResize(VMass,M_Count);
   while(StringLen(SS)>0){NP=StringFind(SS,",");
   if(NP>0){CS=StringSubstr(SS,0,NP); SS=StringSubstr(SS,NP+1,StringLen(SS));}  else {
   if(StringLen(SS)>0){CS=SS; SS="";}} if(Str2Massive(CS,M_Count,VMass)==0){return(-2);}} return(1);}
//+------------------------------------------------------------------------------------------------------------------+