#property copyright ""
#property link      ""

#property indicator_chart_window

extern int  CountDays=1;

extern bool Show_CurrDaily = true;
extern int Shift_CurrDaily_LABEL = 0;
extern bool Show_CurrWeekly = true;
extern int Shift_CurrWeekly_LABEL = 0;
extern bool Show_CurrMonthly = true;
extern int Shift_CurrMonthly_LABEL = 0;
extern color line_color_CurrDailyUPPER = Crimson;
extern color line_color_CurrDailyLOWER = Teal;
extern color line_color_CurrWeeklyUPPER = Crimson;
extern color line_color_CurrWeeklyLOWER = Teal;
extern color line_color_CurrMonthlyUPPER = Crimson;
extern color line_color_CurrMonthyLOWER = Teal;
extern int CurrDaily_LineStyle = 2;
extern int CurrWeekly_LineStyle = 2;
extern int CurrMonthly_LineStyle = 2;


extern bool Show_PreviousDaily = true;
extern bool Xtend_Prev_DailyLine = false;
extern bool Show_PreviousWeekly = true;
extern bool Xtend_Prev_WeeklyLine = false;
extern bool Show_PreviousMonthly = true;
extern bool Xtend_Prev_MonthlyLine = false;
extern color line_color_PreviousDaily = DarkOrange;
extern color line_color_PreviousWeekly = DarkOrange;
extern color line_color_PreviousMonthly = DarkOrange;
extern int PreviousLine_Style = 0;
extern int Shift_Prev_LABEL = 10;

extern bool Show_CurrRectangles_Display = false;
extern bool Show_Rectangles = false;
extern bool Rectangle_Curr_DayPeriod_only = false;
extern bool Show_Daily_Rectangle = false;
extern color Daily_Rectangle_color = Gainsboro;
extern bool Show_Weekly_Rectangle = false;
extern color Weekly_Rectangle_color = LightGray;
extern bool Show_Monthly_Rectangle = false;
extern color Monthly_Rectangle_color = Silver;

extern bool Show_Daily_Pivots = true;
extern color Daily_Pivot_color = Yellow;
extern int Daily_Pivot_LineWidth = 1;  
extern bool Show_Weekly_Pivots = true;
extern color Weekly_Pivot_color = Yellow;
extern int Weekly_Pivot_LineWidth = 1; 
extern bool Show_Monthly_Pivots = true;
extern color Monthly_Pivot_color = Yellow;
extern int Monthly_Pivot_LineWidth = 1;
 
extern bool Show_Daily_R1 = true;
extern color Daily_R1_color = Crimson;
extern int Daily_R1_LineWidth = 1;

extern bool Show_Daily_R2 = true;
extern color Daily_R2_color = Crimson;
extern int Daily_R2_LineWidth = 1;

extern bool Show_Daily_R3 = true;
extern color Daily_R3_color = Crimson;
extern int Daily_R3_LineWidth = 1;

extern bool Show_Daily_S1 = true;
extern color Daily_S1_color = Teal;
extern int Daily_S1_LineWidth = 1;

extern bool Show_Daily_S2 = true;
extern color Daily_S2_color = Teal;
extern int Daily_S2_LineWidth = 1;

extern bool Show_Daily_S3 = true;
extern color Daily_S3_color = Teal;
extern int Daily_S3_LineWidth = 1;

extern bool Show_Weekly_R1 = true;
extern color Weekly_R1_color = Crimson;
extern int Weekly_R1_LineWidth = 1;

extern bool Show_Weekly_R2 = true;
extern color Weekly_R2_color = Crimson;
extern int Weekly_R2_LineWidth = 1;

extern bool Show_Weekly_R3 = true;
extern color Weekly_R3_color = Crimson;
extern int Weekly_R3_LineWidth = 1;

extern bool Show_Weekly_S1 = true;
extern color Weekly_S1_color = Teal;
extern int Weekly_S1_LineWidth = 1;

extern bool Show_Weekly_S2 = true;
extern color Weekly_S2_color = Teal;
extern int Weekly_S2_LineWidth = 1;

extern bool Show_Weekly_S3 = true;
extern color Weekly_S3_color = Teal;
extern int Weekly_S3_LineWidth = 1;

extern bool Show_Monthly_R1 = true;
extern color Monthly_R1_color = Crimson;
extern int Monthly_R1_LineWidth = 1;

extern bool Show_Monthly_R2 = true;
extern color Monthly_R2_color = Crimson;
extern int Monthly_R2_LineWidth = 1;

extern bool Show_Monthly_R3 = true;
extern color Monthly_R3_color = Crimson;
extern int Monthly_R3_LineWidth = 1;

extern bool Show_Monthly_S1 = true;
extern color Monthly_S1_color = Teal;
extern int Monthly_S1_LineWidth = 1;

extern bool Show_Monthly_S2 = true;
extern color Monthly_S2_color = Teal;
extern int Monthly_S2_LineWidth = 1;

extern bool Show_Monthly_S3 = true;
extern color Monthly_S3_color = Teal;
extern int Monthly_S3_LineWidth = 1;

