//+------------------------------------------------------------------+
//|                                   Currency Strength - Giraia.mq4 |
//+------------------------------------------------------------------+
//
// Indicator modified in 06/June/2015 to make it compatible with 
// build 600+. Credits to the original creator.
//
// This version doesn't use all 28 pairs to be compatible with the
// most used version which uses only 25. To have all 28 pairs, just 
// add NC,CF,NF in the Currency pairs. Results will be slightly 
// different.

//  Currency_Strength_Giraia_25_pairs_TRO_MODIFIED
//--------------------------------------------------------------------


#property indicator_chart_window

extern bool TURN_OFF    = false ;    // TRO
extern bool SHOW_CURRENCIES    = true ;    // TRO
extern bool SHOW_CHART_PAIR    = false ;    // TRO  
extern bool SHOW_COMMENT       = false ;    // TRO 
extern bool SHOW_DATA          = true ;    // TRO  

extern string myCorner = 2 ;         // TRO

extern string   missingPairs        = "To have 28 pairs, these must be added: ";
extern string   CurrencyPairs       = "GU,UF,EU,UJ,UC,NU,AU,AN,AC,AF,AJ,CJ,FJ,EG,EA,EF,EJ,EN,EC,GF,GA,GC,GJ,GN,NJ,NC,CF,NF";         
input string    symbols="AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDCAD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY"; //Symbols To Scan
extern string   FontName            = "Calibri";   //Courier New";
extern int      FontSize            = 8;
//extern string   OutputFormat        = "R3.1";
extern int      HorizPos            = 10;
extern int      VertPos             = 10;
extern int      VertSpacing         = 20;
extern int      RefreshEveryXMins   = 0;
extern color    Color1              = clrGreenYellow;
extern double   Level1              = 6.0;
extern color    Color2              = clrAqua;
extern double   Level2              = 5.0;
extern color    Color3              = clrRed;
extern double   Level3              = 2.9;
extern color    Color4              = Red;
extern double   Level4              = 0.0;
extern bool     ShowNoOfPairs       = false;
extern bool     SortDescending      = false;
extern int      checkSeconds        = 1;

double    spr, pnt, tickval, ccy_strength[8];
int       dig, tf, ccy_count[8], ccCP;
string    IndiName, ccy, CP[99], ccy_name[8];
datetime  prev_time;

   string BaseCur, QuoteCur, tMessage;   
   double BaseVal, QuoteVal, PairVal;

input string symbolPrefix=""; //Symbol Prefix
input string symbolSuffix=""; //Symbol Suffix   
string symbolListFinal[]; // array of symbols after merging post and prefix
string symbolList[]; // array of symbols  
int numSymbols=0; //the number of symbols to scan 

int Jolly[28];
int    alertmail[28][6][2];
double priceLow[28]; 
double priceHigh[28];
string array_to_sort[8];  
string Symb_text;
double Symb_value;

input double flashover              = 0.7;                // Livello Alert Pivot 
input ENUM_TIMEFRAMES timeframe     = PERIOD_M15;         // Timeframe Fibonacci corto
input int lookback                  = 144;                // Numero di candele Fibonacci corto 
input int lastbar                   = 0;                  // Partenza Fibonacci corto
 
datetime previousTime[28]; 

int tipo;    

input ENUM_TIMEFRAMES TimeFrame=PERIOD_D1;//Period for calculating
input ENUM_TIMEFRAMES Per   = PERIOD_M15; //Period for new opened charts
input color   UPcolor = clrLimeGreen;     //Color when moved up
input color   DownColor = clrRed;      //Color when moved down
//---
int    Size=10; //Font size
string Font= "Arial Black";
int    BGcolor;  //Bars background color
int    cF = 100; //Coefficient of scale
int    Zero,Wbar,Hbar,Xsize,Ysize;
string PairsArray[28];  //Array for Pairs Name
double ChangeArray[28]; //Array for Pairs Change    

