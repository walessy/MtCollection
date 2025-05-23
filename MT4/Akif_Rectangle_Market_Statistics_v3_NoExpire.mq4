#property copyright "Copyright © 2019, Akif TOKUZ"
#property link      "akifusenet@gmail.com"

#property indicator_chart_window
#property indicator_buffers 8

#property indicator_color1 Orange      //PVP
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
extern bool    FillRectangle = false;
extern color   RectangleColor = clrBlue;
extern bool    Show_SD1 = true;
extern bool    Show_SD2 = true;
extern bool    Show_SD3 = true;
extern bool    Show_Histogram = true;
extern bool    Show_PVP = true;
extern bool    Show_VWAP = true;
extern bool    Show_POC = true;

//---- buffers
//---- buffers
double PVP[];
double VWAP[];
double SD1Pos[];
double SD1Neg[];
double SD2Pos[];
double SD2Neg[];
double SD3Pos[];
double SD3Neg[];
double Hist[]; // drawn specifically

string   label="RVP_";
int      items;         // numbers of items inside volume histogram
double   SD;            // standart deviation




int init()
{

//---- indicators
   IndicatorBuffers(8);
   
   if (Show_PVP==true) SetIndexStyle(0,DRAW_LINE);
   else  SetIndexStyle(0,DRAW_NONE);
   SetIndexLabel(0,"PVP");      
   SetIndexBuffer(0,PVP);
   SetIndexEmptyValue(0,EMPTY_VALUE);
   
   if (Show_VWAP==true) SetIndexStyle(1,DRAW_LINE);
   else  SetIndexStyle(1,DRAW_NONE);
   SetIndexLabel(1,"VWAP");      
   SetIndexBuffer(1,VWAP);
   SetIndexEmptyValue(1,EMPTY_VALUE);
   
   if (Show_SD1==true) SetIndexStyle(2,DRAW_LINE);
   else  SetIndexStyle(2,DRAW_NONE);
   SetIndexLabel(2,"SD1Pos");      
   SetIndexBuffer(2,SD1Pos);
   SetIndexEmptyValue(2,EMPTY_VALUE);
   
   if (Show_SD1==true) SetIndexStyle(3,DRAW_LINE);
   else  SetIndexStyle(3,DRAW_NONE);
   SetIndexLabel(3,"SD1Neg");      
   SetIndexBuffer(3,SD1Neg);
   SetIndexEmptyValue(3,EMPTY_VALUE);
   
   if (Show_SD2==true) SetIndexStyle(4,DRAW_LINE);
   else  SetIndexStyle(4,DRAW_NONE);
   SetIndexLabel(4,"SD2Pos");      
   SetIndexBuffer(4,SD2Pos);
   SetIndexEmptyValue(4,EMPTY_VALUE);
   
   if (Show_SD2==true) SetIndexStyle(5,DRAW_LINE);
   else  SetIndexStyle(5,DRAW_NONE);
   SetIndexLabel(5,"SD2Neg");      
   SetIndexBuffer(5,SD2Neg);
   SetIndexEmptyValue(5,EMPTY_VALUE);
   
   if (Show_SD3==true) SetIndexStyle(6,DRAW_LINE);
   else  SetIndexStyle(6,DRAW_NONE);
   SetIndexLabel(6,"SD3Pos");      
   SetIndexBuffer(6,SD3Pos);
   SetIndexEmptyValue(6,EMPTY_VALUE);
   
   if (Show_SD3==true) SetIndexStyle(7,DRAW_LINE);
   else  SetIndexStyle(7,DRAW_NONE);
   SetIndexLabel(7,"SD3Neg");      
   SetIndexBuffer(7,SD3Neg);
   SetIndexEmptyValue(7,EMPTY_VALUE);
   



   
//---- indicators
  
   
   ArrayInitialize(PVP, EMPTY_VALUE);
   ArrayInitialize(VWAP, EMPTY_VALUE);
   ArrayInitialize(SD1Pos, EMPTY_VALUE);
   ArrayInitialize(SD1Neg, EMPTY_VALUE);
   ArrayInitialize(SD2Pos, EMPTY_VALUE);
   ArrayInitialize(SD2Neg, EMPTY_VALUE);
   ArrayInitialize(SD3Pos, EMPTY_VALUE);
   ArrayInitialize(SD3Neg, EMPTY_VALUE);      	
   
   
   
   string short_name="Rectangle Volume Profile";
   IndicatorShortName(short_name);



   ChartSetInteger(0,CHART_EVENT_OBJECT_CREATE,0,true);
   ChartSetInteger(0,CHART_EVENT_OBJECT_DELETE,0,true);

 
   return(0);
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
  
  
//+------------------------------------------------------------------+
//|                                                                  |
//| drawLine: Draws a line                   |
//|                                                                  |
//+------------------------------------------------------------------+
void  drawLine(string prefix,datetime _startTime,datetime _endTime,double upLimit,double downLimit,int size,color rectColor) 
  {
   string ObjectText=prefix;
   ObjectCreate(ObjectText,OBJ_TREND,0,_startTime,upLimit,_endTime,downLimit);
   ObjectSet(ObjectText,OBJPROP_STYLE,DRAW_LINE);
   ObjectSet(ObjectText,OBJPROP_COLOR,rectColor);
   ObjectSet(ObjectText,OBJPROP_BACK,false);
   ObjectSet(ObjectText,OBJPROP_RAY,false);
   ObjectSet(ObjectText,OBJPROP_WIDTH,size);
  }  
  
  
color getHeatMapColor(float value)
{
  int NUM_COLORS = 4;
  float colors[4][3] = { {0,0,1}, {0,1,0}, {1,1,0}, {1,0,0} };
    // A static array of 4 colors:  (blue,   green,  yellow,  red) using {r,g,b} for each.
 
  int idx1;        // |-- Our desired color will be between these two indexes in "color".
  int idx2;        // |
  float fractBetween = 0;  // Fraction between "idx1" and "idx2" where our value is.
 
  if(value <= 0)      {  idx1 = idx2 = 0;            }    // accounts for an input <=0
  else if(value >= 1)  {  idx1 = idx2 = NUM_COLORS-1; }    // accounts for an input >=0
  else
  {
    value = value * (NUM_COLORS-1);        // Will multiply value by 3.
    idx1  = floor(value);                  // Our desired color will be after this index.
    idx2  = idx1+1;                        // ... and before this index (inclusive).
    fractBetween = value - float(idx1);    // Distance between the two indexes (0-1).
  }
  int r   = int(((colors[idx2][0] - colors[idx1][0])*fractBetween + colors[idx1][0])*255);
  int g = int(((colors[idx2][1] - colors[idx1][1])*fractBetween + colors[idx1][1])*255);
  int b  = int(((colors[idx2][2] - colors[idx1][2])*fractBetween + colors[idx1][2])*255);
  
  return StringToColor(IntegerToString(r)+","+IntegerToString(g)+","+IntegerToString(b));
    
}
 

int deinit()
{
   ObDeleteObjectsByPrefix(label);
   Comment("");
   return(0);
}  

//---------------------------------------------------------+
  
  
  
void ResetAllArrays(){
         ArrayInitialize(PVP, EMPTY_VALUE);
         ArrayInitialize(VWAP, EMPTY_VALUE);
         ArrayInitialize(SD1Pos, EMPTY_VALUE);
         ArrayInitialize(SD1Neg, EMPTY_VALUE);
         ArrayInitialize(SD2Pos, EMPTY_VALUE);
         ArrayInitialize(SD2Neg, EMPTY_VALUE);
         ArrayInitialize(SD3Pos, EMPTY_VALUE);
         ArrayInitialize(SD3Neg, EMPTY_VALUE);   
}  
  
  
  
  

//+------------------------------------------------------------------+
//| Handler of a chart event                                         |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{


   int n;
   
   if (StringSubstr(sparam,0,9)!="Rectangle" && StringSubstr(sparam,0,13)!="MS_Rectangle_" ) return;
   
   /*
      ArrayInitialize(PVP, EMPTY_VALUE);
      ArrayInitialize(VWAP, EMPTY_VALUE);
      ArrayInitialize(SD1Pos, EMPTY_VALUE);
      ArrayInitialize(SD1Neg, EMPTY_VALUE);
      ArrayInitialize(SD2Pos, EMPTY_VALUE);
      ArrayInitialize(SD2Neg, EMPTY_VALUE);
      ArrayInitialize(SD3Pos, EMPTY_VALUE);
      ArrayInitialize(SD3Neg, EMPTY_VALUE); 
   
   */
   
   string rectangleName=sparam;
//--- check the event of clicking the chart object
   if(id==CHARTEVENT_OBJECT_DELETE)
   {
      ObDeleteObjectsByPrefix(label+"VolumeHistogram"+"_"+rectangleName+"_");
      
   }
   else if(id==CHARTEVENT_OBJECT_CREATE || id==CHARTEVENT_OBJECT_DRAG)
   {
      //--- find the changed object
      if(ObjectFind(0,rectangleName)>-1)
      {      
      	
      	datetime rectangleStartTime=(datetime)ObjectGetInteger(0,rectangleName,OBJPROP_TIME1);
      	datetime rectangleEndTime=(datetime)ObjectGetInteger(0,rectangleName,OBJPROP_TIME2);
      	if (rectangleStartTime>rectangleEndTime){
      	   datetime tmpDate=rectangleStartTime;
      	   rectangleStartTime = rectangleEndTime;
      	   rectangleEndTime = tmpDate;
      	}
      	int rectangleStartBarIndex= iBarShift(NULL,0,rectangleStartTime);
      	int rectangleEndBarIndex= iBarShift(NULL,0,rectangleEndTime);
      	int rectangleWidth = rectangleStartBarIndex - rectangleEndBarIndex + 1;
         double max = High[iHighest( NULL , 0, MODE_HIGH, rectangleWidth, rectangleEndBarIndex)];
         double min =  Low[ iLowest( NULL , 0, MODE_LOW,  rectangleWidth, rectangleEndBarIndex)];
      	
      	
      	ObjectSetDouble(0,rectangleName, OBJPROP_PRICE1, max);
      	ObjectSetDouble(0,rectangleName, OBJPROP_PRICE2, min);
      	ObjectSetInteger(0,rectangleName, OBJPROP_STYLE, 2);         
      	ObjectSetInteger(0,rectangleName, OBJPROP_COLOR, RectangleColor );
      	ObjectSetInteger(0,rectangleName, OBJPROP_BACK, FillRectangle);       
	
      	
      items = MathRound((max - min) / Point);

      ArrayResize(Hist, items);
      ArrayInitialize(Hist, 0);
      double TotalVolume=0;
      double TotalPV=0;
      for (int i = rectangleStartBarIndex; i >= rectangleEndBarIndex; i--)
      {         

         double t1 = Low[i], t2 = Open[i], t3 = Close[i], t4 = High[i];
         if (t2 > t3) {t3 = Open[i]; t2 = Close[i];}
         double totalRange = (t4 - t1);         
         if (totalRange != 0.0)
         {
            for (double Price_i = t1; Price_i <= t4; Price_i += Point)
            {
               n = MathRound((Price_i - min) / Point);
               Hist[n] += MathRound(Volume[i]/totalRange);
            }//for
         }else
         {
            // Check if all values are equal to each other
            n = MathRound((t3 - min) / Point);
            Hist[n] += Volume[i];                     
         }//if


        // use H+L+C/3 as average price
         TotalPV+=Volume[i]*((Low[i]+High[i]+Close[i])/3);
         TotalVolume+=Volume[i];                          
      
         if (i==rectangleStartBarIndex) PVP[i]=Close[i];        
         else PVP[i]=min+ArrayMaximum(Hist)*Point;

         if (i==rectangleStartBarIndex) VWAP[i]=Close[i];        
         else{ 
            if (TotalVolume!=0) VWAP[i]=TotalPV/TotalVolume;
         }
 

         SD=0;         
         for (int k = rectangleStartBarIndex; k >= i; k--)
         {
            double avg=(High[k]+Close[k]+Low[k])/3;
            double diff=avg-VWAP[i];
            if (TotalVolume!=0) SD+=(Volume[k]/TotalVolume)*(diff*diff); 
          }
          SD=MathSqrt(SD);
          SD1Pos[i]=VWAP[i]+SD;
          SD1Neg[i]=VWAP[i]-SD;
          SD2Pos[i]=SD1Pos[i]+SD;
          SD2Neg[i]=SD1Neg[i]-SD;
          SD3Pos[i]=SD2Pos[i]+SD;
          SD3Neg[i]=SD2Neg[i]-SD;


      
      }//for BARS BACK
      
        
         
         int POCIndex = ArrayMaximum(Hist);
         int MaxVolume = Hist[POCIndex];      


         double tmpHistVal = 0;
         int histogramWidth=rectangleWidth/2;
         string Histogram_Prefix=label+"VolumeHistogram"+"_"+rectangleName+"_";
         ObDeleteObjectsByPrefix(Histogram_Prefix);
      
         if (Show_Histogram){         
         
            for (i = 0; i <= items; i++){         
               if (MaxVolume != 0) tmpHistVal = MathRound(histogramWidth * Hist[i] / MaxVolume );
            
               if (tmpHistVal > 0){
                  
                  //datetime histRowTime_i = rectangleStartTime+tmpHistVal*PeriodSeconds();
                  datetime histRowTime_i = Time[rectangleStartBarIndex-(int)tmpHistVal];
                  
                  ObjectCreate(Histogram_Prefix+i, OBJ_RECTANGLE, 0, rectangleStartTime, min + i*Point, histRowTime_i, min + (i+1)*Point);
                  ObjectSet(Histogram_Prefix+i, OBJPROP_STYLE, DRAW_HISTOGRAM);
                     
                  int aR = 0;   int aG = 0; int aB=255;  // RGB for our 1st color (blue in this case).
                  int bR = 255; int bG = 0; int bB=0;    // RGB for our 2nd color (red in this case).                                                  
                  float histValueFloat = tmpHistVal / histogramWidth;
                  int red   = int(MathRound((bR - aR) * histValueFloat + aR));
                  int green   = int(MathRound((bG - aG) * histValueFloat + aG));
                  int blue   = int(MathRound((bB - aB) * histValueFloat + aB));                                        
                  color tmpColor = StringToColor(IntegerToString(red)+","+IntegerToString(green)+","+IntegerToString(blue));                                 
                     
                  ObjectSet(Histogram_Prefix+i, OBJPROP_COLOR, getHeatMapColor(histValueFloat));                                    
                  ObjectSet(Histogram_Prefix+i, OBJPROP_BACK, true);                                                   
                     
               } //if  
               
                  
            }//for HISTOGRAM
            
         }//ShowHistogram   
         
         
 
      	
      	           
      	
      }
   }
//--- re-draw property values
   ChartRedraw();
}
    
int start()
{
 

   return(0);
}







