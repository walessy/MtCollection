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


extern string             InpDirectoryName="Data";     // Folder name

int init()
{

   IndiGlobalIsLoaded(true);

  
  
   OnTimer();
   EventSetTimer(2);
   GetLastError();
   return(0);
}

void OnTimer(){

   //int MTF_Tf, MTF_Time;

   double iSymbolOpen,iSymbolClose,iBid,dVal;
   string sComment, sObjName1;
   bool bFoundORderMatchingSymbol=false;
   double vwap;//Std1,Std2,Std3,Std4,Std5,Std6;
   
   for(int dCell=0;dCell<SymbolsTotal(true);dCell++){
      
         sComment= SymbolName(dCell,true);
         //"+IntegerToString(iLine)+"_"+IntegerToString(iCol)+"_
         sObjName1=sIndiName+"_"+sComment+"_"+(string)Period();
         
         //Main VWAP

         vwap = iCustom(sComment,PERIOD_CURRENT,"ere\\MrktObsSet12_VWAP_SD",N,Shift,PRICE_CLOSE,1,1.5,2,0,0);
         /*
         int TimePeriod =PERIOD_CURRENT;
         switch(TimePeriod){
            case PERIOD_M1: MTF_Tf=PERIOD_M1; MTF_Time=1; break;
            case PERIOD_M5: MTF_Tf=PERIOD_M1; MTF_Time=5; break;
            case PERIOD_M15: MTF_Tf=PERIOD_M1; MTF_Time=15; break;
            case PERIOD_M30: MTF_Tf=PERIOD_M1; MTF_Time=30; break;
            case PERIOD_H1: MTF_Tf=PERIOD_M1; MTF_Time=60; break;
            case PERIOD_H4: MTF_Tf=PERIOD_M1; MTF_Time=240; break;
            case PERIOD_D1: MTF_Tf=PERIOD_M1; MTF_Time=1440; break;
            case PERIOD_W1: MTF_Tf=PERIOD_M5; MTF_Time=1440; break;
         }
         
         //vwap = iCustom(sComment,PERIOD_CURRENT,"MarketObservtionSet12\\MrktObsSet12_VWAPMTF",MTF_Tf, MTF_Time);
         */
         iBid = MarketInfo(sComment, MODE_BID);
         iSymbolOpen = iOpen(sComment,PERIOD_CURRENT,0);
         iSymbolClose  = iClose(sComment,PERIOD_CURRENT,0);
         
         
         if(iSymbolClose>vwap&&iSymbolOpen<vwap){
            dVal=1;
         }
         else if (iSymbolClose<vwap&&iSymbolOpen>vwap){
            dVal=0;
         }
         else{
            dVal=2;
         }

         //Write to File
         WriteToFile(sObjName1, (string)dVal); 

  
   }
}

bool WriteToFile(string FileName, string Value){

   
   int handle=FileOpen(FileName + ".csv",FILE_CSV|FILE_READ|FILE_WRITE,',');
   if(handle<1)
   {
      Comment("File " + FileName+ ".csv not found, the last error is ", GetLastError());
      return(false);
   }
   else
   {
   
      FileWrite(handle, Value);
      FileClose(handle);
      return true;
   }
}


int deinit(){

   IndiGlobalIsLoaded(false);
   CleanChart();
   return(0);
   
}

int start()
{
   CleanChart();
   
   return(0);
}




