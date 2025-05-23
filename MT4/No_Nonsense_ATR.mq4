//+------------------------------------------------------------------+
//|                                              NO NONSENSE ATR.mq4 |
//|    Developed by HYPANTHIUM                                       |
//|                               PORTUGAL - 04/2021 - Version 5.80  |
//|                                                                  |
//| Filter ATR is based on:                                          |
//|                      FilteredATR.mq4 Developed by vitelot 1/2019 |
//|                                                                  |
//| Disclaimer:                             No warranties are given! |
//| By using the No Nonsense ATR indicator you agree that the        |
//| programer will not be held liable for any losses that            |
//| may be incured, or any faults or bugs that may be encountered    |
//| whilst using the No Nonsense ATR indicator.                      |
//|                                                                  |
//| Instructions, documentation and source code at:                  |
//|                 https://nnfxalgotester.com/help/no-nonsense-atr/ |
//| Licence: GNU General Public License v3.0                         |
//|                     https://choosealicense.com/licenses/gpl-3.0/ |
//+------------------------------------------------------------------+
#property strict
#property description "The ATR Indicator for the NNFX Traders"
#property description "Developed by Hypanthium - Portugal - https://www.nnfxalgotester.com"
#property description " "
#property description "Instructions, documentation and source code at:   https://nnfxalgotester.com/help/no-nonsense-atr/"
#property description " "
#property description "This software is Open Source. Licence: GNU General Public License v3.0"
#property description "No warranties are given!"

//---- input parameters
input int        ATR_TP_PERIOD        = 14;         // TP ATR PERIOD       
input double     ATR_TP_MULTIPLIER    = 1;          // TP MULTIPLIER            
input int        ATR_SL_PERIOD        = 14;         // SL ATR PERIOD  
input double     ATR_SL_MULTIPLIER    = 1.5;        // SL MULTIPLIER 
input char       ATR_SHIFT            = 0;          // ATR SHIFT
input int        ATR_digits           = 0;          // Nº OF DIGITS TO THE RIGHT OF a DECIMAL POINT
extern string     desc0               = "==========================";  //===================================
input bool       FILTER_ATR           = False;      // FILTER ATR?
input double     SD_multi             = 3;          // STANDARD DEVIATION MULTIPLIER
input int        sample_size          = 200;        // SAMPLE SIZE
extern string     desc1               = "==========================";  //===================================
input bool       SHOW_CORNER_TEXT     = True;       // SHOW CORNER TEXT?
input char       text_corner          = 0;          // TEXT CORNER 0-UL 1-UR 2-LL 3-LR
input int        text_size            = 14;         // FONT SIZE
input color      text_color           = Gold;       // TEXT COLOR
input color      subtext_color        = Gold;       // SUBTEXT COLOR
input bool       text_background      = True;       // SHOW CORNER TEXT BACKGROUND?
input color      solid_color          = Black;      // BACKGROUND COLOR
extern string     desc2               = "==========================";  //===================================
input bool       CLICK_TO_PAUSE       = True;       // MOUSE CLICK TO HOLD TEXT?
input bool       SHOW_SB_LINES        = False;      // SHOW SELL/BUY LINES AT THE SAME TIME?
input bool       SHOW_LINES_ON_CLICK  = True;       // SHOW TP/SL LINES ON CLICK?
input bool       LINES_UNTIL_PRICE    = True;       // SHOW TP/SL LINES UNTIL PRICE?
input bool       LINES_PRICE          = True;       // SHOW PRICE OF TP/SL LINES? 
input bool       ENTRY_PRICE          = True;       // SHOW ENTRY PRICE? 
input int        tp_line_size         = 0;          // TP LINE SIZE
input color      tp_line_color        = DeepSkyBlue;// TP LINE COLOR
input int        sl_line_size         = 0;          // SL LINE SIZE
input color      sl_line_color        = Red;        // SL LINE COLOR
extern string     desc3               = "==========================";  //===================================
enum trading_volume_enum 
  {
   ONLY=0,     // ONLY ON LASTEST CANDLE
   ALWAYS=1,   // ALWAYS
   NEVER=2,    // NEVER
  };
input trading_volume_enum TRADING_VOLUME=NEVER;   // SHOW TRADING VOLUME
input double     RISK                 = 1;          // RISK PER TRADE%
enum account_base_currency 
  {
   QUOTE=0,     // COUNTER CURRENCY
   USD=1,       // USD
   EUR=2,       // EUR
   GBP=3,       // GBP
   CAD=4,       // CAD
   AUD=5,       // AUD
   NZD=6,       // NZD
   JPY=7,       // JPY
   CHF=8,       // CHF
   SGD=9,       // SGD
  };
input account_base_currency ACCOUNT_CURRENCY=QUOTE;            // ACCOUNT BASE CURRENCY
enum account_value 
  {
   BALANCE=0,     // BALANCE
   EQUITY=1,      // EQUITY
   FREE_MARGIN=2, // FREE MARGIN
   FIXED_VALUE=3, // FIXED VALUE
  };
input account_value ACCOUNT_VALUE=BALANCE;          // USE ACCOUNT
input double     ACCOUNT_FIXED_VALUE  = 0;          // ACCOUNT FIXED VALUE (IF SELECTED)
input string     CURRENCY_PREFIX      = "";         // CURRENCY PREFIX (IF ANY)
input string     CURRENCY_SUFFIX      = "";         // CURRENCY SUFFIX (IF ANY)
enum trading_volume_digits 
  {
   AUTO=0,        // AUTO
   DIG_0=1,       // 0
   DIG_1=2,       // 1
   DIG_2=3,       // 2
   DIG_3=4,       // 3
   DIG_4=5,       // 4
   DIG_5=6,       // 5
  };
input trading_volume_digits TRADING_VOLUME_digits=AUTO;         // TRADING VOLUME RESOLUTION
extern string     desc4               = "==========================";  //===================================
input bool       LIVE_MODE            = false;      // LIVE MODE
input int        n_of_history_bars    = 0;          // LOOKBACK CANDLES (0-MAXIMUM)



