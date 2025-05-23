//+------------------------------------------------------------------+
//|                                             ay-MarketProfile.mq4 |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, ahmad.yani@hotmail.com"
#property link      "ahmad.yani@hotmail.com"

#property indicator_chart_window
/*
v1.1        cleaning the code
            add ShowOpenCloseArrow
            add VATPOPercent
v1.2        use 1 pip for pricing step and tpo calculating      
v1.3        add Volume Profile feature
v1.31       add DayStartHour, ShowPriceHistogram, ShowValueArea, ShowVAHVALLines            
v1.31.rev1  add Ticksize, VolAmplitudePercent
            bug fix : 
            - Profile High and Low misscalculated when high or low of the day 
              occured at first m30 candle.
            - Open and Close Arrow Location
            - profile missing when DayStartHour not exist on the chart 
              like Hour 0 not exist on some days on #YMH1 chart (fxpro);
              
*/

#define PRICEIDX        0
#define TPOIDX          1
#define VOLIDX          2

//---extern vars
extern int        LookBack                = 6;
extern bool       UseVolumeProfile        = true;
extern string     ProfileTimeframeInfo    = "use D, W, or M";
extern string     ProfileTimeframe        = "D";
extern int        DayStartHour            = 0;
extern double     VATPOPercent            = 70.0;
extern int        TickSize                = 1;
extern int        ExtendedPocLines        = 5;

extern string     spr0                    = "on/off settings..";
extern bool       ShowPriceHistogram      = true;
extern bool       ShowValueArea           = true;
extern bool       ShowVAHVALLines         = true;
extern bool       ShowOpenCloseArrow      = true;
extern bool       ShowTrendlines          = true;
extern bool       ShowHiLoTrendlines      = true;     


extern string     spr1                    = "design & colors..";
extern double     VolAmplitudePercent     = 40.0;
extern int        HistoHeight             = 2;
extern color      HistoColor1             = C'55,100,135';
extern color      HistoColor2             = C'45,90,125';
extern color      OpenColor               = clrDarkGreen;
extern color      CloseColor              = clrPeru;
extern color      POCColor                = clrPeru;
extern color      VirginPOCColor          = clrYellow;
extern color      VAColor                 = C'16,16,16';
extern color      VALinesColor            = C'64,64,64';
extern color      InfoColor               = clrLime;
extern color      trendcolor              = clrSilver;

extern string     spr2                    = "Profile Data.............";
extern int        DailyProfileDataTf      = 30;
extern int        WeeklyProfileDataTf     = 60;
extern int        MonthlyProfileDataTf    = 240;
int               iclr; 
//---global vars
string            gsPref                  = "ay.mp.";
double            dstep;
double            fpoint
                , gdOneTick
                , gdHistoRange;
