//+------------------------------------------------------------------+
//|                                                MarketProfile.mq4 |
//| 				                 Copyright © 2010-2019, EarnForex.com |
//|                                       https://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "EarnForex.com"
#property link      "https://www.earnforex.com/metatrader-indicators/MarketProfile/"
#property version   "1.12"
#property strict

#property description "Displays the Market Profile indicator for intraday, daily, weekly, or monthly trading sessions."
#property description "Daily - should be attached to M5-M30 timeframes. M30 is recommended."
#property description "Weekly - should be attached to M30-H4 timeframes. H1 is recommended."
#property description "Weeks start on Sunday."
#property description "Monthly - should be attached to H1-D1 timeframes. H4 is recommended."
#property description "Intraday - should be attached to M1-M15 timeframes. M5 is recommended.\r\n"
#property description "Designed for major currency pairs, but should work also with exotic pairs, CFDs, or commodities."

#property indicator_chart_window
#property indicator_plots 0

enum color_scheme
{
   Blue_to_Red, // Blue to Red
   Red_to_Green, // Red to Green
   Green_to_Blue, // Green to Blue
   Yellow_to_Cyan, // Yellow to Cyan
   Magenta_to_Yellow, // Magenta to Yellow
   Cyan_to_Magenta, // Cyan to Magenta
   Single_Color // Single Color
};

enum session_period
{
	Daily,
	Weekly,
	Monthly,
	Intraday
};

enum sat_sun_solution
{
   Saturday_Sunday_Normal_Days, // Normal sessions
   Ignore_Saturday_Sunday, // Ignore Saturday and Sunday
   Append_Saturday_Sunday // Append Saturday and Sunday
};

enum sessions_to_draw_rays
{
   None,
   Previous,
   Current,
   PreviousCurrent, // Previous & Current
   AllPrevious, // All Previous
   All
};

input session_period Session                 = Daily;
input datetime       StartFromDate           = __DATE__; // StartFromDate: lower priority.
input bool           StartFromCurrentSession = true;     // StartFromCurrentSession: higher priority.
input int            SessionsToCount         = 2;        // SessionsToCount: Number of sessions to count Market Profile.
input color_scheme   ColorScheme             = Blue_to_Red;
input sat_sun_solution SaturdaySunday        = Saturday_Sunday_Normal_Days;
input color          SingleColor             = clrBlue;  // SingleColor: if ColorScheme is set to Single_Color.
input color          MedianColor             = clrWhite;
input color          ValueAreaColor          = clrWhite;
input sessions_to_draw_rays ShowValueAreaRays= None;     // ShowValueAreaRays: draw previous value area high/low rays.
input sessions_to_draw_rays ShowMedianRays   = None;     // ShowMedianRays: draw previous median rays.
input bool           RaysUntilIntersection   = false;    // RaysUntilIntersection: rays stop when hit another MP.
input int            TimeShiftMinutes        = 0;        // TimeShiftMinutes: shift session + to the left, - to the right.
input int            PointMultiplier         = 1;        // PointMultiplier: the higher it is, the fewer chart objects.
input int            ThrottleRedraw          = 0;        // ThrottleRedraw: delay (in seconds) for updating Market Profile.



input bool           EnableIntradaySession1      = true;
input string         IntradaySession1StartTime   = "00:00";
input string         IntradaySession1EndTime     = "06:00";
input color_scheme   IntradaySession1ColorScheme = Blue_to_Red;

input bool           EnableIntradaySession2      = true;
input string         IntradaySession2StartTime   = "06:00";
input string         IntradaySession2EndTime     = "12:00";
input color_scheme   IntradaySession2ColorScheme = Red_to_Green;

input bool           EnableIntradaySession3      = true;
input string         IntradaySession3StartTime   = "12:00";
input string         IntradaySession3EndTime     = "18:00";
input color_scheme   IntradaySession3ColorScheme = Green_to_Blue;

input bool           EnableIntradaySession4      = true;
input string         IntradaySession4StartTime   = "18:00";
input string         IntradaySession4EndTime     = "00:00";
input color_scheme   IntradaySession4ColorScheme = Yellow_to_Cyan;

int DigitsM; 					// Number of digits normalized based on TickMultiplier.
bool InitFailed;           // Used for soft INIT_FAILED. Hard INIT_FAILED resets input parameters.
datetime StartDate; 			// Will hold either StartFromDate or Time[0].
double onetick; 				// One normalized pip.
bool FirstRunDone = false; // If true - OnCalculate() was already executed once.
string Suffix = "";			// Will store object name suffix depending on timeframe.
color_scheme CurrentColorScheme; // Required due to intraday sessions.
int Max_number_of_bars_in_a_session = 1;
int Timer = 0; 			   // For throttling updates of market profiles in slow systems.

// For intraday sessions' start and end times.
int IDStartHours[4];
int IDStartMinutes[4];
int IDStartTime[4]; // Stores IDStartHours x 60 + IDStartMinutes for comparison purposes.
int IDEndHours[4];
int IDEndMinutes[4];
int IDEndTime[4]; // Stores IDEndHours x 60 + IDEndMinutes for comparison purposes.
color_scheme IDColorScheme[4];
bool IntradayCheckPassed = false;
int IntradaySessionCount = 0;
int _SessionsToCount;
int IntradayCrossSessionDefined = -1; // For special case used only with Ignore_Saturday_Sunday on Monday.

// We need to know where each session starts and its price range for when RaysUntilIntersection == true.
// These are used also when RaysUntilIntersection == false for Intraday sessions counting.
double RememberSessionMax[], RememberSessionMin[];
datetime RememberSessionStart[];
string RememberSessionSuffix[];
int SessionsNumber = 0; // Different from _SessionsToCount when working with Intraday sessions and for RaysUntilIntersection == true.

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
	InitFailed = false;
	
	_SessionsToCount = SessionsToCount;
	
	if (Session == Daily)
	{
		Suffix = "_D";
		if ((Period() < PERIOD_M5) || (Period() > PERIOD_M30))
		{
			Alert("Timeframe should be between M5 and M30 for a Daily session.");
			InitFailed = true; // Soft INIT_FAILED.
		}
	}
	else if (Session == Weekly)
	{
		Suffix = "_W";
		if ((Period() < PERIOD_M30) || (Period() > PERIOD_H4))
		{
			Alert("Timeframe should be between M30 and H4 for a Weekly session.");
			InitFailed = true; // Soft INIT_FAILED.
		}
	}
	else if (Session == Monthly)
	{
		Suffix = "_M";
		if ((Period() < PERIOD_H1) || (Period() > PERIOD_D1))
		{
			Alert("Timeframe should be between H1 and D1 for a Monthly session.");
			InitFailed = true; // Soft INIT_FAILED.
		}
	}
	else if (Session == Intraday)
	{
		if (Period() > PERIOD_M15)
		{
			Alert("Timeframe should not be higher than M15 for an Intraday sessions.");
			InitFailed = true; // Soft INIT_FAILED.
		}

		IntradaySessionCount = 0;
		if (!CheckIntradaySession(EnableIntradaySession1, IntradaySession1StartTime, IntradaySession1EndTime, IntradaySession1ColorScheme)) return(INIT_PARAMETERS_INCORRECT);
		if (!CheckIntradaySession(EnableIntradaySession2, IntradaySession2StartTime, IntradaySession2EndTime, IntradaySession2ColorScheme)) return(INIT_PARAMETERS_INCORRECT);
		if (!CheckIntradaySession(EnableIntradaySession3, IntradaySession3StartTime, IntradaySession3EndTime, IntradaySession3ColorScheme)) return(INIT_PARAMETERS_INCORRECT);
		if (!CheckIntradaySession(EnableIntradaySession4, IntradaySession4StartTime, IntradaySession4EndTime, IntradaySession4ColorScheme)) return(INIT_PARAMETERS_INCORRECT);
		
		if (IntradaySessionCount == 0)
		{
			Alert("Enable at least one intraday session if you want to use Intraday mode.");
			InitFailed = true; // Soft INIT_FAILED.
		}
	}

   IndicatorShortName("MarketProfile " + EnumToString(Session));

	// Based on number of digits in PointMultiplier. -1 because if PointMultiplier < 10, it does not modify the number of digits.
   DigitsM = _Digits - (StringLen(IntegerToString(PointMultiplier)) - 1);
	onetick = NormalizeDouble(_Point * PointMultiplier, DigitsM);

   // Adjust for TickSize granularity if needed.
   double TickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   if (onetick < TickSize)
   {
      DigitsM = _Digits - (StringLen(IntegerToString((int)MathRound(TickSize / _Point))) - 1);
      onetick = NormalizeDouble(TickSize, DigitsM);
   }
	
	CurrentColorScheme = ColorScheme;
	
	// To clean up potential leftovers when applying a chart template.
	ObjectCleanup();
	
	return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectCleanup();
}

