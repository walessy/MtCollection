#include <ere\sqlite.mqh>
#include <ere\include1v2.mqh>
//#include <Controls\\RadioGroup.mqh>
#property indicator_chart_window
//#define EVENT_ID 12000

extern ENUM_SymbolCorner Symbol_Corner = TopLeft;
extern int cols=1;
//extern color  DataTableBackGroundColor_1 = LightSteelBlue;
//extern color  DataTableBackGroundColor_2 = Lavender;

long current_chart_id=ChartID(),iIndx;
string sIndiName=WindowExpertName();
int iLine=0,iCol=0,iPos=NULL,iStartHeader=20,iStartList=40;
int dColWidth=80,iFontSize,iSearchCount=0;
double dMargin=10;

//const string sDBPath="C:\\Users\\amos\\AppData\\Roaming\\MetaQuotes\\Terminal\\Common\\Files\\VWAP"+".db";
//Memory DB+ shared cache
//const string sDBPath="file:vwapdb?mode=memory&cache=shared";
const int iFlags=SQLITE_OPEN_NOMUTEX|SQLITE_OPEN_READWRITE;  //open in Multithreade mode
//SQLITE_READONLY|SQLITE_OPEN_NOMUTEX
SQLite db;
 
int init()
{

   //int res;
   db.Open(sDBPath,iFlags);
   if (!db.IsOpen()) {
     Alert(StringFormat("Cannot open database %s: %s", sDBPath, db.ErrMsg()));
     return 1;
   }
   
   IndiGlobalIsLoaded(true);
   CleanChart(sIndiName);
   OnTimer();
   EventSetTimer(1);
   GetLastError();
   return(0);
}