string subfolder="";
string namafile="";
string date_="";
string time_="";          
int    handlefile=0;
bool   writefile=false;

   
//+------------------------------------------------------------------+
int init()   {
//+------------------------------------------------------------------+

  
    SetText("Titolo","Symbol",HorizPos,VertPos,clrGray); 
    SetText("Titolo8","Alert",HorizPos+45,VertPos,clrGray);     
    SetText("Titolo1","Curr.",HorizPos+75,VertPos,clrGray);               
    SetText("Titolo2","RG",HorizPos+110,VertPos,clrGray); 
    SetText("Titolo3","Fibo %",HorizPos+135,VertPos,clrGray);     
    SetText("Titolo4","Price",HorizPos+180,VertPos,clrGray);
    
  if (RefreshEveryXMins > 240)                             RefreshEveryXMins = 240;
  if (RefreshEveryXMins > 60 && RefreshEveryXMins < 240)   RefreshEveryXMins = 60;
  if (RefreshEveryXMins > 30 && RefreshEveryXMins < 60)    RefreshEveryXMins = 30;
  if (RefreshEveryXMins > 15 && RefreshEveryXMins < 30)    RefreshEveryXMins = 15;
  if (RefreshEveryXMins > 5  && RefreshEveryXMins < 15)    RefreshEveryXMins = 5;
  if (RefreshEveryXMins > 1  && RefreshEveryXMins < 5)     RefreshEveryXMins = 1;


  CurrencyPairs  = StringUpper(CurrencyPairs);
  if (CurrencyPairs == "")  CurrencyPairs = Symbol();
  if (StringSubstr(CurrencyPairs,StringLen(CurrencyPairs)-1,1) != ",")  CurrencyPairs = CurrencyPairs + ",";
  ccCP = StringFindCount(CurrencyPairs,",");
  
  for (int i=0; i<99; i++)
    CP[i] = "";
    
  int comma1 = -1;
 
  for (i=0; i<99; i++)  {
    int comma2 = StringFind(CurrencyPairs,",",comma1+1);
    string temp  = StringSubstr(CurrencyPairs,comma1+1,comma2-comma1-1);
    CP[i] = ExpandCcy(temp);
    if (comma2 >= StringLen(CurrencyPairs)-1)   break;
    comma1 = comma2;
  }  

  int checksum = 0;
  string str = "0";
  for (i=0; i<StringLen(str); i++)  
    checksum += i * StringGetChar(str,i);
  IndiName = "CurrencyStrength-" + checksum;
  IndicatorShortName(IndiName);

  ccy     = Symbol();
  tf      = Period();
  pnt     = MarketInfo(ccy,MODE_POINT);
  dig     = MarketInfo(ccy,MODE_DIGITS);
  spr     = MarketInfo(ccy,MODE_SPREAD);
  tickval = MarketInfo(ccy,MODE_TICKVALUE);
  if (dig == 3 || dig == 5) {
    pnt     *= 10;
    spr     /= 10;
    tickval *= 10;
  }

  ccy_name[0] = "USD";
  ccy_name[1] = "EUR";
  ccy_name[2] = "GBP";
  ccy_name[3] = "CHF";
  ccy_name[4] = "CAD";
  ccy_name[5] = "AUD";
  ccy_name[6] = "JPY";
  ccy_name[7] = "NZD";

  del_obj();
  plot_obj();    
  prev_time = -9999;
  
  
// extract base and quote from symbol

   BaseCur    = StringSubstr(Symbol(),0,3);
   QuoteCur    = StringSubstr(Symbol(),3,3);  

   getSymbols();
   
   EventSetTimer(checkSeconds);   
    
  return(0);
}


//+------------------------------------------------------------------+
int deinit()  {
//+------------------------------------------------------------------+
  del_obj();
  Comment("") ;
  return(0);
}


