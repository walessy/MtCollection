#property copyright "www,forex-station.com"
#property link      "www,forex-station.com"

#property indicator_chart_window
extern int coaf = 2;
extern int res = 45;
extern int LimitBar = 120;
extern int WIDTH = 3;
extern int cegl = 6;
extern string Shrift = "Arial Black";
extern bool tdelete = true;


datetime ctat_SB =0;
double old_price;
datetime max_SB=0,min_SB=0;
double max_price=0;
double count_plus=0,count_minus=0;
datetime time_21=0,time_22=0;
int max_ti=0, min_ti=0;

int init() {return(0);}

int deinit() {
  if (tdelete == true) {
    GetDellName4(); 
  }
  ObjectsDeleteAll(0, OBJ_HLINE);
  ObjectsDeleteAll(0, OBJ_TREND);
  return(0);
}

int start() {
  double price;string name_1,name_2,name_3,name_44;
  int i=0;
  int limit; 
  double delta;  
  int counted_bars=IndicatorCounted();   
  if(counted_bars<0) return(-1);
  if(counted_bars>0) counted_bars--;
  limit=Bars-counted_bars;
  if(ctat_SB==0) ctat_SB=Time[0];
   
  if(limit>0) limit=0;
   
  for(i=limit; i>=0; i--) {
    if(old_price==0) old_price=Close[i];
    if(iBarShift(NULL,0,ctat_SB)-iBarShift(NULL,0,Time[i])>=LimitBar) {
      ctat_SB=Time[i];       
      max_SB=ctat_SB;
      min_SB=ctat_SB;
      max_price=0;
      count_plus=0;
      count_minus=0;
      max_ti=0; 
      min_ti=0;
    } 
    price = Close[i];
    if(price > max_price) max_price=price;
    delta = price - old_price;
    
     //---- Êàóíò ïëþñ 
    if(delta>=0) {
      count_plus++;
       
       name_1 = "TPM_ "+DoubleToStr(price,Digits)+TimeToStr(ctat_SB); 
        if (ObjectFind(name_1)<0) {
        time_21 = ctat_SB+(60/coaf)*Period();
        TrendLineGraff(name_1,ctat_SB,price,time_21,price,Red,0);
      } else {
        time_21 = ObjectGet(name_1,OBJPROP_TIME2)+(60/coaf)*Period();
        TrendLineGraff(name_1,ctat_SB,price,time_21,price,Red,0);         
      }
      if(time_21>max_SB) {         
        max_SB=time_21;
        TrendLineGraff("TPM_11 "+TimeToStr(ctat_SB),ctat_SB,price,max_SB,price,Tomato,3);
        if (count_plus > count_minus) {
       ObjectDelete("TPM_222 "+" "+TimeToStr(ctat_SB));
       ObjectDelete("TPM_111 "+" "+TimeToStr(ctat_SB));
       LineGraff("TPM_111 "+" "+TimeToStr(ctat_SB),max_SB,price,Tomato);
        }
        max_ti=(max_SB-ctat_SB)/60;            
        }}
        
     //---- Êàóíò ìèíóñ
    if(delta<0) {
      count_minus++;
       name_2 = "TPM_ 2 "+DoubleToStr(price,Digits)+TimeToStr(ctat_SB); 
        if (ObjectFind(name_2)<0) {
        time_22 = ctat_SB-(60/coaf)*Period();
        TrendLineGraff(name_2,ctat_SB,price,time_22,price,Blue,0);
      } else {
        time_22 = ObjectGet(name_2,OBJPROP_TIME2)-(60/coaf)*Period();
        TrendLineGraff(name_2,ctat_SB,price,time_22,price,Blue,0);
      }
      if(min_SB==0)min_SB=ctat_SB;
      if(time_22<min_SB) {
        min_SB=time_22;
        TrendLineGraff("TPM_22 "+TimeToStr(ctat_SB),ctat_SB,price,min_SB,price,SteelBlue,3);
        if (count_plus < count_minus) {
        ObjectDelete("TPM_111 "+" "+TimeToStr(ctat_SB));
        ObjectDelete("TPM_222 "+" "+TimeToStr(ctat_SB));
         LineGraff("TPM_222 "+" "+TimeToStr(ctat_SB),min_SB,price, SteelBlue);
           }
        min_ti=(ctat_SB-min_SB)/60;
          }}
          
     //----
    old_price=price;
     //----
    name_3 = "TPM_ 3 "+DoubleToStr(price,Digits);
    if(time_21==0)time_21=ctat_SB;
    if(time_22==0)time_22=ctat_SB;    
    int lev = (time_21 - ctat_SB)/60 - (ctat_SB - time_22)/60;
    if(lev>0 && lev>=res)
    SetText(name_3,DoubleToStr(lev,0),time_21/*+60*Period()*/, price, Black,8);
    if(lev<0 && MathAbs(lev)>=res)
    SetText(name_3,DoubleToStr(MathAbs(lev),0),time_22/*-60*Period()*/, price, Black,8);     
     //----
    name_44 = "TPM_ 4 "+TimeToStr(ctat_SB);
   // SetText(name_4+"sell",DoubleToStr(MathAbs(count_plus),0)+"/"+DoubleToStr(MathAbs(max_ti),0),ctat_SB+60*Period()*2, max_price+(Ask-Bid)*6, Blue,12);
   // SetText(name_4+"bay",DoubleToStr(MathAbs(count_minus),0)+"/"+DoubleToStr(MathAbs(min_ti),0),ctat_SB-60*Period()*2, max_price+(Ask-Bid)*4.5, Red,12);     
    SetText(name_44+"summ",DoubleToStr(count_minus+count_plus,0)+"/"+DoubleToStr(min_ti+max_ti,0),ctat_SB+20*Period()*2, max_price+(Ask-Bid)*5, Green,12);   
    SetText(name_44+"% ot summ",DoubleToStr((count_minus/(count_minus+count_plus)*100),2)+"/"+DoubleToStr((count_plus/(count_minus+count_plus)*100),2),ctat_SB+40*Period()*2, max_price+(Ask-Bid)*3, Black,12);   
     
  
  }  

  return(0);
}
 void TrendLineGraff(string labebe,datetime time1,double price1,datetime time2,double price2,color colir, int W)
  {
   if (ObjectFind(labebe)!=-1) ObjectDelete(labebe);
   ObjectCreate(labebe, OBJ_TREND, 0,time1,price1,time2,price2);
   ObjectSet(labebe, OBJPROP_COLOR, colir);
   ObjectSet(labebe, OBJPROP_STYLE,0);
   ObjectSet(labebe, OBJPROP_RAY,0);
   ObjectSet(labebe, OBJPROP_WIDTH,W);   
   ObjectSet(labebe, OBJPROP_BACK, true);
  }
  
