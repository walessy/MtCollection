//+------------------------------------------------------------------+
//|                                CPComponent Currency Strength.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   2
//--- plot CA
#property indicator_label1  "CA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellowGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- plot CB
#property indicator_label2  "CB"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrCrimson
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3
#property indicator_level1  10
#property indicator_level2  20
#property indicator_level3  30
#property indicator_level4  40
#property indicator_level5  50
#property indicator_level6  60
#property indicator_level7  70
#property indicator_level8  80
#property indicator_level9  90
#property indicator_level10  100
#property indicator_level11  -10
#property indicator_level12  -20
#property indicator_level13  -30
#property indicator_level14  -40
#property indicator_level15  -50
#property indicator_level16  -60
#property indicator_level17  -70
#property indicator_level18  -80
#property indicator_level19  -90
#property indicator_level20  -100

input int CS_Period=120;                         //Currency Strength Period
input ENUM_MA_METHOD CS_Method=MODE_EMA;        //Currency Averaging Method
input int CS_Pairs_Limit=10;                    //Currency Strength Pairs Limit 
input int CS_AAll_Bars=10000;                   //Currency Strength All Pairs Bars (dont set below period)

enum cs_type
{
cs_type_both=0,                                 //Currencies
cs_type_diff=1                                  //Difference
};

input cs_type CS_Type=cs_type_both;             //Currency Strength Plot Method

enum cs_calc_type
{
cs_calc_type_simple=0,                          //Simple
cs_calc_type_deep=1                             //Deep
};

input cs_calc_type CS_CALC=cs_calc_type_deep;   //Currency Strength Calculation Type

//CURRENCY STRENGTH VARIABLES 
//--- indicator buffers
double         CABuffer[];
double         CBBuffer[];
double         CAMA[];
double         CBMA[];
double         CARaw[];
double         CBRaw[];
//symbols for currency a
int CS_CA_Total=0;
string CS_CA_Pairs[];
double CS_CA_Range[];
double CS_CA_Last[];
double CS_CA_Tik[];
int CS_CA_Alignment[];//1 , ca is base currency , -1 ca is quote currency
//symbols for currency b
int CS_CB_Total=0;
string CS_CB_Pairs[];
double CS_CB_Range[];
double CS_CB_Last[];
double CS_CB_Tik[];
int CS_CB_Alignment[];
int CS_ATR_Min_Bars=0;
double CS_CA_Tiks_Unit=0;
double CS_CB_Tiks_Unit=0;
int CS_All_Bars=0;