#define Curr_DG "Curr_DG"

#define Curr_WG "Curr_WG"

#define Curr_MG "Curr_MG"

   datetime time1;
   datetime time2;
   
   datetime time3;
   datetime time4;
   
   datetime time5;
   datetime time6;
   //******************************
   //currTimes
   
   datetime time7;
   datetime time8;
   datetime time9;
   datetime time10;
   datetime time11;
   datetime time12;
   //********************************
   //Pivot
   datetime time13;
   datetime time14;
   datetime time15;
   datetime time16;
   datetime time17;
   datetime time18;
 
   double DHi,DLo,WHi,WLo,MHi,MLo;
   double DHigh,DLow,WHigh,WLow,MHigh,MLow;
   double highD,lowD,closeD,highW,lowW,closeW,highM,lowM,closeM;
   double PD,PW,PM,PDR1,PDR2,PDR3,PDS1,PDS2,PDS3,PWR1,PWR2,PWR3,PWS1,PWS2,PWS3,PMR1,PMR2,PMR3,PMS1,PMS2,PMS3;
   
   int shift, num;
     
   void ObjDel()
   {
      for (;num<=CountDays;num++)
      {
      ObjectDelete("Previous_DailyHi["+num+"]");
      ObjectDelete("Previous_DailyLo["+num+"]");
      ObjectDelete("Previous_WeeklyHi["+num+"]");
      ObjectDelete("Previous_WeeklyLo["+num+"]");
      ObjectDelete("Previous_MonthlyHi["+num+"]");
      ObjectDelete("Previous_MonthlyLo["+num+"]");
    
      ObjectDelete("CurrentDailyHi["+num+"]");
      ObjectDelete("CurrentDailyLo["+num+"]");
      ObjectDelete("CurrentWeeklyHi["+num+"]");
      ObjectDelete("CurrentWeeklyLo["+num+"]");
      ObjectDelete("CurrentMonthlyHi["+num+"]");
      ObjectDelete("CurrentMonthlyLo["+num+"]");
      //*****************
      //Pivot
       ObjectDelete("CurrentPivot["+num+"]");
       ObjectDelete("CurrentPivotR1["+num+"]");
       ObjectDelete("CurrentPivotR2["+num+"]");
       ObjectDelete("CurrentPivotR3["+num+"]");
       ObjectDelete("CurrentPivotS1["+num+"]");
       ObjectDelete("CurrentPivotS2["+num+"]");
       ObjectDelete("CurrentPivotS3["+num+"]");
       ObjectDelete("CurrentWeeklyPivot["+num+"]");
       ObjectDelete("CurrentWeeklyPivotR1["+num+"]");
       ObjectDelete("CurrentWeeklyPivotR2["+num+"]");
       ObjectDelete("CurrentWeeklyPivotR3["+num+"]");
       ObjectDelete("CurrentWeeklyPivotS1["+num+"]");
       ObjectDelete("CurrentWeeklyPivotS2["+num+"]");
       ObjectDelete("CurrentWeeklyPivotS3["+num+"]");
       ObjectDelete("CurrentMonthlyPivot["+num+"]");
       ObjectDelete("CurrentMonthlyPivotR1["+num+"]");
       ObjectDelete("CurrentMonthlyPivotR2["+num+"]");
       ObjectDelete("CurrentMonthlyPivotR3["+num+"]");
       ObjectDelete("CurrentMonthlyPivotS1["+num+"]");
       ObjectDelete("CurrentMonthlyPivotS2["+num+"]");
       ObjectDelete("CurrentMonthlyPivotS3["+num+"]");
     } 
      
   }

   void PlotLineD(string dname,double value,double line_color_Daily,double style)
   {
   ObjectCreate(dname,OBJ_TREND,0,time1,value,time2,value);
   ObjectSet(dname, OBJPROP_WIDTH, 1);
   ObjectSet(dname, OBJPROP_STYLE, PreviousLine_Style);
   ObjectSet(dname, OBJPROP_RAY, Xtend_Prev_DailyLine);
   ObjectSet(dname, OBJPROP_BACK, true);
   ObjectSet(dname, OBJPROP_COLOR, line_color_Daily);
    }        
    
     void PlotLineW(string wname,double value,double line_color_Weekly,double style)
   {
   ObjectCreate(wname,OBJ_TREND,0,time3,value,time4,value);
   ObjectSet(wname, OBJPROP_WIDTH, 1);
   ObjectSet(wname, OBJPROP_STYLE, PreviousLine_Style);
   ObjectSet(wname, OBJPROP_RAY, Xtend_Prev_WeeklyLine);
   ObjectSet(wname, OBJPROP_BACK, true);
   ObjectSet(wname, OBJPROP_COLOR, line_color_Weekly);
    }        
       void PlotLineM(string mname,double value,double line_color_Monthly,double style)
   {
   ObjectCreate(mname,OBJ_TREND,0,time5,value,time6,value);
   ObjectSet(mname, OBJPROP_WIDTH, 1);
   ObjectSet(mname, OBJPROP_STYLE, PreviousLine_Style);
   ObjectSet(mname, OBJPROP_RAY, Xtend_Prev_MonthlyLine);
   ObjectSet(mname, OBJPROP_BACK, true);
   ObjectSet(mname, OBJPROP_COLOR, line_color_Monthly);
    }
   //****************************************************************************************
   // CurrDaily levels 
         void PlotLineDLY(string dayname,double value,double col,double style)
   {
   ObjectCreate(dayname,OBJ_TREND,0,time7,value,time8,value);
   ObjectSet(dayname, OBJPROP_WIDTH, 1);
   ObjectSet(dayname, OBJPROP_STYLE, CurrDaily_LineStyle );
   ObjectSet(dayname, OBJPROP_RAY, false);
   ObjectSet(dayname, OBJPROP_BACK, true);
   ObjectSet(dayname, OBJPROP_COLOR, col);
    }
  
           void PlotLineWLY(string weekname,double value,double col,double style)
   {
   ObjectCreate(weekname,OBJ_TREND,0,time9,value,time10,value);
   ObjectSet(weekname, OBJPROP_WIDTH, 1);
   ObjectSet(weekname, OBJPROP_STYLE, CurrWeekly_LineStyle );
   ObjectSet(weekname, OBJPROP_RAY, false);
   ObjectSet(weekname, OBJPROP_BACK, true);
   ObjectSet(weekname, OBJPROP_COLOR, col);
    }
            void PlotLineMLY(string monthname,double value,double col,double style)
   {
   ObjectCreate(monthname,OBJ_TREND,0,time11,value,time12,value);
   ObjectSet(monthname, OBJPROP_WIDTH, 1);
   ObjectSet(monthname, OBJPROP_STYLE, CurrMonthly_LineStyle );
   ObjectSet(monthname, OBJPROP_RAY, false);
   ObjectSet(monthname, OBJPROP_BACK, true);
   ObjectSet(monthname, OBJPROP_COLOR, col);
    }    
    
              void PlotLinePVT(string pname,double value,double col,double style)
   {
   ObjectCreate(pname,OBJ_TREND,0,time13,value,time14,value);
   ObjectSet(pname, OBJPROP_WIDTH, Daily_Pivot_LineWidth);
   ObjectSet(pname, OBJPROP_STYLE, 0 );
   ObjectSet(pname, OBJPROP_RAY, false);
   ObjectSet(pname, OBJPROP_BACK, true);
   ObjectSet(pname, OBJPROP_COLOR, col);
    }   
    void PlotLinePVTR1(string pnamer1,double value,double col,double style)
   {
   ObjectCreate(pnamer1,OBJ_TREND,0,time13,value,time14,value);
   ObjectSet(pnamer1, OBJPROP_WIDTH, Daily_R1_LineWidth);
   ObjectSet(pnamer1, OBJPROP_STYLE, 0 );
   ObjectSet(pnamer1, OBJPROP_RAY, false);
   ObjectSet(pnamer1, OBJPROP_BACK, true);
   ObjectSet(pnamer1, OBJPROP_COLOR, col);
    }
    
        void PlotLinePVTR2(string pnamer2,double value,double col,double style)
   {
   ObjectCreate(pnamer2,OBJ_TREND,0,time13,value,time14,value);
   ObjectSet(pnamer2, OBJPROP_WIDTH, Daily_R2_LineWidth);
   ObjectSet(pnamer2, OBJPROP_STYLE, 0 );
   ObjectSet(pnamer2, OBJPROP_RAY, false);
   ObjectSet(pnamer2, OBJPROP_BACK, true);
   ObjectSet(pnamer2, OBJPROP_COLOR, col);
    }
        void PlotLinePVTR3(string pnamer3,double value,double col,double style)
   {
   ObjectCreate(pnamer3,OBJ_TREND,0,time13,value,time14,value);
   ObjectSet(pnamer3, OBJPROP_WIDTH, Daily_R3_LineWidth);
   ObjectSet(pnamer3, OBJPROP_STYLE, 0 );
   ObjectSet(pnamer3, OBJPROP_RAY, false);
   ObjectSet(pnamer3, OBJPROP_BACK, true);
   ObjectSet(pnamer3, OBJPROP_COLOR, col);
    }
    
        void PlotLinePVTS1(string pnames1,double value,double col,double style)
   {
   ObjectCreate(pnames1,OBJ_TREND,0,time13,value,time14,value);
   ObjectSet(pnames1, OBJPROP_WIDTH, Daily_S1_LineWidth);
   ObjectSet(pnames1, OBJPROP_STYLE, 0 );
   ObjectSet(pnames1, OBJPROP_RAY, false);
   ObjectSet(pnames1, OBJPROP_BACK, true);
   ObjectSet(pnames1, OBJPROP_COLOR, col);
    }
    
    
            void PlotLinePVTS2(string pnames2,double value,double col,double style)
   {
   ObjectCreate(pnames2,OBJ_TREND,0,time13,value,time14,value);
   ObjectSet(pnames2, OBJPROP_WIDTH, Daily_S2_LineWidth);
   ObjectSet(pnames2, OBJPROP_STYLE, 0 );
   ObjectSet(pnames2, OBJPROP_RAY, false);
   ObjectSet(pnames2, OBJPROP_BACK, true);
   ObjectSet(pnames2, OBJPROP_COLOR, col);
    }
    
                void PlotLinePVTS3(string pnames3,double value,double col,double style)
   {
   ObjectCreate(pnames3,OBJ_TREND,0,time13,value,time14,value);
   ObjectSet(pnames3, OBJPROP_WIDTH, Daily_S3_LineWidth);
   ObjectSet(pnames3, OBJPROP_STYLE, 0 );
   ObjectSet(pnames3, OBJPROP_RAY, false);
   ObjectSet(pnames3, OBJPROP_BACK, true);
   ObjectSet(pnames3, OBJPROP_COLOR, col);
    }
    
    
    
                  void PlotLinePVTW(string wpname,double value,double col,double style)
   {
   ObjectCreate(wpname,OBJ_TREND,0,time15,value,time16,value);
   ObjectSet(wpname, OBJPROP_WIDTH, Weekly_Pivot_LineWidth);
   ObjectSet(wpname, OBJPROP_STYLE, 0 );
   ObjectSet(wpname, OBJPROP_RAY, false);
   ObjectSet(wpname, OBJPROP_BACK, true);
   ObjectSet(wpname, OBJPROP_COLOR, col);
    }   
    
    void PlotLinePVTWR1(string wpnamer1,double value,double col,double style)
   {
   ObjectCreate(wpnamer1,OBJ_TREND,0,time15,value,time16,value);
   ObjectSet(wpnamer1, OBJPROP_WIDTH, Weekly_R1_LineWidth);
   ObjectSet(wpnamer1, OBJPROP_STYLE, 0 );
   ObjectSet(wpnamer1, OBJPROP_RAY, false);
   ObjectSet(wpnamer1, OBJPROP_BACK, true);
   ObjectSet(wpnamer1, OBJPROP_COLOR, col);
    }   
    
        void PlotLinePVTWR2(string wpnamer2,double value,double col,double style)
   {
   ObjectCreate(wpnamer2,OBJ_TREND,0,time15,value,time16,value);
   ObjectSet(wpnamer2, OBJPROP_WIDTH, Weekly_R2_LineWidth);
   ObjectSet(wpnamer2, OBJPROP_STYLE, 0 );
   ObjectSet(wpnamer2, OBJPROP_RAY, false);
   ObjectSet(wpnamer2, OBJPROP_BACK, true);
   ObjectSet(wpnamer2, OBJPROP_COLOR, col);
    }  
    
        void PlotLinePVTWR3(string wpnamer3,double value,double col,double style)
   {
   ObjectCreate(wpnamer3,OBJ_TREND,0,time15,value,time16,value);
   ObjectSet(wpnamer3, OBJPROP_WIDTH, Weekly_R3_LineWidth);
   ObjectSet(wpnamer3, OBJPROP_STYLE, 0 );
   ObjectSet(wpnamer3, OBJPROP_RAY, false);
   ObjectSet(wpnamer3, OBJPROP_BACK, true);
   ObjectSet(wpnamer3, OBJPROP_COLOR, col);
    }  
    
        void PlotLinePVTWS1(string wpnames1,double value,double col,double style)
   {
   ObjectCreate(wpnames1,OBJ_TREND,0,time15,value,time16,value);
   ObjectSet(wpnames1, OBJPROP_WIDTH, Weekly_S1_LineWidth);
   ObjectSet(wpnames1, OBJPROP_STYLE, 0 );
   ObjectSet(wpnames1, OBJPROP_RAY, false);
   ObjectSet(wpnames1, OBJPROP_BACK, true);
   ObjectSet(wpnames1, OBJPROP_COLOR, col);
    }  
    
            void PlotLinePVTWS2(string wpnames2,double value,double col,double style)
   {
   ObjectCreate(wpnames2,OBJ_TREND,0,time15,value,time16,value);
   ObjectSet(wpnames2, OBJPROP_WIDTH, Weekly_S2_LineWidth);
   ObjectSet(wpnames2, OBJPROP_STYLE, 0 );
   ObjectSet(wpnames2, OBJPROP_RAY, false);
   ObjectSet(wpnames2, OBJPROP_BACK, true);
   ObjectSet(wpnames2, OBJPROP_COLOR, col);
    }  
    
            void PlotLinePVTWS3(string wpnames3,double value,double col,double style)
   {
   ObjectCreate(wpnames3,OBJ_TREND,0,time15,value,time16,value);
   ObjectSet(wpnames3, OBJPROP_WIDTH, Weekly_S3_LineWidth);
   ObjectSet(wpnames3, OBJPROP_STYLE, 0 );
   ObjectSet(wpnames3, OBJPROP_RAY, false);
   ObjectSet(wpnames3, OBJPROP_BACK, true);
   ObjectSet(wpnames3, OBJPROP_COLOR, col);
    }  
                 void PlotLinePVTM(string mpname,double value,double col,double style)
   {
   ObjectCreate(mpname,OBJ_TREND,0,time17,value,time18,value);
   ObjectSet(mpname, OBJPROP_WIDTH, Monthly_Pivot_LineWidth);
   ObjectSet(mpname, OBJPROP_STYLE, 0 );
   ObjectSet(mpname, OBJPROP_RAY, false);
   ObjectSet(mpname, OBJPROP_BACK, true);
   ObjectSet(mpname, OBJPROP_COLOR, col);
    }   
    
    void PlotLinePVTMR1(string mpnamer1,double value,double col,double style)
   {
   ObjectCreate(mpnamer1,OBJ_TREND,0,time17,value,time18,value);
   ObjectSet(mpnamer1, OBJPROP_WIDTH, Monthly_R1_LineWidth);
   ObjectSet(mpnamer1, OBJPROP_STYLE, 0 );
   ObjectSet(mpnamer1, OBJPROP_RAY, false);
   ObjectSet(mpnamer1, OBJPROP_BACK, true);
   ObjectSet(mpnamer1, OBJPROP_COLOR, col);
    }
    
        void PlotLinePVTMR2(string mpnamer2,double value,double col,double style)
   {
   ObjectCreate(mpnamer2,OBJ_TREND,0,time17,value,time18,value);
   ObjectSet(mpnamer2, OBJPROP_WIDTH, Monthly_R2_LineWidth);
   ObjectSet(mpnamer2, OBJPROP_STYLE, 0 );
   ObjectSet(mpnamer2, OBJPROP_RAY, false);
   ObjectSet(mpnamer2, OBJPROP_BACK, true);
   ObjectSet(mpnamer2, OBJPROP_COLOR, col);
    }
    
        void PlotLinePVTMR3(string mpnamer3,double value,double col,double style)
   {
   ObjectCreate(mpnamer3,OBJ_TREND,0,time17,value,time18,value);
   ObjectSet(mpnamer3, OBJPROP_WIDTH, Monthly_R3_LineWidth);
   ObjectSet(mpnamer3, OBJPROP_STYLE, 0 );
   ObjectSet(mpnamer3, OBJPROP_RAY, false);
   ObjectSet(mpnamer3, OBJPROP_BACK, true);
   ObjectSet(mpnamer3, OBJPROP_COLOR, col);
    }
    
        void PlotLinePVTMS1(string mpnames1,double value,double col,double style)
   {
   ObjectCreate(mpnames1,OBJ_TREND,0,time17,value,time18,value);
   ObjectSet(mpnames1, OBJPROP_WIDTH, Monthly_S1_LineWidth);
   ObjectSet(mpnames1, OBJPROP_STYLE, 0 );
   ObjectSet(mpnames1, OBJPROP_RAY, false);
   ObjectSet(mpnames1, OBJPROP_BACK, true);
   ObjectSet(mpnames1, OBJPROP_COLOR, col);
    }
    
            void PlotLinePVTMS2(string mpnames2,double value,double col,double style)
   {
   ObjectCreate(mpnames2,OBJ_TREND,0,time17,value,time18,value);
   ObjectSet(mpnames2, OBJPROP_WIDTH, Monthly_S2_LineWidth);
   ObjectSet(mpnames2, OBJPROP_STYLE, 0 );
   ObjectSet(mpnames2, OBJPROP_RAY, false);
   ObjectSet(mpnames2, OBJPROP_BACK, true);
   ObjectSet(mpnames2, OBJPROP_COLOR, col);
    }
    
            void PlotLinePVTMS3(string mpnames3,double value,double col,double style)
   {
   ObjectCreate(mpnames3,OBJ_TREND,0,time17,value,time18,value);
   ObjectSet(mpnames3, OBJPROP_WIDTH, Monthly_S3_LineWidth);
   ObjectSet(mpnames3, OBJPROP_STYLE, 0 );
   ObjectSet(mpnames3, OBJPROP_RAY, false);
   ObjectSet(mpnames3, OBJPROP_BACK, true);
   ObjectSet(mpnames3, OBJPROP_COLOR, col);
    }
    