int               fdigits
                , giStep
                , giProfileTf             = PERIOD_D1
                , giDataTf                = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{       
      
   giDataTf = Period(); //default
   
   if (Point == 0.001 || Point == 0.00001) 
   { fpoint = Point*10; fdigits = Digits - 1; }
   else 
   { fpoint = Point; fdigits = Digits; }     
      
   
   if (ProfileTimeframe == "M" )   
   {
      gsPref      = gsPref + "2.0." + ProfileTimeframe + "."; 
      giProfileTf = PERIOD_MN1;     
      HistoHeight = MathMax(HistoHeight, 8);
      giDataTf    = MonthlyProfileDataTf;
   }   
   else if (ProfileTimeframe == "W" )
   {
      gsPref      = gsPref + "3.0." + ProfileTimeframe + "."; 
      giProfileTf = PERIOD_W1;     
      HistoHeight = MathMax(HistoHeight, 3);
      giDataTf    = WeeklyProfileDataTf;

   }
   else //default D1
   {
      gsPref      = gsPref + "4.0." + ProfileTimeframe + "."; 
      giProfileTf = PERIOD_D1;
      HistoHeight = MathMax(HistoHeight, 1);
      giDataTf    = DailyProfileDataTf;
   }
   //----
   HistoHeight    = MathMax(HistoHeight, TickSize);
   gdOneTick      = TickSize/(MathPow(10,fdigits));
   gdHistoRange   = HistoHeight/(MathPow(10,fdigits)); 
   giStep         = HistoHeight;
   
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   delObjs();

   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
 
   if ( !isOK() ) return(0);
   
   LookBack = MathMin( LookBack, iBarShift(NULL, giProfileTf, Time[Bars-1]) - 1 );
   LookBack = MathMin( LookBack, iBarShift(NULL, giProfileTf, iTime(NULL, giDataTf, iBars(NULL, giDataTf) - 1)) );

   int ibarproftf = 0, endbarproftf = 0;   
       
   //---create all profile on startup/new tfsrc bar
   //---and then only update the last tfsrc profile
   
   if ( newBarProfileTf() ) { delObjs(); endbarproftf = LookBack-1; } 
   
   double     apricestep[][3];             // [ 3-->{price, count tpo, count vol} ]
   double   hh, ll                       // profile
            , maxvol
            , vah                          // Value Area High
            , val                          // Value Area Low
            , totaltpo                     // Total TPO
            , totalvol;                    // Total Vol
   //datetime   dtproftf;
   int        startbar                     // startbar on giDataTf
            , endbar                       // endbar on giDataTf
            , countps
            , vahidx
            , validx  
            , maxtpo
            , maxtpoidx
            , maxvolidx;   

            
    //---main loop --> day by day, week by week, month by month...         
   for (ibarproftf = endbarproftf; ibarproftf >= 0; ibarproftf--)      
   {
      
      ArrayResize(apricestep, 0);
      
      getStartAndEndBar(ibarproftf, startbar, endbar);          
      
      if (startbar == -1) continue;
                          
      getHHLL(startbar, endbar, hh, ll);
                             
      getPriceTPO 
         ( startbar, endbar, hh, ll, apricestep, countps, maxtpo, 
           maxtpoidx, totaltpo, maxvol, maxvolidx, totalvol );                         
      
      //continue;    
      drawPriceHistoAndPOCLines 
         ( startbar, endbar, ibarproftf, countps, apricestep, maxtpo, 
           maxtpoidx, maxvol, maxvolidx );
                              
      //continue;
      getValueArea 
         ( countps, apricestep, maxtpo, maxtpoidx, totaltpo, (int)maxvol, 
           maxvolidx, totalvol, vah, vahidx, val, validx );      
          
      //continue;
      drawValueArea 
         ( startbar, endbar, ibarproftf, countps, apricestep, vah, 
           vahidx, val, validx );
 
   }//end for (ibartf = endbartf; ibartf >= 0; ibartf--)    
   
   //update time ExtendedPocLines   
   if (newBar()) 
   {
      for (int i=1; i<=ExtendedPocLines; i++)
      {
         ObjectSet(gsPref + "#" + (string)i +".1.1.poc",       OBJPROP_TIME2, Time[0] + 10*Period()*60 );     
         ObjectSet(gsPref + "#" + (string)i +".1.0.poc.price", OBJPROP_TIME1, Time[0] + 13*Period()*60 );
      
      }   
   }
   
   drawInfo();

   
   //---delay 5 seconds      
   Sleep(5000);
   
   return(0);
   
}
//+------------------------------------------------------------------+
//| isOK                                                             |
//+------------------------------------------------------------------+
bool isOK()
{   
   switch (Period())
   {
      case PERIOD_M1:         
      case PERIOD_M5:         
      case PERIOD_M15:
         if (giProfileTf == PERIOD_D1) return(true);
         break;      
      case PERIOD_M30: 
         if (giProfileTf <= PERIOD_W1) return(true);
         break;          
      case PERIOD_H1:   
         return(true);
         break;            
      case PERIOD_H4:
      case PERIOD_D1:
         if (giProfileTf >= PERIOD_W1) return(true);
         break;
      default:
         return(false);               
         break;
   }          
   
   return(false);
}

//+------------------------------------------------------------------+
//| getStartAndEndBar                                                |
//+------------------------------------------------------------------+
void getStartAndEndBar(int ibarproftf, int &startbar, int &endbar)
{      
   
   int i, j;
   datetime dtproftf;     
   datetime dtproftfnext; 
   int oneday;
   int iday;  
   datetime dt;
   switch (giProfileTf)
   {
      case PERIOD_D1:
             oneday = PERIOD_D1*60;
             iday = -1;
         
         startbar = 0; endbar = 0;         
         
         if (DayStartHour == 0)
         {
           dtproftf       = iTime( NULL, giProfileTf, ibarproftf );
           dtproftfnext  = iTime( NULL, giProfileTf, ibarproftf - 1 );         
           startbar        = iBarShift ( NULL, giDataTf, dtproftf);
           endbar          = iBarShift ( NULL, giDataTf, dtproftfnext - (giDataTf * 60) );  
            
            //current day        
           if (dtproftfnext < dtproftf) endbar = 0;         
            // fix ibarshift on month\week start
           if ( iTime(NULL, giDataTf, startbar) < dtproftf ) startbar--; 
           
           if (TimeDayOfWeek(iTime( NULL, giDataTf, startbar )) == 0) startbar = -1;
                
           break;
         }         
         
         for (i=0; i<iBars(NULL, giDataTf); i++)
         {
            dt = iTime(NULL, giDataTf, i);
            if (TimeHour(dt) == DayStartHour && TimeMinute(dt) == 0 )
            {
               iday++;
               if (iday == ibarproftf) 
               {
                  startbar = i;         
                  if (ibarproftf !=0) 
                  {
                     endbar  = iBarShift( NULL, giDataTf, dt + oneday - (giDataTf * 60) );                
                     if ( iTime(NULL, giDataTf, endbar) < dt + oneday - (giDataTf * 60) ) 
                     {
                        endbar++;
                        for (j=endbar; j>=0; j--)
                        {
                           dt = iTime(NULL, giDataTf, j);
                           if (TimeHour(dt) == DayStartHour && TimeMinute(dt) == 0 )
                           {
                              endbar = j+1;
                              break;
                           }                            
                        }// end for j
                     }
                  }
                  else endbar = 0;
                  
                  break;
               }
            }
         }// end for i
         
         if (iday == -1) {startbar = -1; endbar = -1;}
                  
         break;
         
      default:
         dtproftf      = iTime( NULL, giProfileTf, ibarproftf );
         dtproftfnext = iTime( NULL, giProfileTf, ibarproftf - 1 );
         
         startbar  = iBarShift ( NULL, giDataTf, dtproftf);
         endbar    = iBarShift ( NULL, giDataTf, dtproftfnext - (giDataTf * 60) );
         //current week.Month         
         if (dtproftfnext < dtproftf) endbar = 0;         
         // fix ibarshift on month\week start
         if ( iTime(NULL, giDataTf, startbar) < dtproftf ) startbar--;    
                           
         break;
   }         
}
//+------------------------------------------------------------------+
//| getHHLL                                                          |
//+------------------------------------------------------------------+
void getHHLL(int startbar, int endbar, double &hh, double &ll)
{
   hh = iHigh ( NULL, giDataTf, iHighest(NULL, giDataTf, MODE_HIGH, (startbar - endbar)+1, endbar) );
   ll = iLow  ( NULL, giDataTf, iLowest (NULL, giDataTf, MODE_LOW,  (startbar - endbar)+1, endbar) );
   hh = NormalizeDouble(hh, fdigits);
   ll = NormalizeDouble(ll, fdigits);
    
    }

