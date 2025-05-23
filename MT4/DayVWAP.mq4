#property copyright "Copyright © 2020, Akif TOKUZ"
#property link      "akifusenet@gmail.com"

#property indicator_chart_window

#property indicator_buffers 8

#property indicator_color1 Crimson      //PVP
#property indicator_width1 2

#property indicator_color2 Aqua        //VWAP
#property indicator_width2 2

#property indicator_color3 Gray       //SD1Pos
#property indicator_width3 1
#property indicator_style3 2

#property indicator_color4 Gray         //SD1Neg
#property indicator_width4 1
#property indicator_style4 2

#property indicator_color5 Gray//SD2Pos
#property indicator_width5 1
#property indicator_style5 2

#property indicator_color6 Gray     //SD2Neg
#property indicator_width6 1
#property indicator_style6 2

#property indicator_color7 Gray   //SD2Pos
#property indicator_width7 1
#property indicator_style7 2

#property indicator_color8 Gray   //SD2Neg
#property indicator_width8 1
#property indicator_style8 2


//---- input parameters
extern int     InstanceOnChart = 1;
extern bool    UseTPOInsteadTickVolume = false;
extern bool    EndingDragLine = false;
extern int     DayStartingHour=9;
//extern int     HistogramAmplitude = 100;

//extern bool    Show_SD1 = true;
//extern bool    Show_SD2 = true;
//extern bool    Show_SD3 = true;

//extern bool    Show_PVP = true;
extern bool    Show_VWAP = true;
//extern bool    Show_POC = true;
//extern color   POC_Color = clrAqua;
//extern int     POC_Width = 4;
//extern int     POC_Style = 0;
//extern int     LabelFontSize = 15;
//extern color   SDLabelColor = clrGray;


int     startDaysBack=1;
int     endDaysBack=0;


//---- buffers
//double PVP[];
double VWAP[];
//double SD1Pos[];
//double SD1Neg[];
//double SD2Pos[];
//double SD2Neg[];
//double SD3Pos[];
//double SD3Neg[];

//double Hist[]; // drawn specifically

string  label="MS_Daily_"+InstanceOnChart+"_";
string   OBJECT_PREFIX;
int      Bars_Back = 0; // Shows the starting bar for given date
int      Bars_Back_End = 0; // Shows the end bar for given date
int      items;         // numbers of items inside volume histogram
double   SD;            // standart deviation
datetime CurrentCandleTime = D'2034.03.05 15:46:58';
bool     startLineDragged = false;
bool     endLineDragged = false;
bool     firstRun;

// Finds the bar number for the given date
int FindStartIndex()
{
  if (Bars>=Bars_Back) return(Bars_Back);  
  return(0);
} 

// Finds the bar number for the given date
int FindEndIndex()
{
  if (Bars_Back_End<0) return(0);  
  return(Bars_Back_End);
} 


