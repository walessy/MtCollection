//+------------------------------------------------------------------+
//|                                                                  |
//|  R-Market-Profile v.1.6.2                                        |
//|  Copyright © 2009 Riccardo "Rich" Cap                            |
//|  email: richcap.rc@gmail.com                                     |
//|                                                                  |
//|                                                                  |
//|  This indicator draws  the major values of original Market       |
//|  Profile (Copyright CBOT) at the end of each bar as well as      |
//|  original profile shape divided in timezones.                    |
//|  Through this indicator you can see how the market profile       |
//|  develops through the day (or through another time lapse of your |
//|  choiche).                                                       |
//|  Also, you can force market profile rebuild upon volatility      |
//|  breakout (which often means that an activity of institutional   |
//|  operators is ongoing) or after a given range extension          |
//|  (meaning a trend is marked, i.e. institutionals ar at work)     |
//|                                                                  |
//|  Permission to use, copy, modify, and distribute this software   |
//|  for any purpose without fee is hereby granted, provided that    |
//|  this entire notice is included in all copies of any software    |
//|  which is or includes a copy or modification of this software    |
//|  and in all copies of the supporting documentation for such      |
//|  software.                                                       |
//|  THIS SOFTWARE IS BEING PROVIDED "AS IS", WITHOUT ANY EXPRESS    |
//|  OR IMPLIED WARRANTY.  IN PARTICULAR, NEITHER THE AUTHOR DOES    |
//|  NOT MAKE ANY REPRESENTATION OR WARRANTY OF ANY KIND CONCERNING  |
//|  THE MERCHANTABILITY OF THIS SOFTWARE OR ITS FITNESS FOR ANY     |
//|  PARTICULAR PURPOSE.                                             |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Riccardo -Rich- Cap"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Yellow
#property indicator_color2 Violet  
#property indicator_color3 Magenta    
#property indicator_color4 Aqua
#property indicator_color5 DarkTurquoise
#property indicator_color6 Coral
#property indicator_color7 Orange
#property indicator_color8 Black
          


//---- buffers
double Buffer1[];                         //  Fairest Price
double Buffer2[];                         //  Range low
double Buffer3[];                         //  Range High
double Buffer4[];                         //  Initial Balance low  
double Buffer5[];                         //  Initial Balance high
double Buffer6[];                         //  Value Area low
double Buffer7[];                         //  Value Area high
double Buffer8[];                         //  Number of bars since beginning of profile

//---- External parameters 

extern bool reset_each_day=true;          // If true, each profile is rebuilt each day from "initial_time"'s time of day    
extern int backward_bars=0;               // The indicator is drawn backard "*" bars, at least
extern datetime initial_time=D'1970.01.01 00:00'; // if backward_bars=0, draw indicator from initial_time, at least 
extern datetime final_time=D'1970.01.01 00:00';   // if backward_bars=0 and initial_time is right, draw indicator from initial_time to final_time 
extern int reset_bar=0;                   // The bar number above which the profile bust be rebuilt anyway (if > 0)
extern double point=0;                    // if point is 0 (zero) default Point variable is used, otherwise "point" is new point value (=pip) definition
extern double vol_ratio=0.0;              // Volatility ratio between ATR[1] and ATR[6] above which profile is rebuilt (if > 0.0)
extern double extension_ratio= 0.0;       // Extension range ratio (Extension/Initial Balance) above which profile is rebuilt
extern bool show_progressive_profile=false;// if true the major values of profile are written into buffers at the end of each bar 
extern bool show_profile_shape=true;      // if true the market profile is drawn in its original shape
extern double server_time_wrt_GMT=0.0;    // Server Time with respect to GWT. If 0.0, Greenwich (LSE) time is assumed. For NewYork (WS) put "-4.0"
extern color asia_zone=LightPink;
extern color europe_zone=Coral;
extern color america_zone=Gold;
extern int initial_balance_bars=0;        // Number of bars to calculate Initial Balance on (if 0 it is the equivalent of 1 hour)

//---- Internal variables and arrays