int init()
  {
 IndicatorShortName("MTF_HI_LOW");  
  return(0);
  }
   
   
int deinit()
  {
  ObjectsDeleteAll(0,OBJ_RECTANGLE);
  ObjectsDeleteAll(0,OBJ_TRENDBYANGLE);
  ObjectsDeleteAll(0,OBJ_TEXT);
   ObjDel();
   Comment("");
   return(0);
  }

int start()
//*******************************************************************************************
  {
 
     CreateDHI();
}

void Create_DailyLineHI(string dLine, double start, double end,double w, double s,color clr)
  {
   ObjectCreate(dLine, OBJ_RECTANGLE, 0, iTime(NULL,1440,0), start, Time[0], end);
   ObjectSet(dLine, OBJPROP_COLOR, clr);
   ObjectSet(dLine,OBJPROP_RAY,false);
   ObjectSet(dLine,OBJPROP_BACK,Show_Rectangles);
   ObjectSet(dLine,OBJPROP_WIDTH,w);
    ObjectSet(dLine,OBJPROP_STYLE,s);

  }
   void DeleteCreate_DailyLineHI()
   {
   ObjectDelete( Curr_DG);ObjectDelete( Curr_WG);ObjectDelete( Curr_MG);  
   }
   void CreateDHI()
   {
   DeleteCreate_DailyLineHI();
   ObjectsDeleteAll(0,OBJ_RECTANGLE);
   
    
     CreateWHI();
}