void LineGraff(string labebe1,datetime time1,double price1,color colir)
  {
 
  if (ObjectFind(labebe1)!=-1) ObjectDelete(labebe1);
   ObjectCreate(labebe1, OBJ_HLINE, 0,time1,price1);
   ObjectSet(labebe1, OBJPROP_COLOR, colir);
   ObjectSet(labebe1, OBJPROP_STYLE,2);
   ObjectSet(labebe1, OBJPROP_BACK, true);
   }  
  
//+-----------------------------------------------------------+
//| Óäàëåíèå îáúåêòîâ                                          |
//+------------------------------------------------------------+
 void GetDellName4 (string name_n = "TPM_ ")
  {
   string vName4;
   for(int i=ObjectsTotal()-1; i>=0;i--)
    {
     vName4 = ObjectName(i);
     if (StringFind(vName4,name_n) !=-1) ObjectDelete(vName4);
    }  
  } 
//---- 
void SetText(string name,string text,datetime t1, double p1, color c, int size)
 {
  if (ObjectFind(name)!=-1) ObjectDelete(name);
  ObjectCreate(name,OBJ_TEXT,0,0,0,0,0);     
  ObjectSet(name, OBJPROP_TIME1 , t1);
  ObjectSet(name, OBJPROP_PRICE1, p1);    
  ObjectSetText(name,text,cegl,Shrift,c);
 }
//----