int indicator_ID;                         // Init
bool initialized=false;                   // Init
color value_area_color=Red;
color initial_balance_color=Blue;
double high_val, low_val, range;          // Actual Market Profile price high, low and range
int range_pips;                           // Actual Market Profile range in pips
int price_vector [1];                     // Array for storing current Market Profile TPO count
double profile_analysis[10];              // Array for storing actual Market Profile analysis
int barCounter=0;                         // Bar number in current Market Profile
int final_bar=0;
int minute_start_of_day=0;                // Minute of day beginning
int debug_level=0;                        // Debug level
static datetime prevtime=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   
   //---- indicators
   IndicatorDigits(Digits+2);
   SetIndexStyle(0,DRAW_LINE, EMPTY, 2);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexStyle(6,DRAW_LINE);
   SetIndexStyle(7,DRAW_NONE);
   
   SetIndexDrawBegin(0,0);
   SetIndexDrawBegin(1,0);
   SetIndexDrawBegin(2,0);
   SetIndexDrawBegin(3,0);
   SetIndexDrawBegin(4,0);
   SetIndexDrawBegin(5,0);
   SetIndexDrawBegin(6,0);
   
   SetIndexBuffer(0,Buffer1);
   SetIndexBuffer(1,Buffer2);
   SetIndexBuffer(2,Buffer3);
   SetIndexBuffer(3,Buffer4);
   SetIndexBuffer(4,Buffer5);
   SetIndexBuffer(5,Buffer6);
   SetIndexBuffer(6,Buffer7);
   SetIndexBuffer(7,Buffer8);
   
   SetIndexLabel(0,"Fairest Price");
   SetIndexLabel(1,"Range low");
   SetIndexLabel(2,"Range high");
   SetIndexLabel(3,"Initial Balance low");
   SetIndexLabel(4,"Initial Balance high");
   SetIndexLabel(5,"Value Area low");
   SetIndexLabel(6,"Value Area high");
   
   Print("Version 1.6.2");
    
   return(0);
   
  }
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   if (show_profile_shape)
   {  
     clear_chart();
   } 
   ObjectDelete("R-Profile-placeholder-"+indicator_ID);
   return(0);
  }
  
