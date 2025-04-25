#include <ere\include1v2.mqh>
#property indicator_chart_window
//#define EVENT_ID 12000
//#define PTDIndi "Indicators\\MarketObservtionSet12\\MrktObsSet12_VWAP.ex4"
//#resource "\\"+PTDIndi

extern ENUM_SymbolCorner Symbol_Corner = TopLeft;
extern int cols=1;
extern color  DataTableBackGroundColor_1 = LightSteelBlue;
extern color  DataTableBackGroundColor_2 = Lavender;
input int N=20;
input int Shift=0;

long current_chart_id=ChartID(),iIndx;
string sIndiName=WindowExpertName();
int iLine=0,iCol=0,iPos=NULL,iStart=20;
int dColWidth=80,iFontSize,iSearchCount=0;
double dMargin=10;
   
int init()
{

   IndiGlobalIsLoaded(true);
   OnTimer();
   EventSetTimer(5);
   GetLastError();
   return(0);
}

void OnTimer(){
     
   string sComment, sObjName1,sObjName2;
   bool bFoundORderMatchingSymbol=false;
   double vwap;
   //double Std1,Std2,Std3,Std4,Std5,Std6;
   for(int dCell=0;dCell<SymbolsTotal(true);dCell++){
      
         sComment= SymbolName(dCell,true);
         //"+IntegerToString(iLine)+"_"+IntegerToString(iCol)+"_
         sObjName1=sIndiName+"_"+sComment+"_"+(string)Period();
         IndiGlobalRemoveVarByString(sObjName1);
         //Main VWAP
         vwap = iCustom(sComment,PERIOD_CURRENT,"ere\\MrktObsSet12_VWAP",N,Shift,PRICE_CLOSE,1,1.5,2,0,0);
         //Sleep(20);
         //Positive
         //Std1 = iCustom(sComment,PERIOD_CURRENT,"MarketObservtionSet12\\MrktObsSet12_VWAP",20,0,PRICE_CLOSE,1,1.5,2,1,0);
         //Sleep(1);
         //Std2 = iCustom(sComment,PERIOD_CURRENT,"MarketObservtionSet12\\MrktObsSet12_VWAP",20,0,PRICE_CLOSE,1,1.5,2,3,0);
         //Sleep(1);
         //Std3 = iCustom(sComment,PERIOD_CURRENT,"MarketObservtionSet12\\MrktObsSet12_VWAP",20,0,PRICE_CLOSE,1,1.5,2,5,0);
         //Negative
         //Std4 = vwap-(Std1-vwap);
         //Std5 = vwap-(Std2-vwap);
         //Std6 = vwap-(Std3-vwap);
         
         
         sObjName2=sObjName1+"_vwap";
         GlobalVariableTemp(sObjName2);GlobalVariableSet(sObjName2,vwap);
         //sObjName2=sObjName1+"_vwapStd1";
         //GlobalVariableTemp(sObjName2);GlobalVariableSet(sObjName2,Std1);
         //sObjName2=sObjName1+"_vwapStd2";
         //GlobalVariableTemp(sObjName2);GlobalVariableSet(sObjName2,Std2);     
         //sObjName2=sObjName1+"_vwapStd3";
         //GlobalVariableTemp(sObjName2);GlobalVariableSet(sObjName2,Std3); 
         //sObjName2=sObjName1+"_vwapStd4";
         //GlobalVariableTemp(sObjName2);GlobalVariableSet(sObjName2,Std4); 
         //sObjName2=sObjName1+"_vwapStd5";
         //GlobalVariableTemp(sObjName2);GlobalVariableSet(sObjName2,Std5);
         //sObjName2=sObjName1+"_vwapStd6";
         //GlobalVariableTemp(sObjName2);GlobalVariableSet(sObjName2,Std6);              
   }
   
}

int deinit(){


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