//CURRENCY STRENGTH VARIABLES END HERE 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,CABuffer);
   SetIndexBuffer(1,CBBuffer);
   SetIndexBuffer(2,CARaw);
   SetIndexBuffer(3,CBRaw);
   SetIndexBuffer(4,CAMA);
   SetIndexBuffer(5,CBMA);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexStyle(5,DRAW_NONE);
   //base currency
   string currency_a=SymbolInfoString(Symbol(),SYMBOL_CURRENCY_BASE);
   string currency_b=SymbolInfoString(Symbol(),SYMBOL_CURRENCY_PROFIT);
   if(CS_Type==cs_type_both)
   {
   SetIndexLabel(0,currency_a+" Strength");
   SetIndexLabel(1,currency_b+" Strength");
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"10%");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"20%");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,"30%");
   IndicatorSetString(INDICATOR_LEVELTEXT,3,"40%");
   IndicatorSetString(INDICATOR_LEVELTEXT,4,"50%");
   IndicatorSetString(INDICATOR_LEVELTEXT,5,"60%");
   IndicatorSetString(INDICATOR_LEVELTEXT,6,"70%");
   IndicatorSetString(INDICATOR_LEVELTEXT,7,"80%");
   IndicatorSetString(INDICATOR_LEVELTEXT,8,"90%");
   IndicatorSetString(INDICATOR_LEVELTEXT,9,"100%");
   IndicatorSetString(INDICATOR_LEVELTEXT,10,"-10%");
   IndicatorSetString(INDICATOR_LEVELTEXT,11,"-20%");
   IndicatorSetString(INDICATOR_LEVELTEXT,12,"-30%");
   IndicatorSetString(INDICATOR_LEVELTEXT,13,"-40%");
   IndicatorSetString(INDICATOR_LEVELTEXT,14,"-50%");
   IndicatorSetString(INDICATOR_LEVELTEXT,15,"-60%");
   IndicatorSetString(INDICATOR_LEVELTEXT,16,"-70%");
   IndicatorSetString(INDICATOR_LEVELTEXT,17,"-80%");
   IndicatorSetString(INDICATOR_LEVELTEXT,18,"-90%");
   IndicatorSetString(INDICATOR_LEVELTEXT,19,"-100%");   
   }
   if(CS_Type==cs_type_diff)
   {
   SetIndexLabel(0,Symbol()+" Strength");
   SetIndexLabel(1,Symbol()+" Strength");
   IndicatorSetString(INDICATOR_LEVELTEXT,0,currency_a+" 10%");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,currency_a+" 20%");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,currency_a+" 30%");
   IndicatorSetString(INDICATOR_LEVELTEXT,3,currency_a+" 40%");
   IndicatorSetString(INDICATOR_LEVELTEXT,4,currency_a+" 50%");
   IndicatorSetString(INDICATOR_LEVELTEXT,5,currency_a+" 60%");
   IndicatorSetString(INDICATOR_LEVELTEXT,6,currency_a+" 70%");
   IndicatorSetString(INDICATOR_LEVELTEXT,7,currency_a+" 80%");
   IndicatorSetString(INDICATOR_LEVELTEXT,8,currency_a+" 90%");
   IndicatorSetString(INDICATOR_LEVELTEXT,9,currency_a+" 100%");
   IndicatorSetString(INDICATOR_LEVELTEXT,10,currency_b+" 10%");
   IndicatorSetString(INDICATOR_LEVELTEXT,11,currency_b+" 20%");
   IndicatorSetString(INDICATOR_LEVELTEXT,12,currency_b+" 30%");
   IndicatorSetString(INDICATOR_LEVELTEXT,13,currency_b+" 40%");
   IndicatorSetString(INDICATOR_LEVELTEXT,14,currency_b+" 50%");
   IndicatorSetString(INDICATOR_LEVELTEXT,15,currency_b+" 60%");
   IndicatorSetString(INDICATOR_LEVELTEXT,16,currency_b+" 70%");
   IndicatorSetString(INDICATOR_LEVELTEXT,17,currency_b+" 80%");
   IndicatorSetString(INDICATOR_LEVELTEXT,18,currency_b+" 90%");
   IndicatorSetString(INDICATOR_LEVELTEXT,19,currency_b+" 100%");   
   }  
   
   //Scan all symbols in market watch and construct arrays for CS 
   string possible_pair;
   int possible_alignment;
   int total_symbols=SymbolsTotal(true);
   string sname;
   string s_base,s_quote;
   string seek_base,seek_quote;
   string found_base,found_quote,found_name;
   int ca_align,cb_align;
   //Loop
     for(int s=0;s<total_symbols;s++)
     {
     sname=SymbolName(s,true);
     s_base=SymbolInfoString(sname,SYMBOL_CURRENCY_BASE);
     s_quote=SymbolInfoString(sname,SYMBOL_CURRENCY_PROFIT);
     //if base!=quote
       if(s_base!=s_quote)
       {
       //if currency a exists in the symbol
         if(s_base==currency_a||s_quote==currency_a)
         {
         int combo_exist=-1;
         //if ca is the base 
           if(s_base==currency_a)
           {
           ca_align=1;
           seek_base=s_quote;
           seek_quote=currency_b;
           if(seek_base==seek_quote) seek_base=currency_a;
           //seek combo A of currency b this quote as base and cb as quote
             for(int sb=0;sb<total_symbols;sb++)
             {
             found_name=SymbolName(sb,true);
             found_base=SymbolInfoString(found_name,SYMBOL_CURRENCY_BASE);
             found_quote=SymbolInfoString(found_name,SYMBOL_CURRENCY_PROFIT);
             if(found_base==seek_base&&found_quote==seek_quote&&found_base!=found_quote)
               {
               combo_exist=sb;
               cb_align=-1;
               break;
               }
             }
           //seek combo A of currency b ends here 
           //seek combo B of currency b this quote as quote and cb as base
             if(combo_exist==-1)
             {
             seek_base=currency_b;
             seek_quote=s_quote;
             if(seek_base==seek_quote) seek_quote=currency_a;
             for(int sb=0;sb<total_symbols;sb++)
             {
             found_name=SymbolName(sb,true);
             found_base=SymbolInfoString(found_name,SYMBOL_CURRENCY_BASE);
             found_quote=SymbolInfoString(found_name,SYMBOL_CURRENCY_PROFIT);
             if(found_base==seek_base&&found_quote==seek_quote&&found_base!=found_quote)
               {
               combo_exist=sb;
               cb_align=1;
               break;
               }
             }
             }
           //seek combo B of currency b ends here 
           }
         //if ca is the base ends here 
         //if ca is the quote
           if(s_quote==currency_a)
           {
           ca_align=-1;
           seek_base=s_base;
           seek_quote=currency_b;
           if(seek_base==seek_quote) seek_base=currency_a;
           //seek combo A of currency b this base as base and cb as quote
             for(int sb=0;sb<total_symbols;sb++)
             {
             found_name=SymbolName(sb,true);
             found_base=SymbolInfoString(found_name,SYMBOL_CURRENCY_BASE);
             found_quote=SymbolInfoString(found_name,SYMBOL_CURRENCY_PROFIT);
             if(found_base==seek_base&&found_quote==seek_quote&&found_base!=found_quote)
               {
               combo_exist=sb;
               cb_align=-1;
               break;
               }
             }
           //seek combo A of currency b ends here 
           //seek combo B of currency b this base as quote and cb as base
             if(combo_exist==-1)
             {
             seek_base=currency_b;
             seek_quote=s_base;
             if(seek_base==seek_quote) seek_quote=currency_a;
             for(int sb=0;sb<total_symbols;sb++)
             {
             found_name=SymbolName(sb,true);
             found_base=SymbolInfoString(found_name,SYMBOL_CURRENCY_BASE);
             found_quote=SymbolInfoString(found_name,SYMBOL_CURRENCY_PROFIT);
             if(found_base==seek_base&&found_quote==seek_quote&&found_base!=found_quote)
               {
               combo_exist=sb;
               cb_align=1;
               break;
               }
             }
             }
           //seek combo B of currency b ends here 
           }
         //if ca is the quote ends here 
         //if combo exists 
           if(CS_CA_Total==CS_Pairs_Limit) break;
           if(combo_exist!=-1&&CS_CA_Total<CS_Pairs_Limit)
           {
           //add this pair to ca buffers  
             CS_CA_Total++;
             ArrayResize(CS_CA_Pairs,CS_CA_Total,0);
             ArrayResize(CS_CA_Alignment,CS_CA_Total,0);
             ArrayResize(CS_CA_Last,CS_CA_Total,0);
             ArrayResize(CS_CA_Range,CS_CA_Total,0);
             ArrayResize(CS_CA_Tik,CS_CA_Total,0);
             CS_CA_Pairs[CS_CA_Total-1]=sname;
             CS_CA_Alignment[CS_CA_Total-1]=ca_align;
           //add this pair to ca buffers ends here
           //add this pair to cb buffers
             CS_CB_Total++;
             ArrayResize(CS_CB_Pairs,CS_CB_Total,0);
             ArrayResize(CS_CB_Alignment,CS_CB_Total,0);
             ArrayResize(CS_CB_Last,CS_CB_Total,0);
             ArrayResize(CS_CB_Range,CS_CB_Total,0);
             ArrayResize(CS_CB_Tik,CS_CB_Total,0);
             CS_CB_Pairs[CS_CB_Total-1]=found_name;
             CS_CB_Alignment[CS_CB_Total-1]=cb_align;       
             //Alert(" A Pair : "+sname+" B Pair : "+found_name);    
           //add this pair to cb buffers ends here 
           }
         //if combo exists ends here 
         }
       //if currency a exists in the symbol ends here 
       }
     //if base!=quote ends here 
     }
   //Loop ends here 
   //Loop and find min available bars for all
     CS_ATR_Min_Bars=200;
     CS_All_Bars=CS_AAll_Bars;
     //loop in ca
     for(int ca=0;ca<CS_CA_Total;ca++)
     {
     int a_bars=iBars(CS_CA_Pairs[ca],Period());
     if(a_bars<CS_ATR_Min_Bars) CS_ATR_Min_Bars=a_bars;
     if(a_bars<CS_All_Bars) CS_All_Bars=a_bars;
     }
     //loop in cb
     for(int cb=0;cb<CS_CB_Total;cb++)
     {
     int b_bars=iBars(CS_CB_Pairs[cb],Period());
     if(b_bars<CS_ATR_Min_Bars) CS_ATR_Min_Bars=b_bars;
     if(b_bars<CS_All_Bars) CS_All_Bars=b_bars;
     }
   //Loop and find min available bars for all ends here 
   //Loop and get ranges
     //loop in ca
     double ttik;
     double aatr;
     for(int ca=0;ca<CS_CA_Total;ca++)
     {
     ttik=MarketInfo(CS_CA_Pairs[ca],MODE_POINT);
     CS_CA_Tik[ca]=ttik;
     aatr=iATR(CS_CA_Pairs[ca],Period(),CS_ATR_Min_Bars,0);
     aatr=aatr/ttik;
     CS_CA_Range[ca]=aatr;
     CS_CA_Last[ca]=iClose(CS_CA_Pairs[ca],Period(),1);
     }
     //loop in cb
     for(int cb=0;cb<CS_CB_Total;cb++)
     {
     ttik=MarketInfo(CS_CB_Pairs[cb],MODE_POINT);
     CS_CB_Tik[cb]=ttik;
     aatr=iATR(CS_CB_Pairs[cb],Period(),CS_ATR_Min_Bars,0);
     aatr=aatr/ttik;
     CS_CB_Range[cb]=aatr;
     CS_CB_Last[cb]=iClose(CS_CB_Pairs[cb],Period(),1);
     }     
   //Loop and get ranges ends here 
   //calculate CA Unit
     CS_CA_Tiks_Unit=0;
     for(int ca=0;ca<CS_CA_Total;ca++)
     {
     CS_CA_Tiks_Unit=CS_CA_Tiks_Unit+CS_CA_Range[ca];
     }
     if(CS_CA_Total>0) CS_CA_Tiks_Unit=CS_CA_Tiks_Unit/100;
     CS_CB_Tiks_Unit=0;
     for(int cb=0;cb<CS_CB_Total;cb++)
     {
     CS_CB_Tiks_Unit=CS_CB_Tiks_Unit+CS_CB_Range[cb];
     }
     if(CS_CB_Total>0) CS_CB_Tiks_Unit=CS_CB_Tiks_Unit/100;     
   //Scan all symbols in market watch and construct arrays for CS ends here 
   IndicatorShortName(currency_a+" + "+currency_b+" [Pairs:"+IntegerToString(CS_CA_Total)+"] [Bars:"+IntegerToString(CS_All_Bars)+"]");