//+------------------------------------------------------------------+
//| Custom Market Profile main iteration function                    |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time_timeseries[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[]
)
{
	if (InitFailed)
	{
	   Print("Initialization failed. Please see the alert message for details.");
	   return(0);
	}
	
	if (StartFromCurrentSession) StartDate = Time[0];
	else StartDate = StartFromDate;

   // Adjust if Ignore_Saturday_Sunday is set.
   if (SaturdaySunday == Ignore_Saturday_Sunday)
   {
      // Saturday? Switch to Friday.
      if (TimeDayOfWeek(StartDate) == 6) StartDate -= 86400;
      // Sunday? Switch to Friday too.
      else if (TimeDayOfWeek(StartDate) == 0) StartDate -= 2 * 86400;
   }

	// If we calculate profiles for the past sessions, no need to run it again.
	if ((FirstRunDone) && (StartDate != Time[0])) return(0);

   // Delay the update of Market Profile if ThrottleRedraw is given.
   if ((ThrottleRedraw > 0) && (Timer > 0))
   {
      if ((int)TimeLocal() - Timer < ThrottleRedraw) return(rates_total);
   }

   // Recalculate everything if there were missing bars or something like that.
   if (rates_total - prev_calculated > 1)
   {
      //Print("RUNNING AGAIN");
      FirstRunDone = false;
      ObjectCleanup();
   }

	// Get start and end bar numbers of the given session.
	int sessionend = FindSessionEndByDate(StartDate);

	int sessionstart = FindSessionStart(sessionend);
   if (sessionstart == -1)
   {
      Print("Something went wrong! Waiting for data to load.");
      return(prev_calculated);
   }

	int SessionToStart = 0;
	// If all sessions have already been counted, jump to the current one.
	if (FirstRunDone) SessionToStart = _SessionsToCount - 1;
	else
	{
		// Move back to the oldest session to count to start from it.
		for (int i = 1; i < _SessionsToCount; i++)
		{
			sessionend = sessionstart + 1;
			if (sessionend >= Bars) return(prev_calculated);
			if (SaturdaySunday == Ignore_Saturday_Sunday)
			{
			   // Pass through Sunday and Saturday.
			   while ((TimeDayOfWeek(Time[sessionend]) == 0) || (TimeDayOfWeek(Time[sessionend]) == 6))
			   {
			      sessionend++;
			      if (sessionend >= Bars) break;
			   }
			}
			sessionstart = FindSessionStart(sessionend);
		}
	}

	// We begin from the oldest session coming to the current session or to StartFromDate.
	for (int i = SessionToStart; i < _SessionsToCount; i++)
	{
      if (Session == Intraday)
      {
         if (!ProcessIntradaySession(sessionstart, sessionend, i)) return(0);
      }
      else
      {
         if (Session == Daily) Max_number_of_bars_in_a_session = PeriodSeconds(PERIOD_D1) / PeriodSeconds();
         else if (Session == Weekly) Max_number_of_bars_in_a_session = 604800 / PeriodSeconds();
         else if (Session == Monthly) Max_number_of_bars_in_a_session = 2678400 / PeriodSeconds();
         if (SaturdaySunday == Append_Saturday_Sunday)
         {
            // The start is on Sunday - add remaining time.
            if (TimeDayOfWeek(Time[sessionstart]) == 0) Max_number_of_bars_in_a_session += (24 * 3600 - (TimeHour(Time[sessionstart]) * 3600 + TimeMinute(Time[sessionstart]) * 60)) / PeriodSeconds();
            // The end is on Saturday. +1 because even 0:00 bar deserves a bar. 
            if (TimeDayOfWeek(Time[sessionend]) == 6) Max_number_of_bars_in_a_session += ((TimeHour(Time[sessionend]) * 3600 + TimeMinute(Time[sessionend]) * 60)) / PeriodSeconds() + 1;
         }
         if (!ProcessSession(sessionstart, sessionend, i)) return(0);
      }

		// Go to the newer session only if there is one or more left.
		if (_SessionsToCount - i > 1)
		{
			sessionstart = sessionend - 1;
			if (SaturdaySunday == Ignore_Saturday_Sunday)
			{
			   // Pass through Sunday and Saturday.
			   while ((TimeDayOfWeek(Time[sessionstart]) == 0) || (TimeDayOfWeek(Time[sessionstart]) == 6))
			   {
			      sessionstart--;
			      if (sessionstart == 0) break;
			   }
			}
			sessionend = FindSessionEndByDate(Time[sessionstart]);
		}
	}

   if ((ShowValueAreaRays != None) || (ShowMedianRays != None)) CheckRays();

	FirstRunDone = true;

   Timer = (int)TimeLocal();

	return(rates_total);
}

//+------------------------------------------------------------------+
//| Finds the session's starting bar number for any given bar number.|
//| n - bar number for which to find starting bar. 					   |
//+------------------------------------------------------------------+
int FindSessionStart(const int n)
{
	if (Session == Daily) return(FindDayStart(n));
	else if (Session == Weekly) return(FindWeekStart(n));
	else if (Session == Monthly) return(FindMonthStart(n));
	else if (Session == Intraday)
	{
	   // A special case when Append_Saturday_Sunday is on and n is on Monday.
	   if ((SaturdaySunday == Append_Saturday_Sunday) && (TimeDayOfWeek(Time[n] + TimeShiftMinutes * 60) == 1))
	   {
   	   // One of the intraday sessions should start at 00:00 or have end < start.
   	   for (int intraday_i = 0; intraday_i < IntradaySessionCount; intraday_i++)
         {
            if ((IDStartTime[intraday_i] == 0) || (IDStartTime[intraday_i] > IDEndTime[intraday_i]))
            {
               // "Monday" part of the day. Effective only for "end < start" sessions.
               if ((TimeHour(Time[n]) * 60 + TimeMinute(Time[n]) >= IDEndTime[intraday_i]) && (IDStartTime[intraday_i] > IDEndTime[intraday_i]))
               {
                  // Find the first bar on Monday after the borderline session.
               	int x = n;
               	
               	while ((x < Bars) && (TimeHour(Time[x]) * 60 + TimeMinute(Time[x]) >= IDEndTime[intraday_i]))
               	{
               		x++;
               		// If there is no Sunday session (stepped into Saturday or another non-Sunday/non-Monday day, return normal day start.
               		if (TimeDayOfWeek(Time[x] + TimeShiftMinutes * 60) > 1) return(FindDayStart(n));
                  }
                  return(x - 1);
               }
               else 
               {
                  // Find the first Sunday bar.
               	int x = n;
               	
               	while ((x < Bars) && ((TimeDayOfYear(Time[n] + TimeShiftMinutes * 60) == TimeDayOfYear(Time[x] + TimeShiftMinutes * 60)) || (TimeDayOfWeek(Time[x] + TimeShiftMinutes * 60) == 0)))
               	{
               		x++;
                  }
                  // Number of sessions should be increased as we "lose" one session to Sunday.
                  _SessionsToCount++;
                  return(x - 1);
               }
            }
         }         
      }	   
	   
	   return(FindDayStart(n));
	}	
	return(-1);
}

//+------------------------------------------------------------------+
//| Finds the day's starting bar number for any given bar number.    |
//| n - bar number for which to find starting bar. 					   |
//+------------------------------------------------------------------+
int FindDayStart(const int n)
{
	if (n >= Bars) return(-1);
	int x = n;
	int time_x_day_of_week = TimeDayOfWeek(Time[x] + TimeShiftMinutes * 60);
	int time_n_day_of_week = time_x_day_of_week;
	
	// Condition should pass also if Append_Saturday_Sunday is on and it is Sunday or it is Friday but the bar n is on Saturday.
	while ((TimeDayOfYear(Time[n] + TimeShiftMinutes * 60) == TimeDayOfYear(Time[x] + TimeShiftMinutes * 60)) || ((SaturdaySunday == Append_Saturday_Sunday) && ((time_x_day_of_week == 0) || ((time_x_day_of_week == 5) && (time_n_day_of_week == 6)))))
	{
		x++;
		if (x >= Bars) break;
		time_x_day_of_week = TimeDayOfWeek(Time[x] + TimeShiftMinutes * 60);
   }
   
	return(x - 1);
}

//+------------------------------------------------------------------+
//| Finds the week's starting bar number for any given bar number.   |
//| n - bar number for which to find starting bar. 					   |
//+------------------------------------------------------------------+
int FindWeekStart(const int n)
{
	if (n >= Bars) return(-1);
	int x = n;
   int time_x_day_of_week = TimeDayOfWeek(Time[x] + TimeShiftMinutes * 60);

	// Condition should pass also if Append_Saturday_Sunday is on and it is Sunday.
	while ((SameWeek(Time[n] + TimeShiftMinutes * 60, Time[x] + TimeShiftMinutes * 60)) || ((SaturdaySunday == Append_Saturday_Sunday) && (time_x_day_of_week == 0)))
	{
		// If Ignore_Saturday_Sunday is on and we stepped into Sunday, stop.
		if ((SaturdaySunday == Ignore_Saturday_Sunday) && (time_x_day_of_week == 0)) break;
		x++;
		if (x >= Bars) break;
		time_x_day_of_week = TimeDayOfWeek(Time[x] + TimeShiftMinutes * 60);
   }
   
	return(x - 1);
}