bool initialization()
  {   
   
   // set indicator ID to properly manage graphic objects
   indicator_ID=1;      
   while ( ObjectFind("R-Profile-placeholder-"+indicator_ID) > -1)
   {   
      if (debug_level>2) Print ("Found ",indicator_ID," indicator(s)");
      indicator_ID++;
      if (indicator_ID > 9)
      {   
         Print("initialization not possible, too many indicators of same type");
         return (false);
      }
   }
   ObjectCreate("R-Profile-placeholder-"+indicator_ID, OBJ_ARROW,0, Time[Bars-1], 0); 
   
   
   // picks  minute of day from initial_time, rounded  respect to period()
   minute_start_of_day=(60*TimeHour(initial_time)+(TimeMinute(initial_time)))/Period()*Period();
   
   // sets minimum number of initial bars and, eventually, final bar  
   if (backward_bars==0)
   {
      if (initial_time == D'1970.01.01 00:00')
      {  
         string cYear=DoubleToStr(TimeYear(TimeCurrent()),0);
         string cMonth=DoubleToStr(TimeMonth(TimeCurrent()),0);
         string cDay=DoubleToStr(TimeDay(TimeCurrent()),0);  
         initial_time = StrToTime(StringConcatenate(cYear,".",cMonth,".",cDay," 00:00"));
         if (debug_level>0) Print ("Very beginning of day :",TimeToStr(initial_time));        
      } 
      
      {  
         backward_bars=iBarShift(NULL,0,initial_time, true); 
         if (final_time != D'1970.01.01 00:00')
         final_bar=iBarShift(NULL,0,final_time, true);
         
         while (backward_bars==-1)
         {
            initial_time+=60*Period();
            if (debug_level > 0) Print ("Initial time not valid, skip to next:",TimeToStr(initial_time));
            backward_bars=iBarShift(NULL,0,initial_time, true);          
         }
      }     
   }   
   initial_time=Time[backward_bars];
   if (debug_level > 0) Print("shift number for open time ",TimeToStr(initial_time)," is ",backward_bars," - Minute of day:", minute_start_of_day);
   
   
   // Some controls on external parameters
   if (initial_balance_bars==0)
   {  
     initial_balance_bars = 60/Period(); 
     if (initial_balance_bars==0) initial_balance_bars=1;   // for timeframes above H1, initial balance is 1 if not specified            
   } 
   if (vol_ratio==0.0) vol_ratio=1000.0;                // not enabled
   if (extension_ratio==0.0) extension_ratio=1000.0;    // not enabled
   if (point==0.0 || point < Point) point=Point;
   
   if (show_profile_shape)
   {  
     clear_chart();
   } 
   
   
   //----
   
   
   initialized=true;
   return (true);
  }
  
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{ 
   int i, j, counted_bars=IndicatorCounted();
   static int last_adj_bar=-1;   // Profile is built starting from last price major adjustment (caused by time, volatility or range extension)

   if (!initialized) 
    {
      if (debug_level>1) Print("Still initializing");
      if (!initialization()) 
         return (-1);
    }   

   if(!newPeriodOpening())
   {
      if (debug_level > 1) Print("Not the beginning of a new period");
      return(0);  // Not the beginning of a new period, skip 
   } 

  
   if(Bars<=backward_bars)
   {
      Print("Too many Bars backwards, please stay under ",Bars," Bars");
      return(0);
   }   
   
   i=MathMax(backward_bars,1);      
   if (counted_bars>Bars-backward_bars-1)                
      i=Bars-counted_bars-1;
 
   while(i>=MathMax(1,final_bar))
   {  
      last_adj_bar = evaluate_adj_bar(i, last_adj_bar); 
      build_profile(i,last_adj_bar);
      analyze_profile(i,last_adj_bar, profile_analysis);
      
      if (show_progressive_profile)
      {
         Buffer1[i]= profile_analysis[0];
         Buffer2[i]= low_val;
         Buffer3[i]= high_val;
         Buffer4[i]= profile_analysis[1];
         Buffer5[i]= profile_analysis[2];
         Buffer6[i]= profile_analysis[3];
         Buffer7[i]= profile_analysis[4];
         Buffer8[i]= last_adj_bar;
      } 
     
      if (show_profile_shape)
      {
         draw_graphics(i,last_adj_bar);
      } 

      if ( i==1 && !IsTesting()) draw_lastshift_placeholders();
      
      barCounter++;
      i--;
   }
   return(0);
}
  
  
bool build_profile (int shift, int last_adj_bar)
{

      
      double price_level;   
      int price_index, spanBars;

      if (debug_level > 3) Print ("Time:", TimeToStr(Time[shift])," - shift:",shift," - last_adj_bar:", last_adj_bar);
   
      spanBars = last_adj_bar - shift;    
      high_val=High[iHighest(NULL,0,MODE_HIGH,spanBars+1,shift)];
      low_val=Low[iLowest(NULL,0,MODE_LOW,spanBars+1,shift)];
      double rounded_low_val = low_val - MathMod(low_val, point);
      if (debug_level > 3) Print ( "low_val, rounded_low_val: ",DoubleToStr(low_val,Digits+2),",", DoubleToStr(rounded_low_val,Digits+2));
      low_val=rounded_low_val;
      range = high_val - low_val;
      range_pips = MathRound(range / point )+1; 
      ArrayResize(price_vector,range_pips+1);
      ArrayInitialize(price_vector,0);
         
      price_index=0;
      for (price_level = low_val; price_level <= high_val; price_level += point)
      {
         int count=0;
         for ( int i = 0; i <= spanBars; i++)
         {
            if ( (High[shift+i] >= price_level && Low[shift+i] <= price_level) )
            count++;
         }
         if (debug_level > 3) Print (" Price[",price_index,"] = ", count);
         price_vector[price_index]=count;
         price_index++;
      }
      if (debug_level > 3) Print (price_index, " levels of price");
      return (true);
}