//---
   return(INIT_SUCCEEDED);
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
//---
//CURRENCY STRENGTH CALCULATION AND PLOTS 
//--- prevent total recalculation
   int i=rates_total-prev_calculated-1;
   int safe_to_check=Bars-1;
//--- current value should be recalculated
   if(i<0)
      i=0;
//---
   while(i>=0)
     {
     double cA_sum,cB_sum,cA_last,cB_last,cA_now,cB_now;
     cA_sum=0;
     cB_sum=0;
     double difff;     
     //check for min bars on all pairs , live load
     if(i<CS_All_Bars&&i==0)
     {
     //loop 
       for(int x=0;x<CS_CA_Total;x++)
        {
        //get last of A 
        cA_last=iClose(CS_CA_Pairs[x],Period(),i+1);
        cA_now=iClose(CS_CA_Pairs[x],Period(),i);
        //get last of B
        cB_last=iClose(CS_CB_Pairs[x],Period(),i+1);
        cB_now=iClose(CS_CB_Pairs[x],Period(),i);
        //a difference
        difff=cA_now-cA_last;
        difff=difff/CS_CA_Tik[x];
        difff=difff*CS_CA_Alignment[x];
        cA_sum=cA_sum+difff;
        //b difference
        difff=cB_now-cB_last;
        difff=difff/CS_CB_Tik[x];
        difff=difff*CS_CB_Alignment[x];
        cB_sum=cB_sum+difff;
        }
     //loop ends here 
     if(CS_CA_Total>0)
     {
     //if calculation is deep recalc units 
       if(CS_CALC==cs_calc_type_deep)
       {
       //loop in ca
        double ttik;
        double aatr;
        for(int ca=0;ca<CS_CA_Total;ca++)
        {
        aatr=iATR(CS_CA_Pairs[ca],Period(),CS_ATR_Min_Bars,i);
        aatr=aatr/CS_CA_Tik[ca];
        CS_CA_Range[ca]=aatr;
        }
        //loop in cb
        for(int cb=0;cb<CS_CB_Total;cb++)
        {
        aatr=iATR(CS_CB_Pairs[cb],Period(),CS_ATR_Min_Bars,i);
        aatr=aatr/CS_CB_Tik[cb];
        CS_CB_Range[cb]=aatr;
        }     
        //Loop and get ranges ends here 
        //calculate CA Unit
        CS_CA_Tiks_Unit=0;
        for(int ca=0;ca<CS_CA_Total;ca++)
        {
        CS_CA_Tiks_Unit=CS_CA_Tiks_Unit+CS_CA_Range[ca];
        }
        if(CS_CA_Total>0) CS_CA_Tiks_Unit=CS_CA_Tiks_Unit/100;
        CS_CB_Tiks_Unit=0;
        for(int cb=0;cb<CS_CB_Total;cb++)
        {
        CS_CB_Tiks_Unit=CS_CB_Tiks_Unit+CS_CB_Range[cb];
        }
        if(CS_CB_Total>0) CS_CB_Tiks_Unit=CS_CB_Tiks_Unit/100;           
       }
     //if calculation is deep recalc units ends here 
     cA_sum=cA_sum/CS_CA_Tiks_Unit;
     cB_sum=cB_sum/CS_CB_Tiks_Unit;
     CARaw[i]=cA_sum;
     CBRaw[i]=cB_sum;
     //if period valid plot ma's
     if((CS_All_Bars-i)>CS_Period)
       {
       CAMA[i]=iMAOnArray(CARaw,0,CS_Period,0,CS_Method,i);
       CBMA[i]=iMAOnArray(CBRaw,0,CS_Period,0,CS_Method,i);
       if(CS_Type==cs_type_both)
       {
       CABuffer[i]=CAMA[i];
       CBBuffer[i]=CBMA[i];
       }
       if(CS_Type==cs_type_diff)
       {
       CABuffer[i]=CAMA[i]-CBMA[i];
       CBBuffer[i]=CAMA[i]-CBMA[i];
       }
       }
     //if period valid plot ma's ends here 
     }     
     }
     //check for min bars on all pairs , live load ends here 
     //check for min bars on all pairs , initial load 
     if(i<CS_All_Bars&&i>0)
     {
     //loop 
       for(int x=0;x<CS_CA_Total;x++)
        {
        //get last of A 
        cA_last=iClose(CS_CA_Pairs[x],Period(),i+1);
        cA_now=iClose(CS_CA_Pairs[x],Period(),i);
        //get last of B
        cB_last=iClose(CS_CB_Pairs[x],Period(),i+1);
        cB_now=iClose(CS_CB_Pairs[x],Period(),i);
        //a difference
        difff=cA_now-cA_last;
        difff=difff/CS_CA_Tik[x];
        difff=difff*CS_CA_Alignment[x];
        cA_sum=cA_sum+difff;
        //b difference
        difff=cB_now-cB_last;
        difff=difff/CS_CB_Tik[x];
        difff=difff*CS_CB_Alignment[x];
        cB_sum=cB_sum+difff;
        }
     //loop ends here 
     if(CS_CA_Total>0)
     {
     //if calculation is deep recalc units 
       if(CS_CALC==cs_calc_type_deep)
       {
       //loop in ca
        double ttik;
        double aatr;
        for(int ca=0;ca<CS_CA_Total;ca++)
        {
        aatr=iATR(CS_CA_Pairs[ca],Period(),CS_ATR_Min_Bars,i);
        aatr=aatr/CS_CA_Tik[ca];
        CS_CA_Range[ca]=aatr;
        }
        //loop in cb
        for(int cb=0;cb<CS_CB_Total;cb++)
        {
        aatr=iATR(CS_CB_Pairs[cb],Period(),CS_ATR_Min_Bars,i);
        aatr=aatr/CS_CB_Tik[cb];
        CS_CB_Range[cb]=aatr;
        }     
        //Loop and get ranges ends here 
        //calculate CA Unit
        CS_CA_Tiks_Unit=0;
        for(int ca=0;ca<CS_CA_Total;ca++)
        {
        CS_CA_Tiks_Unit=CS_CA_Tiks_Unit+CS_CA_Range[ca];
        }
        if(CS_CA_Total>0) CS_CA_Tiks_Unit=CS_CA_Tiks_Unit/100;
        CS_CB_Tiks_Unit=0;
        for(int cb=0;cb<CS_CB_Total;cb++)
        {
        CS_CB_Tiks_Unit=CS_CB_Tiks_Unit+CS_CB_Range[cb];
        }
        if(CS_CB_Total>0) CS_CB_Tiks_Unit=CS_CB_Tiks_Unit/100;           
       }
     //if calculation is deep recalc units ends here 
     cA_sum=cA_sum/CS_CA_Tiks_Unit;
     cB_sum=cB_sum/CS_CB_Tiks_Unit;
     CARaw[i]=cA_sum;
     CBRaw[i]=cB_sum;
     //if period valid plot ma's
     if((CS_All_Bars-i)>CS_Period)
       {
       CAMA[i]=iMAOnArray(CARaw,0,CS_Period,0,CS_Method,i);
       CBMA[i]=iMAOnArray(CBRaw,0,CS_Period,0,CS_Method,i);
       if(CS_Type==cs_type_both)
       {
       CABuffer[i]=CAMA[i];
       CBBuffer[i]=CBMA[i];
       }
       if(CS_Type==cs_type_diff)
       {
       CABuffer[i]=CAMA[i]-CBMA[i];
       CBBuffer[i]=CAMA[i]-CBMA[i];
       }
       }
     //if period valid plot ma's ends here 
     }

     }
     //check for min bars on all pairs , initial load ends here 
     i--;
     }
//CURRENCY STRENGTH CALCULATION AND PLOTS ENDS HERE    
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+