//+------------------------------------------------------------------+
//| Finds the month's starting bar number for any given bar number.  |
//| n - bar number for which to find starting bar. 					   |
//+------------------------------------------------------------------+
int FindMonthStart(const int n)
{
	if (n >= Bars) return(-1);
	int x = n;
   int time_x_day_of_week = TimeDayOfWeek(Time[x] + TimeShiftMinutes * 60);
   // These don't change:
   int time_n_day_of_week = TimeDayOfWeek(Time[n] + TimeShiftMinutes * 60);
   int time_n_day = TimeDay(Time[n] + TimeShiftMinutes * 60);
   int time_n_month = TimeMonth(Time[n] + TimeShiftMinutes * 60);
	
	// Condition should pass also if Append_Saturday_Sunday is on and it is Sunday or Saturday the 1st day of month.
	while ((time_n_month == TimeMonth(Time[x] + TimeShiftMinutes * 60)) || ((SaturdaySunday == Append_Saturday_Sunday) && ((time_x_day_of_week == 0) || ((time_n_day_of_week == 6) && (time_n_day == 1)))))
	{
      // If month distance somehow becomes greater than 1, break.
      int month_distance = time_n_month - TimeMonth(Time[x] + TimeShiftMinutes * 60);
      if (month_distance < 0) month_distance = 12 - month_distance;
      if (month_distance > 1) break;
      // Check if Append_Saturday_Sunday is on and today is Saturday the 1st day of month. Despite it being current month, it should be skipped because it is appended to the previous month. Unless it is the sessionend day, which is the Saturday of the next month attached to this session.
		if (SaturdaySunday == Append_Saturday_Sunday)
		{
		   if ((time_x_day_of_week == 6) && (TimeDay(Time[x] + TimeShiftMinutes * 60) == 1) && (time_n_day != TimeDay(Time[x] + TimeShiftMinutes * 60))) break;
		}
      // Check if Ignore_Saturday_Sunday is on and today is Sunday or Saturday the 2nd or the 1st day of month. Despite it being current month, it should be skipped because it is ignored.
		if (SaturdaySunday == Ignore_Saturday_Sunday)
		{
		   if (((time_x_day_of_week == 0) || (time_x_day_of_week == 6)) && ((TimeDay(Time[x] + TimeShiftMinutes * 60) == 1) || (TimeDay(Time[x] + TimeShiftMinutes * 60) == 2))) break;
		}
		x++;
		if (x >= Bars) break;
		time_x_day_of_week = TimeDayOfWeek(Time[x] + TimeShiftMinutes * 60);
   }

	return(x - 1);
}

//+------------------------------------------------------------------+
//| Finds the session's end bar by the session's date.					|
//+------------------------------------------------------------------+
int FindSessionEndByDate(const datetime date)
{
	if (Session == Daily) return(FindDayEndByDate(date));
	else if (Session == Weekly) return(FindWeekEndByDate(date));
	else if (Session == Monthly) return(FindMonthEndByDate(date));
	else if (Session == Intraday)
	{
	   // A special case when Append_Saturday_Sunday is on and the date is on Sunday.
	   if ((SaturdaySunday == Append_Saturday_Sunday) && (TimeDayOfWeek(date + TimeShiftMinutes * 60) == 0))
	   {
   	   // One of the intraday sessions should start at 00:00 or have end < start.
   	   for (int intraday_i = 0; intraday_i < IntradaySessionCount; intraday_i++)
         {
            if ((IDStartTime[intraday_i] == 0) || (IDStartTime[intraday_i] > IDEndTime[intraday_i]))
            {
               // Find the last bar of this intraday session and return it as sessionend.
            	int x = 0;
               int abs_day = TimeAbsoluteDay(date + TimeShiftMinutes * 60);
            	// TimeAbsoluteDay is used for cases when the given date is Dec 30 (#364) and the current date is Jan 1 (#1) for example.
            	while ((x < Bars) && (abs_day < TimeAbsoluteDay(Time[x] + TimeShiftMinutes * 60))) // It's Sunday.
            	{
            		// On Monday.
            		if (TimeAbsoluteDay(Time[x] + TimeShiftMinutes * 60) == abs_day + 1)
            		{
               		// Inside the session.
               		if (TimeHour(Time[x]) * 60 +  TimeMinute(Time[x]) < IDEndTime[intraday_i]) break;
               		// Break out earlier (on Monday's end bar) if working with 00:00-XX:XX session.
               		if (IDStartTime[intraday_i] == 0) break; 
                  }
            		x++;
               }
            	return(x);
            }
         }
      }
	   return(FindDayEndByDate(date));
	}
	
	return(-1);
}

//+------------------------------------------------------------------+
//| Finds the day's end bar by the day's date.								|
//+------------------------------------------------------------------+
int FindDayEndByDate(const datetime date)
{
	int x = 0;

	// TimeAbsoluteDay is used for cases when the given date is Dec 30 (#364) and the current date is Jan 1 (#1) for example.
	while ((x < Bars) && (TimeAbsoluteDay(date + TimeShiftMinutes * 60) < TimeAbsoluteDay(Time[x] + TimeShiftMinutes * 60)))
	{
      // Check if Append_Saturday_Sunday is on and if the found end of the day is on Saturday and the given date is the previous Friday; or it is a Monday and the sought date is the previous Sunday.
		if (SaturdaySunday == Append_Saturday_Sunday)
		{
		   if (((TimeDayOfWeek(Time[x] + TimeShiftMinutes * 60) == 6) || (TimeDayOfWeek(Time[x] + TimeShiftMinutes * 60) == 1)) && (TimeAbsoluteDay(Time[x] + TimeShiftMinutes * 60) - TimeAbsoluteDay(date + TimeShiftMinutes * 60) == 1)) break;
		}
		x++;
   }
   
	return(x);
}

//+------------------------------------------------------------------+
//| Finds the week's end bar by the week's date.							|
//+------------------------------------------------------------------+
int FindWeekEndByDate(const datetime date)
{
	int x = 0;
   int time_x_day_of_week = TimeDayOfWeek(Time[x] + TimeShiftMinutes * 60);

	// Condition should pass also if Append_Saturday_Sunday is on and it is Sunday; and also if Ignore_Saturday_Sunday is on and it is Saturday or Sunday.
	while ((SameWeek(date + TimeShiftMinutes * 60, Time[x] + TimeShiftMinutes * 60) != true) || ((SaturdaySunday == Append_Saturday_Sunday) && (time_x_day_of_week == 0))  || ((SaturdaySunday == Ignore_Saturday_Sunday) && ((time_x_day_of_week == 0) || (time_x_day_of_week == 6))))
	{
		x++;
		if (x >= Bars) break;
      time_x_day_of_week = TimeDayOfWeek(Time[x] + TimeShiftMinutes * 60);
   }
   
	return(x);
}

//+------------------------------------------------------------------+
//| Finds the month's end bar by the month's date.							|
//+------------------------------------------------------------------+
int FindMonthEndByDate(const datetime date)
{
	int x = 0;
   int time_x_day_of_week = TimeDayOfWeek(Time[x] + TimeShiftMinutes * 60);

	// Condition should pass also if Append_Saturday_Sunday is on and it is Sunday; and also if Ignore_Saturday_Sunday is on and it is Saturday or Sunday.
	while ((SameMonth(date + TimeShiftMinutes * 60, Time[x] + TimeShiftMinutes * 60) != true) || ((SaturdaySunday == Append_Saturday_Sunday) && (time_x_day_of_week == 0))  || ((SaturdaySunday == Ignore_Saturday_Sunday) && ((time_x_day_of_week == 0) || (time_x_day_of_week == 6))))
	{
      // Check if Append_Saturday_Sunday is on.
		if (SaturdaySunday == Append_Saturday_Sunday)
		{
		   // Today is Saturday the 1st day of the next month. Despite it being in a next month, it should be appended to the current month.
		   if ((time_x_day_of_week == 6) && (TimeDay(Time[x] + TimeShiftMinutes * 60) == 1) && (TimeYear(Time[x] + TimeShiftMinutes * 60) * 12 + TimeMonth(Time[x] + TimeShiftMinutes * 60) - TimeYear(date + TimeShiftMinutes * 60) * 12 - TimeMonth(date + TimeShiftMinutes * 60) == 1)) break;
		   // Given date is Sunday of a previous month. It was rejected in the previous month and should be appended to beginning of this one.
		   // Works because date here can be only the end or the beginning of the month.
		   if ((TimeDayOfWeek(date + TimeShiftMinutes * 60) == 0) && (TimeYear(Time[x] + TimeShiftMinutes * 60) * 12 + TimeMonth(Time[x] + TimeShiftMinutes * 60) - TimeYear(date + TimeShiftMinutes * 60) * 12 - TimeMonth(date + TimeShiftMinutes * 60) == 1)) break;
		}
		x++;
		if (x >= Bars) break;
      time_x_day_of_week = TimeDayOfWeek(Time[x] + TimeShiftMinutes * 60);
   }
   
	return(x);
}

