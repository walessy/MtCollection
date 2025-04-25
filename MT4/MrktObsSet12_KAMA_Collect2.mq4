#include <ere\include1v2.mqh>
#include <ere\sqlite.mqh>
//https://github.com/saleyn/sqlite3-mt4#sample
#property indicator_chart_window

//#define EVENT_ID 12000
//#define PTDIndi "Indicators\\ere\\MrktObsSet12_kaufman - price filtered 2.1.ex4"
//#resource "\\"+PTDIndi

long current_chart_id=ChartID(),iIndx;
string sIndiName=WindowExpertName();

int iLine=0,iCol=0,iPos=NULL,iStart=20;
int dColWidth=80,iFontSize,iSearchCount=0;
double dMargin=10;

bool FirstRun=true;

const string sDBPath="C:\\Users\\amos\\AppData\\Roaming\\MetaQuotes\\Terminal\\Common\\Files\\KAMA"+".db";
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
  
   sSQL="drop table if exists KAMA_"+(string)Period();
   res = db.ExecDDL(sSQL);
   if (res != SQLITE_OK) PrintFormat("CouldN'T DROP TABLE VWAP database: (%d) %s", db.ErrCode(), db.ErrMsg());

   
   sSQL="create table if not exists KAMA_"+(string)Period()+" (SYMBOL text, KAMA double)";
   res = db.ExecDDL(sSQL);
   if (res != SQLITE_OK) PrintFormat("CouldN'T create table KAMA database: (%d) %s", db.ErrCode(), db.ErrMsg());
   
   sSQL="CREATE UNIQUE INDEX INDEX_KAMA_"+(string)Period()+" ON KAMA_"+(string)Period()+" (SYMBOL)";
   res = db.ExecDDL(sSQL);
   if (res != SQLITE_OK) PrintFormat("CouldN'T CREATE UNIQUE INDEX database: (%d) %s", db.ErrCode(), db.ErrMsg());
   
   
    for(int dCell=0;dCell<SymbolsTotal(true);dCell++){ 
      sComment= SymbolName(dCell,true); 
      sSQL="INSERT INTO KAMA_"+(string)Period()+" (SYMBOL, KAMA) VALUES ('"+sComment +"',0);";
      res = db.ExecDDL(sSQL);
      if (res != SQLITE_OK) PrintFormat("CouldN'T CREATE UNIQUE INDEX database: (%d) %s", db.ErrCode(), db.ErrMsg());
       
      
    }        

   OnTimer();
   EventSetTimer(5);
   GetLastError();
   return(0);
}

void OnTimer(){
   int res;
   string sComment, sObjName1,sObjName2,sSQL;
   bool bFoundORderMatchingSymbol=false;
   double kama;//Std1,Std2,Std3,Std4,Std5,Std6;


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
         kama = iCustom(sComment,PERIOD_CURRENT,"MrktObsSet12_kaufman - price filtered 2.1",10,0,2,30,2.0,15.0,0.0,0,0);
         sSQL="UPDATE KAMA_"+(string)Period()+" SET KAMA = " + (string)kama +" WHERE SYMBOL = '"+ sComment +"';";
         
         res = db.ExecDDL(sSQL);
         if (res != SQLITE_OK) PrintFormat("CouldN'T update kama table database: (%d) %s", db.ErrCode(), db.ErrMsg());   
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