//+------------------------------------------------------------------+
int start()  {
//+------------------------------------------------------------------+
 
 //ArrayInitialize(priceHigh,0);
 //ArrayInitialize(priceLow,0);
    
 if( TURN_OFF ) { deinit(); return(0) ; }
 
  if (RefreshEveryXMins == 0) {
    del_obj();
    plot_obj();    
  }
  else {
    if(prev_time != iTime(ccy,RefreshEveryXMins,0))  {
      del_obj();
      plot_obj();
      prev_time = iTime(ccy,RefreshEveryXMins,0);
  } }         
                          
     for(int i=0;i<28;i++)
     {             
        
        WriteSuperMinMax(symbolListFinal[i],i);
        
        BaseCur    = StringSubstr(symbolListFinal[i],0,3);
        QuoteCur   = StringSubstr(symbolListFinal[i],3,3);                       

      for(int j=0;j<8;j++)
       {         
         Symb_text = StringSubstr(ObjectDescription("CurrencyStrength-0-"+IntegerToString(j)),0,3);                // extract the symbol
         Symb_value= StrToDouble(StringSubstr(ObjectDescription("CurrencyStrength-0-"+IntegerToString(j)),7,3));   // extract the value
          
        if(BaseCur==Symb_text){                
         if       (Symb_value < Level3) { 
         alertmail[i][3][1]=1;
         if(SHOW_DATA)SetText("Symb*"+IntegerToString(i),DoubleToStr(Symb_value,1) ,HorizPos+70,(i*16)+VertPos+15,Color3);         
         }
         else if  (Symb_value > Level1) { 
         alertmail[i][3][0]=1;
         if(SHOW_DATA)SetText("Symb*"+IntegerToString(i),DoubleToStr(Symb_value,1) ,HorizPos+70,(i*16)+VertPos+15,Color1);
         }
         else{                            
         alertmail[i][3][0]=0; alertmail[i][3][1]=0;        
         if(SHOW_DATA)SetText("Symb*"+IntegerToString(i),DoubleToStr(Symb_value,1) ,HorizPos+70,(i*16)+VertPos+15,Color2);
         }         
        }
        
        if(QuoteCur==Symb_text){
         if       (Symb_value < Level3) { 
         alertmail[i][2][1]=1;
         if(SHOW_DATA)SetText("Symb:"+IntegerToString(i),DoubleToStr(Symb_value,1) ,HorizPos+90,(i*16)+VertPos+15,Color3);         
         }
         else if  (Symb_value > Level1) { 
         alertmail[i][2][0]=1;
         if(SHOW_DATA)SetText("Symb:"+IntegerToString(i),DoubleToStr(Symb_value,1) ,HorizPos+90,(i*16)+VertPos+15,Color1);         
         }
         else{                           
         alertmail[i][2][1]=0; alertmail[i][2][0]=0;
         if(SHOW_DATA)SetText("Symb:"+IntegerToString(i),DoubleToStr(Symb_value,1) ,HorizPos+90,(i*16)+VertPos+15,Color2);         
         }        
        }
       
       }        
       
         SetText("Symb_"+IntegerToString(i),symbolListFinal[i],HorizPos,(i*16)+VertPos+15,clrAqua);           
 
         if(ObjectDescription("Symb*"+IntegerToString(i))>ObjectDescription("Symb:"+IntegerToString(i)))
          {        
           //SetObjText("Symb°"+IntegerToString(i),CharToStr(233),HorizPos+240,(i*16)+VertPos+15,UPcolor,8);}else{
           //SetObjText("Symb°"+IntegerToString(i),CharToStr(234),HorizPos+240,(i*16)+VertPos+15,DownColor,8);
          }
                    
         int passo = 4;
         
         switch(i)//initalize seleted pivot point forumula
           {
            case 2 : passo=3;     break;
            case 6 : passo=3;     break;            
            case 7 : passo=2;     break;
            case 12 : passo=2;    break;            
            case 18 : passo=2;    break;   
            case 23 : passo=3;    break; 
            case 27 : passo=2;    break;                                                
           }
           
            if(SHOW_DATA)SetText("Price"+IntegerToString(i),DoubleToStr(iClose(symbolListFinal[i],0,0),passo),HorizPos+180,(i*16)+VertPos+15,clrAqua);  

            color MyColor = Aqua; 
            if(GlobalVariableGet(symbolListFinal[i])<flashover*-1 ) MyColor = clrRed;
            if(GlobalVariableGet(symbolListFinal[i])>flashover)     MyColor = clrGreenYellow;  
                
            //SetText("pivot"+IntegerToString(i),DoubleToStr(GlobalVariableGet(symbolListFinal[i]),2) ,HorizPos+150,(i*16)+VertPos+15,MyColor);            
            
            
            MyColor = Aqua; 
            
            if(priceLow[i]<0){      
                                    alertmail[i][0][0]=1;
                                    MyColor = Red; 
                                    if(SHOW_DATA)SetText("priceL"+IntegerToString(i),DoubleToStr(priceLow[i],2) ,HorizPos+125,(i*16)+VertPos+15,MyColor);
                                    }
            else if(priceLow[i]>1){ 
                                    alertmail[i][0][1]=1;
                                    MyColor = Gold; 
                                    if(SHOW_DATA)SetText("priceL"+IntegerToString(i),DoubleToStr(priceLow[i],2) ,HorizPos+125,(i*16)+VertPos+15,MyColor);
                                    } 
            else                  { 
                                    alertmail[i][0][0]=0; alertmail[i][0][1]=0;
                                    if(SHOW_DATA)SetText("priceL"+IntegerToString(i),DoubleToStr(priceLow[i],2),HorizPos+125,(i*16)+VertPos+15,MyColor);             
                                    }                                                
            
            MyColor = Aqua; 
            
            if(priceHigh[i]<0){
                                     alertmail[i][1][0]=1;
                                     MyColor = Red; 
                                     if(SHOW_DATA)SetText("priceH"+IntegerToString(i),DoubleToStr(priceHigh[i],2) ,HorizPos+153,(i*16)+VertPos+15,MyColor);
                                     }
            else if(priceHigh[i]>1){
                                     alertmail[i][1][1]=1;
                                     MyColor = Gold; 
                                     if(SHOW_DATA)SetText("priceH"+IntegerToString(i),DoubleToStr(priceHigh[i],2) ,HorizPos+153,(i*16)+VertPos+15,MyColor);
                                     } 
            else                   {
                                     alertmail[i][1][0]=0; alertmail[i][1][1]=0;
                                     if(SHOW_DATA)SetText("priceH"+IntegerToString(i),DoubleToStr(priceHigh[i],2) ,HorizPos+153,(i*16)+VertPos+15,MyColor);             
                                     }  
/*                          
           if(ObjectDescription("priceL"+IntegerToString(i))>ObjectDescription("priceH"+IntegerToString(i)))
            {
                     if(SHOW_DATA)SetObjText("Symb|"+IntegerToString(i),CharToStr(230),HorizPos+220,(i*16)+VertPos+15,DownColor,8);               
            }else{
                     if(SHOW_DATA)SetObjText("Symb|"+IntegerToString(i),CharToStr(228),HorizPos+220,(i*16)+VertPos+15,UPcolor,8); 
            }           
*/
            if(GlobalVariableGet(symbolListFinal[i]+"LR")== DownColor ) {MyColor = DownColor; tipo = 234; alertmail[i][4][0]=1;}else{alertmail[i][4][0]=0;}
            if(GlobalVariableGet(symbolListFinal[i]+"LR")== UPcolor)    {MyColor = UPcolor; tipo = 233; alertmail[i][4][1]=1;}else{alertmail[i][4][1]=0;} 
            
            if(SHOW_DATA)SetObjText("ColSymb"+IntegerToString(i),CharToStr(tipo),HorizPos+110,(i*16)+VertPos+15,MyColor,8);
                        
            MyColor = clrBlack;                                                     
           
            if(alertmail[i][4][0] + alertmail[i][1][0]==2) {Jolly[i]= 1;}else{Jolly[i]= 0;} // Regression - Fibo H             
            if(alertmail[i][4][1] + alertmail[i][0][0]==2) {Jolly[i]= 1;}else{Jolly[i]= 0;} // Regression - Fibo L 
                                                           
            int punteggio = alertmail[i][0][0]+alertmail[i][0][1]+      // Fibo L
                            alertmail[i][1][0]+alertmail[i][1][1]+      // Fibo H
                            alertmail[i][2][0]+alertmail[i][2][1]+      // Currency Quote Cur
                            alertmail[i][3][0]+alertmail[i][3][1]+      // Currency Base
                            Jolly[i];                                   // Regression bar
                                                                                                                                   
            if(punteggio >= 2){ 
                                 switch(punteggio)
                                 {
                                  case 2: MyColor = clrGray;break;
                                  case 3: MyColor = clrTomato;break;
                                  case 4: MyColor = clrGold;break;
                                  case 5: MyColor = clrGreenYellow;break;
                                 }               
                                             
            SetObjText("Sign"+IntegerToString(i),CharToStr(punteggio+139),HorizPos+50,(i*16)+VertPos+15,MyColor,10); 
           
            if(punteggio>=4) doAlert(symbolListFinal[i],i,punteggio);          
            }else{
            SetObjText("Sign"+IntegerToString(i),CharToStr(36),HorizPos+50,(i*16)+VertPos+15,MyColor,10); 
            previousTime[i]  = Time[0];                      
            } 
                                                                                    
     }  
     
            Roc();     
       
       RefreshRates();
       
  return(0);
}