//+------------------------------------------------------------------+
//| drawInfo                                                         |
//+------------------------------------------------------------------+
void drawInfo()
{
   
   string info = "Volume Profile";
   if (!UseVolumeProfile) info = "TPO Profile";
   
   if (ObjectFind(gsPref+"lblinfo1") == -1)
    ObjectCreate (gsPref+"lblinfo1", OBJ_LABEL,0,0,0);
   
   ObjectSet    (gsPref+"lblinfo1", OBJPROP_CORNER, 3);
   ObjectSetText(gsPref+"lblinfo1", info, 8, "Tahoma", InfoColor);
   ObjectSet    (gsPref+"lblinfo1", OBJPROP_XDISTANCE, 10);
   ObjectSet    (gsPref+"lblinfo1", OBJPROP_YDISTANCE, 20);
   
   if (giProfileTf == PERIOD_D1)
   {
      if (ObjectFind(gsPref+"lblinfo2") == -1)      
        ObjectCreate (gsPref+"lblinfo2", OBJ_LABEL,0,0,0);
      
      ObjectSet    (gsPref+"lblinfo2", OBJPROP_CORNER, 3);
      ObjectSetText(gsPref+"lblinfo2", "DayStartHour: " + (string)DayStartHour, 8, "Tahoma", InfoColor);
      ObjectSet    (gsPref+"lblinfo2", OBJPROP_XDISTANCE, 10);
      ObjectSet    (gsPref+"lblinfo2", OBJPROP_YDISTANCE, 5);            
   }
   
   
}
//+------------------------------------------------------------------+
//| getPriceTPO                                                      |
//+------------------------------------------------------------------+
void getPriceTPO
(
     int       startbar
   , int       endbar
   , double    hh
   , double    ll
   , double    &apricestep[][3]
   , int       &countps
   , int       &maxtpo
   , int       &maxtpoidx
   , double    &totaltpo
   , double    &maxvol
   , int       &maxvolidx   
   , double    &totalvol
)
{

   maxtpo        = 0;
   maxtpoidx     = 0;
   totaltpo      = 0.0;
   maxvol        = 0.000001;
   maxvolidx     = 0; 
   totalvol      = 0.0;
   
   double     shh = hh; //start hh
   double     profilerange       = MathMax(hh - ll, gdOneTick)
            , midprofileprice   = hh - (0.5 * profilerange);   
            
   //--- populate price level     
   countps  = 0;          
   while (shh >= ll)
   {   
      ArrayResize(apricestep, countps+1);   
      apricestep [countps][PRICEIDX] = shh;
      apricestep [countps][TPOIDX]   = 0.0;
      apricestep [countps][VOLIDX]   = 0.0;
      
      shh -= gdOneTick;
      countps  ++;

   } // while (shh >= ll)   
   //--- end populate price level                
  
   //--- Counting tpo     
   int      i, j;
   double   pricestep;
   
   for (i=0; i<countps; i++)
   {
      pricestep = apricestep[i][PRICEIDX];
      j = startbar;
      while ( j >= endbar)
      {            
         double hp        = iHigh  (NULL, giDataTf, j);
         double lp        = iLow   (NULL, giDataTf, j);         
         double barvol   = (int)iVolume(NULL, giDataTf, j);
         double barrange = MathMax( (hp - lp) / fpoint, gdOneTick );
         double pipvol   = barvol / barrange;         
         
         if (  pricestep >= lp && pricestep <= hp )   
         {
            apricestep[i][TPOIDX] += 1;  
            apricestep[i][VOLIDX] += pipvol;
            totaltpo += 1; 
            totalvol += pipvol;
            // save maxtpo
            if (apricestep[i][TPOIDX] > maxtpo) 
            {
               maxtpo    = (int)apricestep[i][TPOIDX];
               maxtpoidx = i;               
            }
            
            if (apricestep[i][TPOIDX] == maxtpo) 
            {
               // take the closes to the middle of profile range
               if (   MathAbs(midprofileprice - apricestep[i][PRICEIDX]) 
                    < MathAbs(midprofileprice - apricestep[maxtpoidx][PRICEIDX]) 
                   )
               {
                  maxtpo    = (int)apricestep[i][TPOIDX];
                  maxtpoidx = i;
               }
            }
            // end save maxtpo
            
            // save maxvol
            if (apricestep[i][VOLIDX] > maxvol) 
            {
               maxvol    = apricestep[i][VOLIDX];
               maxvolidx = i;               
            }
            
            if (apricestep[i][VOLIDX] == maxvol) 
            {
               // take the closes to the middle of profile range
               if (   MathAbs(midprofileprice - apricestep[i][PRICEIDX]) 
                    < MathAbs(midprofileprice - apricestep[maxvolidx][PRICEIDX]) 
                   )
               {
                  maxvol    = apricestep[i][VOLIDX];
                  maxvolidx = i;
               }
            }
            // end save maxtpo                                         
         } // end if (price-gdHistoRange <= High[j] && price >= Low[j])   
         
         j--;
      } // end while ( iBarShift(NULL, giProfileTf, Time[j]) == itfsource )
      
      //----end Counting tpo     
      
   }// end for (i=0; i<countps; i++)   
   
}