int init()
{
   //OBJECT_PREFIX = label+"VolumeHistogram_"+DoubleToStr(Time[FindStartIndex()],0)+"_" ;
   OBJECT_PREFIX = label+"VolumeHistogram_";
   
//---- indicators
   IndicatorBuffers(8);
   
//   if (Show_PVP==true) SetIndexStyle(0,DRAW_LINE);
//   else  SetIndexStyle(0,DRAW_NONE);
//   SetIndexLabel(0,"PVP");      
//   SetIndexBuffer(0,PVP);
//   SetIndexEmptyValue(0,EMPTY_VALUE);
   
   //if (Show_VWAP==true) 
   SetIndexStyle(1,DRAW_LINE);
   //else  SetIndexStyle(1,DRAW_NONE);
   SetIndexLabel(1,"VWAP");      
   SetIndexBuffer(1,VWAP);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   
   //if (Show_SD1==true) SetIndexStyle(2,DRAW_LINE);
   //else  SetIndexStyle(2,DRAW_NONE);
   //SetIndexLabel(2,"SD1Pos");      
   //SetIndexBuffer(2,SD1Pos);
   //SetIndexEmptyValue(2,EMPTY_VALUE);
   
   //if (Show_SD1==true) SetIndexStyle(3,DRAW_LINE);
   //else  SetIndexStyle(3,DRAW_NONE);
   //SetIndexLabel(3,"SD1Neg");      
   //SetIndexBuffer(3,SD1Neg);
   //SetIndexEmptyValue(3,EMPTY_VALUE);
   
   //if (Show_SD2==true) SetIndexStyle(4,DRAW_LINE);
   //else  SetIndexStyle(4,DRAW_NONE);
   //SetIndexLabel(4,"SD2Pos");      
   //SetIndexBuffer(4,SD2Pos);
   //SetIndexEmptyValue(4,EMPTY_VALUE);
   
   //if (Show_SD2==true) SetIndexStyle(5,DRAW_LINE);
   //else  SetIndexStyle(5,DRAW_NONE);
   //SetIndexLabel(5,"SD2Neg");      
   //SetIndexBuffer(5,SD2Neg);
   //SetIndexEmptyValue(5,EMPTY_VALUE);
   
   //if (Show_SD3==true) SetIndexStyle(6,DRAW_LINE);
   //else  SetIndexStyle(6,DRAW_NONE);
   //SetIndexLabel(6,"SD3Pos");      
   //SetIndexBuffer(6,SD3Pos);
   //SetIndexEmptyValue(6,EMPTY_VALUE);
   
   //if (Show_SD3==true) SetIndexStyle(7,DRAW_LINE);
   //else  SetIndexStyle(7,DRAW_NONE);
   //SetIndexLabel(7,"SD3Neg");      
   //SetIndexBuffer(7,SD3Neg);
   //SetIndexEmptyValue(7,EMPTY_VALUE);
   
   string short_name="Market_Statistics";
   IndicatorShortName(short_name);
   


   if(ObjectFind(label+"Starting_Time")==0){ 
       Bars_Back = iBarShift(NULL,0,ObjectGet(label+"Starting_Time", OBJPROP_TIME1));    
   }
   else{
       Bars_Back = findStartingIndexOfDayPrior(startDaysBack);
   }
 
 
   if(ObjectFind(label+"End_Time")==0){ 
       Bars_Back_End = iBarShift(NULL,0,ObjectGet(label+"End_Time", OBJPROP_TIME1));    
   }
   else{
       Bars_Back_End = findStartingIndexOfDayPrior(endDaysBack);
       
   }
   
   if(EndingDragLine){
      Bars_Back_End = 1;
   }

   firstRun = true; 
   return(0);
}



int findStartingIndexOfDayPrior(int prior){
   int result=0;
   if (prior==0) return 0;
   MqlDateTime currentTime;
   MqlDateTime prevTime;
   int counter=0;
   int endIndex=0;
   for (int i=0;i<Bars-2;i++){
      TimeToStruct(Time[i],currentTime);
      TimeToStruct(Time[i+1],prevTime);
//      Print("currentTime.day_of_week:"+currentTime.day_of_week+" prevTime.day_of_week:"+prevTime.day_of_week);
      
      if (currentTime.day_of_year!=prevTime.day_of_year){ // day change
      
         //Find the hour index
         if (currentTime.hour<DayStartingHour && i>0){
            MqlDateTime hourTime;
            for (int j=i-1;j>=0;j--){
               TimeToStruct(Time[j],hourTime);
               if (hourTime.day_of_year!=currentTime.day_of_year) break;
               if (hourTime.hour==DayStartingHour){
                  i=j;
                  break;               
               }
            }
         }
         
         result=i;
         counter++;         
         if (counter>=prior) break;
      }
   }
   return result;   
}


// Delete all objects with given prefix
void ObDeleteObjectsByPrefix(string Prefix)
{
   int L = StringLen(Prefix);
   int i = 0; 
   while(i < ObjectsTotal())
   {
       string ObjName = ObjectName(i);
       if(StringSubstr(ObjName, 0, L) != Prefix) 
       { 
           i++; 
           continue;
       }
       ObjectDelete(ObjName);
   }
}
  
  

//---------------------------------------------------------+
  