//+------------------------------------------------------------------+
void plot_obj()   {
//+------------------------------------------------------------------+

  ArrayInitialize(ccy_strength,0.0);
  ArrayInitialize(ccy_count,0);

  for (int i=0; i<ccCP; i++)   {
    double day_high     = MarketInfo(CP[i],MODE_HIGH);
    double day_low      = MarketInfo(CP[i],MODE_LOW);
    double curr_bid     = MarketInfo(CP[i],MODE_BID);
    double bid_ratio    = DivZero(curr_bid - day_low, day_high - day_low);

    double ind_strength = 0;
    if (bid_ratio >= 0.97)   ind_strength = 9;    else
    if (bid_ratio >= 0.90)   ind_strength = 8;    else
    if (bid_ratio >= 0.75)   ind_strength = 7;    else
    if (bid_ratio >= 0.60)   ind_strength = 6;    else
    if (bid_ratio >= 0.50)   ind_strength = 5;    else
    if (bid_ratio >= 0.40)   ind_strength = 4;    else
    if (bid_ratio >= 0.25)   ind_strength = 3;    else
    if (bid_ratio >= 0.10)   ind_strength = 2;    else
    if (bid_ratio >= 0.03)   ind_strength = 1;

    string temp = StringSubstr(CP[i],0,3);
    for (int j=0; j<8; j++)   {
      if (ccy_name[j] == temp)  {
        ccy_strength[j] += ind_strength;
        ccy_count[j]    += 1;
        break;
    } }    

    temp = StringSubstr(CP[i],3,3);
    for (j=0; j<8; j++)   {
      if (ccy_name[j] == temp)  {
        ccy_strength[j] += 9 - ind_strength;
        ccy_count[j]    += 1;
        break;
  } } }    

  // This routine loads the strength values and currency symbols into an array, and sorts the array......
  //string array_to_sort[8];
  
  for (j=0; j<8; j++)  
  {
       array_to_sort[j] = "";
       if (ccy_count[j] < 1)   continue;
       double out_value = DivZero(ccy_strength[j],ccy_count[j]);        // calculate the strength value = total strength / number of pairs that were summed        
      
      if( ccy_name[j] == BaseCur )
      {
         BaseVal = out_value ;  int basej = j ;
      }
      
      if( ccy_name[j] == QuoteCur )
      {
         QuoteVal = out_value ; int quotej = j ;
      } 
         
       string tstr1     = DoubleToStr(out_value, 1) + ccy_name[j];      // build a string (tstr1) with the formatted number value, followed by the currency name
       int    length    = StringLen(DoubleToStr(out_value,1));          // length of the formatted number value
       if (ShowNoOfPairs)  
         tstr1 = tstr1 + DoubleToStr(ccy_count[j],0);                   // append the currency count to the string
         array_to_sort[j] = tstr1;                                      // load the string into an array to be sorted
     
  }
   
  ShellsortStringArray(array_to_sort,SortDescending);   
                                                                             //   string, it has priority, but everything in the string gets sorted
  int xp = HorizPos;
  int yp = VertPos;
  for (j=0; j<8; j++)  
  {
    if (ccy_count[j] < 1)   continue;
    
      color FontColor = White;
      string objname = IndiName + "-" + j;
    
    out_value = StrToDouble(StringSubstr(array_to_sort[j],0,length));                      // extract the value from the string
    //Print(array_to_sort[j], " ", out_value, " ", length);
    tstr1 = StringSubstr(array_to_sort[j],length,3) + "    " + DoubleToStr(out_value,1);   // build a new string to be output, from the sorted array, with the currency sybol first
    if (ShowNoOfPairs)  
      tstr1 = tstr1 + " (" + StringSubstr(array_to_sort[j],length+3) + ")";                // extract and append the currency count to the string
//    string objname = IndiName + "-" + j;
 
 
   if(SHOW_CURRENCIES)
   {  
       ObjectCreate(objname,OBJ_LABEL,0,0,0);
       ObjectSet(objname, OBJPROP_CORNER, myCorner ); // TRO
       ObjectSet(objname,OBJPROP_XDISTANCE,xp);
       ObjectSet(objname,OBJPROP_YDISTANCE,yp);
   //    color FontColor = White;
       if (out_value >  Level1)   FontColor = Color1;    else
       if (out_value >  Level2)   FontColor = Color2;    else
       if (out_value >  Level3)   FontColor = Color3;    else
       if (out_value >= Level4)   FontColor = Color4;
       tstr1=StringRightPad(tstr1,16," ");
       ObjectSetText(objname,tstr1,FontSize,FontName,FontColor);
       yp += VertSpacing;
   } // if
 
  } // for



      PairVal  =  BaseVal - QuoteVal ;
      
      if( PairVal >= 0.0 )   { tMessage = "BUY  " ; FontColor = Lime; } 
                        else { tMessage = "SELL " ; FontColor = Magenta;} 

   if(SHOW_COMMENT)
   {   
   
      Comment( BaseCur  + " " + DoubleToStr(BaseVal,Digits)  , "\n" , 
               QuoteCur + " " + DoubleToStr(QuoteVal,Digits) , "\n" , 
               Symbol() + " " + DoubleToStr(PairVal,Digits) + " " +  tMessage   , "\n" ,  
               "") ;
   }            
               
   if(SHOW_CHART_PAIR)
   {                   
       tstr1 = Symbol() + " " + DoubleToStr(PairVal,1) + " " +  tMessage ;
       objname = IndiName + "-" + j;
       ObjectCreate(objname,OBJ_LABEL,0,0,0);
       ObjectSet(objname, OBJPROP_CORNER, myCorner ); // TRO
       ObjectSet(objname,OBJPROP_XDISTANCE,xp);
       ObjectSet(objname,OBJPROP_YDISTANCE,yp);
        
       ObjectSetText(objname,tstr1,FontSize,FontName,FontColor);
       yp += VertSpacing;
       
       
    }//if  

          
  //return(0);
}