//+------------------------------------------------------------------+
//| drawPriceHistoAndPOCLines                                        |
//+------------------------------------------------------------------+
void drawPriceHistoAndPOCLines
(
     int    startbar
   , int    endbar  
   , int    ibarproftf  
   , int    countps
   , double &apricestep[][]
   , int    maxtpo
   , int    maxtpoidx
   , double maxvol
   , int    maxvolidx
)
{
   double   price1, price2;
   int      numtpo; 
   double   numvol;
   int      step, i;
   int      chartstartbar = iBarShift( NULL, 0, iTime(NULL, giDataTf, startbar) );
   int      chartendbar   = iBarShift( NULL, 0, iTime(NULL, giDataTf, endbar) );
   int      numbar         = chartstartbar - chartendbar;
   color    clr; 
   datetime t1 = Time[chartstartbar], t2;
   string   strdtproftf = TimeToStr (iTime (NULL, giProfileTf, ibarproftf), TIME_DATE);
   double   lprice = apricestep[countps-1][0]; 
   
   //--- draw price histo
   if (ShowPriceHistogram)
   {   
      
      if (ibarproftf == 0) 
      {
         if (UseVolumeProfile) 
            delObjs( gsPref + "#" + (string)ibarproftf + ".histovol.");  
         else 
            delObjs( gsPref + "#" + (string)ibarproftf + ".histotpo.");
      }
       
      for (step=0; step<countps; step += giStep)      
      {
         price1   = apricestep[step][PRICEIDX];
         price2   = apricestep[step+(giStep)][PRICEIDX];
      
         if (MathCeil(dstep/2) == dstep/2) clr = HistoColor1;
         else clr = HistoColor2;
      
         if (!UseVolumeProfile)
         {
            numtpo   = 0;
      
            for (i=step; i < step+giStep; i++)
               numtpo = (int)MathMax( numtpo, apricestep[i][TPOIDX] );
      
            double x2 = ((giDataTf/1.0)/Period()) * numtpo;
            
            numtpo = (int)MathCeil( x2 ) ;
            
            t2 = Time[chartstartbar - numtpo] ;
                  
            if (t2<=t1) t2 = t1 + (Period()*60);         
      
            createRect( "#" + (string)ibarproftf + ".histotpo." + DoubleToStr(price1,fdigits)
               , price1,                  t1
               , MathMax(price2, lprice), t2
               , clr ); 
         }   
         else
         {            
            numvol = 0.0;
            for (i=step; i< step+giStep; i++)
              numvol   = MathMax(numvol, (apricestep[i][VOLIDX] / maxvol) * numbar );   
      
            //numtpo vol;  
            numtpo = (int)MathCeil((VolAmplitudePercent/100.0)*numvol);   
      
            t2 = Time[chartstartbar - numtpo] ;
            createRect( "#" + (string)ibarproftf + ".histovol." + DoubleToStr(price1,fdigits)
               , price1,                  t1
               , MathMax(price2, lprice), t2
               , clr );             
         }   
         
         dstep += 1.0;                                        
      }      
      
   }
   //--end draw price histo
      
   //--- draw poc lines
   t2 = Time[chartstartbar] + (2 * giProfileTf * 60);

   int idx = maxvolidx;
   
   string spoc = ".POC ";
   
   if (!UseVolumeProfile) idx   = maxtpoidx;
   double hh, ll;
   clr = POCColor;
   if ( ibarproftf != 0 )
   {
      
      getHHLL(endbar-1, 0, hh, ll);
      
      if ( (apricestep[ idx ][PRICEIDX] > hh && apricestep[ idx ][PRICEIDX] > ll)
         ||(apricestep[ idx ][PRICEIDX] < hh && apricestep[ idx ][PRICEIDX] < ll) )
      {
         clr = VirginPOCColor;
         spoc = ".VPOC ";
      } 
   }
    
   if (ibarproftf <= ExtendedPocLines || ibarproftf == 0) 
   {
      t2 = Time[0] + 10*Period()*60;
      
      createText( "#" + (string)ibarproftf +".1.1.poc.price"   
         , t2 + (3 * Period() * 60)
         , apricestep[ idx ][PRICEIDX]
         , addStr(
            ProfileTimeframe + "#" + (string)ibarproftf + spoc
            + StringSubstr( strdtproftf, 2, 8 )+" "
            + DoubleToStr( apricestep[ idx ][PRICEIDX], fdigits )
            , " ", 60
            )
         , 8, "Arial Narrow", clr
         );                       
   }    

   bool backg = true;
   if (spoc == ".VPOC ") backg = false;
   createTl("#" + (string)ibarproftf + ".1.1.poc", t1, apricestep[ idx ][PRICEIDX], t2, apricestep[ idx ][PRICEIDX], clr, STYLE_SOLID, 1, backg);  
  
   hh = iHigh ( NULL, giDataTf, iHighest(NULL, giDataTf, MODE_HIGH, (startbar - endbar)+1, endbar) );
   ll = iLow  ( NULL, giDataTf, iLowest (NULL, giDataTf, MODE_LOW,  (startbar - endbar)+1, endbar) );
   hh = NormalizeDouble(hh, fdigits);
   ll = NormalizeDouble(ll, fdigits);
   
   if(ShowTrendlines && !ShowHiLoTrendlines){
   datetime dtva3          = Time[chartendbar];  
   
   double mirror = (apricestep[ idx ][PRICEIDX])+(apricestep[ idx ][PRICEIDX]-hh);
   if(dtva3<Time[0]){
   createTl("#" + (string)ibarproftf + ".1.1.poc2", Time[chartendbar-1], apricestep[ idx ][PRICEIDX], t1, hh, trendcolor, STYLE_SOLID, 1, backg); 
   createTl("#" + (string)ibarproftf + ".1.1.poc3", Time[chartendbar-1], apricestep[ idx ][PRICEIDX], t1, mirror, trendcolor, STYLE_SOLID, 1, backg);  
   }else{
   createTl("#" + (string)ibarproftf + ".1.1.poc4", t2, apricestep[ idx ][PRICEIDX], t1, hh, trendcolor, STYLE_SOLID, 1, backg); 
   createTl("#" + (string)ibarproftf + ".1.1.poc5", t2, apricestep[ idx ][PRICEIDX], t1, mirror, trendcolor, STYLE_SOLID, 1, backg);  
   }}
   
   if(ShowTrendlines && ShowHiLoTrendlines){
    dtva3          = Time[chartendbar];  
   if(dtva3<Time[0]){
   createTl("#" + (string)ibarproftf + ".1.1.poc2", Time[chartendbar-1], apricestep[ idx ][PRICEIDX], t1, hh, trendcolor, STYLE_SOLID, 1, backg); 
   createTl("#" + (string)ibarproftf + ".1.1.poc3", Time[chartendbar-1], apricestep[ idx ][PRICEIDX], t1, ll, trendcolor, STYLE_SOLID, 1, backg);  
   }else{
   createTl("#" + (string)ibarproftf + ".1.1.poc4", t2, apricestep[ idx ][PRICEIDX], t1, hh, trendcolor, STYLE_SOLID, 1, backg); 
   createTl("#" + (string)ibarproftf + ".1.1.poc5", t2, apricestep[ idx ][PRICEIDX], t1, ll, trendcolor, STYLE_SOLID, 1, backg);  
   }}
   //--- draw open and close
   if (ShowOpenCloseArrow) 
   {
   
      double dopen  = iOpen (NULL, giDataTf, startbar);
      double dclose = iClose(NULL, giDataTf, endbar);
      createArw("#0.0.0.0" + (string)ibarproftf + ".open", dopen
         , Time[chartstartbar], 2, OpenColor);
   
      createArw("#0.0.0.0" + (string)ibarproftf + ".close", dclose
         , Time[chartstartbar], 2, CloseColor);
   } 
    
}