void OnTimer(){
   
   //int res;
   //CleanChart(sIndiName);
   
   string sComment, sFont,sFontBold,sFontTemp,sFontSymbol, sObjName, text,fontSizeTemp,sSQL;
   string up_arrow="up_arrow",sCurrBase,sCurrProfit,sAllCurrBases, sAllCurrProfits;
   string suffix,prefix;
   double GV,clrTemp, high,low,close;
   //GVStd1,GVStd2,GVStd3,GVStd4,GVStd5,GVStd6,
   bool bFoundORderMatchingSymbol=false;
   //long periodMin;
   int iSymbolCount=0,fontSizeBg;
   //Header
   sFontBold ="Courier New Bold";
   sFont ="Courier New";
   sFontSymbol="Windings";
   iFontSize=10;
   fontSizeBg=10;

   iCol++;
   sObjName=sIndiName+"_HeaderSup2";
   ObjectDelete(sObjName);
   ObjectCreate(sObjName,OBJ_LABEL,0,0,0,0,0);
   ObjectSet(sObjName,OBJPROP_CORNER,Symbol_Corner);
   ObjectSet(sObjName,OBJPROP_XDISTANCE,(dColWidth*iCol)+dMargin);
   ObjectSet(sObjName,OBJPROP_YDISTANCE,0);
   ObjectSetText(sObjName,"'ERE VWAP",iFontSize,sFontBold,clrSkyBlue);
   
   iCol--;
   sObjName=sIndiName+"_Header1";
   ObjectDelete(sObjName);
   ObjectCreate(sObjName,OBJ_LABEL,0,0,0,0,0);
   ObjectSet(sObjName,OBJPROP_CORNER,Symbol_Corner);
   ObjectSet(sObjName,OBJPROP_XDISTANCE,(dColWidth*iCol)+dMargin);
   ObjectSet(sObjName,OBJPROP_YDISTANCE,(20*iLine)+iStartHeader);
   //ObjectSet(sObjName,OBJPROP_BACK,
   ObjectSetText(sObjName,"SYMBOL",iFontSize,sFontBold,clrSkyBlue); 
   
   iCol++;
       
   sObjName=sIndiName+"_Header2";
   ObjectDelete(sObjName);
   ObjectCreate(sObjName,OBJ_LABEL,0,0,0,0,0);
   ObjectSet(sObjName,OBJPROP_CORNER,Symbol_Corner);
   ObjectSet(sObjName,OBJPROP_XDISTANCE,(dColWidth*iCol)+dMargin);
   ObjectSet(sObjName,OBJPROP_YDISTANCE,(20*iLine)+iStartHeader);
   ObjectSetText(sObjName,"1D",iFontSize,sFontBold,clrSkyBlue); 

   iCol--;
   //iStart=iStart+20;
   for(int dCell=0;dCell<SymbolsTotal(true);dCell++){
      sComment= SymbolName(dCell,true);
      //if (MarketInfo(sComment, MODE_MARGINCALCMODE) == 0.0) //ie  forex
      //{
      
         sCurrBase = SymbolInfoString(Symbol(),SYMBOL_CURRENCY_BASE); //first currency in a pair
         sCurrProfit = SymbolInfoString(Symbol(),SYMBOL_CURRENCY_PROFIT); //second currency in a pair
         for (int orderpos=OrdersTotal()-1; orderpos >= 0; orderpos--)
         {
            if (OrderSelect(orderpos, SELECT_BY_POS, MODE_TRADES))
            {
                 if (OrderSymbol() == sComment)
                 {   
                     iSymbolCount++;
                 }
                     
                 StringAdd(sAllCurrBases,StringSubstr(OrderSymbol(),0,3)+",");
                 StringAdd(sAllCurrProfits,StringSubstr(OrderSymbol(),3,3)+",");
            }
         }

         if(iSymbolCount>0){
            fontSizeTemp=(string)fontSizeBg; 
         }
         else{         
            fontSizeTemp=(string)iFontSize;
         }
         
         //iSymbolCount=0;
         sSQL="SELECT VWAP FROM VWAP_"+(string)Period()+" WHERE SYMBOL='"+sComment+"';";
         SQLiteQuery* query = db.Prepare(sSQL);
         if (!query){ PrintFormat("Invalid query: (%d) %s", db.ErrCode(), db.ErrMsg());  return;}

         GV=-1;
         for(int count= 0; query.Next() == SQLITE_ROW; ++count) {
            //should only be one row
            GV     = query.GetDouble(0);
         }
         delete query;

         high=iHigh(sComment,Period(),1);
         low=iLow(sComment,Period(),1);
         close=iClose(sComment,Period(),1);         
         if((high>GV&&low<GV)&&close>GV){
                                     
            clrTemp = clrGreen; 
         }
         else if((high>GV&&low<GV)&&close<GV){
            //Print("2");
            clrTemp = clrRed; 
         }
         else{         
            //Print("3");
            clrTemp=clrSkyBlue;
         }
         
         sObjName=sIndiName+"_"+sComment; //IntegerToString(iLine)+"_"+IntegerToString(iCol);
         //GlobalVariableTemp(sObjName);
         ObjectDelete(sObjName);
         ObjectCreate(sObjName,OBJ_LABEL,0,0,0,0,0);
         ObjectSet(sObjName,OBJPROP_CORNER,Symbol_Corner);
         ObjectSet(sObjName,OBJPROP_XDISTANCE,(dColWidth*iCol)+dMargin);
         ObjectSet(sObjName,OBJPROP_YDISTANCE,(20*iLine)+iStartList);
         sFontTemp =(iSymbolCount>0)?sFontBold:sFont;
         //sFont =(bFoundORderMatchingSymbol)?sFontBold:sFont;
         iFontSize=10;
         prefix=(sComment==Symbol())?"*"+sComment:sComment;
         suffix=(iSymbolCount>0)?prefix+" <<":prefix;
         
         ObjectSetText(sObjName,suffix,(int)fontSizeTemp,sFontTemp,(color)clrTemp); 

         iCol++;
         sObjName=sIndiName+"_vwap_"+(string)Period()+"_"+sComment; //+IntegerToString(iLine)+"_"+IntegerToString(iCol)+"_VWAP";
         ObjectDelete(sObjName);
         ObjectCreate(sObjName,OBJ_LABEL,0,0,0,0,0);
         ObjectSet(sObjName,OBJPROP_CORNER,Symbol_Corner);
         ObjectSet(sObjName,OBJPROP_XDISTANCE,(dColWidth*iCol)+dMargin);
         ObjectSet(sObjName,OBJPROP_YDISTANCE,(20*iLine)+iStartList);
         
         //GV=GlobalVariableGet("MrktObsSet12_VWAPCollect_"+sComment+"_1440_vwap");
         //Print("MrktObsSet12_VWAPCollect_"+sComment+"_vwap");
         high=iHigh(sComment,Period(),0);
         low=iLow(sComment,Period(),0);
         close=iClose(sComment,Period(),0);

         if((high>GV&&low<GV)&&close>GV){
                                      // Draw arrow now
            clrTemp = clrGreen; 
         }
         else if((high>GV&&low<GV)&&close<GV){
            //Print("2");
            clrTemp = clrRed; 
         }
         else{         
            //Print("3");
            clrTemp=clrSkyBlue;
         }
         //text = (string)GV;
         text = "X";
         
         ObjectSetText(sObjName,text,(int)fontSizeTemp,sFontSymbol,(color)clrTemp);
         

           
         //ObjectSet(sObjName,OBJPROP_BORDER_COLOR,clrYellow);
         //ObjectSet(sObjName,OBJPROP_BGCOLOR,clrYellow);
         //ObjectSet(sObjName,OBJPROP_ZORDER,0);

         
      //}
      if(MathMod(dCell+1,cols)==0)
      {
         iCol=0;
         iLine++;
      }
      else
      {
         iCol++;
      }
      iSymbolCount=0;
   }
   iCol=0;
   iLine=0;
}