bool analyze_profile (int shift, int last_adj_bar, double& profile_analysis[])
{
      // Calculate Fairest Price. It is important to find price value with max number of occurrences
      // in the middle of Range (High - Low). Default algorythm ArrayMaximum() only finds first "maximum" element 
      // so we must search for a maximum closer to the center of the array
      int    fairPriceIdx=ArrayMaximum(price_vector);
      for (int i = 0; i < range_pips/2 - fairPriceIdx; i++)
      { 
         // above the center
         int idx = range_pips/2 + i;
         if (price_vector[idx] == price_vector[fairPriceIdx])
               fairPriceIdx = idx;
         
         // below the center
         idx = range_pips/2 - i;
         if (price_vector[idx] == price_vector[fairPriceIdx])
               fairPriceIdx = idx;
      }
      profile_analysis[0]= low_val+(fairPriceIdx)*point;    // fairest_price
       
      // calculate Initial Balance
      if (barCounter < initial_balance_bars)
      { 
          profile_analysis[1]=low_val;    // Initial Balance low
          profile_analysis[2]=high_val;   // Initial Balance high
      }
      
      // calculate Value Area
      
      // First count TPO's...
      int total_area_tpos=0, tpo_up=0, tpo_dn=0;
      for (i =0; i < range_pips; i++)
         total_area_tpos+=price_vector[i];
      // ...then find 70% of TPO's starting from fairest price
      int value_area_tpos = (total_area_tpos*70)/100;
      int idxUp = fairPriceIdx;
      int idxDn = idxUp;
      int count=0;
      int value_area_prog = price_vector[idxUp]; //initial value
      while (value_area_prog < value_area_tpos && count < range_pips+1)
      { 
         if (idxUp < range_pips-1) int ext_tpo_up = price_vector[idxUp+1];
         else ext_tpo_up=0;
         
         if (idxDn > 0) int ext_tpo_dn = price_vector[idxDn-1];
         else ext_tpo_dn=0;
         if ( ext_tpo_up > ext_tpo_dn )   // more TPOs up
         { 
            idxUp++;
            value_area_prog+=ext_tpo_up;
            tpo_up+=ext_tpo_up;
         }
         else if ( ext_tpo_up < ext_tpo_dn ) // more TPOs down
         { 
            idxDn--;
            value_area_prog+=ext_tpo_dn;
            tpo_dn+=ext_tpo_dn;
         }
         else if ( ext_tpo_up + ext_tpo_dn > 0 ) // seems like we don't know where to go both directions
         { 
            idxUp++;
            value_area_prog+=ext_tpo_up;
            tpo_up+=ext_tpo_up;
            idxDn--;
            value_area_prog+=ext_tpo_dn;
            tpo_dn+=ext_tpo_dn;
         }
         else                                   // seems like there is a gap, skip it
         { 
            if (idxUp < range_pips-1) idxUp++;  //  there are more price levels up
            else if (idxDn > 0) idxDn--;        //  there are more price levels down
            //else return (0);                    //  there are no more levels, if value_area_prog < value_area_tpos something went wrong
         }
         count++;
         if (debug_level > 3) Print ("idx dn =", idxDn, " - idx up =", idxUp);
      }
      profile_analysis[3]=low_val+idxDn*point;     // Value Area low
      profile_analysis[4]=low_val+idxUp*point;     // Value Area high
      profile_analysis[7]=tpo_dn;     // Total TPO in Value Area below Fairest price
      profile_analysis[8]=tpo_up;     // Total TPO in Value Area above Fairest price
      
      // calculate range extension up an down
      profile_analysis[5]=profile_analysis[1]-low_val;         // Range Extension Down
      profile_analysis[6]=high_val - profile_analysis[2];      // Range Extension Up
      
      if (debug_level > 3)
      {  Print("-----------------------Market Profile-------------------------------");
         Print("Range low = ", DoubleToStr(low_val,6), " - Range high = ", DoubleToStr(high_val,6), " - Range pips = ", range_pips);
         Print("Total TPO = ", total_area_tpos, " - Value Area prog = ", value_area_prog);
         Print("Fairest Price Idx = ", fairPriceIdx, " - Value Area down idx = ", idxDn, " - Value Area up idx = ", idxUp);
         Print("Fairest Price = ", DoubleToStr(profile_analysis[0],6)); 
         Print("Initial Balance low = ", DoubleToStr(profile_analysis[1],6), " - Initial Balance high = ", DoubleToStr(profile_analysis[2],6));
         Print("Value Area low = ", DoubleToStr(profile_analysis[3],6), " - Value Area high = ", DoubleToStr(profile_analysis[4],6));
         Print("Extension down = ", DoubleToStr(profile_analysis[5],6), " - Extension up = ", DoubleToStr(profile_analysis[6],6));
         Print("--------------------------------------------------------------------");
      }

      return (true);
}

  
int evaluate_adj_bar(int shift, int last_adj_bar)
{
   static bool first_time=true;
   // if this was the last bar, increase counter last_adj_bar skipping first time
   if (shift == 1 && !first_time) 
      last_adj_bar++; 
   else if (shift == 1 && first_time) 
      first_time=false;
     
   // change profile if 'reset_each_day' flag is true and a new day has come
   int minute_of_day=60*TimeHour(Time[shift])+TimeMinute(Time[shift]);
   int previous_minute_of_day=60*TimeHour(Time[shift+1])+TimeMinute(Time[shift+1]);
   if (TimeDayOfYear(Time[shift])>TimeDayOfYear(Time[shift+1]) || TimeYear(Time[shift])!=TimeYear(Time[shift+1])) previous_minute_of_day-=1440;
   if (debug_level > 0) Print("Minute of actual shift: ",minute_of_day," - and of previous shift: ", previous_minute_of_day, "  - (1440-Period): ", 1440 - Period());
   if (reset_each_day && 
       Time[shift] != initial_time && 
       ( minute_of_day >= minute_start_of_day  && previous_minute_of_day < minute_start_of_day )  )
   {
      int shiftbars = 1440 / Period();
      last_adj_bar = last_adj_bar - MathMin(barCounter,shiftbars);
      if (debug_level > 0) Print("Decrease by ",MathMin(barCounter,shiftbars)," - barcounter:",barCounter," - shiftbars:",shiftbars);
      if (debug_level > 0) Print("Reset for changed day - Period at:", barCounter," - last_adj_bar = ", last_adj_bar," - decreased by ",  PERIOD_D1/Period());
      barCounter=0;
   }
   
   
   // change profile if max reset_bar is reached
   if (barCounter == reset_bar && reset_bar > 0)
   {
      last_adj_bar = last_adj_bar - reset_bar; 
      if (debug_level > 1) Print("Reset for reached maximum bar at:", barCounter," - last_adj_bar = ", last_adj_bar );
      barCounter=0;
   }
   
   // change profile if a Volatility Break Out occurs
   if ( iATR(NULL,0,1,shift) > vol_ratio*iATR(NULL,0,60,shift+1) ) 
   {
      last_adj_bar =0;
      if (debug_level > 1)
      {
         Print("Reset for volatility breakout at:", barCounter," - last_adj_bar = ", last_adj_bar);
         Print("Volatility Breakout:", DoubleToStr(iATR(NULL,0,1,shift)/iATR(NULL,0,60,shift+1),2));
      }
   
      barCounter=0;
   }
     
   // change profile if an extension is wider than extension_ratio * Initial Balance
   double initial_balance = profile_analysis[2] - profile_analysis[1];
   double extension_down = profile_analysis[5];
   double extension_up = profile_analysis[6];
   if (extension_down > extension_ratio * initial_balance || extension_up > extension_ratio * initial_balance)
   {
      last_adj_bar =0;
      if (debug_level > 1)
      {
         Print("Reset for maximum Range Extension at:", barCounter," - last_adj_bar = ", last_adj_bar);
         if (extension_down > extension_up)
            Print("Range Extension Down:", DoubleToStr(extension_down,2));
         else
            Print("Range Extension Up:", DoubleToStr(extension_up,2));
      }  
      barCounter=0;
   }
   
   // anyway, last_adj_bar cannot be less than shift
   last_adj_bar = MathMax(last_adj_bar,shift);

   return(last_adj_bar);
}


    
void draw_graphics(int shift, int last_adj_bar)
{
   double price_level, rounded_low;
   int tpo_color;
   
   if (debug_level > 3) 
   {
      Print("---<draw_graphics>----");
   }
   
   // draw profile
   rounded_low= Low[shift] - MathMod(Low[shift], point);
   for (price_level = rounded_low; price_level<= High[shift]-point; price_level += point)
   {
 
      for (int bar=last_adj_bar; bar >= shift;  bar--)
      {
         
        // set color
        if ( TimeHour(Time[shift])>=(14+server_time_wrt_GMT) && TimeHour(Time[shift])<(22+server_time_wrt_GMT) ) 
           tpo_color=america_zone; 
        else if ( TimeHour(Time[shift])>=(6+server_time_wrt_GMT) && TimeHour(Time[shift])<(14+server_time_wrt_GMT)) 
           tpo_color=europe_zone; 
        else 
           tpo_color=asia_zone;    
           
        if (shift==0) 
        {
          // the case of shift=0 must be addressed!!
          tpo_color=Lime;
        }  
        
        if (debug_level > 3) Print ("Price level to search for graphical object",DoubleToStr(price_level,Digits), " - bar:",bar );
        
        if( ObjectFind("R-Profile-"+indicator_ID+"_"+TimeToStr(Time[bar],TIME_DATE)+"_"+TimeToStr(Time[bar],TIME_MINUTES)+"-"+DoubleToStr(price_level,Digits) )== -1 ) 
        {
            ObjectCreate("R-Profile-"+indicator_ID+"_"+TimeToStr(Time[bar],TIME_DATE)+"_"+TimeToStr(Time[bar],TIME_MINUTES)+"-"+DoubleToStr(price_level,Digits), OBJ_RECTANGLE, 0, Time[bar], price_level,Time[bar-1],price_level+point);
            ObjectSet("R-Profile-"+indicator_ID+"_"+TimeToStr(Time[bar],TIME_DATE)+"_"+TimeToStr(Time[bar],TIME_MINUTES)+"-"+DoubleToStr(price_level,Digits), OBJPROP_COLOR, tpo_color);   
            break;        
        }  
        
      }
   }  
   
   // draw Initial Balance
   ObjectDelete("R-Profile-"+indicator_ID+"_InitialBalance"+TimeToStr(Time[last_adj_bar],TIME_DATE)+"_"+TimeToStr(Time[last_adj_bar],TIME_MINUTES));
   ObjectCreate("R-Profile-"+indicator_ID+"_InitialBalance"+TimeToStr(Time[last_adj_bar],TIME_DATE)+"_"+TimeToStr(Time[last_adj_bar],TIME_MINUTES), OBJ_RECTANGLE, 0, Time[last_adj_bar+3], profile_analysis[1],Time[last_adj_bar+2],profile_analysis[2]);
   ObjectSet("R-Profile-"+indicator_ID+"_InitialBalance"+TimeToStr(Time[last_adj_bar],TIME_DATE)+"_"+TimeToStr(Time[last_adj_bar],TIME_MINUTES), OBJPROP_COLOR, initial_balance_color);   

   // draw Value Area
   ObjectDelete("R-Profile-"+indicator_ID+"_ValueArea"+TimeToStr(Time[last_adj_bar],TIME_DATE)+"_"+TimeToStr(Time[last_adj_bar],TIME_MINUTES));
   ObjectCreate("R-Profile-"+indicator_ID+"_ValueArea"+TimeToStr(Time[last_adj_bar],TIME_DATE)+"_"+TimeToStr(Time[last_adj_bar],TIME_MINUTES), OBJ_RECTANGLE, 0, Time[last_adj_bar+2], profile_analysis[3],Time[last_adj_bar+1],profile_analysis[4]);
   ObjectSet("R-Profile-"+indicator_ID+"_ValueArea"+TimeToStr(Time[last_adj_bar],TIME_DATE)+"_"+TimeToStr(Time[last_adj_bar],TIME_MINUTES), OBJPROP_COLOR, value_area_color);   
   
   // draw Fairest Price arrow
   ObjectDelete("R-Profile-"+indicator_ID+"_FairestValue"+TimeToStr(Time[last_adj_bar],TIME_DATE)+"_"+TimeToStr(Time[last_adj_bar],TIME_MINUTES));
   ObjectCreate("R-Profile-"+indicator_ID+"_FairestValue"+TimeToStr(Time[last_adj_bar],TIME_DATE)+"_"+TimeToStr(Time[last_adj_bar],TIME_MINUTES), OBJ_ARROW,0, Time[last_adj_bar], profile_analysis[0]);
   ObjectSet("R-Profile-"+indicator_ID+"_FairestValue"+TimeToStr(Time[last_adj_bar],TIME_DATE)+"_"+TimeToStr(Time[last_adj_bar],TIME_MINUTES), OBJPROP_STYLE, STYLE_DOT);
   ObjectSet("R-Profile-"+indicator_ID+"_FairestValue"+TimeToStr(Time[last_adj_bar],TIME_DATE)+"_"+TimeToStr(Time[last_adj_bar],TIME_MINUTES), OBJPROP_ARROWCODE, 5);
   ObjectSet("R-Profile-"+indicator_ID+"_FairestValue"+TimeToStr(Time[last_adj_bar],TIME_DATE)+"_"+TimeToStr(Time[last_adj_bar],TIME_MINUTES), OBJPROP_COLOR, LightBlue);
   
   if (debug_level > 3) 
   {
      Print("Shift:",shift," - last_adj_bar:",last_adj_bar,"- VA High:",profile_analysis[4]," - VA low",profile_analysis[3]);
      Print("Shift:",shift," - Low:",Low[shift],"- High:",High[shift]);
      Print("---</draw_graphics>----");
   }

}