//+------------------------------------------------------------------+
//| del_obj                                                          |
//+------------------------------------------------------------------+
void del_obj()
{
  int k=0;
  while (k<ObjectsTotal())   {
    string objname = ObjectName(k);
    if (StringSubstr(objname,0,StringLen(IndiName)) == IndiName)  
      ObjectDelete(objname);
    else
      k++;
  }    
  //return(0);
}



//===========================================================================
//                            FUNCTIONS LIBRARY
//===========================================================================


//+------------------------------------------------------------------+
string StringLeft(string str, int n=1)
//+------------------------------------------------------------------+
// Returns the leftmost N characters of STR, if N is positive
// Usage:    string x=StringLeft("ABCDEFG",2)  returns x = "AB"
//
// Returns all but the rightmost N characters of STR, if N is negative
// Usage:    string x=StringLeft("ABCDEFG",-2)  returns x = "ABCDE"
{
  if (n > 0)  return(StringSubstr(str,0,n));
  if (n < 0)  return(StringSubstr(str,0,StringLen(str)+n));
  return("");
}


//+------------------------------------------------------------------+
string StringRight(string str, int n=1)
//+------------------------------------------------------------------+
// Returns the rightmost N characters of STR, if N is positive
// Usage:    string x=StringRight("ABCDEFG",2)  returns x = "FG"
//
// Returns all but the leftmost N characters of STR, if N is negative
// Usage:    string x=StringRight("ABCDEFG",-2)  returns x = "CDEFG"
{
  if (n > 0)  return(StringSubstr(str,StringLen(str)-n,n));
  if (n < 0)  return(StringSubstr(str,-n,StringLen(str)-n));
  return("");
}


//+------------------------------------------------------------------+
string StringRightPad(string str, int n=1, string str2=" ")
//+------------------------------------------------------------------+
// Appends occurrences of the string STR2 to the string STR to make a string N characters long
// Usage:    string x=StringRightPad("ABCDEFG",9," ")  returns x = "ABCDEFG  "
{
  return(str + StringRepeat(str2,n-StringLen(str)));
}


//+------------------------------------------------------------------+
int StringFindCount(string str, string str2)
//+------------------------------------------------------------------+
// Returns the number of occurrences of STR2 in STR
// Usage:   int x = StringFindCount("ABCDEFGHIJKABACABB","AB")   returns x = 3
{
  int c = 0;
  for (int i=0; i<StringLen(str); i++)
    if (StringSubstr(str,i,StringLen(str2)) == str2)  c++;
  return(c);
}