//+------------------------------------------------------------------+
//| getValueArea                                                     |
//+------------------------------------------------------------------+
void getValueArea
(
     int      countps
   , double   &apricestep[][]
   , int      maxtpo
   , int      maxtpoidx      
   , double   totaltpo
   , int      maxvol
   , int      maxvolidx
   , double   totalvol
   , double   &vah
   , int      &vahidx
   , double   &val
   , int      &validx
)
{

   int   idx      = maxvolidx;
   int   idx2     = VOLIDX;
   double total   = totalvol;
   if (!UseVolumeProfile) 
   {  
      idx   = maxtpoidx;
      idx2  = TPOIDX;
      total = totaltpo;
   }
   
   double vatpo  = (VATPOPercent/100) * total;      
   double tpo    = apricestep[ idx ][ idx2 ];   
   double tpo2upper, tpo2lower;
   int    upperidx = 1, lastupperidx = 1; 
   int    loweridx = 1, lastloweridx = 1; 

   while (tpo <= vatpo)
   {

      double utpo1 = apricestep[ idx - upperidx ][idx2];
      double ltpo1 = apricestep[ idx + loweridx ][idx2];
      double utpo2 = apricestep[ idx - (upperidx+1) ][idx2];
      double ltpo2 = apricestep[ idx + (loweridx+1) ][idx2];
      
      //check if vatpo reached by a single step                  
      if ( utpo1 >= ltpo1 && tpo + utpo1 >= vatpo )
      {
         lastupperidx = upperidx;
         tpo += utpo1;
         break;
      }
      else 
      if ( ltpo1 > utpo1 && tpo + ltpo1 >= vatpo )
      {
         lastloweridx = loweridx;
         tpo += ltpo1;
         break;         
      }
      
      //2 step price
      tpo2upper = utpo1 + utpo2;
      tpo2lower = ltpo1 + ltpo2;
                        
      if (tpo2upper >= tpo2lower)
      {
         lastupperidx = upperidx+1;
         if (idx-lastupperidx < 0) lastupperidx--;
         upperidx +=2;
         tpo += tpo2upper;
      }
      else
      {
         lastloweridx = loweridx+1;
         if (idx+lastloweridx > countps-1) lastloweridx--;
         loweridx +=2;
         tpo += tpo2lower;        
      }         
   }//end  while (tpo <= vatpo)
   
   vahidx = idx - lastupperidx;
   validx = idx + lastloweridx;
   vah    = apricestep[ idx-(lastupperidx) ][0];
   val    = apricestep[ idx+(lastloweridx) ][0];

}
//+------------------------------------------------------------------+
//| drawValueArea                                                    |
//+------------------------------------------------------------------+
void drawValueArea
(
     int    startbar
   , int    endbar
   , int    ibarproftf
   , int    countps
   , double &apricestep[][]
   , double vah
   , int    vahidx
   , double val
   , int    validx
)
{
   int      chartstartbar = iBarShift( NULL, 0, iTime(NULL, giDataTf, startbar) );
   int      chartendbar   = iBarShift( NULL, 0, iTime(NULL, giDataTf, endbar - 1) ) ;   
  // int      numtpo;
   int      step;
   datetime dtva1          = Time[chartstartbar];
   datetime dtva2          = Time[chartendbar]; //iTime(NULL, giProfileTf, ibar.proftf-1); 
   double   lprice         = apricestep[countps-1][0];     

   //current profile   
   if (endbar == 0 ) dtva2 = Time[0] + 10*Period()*60;
   
   int      argb[3];
   intToRGB(VAColor, argb);      

   if (ibarproftf == 0) 
   {
      delObjs( gsPref + "#" + (string)ibarproftf + ".0.0.0.va.");
      //ObjectDelete( gsPref + "#" + ibar.proftf + ".0.0.0.vah");
      //ObjectDelete( gsPref + "#" + ibar.proftf + ".0.0.0.val");
   }

     
   double   price1, price2;
   int      midvaidx    = vahidx + (int)MathCeil((validx-vahidx)/2);   
   int      vaidx       = 0;      
   
   // show value area
   if (ShowValueArea)   
   {
      for (step=0; step<countps; step += giStep)      
      {

         if ( step > validx ) break;
         //if ( step < vahidx ) continue;
      
         price1   = apricestep[ step ][0];
         price2   = apricestep[ step+giStep ][0];
         
         if (price2 > vah) continue;
            
         dtva1  = (int)MathMax(
              ObjectGet(gsPref + "#" + (string)ibarproftf + ".histotpo." + DoubleToStr(price1, fdigits), OBJPROP_TIME2 )
            , ObjectGet(gsPref + "#" + (string)ibarproftf + ".histovol." + DoubleToStr(price1, fdigits), OBJPROP_TIME2 )
            ); 
         //shadow effect
         //dtva1 += (Period() * 60); 
      
         if ( dtva1 < Time[chartstartbar] ) dtva1 = Time[0] + Period()*60;   
         if ( !ShowPriceHistogram ) dtva1 = Time[chartstartbar];      
         //if ( dtva2 < dtva1 ) dtva2  = Time[0] + 10*Period()*60;
      
         //rect @vah
         if (vah <= price1 && vah >= price2) price1 = vah;
      
         createRect("#" + (string)ibarproftf + ".0.0.0.va." + (string)vaidx
            , price1, dtva1 
            , MathMax(price2, val), dtva2
            , RGB(argb[0]+iclr, argb[1]+iclr, argb[2]+iclr)
            );  
     
         if (step <= midvaidx)
         {       
            if (giProfileTf == PERIOD_MN1) iclr +=1;
            if (giProfileTf == PERIOD_W1)  iclr +=2;
            else iclr += 3;
         }
         else
         {
            if (giProfileTf == PERIOD_MN1) iclr -=1;
            if (giProfileTf == PERIOD_W1)  iclr -=2;
            else iclr -= 3;      
         }
      
         vaidx ++;                                       
      }             
   }// end show value area
   
   //draw vah and val lines
   if (ShowVAHVALLines)
   {
      if(dtva2 < Time[chartstartbar]) dtva2 = Time[0] + (10*Period()*60);
      
      int width = 1;
      if (!ShowValueArea) width = 2;
   
      createTl("#" + (string)ibarproftf + ".0.0.0.vah"
         , Time[chartstartbar], apricestep[ vahidx ][PRICEIDX]
         , dtva2,                apricestep[ vahidx ][PRICEIDX]
         , VALinesColor, STYLE_SOLID, width
         );       
         
      createTl("#" + (string)ibarproftf + ".0.0.0.val"
         , Time[chartstartbar], apricestep[ validx ][PRICEIDX]
         , dtva2,                apricestep[ validx ][PRICEIDX]
         , VALinesColor, STYLE_SOLID, width
         );          
   } 
}
  