int deinit(){
   IndiGlobalIsLoaded(false);
   CleanChart(sIndiName);
   IndiGlobalRemoveVarByString(sIndiName);
   return(0);
}

int start()
{

   return(0);
   //CRadioGroup rg;
}


void OnChartEvent(const int id,         // Event identifier  Event
                  const long& lparam,   // Event parameter of long type X
                  const double& dparam, // Event parameter of double type Y
                  const string& sparam) // Event parameter of string type  Name of the graphical object, on which the event occurred
{

   string sObjName,DoChartName;
   string Curr;
   string ChartNamePrefix="MrktObsSet12_VWAP_ChartID_";
   string ChartNamePrefix2="MrktObsSet12_VWAP_SD_ChartID_";

   long Chartid;
   int tf;
   
   switch (id){
   case CHARTEVENT_OBJECT_CLICK : 
      sObjName=ObjectGetString(0,sparam,OBJPROP_NAME,0);
      Curr=StringSubstr(sObjName,StringLen(sObjName)-6,6);
      ChartSetSymbolPeriod(0,Curr, Period());
      //GlobalVariableTemp(sIndiName+"_CHNG_SYMBL_"+Curr); //Create if not exist
      
      for(int i=0;i<=GlobalVariablesTotal(); i++){
      
         if(StringFind(GlobalVariableName(i),ChartNamePrefix,0)!=-1){
           // Print("GV Name=" +GlobalVariableName(i));
            DoChartName=StringSubstr(GlobalVariableName(i),StringLen(ChartNamePrefix), StringLen(DoChartName)-StringLen(ChartNamePrefix));
            Chartid=(long)DoChartName;
            tf=ChartPeriod(Chartid);
            ChartSetSymbolPeriod(Chartid,Symbol(),tf);         
         }
         if(StringFind(GlobalVariableName(i),ChartNamePrefix2,0)!=-1){
           // Print("GV Name=" +GlobalVariableName(i));
            DoChartName=StringSubstr(GlobalVariableName(i),StringLen(ChartNamePrefix2), StringLen(DoChartName)-StringLen(ChartNamePrefix2));
            Chartid=(long)DoChartName;
            tf=ChartPeriod(Chartid);
            ChartSetSymbolPeriod(Chartid,Symbol(),tf);         
         }
      }      
   }
}