//+------------------------------------------------------------------+
string StringTrim(string str)
//+------------------------------------------------------------------+
// Removes all spaces (leading, traing embedded) from a string
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "TheQuickBrownFox"
{
  string outstr = "";
  for(int i=0; i<StringLen(str); i++)  {
    if (StringSubstr(str,i,1) != " ")
      outstr = outstr + StringSubstr(str,i,1);
  }
  return(outstr);
}


//+------------------------------------------------------------------+
string StringLeftTrim(string str)
//+------------------------------------------------------------------+
// Removes all leading spaces from a string
// Usage:    string x=StringLeftTrim("  XX YY  ")  returns x = "XX  YY  "
{
  bool   left = true;
  string outstr = "";
  for(int i=0; i<StringLen(str); i++)  {
    if (StringSubstr(str,i,1) != " " || !left) {
      outstr = outstr + StringSubstr(str,i,1);
      left = false;
  } }
  return(outstr);
}


//+------------------------------------------------------------------+
string StringRightTrim(string str)
//+------------------------------------------------------------------+
// Removes all trailing spaces from a string
// Usage:    string x=StringRightTrim("  XX YY  ")  returns x = "  XX  YY"
{
  int pos = 0;
  for(int i=StringLen(str)-1; i>=0; i--)  {
    if (StringSubstr(str,i,1) != " ")   {
      pos = i;
      break;
  } }
  string outstr = StringSubstr(str,0,pos+1);
  return(outstr);
}


//+------------------------------------------------------------------+
string StringRepeat(string str, int n=1)
//+------------------------------------------------------------------+
// Repeats the string STR N times
// Usage:    string x=StringRepeat("-",10)  returns x = "----------"
{
  string outstr = "";
  for(int i=0; i<n; i++)  {
    outstr = outstr + str;
  }
  return(outstr);
}


//+------------------------------------------------------------------+
string StringUpper(string str)
//+------------------------------------------------------------------+
// Converts any lowercase characters in a string to uppercase
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "THE QUICK BROWN FOX"
{
  string outstr = "";
  string lower  = "abcdefghijklmnopqrstuvwxyz";
  string upper  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  for(int i=0; i<StringLen(str); i++)  {
    int t1 = StringFind(lower,StringSubstr(str,i,1),0);
    if (t1 >=0)  
      outstr = outstr + StringSubstr(upper,t1,1);
    else
      outstr = outstr + StringSubstr(str,i,1);
  }
  return(outstr);
}  


//+------------------------------------------------------------------+
string StringLower(string str)
//+------------------------------------------------------------------+
// Converts any uppercase characters in a string to lowercase
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "the quick brown fox"
{
  string outstr = "";
  string lower  = "abcdefghijklmnopqrstuvwxyz";
  string upper  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  for(int i=0; i<StringLen(str); i++)  {
    int t1 = StringFind(upper,StringSubstr(str,i,1),0);
    if (t1 >=0)  
      outstr = outstr + StringSubstr(lower,t1,1);
    else
      outstr = outstr + StringSubstr(str,i,1);
  }
  return(outstr);
}


//+------------------------------------------------------------------+
string ExpandCcy(string str)
//+------------------------------------------------------------------+
// Expands a currency (e.g. G to GBP) or a currency pair (e.g. EU to EURUSD)
//  as shown in the code
{
  str = StringTrim(StringUpper(str));
  if (StringLen(str) < 1 || StringLen(str) > 2)   return(str);
  string str2 = "";
  for (int i=0; i<StringLen(str); i++)   {
    string char2 = StringSubstr(str,i,1);
    if (char2 == "A")  str2 = str2 + "AUD";     else
    if (char2 == "C")  str2 = str2 + "CAD";     else   
    if (char2 == "E")  str2 = str2 + "EUR";     else   
    if (char2 == "F")  str2 = str2 + "CHF";     else   
    if (char2 == "G")  str2 = str2 + "GBP";     else   
    if (char2 == "J")  str2 = str2 + "JPY";     else   
    if (char2 == "N")  str2 = str2 + "NZD";     else   
    if (char2 == "U")  str2 = str2 + "USD";     else   
    if (char2 == "H")  str2 = str2 + "HKD";     else   
    if (char2 == "S")  str2 = str2 + "SGD";     else   
    if (char2 == "Z")  str2 = str2 + "ZAR";   
  }  
  return(str2);
}


//+------------------------------------------------------------------+
string ReduceCcy(string str)
//+------------------------------------------------------------------+
// Abbreviates a single currency (e.g. GBP to G) or a currency pair (e.g. EURUSD to EU)
//  as shown in the code. Inverse of ExpandCcy() function
{
  str = StringTrim(StringUpper(str));
  if (StringLen(str) !=3 && StringLen(str) < 6)   return("");
  string s = "";
  for (int i=0; i<StringLen(str); i+=3)   {
    string char2 = StringSubstr(str,i,3);
    if (char2 == "AUD")  s = s + "A";     else
    if (char2 == "CAD")  s = s + "C";     else   
    if (char2 == "EUR")  s = s + "E";     else   
    if (char2 == "CHF")  s = s + "F";     else   
    if (char2 == "GBP")  s = s + "G";     else   
    if (char2 == "JPY")  s = s + "J";     else   
    if (char2 == "NZD")  s = s + "N";     else   
    if (char2 == "USD")  s = s + "U";     else   
    if (char2 == "HKD")  s = s + "H";     else   
    if (char2 == "SGD")  s = s + "S";     else   
    if (char2 == "ZAR")  s = s + "Z";   
  }  
  return(s);
}