void draw_lastshift_placeholders()
{
   
   ObjectDelete("R-Profile-"+indicator_ID+"_POC");
   ObjectCreate("R-Profile-"+indicator_ID+"_POC", OBJ_RECTANGLE, 0, Time[1], profile_analysis[0],Time[0],profile_analysis[0]+point/4);
   ObjectSet("R-Profile-"+indicator_ID+"_POC", OBJPROP_COLOR, indicator_color1);   
   
   ObjectDelete("R-Profile-"+indicator_ID+"_RangeLow");
   ObjectCreate("R-Profile-"+indicator_ID+"_RangeLow", OBJ_RECTANGLE, 0, Time[1], low_val,Time[0],low_val+point/4);
   ObjectSet("R-Profile-"+indicator_ID+"_RangeLow", OBJPROP_COLOR, indicator_color2);   
   
   ObjectDelete("R-Profile-"+indicator_ID+"_RangeHigh");
   ObjectCreate("R-Profile-"+indicator_ID+"_RangeHigh", OBJ_RECTANGLE, 0, Time[1], high_val,Time[0],high_val+point/4);
   ObjectSet("R-Profile-"+indicator_ID+"_RangeHigh", OBJPROP_COLOR, indicator_color3);   
  
   ObjectDelete("R-Profile-"+indicator_ID+"_InitialBalanceLow");
   ObjectCreate("R-Profile-"+indicator_ID+"_InitialBalanceLow", OBJ_RECTANGLE, 0, Time[1], profile_analysis[1],Time[0],profile_analysis[1]+point/4);
   ObjectSet("R-Profile-"+indicator_ID+"_InitialBalanceLow", OBJPROP_COLOR, indicator_color4);   
   
   ObjectDelete("R-Profile-"+indicator_ID+"_InitialBalanceHigh");
   ObjectCreate("R-Profile-"+indicator_ID+"_InitialBalanceHigh", OBJ_RECTANGLE, 0, Time[1], profile_analysis[2],Time[0],profile_analysis[2]+point/4);
   ObjectSet("R-Profile-"+indicator_ID+"_InitialBalanceHigh", OBJPROP_COLOR, indicator_color5);   
    
   ObjectDelete("R-Profile-"+indicator_ID+"_ValueAreaLow");
   ObjectCreate("R-Profile-"+indicator_ID+"_ValueAreaLow", OBJ_RECTANGLE, 0, Time[1], profile_analysis[3],Time[0],profile_analysis[3]+point/4);
   ObjectSet("R-Profile-"+indicator_ID+"_ValueAreaLow", OBJPROP_COLOR, indicator_color6);   
   
   ObjectDelete("R-Profile-"+indicator_ID+"_ValueAreaHigh");
   ObjectCreate("R-Profile-"+indicator_ID+"_ValueAreaHigh", OBJ_RECTANGLE, 0, Time[1], profile_analysis[4],Time[0],profile_analysis[4]+point/4);
   ObjectSet("R-Profile-"+indicator_ID+"_ValueAreaHigh", OBJPROP_COLOR, indicator_color7);   
   
   
}
   

bool clear_chart()
{

     string obj_name, obj_name_substr;
     int  obj_total=ObjectsTotal();
     while (obj_total > 0)
     {
         int other_objects=0;
         for(int i=obj_total-1; i>=0; i--)
         {
            obj_name=ObjectName(i);
            obj_name_substr=StringSubstr(obj_name, 0, 12);
            if (obj_name_substr == "R-Profile-"+indicator_ID+"_") 
               ObjectDelete(obj_name);
            else
               other_objects++;   
         }
         obj_total=ObjectsTotal();
         if (debug_level > 1) Print ("Other objects:",other_objects," - Object total:",obj_total );
         if (obj_total == other_objects) break;
         
     }
     return (true);
}
  
  
  
bool newPeriodOpening()
{
   if(prevtime == Time[0]) return(false);
   prevtime = Time[0];
   return(true);
}
  
   
//-------------------------------------------------------------------+