//+------------------------------------------------------------------+
//| Check if two dates are in the same week.									|
//+------------------------------------------------------------------+
int SameWeek(const datetime date1, const datetime date2)
{
	int seconds_from_start = TimeDayOfWeek(date1) * 24 * 3600 + TimeHour(date1) * 3600 + TimeMinute(date1) * 60 + TimeSeconds(date1);
	
	if (date1 == date2) return(true);
	else if (date2 < date1)
	{
		if (date1 - date2 <= seconds_from_start) return(true);
	}
	// 604800 - seconds in one week.
	else if (date2 - date1 < 604800 - seconds_from_start) return(true);

	return(false);
}

//+------------------------------------------------------------------+
//| Check if two dates are in the same month.								|
//+------------------------------------------------------------------+
int SameMonth(const datetime date1, const datetime date2)
{
	if ((TimeMonth(date1) == TimeMonth(date2)) && (TimeYear(date1) == TimeYear(date2))) return(true);
	return(false);
}

//+------------------------------------------------------------------+
//| Puts a dot (rectangle) at a given position and color. 			   |
//| price and time are coordinates.								 			   |
//| range is for the second coordinate.						 			   |
//| bar is to determine the color of the dot.				 			   |
//+------------------------------------------------------------------+
void PutDot(const double price, const int start_bar, const int range, const int bar)
{
	double divisor, color_shift;
	string LastName = " " + TimeToString(Time[start_bar - range]) + " " + DoubleToString(price, _Digits);
	if (ObjectFind(0, "MP" + Suffix + LastName) >= 0) return;

	// Protection from 'Array out of range' error.
	datetime time_end;
	if (start_bar - (range + 1) < 0) time_end = Time[0] + PeriodSeconds();
   else time_end = Time[start_bar - (range + 1)];
	
	ObjectCreate("MP" + Suffix + LastName, OBJ_RECTANGLE, 0, Time[start_bar - range], price, time_end, price - onetick);
	
	// Color switching depending on the distance of the bar from the session's beginning.
	int colour, offset1, offset2;
	switch(CurrentColorScheme)
	{
		case Blue_to_Red:
			colour = 0x00FF0000; // clrBlue;
			offset1 = 0x00010000;
			offset2 = 0x00000001;
		break;
		case Red_to_Green:
			colour = 0x000000FF; // clrDarkRed;
			offset1 = 0x00000001;
			offset2 = 0x00000100;
		break;
		case Green_to_Blue:
			colour = 0x0000FF00; // clrDarkGreen;
			offset1 = 0x00000100;
			offset2 = 0x00010000;
		break;
		case Yellow_to_Cyan:
			colour = 0x0000FFFF; // clrYellow;
			offset1 = 0x00000001;
			offset2 = 0x00010000;
		break;
		case Magenta_to_Yellow:
			colour = 0x00FF00FF; // clrMagenta;
			offset1 = 0x00010000;
			offset2 = 0x00000100;
		break;
		case Cyan_to_Magenta:
			colour = 0x00FFFF00; // clrCyan;
			offset1 = 0x00000100;
			offset2 = 0x00000001;
		break;
		case Single_Color:
			colour = SingleColor;
			offset1 = 0;
			offset2 = 0;
		break;
		default:
			colour = SingleColor;
			offset1 = 0;
			offset2 = 0;
		break;
	}

	// No need to do these calculations if plain color is used.
	if (CurrentColorScheme != Single_Color)
	{
   	divisor = 1.0 / 0xFF * (double)Max_number_of_bars_in_a_session;
   
   	// bar is negative.
   	color_shift = MathFloor((double)bar / divisor);
   
      // Prevents color overflow.
      if ((int)color_shift < -0xFF) color_shift = -0xFF;
   
   	colour += (int)color_shift * offset1;
   	colour -= (int)color_shift * offset2;
   }

	ObjectSet("MP" + Suffix + LastName, OBJPROP_COLOR, colour);
	// Fills rectangle.
	ObjectSet("MP" + Suffix + LastName, OBJPROP_BACK, true);
	ObjectSet("MP" + Suffix + LastName, OBJPROP_SELECTABLE, false);
	ObjectSet("MP" + Suffix + LastName, OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
//| Deletes all chart objects created by the indicator.              |
//+------------------------------------------------------------------+
void ObjectCleanup()
{
	// Delete all rectangles with set prefix.
	ObjectsDeleteAll(0, "MP" + Suffix, EMPTY, OBJ_RECTANGLE);
	ObjectsDeleteAll(0, "Median" + Suffix, EMPTY, OBJ_TREND);
	ObjectsDeleteAll(0, "Value Area" + Suffix, EMPTY, OBJ_RECTANGLE);
	if (ShowValueAreaRays != None)
	{
	   // Delete all trendlines with set prefix.
	   ObjectsDeleteAll(0, "Value Area HighRay" + Suffix, EMPTY, OBJ_TREND);
	   ObjectsDeleteAll(0, "Value Area LowRay" + Suffix, EMPTY, OBJ_TREND);
	}
	if (ShowMedianRays != None)
	{
	   // Delete all trendlines with set prefix.
	   ObjectsDeleteAll(0, "Median Ray" + Suffix, EMPTY, OBJ_TREND);
	}
}

//+------------------------------------------------------------------+
//| Extract hours and minutes from a time string.                    |
//| Returns false in case of an error.                               |
//+------------------------------------------------------------------+
bool GetHoursAndMinutes(string time_string, int& hours, int& minutes, int& time)
{
	if (StringLen(time_string) == 4) time_string = "0" + time_string;
	
	if ( 
		// Wrong length.
		(StringLen(time_string) != 5) ||
		// Wrong separator.
		(time_string[2] != ':') ||
		// Wrong first number (only 24 hours in a day).
		((time_string[0] < '0') || (time_string[0] > '2')) ||
		// 00 to 09 and 10 to 19.
		(((time_string[0] == '0') || (time_string[0] == '1')) && ((time_string[1] < '0') || (time_string[1] > '9'))) ||
		// 20 to 23.
		((time_string[0] == '2') && ((time_string[1] < '0') || (time_string[1] > '3'))) ||
		// 0M to 5M.
		((time_string[3] < '0') || (time_string[3] > '5')) ||
		// M0 to M9.
		((time_string[4] < '0') || (time_string[4] > '9'))
		)
   {
      Print("Wrong time string: ", time_string, ". Please use HH:MM format.");
      return(false);
   }

   string result[];
   int number_of_substrings = StringSplit(time_string, ':', result);
   hours = (int)StringToInteger(result[0]);
   minutes = (int)StringToInteger(result[1]);
   time = hours * 60 + minutes;
   
   return(true);
}

//+------------------------------------------------------------------+
//| Extract hours and minutes from a time string.                    |
//| Returns false in case of an error.                               |
//+------------------------------------------------------------------+
bool CheckIntradaySession(const bool enable, const string start_time, const string end_time, const color_scheme cs)
{
	if (enable)
	{
		if (!GetHoursAndMinutes(start_time, IDStartHours[IntradaySessionCount], IDStartMinutes[IntradaySessionCount], IDStartTime[IntradaySessionCount]))
		{
		   Alert("Wrong time string format: ", start_time, ".");
		   return(false);
		}
		if (!GetHoursAndMinutes(end_time, IDEndHours[IntradaySessionCount], IDEndMinutes[IntradaySessionCount], IDEndTime[IntradaySessionCount]))
		{
		   Alert("Wrong time string format: ", end_time, ".");
		   return(false);
		}
		// Special case of the intraday session ending at "00:00".
		if (IDEndTime[IntradaySessionCount] == 0)
		{
		   // Turn it into "24:00".
		   IDEndHours[IntradaySessionCount] = 24;
		   IDEndMinutes[IntradaySessionCount] = 0;
		   IDEndTime[IntradaySessionCount] = 24 * 60;
		}
		
		IDColorScheme[IntradaySessionCount] = cs;
		
		// For special case used only with Ignore_Saturday_Sunday on Monday.
		if (IDEndTime[IntradaySessionCount] < IDStartTime[IntradaySessionCount]) IntradayCrossSessionDefined = IntradaySessionCount;
		
		IntradaySessionCount++;
	}
	return(true);
}

//+------------------------------------------------------------------+
//| Main procedure to draw the Market Profile based on a session     |
//| start bar and session end bar.                                   |
//| i - session number with 0 being the oldest one.                  |
//| Returns true on success, false - on failure.                     |
//+------------------------------------------------------------------+
bool ProcessSession(const int sessionstart, const int sessionend, const int i)
{
   if (sessionstart >= Bars) return(false); // Data not yet ready.

	double SessionMax = DBL_MIN, SessionMin = DBL_MAX;
	
	// Find the session's high and low. 
	for (int bar = sessionstart; bar >= sessionend; bar--)
	{
		if (High[bar] > SessionMax) SessionMax = High[bar];
		if (Low[bar] < SessionMin) SessionMin = Low[bar];
	}
	SessionMax = NormalizeDouble(SessionMax, DigitsM);
	SessionMin = NormalizeDouble(SessionMin, DigitsM);
	
   int session_counter = i;
   // Find Time[sessionstart] among RememberSessionStart[].
   bool need_to_increment = true;
   for (int j = 0; j < SessionsNumber; j++)
   {
      if (RememberSessionStart[j] == Time[sessionstart])
      {
         need_to_increment = false;
         session_counter = j; // Real number of the session.
         break;
      }
   }
   // Raise the number of sessions and resize arrays.
   if (need_to_increment)
   {
      SessionsNumber++;
      session_counter = SessionsNumber - 1; // Newest session.
	   ArrayResize(RememberSessionMax, SessionsNumber);
	   ArrayResize(RememberSessionMin, SessionsNumber);
	   ArrayResize(RememberSessionStart, SessionsNumber);
	   ArrayResize(RememberSessionSuffix, SessionsNumber);
   }
   RememberSessionMax[session_counter] = SessionMax;
   RememberSessionMin[session_counter] = SessionMin;
   RememberSessionStart[session_counter] = Time[sessionstart];
   RememberSessionSuffix[session_counter] = Suffix;
	
	// Used to make sure that SessionMax increments only by 'onetick' increments.
	// This is needed only when updating the latest trading session and PointMultiplier > 1.
	static double PreviousSessionMax = DBL_MIN;
	static datetime PreviousSessionStartTime = 0;
   // Reset PreviousSessionMax when a new session becomes the 'latest one'.
	if (Time[sessionstart] > PreviousSessionStartTime)
	{
	   PreviousSessionMax = DBL_MIN;
	   PreviousSessionStartTime = Time[sessionstart];
	}
	if ((FirstRunDone) && (i == _SessionsToCount - 1) && (PointMultiplier > 1)) // Updating the latest trading session.
	{
	   if (SessionMax - PreviousSessionMax < onetick) // SessionMax increased only slightly - too small to use the new value with the current onetick.
	   {
	      SessionMax = PreviousSessionMax; // Do not update session max.
	   }
	   else
	   {
	      if (PreviousSessionMax != DBL_MIN)
	      {
	         // Calculate number of increments.
	         double nc = (SessionMax - PreviousSessionMax) / onetick;
	         // Adjust SessionMax.
	         SessionMax = NormalizeDouble(PreviousSessionMax + MathRound(nc) * onetick, DigitsM);
	      }
	      PreviousSessionMax = SessionMax;
	   }
	}
	
	int TPOperPrice[];
	// Possible price levels if multiplied to integer.
	int max = (int)MathRound((SessionMax - SessionMin) / onetick + 2); // + 2 because further we will be possibly checking array at SessionMax + 1.
	ArrayResize(TPOperPrice, max);
	ArrayInitialize(TPOperPrice, 0);

	int MaxRange = 0; // Maximum distance from session start to the drawn dot.
	double PriceOfMaxRange = 0; // Level of the maximum range, required to draw Median.
	double DistanceToCenter = DBL_MAX; // Closest distance to center for the Median.
	
	int TotalTPO = 0; // Total amount of dots (TPO's).
	
	// Going through all possible quotes from session's High to session's Low.
	for (double price = SessionMax; price >= SessionMin; price -= onetick)
	{
      price = NormalizeDouble(price, DigitsM);
		int range = 0; // Distance from first bar to the current bar.

		// Going through all bars of the session to see if the price was encountered here.
		for (int bar = sessionstart; bar >= sessionend; bar--)
		{
			// Price is encountered in the given bar
			if ((price >= Low[bar]) && (price <= High[bar]))
			{
				// Update maximum distance from session's start to the found bar (needed for Median).
				// Using the center-most Median if there are more than one.
				if ((MaxRange < range) || ((MaxRange == range) && (MathAbs(price - (SessionMin + (SessionMax - SessionMin) / 2)) < DistanceToCenter)))
				{
					MaxRange = range;
					PriceOfMaxRange = price;
					DistanceToCenter = MathAbs(price - (SessionMin + (SessionMax - SessionMin) / 2));
				}
				// Draws rectangle.
				PutDot(price, sessionstart, range, bar - sessionstart);
				// Remember the number of encountered bars for this price.
				int index = (int)MathRound((price - SessionMin) / onetick);
				TPOperPrice[index]++;
				range++;
				TotalTPO++;
			}
		}
	}

	double TotalTPOdouble = TotalTPO;
	// Calculate amount of TPO's in the Value Area.
	int ValueControlTPO = (int)MathRound(TotalTPOdouble * 0.7);
	// Start with the TPO's of the Median.
	int index = (int)((PriceOfMaxRange - SessionMin) / onetick);
   if (index < 0) return(false); // Data not yet ready.
	int TPOcount = TPOperPrice[index];

	// Go through the price levels above and below median adding the biggest to TPO count until the 70% of TPOs are inside the Value Area.
	int up_offset = 1;
	int down_offset = 1;
	while (TPOcount < ValueControlTPO)
	{
		double abovePrice = PriceOfMaxRange + up_offset * onetick;
		double belowPrice = PriceOfMaxRange - down_offset * onetick;
		// If belowPrice is out of the session's range then we should add only abovePrice's TPO's, and vice versa.
		index = (int)MathRound((abovePrice - SessionMin) / onetick);
		int index2 = (int)MathRound((belowPrice - SessionMin) / onetick);
		if (((belowPrice < SessionMin) || (TPOperPrice[index] >= TPOperPrice[index2])) && (abovePrice <= SessionMax))
		{
			TPOcount += TPOperPrice[index];
			up_offset++;
		}
		else if (belowPrice >= SessionMin)
		{
			TPOcount += TPOperPrice[index2];
			down_offset++;
		}
		// Cannot proceed - too few data points.
		else if (TPOcount < ValueControlTPO)
		{
		   break;
		}
	}
	string LastName = " " + TimeToStr(Time[sessionstart], TIME_DATE);
	// Delete old Median.
	if (ObjectFind(0, "Median" + Suffix + LastName) >= 0) ObjectDelete("Median" + Suffix + LastName);
	// Draw a new one.
	index = MathMax(sessionstart - MaxRange - 1, 0);
	ObjectCreate("Median" + Suffix + LastName, OBJ_TREND, 0, Time[sessionstart], PriceOfMaxRange, Time[index], PriceOfMaxRange);
	ObjectSet("Median" + Suffix + LastName, OBJPROP_COLOR, MedianColor);
	ObjectSet("Median" + Suffix + LastName, OBJPROP_STYLE, STYLE_SOLID);
	ObjectSet("Median" + Suffix + LastName, OBJPROP_BACK, false);
	ObjectSet("Median" + Suffix + LastName, OBJPROP_SELECTABLE, false);
	ObjectSet("Median" + Suffix + LastName, OBJPROP_HIDDEN, true);
	ObjectSet("Median" + Suffix + LastName, OBJPROP_RAY, false);
	
	// Delete old Value Area.
	if (ObjectFind(0, "Value Area" + Suffix + LastName) >= 0) ObjectDelete("Value Area" + Suffix + LastName);
	// Draw a new one.
	ObjectCreate("Value Area" + Suffix + LastName, OBJ_RECTANGLE, 0, Time[sessionstart], PriceOfMaxRange + up_offset * onetick, Time[index], PriceOfMaxRange - down_offset * onetick);
	ObjectSet("Value Area" + Suffix + LastName, OBJPROP_COLOR, ValueAreaColor);
	ObjectSet("Value Area" + Suffix + LastName, OBJPROP_STYLE, STYLE_SOLID);
	ObjectSet("Value Area" + Suffix + LastName, OBJPROP_BACK, false);
	ObjectSet("Value Area" + Suffix + LastName, OBJPROP_SELECTABLE, false);
	ObjectSet("Value Area" + Suffix + LastName, OBJPROP_HIDDEN, true);

   return(true);
}

//+------------------------------------------------------------------+
//| A cycle through intraday sessions for a given day with necessary |
//| checks.                                                          |
//| Returns true on success, false - on failure.                     |
//+------------------------------------------------------------------+
bool ProcessIntradaySession(int sessionstart, int sessionend, int i)
{
   // 'remember_*' vars point at day start and day end throughout this function.
   int remember_sessionstart = sessionstart;
   int remember_sessionend = sessionend;
   
   if (remember_sessionend >= Bars) return(false);
   
   // Special case stuff.
   bool ContinuePreventionFlag = false;

   // Start a cycle through intraday sessions if needed.
   // For each intraday session, find its own sessionstart and sessionend.
   int IntradaySessionCount_tmp = IntradaySessionCount;
   // If Ignore_Saturday_Sunday is on, day's start is on Monday, and there is a "22:00-06:00"-style intraday session defined, increase the counter to run the "later" "22:00-06:00" session and create this temporary dummy session.
   if ((SaturdaySunday == Ignore_Saturday_Sunday) && (TimeDayOfWeek(Time[remember_sessionstart]) == 1) && (IntradayCrossSessionDefined > -1))
   {
      IntradaySessionCount_tmp++;
   }

   for (int intraday_i = 0; intraday_i < IntradaySessionCount_tmp; intraday_i++)
   {
      // Continue was triggered during the special case iteration.
      if (ContinuePreventionFlag) break;
      // Special case iteration.
      if (intraday_i == IntradaySessionCount)
      {
         intraday_i = IntradayCrossSessionDefined;
         ContinuePreventionFlag = true;
      }
      Suffix = "_ID" + IntegerToString(intraday_i);
      CurrentColorScheme = IDColorScheme[intraday_i];
      // Get minutes.
      Max_number_of_bars_in_a_session = IDEndTime[intraday_i] - IDStartTime[intraday_i];
      // If end is less than beginning:
      if (Max_number_of_bars_in_a_session < 0)
      {
         Max_number_of_bars_in_a_session = 24 * 60 + Max_number_of_bars_in_a_session;
         if (SaturdaySunday == Ignore_Saturday_Sunday)
         {
            // Day start is on Monday. And it is not a special additional intra-Monday session.
            if ((TimeDayOfWeek(remember_sessionstart) == 1) && (!ContinuePreventionFlag))
            {
               // Cut out Sunday part.
               Max_number_of_bars_in_a_session -= 24 * 60 - IDStartTime[intraday_i];
            }
            // Day start is on Friday.
            else if (TimeDayOfWeek(remember_sessionstart) == 5)
            {
               // Cut out Saturday part.
               Max_number_of_bars_in_a_session -= IDEndTime[intraday_i];
            }
         }
      }
      
      // If Append_Saturday_Sunday is on:
      if (SaturdaySunday == Append_Saturday_Sunday)
      {
         // The intraday session starts on 00:00 or otherwise captures midnight, and remember_sessionstart points to Sunday:
         if (((IDStartTime[intraday_i] == 0) || (IDStartTime[intraday_i] > IDEndTime[intraday_i])) && (TimeDayOfWeek(Time[remember_sessionstart]) == 0))
         {
            // Add Sunday hours.
            Max_number_of_bars_in_a_session += 24 * 60 - (TimeHour(Time[remember_sessionstart]) * 60 + TimeMinute(Time[remember_sessionstart]));
            // Remove the part of Sunday that has already been added before.
            if (IDStartTime[intraday_i] > IDEndTime[intraday_i]) Max_number_of_bars_in_a_session -= 24 * 60 - IDStartTime[intraday_i];
         }
         // The intraday session ends on 00:00 or otherwise captures midnight, and remember_sessionstart points to Friday:
         else if (((IDEndTime[intraday_i] == 24 * 60) || (IDStartTime[intraday_i] > IDEndTime[intraday_i])) && (TimeDayOfWeek(Time[remember_sessionstart]) == 5))
         {
            // Add Saturday hours. The thing is we don't know how many hours there will be on Saturday. So add to max.
            Max_number_of_bars_in_a_session += 24 * 60;
            // Remove the part of Saturday that has already been added before.
            if (IDStartTime[intraday_i] > IDEndTime[intraday_i]) Max_number_of_bars_in_a_session -= 24 * 60 - IDEndTime[intraday_i];
         }
      }
      
      Max_number_of_bars_in_a_session = Max_number_of_bars_in_a_session / (PeriodSeconds() / 60);
      
      // If it is the updating stage, we need to recalculate only those intraday sessions that include the current bar.
      int hour, minute, time;
      if (FirstRunDone)
      {
         //sessionstart = day_start;
         hour = TimeHour(Time[0]);
         minute = TimeMinute(Time[0]);
         time = hour * 60 + minute;
      
         // For example, 13:00-18:00.
         if (IDStartTime[intraday_i] < IDEndTime[intraday_i])
         {
            if (SaturdaySunday == Append_Saturday_Sunday)
            {
               // Skip all sessions that do not absorb Sunday session:
               if ((IDStartTime[intraday_i] != 0) && (TimeDayOfWeek(Time[0]) == 0)) continue;
               // Skip all sessions that do not absorb Saturday session:
               if ((IDEndTime[intraday_i] != 24 * 60) && (TimeDayOfWeek(Time[0]) == 6)) continue;
            }
            // If Append_Saturday_Sunday is on and the session starts on 00:00, and now is either Sunday or Monday before the session's end:
            if ((SaturdaySunday == Append_Saturday_Sunday) && (IDStartTime[intraday_i] == 0) && ((TimeDayOfWeek(Time[0]) == 0) || ((TimeDayOfWeek(Time[0]) == 1) && (time < IDEndTime[intraday_i]))))
            {
               // Then we can use remember_sessionstart as the session's start.
               sessionstart = remember_sessionstart;
            }
            else if (((time < IDEndTime[intraday_i]) && (time >= IDStartTime[intraday_i]))
            // If Append_Saturday_Sunday is on and the session ends on 24:00, and now is Saturday, then go on in case, for example, of 18:00 Saturday time and 16:00-00:00 defined session.
            || ((SaturdaySunday == Append_Saturday_Sunday) && (IDEndTime[intraday_i] == 24 * 60) && (TimeDayOfWeek(Time[0]) == 6)))
            {
               sessionstart = 0;
               int sessiontime = TimeHour(Time[sessionstart]) * 60 + TimeMinute(Time[sessionstart]);
               while (((sessiontime > IDStartTime[intraday_i]) 
               // Prevents problems when the day has partial data (e.g. Sunday) when neither appending not ignoring Saturday/Sunday. Alternatively, continue looking for the sessionstart bar if we moved from Saturday to Friday with Append_Saturday_Sunday and for XX:XX-00:00 session.
               && ((TimeDayOfYear(Time[sessionstart]) == TimeDayOfYear(Time[0])) || ((SaturdaySunday == Append_Saturday_Sunday) && (IDEndTime[intraday_i] == 24 * 60) && (TimeDayOfWeek(Time[0]) == 6))))
               // If Append_Saturday_Sunday is on and the session ends on 24:00 and the session start is now going through Saturday, then go on in case, for example, of 13:00 Saturday time and 16:00-00:00 defined session.
               || ((SaturdaySunday == Append_Saturday_Sunday) && (IDEndTime[intraday_i] == 24 * 60) && (TimeDayOfWeek(Time[sessionstart]) == 6)))
               {
                  sessionstart++;
                  sessiontime = TimeHour(Time[sessionstart]) * 60 + TimeMinute(Time[sessionstart]);
               }
               // This check is necessary because sessionsart may pass to the wrong day in some cases.
               if (sessionstart > remember_sessionstart) sessionstart = remember_sessionstart;
            }
            else continue;
         }
         // For example, 22:00-6:00.
         else if (IDStartTime[intraday_i] > IDEndTime[intraday_i])
         {
            // If Append_Saturday_Sunday is on and now is either Sunday or Monday before the session's end:
            if ((SaturdaySunday == Append_Saturday_Sunday) && ((TimeDayOfWeek(Time[0]) == 0) || ((TimeDayOfWeek(Time[0]) == 1) && (time < IDEndTime[intraday_i]))))
            {
               // Then we can use remember_sessionstart as the session's start.
               sessionstart = remember_sessionstart;
            }
            // If Ignore_Saturday_Sunday is on and it is Monday before the session's end:
            else if ((SaturdaySunday == Ignore_Saturday_Sunday) && (TimeDayOfWeek(Time[0]) == 1) && (time < IDEndTime[intraday_i]))
            {
               // Then we can use remember_sessionstart as the session's start.
               sessionstart = remember_sessionstart;
            }
            else if (((time < IDEndTime[intraday_i]) || (time >= IDStartTime[intraday_i]))
            // If Append_Saturday_Sunday is on and now is Saturday, then go on in case, for example, of 18:00 Saturday time and 22:00-06:00 defined session.
            || ((SaturdaySunday == Append_Saturday_Sunday) && (TimeDayOfWeek(Time[0]) == 6)))
            {
               sessionstart = 0;
               int sessiontime = TimeHour(Time[sessionstart]) * 60 + TimeMinute(Time[sessionstart]);
               // Within 24 hours of the current time - but can be today or yesterday.
               while(((sessiontime > IDStartTime[intraday_i]) && (Time[0] - Time[sessionstart] <= 3600 * 24)) 
               // Same day only.
               || ((sessiontime < IDEndTime[intraday_i]) && (TimeDayOfYear(Time[sessionstart]) == TimeDayOfYear(Time[0])))
               // If Append_Saturday_Sunday is on and the session start is now going through Saturday, then go on in case, for example, of 18:00 Saturday time and 22:00-06:00 defined session.
               || ((SaturdaySunday == Append_Saturday_Sunday) && (TimeDayOfWeek(Time[sessionstart]) == 6)))
               {
                  sessionstart++;
                  sessiontime = TimeHour(Time[sessionstart]) * 60 + TimeMinute(Time[sessionstart]);
               }
               // When the same condition in the above while cycle fails and sessionstart is one step farther than needed.
               if (Time[0] - Time[sessionstart] > 3600 * 24) sessionstart--;
            }
            else continue;
         }
         // If start time equals end time, we can skip the session.
         else continue;
         
         // Because apparently, we are still inside the session.
         sessionend = 0;

         if (!ProcessSession(sessionstart, sessionend, i)) return(false);
      }
      // If it is the first run.
      else
      {
         sessionend = remember_sessionend;
         // Process the sessions that start today.
         // For example, 13:00-18:00.
         if (IDStartTime[intraday_i] < IDEndTime[intraday_i])
         {
            // If Append_Saturday_Sunday is on and the session ends on 24:00, and day's start is on Friday and day's end is on Saturday, then do not trigger 'continue' in case, for example, of 15:00 Saturday end and 16:00-00:00 defined session.
            if ((SaturdaySunday == Append_Saturday_Sunday)/* && (IDEndTime[intraday_i] == 24 * 60)*/ && (TimeDayOfWeek(Time[remember_sessionend]) == 6) && (TimeDayOfWeek(Time[remember_sessionstart]) == 5))
            {
            }
            // Intraday session starts after the today's actual session ended (for Friday/Saturday cases).
            else if (TimeHour(Time[remember_sessionend]) * 60 + TimeMinute(Time[remember_sessionend]) < IDStartTime[intraday_i]) continue;
            // If Append_Saturday_Sunday is on and the session starts on 00:00, and the session end points to Sunday or end points to Monday and start points to Sunday, then do not trigger 'continue' in case, for example, of 18:00 Sunday start and 00:00-16:00 defined session.
            if ((SaturdaySunday == Append_Saturday_Sunday) && (((IDStartTime[intraday_i] == 0) && (TimeDayOfWeek(Time[remember_sessionend]) == 0)) || ((TimeDayOfWeek(Time[remember_sessionend]) == 1) && (TimeDayOfWeek(Time[remember_sessionstart]) == 0))))
            {
            }
            // Intraday session ends before the today's actual session starts (for Sunday cases).
            else if (TimeHour(Time[remember_sessionstart]) * 60 + TimeMinute(Time[remember_sessionstart]) >= IDEndTime[intraday_i]) continue;
            // If Append_Saturday_Sunday is on and the session ends on 24:00, and the start points to Friday:
            if ((SaturdaySunday == Append_Saturday_Sunday) && (IDEndTime[intraday_i] == 24 * 60) && (TimeDayOfWeek(Time[sessionstart]) == 5))
            {
               // We already have sessionend right because it is the same as remember_sessionend (end of Saturday).
            }
            // If Append_Saturday_Sunday is on and the session starts on 00:00 and the session end points to Sunday (it is current Sunday session , no Monday bars yet):
            else if ((SaturdaySunday == Append_Saturday_Sunday) && (IDStartTime[intraday_i] == 0) && (TimeDayOfWeek(Time[sessionend]) == 0))
            {
               // We already have sessionend right because it is the same as remember_sessionend (current bar and it is on Sunday).
            }
            // Otherwise find the session end.
            else while((sessionend < Bars) && ((TimeHour(Time[sessionend]) * 60 + TimeMinute(Time[sessionend]) >= IDEndTime[intraday_i]) || ((TimeDayOfWeek(Time[sessionend]) == 6) && (SaturdaySunday == Append_Saturday_Sunday))))
            {
               sessionend++;
            }
            if (sessionend == Bars) sessionend--;

            // If Append_Saturday_Sunday is on and the session starts on 00:00 and the session start is now going through Sunday:
            if ((SaturdaySunday == Append_Saturday_Sunday) && (IDStartTime[intraday_i] == 0) && (TimeDayOfWeek(Time[sessionstart]) == 0))
            {
               // We already have sessionstart right because it is the same as remember_sessionstart (start of Sunday).
               sessionstart = remember_sessionstart;
            }
            else
            {
               sessionstart = sessionend;
               while ((sessionstart < Bars) && (((TimeHour(Time[sessionstart]) * 60 + TimeMinute(Time[sessionstart]) >= IDStartTime[intraday_i])
               // Same day - for cases when the day does not contain intraday session start time. Alternatively, continue looking for the startsession bar if we moved from Saturday to Friday with Append_Saturday_Sunday and for XX:XX-00:00 session.
               && ((TimeDayOfYear(Time[sessionstart]) == TimeDayOfYear(Time[sessionend])) || ((SaturdaySunday == Append_Saturday_Sunday) && (IDEndTime[intraday_i] == 24 * 60) && (TimeDayOfWeek(Time[sessionend]) == 6))))
               // If Append_Saturday_Sunday is on and the session ends on 24:00, and the session start is now going through Saturday, then go on in case, for example, of 15:00 Saturday end and 16:00-00:00 defined session.
               || ((SaturdaySunday == Append_Saturday_Sunday) && (IDEndTime[intraday_i] == 24 * 60) && (TimeDayOfWeek(Time[sessionstart]) == 6))))
               {
                  sessionstart++;
               }
               sessionstart--;
            }
         }
         // For example, 22:00-6:00.
         else if (IDStartTime[intraday_i] > IDEndTime[intraday_i])
         {
            // If Append_Saturday_Sunday is on and the start points to Friday, then do not trigger 'continue' in case, for example, of 15:00 Saturday end and 22:00-06:00 defined session.
            if ((SaturdaySunday == Append_Saturday_Sunday) && (((TimeDayOfWeek(Time[sessionstart]) == 5) && (TimeDayOfWeek(Time[remember_sessionend]) == 6)) || ((TimeDayOfWeek(Time[sessionstart]) == 0) && (TimeDayOfWeek(Time[remember_sessionend]) == 1))))
            {
            }
            // Today's intraday session starts after the end of the actual session (for Friday/Saturday cases).
            else if (TimeHour(Time[remember_sessionend]) * 60 + TimeMinute(Time[remember_sessionend]) < IDStartTime[intraday_i]) continue;

            // If Append_Saturday_Sunday is on and the session start is on Sunday:
            if ((SaturdaySunday == Append_Saturday_Sunday) && (TimeDayOfWeek(Time[sessionstart]) == 0))
            {
               // We already have sessionstart right because it is the same as remember_sessionstart (start of Sunday).
               sessionstart = remember_sessionstart;
            }
            // If Ignore_Saturday_Sunday is on and it is Monday: (and it is not a special additional intra-Monday session.)
            else if ((SaturdaySunday == Ignore_Saturday_Sunday) && (TimeDayOfWeek(Time[remember_sessionstart]) == 1) && (!ContinuePreventionFlag))
            {
               // Then we can use remember_sessionstart as the session's start.
               sessionstart = remember_sessionstart;
               // Monday starts on 7:00 and we have 22:00-6:00. Skip it.
               if (TimeHour(Time[sessionstart]) * 60 + TimeMinute(Time[sessionstart]) >= IDEndTime[intraday_i]) continue;
            }
            else
            {
               // Find starting bar.
               sessionstart = remember_sessionend; // Start from the end.
               while ((sessionstart < Bars) && (((TimeHour(Time[sessionstart]) * 60 + TimeMinute(Time[sessionstart]) >= IDStartTime[intraday_i])
               // Same day - for cases when the day does not contain intraday session start time.
               && ((TimeDayOfYear(Time[sessionstart]) == TimeDayOfYear(Time[remember_sessionend])) || (TimeDayOfYear(Time[sessionstart]) == TimeDayOfYear(Time[remember_sessionstart])) ))
               // If Append_Saturday_Sunday is on and the session start is now going through Saturday, then go on in case, for example, of 15:00 Saturday end and 22:00-06:00 defined session.
               || ((SaturdaySunday == Append_Saturday_Sunday) && (TimeDayOfWeek(Time[sessionstart]) == 6))
               ))
               {
                  sessionstart++;
               }
               sessionstart--;
            }

            int sessionlength; // In seconds.
            // If Append_Saturday_Sunday is on and the end points to Saturday, don't go through this calculation because sessionend = remember_sessionend.
            if ((SaturdaySunday == Append_Saturday_Sunday) && (TimeDayOfWeek(Time[sessionend]) == 6))
            {
               // We already have sessionend right because it is the same as remember_sessionend (end of Saturday).
            }
            // If Append_Saturday_Sunday is on and the start points to Sunday, use a simple method to find the end.
            else if ((SaturdaySunday == Append_Saturday_Sunday) && (TimeDayOfWeek(Time[sessionstart]) == 0))
            {
               // While we are on Monday and sessionend is pointing on bar after IDEndTime.
               while((sessionend < Bars) && (TimeDayOfWeek(Time[sessionend]) == 1) && (TimeHour(Time[sessionend]) * 60 + TimeMinute(Time[sessionend]) >= IDEndTime[intraday_i]))
               {
                  sessionend++;
               }
            }
            // If Ignore_Saturday_Sunday is on and the session starts on Friday:
            else if ((SaturdaySunday == Ignore_Saturday_Sunday) && (TimeDayOfWeek(Time[remember_sessionstart]) == 5))
            {
               // Then it also ends on Friday.
               sessionend = remember_sessionend;
            }
            else
            {
               sessionend = sessionstart;
               sessionlength = (24 * 60 - IDStartTime[intraday_i] + IDEndTime[intraday_i]) * 60;
               // If ignoring Sundays and session start is on Monday, cut out Sunday part of the intraday session. And it is not a special additional intra-Monday session.
               if ((SaturdaySunday == Ignore_Saturday_Sunday) && (TimeDayOfWeek(Time[sessionstart]) == 1) && (!ContinuePreventionFlag)) sessionlength -= (24 * 60 - IDStartTime[intraday_i]) * 60;
               while((sessionend >= 0) && (Time[sessionend] - Time[sessionstart] < sessionlength))
               {
                  sessionend--;
               }
               sessionend++;
            }
         }
         // If start time equals end time, we can skip the session.
         else continue;

         if (sessionend == sessionstart) continue; // No need to process such an intraday session.

         if (!ProcessSession(sessionstart, sessionend, i)) return(false);
      }
   }
   Suffix = "_ID";
   
   return(true);
}

//+------------------------------------------------------------------+
//| Returns absolute day number.                                     |
//+------------------------------------------------------------------+
int TimeAbsoluteDay(const datetime time)
{
   return((int)time / 86400);
}

//+------------------------------------------------------------------+
//| Checks whether Median/VA rays are required and whether they      |
//| should be cut.                                                   |
//+------------------------------------------------------------------+
void CheckRays()
{
	for (int i = 0; i < SessionsNumber; i++)
	{
      string last_name = " " + TimeToString(RememberSessionStart[i], TIME_DATE);
      string suffix = RememberSessionSuffix[i];

      // If the median rays have to be created for the given trading session:
      if (((ShowMedianRays == AllPrevious) && (SessionsNumber - i >= 2)) ||
      (((ShowMedianRays == Previous) || (ShowMedianRays == PreviousCurrent)) && (SessionsNumber - i == 2)) ||
      (((ShowMedianRays == Current) || (ShowMedianRays == PreviousCurrent)) && (SessionsNumber - i == 1)) ||
      (ShowMedianRays == All))
      {
      	double median_price = ObjectGetDouble(0, "Median" + suffix + last_name, OBJPROP_PRICE, 0);
      	datetime median_time = (datetime)ObjectGetInteger(0, "Median" + suffix + last_name, OBJPROP_TIME, 1);
      	
      	// Delete old Median Ray.
      	if (ObjectFind(0, "Median Ray" + suffix + last_name) >= 0) ObjectDelete(0, "Median Ray" + suffix + last_name);
      	// Draw a new Median Ray.
      	ObjectCreate(0, "Median Ray" + suffix + last_name, OBJ_TREND, 0, RememberSessionStart[i], median_price, median_time, median_price);
      	ObjectSetInteger(0, "Median Ray" + suffix + last_name, OBJPROP_COLOR, MedianColor);
      	ObjectSetInteger(0, "Median Ray" + suffix + last_name, OBJPROP_STYLE, STYLE_DASH);
      	ObjectSetInteger(0, "Median Ray" + suffix + last_name, OBJPROP_BACK, false);
      	ObjectSetInteger(0, "Median Ray" + suffix + last_name, OBJPROP_SELECTABLE, false);
      	ObjectSetInteger(0, "Median Ray" + suffix + last_name, OBJPROP_RAY_RIGHT, true);
      	ObjectSetInteger(0, "Median Ray" + suffix + last_name, OBJPROP_HIDDEN, true);
      }
      
      // We should also delete outdated rays that no longer should be there.
      if ((((ShowMedianRays == Previous) || (ShowMedianRays == PreviousCurrent)) && (SessionsNumber - i > 2)) ||
      ((ShowMedianRays == Current) && (SessionsNumber - i > 1)))
      {
         if (ObjectFind(0, "Median Ray" + suffix + last_name) >= 0) ObjectDelete(0, "Median Ray" + suffix + last_name);
      }
   
      // If the median rays have to be created for the given trading session:
      if (((ShowValueAreaRays == AllPrevious) && (SessionsNumber - i >= 2)) ||
      (((ShowValueAreaRays == Previous) || (ShowValueAreaRays == PreviousCurrent)) && (SessionsNumber - i == 2)) ||
      (((ShowValueAreaRays == Current) || (ShowValueAreaRays == PreviousCurrent)) && (SessionsNumber - i == 1)) ||
      (ShowValueAreaRays == All))
      {
      	double va_high_price = ObjectGetDouble(0, "Value Area" + suffix + last_name, OBJPROP_PRICE, 0);
      	double va_low_price = ObjectGetDouble(0, "Value Area" + suffix + last_name, OBJPROP_PRICE, 1);
      	datetime va_time = (datetime)ObjectGetInteger(0, "Value Area" + suffix + last_name, OBJPROP_TIME, 1);

      	if (ObjectFind(0, "Value Area" + suffix + last_name) >= 0)

      	// Delete old Value Area Rays.
      	if (ObjectFind(0, "Value Area HighRay" + suffix + last_name) >= 0) ObjectDelete(0, "Value Area HighRay" + suffix + last_name);
      	if (ObjectFind(0, "Value Area LowRay" + suffix + last_name) >= 0) ObjectDelete(0, "Value Area LowRay" + suffix + last_name);
      	// Draw a new Value Area High Ray.
      	ObjectCreate(0, "Value Area HighRay" + suffix + last_name, OBJ_TREND, 0, RememberSessionStart[i], va_high_price, va_time, va_high_price);
      	ObjectSetInteger(0, "Value Area HighRay" + suffix + last_name, OBJPROP_COLOR, ValueAreaColor);
      	ObjectSetInteger(0, "Value Area HighRay" + suffix + last_name, OBJPROP_STYLE, STYLE_DOT);
      	ObjectSetInteger(0, "Value Area HighRay" + suffix + last_name, OBJPROP_BACK, false);
      	ObjectSetInteger(0, "Value Area HighRay" + suffix + last_name, OBJPROP_SELECTABLE, false);
      	ObjectSetInteger(0, "Value Area HighRay" + suffix + last_name, OBJPROP_RAY_RIGHT, true);
      	ObjectSetInteger(0, "Value Area HighRay" + suffix + last_name, OBJPROP_HIDDEN, true);
      	// Draw a new Value Area Low Ray.
      	ObjectCreate(0, "Value Area LowRay" + suffix + last_name, OBJ_TREND, 0, RememberSessionStart[i], va_low_price, va_time, va_low_price);
      	ObjectSetInteger(0, "Value Area LowRay" + suffix + last_name, OBJPROP_COLOR, ValueAreaColor);
      	ObjectSetInteger(0, "Value Area LowRay" + suffix + last_name, OBJPROP_STYLE, STYLE_DOT);
      	ObjectSetInteger(0, "Value Area LowRay" + suffix + last_name, OBJPROP_BACK, false);
      	ObjectSetInteger(0, "Value Area LowRay" + suffix + last_name, OBJPROP_SELECTABLE, false);
      	ObjectSetInteger(0, "Value Area LowRay" + suffix + last_name, OBJPROP_RAY_RIGHT, true);
      	ObjectSetInteger(0, "Value Area LowRay" + suffix + last_name, OBJPROP_HIDDEN, true);
      }
      
      // We should also delete outdated rays that no longer should be there.
      if ((((ShowValueAreaRays == Previous) || (ShowValueAreaRays == PreviousCurrent)) && (SessionsNumber - i > 2)) ||
      ((ShowValueAreaRays == Current) && (SessionsNumber - i > 1)))
      {
         if (ObjectFind(0, "Value Area HighRay" + suffix + last_name) >= 0) ObjectDelete(0, "Value Area HighRay" + suffix + last_name);
         if (ObjectFind(0, "Value Area LowRay" + suffix + last_name) >= 0) ObjectDelete(0, "Value Area LowRay" + suffix + last_name);
      }
      
      if (!RaysUntilIntersection) continue;
      
	   if ((((ShowMedianRays == Previous) || (ShowMedianRays == PreviousCurrent)) && (SessionsNumber - i == 2)) || (((ShowMedianRays == AllPrevious) || (ShowMedianRays == All)) && (SessionsNumber - i >= 2)))
	   {
	      CheckRayIntersections("Median Ray" + suffix + last_name, i + 1);
	   }
	   if ((((ShowValueAreaRays == Previous) || (ShowValueAreaRays == PreviousCurrent)) && (SessionsNumber - i == 2)) || (((ShowValueAreaRays == AllPrevious) || (ShowValueAreaRays == All)) && (SessionsNumber - i >= 2)))
	   {
	      CheckRayIntersections("Value Area HighRay" + suffix + last_name, i + 1);
	      CheckRayIntersections("Value Area LowRay" + suffix + last_name, i + 1);
      }
	}
}

//+------------------------------------------------------------------+
//| Checks price intersection and cuts a ray for a given object.     |
//+------------------------------------------------------------------+
void CheckRayIntersections(const string object, const int start_j)
{
   if (ObjectFind(0, object) < 0) return;

   double price = ObjectGetDouble(0, object, OBJPROP_PRICE, 0);
   for (int j = start_j; j < SessionsNumber; j++) // Find the nearest intersecting session.
   {
      if ((price <= RememberSessionMax[j]) && (price >= RememberSessionMin[j]))
      {
         ObjectSetInteger(0, object, OBJPROP_RAY, false);
         ObjectSetInteger(0, object, OBJPROP_TIME, 1, RememberSessionStart[j]);
         break;
      }
   }
}
//+------------------------------------------------------------------+