//+------------------------------------------------------------------+
double MathInt(double n, int d=0)
//+------------------------------------------------------------------+
// Corrects a rounding/accuracy bug in MQL4's MathFloor function
//   (use MathInt(n) instead of MathFloor(n)
// Rounds n DOWN to d decimal places, e.g.
// MathInt(2.57,1) returns 2.5
// MathInt(2.99)   returns 2
 {
   return(MathFloor(n*MathPow(10,d)+0.000000000001)/MathPow(10,d));
 }  


//+------------------------------------------------------------------+
double MathFix(double n, int d=0)
//+------------------------------------------------------------------+
// Corrects a rounding/accuracy bug in MQL4's MathRound() function
//   (use MathFix(n) instead of MathRound(n)
// Rounds n to d decimal places, e.g.
// MathFix(2.54,1) returns 2.5
// MathFix(2.57,1) returns 2.6
// MathFix(2.99)   returns 3
{
  return(MathRound(n*MathPow(10,d)+0.000000000001*MathSign(n))/MathPow(10,d));
}  


//+------------------------------------------------------------------+
double DivZero(double n, double d)
//+------------------------------------------------------------------+
// Divides N by D, and returns 0 if the denominator (D) = 0
// Usage:   double x = DivZero(y,z)  sets x = y/z
// Use DivZero(y,z) instead of y/z to eliminate division by zero errors
{
  if (d == 0) return(0);  else return(1.0*n/d);
}  


//+------------------------------------------------------------------+
int MathSign(double n)
//+------------------------------------------------------------------+
// Returns the sign of a number (i.e. -1, 0, +1)
// Usage:   int x=MathSign(-25)   returns x=-1
{
  if (n > 0) return(1);
  else if (n < 0) return (-1);
  else return(0);
}  


//+------------------------------------------------------------------+
void ShellsortStringArray(string &a[], bool desc=false)  {
//+------------------------------------------------------------------+
// Performs a shell sort (rapid resorting) of string array 'a'
//  default is ascending order, unless 'desc' is set to true
  int n=ArraySize(a);
  int j,i,m;
  string mid;
  for(m=n/2; m>0; m/=2)  {
    for(j=m; j<n; j++)  {
      for(i=j-m; i>=0; i-=m)  {
        if (desc)   {
          if (a[i+m] <= a[i])
            break;
          else {
            mid = a[i];
            a[i] = a[i+m];
            a[i+m] = mid;
        } }  
        else  {
          if (a[i+m] >= a[i])
            break;
          else {
            mid = a[i];
            a[i] = a[i+m];
            a[i+m] = mid;
        } }  
  } } } 
  //return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getSymbols()
  {
   string sep=",";
   ushort u_sep;
   u_sep=StringGetCharacter(sep,0);
   StringSplit(symbols,u_sep,symbolList);

   numSymbols=ArraySize(symbolList);//get the number of how many symbols are in the symbolList array

   ArrayResize(symbolListFinal,numSymbols);//resize finals symbol list to correct size

   for(int i=0;i<numSymbols;i++)//combines postfix , symbol , prefix names together
     {
      symbolListFinal[i]=symbolPrefix+symbolList[i]+symbolSuffix;
      //printf(symbolListFinal[i]);
     }
  }

//+----------------------------------------------------------------------------+
// PlSoft Routine ( trova superminimo & supermassimo)
//+----------------------------------------------------------------------------+
int WriteSuperMinMax(string MySymbol,int dux)
  {

   int    counted_bars=IndicatorCounted();
   
   double lowest=1000.0; double highest=0.0;
 
//----
   
   for(int i=lookback+lastbar;i>lastbar+1;i--)
   {  
      double curLow0=iClose(MySymbol,timeframe,i-2);
      double curLow1=iClose(MySymbol,timeframe,i+1);
      double curLow2=iClose(MySymbol,timeframe,i);
      double curLow3=iClose(MySymbol,timeframe,i-1);
      double curLow4=iClose(MySymbol,timeframe,i-2);
      
      double curHigh0=iClose(MySymbol,timeframe,i+2);
      double curHigh1=iClose(MySymbol,timeframe,i+1);
      double curHigh2=iClose(MySymbol,timeframe,i);
      double curHigh3=iClose(MySymbol,timeframe,i-1);
      double curHigh4=iClose(MySymbol,timeframe,i-2);
         
      if(curLow2<=curLow1 && curLow2<=curLow1 && curLow2<=curLow0 )
      {
         if(lowest>curLow2){
         lowest=curLow2;}                
      }
      
      if(curHigh2>=curHigh1 && curHigh2>=curHigh3&& curHigh2>=curHigh4)
      {  
         if(highest<curHigh2){
         highest=curHigh2;}    
      }     

  }            
      
      priceLow[dux] = 100*(iClose(MySymbol,timeframe,0)-lowest)/lowest;
      priceHigh[dux] = 100*(highest-iClose(MySymbol,timeframe,0))/iClose(MySymbol,timeframe,0); 
                 
return(0);

}
void SetText(string name,string text,int x,int y,color colour)
  {
   if (ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);

    ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
    ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
    ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
    ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FontSize);
    ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
    ObjectSetString(0,name,OBJPROP_TEXT,text);
  } 
  