void Create_DailyLineWHI(string WLine, double start, double end,double w, double s,color clr)
  {
   ObjectCreate(WLine, OBJ_RECTANGLE, 0, iTime(NULL,10080,0), start, Time[0], end);
   ObjectSet(WLine, OBJPROP_COLOR, clr);
   ObjectSet(WLine,OBJPROP_RAY,false);
   ObjectSet(WLine,OBJPROP_BACK,Show_Rectangles);
   ObjectSet(WLine,OBJPROP_WIDTH,w);
    ObjectSet(WLine,OBJPROP_STYLE,s);

  }
   void DeleteCreate_DailyLineWHI()
   {
   ObjectDelete( Curr_WG); 
   }
   void CreateWHI()
   {
   DeleteCreate_DailyLineWHI();
   ObjectsDeleteAll(0,OBJ_RECTANGLE);
    
     CreateMHI();
}

void Create_DailyLineMHI(string MLine, double start, double end,double w, double s,color clr)
  {
   ObjectCreate(MLine, OBJ_RECTANGLE, 0, iTime(NULL,43200,0), start, Time[0], end);
   ObjectSet(MLine, OBJPROP_COLOR, clr);
   ObjectSet(MLine,OBJPROP_RAY,false);
   ObjectSet(MLine,OBJPROP_BACK,Show_Rectangles);
   ObjectSet(MLine,OBJPROP_WIDTH,w);
    ObjectSet(MLine,OBJPROP_STYLE,s);

  }
   void DeleteCreate_DailyLineMHI()
   {
   ObjectDelete( Curr_MG); 
   }
   void CreateMHI()
   {
   DeleteCreate_DailyLineMHI();
   ObjectsDeleteAll(0,OBJ_RECTANGLE);
   
   double Dailyhigh = iHigh(NULL,1440,0);
   double Dailylow = iLow(NULL,1440,0);
   double Weeklyhigh = iHigh(NULL,10080,0);
   double Weeklylow = iLow(NULL,10080,0);
   double Monthlyhigh = iHigh(NULL,43200,0);
   double Monthlylow = iLow(NULL,43200,0);
   
   if (  Rectangle_Curr_DayPeriod_only == false )
   {
   if (Show_CurrRectangles_Display == true )
   { 
   if (Show_Daily_Rectangle == true )
   {
   Create_DailyLineHI( Curr_DG, Dailyhigh , Dailylow ,2,2,Daily_Rectangle_color);
   }
    if (Show_Weekly_Rectangle == true )
   {
   Create_DailyLineWHI( Curr_WG, Weeklyhigh , Weeklylow ,2,2,Weekly_Rectangle_color);
   }
    if (Show_Monthly_Rectangle == true )
   {
   Create_DailyLineMHI( Curr_MG, Monthlyhigh , Monthlylow ,2,2,Monthly_Rectangle_color);
   }}}
   
    if ( Rectangle_Curr_DayPeriod_only == true )
   {
   if (Show_CurrRectangles_Display == true )
   { 
   if (Show_Daily_Rectangle == true )
   {
   Create_DailyLineHI( Curr_DG, Dailyhigh , Dailylow ,2,2,Daily_Rectangle_color);
   }
    if (Show_Weekly_Rectangle == true )
   {
   Create_DailyLineHI( Curr_WG, Weeklyhigh , Weeklylow ,2,2,Weekly_Rectangle_color);
   }
    if (Show_Monthly_Rectangle == true )
   {
   Create_DailyLineHI( Curr_MG, Monthlyhigh , Monthlylow ,2,2,Monthly_Rectangle_color);
   }}}
   //*******************************************************************************
  int i;
     
  ObjDel();
  num=0;
  
  for (shift=CountDays-1;shift>=0;shift--)
  {
  time1=iTime(NULL,PERIOD_D1,shift);
  time3=iTime(NULL,PERIOD_W1,shift);
  time5=iTime(NULL,PERIOD_MN1,shift);
  //**************************************************
  //CurrDaily levels
  time7=iTime(NULL,PERIOD_D1,0);
  time9=iTime(NULL,PERIOD_W1,0);
  time11=iTime(NULL,PERIOD_MN1,0);
  //**********************************************
  //Pivot
  time13=iTime(NULL,PERIOD_D1,shift);
  time15=iTime(NULL,PERIOD_W1,shift);
  time17=iTime(NULL,PERIOD_MN1,shift);
  
 
  i=shift-1;
  if (i<0) 
  time2=Time[0];
  else
  time2=iTime(NULL,PERIOD_D1,i)-Period()*60;
  if (i<0)
  time4=Time[0];
  else
  time4=iTime(NULL,PERIOD_W1,i)-Period()*60;
  if (i<0)
  time6=Time[0];
  else
  time6=iTime(NULL,PERIOD_MN1,i)-Period()*60; 
  if (i<0)
  //***********************************************************
  //CurrDaily levels
  time8=iTime(NULL,PERIOD_D1,0)-Period()*60; 
  time10=iTime(NULL,PERIOD_W1,0)-Period()*60; 
  time12=iTime(NULL,PERIOD_MN1,0)-Period()*60; 
  //*********************************************************
  //Pivot
  if (i<0) 
  time14=Time[0];
  else
  time14=iTime(NULL,PERIOD_D1,i)-Period()*60;
  if (i<0)
  time16=Time[0];
  else
  time16=iTime(NULL,PERIOD_W1,i)-Period()*60;
  if (i<0)
  time18=Time[0];
  else
  time18=iTime(NULL,PERIOD_MN1,i)-Period()*60; 
  
  highD  = iHigh(NULL,PERIOD_D1,shift+1);
  lowD   = iLow(NULL,PERIOD_D1,shift+1);
  closeD = iClose(NULL,PERIOD_D1,shift+1);
  highW  = iHigh(NULL,PERIOD_W1,shift+1);
  lowW   = iLow(NULL,PERIOD_W1,shift+1);
  closeW = iClose(NULL,PERIOD_W1,shift+1);
  highM  = iHigh(NULL,PERIOD_MN1,shift+1);
  lowM   = iLow(NULL,PERIOD_MN1,shift+1);
  closeM = iClose(NULL,PERIOD_MN1,shift+1);
 
       
  PD  = (highD+lowD+closeD)/3.0;
  PW  = (highW+lowW+closeW)/3.0;
  PM  = (highM+lowM+closeM)/3.0;
  PDR1  = ((2.0*PD)-lowD);
  PDR2  = (PD+(highD-lowD));
  PDR3  = (highD + 2.0*(PD-lowD));
  PDS1  = ((2.0*PD)-highD);
  PDS2  = (PD-(highD-lowD));
  PDS3  = (lowD - 2.0*(highD-PD));
  
  PWR1  = ((2.0*PW)-lowW);
  PWR2  = (PW+(highW-lowW));
  PWR3  = (highW + 2.0*(PW-lowW));
  PWS1  = ((2.0*PW)-highW);
  PWS2  = (PW-(highW-lowW));
  PWS3  = (lowW - 2.0*(highW-PW));
  
  PMR1  = ((2.0*PM)-lowM);
  PMR2  = (PM+(highM-lowM));
  PMR3  = (highM + 2.0*(PM-lowM));
  PMS1  = ((2.0*PM)-highM);
  PMS2  = (PM-(highM-lowM));
  PMS3  = (lowM - 2.0*(highM-PM));

      
  DHi  = iHigh(NULL,PERIOD_D1,shift+1);
  DLo   = iLow(NULL,PERIOD_D1,shift+1);
  
  WHi  = iHigh(NULL,PERIOD_W1,shift+1);
  WLo   = iLow(NULL,PERIOD_W1,shift+1);
 
  MHi  = iHigh(NULL,PERIOD_MN1,shift+1);
  MLo   = iLow(NULL,PERIOD_MN1,shift+1);
  //***************************
  //CurrDaily levels
  DHigh  = iHigh(NULL,PERIOD_D1,0);
  DLow   = iLow(NULL,PERIOD_D1,0);
  
  WHigh  = iHigh(NULL,PERIOD_W1,0);
  WLow   = iLow(NULL,PERIOD_W1,0);
  
  MHigh  = iHigh(NULL,PERIOD_MN1,0);
  MLow   = iLow(NULL,PERIOD_MN1,0);
 
  time2=time1+PERIOD_D1*60;
  time4=time3+PERIOD_W1*60;
  time6=time5+PERIOD_MN1*60;
  //******************************************
  // CurrDaily levels
  time8=time7+PERIOD_D1*60;
  time10=time9+PERIOD_W1*60;
  time12=time11+PERIOD_MN1*60;
  //******************************************
  //Pivot
  time14=time13+PERIOD_D1*60;
  time16=time15+PERIOD_W1*60;
  time18=time17+PERIOD_MN1*60;

 
         
 
  num=shift;
   if (Show_PreviousDaily == true)
    {       
  PlotLineD("Previous_DailyHi["+num+"]",DHi,line_color_PreviousDaily,0);
  PlotLineD("Previous_DailyLo["+num+"]",DLo,line_color_PreviousDaily,0);
  }
   if (Show_PreviousWeekly == true)
    {  
  PlotLineW("Previous_WeeklyHi["+num+"]",WHi,line_color_PreviousWeekly,0);
  PlotLineW("Previous_WeeklyLo["+num+"]",WLo,line_color_PreviousWeekly,0);
  }
   if (Show_PreviousMonthly == true)
    {  
  PlotLineM("Previous_MonthlyHi["+num+"]",MHi,line_color_PreviousMonthly,0);
  PlotLineM("Previous_MonthlyLo["+num+"]",MLo,line_color_PreviousMonthly,0);
 }
 //***************************************************************************************************
 //CurrDaily levels
  if (Show_CurrDaily == true)
    {    
  PlotLineDLY("CurrentDailyHi["+num+"]",DHigh,line_color_CurrDailyUPPER ,0);
  PlotLineDLY("CurrentDailyLo["+num+"]",DLow,line_color_CurrDailyLOWER,0);
  }
   if (Show_CurrWeekly == true)
    { 
  PlotLineWLY("CurrentWeeklyHi["+num+"]",WHigh,line_color_CurrWeeklyUPPER,0);
  PlotLineWLY("CurrentWeeklyLo["+num+"]",WLow,line_color_CurrWeeklyLOWER,0);
  }
   if (Show_CurrMonthly == true)
    { 
  PlotLineMLY("CurrentMonthlyHi["+num+"]",MHigh,line_color_CurrMonthlyUPPER ,0);
  PlotLineMLY("CurrentMonthlyLo["+num+"]",MLow,line_color_CurrMonthyLOWER,0);
  }}
  //*****************************************
  if (Show_Daily_Pivots == true)
  {
  PlotLinePVT("CurrentPivot["+num+"]",PD,Daily_Pivot_color,0);
  }
  if (Show_Daily_R1 == true)
  {
  PlotLinePVTR1("CurrentPivotR1["+num+"]",PDR1,Daily_R1_color,0);
  }
  
    if (Show_Daily_R2 == true)
  {
  PlotLinePVTR2("CurrentPivotR2["+num+"]",PDR2,Daily_R2_color,0);
  }
  
    if (Show_Daily_R3 == true)
  {
  PlotLinePVTR3("CurrentPivotR3["+num+"]",PDR3,Daily_R3_color,0);
  }
  
    if (Show_Daily_S1 == true)
  {
  PlotLinePVTS1("CurrentPivotS1["+num+"]",PDS1,Daily_S1_color,0);
  }
  
      if (Show_Daily_S2 == true)
  {
  PlotLinePVTS2("CurrentPivotS2["+num+"]",PDS2,Daily_S2_color,0);
  }
  
      if (Show_Daily_S3 == true)
  {
  PlotLinePVTS3("CurrentPivotS3["+num+"]",PDS3,Daily_S3_color,0);
  }
  
  if (Show_Weekly_Pivots == true)
  {
  PlotLinePVTW("CurrentWeeklyPivot["+num+"]",PW,Weekly_Pivot_color,0);
  }
  
  if (Show_Weekly_R1 == true)
  {
  PlotLinePVTWR1("CurrentWeeklyPivotR1["+num+"]",PWR1,Weekly_R1_color,0);
  }
  
    if (Show_Weekly_R2 == true)
  {
  PlotLinePVTWR2("CurrentWeeklyPivotR2["+num+"]",PWR2,Weekly_R2_color,0);
  }
    if (Show_Weekly_R3 == true)
  {
  PlotLinePVTWR3("CurrentWeeklyPivotR3["+num+"]",PWR3,Weekly_R3_color,0);
  }
  
    if (Show_Weekly_S1 == true)
  {
  PlotLinePVTWS1("CurrentWeeklyPivotS1["+num+"]",PWS1,Weekly_S1_color,0);
  }
      if (Show_Weekly_S2 == true)
  {
  PlotLinePVTWS2("CurrentWeeklyPivotS2["+num+"]",PWS2,Weekly_S2_color,0);
  }
      if (Show_Weekly_S3 == true)
  {
  PlotLinePVTWS3("CurrentWeeklyPivotS3["+num+"]",PWS3,Weekly_S3_color,0);
  }
  if (Show_Monthly_Pivots == true)
  {
  PlotLinePVTM("CurrentMonthlyPivot["+num+"]",PM,Monthly_Pivot_color ,0);
  }
     if (Show_Monthly_R1 == true)
  {
  PlotLinePVTMR1("CurrentMonthlyPivotR1["+num+"]",PMR1,Monthly_R1_color ,0);
  }
        if (Show_Monthly_R2 == true)
  {
  PlotLinePVTMR2("CurrentMonthlyPivotR2["+num+"]",PMR2,Monthly_R2_color ,0);
  }
  
       if (Show_Monthly_R3 == true)
  {
  PlotLinePVTMR3("CurrentMonthlyPivotR3["+num+"]",PMR3,Monthly_R3_color ,0);
  }
         if (Show_Monthly_S1 == true)
  {
  PlotLinePVTMS1("CurrentMonthlyPivotS1["+num+"]",PMS1,Monthly_S1_color ,0);
  }
           if (Show_Monthly_S2 == true)
  {
  PlotLinePVTMS2("CurrentMonthlyPivotS2["+num+"]",PMS2,Monthly_S2_color ,0);
  } 
             if (Show_Monthly_S3 == true)
  {
  PlotLinePVTMS3("CurrentMonthlyPivotS3["+num+"]",PMS3,Monthly_S3_color ,0);
  }       
       
         
   return(0);
  }
//+------------------------------------------------------------------+