int start()
{

   double TotalVolume=0;
   double TotalPV=0;

   int old_Bars_Back = Bars_Back;
   int old_Bars_Back_End = Bars_Back_End;
   color SkewLabelColor = clrGray;
   
   if(ObjectFind(label+"Starting_Time") == 0)
   { 
      Bars_Back= iBarShift(NULL,0,ObjectGet(label+"Starting_Time", OBJPROP_TIME1));
   }
   
   if(ObjectFind(label+"End_Time") == 0)
   { 
      Bars_Back_End= iBarShift(NULL,0,ObjectGet(label+"End_Time", OBJPROP_TIME1));
   }
   
   if (old_Bars_Back != Bars_Back){
      // Start Line has been dragged
      startLineDragged = true;
   }
   
   if (old_Bars_Back_End != Bars_Back_End){
      // End Line has been dragged
      endLineDragged = true;
   }
   

   if(ObjectFind(label+"Starting_Time") != 0)
   {
      // Vertical start line is not drawn
      Bars_Back=FindStartIndex();
      if (Bars_Back != 0){           
         ObjectCreate(label+"Starting_Time", OBJ_VLINE, 0, Time[Bars_Back], 0);
         ObjectSet(label+"Starting_Time", OBJPROP_TIME1, Time[Bars_Back]);
         ObjectSet(label+"Starting_Time", OBJPROP_COLOR, Red); 
         ObjectSet(label+"Starting_Time", OBJPROP_WIDTH, 2);           
      }
   }      
   
   

   if(ObjectFind(label+"End_Time") != 0)
   {
      // Vertical end line is not drawn
      Bars_Back_End=FindEndIndex();
      if (Bars_Back_End != 0){           
         ObjectCreate(label+"End_Time", OBJ_VLINE, 0, Time[Bars_Back_End], 0);
         ObjectSet(label+"End_Time", OBJPROP_TIME1, Time[Bars_Back_End]);
         ObjectSet(label+"End_Time", OBJPROP_COLOR, Blue); 
         ObjectSet(label+"End_Time", OBJPROP_WIDTH, 1);     
         ObjectSet(label+"End_Time", OBJPROP_STYLE, STYLE_DOT);      
      }
   }    
   
   int rectangleWidth = Bars_Back-Bars_Back_End + 1;
   // MAIN ALGORITM.Works only after a new candle occurs or if lines has been dragged
   
  
   if (endLineDragged || startLineDragged || (Bars_Back_End==0 && CurrentCandleTime != Time[0]) || firstRun )
   {
      firstRun = false;
      
      
      // New candle
      CurrentCandleTime = Time[0];
      startLineDragged = false;
      endLineDragged = false;
   
   
      //ArrayInitialize(PVP, EMPTY_VALUE);
      ArrayInitialize(VWAP, EMPTY_VALUE);
      //ArrayInitialize(SD1Pos, EMPTY_VALUE);
      //ArrayInitialize(SD1Neg, EMPTY_VALUE);
      //ArrayInitialize(SD2Pos, EMPTY_VALUE);
      //ArrayInitialize(SD2Neg, EMPTY_VALUE);
      //ArrayInitialize(SD3Pos, EMPTY_VALUE);
      //ArrayInitialize(SD3Neg, EMPTY_VALUE);      
   
                         
      double max = High[iHighest( NULL , 0, MODE_HIGH, Bars_Back-Bars_Back_End, Bars_Back_End)];
      double min =  Low[ iLowest( NULL , 0, MODE_LOW,  Bars_Back-Bars_Back_End, Bars_Back_End)];
      items = MathRound((max - min) / Point);

      //ArrayResize(Hist, items);
      //ArrayInitialize(Hist, 0);

      TotalVolume=0;
      TotalPV=0;
      for (int i = Bars_Back; i >= Bars_Back_End+1; i--)
      {         

         double t1 = Low[i], t2 = Open[i], t3 = Close[i], t4 = High[i];
         if (t2 > t3) {t3 = Open[i]; t2 = Close[i];}
         double totalRange = (t4 - t1);         
         /*
         if (totalRange != 0.0)
         {
         
            for (double Price_i = t1; Price_i <= t4; Price_i += Point)
            {
               n = MathRound((Price_i - min) / Point);
               //Hist[n] += MathRound(Volume[i]/totalRange);
               if (UseTPOInsteadTickVolume)
                  Hist[n] +=1;
               else
                  Hist[n] += MathRound(Volume[i]/totalRange);               
            }//for
            
         }else
         {
            // Check if all values are equal to each other
            n = MathRound((t3 - min) / Point);
            if (UseTPOInsteadTickVolume)
               Hist[n] +=1;
            else
               Hist[n] += Volume[i];                
            //Hist[n] += Volume[i];                     
         }//if
         */


         // use H+L+C/3 as average price
         if (UseTPOInsteadTickVolume){
            TotalPV+=((Low[i]+High[i]+Close[i])/3);
            TotalVolume+=1.0;                          
         }
         else{
            TotalPV+=Volume[i]*((Low[i]+High[i]+Close[i])/3);
            TotalVolume+=Volume[i];                          
         }
      
         //if (i==Bars_Back) PVP[i]=Close[i];        
         //else PVP[i]=min+ArrayMaximum(Hist)*Point;

         if (i==Bars_Back) VWAP[i]=Close[i];        
         else{ 
            if (TotalVolume!=0) VWAP[i]=TotalPV/TotalVolume;
         }
 

         SD=0;         
         for (int k = Bars_Back; k >= i; k--)
         {
            double avg=(High[k]+Close[k]+Low[k])/3;
            double diff=avg-VWAP[i];
             if (UseTPOInsteadTickVolume){
                  if (TotalVolume!=0) SD+=(1.0/TotalVolume)*(diff*diff); 
             }
             else{
                  if (TotalVolume!=0) SD+=(Volume[k]/TotalVolume)*(diff*diff); 
             }
             
          }
          //SD=MathSqrt(SD);
          //SD1Pos[i]=VWAP[i]+SD;
          //SD1Neg[i]=VWAP[i]-SD;
          //SD2Pos[i]=SD1Pos[i]+SD;
          //SD2Neg[i]=SD1Neg[i]-SD;
          //SD3Pos[i]=SD2Pos[i]+SD;
          //SD3Neg[i]=SD2Neg[i]-SD;
          
         
         //string SDText = "SD: "+DoubleToStr(SD/Point()/10, 2);
         //string SkewText = "Skew: "+DoubleToStr((VWAP[i]-PVP[i])/Point()/10, 2);
         
         //if (VWAP[i]>PVP[i]) SkewLabelColor = clrDodgerBlue;
         //else SkewLabelColor = clrRed;
          
          
      }//for BARS BACK
      
      /*
        extern string note6 = "Upper left=0; Upper right=1";
        extern string note7 = "Lower left=2; Lower right=3";
      */            
      string SDLabelName = label+"Label_SD_";
      string SkewLabelName = label+"Label_Skew_";
      //ObjectCreate(SDLabelName, OBJ_LABEL, 0, 0, 0);
      //ObjectSetText(SDLabelName, SDText, LabelFontSize, "Times New Roman", SDLabelColor);
      //ObjectCreate(SkewLabelName, OBJ_LABEL, 0, 0, 0);
      //ObjectSetText(SkewLabelName, SkewText, LabelFontSize, "Times New Roman", SkewLabelColor);
      //ObjectSet(SDLabelName, OBJPROP_CORNER, 1);
      //ObjectSet(SkewLabelName, OBJPROP_CORNER, 1);
      //ObjectSet(SDLabelName, OBJPROP_XDISTANCE, 1+(LabelFontSize*10)*(InstanceOnChart-1));
      //ObjectSet(SkewLabelName, OBJPROP_XDISTANCE, 1+(LabelFontSize*10)*(InstanceOnChart-1));
      //ObjectSet(SDLabelName, OBJPROP_YDISTANCE, 1);
      //ObjectSet(SkewLabelName, OBJPROP_YDISTANCE, LabelFontSize*2);
      
      
      
      
      // Clear volume histogram objects
      ObDeleteObjectsByPrefix(OBJECT_PREFIX);

      //int histogramWidth=rectangleWidth/2;
      

   }//MAIN IF BAR START


   
   return(0);
}

int deinit()
{
   ObDeleteObjectsByPrefix(OBJECT_PREFIX);
   
   ObjectDelete(label+"Label_SD_");
   ObjectDelete(label+"Label_Skew_");
   ObjectDelete(label+"Starting_Time");
   ObjectDelete(label+"End_Time");

   Comment("");
   return(0);
}