double NNF_SL[],NNF_TP[],NNF_TRADING_VOL[], _NO_NORMALIZE_NNF_SL[];
char user_mouseclick=0, show_live, live_mode=0, first_try=1;
int barstocursor=0, n_of_bars_show=0, n_of_bars_calc=0, barstocursor_mouseclick=0;
double SL, TP;
char SHOW_TEXT=True;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){
   IndicatorBuffers(4);
   SetIndexBuffer(0,NNF_SL);         // Assigning an array to a buffer
   SetIndexLabel(0,"NNFX_SL");
   SetIndexStyle (0,DRAW_NONE);// nao desenhar
   SetIndexBuffer(1,NNF_TP);         // Assigning an array to a buffer
   SetIndexLabel(1,"NNFX_TP");
   SetIndexStyle (1,DRAW_NONE);// nao desenhar
   SetIndexBuffer(2,NNF_TRADING_VOL);         // Assigning an array to a buffer
   SetIndexLabel(2,"NNFX_TRADING_VOL");
   SetIndexStyle (2,DRAW_NONE);// nao desenhar
   SetIndexBuffer(3,_NO_NORMALIZE_NNF_SL);         // Assigning an array to a buffer

    
   if(SHOW_CORNER_TEXT==True){
      
      if(text_background==True){
         //https://www.mql5.com/en/forum/130520 https://www.mql5.com/en/forum/208082
         ObjectCreate("NO_NONSENSE_ATR_RECT", OBJ_LABEL, 0, 0, 0, 0 ,0);
         ObjectSetText("NO_NONSENSE_ATR_RECT", "gggggg", text_size*2, "Webdings", solid_color);
         ObjectSetInteger(0,"NO_NONSENSE_ATR_RECT",OBJPROP_READONLY,true);
         ObjectSetInteger(0,"NO_NONSENSE_ATR_RECT",OBJPROP_SELECTABLE,false);
         ObjectSet("NO_NONSENSE_ATR_RECT", OBJPROP_CORNER, text_corner);
         ObjectSet("NO_NONSENSE_ATR_RECT", OBJPROP_XDISTANCE, 0);
         ObjectSet("NO_NONSENSE_ATR_RECT", OBJPROP_YDISTANCE, 5+text_size);
         ObjectSet("NO_NONSENSE_ATR_RECT", OBJPROP_BACK, false);
      }
   
      ObjectCreate("NO_NONSENSE_ATR", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("NO_NONSENSE_ATR"," No Nonsense ATR",text_size, "Verdana", text_color);
      ObjectSetInteger(0,"NO_NONSENSE_ATR",OBJPROP_READONLY,true);
      ObjectSetInteger(0,"NO_NONSENSE_ATR",OBJPROP_SELECTABLE,false);
      ObjectSet("NO_NONSENSE_ATR", OBJPROP_CORNER, text_corner);
      ObjectSet("NO_NONSENSE_ATR", OBJPROP_XDISTANCE, 0);
      ObjectSet("NO_NONSENSE_ATR", OBJPROP_YDISTANCE, 5+text_size);
      
      ObjectCreate("NO_NONSENSE_ATR_FIXED", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("NO_NONSENSE_ATR_FIXED","",text_size, "Verdana", subtext_color);
      ObjectSetInteger(0,"NO_NONSENSE_ATR_FIXED",OBJPROP_READONLY,true);
      ObjectSetInteger(0,"NO_NONSENSE_ATR_FIXED",OBJPROP_SELECTABLE,false);
      ObjectSet("NO_NONSENSE_ATR_FIXED", OBJPROP_CORNER, text_corner);
      ObjectSet("NO_NONSENSE_ATR_FIXED", OBJPROP_XDISTANCE, 0);
      ObjectSet("NO_NONSENSE_ATR_FIXED", OBJPROP_YDISTANCE, 5+text_size*2+text_size/4); // distancia relativa ao tamanho do texto
      
      ObjectDelete("NO_NONSENSE_ATR_ERROR");
      ObjectDelete("NO_NONSENSE_ATR_FIXED_ERROR");
   }
   
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,1); // enable CHART_EVENT_MOUSE_MOVE messages

   update_n_of_bars();

   return(INIT_SUCCEEDED);
}
 

 
//+------------------------------------------------------------------+
//| get text description                                             |
//+------------------------------------------------------------------+
string getUninitReasonText(int reasonCode){
   string text="";
   switch(reasonCode){
      case REASON_ACCOUNT:
         text="Account was changed";break;
      case REASON_CHARTCHANGE:
         text="Symbol or timeframe was changed";break;
      case REASON_CHARTCLOSE:
         text="Chart was closed";break;
      case REASON_PARAMETERS:
         text="Input-parameter was changed";break;
      case REASON_RECOMPILE:
         text="Program "+__FILE__+" was recompiled";break;
      case REASON_REMOVE:
         text="Program "+__FILE__+" was removed from chart";break;
      case REASON_TEMPLATE:
         text="New template was applied to chart";break;
      default:text="Another reason";
     }
   return text;
}
//+------------------------------------------------------------------+
//| Deinitialization function                                        |
//+------------------------------------------------------------------+
int deinit(){
   if(SHOW_TEXT==true){ // saida nao por causa erro
      ObjectDelete("NO_NONSENSE_ATR"); // apagar objetos
      ObjectDelete("NO_NONSENSE_ATR_FIXED");
      ObjectDelete("NO_NONSENSE_ATR_RECT");
      
      ObjectDelete("NO_NONSENSE_ATR_ERROR");
      ObjectDelete("NO_NONSENSE_ATR_FIXED_ERROR");
      
      ObjectDelete("NO_NONSENSE_ATR_ORDER_LINE");
      ObjectDelete("NO_NONSENSE_ATR_ORDER_LINE_TEXT");
      
      lines_delete(0);
      lines_delete(1);
   }
   
   //Print("No Nonsense ATR Uninit Reason - ",getUninitReasonText(_UninitReason));
   return(0);
}
//+------------------------------------------------------------------+
//| Fazer sair do programa porque ocorreu um erro                    |
//+------------------------------------------------------------------+
void exit_program(string error_code, string text, string text2){
   if(SHOW_TEXT==true){
      ObjectDelete("NO_NONSENSE_ATR"); // apagar objetos
      ObjectDelete("NO_NONSENSE_ATR_FIXED");

      ObjectCreate("NO_NONSENSE_ATR_ERROR", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("NO_NONSENSE_ATR_ERROR"," No Nonsense ATR",text_size, "Verdana", text_color);
      ObjectSetInteger(0,"NO_NONSENSE_ATR_ERROR",OBJPROP_READONLY,true);
      ObjectSetInteger(0,"NO_NONSENSE_ATR_ERROR",OBJPROP_SELECTABLE,false);
      ObjectSet("NO_NONSENSE_ATR_ERROR", OBJPROP_CORNER, text_corner);
      ObjectSet("NO_NONSENSE_ATR_ERROR", OBJPROP_XDISTANCE, 0);
      ObjectSet("NO_NONSENSE_ATR_ERROR", OBJPROP_YDISTANCE, 5+text_size);
      
      ObjectCreate("NO_NONSENSE_ATR_FIXED_ERROR", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("NO_NONSENSE_ATR_FIXED_ERROR"," -- ERROR "+error_code+" -- Check the Experts tab!",text_size, "Verdana", subtext_color);
      ObjectSetInteger(0,"NO_NONSENSE_ATR_FIXED_ERROR",OBJPROP_READONLY,true);
      ObjectSetInteger(0,"NO_NONSENSE_ATR_FIXED_ERROR",OBJPROP_SELECTABLE,false);
      ObjectSet("NO_NONSENSE_ATR_FIXED_ERROR", OBJPROP_CORNER, text_corner);
      ObjectSet("NO_NONSENSE_ATR_FIXED_ERROR", OBJPROP_XDISTANCE, 0);
      ObjectSet("NO_NONSENSE_ATR_FIXED_ERROR", OBJPROP_YDISTANCE, 5+text_size*2+text_size/4);
      
      
      Print("");
      Print(text2);
      Print("No Nonsense ATR ERROR - "+text);
      
      Print("");
      
      ObjectDelete("NO_NONSENSE_ATR_ORDER_LINE");
      ObjectDelete("NO_NONSENSE_ATR_ORDER_LINE_TEXT");
      lines_delete(0);
      lines_delete(1);
      bool res=ChartIndicatorDelete(0,ChartWindowFind(),"No_Nonsense_ATR");
      if(!res){
         PrintFormat("Failed to delete indicator",GetLastError());  
         Print("Make a zero divide to exit program.");
         n_of_bars_show=0; n_of_bars_show=1/n_of_bars_show; // make a zero divide to exit program
      }
      SHOW_TEXT=FALSE;
   }
}
//+------------------------------------------------------------------+
//| lines_delete                                                     |
//|  0-delete sell lines 1- delete buy lines                         |
//+------------------------------------------------------------------+
void lines_delete(char lines){
            
   if (lines==1){
   ObjectDelete("NO_NONSENSE_ATR_TP_LINE_BUY");
   ObjectDelete("NO_NONSENSE_ATR_TP_TEXT_BUY");
   ObjectDelete("NO_NONSENSE_ATR_SL_LINE_BUY");
   ObjectDelete("NO_NONSENSE_ATR_SL_TEXT_BUY");
   }else{
   ObjectDelete("NO_NONSENSE_ATR_TP_LINE_SELL");
   ObjectDelete("NO_NONSENSE_ATR_TP_TEXT_SELL");
   ObjectDelete("NO_NONSENSE_ATR_SL_LINE_SELL");
   ObjectDelete("NO_NONSENSE_ATR_SL_TEXT_SELL");
   }      

}
//+------------------------------------------------------------------+
//| update_n_of_bars                                                 |
//|  Faz o update das variaveis   n_of_bars_show &&   n_of_bars_calc |
//+------------------------------------------------------------------+
void update_n_of_bars(){

   if(FILTER_ATR==False){
      if(n_of_history_bars==0){
         if(ATR_TP_PERIOD>=ATR_SL_PERIOD){
            n_of_bars_show=Bars-ATR_TP_PERIOD-ATR_SHIFT;
         }else{
            n_of_bars_show=Bars-ATR_SL_PERIOD-ATR_SHIFT;
         }
         n_of_bars_calc=Bars;
      }else{
         if(ATR_TP_PERIOD>=ATR_SL_PERIOD){
            n_of_bars_show=n_of_history_bars-ATR_TP_PERIOD-ATR_SHIFT;
         }else{
            n_of_bars_show=n_of_history_bars-ATR_SL_PERIOD-ATR_SHIFT;
         }
         n_of_bars_calc=n_of_history_bars;
      }
   }else{
      if(n_of_history_bars==0){ 
         if(ATR_TP_PERIOD>=ATR_SL_PERIOD){
            n_of_bars_show=Bars-(sample_size+ATR_TP_PERIOD);
         }else{
            n_of_bars_show=Bars-(sample_size+ATR_SL_PERIOD);
         }
         n_of_bars_calc=Bars;
      }else{
         if(ATR_TP_PERIOD>=ATR_SL_PERIOD){
            n_of_bars_calc=n_of_history_bars+(sample_size+ATR_TP_PERIOD);
         }else{
            n_of_bars_calc=n_of_history_bars+(sample_size+ATR_SL_PERIOD);
         }
         n_of_bars_show=n_of_history_bars-ATR_SHIFT;
      }
   }       
   
}


//+------------------------------------------------------------------+
//|                          calc_lots()                             |
//| Calcula o numero de lots de acordo com o risco                   |
//|        (calcula os lots sempre baseado no preço atual)           |
//+------------------------------------------------------------------+
double calc_lots(double stoploss, int candle){
   double lots, price_symbol, pip_value=1, account_value_to_use;
   string symbol_base, symbol_counter, calc_symbol, final_symbol, symbol_account_currency, string_aux;
   bool invert_symbol=0;
   double lotsize = MarketInfo(_Symbol,MODE_LOTSIZE);
   string symbol_margin=SymbolInfoString(_Symbol,SYMBOL_CURRENCY_MARGIN);
   if(lotsize==0){
      Print("Could not get LOT size value. The value 100000 will be used.");
      lotsize=100000;
   }
   
   symbol_base=StringSubstr(CURRENCY_PREFIX+_Symbol+CURRENCY_SUFFIX,StringLen(CURRENCY_PREFIX),3);
   symbol_counter=StringSubstr(CURRENCY_PREFIX+_Symbol+CURRENCY_SUFFIX,StringLen(CURRENCY_PREFIX)+3,3);
   //Print("symbol_base=",symbol_base,"     symbol_counter=",symbol_counter);
   //Print("SYMBOL_CURRENCY_MARGIN=",symbol_margin);

   if(ACCOUNT_CURRENCY==1){
      symbol_account_currency="USD";
   }else if(ACCOUNT_CURRENCY==2){
      symbol_account_currency="EUR";
   }else if(ACCOUNT_CURRENCY==3){
      symbol_account_currency="GBP";
   }else if(ACCOUNT_CURRENCY==4){
      symbol_account_currency="CAD";
   }else if(ACCOUNT_CURRENCY==5){
      symbol_account_currency="AUD";
   }else if(ACCOUNT_CURRENCY==6){
      symbol_account_currency="NZD";
   }else if(ACCOUNT_CURRENCY==7){
      symbol_account_currency="JPY";
   }else if(ACCOUNT_CURRENCY==8){
      symbol_account_currency="CHF";
   }else if(ACCOUNT_CURRENCY==9){
      symbol_account_currency="SGD";
   }else{
      symbol_account_currency="QUOTE";
   }
   string_aux=symbol_account_currency;
   
   if (StringCompare(symbol_account_currency,symbol_counter)==0 || symbol_account_currency=="QUOTE"){
      price_symbol=1;
      pip_value=(Point*lotsize);
   }else if(StringCompare(symbol_account_currency,symbol_base)==0){ // Moeda da conta é igual à moeda base do par
      price_symbol=Ask;
      pip_value=(Point*lotsize)/price_symbol;
   }else if( (symbol_base!="USD" && symbol_base!="EUR" && symbol_base!="GBP" && symbol_base!="CAD" && symbol_base!="AUD" && symbol_base!="NZD" && symbol_base!="JPY" && symbol_base!="CHF" && symbol_base!="SGD") || (symbol_counter!="USD" && symbol_counter!="EUR" && symbol_counter!="GBP" && symbol_counter!="CAD" && symbol_counter!="AUD" && symbol_counter!="NZD" && symbol_counter!="JPY" && symbol_counter!="CHF" && symbol_counter!="SGD")) {
      
      if(symbol_account_currency!=symbol_margin && symbol_account_currency!="QUOTE"){ // symbol_account_currency nao é igual à moeda da margin nem a opção "quote"
         //Print("The QUOTE/MARGIN currency ("+symbol_margin+") will be used as account currency for the trading volume calculations.");
         //exit_program("(E01)","(E01) The QUOTE/MARGIN currency ("+symbol_margin+") will be used as account currency for the trading volume calculations.","The QUOTE/MARGIN currency ("+symbol_margin+") will be used as account currency for the trading volume calculations.");
      }
      //symbol_account_currency=symbol_margin; // QUOTE
      price_symbol=1;
      pip_value=(Point*lotsize);
   }else{ // https://www.earnforex.com/guides/pip-value-formula/  //https://www.myfxbook.com/forex-calculators/position-size
      if (symbol_account_currency=="USD") {
         if (symbol_counter=="NZD" || symbol_counter=="GBP" || symbol_counter=="AUD" || symbol_counter=="EUR") { // trocar USDNZD USDGBP USDAUD USDEUR trocar para NZDUSD GBPUSD AUDUSD EURUSD
            StringAdd(symbol_counter,symbol_account_currency);
            calc_symbol=symbol_counter;
            invert_symbol=1;
         }else{ // outros pares estão bem // USDJPY USDCHF USDCAD USDSGD
            StringAdd(string_aux,symbol_counter);
            calc_symbol=string_aux;
         }
      }else if (symbol_account_currency=="EUR") { // pares EUR estão todos bem // EURCAD EURJPY EURNZD EURUSD EURAUD EURCHF EURGBP EURSGD
         StringAdd(string_aux,symbol_counter);
         calc_symbol=string_aux;
      }else if (symbol_account_currency=="GBP") { 
         if (symbol_counter=="EUR") {              // GBPEUR -> EURGBP
            StringAdd(symbol_counter,string_aux);
            calc_symbol=symbol_counter;
            invert_symbol=1;
         }else{                                    // GBPCAD GBPCHF GBPJPY GBPAUD GBPNZD GBPUSD GBPSGD
            StringAdd(string_aux,symbol_counter);
            calc_symbol=string_aux;
         }
      }else if (symbol_account_currency=="CAD") { 
         if (symbol_counter=="GBP" || symbol_counter=="EUR" || symbol_counter=="USD" || symbol_counter=="AUD" || symbol_counter=="NZD") {              // CADGBP CADEUR CADUSD CADNZD CADAUD -> GBPCAD EURCAD USDCAD NZDCAD AUDCAD
            StringAdd(symbol_counter,string_aux);
            calc_symbol=symbol_counter;
            invert_symbol=1;
         }else{                                    // CADCHF CADJPY CADSGD
            StringAdd(string_aux,symbol_counter);
            calc_symbol=string_aux;
         }
      }else if (symbol_account_currency=="AUD") { 
         if (symbol_counter=="GBP" || symbol_counter=="EUR") {              // AUDEUR AUDBGBP -> EURAUD GBPAUD
            StringAdd(symbol_counter,string_aux);
            calc_symbol=symbol_counter;
            invert_symbol=1;
         }else{                                    // AUDJPY AUDCAD AUDCHF AUDUSD AUDNZD AUDSGD
            StringAdd(string_aux,symbol_counter);
            calc_symbol=string_aux;
         }
      }else if (symbol_account_currency=="NZD") { 
         if (symbol_counter=="GBP" || symbol_counter=="EUR" || symbol_counter=="AUD") {              // NZDAUD NZDEUR NZDGBP -> AUDNZD EURNZD GBPNZD
            StringAdd(symbol_counter,string_aux);
            calc_symbol=symbol_counter;
            invert_symbol=1;
         }else{                                    // NZDCHF NZDJPY NZDCAD NZDUSD NZDSGD
            StringAdd(string_aux,symbol_counter);
            calc_symbol=string_aux;
         }
      }else if (symbol_account_currency=="JPY") { 
         if (symbol_counter=="GBP" || symbol_counter=="EUR" || symbol_counter=="AUD" || symbol_counter=="CAD" || symbol_counter=="NZD" || symbol_counter=="USD" || symbol_counter=="CHF" || symbol_counter=="SGD") {              // JPYGBP JPYEUR JPYAUD JPYCAD JPYNZD JPYUSD JPYCHF JPYSGD -> GBPJPY EURJPY AUDJPY CADJPY NZDJPY USDJPY CHFJPY SGDJPY
            StringAdd(symbol_counter,string_aux);
            calc_symbol=symbol_counter;
            invert_symbol=1;
         }
      }else if (symbol_account_currency=="CHF") { 
         if (symbol_counter=="GBP" || symbol_counter=="EUR" || symbol_counter=="AUD" || symbol_counter=="CAD" || symbol_counter=="NZD" || symbol_counter=="USD") {              // CHFGBP CHFEUR CHFAUD CHFCAD CHFNZD CHFUSD -> GBPCHF EURCHF AUDCHF CADCHF NZDCHF USDCHF
            StringAdd(symbol_counter,string_aux);
            calc_symbol=symbol_counter;
            invert_symbol=1;
         }else{                                    // CHFJPY CHFSGD
            StringAdd(string_aux,symbol_counter);
            calc_symbol=string_aux;
         }
      }else if (symbol_account_currency=="SGD") { 
         if (symbol_counter=="GBP" || symbol_counter=="EUR" || symbol_counter=="AUD" || symbol_counter=="CAD" || symbol_counter=="NZD" || symbol_counter=="USD" || symbol_counter=="CHF") {              // SGDGBP SGDEUR SGDAUD SGDCAD SGDNZD SGDUSD SGDCHF -> GBPSGD EURSGD AUDSGD CADSGD NZDSGD USDSGD CHFSGD
            StringAdd(symbol_counter,string_aux);
            calc_symbol=symbol_counter;
            invert_symbol=1;
         }else{                                    // SGDJPY
            StringAdd(string_aux,symbol_counter);
            calc_symbol=string_aux;
         }
      }
      // juntar prefixo e sufixo
      //final_symbol=CUREENCY_PREFIX; 
      //StringAdd(calc_symbol,CUREENCY_SUFFIX);
      //StringAdd(final_symbol,calc_symbol);
      
      final_symbol=calc_symbol;
      //Print(final_symbol);
      
      if (invert_symbol==1){// par invertido logo inverter preço
         price_symbol=(MarketInfo(final_symbol,MODE_BID));
      }else{
         price_symbol=MarketInfo(final_symbol,MODE_ASK);
      }
      if(price_symbol==0){ // ERRO AO BUSCAR DADOS DO PAR
         exit_program("(E02)","(E02) The "+final_symbol+" pair does not exist or is not possible to obtain the price."," Offline graph? Select COUNTER CURRENCY as ACCOUNT BASE CURRENCY.");
      }else{
         pip_value=(Point*lotsize)/price_symbol;
      }
      
   }
   //Print("Pip Value - ",pip_value);
   
   if(ACCOUNT_VALUE==0){
      account_value_to_use=AccountBalance();
   }else if(ACCOUNT_VALUE==1){
      account_value_to_use=AccountEquity();
   }else if(ACCOUNT_VALUE==2){
      account_value_to_use=AccountFreeMargin();
   }else{
      account_value_to_use=ACCOUNT_FIXED_VALUE;
    }
   
   lots = (account_value_to_use*(RISK/100))/(stoploss*10*pip_value);
   
   //Print("PAR-",final_symbol, " = ", price_symbol, " LOTS-",lots );
   //Print("Amount at ",RISK,"% Risk=",NormalizeDouble((account_value_to_use*(RISK/100)),2), " (",symbol_account_currency,") (",NormalizeDouble(lots,2)," lots)" );
   
   int norm = 0;
   if(TRADING_VOLUME_digits==0){ 
      double step = MarketInfo(_Symbol,MODE_LOTSTEP);
      double minlot = MarketInfo(_Symbol,MODE_MINLOT);
      double maxlot = MarketInfo(_Symbol,MODE_MAXLOT);
   
      if(step==0 || minlot==0 || maxlot==0){
         exit_program("(E03)","(E03) Could not get STEP LOT ("+DoubleToStr(step,4)+"), MIN LOT ("+DoubleToStr(minlot,4)+") and MAX LOT ("+DoubleToStr(maxlot,4)+") size value."," The AUTO option in the TRADING VOLUME RESOLUTION input can not be used, choose another resolution.");
         step=0.01;
         maxlot=1000;
         minlot=0.01;
      } 
      
      if (step==1)    norm = 0;
      if (step==0.1)  norm = 1;
      if (step==0.01) norm = 2;
      if(step>1 && lots>step){
         lots=NormalizeDouble((lots/step),0)*step;
      }else{
         lots = NormalizeDouble(lots,norm);
      }
      
      //Print("Margin Currency=",symbol_margin,"   Contrat Size=",lotsize, "   Lot Step=",step,"   Lot Min=",minlot,"   Lot Max=",maxlot );
      
      if (lots>maxlot){
         if(candle>0){ // deu algum erro no historico - nao é importante
            lots=maxlot;
         }else{
            exit_program("(E04)","(E04) The value of the calculated trading volume ("+DoubleToStr((account_value_to_use*(RISK/100))/(stoploss*10*pip_value),4)+ "=~"+ DoubleToStr(lots,4)+") is bigger than the maximum allowed by the broker ("+DoubleToStr(maxlot,4)+")."," To disable this error, choose another option (not AUTO) in the TRADING VOLUME RESOLUTION input.");
         }
      }else if(lots<minlot){
         if(candle>0){ // deu algum erro no historico - nao é importante
            lots=minlot;
         }else{
            exit_program("(E05)","(E05) The value of the calculated trading volume ("+DoubleToStr((account_value_to_use*(RISK/100))/(stoploss*10*pip_value),4)+ "=~"+DoubleToStr(lots,4)+") is smaller than the minimum allowed by the broker ("+DoubleToStr(minlot,4)+")."," To disable this error, choose another option (not AUTO) in the TRADING VOLUME RESOLUTION input.");
         }
      }
   }else{
      norm = TRADING_VOLUME_digits-1;
      lots = NormalizeDouble(lots,norm);
   }


   return lots;
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


   if (n_of_bars_show<1){ // tratar erro
     if(first_try==1){ // se for a primeira vez que a função oncalculate é executada 
         update_n_of_bars();
     }else{
        exit_program("(E06)","(E06) Are not there enough candles in the chart? ("+IntegerToString(n_of_bars_show)+")."," Maybe reloading the indicator will solve the problem.");
     } 
   }
   if (ATR_SHIFT<0){ // tratar erro
     exit_program("(E11)","(E11) ATR SHIFT cannot be a negative value (ATR SHIFT="+IntegerToString(ATR_SHIFT)+").","");
   }
   if (n_of_bars_show>n_of_bars_calc){ // tratar erro
     exit_program("(E07)","(E07) You need more candles to calculate the number of values you want ("+IntegerToString(n_of_bars_show)+">"+IntegerToString(n_of_bars_calc)+")."," If you are using Filtered ATR then decrease the SAMPLE SIZE.");
   }
   if (n_of_bars_show>Bars){ // tratar erro
     exit_program("(E08)","(E08) The N OF HISTORY BARS ("+IntegerToString(n_of_bars_show)+") can not be higher than the number of candles available in the chart ("+IntegerToString(Bars)+")!","");
   }
   if(FILTER_ATR==false){
      for(int i=0; i<n_of_bars_show; i++) {
         NNF_TP[i]=NormalizeDouble(((iATR(NULL,0,ATR_TP_PERIOD,ATR_SHIFT+i)/Point)/10)*ATR_TP_MULTIPLIER,ATR_digits);
         NNF_SL[i]=NormalizeDouble(((iATR(NULL,0,ATR_SL_PERIOD,ATR_SHIFT+i)/Point)/10)*ATR_SL_MULTIPLIER,ATR_digits);
         _NO_NORMALIZE_NNF_SL[i]=((iATR(NULL,0,ATR_SL_PERIOD,ATR_SHIFT+i)/Point)/10)*ATR_SL_MULTIPLIER;
      }
   }else{
      if (sample_size>Bars){ // tratar erro
         exit_program("(E09)","(E09) The SAMPLE SIZE ("+IntegerToString(sample_size)+") can not be higher than the number of candles available in the chart ("+IntegerToString(Bars)+")!","");
      }
      if (n_of_bars_calc>Bars){ // tratar erro
         exit_program("(E10)","(E10) There must be at least "+IntegerToString(n_of_bars_calc)+" candles available to calculate the filtered ATR! Candles available in the chart = "+IntegerToString(Bars)+".","");
      }
      
      double         atr_1[];
      double         atr_medio[];
      double         atr_sd[];
      double         filted_atr[];
      
      ArrayResize(atr_1,Bars);
      ArrayResize(atr_medio,Bars);
      ArrayResize(atr_sd,Bars);
      ArrayResize(filted_atr,0);
      
      for(int i=0; i<Bars; i++) {
         atr_medio[i] = iATR(NULL, 0, sample_size, i);
         atr_1[i] = iATR(NULL, 0, 1, i);
      }
   
      for(int i=0; i<Bars; i++) {
         atr_sd[i]=iStdDevOnArray(atr_1,0,sample_size,0,MODE_SMA,i);
      }
   
      for(int i=0; i<n_of_bars_calc; i++) {
        ArrayResize(filted_atr,ArraySize(filted_atr)+1);
        if( atr_1[i] > (atr_medio[i] + SD_multi*atr_sd[i]) ){
            filted_atr[i] = atr_medio[i];
            //Print(i," --- ",atr_1[i], " > ", (atr_medio[i] + SD_multi*atr_sd[i]));
        } else { 
            filted_atr[i] = atr_1[i];
        }
      }
   
      for(int i=0; i<n_of_bars_show; i++) {
         NNF_TP[i]=NormalizeDouble(((iMAOnArray(filted_atr,n_of_bars_calc,ATR_TP_PERIOD,-ATR_TP_PERIOD-ATR_SHIFT,0,n_of_bars_calc-i)/Point)/10)*ATR_TP_MULTIPLIER,ATR_digits);
         NNF_SL[i]=NormalizeDouble(((iMAOnArray(filted_atr,n_of_bars_calc,ATR_SL_PERIOD,-ATR_SL_PERIOD-ATR_SHIFT,0,n_of_bars_calc-i)/Point)/10)*ATR_SL_MULTIPLIER,ATR_digits);
         _NO_NORMALIZE_NNF_SL[i]=((iMAOnArray(filted_atr,n_of_bars_calc,ATR_SL_PERIOD,-ATR_SL_PERIOD-ATR_SHIFT,0,n_of_bars_calc-i)/Point)/10)*ATR_SL_MULTIPLIER;
      }
  
   }
   
   for(int i=0; i<n_of_bars_show; i++) {
      if(TRADING_VOLUME==0 || TRADING_VOLUME==1){
         NNF_TRADING_VOL[i]=calc_lots(_NO_NORMALIZE_NNF_SL[i],i);
      }else
         NNF_TRADING_VOL[i]=EMPTY_VALUE;
   }
   


   if(SHOW_CORNER_TEXT==True && barstocursor==0 && ((user_mouseclick==0 || user_mouseclick==1) || live_mode==1)){
      string text; 

      TP=NNF_TP[0]; // mais rapido
      SL=NNF_SL[0];
      
      
      if (TRADING_VOLUME==0 || TRADING_VOLUME==1){
         //ObjectSetText("NO_NONSENSE_ATR_FIXED"," -- LIVE -- ",text_size, "Verdana", subtext_color);
         if(TRADING_VOLUME_digits==0) 
            text=StringConcatenate("\n SL = ", DoubleToString(SL,ATR_digits), " pips     TP = ",  DoubleToString(TP,ATR_digits), " pips     VOL = ", DoubleToString(NNF_TRADING_VOL[0],2), " lots");  
         else
            text=StringConcatenate("\n SL = ", DoubleToString(SL,ATR_digits), " pips     TP = ",  DoubleToString(TP,ATR_digits), " pips     VOL = ", DoubleToString(NNF_TRADING_VOL[0],TRADING_VOLUME_digits-1), " lots");
      }else{
         text=StringConcatenate("\n SL = ", DoubleToString(SL,ATR_digits), " pips     TP = ",  DoubleToString(TP,ATR_digits), " pips");  
      }
      
      if(text_background==True){
         string backtext="g";
         for(char x=0;x<(StringLen(text)/4); x++){ // Ajustar background ao texto
            if(IsStopped())
               break;
            StringAdd(backtext,"g");
         }
         ObjectSetText("NO_NONSENSE_ATR_RECT", backtext, text_size*2, "Webdings", solid_color);
      }
      
      ObjectSetText("NO_NONSENSE_ATR",text,text_size, "Verdana", text_color);
      
   }  
   
   first_try=0; //reset flag first_try
   return(rates_total); //--- return value of prev_calculated for next call
  }
  
  
  
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam){
   if(id==CHARTEVENT_MOUSE_MOVE && LIVE_MODE==false && (user_mouseclick==0 || user_mouseclick==1 || (user_mouseclick==2 && live_mode==1) ) ){
      
      //--- Prepare variables
      int      x     =(int)lparam;
      int      y     =(int)dparam;
      datetime dt    =0;
      double   price =0;
      int      window=0;
      if(ChartXYToTimePrice(0,x,y,window,dt,price)){
         //PrintFormat("Window=%d X=%d  Y=%d  =>  Time=%s  Price=%G",window,x,y,TimeToString(dt),price);
         
         barstocursor=Bars(NULL, 0, dt, iTime(NULL, 0, 0))-1;
         if (dt>iTime(NULL, 0, 0)){
            show_live=1;
         }else{
            show_live=0;
         }
         
         if(barstocursor >= n_of_bars_show){ // nao mostra valores depois do limite
            TP=0;
            SL=0;
         }else{
            TP=NNF_TP[barstocursor]; // mais rapido
            SL=NNF_SL[barstocursor];
         }
         
         if(SHOW_CORNER_TEXT==True && user_mouseclick==0){
            string text;
            if ( ((show_live==1 || barstocursor==0) && TRADING_VOLUME==0) || TRADING_VOLUME==1 ){
               if(TRADING_VOLUME_digits==0) 
                  text=StringConcatenate("\n SL = ", DoubleToString(SL,ATR_digits), " pips     TP = ",  DoubleToString(TP,ATR_digits), " pips     VOL = ", DoubleToString(NNF_TRADING_VOL[barstocursor],2), " lots");  
               else
                  text=StringConcatenate("\n SL = ", DoubleToString(SL,ATR_digits), " pips     TP = ",  DoubleToString(TP,ATR_digits), " pips     VOL = ", DoubleToString(NNF_TRADING_VOL[barstocursor],TRADING_VOLUME_digits-1), " lots");  
            }else{
               text=StringConcatenate("\n SL = ", DoubleToString(SL,ATR_digits), " pips     TP = ",  DoubleToString(TP,ATR_digits), " pips");    
            }
            if(text_background==True){
               string backtext="g";
               for(char i=0;i<(StringLen(text)/4); i++){ // Ajustar background ao texto
                  if(IsStopped())
                     break;
                  StringAdd(backtext,"g");
               }
               ObjectSetText("NO_NONSENSE_ATR_RECT", backtext, text_size*2, "Webdings", solid_color);
            }
            ObjectSetText("NO_NONSENSE_ATR",text,text_size, "Verdana", text_color);
         }  
      //}else{
      //   Print("ChartXYToTimePrice return error code: ",GetLastError());
      }
   }
   if(id==CHARTEVENT_CLICK && CLICK_TO_PAUSE==True && LIVE_MODE==false){
      
      if(user_mouseclick==0 || (user_mouseclick==1 && barstocursor==barstocursor_mouseclick) ){
         
         int a=0, i=0, x=0, y=0;
         
         if (SHOW_SB_LINES==False) 
            user_mouseclick++;
         else
            user_mouseclick=2;
         
         if((barstocursor) >= n_of_bars_show){ // nao mostra valores depois do limite
            ObjectSetText("NO_NONSENSE_ATR_FIXED"," -- NO DATA --",text_size, "Verdana", subtext_color);
         }else{
            if(show_live==1){ 
               ObjectSetText("NO_NONSENSE_ATR_FIXED"," -- LIVE -- ",text_size, "Verdana", subtext_color);
               user_mouseclick=2; // no double clique
               lines_delete(1); // delete buy lines
               ObjectDelete("NO_NONSENSE_ATR_ORDER_LINE");
               if(ENTRY_PRICE==true) ObjectDelete("NO_NONSENSE_ATR_ORDER_LINE_TEXT");
               live_mode=1;
            }else{
               ObjectSetText("NO_NONSENSE_ATR_FIXED"," -- FIXED -- ",text_size, "Verdana", subtext_color);
            
               if(SHOW_LINES_ON_CLICK==True && CLICK_TO_PAUSE==True){// -- desenhar linhas
               
                  ObjectCreate("NO_NONSENSE_ATR_ORDER_LINE", OBJ_TREND, 0, Time[barstocursor+1], Close[barstocursor], Time[barstocursor], Close[barstocursor]);
                  ObjectSetInteger(0,"NO_NONSENSE_ATR_ORDER_LINE",OBJPROP_SELECTABLE,false);
                  ObjectSet("NO_NONSENSE_ATR_ORDER_LINE", OBJPROP_WIDTH, 0);
                  ObjectSet("NO_NONSENSE_ATR_ORDER_LINE", OBJPROP_COLOR, text_color);
                  ObjectSet("NO_NONSENSE_ATR_ORDER_LINE", OBJPROP_RAY_RIGHT, 0);
                  
                  if(ENTRY_PRICE==true){
                     ObjectCreate("NO_NONSENSE_ATR_ORDER_LINE_TEXT", OBJ_TEXT, 0, Time[barstocursor+2], NormalizeDouble(Close[barstocursor],Digits));
                     ObjectSetInteger(0,"NO_NONSENSE_ATR_ORDER_LINE_TEXT",OBJPROP_SELECTABLE,false);
                  }
                  
                  if(LINES_UNTIL_PRICE==False){
                     
                     ObjectCreate("NO_NONSENSE_ATR_TP_LINE_BUY", OBJ_TREND, 0, Time[barstocursor+1], Close[barstocursor] + TP * 10 * Point, Time[barstocursor], Close[barstocursor]+ TP *10 * Point);
                     ObjectCreate("NO_NONSENSE_ATR_SL_LINE_BUY", OBJ_TREND, 0, Time[barstocursor+1], Close[barstocursor] - SL * 10 * Point, Time[barstocursor], Close[barstocursor]- SL *10 * Point);
                     ObjectSetInteger(0,"NO_NONSENSE_ATR_TP_LINE_BUY",OBJPROP_SELECTABLE,false);
                     ObjectSetInteger(0,"NO_NONSENSE_ATR_SL_LINE_BUY",OBJPROP_SELECTABLE,false);
                     ObjectSet("NO_NONSENSE_ATR_TP_LINE_BUY", OBJPROP_RAY_RIGHT, 1);
                     ObjectSet("NO_NONSENSE_ATR_SL_LINE_BUY", OBJPROP_RAY_RIGHT, 1);
                     
                     ObjectCreate("NO_NONSENSE_ATR_TP_LINE_SELL", OBJ_TREND, 0, Time[barstocursor+1], Close[barstocursor] - TP * 10 * Point, Time[barstocursor], Close[barstocursor]- TP *10 * Point);
                     ObjectCreate("NO_NONSENSE_ATR_SL_LINE_SELL", OBJ_TREND, 0, Time[barstocursor+1], Close[barstocursor] + SL * 10 * Point, Time[barstocursor], Close[barstocursor]+ SL *10 * Point);
                     ObjectSetInteger(0,"NO_NONSENSE_ATR_TP_LINE_SELL",OBJPROP_SELECTABLE,false);
                     ObjectSetInteger(0,"NO_NONSENSE_ATR_SL_LINE_SELL",OBJPROP_SELECTABLE,false);       
                     ObjectSet("NO_NONSENSE_ATR_TP_LINE_SELL", OBJPROP_RAY_RIGHT, 1);
                     ObjectSet("NO_NONSENSE_ATR_SL_LINE_SELL", OBJPROP_RAY_RIGHT, 1);
                     
                  }else{
  
                     for(a=barstocursor-1; a>=0; a--){
                        if(High[a] >= (Close[barstocursor] + TP * 10 * Point) ){ // NO_NONSENSE_ATR_TP_LINE_BUY
                           ObjectCreate("NO_NONSENSE_ATR_TP_LINE_BUY", OBJ_TREND, 0, Time[barstocursor+1], Close[barstocursor] + TP * 10 * Point, Time[a], Close[barstocursor]+ TP *10 * Point);
                           ObjectSetInteger(0,"NO_NONSENSE_ATR_TP_LINE_BUY",OBJPROP_SELECTABLE,false);
                           ObjectSet("NO_NONSENSE_ATR_TP_LINE_BUY", OBJPROP_RAY_RIGHT, 0);
                           break;
                        }
                     }
                     if(a<0){
                        ObjectCreate("NO_NONSENSE_ATR_TP_LINE_BUY", OBJ_TREND, 0, Time[barstocursor+1], Close[barstocursor] + TP * 10 * Point, Time[barstocursor], Close[barstocursor]+ TP *10 * Point);
                        ObjectSetInteger(0,"NO_NONSENSE_ATR_TP_LINE_BUY",OBJPROP_SELECTABLE,false);
                        ObjectSet("NO_NONSENSE_ATR_TP_LINE_BUY", OBJPROP_RAY_RIGHT, 1);
                     }
                     for(i=barstocursor-1; i>=0; i--){ 
                        if(High[i] >= (Close[barstocursor] + SL * 10 * Point) ){ // NO_NONSENSE_ATR_TP_LINE_BUY
                           ObjectCreate("NO_NONSENSE_ATR_SL_LINE_SELL", OBJ_TREND, 0, Time[barstocursor+1], Close[barstocursor] + SL * 10 * Point, Time[i], Close[barstocursor]+ SL *10 * Point);
                           ObjectSetInteger(0,"NO_NONSENSE_ATR_SL_LINE_SELL",OBJPROP_SELECTABLE,false);     
                           ObjectSet("NO_NONSENSE_ATR_SL_LINE_SELL", OBJPROP_RAY_RIGHT, 0);
                           break;
                        }
                     }
                     if(i<0){
                        ObjectCreate("NO_NONSENSE_ATR_SL_LINE_SELL", OBJ_TREND, 0, Time[barstocursor+1], Close[barstocursor] + SL * 10 * Point, Time[barstocursor], Close[barstocursor]+ SL *10 * Point);
                        ObjectSetInteger(0,"NO_NONSENSE_ATR_SL_LINE_SELL",OBJPROP_SELECTABLE,false);     
                        ObjectSet("NO_NONSENSE_ATR_SL_LINE_SELL", OBJPROP_RAY_RIGHT, 1);
                     }
                     for(x=barstocursor-1; x>=0; x--){   
                        if(Low[x] <= (Close[barstocursor] - SL * 10 * Point) ){ // NO_NONSENSE_ATR_TP_LINE_BUY
                           ObjectCreate("NO_NONSENSE_ATR_SL_LINE_BUY", OBJ_TREND, 0, Time[barstocursor+1], Close[barstocursor] - SL * 10 * Point, Time[x], Close[barstocursor]- SL *10 * Point);
                           ObjectSetInteger(0,"NO_NONSENSE_ATR_SL_LINE_BUY",OBJPROP_SELECTABLE,false);
                           ObjectSet("NO_NONSENSE_ATR_SL_LINE_BUY", OBJPROP_RAY_RIGHT, 0);
                           break;
                        }
                     }
                     if(x<0){
                        ObjectCreate("NO_NONSENSE_ATR_SL_LINE_BUY", OBJ_TREND, 0, Time[barstocursor+1], Close[barstocursor] - SL * 10 * Point, Time[barstocursor], Close[barstocursor]- SL *10 * Point);
                        ObjectSetInteger(0,"NO_NONSENSE_ATR_SL_LINE_BUY",OBJPROP_SELECTABLE,false);
                        ObjectSet("NO_NONSENSE_ATR_SL_LINE_BUY", OBJPROP_RAY_RIGHT, 1);
                     }
                     for(y=barstocursor-1; y>=0; y--){    
                        if(Low[y] <= (Close[barstocursor] - TP * 10 * Point) ){ // NO_NONSENSE_ATR_TP_LINE_BUY
                           ObjectCreate("NO_NONSENSE_ATR_TP_LINE_SELL", OBJ_TREND, 0, Time[barstocursor+1], Close[barstocursor] - TP * 10 * Point, Time[y], Close[barstocursor]- TP *10 * Point);
                           ObjectSetInteger(0,"NO_NONSENSE_ATR_TP_LINE_SELL",OBJPROP_SELECTABLE,false);
                           ObjectSet("NO_NONSENSE_ATR_TP_LINE_SELL", OBJPROP_RAY_RIGHT, 0);
                           break;
                        }
                     }
                     if(y<0){
                        ObjectCreate("NO_NONSENSE_ATR_TP_LINE_SELL", OBJ_TREND, 0, Time[barstocursor+1], Close[barstocursor] - TP * 10 * Point, Time[barstocursor], Close[barstocursor]- TP *10 * Point);
                        ObjectSetInteger(0,"NO_NONSENSE_ATR_TP_LINE_SELL",OBJPROP_SELECTABLE,false);
                        ObjectSet("NO_NONSENSE_ATR_TP_LINE_SELL", OBJPROP_RAY_RIGHT, 1);
                     }
                  }
                  
                  
                  ObjectSet("NO_NONSENSE_ATR_TP_LINE_BUY", OBJPROP_WIDTH, tp_line_size);
                  ObjectSet("NO_NONSENSE_ATR_TP_LINE_BUY", OBJPROP_COLOR, tp_line_color);
                  ObjectCreate("NO_NONSENSE_ATR_TP_TEXT_BUY", OBJ_TEXT, 0, Time[barstocursor], Close[barstocursor] + TP * 10 * Point);
                  ObjectSetInteger(0,"NO_NONSENSE_ATR_TP_TEXT_BUY",OBJPROP_SELECTABLE,false);
         
                  
                  ObjectSet("NO_NONSENSE_ATR_TP_LINE_SELL", OBJPROP_WIDTH, tp_line_size);
                  ObjectSet("NO_NONSENSE_ATR_TP_LINE_SELL", OBJPROP_COLOR, tp_line_color);
                  ObjectCreate("NO_NONSENSE_ATR_TP_TEXT_SELL", OBJ_TEXT, 0, Time[barstocursor], Close[barstocursor] - TP * 10 * Point);
                  ObjectSetInteger(0,"NO_NONSENSE_ATR_TP_TEXT_SELL",OBJPROP_SELECTABLE,false);
                  

                  ObjectSet("NO_NONSENSE_ATR_SL_LINE_BUY", OBJPROP_WIDTH, sl_line_size);
                  ObjectSet("NO_NONSENSE_ATR_SL_LINE_BUY", OBJPROP_COLOR, sl_line_color);
                  ObjectCreate("NO_NONSENSE_ATR_SL_TEXT_BUY", OBJ_TEXT, 0, Time[barstocursor], Close[barstocursor] - SL * 10 * Point);
                  ObjectSetInteger(0,"NO_NONSENSE_ATR_SL_TEXT_BUY",OBJPROP_SELECTABLE,false);
                  
                  
                  ObjectSet("NO_NONSENSE_ATR_SL_LINE_SELL", OBJPROP_WIDTH, sl_line_size);
                  ObjectSet("NO_NONSENSE_ATR_SL_LINE_SELL", OBJPROP_COLOR, sl_line_color);
                  ObjectCreate("NO_NONSENSE_ATR_SL_TEXT_SELL", OBJ_TEXT, 0, Time[barstocursor], Close[barstocursor] + SL * 10 * Point);
                  ObjectSetInteger(0,"NO_NONSENSE_ATR_SL_TEXT_SELL",OBJPROP_SELECTABLE,false);
                  
                  if (LINES_PRICE==True){
                     string text;
                     text=StringConcatenate("\n                   BUY TP - ", DoubleToString((Close[barstocursor] + TP * 10 * Point),Digits));  
                     ObjectSetText("NO_NONSENSE_ATR_TP_TEXT_BUY",text,10, "Verdana", tp_line_color);
                     text=StringConcatenate("\n                   SELL TP - ", DoubleToString((Close[barstocursor] - TP * 10 * Point),Digits));  
                     ObjectSetText("NO_NONSENSE_ATR_TP_TEXT_SELL",text,10, "Verdana", tp_line_color);
                     text=StringConcatenate("\n                   BUY SL - ", DoubleToString((Close[barstocursor] - SL * 10 * Point),Digits));  
                     ObjectSetText("NO_NONSENSE_ATR_SL_TEXT_BUY",text,10, "Verdana", sl_line_color);
                     text=StringConcatenate("\n                   SELL SL - ", DoubleToString((Close[barstocursor] + SL * 10 * Point),Digits));  
                     ObjectSetText("NO_NONSENSE_ATR_SL_TEXT_SELL",text,10, "Verdana", sl_line_color);
                  }else{
                     ObjectSetText("NO_NONSENSE_ATR_TP_TEXT_BUY","  BUY TP",10, "Verdana", tp_line_color);
                     ObjectSetText("NO_NONSENSE_ATR_TP_TEXT_SELL","   SELL TP",10, "Verdana", tp_line_color);
                     ObjectSetText("NO_NONSENSE_ATR_SL_TEXT_BUY","  BUY SL",10, "Verdana", sl_line_color);
                     ObjectSetText("NO_NONSENSE_ATR_SL_TEXT_SELL","   SELL SL",10, "Verdana", sl_line_color);
                  }
                  if(ENTRY_PRICE==true){
                     string text2=StringConcatenate(" ", Close[barstocursor]);  
                     ObjectSetText("NO_NONSENSE_ATR_ORDER_LINE_TEXT",text2,10, "Verdana", text_color);
                  }
                  
                  if (SHOW_SB_LINES==False){
                     if(user_mouseclick==1){ // esconder linhas de venda - MODO COMPRA
                        
                        lines_delete(0);
                        
                        ObjectSetText("NO_NONSENSE_ATR_FIXED"," -- FIXED -- BUY ",text_size, "Verdana", subtext_color);
                        if(LINES_UNTIL_PRICE==True){
                           if (a>x){ // WIN
                              ObjectSetText("NO_NONSENSE_ATR_FIXED"," -- FIXED -- BUY --> WIN ",text_size, "Verdana", subtext_color);
                           }else if (a<x){ // LOSS
                              ObjectSetText("NO_NONSENSE_ATR_FIXED"," -- FIXED -- BUY --> LOSS ",text_size, "Verdana", subtext_color);
                           } // nao modifica
                        }
                     }else if (user_mouseclick==2){ // esconder linhas de compra - MODO VENDA

                        lines_delete(1);
                        
                        ObjectSetText("NO_NONSENSE_ATR_FIXED"," -- FIXED -- SELL  ",text_size, "Verdana", subtext_color);
                        if(LINES_UNTIL_PRICE==True){
                           if (y>i){ // WIN
                              ObjectSetText("NO_NONSENSE_ATR_FIXED"," -- FIXED -- SELL --> WIN ",text_size, "Verdana", subtext_color);
                           }else if (y<i){ // LOSS
                              ObjectSetText("NO_NONSENSE_ATR_FIXED"," -- FIXED -- SELL --> LOSS ",text_size, "Verdana", subtext_color);
                           } // nao modifica
                        }
                     }
                 }
               }
                
            }
         
         }
         
         barstocursor_mouseclick=barstocursor; // gravar barra 

         
      }else{
         if(live_mode==0 || (live_mode==1 && show_live==1)){ // modo live activo e na zona
            live_mode=0;
            user_mouseclick=0;
            ObjectSetText("NO_NONSENSE_ATR_FIXED","",text_size, "Verdana", subtext_color);
            
            if(SHOW_LINES_ON_CLICK==True && CLICK_TO_PAUSE==True){   // -- apagar linhas
               ObjectDelete("NO_NONSENSE_ATR_ORDER_LINE");
               if(ENTRY_PRICE==true) ObjectDelete("NO_NONSENSE_ATR_ORDER_LINE_TEXT");
            
               lines_delete(0);
               lines_delete(1);
            }
         }
        
         
      }
   }
   
   
}
//+------------------------------------------------------------------+