//+------------------------------------------------------------------+
//|add char at beginning or end of text                              |
//+------------------------------------------------------------------+
string addStr(string str, string tchar, int maxlength, bool atbeginning = true)
{
   int l = maxlength - StringLen(str);
   for (int i=0; i<l; i++)
   {
      if (atbeginning) str = tchar + str;
      else str = str + tchar;
   }
      
   return(str);
}  
//+------------------------------------------------------------------+
//| createRect                                                       |
//+------------------------------------------------------------------+   
void createRect(string objname, double p1, datetime t1, double p2, datetime t2, color clr, bool back=true)
{

   objname = gsPref + objname;
   if(ObjectFind(objname) != 0)    
      ObjectCreate(objname, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
   
   ObjectSet(objname, OBJPROP_PRICE1, p1);
   ObjectSet(objname, OBJPROP_TIME1,  t1);
   ObjectSet(objname, OBJPROP_PRICE2, p2);
   ObjectSet(objname, OBJPROP_TIME2,  t2);
   ObjectSet(objname, OBJPROP_COLOR,  clr);
   ObjectSet(objname, OBJPROP_BACK,   back);
}  
//+------------------------------------------------------------------+
//| createArw                                                        |
//+------------------------------------------------------------------+ 
void createArw(string objname, double p1, datetime t1, int ac, 
   color clr)
{
   objname = gsPref + objname;
   if(ObjectFind(objname) != 0)    
      ObjectCreate(objname, OBJ_ARROW, 0, 0, 0, 0, 0);
   
   ObjectSet(objname, OBJPROP_PRICE1,     p1);
   ObjectSet(objname, OBJPROP_TIME1,      t1);  
   ObjectSet(objname, OBJPROP_ARROWCODE,  ac);  
   ObjectSet(objname, OBJPROP_COLOR,      clr);  
   
}
//+------------------------------------------------------------------+
//| createText                                                       |
//+------------------------------------------------------------------+
void createText(string name, datetime t, double p, string text
   , int size=8, string font="Arial", color c=White)
{
   name = gsPref + name;
   
   if (ObjectFind(name) != 0)
      ObjectCreate (name,OBJ_TEXT,0,0,0);
   
   ObjectSet    (name,OBJPROP_TIME1,  t);
   ObjectSet    (name,OBJPROP_PRICE1, p);
   ObjectSetText(name,text,size,font, c);

}
//+------------------------------------------------------------------+
//| createTl                                                         |
//+------------------------------------------------------------------+ 
void createTl(string tlname, datetime t1, double v1, datetime t2, double v2, 
     color tlColor, int style = STYLE_SOLID, int width = 1, bool back=true, string desc="")
{
   tlname = gsPref + tlname;
   if(ObjectFind(tlname) != 0)
   {
      ObjectCreate(
            tlname
            , OBJ_TREND
            , 0
            , t1
            , v1
            , t2
            , v2
            );      
   }else
   {
      ObjectMove(tlname, 0, t1, v1);   
      ObjectMove(tlname, 1, t2, v2);
   }
   ObjectSet(tlname, OBJPROP_COLOR, tlColor);
   ObjectSet(tlname, OBJPROP_RAY,   false);
   ObjectSet(tlname, OBJPROP_STYLE, style);
   ObjectSet(tlname, OBJPROP_WIDTH, width);
   ObjectSet(tlname, OBJPROP_BACK,  back);
   ObjectSetText(tlname, desc);
} 

//+------------------------------------------------------------------+
//| newBarProfileTf                                                  |
//+------------------------------------------------------------------+
bool newBarProfileTf()
{
   
   static datetime LastProfile;
   datetime CurrProfile;
   string strdate;
   int oneperiod = giProfileTf*60;
   
   switch (giProfileTf)
   {
      case PERIOD_D1:
         strdate     = TimeToStr(Time[0],TIME_DATE);
         CurrProfile = StrToTime(strdate) + (DayStartHour * PERIOD_H1 * 60);
         if (Time[0] < CurrProfile) CurrProfile -= oneperiod;
         //string str = StringConcatenate("Currtime ", TimeToStr(Time[0]), "\nLastProfile ", TimeToStr(LastProfile), "\nCurrProfile ", TimeToStr(CurrProfile), "\nlastbar!=currbar ", (LastProfile != CurrProfile));                            
         break;
         
      default: //weekly and montly
         CurrProfile = iTime(NULL, giProfileTf, iBarShift(NULL, giProfileTf, Time[0]));
         break;
   }

   if(LastProfile != CurrProfile)
   {
     LastProfile = CurrProfile;
     return (true);
   }
   
   return(false);     
   
}
//+------------------------------------------------------------------+
//| newBar                                                           |
//+------------------------------------------------------------------+   

bool newBar()
{
 static datetime LastBar;
 datetime CurrBar = Time[0];
 
 if(LastBar != CurrBar)
 {
   LastBar = CurrBar;
   return (true);
 }
 
 return(false);    
}  

//+------------------------------------------------------------------+
//| secondDiff                                                       |
//+------------------------------------------------------------------+ 
/*
bool secondDiff(int sec = 10)
{
   static datetime lasttime ;
   int diff = TimeCurrent() - lasttime ;

   if (diff > sec )
   {
      lasttime = TimeCurrent();
      return (true);
   }
   
   return (false);
   
}  
*/


//+------------------------------------------------------------------+
//| delObjs function                                                 |
//+------------------------------------------------------------------+
void delObjs(string s="")
{
   int objs = ObjectsTotal();
   if (StringLen(s) == 0) s = gsPref;
   
   string name;
   for(int cnt=ObjectsTotal()-1;cnt>=0;cnt--)
   {
      name=ObjectName(cnt);
      if (StringSubstr(name,0,StringLen(s)) == s)       
         ObjectDelete(name); 
   }   
} 

//+------------------------------------------------------------------+
//| convert red, green and blue values to color                      |
//+------------------------------------------------------------------+
int RGB(int red_value,int green_value,int blue_value)
{
   //---- check parameters
   if(red_value<0)     red_value   = 0;
   if(red_value>255)   red_value   = 255;
   if(green_value<0)   green_value = 0;
   if(green_value>255) green_value = 255;
   if(blue_value<0)    blue_value  = 0;
   if(blue_value>255)  blue_value  = 255;
   //----
   green_value<<=8;
   blue_value<<=16;
   return(red_value+green_value+blue_value);
}
//+------------------------------------------------------------------+
//| convert color to red, green and blue values                      |
//+------------------------------------------------------------------+  
void intToRGB(int clr, int &argb[] )
{   
   int red   = (clr % 0x1000000 / 0x10000);  
   int green = (clr % 0x10000 / 0x100);  
   int blue  = (clr % 0x100); 

   argb[0] = red;
   argb[1] = green;
   argb[2] = blue;
      
}  
//+------------------------------------------------------------------+

/*
sugestions v1.31
http://www.forexfactory.com/showpost.php?p=4432129&postcount=629
@mima
Very good, I like that histogram can be false/true...VA is 1st standard deviation...so there is need for 2nd , 3rd and extremes(excesses)...Hopefully it will be in next revision. Thank you.

http://www.forexfactory.com/showpost.php?p=4432111&postcount=628
@kave
PS: One thing i notice that if the POC & VPC is align the POC overlay onto the VPC as shown here, (those 2 POC of 23rd & 24th). Since the 24th Feb qualifies as a VPC, is it possible let the VPC line to be overlayed on top instead??
http://www.forexfactory.com/showpost.php?p=4433083&postcount=634
@jamie
One comment, for the volume based profile is it possible to reduce the amplitude of the profile so that it doesn't extend so far to the right?

*/

  