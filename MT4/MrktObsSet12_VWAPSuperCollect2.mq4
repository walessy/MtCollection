#include <ere\include1v2.mqh>
#include <sqlite.mqh>
//https://github.com/saleyn/sqlite3-mt4#sample
#property indicator_chart_window
input int N=20;
input int Shift=0;
//#define EVENT_ID 12000
//#define PTDIndi "Indicators\\MarketObservtionSet12\\MrktObsSet12_VWAP.ex4"
//#resource "\\"+PTDIndi

long current_chart_id=ChartID(),iIndx;
string sIndiName=WindowExpertName();

int iLine=0,iCol=0,iPos=NULL,iStart=20;
int dColWidth=80,iFontSize,iSearchCount=0;
double dMargin=10;

//NewCandleTime = TimeCurrent();
bool FirstRun=true;

//already defined in env.mqh 
//const string sDBPath="C:\\Users\\amos\\AppData\\Roaming\\MetaQuotes\\Terminal\\Common\\Files\\VWAP"+".db";
//Memory DB+ shared cache
//const string sDBPath="file:vwapdb?mode=memory&cache=shared";
const int iFlags=SQLITE_OPEN_NOMUTEX|SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE;

SQLite db;

int init()
{
   int res;
   db.Open(sDBPath,iFlags);

   string sComment,sSQL;
   
   if (!db.IsOpen()) {
     Alert(StringFormat("Cannot open database %s: %s", sDBPath, db.ErrMsg()));
     return 1;
   }
   
   IndiGlobalIsLoaded(true);
  
   sSQL="drop table if exists VWAP_"+(string)Period();
   res = db.ExecDDL(sSQL);
   if (res != SQLITE_OK) PrintFormat("CouldN'T DROP TABLE VWAP database: (%d) %s", db.ErrCode(), db.ErrMsg());

   
   sSQL="create table if not exists VWAP_"+(string)Period()+" (SYMBOL text, VWAP double)";
   res = db.ExecDDL(sSQL);
   if (res != SQLITE_OK) PrintFormat("CouldN'T create table VWAP database: (%d) %s", db.ErrCode(), db.ErrMsg());
   
   sSQL="CREATE UNIQUE INDEX INDEX_VWAP_"+(string)Period()+" ON VWAP_"+(string)Period()+" (SYMBOL)";
   res = db.ExecDDL(sSQL);
   if (res != SQLITE_OK) PrintFormat("CouldN'T CREATE UNIQUE INDEX database: (%d) %s", db.ErrCode(), db.ErrMsg());
   
   
    for(int dCell=0;dCell<SymbolsTotal(true);dCell++){ 
      sComment= SymbolName(dCell,true); 
      sSQL="INSERT INTO VWAP_"+(string)Period()+" (SYMBOL, VWAP) VALUES ('"+sComment +"',0);";
      res = db.ExecDDL(sSQL);
      if (res != SQLITE_OK) PrintFormat("CouldN'T CREATE UNIQUE INDEX database: (%d) %s", db.ErrCode(), db.ErrMsg());
  
    }        

   OnTimer();
   EventSetMillisecondTimer(100);
   GetLastError();
   return(0);
}

void OnTimer(){
   //Print("Timer Reset:  Do stuff");
   int res;
   double iSymbolOpen,iSymbolClose,dVal;
   string sComment, sObjName1,sObjName2,sSQL,sText;
   bool bFoundORderMatchingSymbol=false;
   double vwap;//Std1,Std2,Std3,Std4,Std5,Std6;
   
   

   if(FirstRun)
   {
      ;
   }
   else
   {
      if(!IsNewCandle())
      {
      
      return;
      }
   }
      
   for(int dCell=0;dCell<SymbolsTotal(true);dCell++){
      
         sComment= SymbolName(dCell,true);
         //"+IntegerToString(iLine)+"_"+IntegerToString(iCol)+"_
         sObjName1=sIndiName+"_"+sComment+"_"+(string)Period();
         IndiGlobalRemoveVarByString(sObjName1);
         //Main VWAP
         vwap = iCustom(sComment,PERIOD_CURRENT,"ere\\MrktObsSet12_VWAPSuper_SDv2",N,Shift,PRICE_CLOSE,1.0,1.5,2,0,0);
         //iBid = MarketInfo(sComment, MODE_BID);
         iSymbolOpen = iCustom(sComment,PERIOD_CURRENT,"ere\\MrktObsSet12_VWAPSuper_SDv2",N,Shift,PRICE_CLOSE,1.0,1.5,2,8,0);
         iSymbolClose =iCustom(sComment,PERIOD_CURRENT,"ere\\MrktObsSet12_VWAPSuper_SDv2",N,Shift,PRICE_CLOSE,1.0,1.5,2,9,0);;
        
         
         if(iSymbolClose>vwap&&iSymbolOpen<vwap){
            dVal=1;
         }
         else if (iSymbolClose<vwap&&iSymbolOpen>vwap){
            dVal=0;
         }
         else{
            dVal=2;
         }
         
         sSQL="UPDATE VWAP_"+(string)Period()+" SET VWAP = " + (string)dVal +" WHERE SYMBOL = '"+ sComment +"';";
         //Print(sSQL);
         res = db.ExecDDL(sSQL);
         if (res != SQLITE_OK) {
            Print("Err DB");
            PrintFormat("CouldN'T update vwap table database: (%d) %s", db.ErrCode(), db.ErrMsg());   
         }
   }
}

int deinit(){

   db.Close();
   string sObjName1,sComment;
   IndiGlobalIsLoaded(false);
   CleanChart();
   
   for(int dCell=0;dCell<=SymbolsTotal(true);dCell++){
         
         sComment= SymbolName(dCell,true);
         //"+IntegerToString(iLine)+"_"+IntegerToString(iCol)+"_
         sObjName1=sIndiName+"_"+sComment+"_"+(string)Period();
         IndiGlobalRemoveVarByString(sObjName1);
     
   }
   
   return(0);
}

int start()
{
   CleanChart();
   
   return(0);
}