//+------------------------------------------------------------------+  
void SetObjText(string name,string CharToStr,int x,int y,color colour,int fontsize=12)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);

   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_TEXT,CharToStr);
   ObjectSetString(0,name,OBJPROP_FONT,"Wingdings");
  }   
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(string doWhat,int SYm, int bilia)
{

   string message, altezza, trend;

   //
   //
   //
   //
   //     
   
   if(GlobalVariableGet(doWhat+"LR")==DownColor)trend = "SELL"; else trend = "BUY";
   
   if(GlobalVariableGet(doWhat+"LR")==DownColor && alertmail[SYm][1][0]==1) { altezza = " >FH"; }
   else if(GlobalVariableGet(doWhat+"LR")==UPcolor && alertmail[SYm][0][0]==1) { altezza = " <FL"; }
   else { altezza = "-";}
   
   if(previousTime[SYm]!=Time[0]) 
   {
      previousTime[SYm]  = Time[0];
   
      message= StringConcatenate(TimeToStr(TimeLocal(),TIME_SECONDS)," Massima Divergenza : ",doWhat,
                                                                     " Trend: ", trend,
                                                                     " Sfera: ",DoubleToStr(bilia,0),
                                                                     "\n Price: ",DoubleToStr(iClose(symbolListFinal[SYm],0,0),3), 
                                                                     " # ", altezza);
                                                                     
               WriteFile(doWhat,trend,DoubleToStr(bilia,0) ,DoubleToStr(iClose(symbolListFinal[SYm],0,0),3),altezza);
               SendNotification(message);
               Alert(message);
    }
}
//+------------------------------------------------------------------+
//|ROC                                                              |
//+------------------------------------------------------------------+
void Roc()
  {   
  
   for(int i=0; i<28; i++)
     {
      ChangeArray[i]=SymbolChange(symbolListFinal[i],TimeFrame);       
            
      //---
      if(ChangeArray[i]<0)
        {   //SetText("Roc_"+symbolListFinal[i], DoubleToStr(ChangeArray[i],2),HorizPos+255,(i*16)+VertPos+15,DownColor);
        }                 
      else if(ChangeArray[i]>1)
        {   //SetText("Roc_"+symbolListFinal[i], DoubleToStr(ChangeArray[i],2),HorizPos+255,(i*16)+VertPos+15,UPcolor);
        }                
      else if(ChangeArray[i]>-0.01 && ChangeArray[i]<0.01)
        {   //SetText("Roc_"+symbolListFinal[i], DoubleToStr(ChangeArray[i],2),HorizPos+255,(i*16)+VertPos+15,clrGold); 
        alertmail[i][5][0]=1;
        }                      
      else 
        {   //SetText("Roc_"+symbolListFinal[i], DoubleToStr(ChangeArray[i],2),HorizPos+255,(i*16)+VertPos+15,clrAqua);
        }
     
   int max = ArrayMaximum(ChangeArray, WHOLE_ARRAY, 0);
   int min = ArrayMinimum(ChangeArray, WHOLE_ARRAY, 0);
//---
   double tmp=0;
//---
   if(ChangeArray[max]>MathAbs(ChangeArray[min])) tmp=ChangeArray[max];
   else tmp=MathAbs(ChangeArray[min]);
//---
   if(tmp*cF>Ysize/2) cF--;
   if((Ysize/2-tmp*cF)>20) cF++;
  }
} 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SymbolChange(string symbol,ENUM_TIMEFRAMES period)
  {
   SymbolSelect(symbol,true);
   double perf  = 0;
   double open  = iOpen(symbol, period, 0);
   double close = iClose(symbol, period, 0);
//---
   if(open!=0)
     {
      perf=(close-open);
      perf /= open;
      perf *= 100;
     }
   else Print("Change NaN");
//---
 
   //GlobalVariableSet(symbol+"ROC", perf);
   return(NormalizeDouble(perf, 2));
   
  }
//+----------------------------------------------------------------------------+
// PlSoft Routine ( memorizzazione dati CVS)
//+----------------------------------------------------------------------------+
void WriteFile(string s2,string s3 ,string s4,double price,string s5)
  { 
   
   subfolder="Research";
   namafile="_data of "+s2+".csv";
   handlefile=FileOpen(subfolder+"\\"+namafile, FILE_CSV|FILE_WRITE|FILE_READ, ";");
      
   if(handlefile>0)
     {  
        date_=TimeToStr(Time[0], TIME_DATE);
        time_=TimeToStr(TimeCurrent(),TIME_MINUTES);

        FileSeek (handlefile, 0 , SEEK_END );
        writefile=FileWrite(handlefile, "Symbol " +"|"+ s2 +
                                        "|"+ date_ +
                                        "|"+ time_ +
                                        "|"+ s3 +
                                        "|"+ s4 +                                        
                                        "|"+ price +
                                        "|"+ s5                                                                                                
                            );
                                            
        FileClose(handlefile);         
      
      }   
      
     // SetText("centro",s2,0,220,clrTomato,12);        
}
//
//
//
//
