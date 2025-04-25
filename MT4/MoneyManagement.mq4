#include <ere/include1v2.mqh>
#property indicator_chart_window

extern int ATR_Period=14;
extern double SL =1.5;
extern double TP=2;
extern double RiskPercent=2;

string sIndiName=WindowExpertName();
string sObjNameInfoPrefix=sIndiName+"_Info_"; 
string sObjNameCurrPrefix=sIndiName+"_Curr_";

int init()
{
   CleanChart(sIndiName);
   IndiGlobalIsLoaded(true);
   return(0);
}


void deinit()
{
   IndiGlobalIsLoaded(false);
   CleanChart(sIndiName);;
}

int start()
{
   
   double   nTickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   int      iCurrBasesCount,iCurrProfitCount;
   string   sAllCurrBases, sAllCurrProfits, sComment,sObjName,sLine;
   datetime LastActionTime = 0;
   double   dATRRatio,dATR, dSLATR,dTPATR;
   double   dLotSize,dAmndLtSz;
   long     lLvg;
   double   iSymbolCount=0,dBalPer;
   double   dModifiedAccountBalance= AccountBalance();
   
   double   dCurrAskPrice = MarketInfo(Symbol(), MODE_ASK);
   string   sCurrSymb = Symbol();
   string   sCurrBase = SymbolInfoString(Symbol(),SYMBOL_CURRENCY_BASE); //first currency in a pair
   string   sCurrProfit = SymbolInfoString(Symbol(),SYMBOL_CURRENCY_PROFIT); //second currency in a pair
   
   int      iLine=0,iCol=0,dColWidth=50, iCorner=1;
   //int counted_bars=IndicatorCounted();
   //if(counted_bars<0) return(-1);
   //if(counted_bars>0) counted_bars--;
   //int      limit=MathMin(Bars-counted_bars,Bars-1);

   CleanChart();
   
   for (int orderpos=OrdersTotal()-1; orderpos >= 0; orderpos--)
   {
      if (OrderSelect(orderpos, SELECT_BY_POS, MODE_TRADES))
      {
           if (OrderSymbol() == Symbol())
           {   
               iSymbolCount++;
           }
               
           StringAdd(sAllCurrBases,StringSubstr(OrderSymbol(),0,3)+",");
           StringAdd(sAllCurrProfits,StringSubstr(OrderSymbol(),3,3)+",");
      }
   }
   dModifiedAccountBalance-=ACCOUNT_EQUITY;
     
   if (MarketInfo(sComment, MODE_MARGINCALCMODE) == 0.0) //ie  forex
   {
      dATR = iATR(Symbol(),0,ATR_Period,1);
      dSLATR=(SL * dATR);
      dTPATR = (TP * dATR);
         
      bool bProfitCurr=(MarketInfo((AccountCurrency()+sCurrProfit), MODE_TICKVALUE)>0)?true:false;
      bool bBaseCurr = (MarketInfo((AccountCurrency()+sCurrBase), MODE_TICKVALUE)>0)?true:false;

      string newProfitCurr; 

       //Recommened pair
      if(Symbol()=="EURGBP"||Symbol()=="GBPCHF")
      {
         iLine++;
         sComment=" VP Recomended Pair";
               
         //ObjectCreate(current_chart_id,sObjNamePrefix+"_Info_"+iLine,OBJ_LABEL,0,0,0);
         sObjName=sObjNameInfoPrefix+sLine;
         ObjectCreate(sObjName,OBJ_LABEL,0,0,0,0,0);
         ObjectSet(sObjName,OBJPROP_CORNER,iCorner);
         ObjectSet(sObjName,OBJPROP_XDISTANCE,20);
         ObjectSet(sObjName,OBJPROP_YDISTANCE,20*iLine);
         ObjectSetText(sObjName,sComment,8,"Tahoma",White);
      }
         
      if(bProfitCurr==false)
      {
         newProfitCurr = sCurrProfit+AccountCurrency();
      }
      else
      {
         newProfitCurr = AccountCurrency()+sCurrProfit;
      }
      
      string newBaseCurr; 
      
      if(bBaseCurr==false)
      {  
         newBaseCurr = sCurrBase+AccountCurrency();
      }
      else
      {
         newBaseCurr = AccountCurrency()+sCurrBase;
      }   

      Print(newBaseCurr + ":" + newProfitCurr );

      /*
      if(StringTrimLeft(AccountCurrency())==StringTrimLeft(sCurrBase)){
         Print("1");
         dATRRatio=(iATR(newProfitCurr,1,1,1));        
      }
      else if(StringTrimLeft(AccountCurrency())==StringTrimLeft(sCurrProfit)){       
         Print("2");
         dATRRatio=iATR(sCurrBase,1,1,1);
      }
      else
      {
         //Print("3");
         if(iATR(newProfitCurr,1,1,1)==0) {return(0);}
         else
         dATRRatio = iATR(newBaseCurr,1,1,1)/iATR(newProfitCurr,1,1,1));
      }
      */
      //string sATRRatio = NormalizeDouble(dATRRatio,2);
      //Print("here:"+sATRRatio);
      
      //Print("BASE:"+MarketInfo(newBaseCurr, MODE_BID));
      //Print("POROFIT:"+MarketInfo(newProfitCurr, MODE_BID));
      
      iLine++;
      if(newBaseCurr=="GBPGBP"){
         dATRRatio= 1/MarketInfo(newProfitCurr, MODE_BID);
         
      }
      else if(newProfitCurr=="GBPGBP"){
         dATRRatio= MarketInfo(newBaseCurr, MODE_BID)/1;
      }
      else
      {
         
         dATRRatio = MarketInfo(newBaseCurr, MODE_BID)/MarketInfo(newProfitCurr, MODE_BID);
      }
      
      sComment="Ratio  "+ newBaseCurr+"/"+ newProfitCurr + " is "+ DoubleToStr(dATRRatio);
      sLine=IntegerToString(iLine);
      sObjName=sObjNameInfoPrefix+sLine;
      ObjectCreate(sObjName,OBJ_LABEL,0,0,0,0,0);
      ObjectSet(sObjName,OBJPROP_CORNER,iCorner);
      ObjectSet(sObjName,OBJPROP_XDISTANCE,20);
      ObjectSet(sObjName,OBJPROP_YDISTANCE,20*iLine);
      ObjectSetText(sObjName,sComment,8,"Tahoma",White);
 
       
          
      iLine++;
      sLine=IntegerToString(iLine);
      sObjName=sObjNameInfoPrefix+sLine; 
      dBalPer= NormalizeDouble((dModifiedAccountBalance*RiskPercent)/100,2);
      sComment="Equity remaining="+DoubleToStr(dModifiedAccountBalance)+": "+DoubleToStr(RiskPercent)+"%="+DoubleToStr(dBalPer);
      ObjectCreate(sObjName,OBJ_LABEL,0,0,0,0,0);
      ObjectSet(sObjName,OBJPROP_CORNER,iCorner);
      ObjectSet(sObjName,OBJPROP_XDISTANCE,20);
      ObjectSet(sObjName,OBJPROP_YDISTANCE,20*iLine);
      ObjectSetText(sObjName,sComment,8,"Tahoma",White);
      
      iLine++;
      sLine=IntegerToString(iLine);
      sObjName=sObjNameInfoPrefix+sLine;     
      if((Digits == 3) || (Digits == 5))
      {
         nTickValue = nTickValue * 10;
      }
      dLotSize = (dModifiedAccountBalance * RiskPercent / 100) / (SL * nTickValue);
      dLotSize = MathRound(dLotSize / MarketInfo(Symbol(), MODE_LOTSTEP)) * MarketInfo(Symbol(), MODE_LOTSTEP);
      sComment="Lot size:" + DoubleToStr(NormalizeDouble(dLotSize,2));// + " PipRatio:"+dPipRatio;
      ObjectSet(sObjName,OBJPROP_CORNER,iCorner);
      ObjectSet(sObjName,OBJPROP_XDISTANCE,20);
      ObjectSet(sObjName,OBJPROP_YDISTANCE,20*iLine);
      ObjectSetText(sObjName,sComment,8,"Tahoma",White);
   
      iLine++;
      sLine=IntegerToString(iLine);
      sObjName=sObjNameInfoPrefix+sLine; 
      dAmndLtSz =  NormalizeDouble(dLotSize-(dLotSize*dATRRatio),2);
      sComment="Amended Lot size:" + DoubleToStr(dAmndLtSz);
      ObjectCreate(sObjName,OBJ_LABEL,0,0,0,0,0);
      ObjectSet(sObjName,OBJPROP_CORNER,iCorner);
      ObjectSet(sObjName,OBJPROP_XDISTANCE,20);
      ObjectSet(sObjName,OBJPROP_YDISTANCE,20*iLine);
      ObjectSetText(sObjName,sComment,8,"Tahoma",White);
      
      iLine++;
      sLine=IntegerToString(iLine);
      sObjName=sObjNameInfoPrefix+sLine; 
      lLvg = AccountInfoInteger(ACCOUNT_LEVERAGE);
      sComment="Account Leverge:" + DoubleToStr(lLvg) +" Lot size="+DoubleToStr(NormalizeDouble((dAmndLtSz/lLvg),2));
      ObjectCreate(sObjName,OBJ_LABEL,0,0,0,0,0);
      ObjectSet(sObjName,OBJPROP_CORNER,iCorner);
      ObjectSet(sObjName,OBJPROP_XDISTANCE,20);
      ObjectSet(sObjName,OBJPROP_YDISTANCE,20*iLine);
      ObjectSetText(sObjName,sComment,8,"Tahoma",White);
      
      
      if(iSymbolCount>0){
         iLine++; 
         sLine=IntegerToString(iLine);
         sObjName=sObjNameInfoPrefix+sLine;  
         sComment="YOU ALREADY  HAVE "+ DoubleToString(iSymbolCount)+" ORDER(S) FOR THIS SYMBOL";
         ObjectCreate(sObjName,OBJ_LABEL,0,0,0,0,0);
         ObjectSet(sObjName,OBJPROP_CORNER,iCorner);
         ObjectSet(sObjName,OBJPROP_XDISTANCE,20);
         ObjectSet(sObjName,OBJPROP_YDISTANCE,20*iLine);
         ObjectSetText(sObjName,sComment,8,"Tahoma Bold",White);
      }
       
      string sAllCurr = sAllCurrBases+","+sAllCurrProfits;
      iCurrBasesCount=StringCountMatches(sAllCurr,sCurrBase);
      
      iCurrProfitCount=StringCountMatches(sAllCurr,sCurrProfit);
         
      if(iCurrBasesCount+iCurrProfitCount>0){
      
         iLine++;
         sLine=IntegerToString(iLine);
         sObjName=sObjNameInfoPrefix+sLine;  
         
         sComment="The BASE or PROFIT currrency is exposed " + IntegerToString((iCurrBasesCount+iCurrProfitCount))+  " times";

         ObjectCreate(sObjName,OBJ_LABEL,0,0,0,0,0);
         ObjectSet(sObjName,OBJPROP_CORNER,iCorner);
         ObjectSet(sObjName,OBJPROP_XDISTANCE,20);
         ObjectSet(sObjName,OBJPROP_YDISTANCE,20*iLine);
         ObjectSetText(sObjName,sComment,8,"Tahoma Bold",White);  
                 
      }
   }

   return(0);
}
