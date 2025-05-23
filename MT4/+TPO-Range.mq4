#property copyright "TPO: Time Price Opportunity (on time range), v2.5.7491. © 2009-2010 Plus."
#property link      "http://fxcoder.ru, plusfx@ya.ru, skype:plusfx"

#property indicator_chart_window

// Ïàðàìåòðû ðàñ÷åòîâ
extern int RangeMode = 0;						// äèàïàçîí: 0 - ìåæäó âåðòèêàëüíûõ ëèíèé, 1 - ïîñëåäíèå RangeMinutes ìèíóò, 2 = RangeMinutes ïåðåä ëèíèåé
extern int RangeMinutes = 1440;					// êîëè÷åñòâî ìèíóò â äèàïàçîíå (äëÿ íåêîòîðûõ òèïîâ óêàçàíèÿ ãðàíèö)
extern int ModeStep = 10;						// øàã ïîèñêà ìîä, ôàêòè÷åñêè â 2 ðàçà áîëüøå + 1
int Smooth = 0;									// ãëóáèíà ñãëàæèâàíèÿ, ïðèìåíÿåòñÿ àëãîðèòì ïîñëåäîâàòåëüíîãî óñðåäíåíèÿ òðèàä óêàçàííîå ÷èñëî ðàç
int PriceStep = 0;								// øàã öåíû, 0 - àâòî (ñì. #1)
int DataPeriod = 1;								// ïåðèîä äëÿ äàííûõ, ìèíóòêè - ñàìûå òî÷íûå
bool ShowHorizon = true;						// ïîêàçàòü ãîðèçîíò äàííûõ

// Ãèñòîãðàììà è ìîäû
extern int HGPosition = 1;						// 0 - window left, 1 - window right, 2 - left side, 3 - right side, //TODO: 4 - âíóòðè
extern color HGColor = C'160,224,160';			// öâåò ãèñòîãðàììû
extern int HGStyle = 1;							// ñòèëü ãèñòîãðàììû: 0 - ëèíèè, 1 - ïóñòûå ïðÿìîóãîëüíèêè, 2 - çàïîëíåííûå ïðÿìîóãîëüíèêè
extern color ModeColor = Green;					// öâåò ìîä
extern color MaxModeColor = CLR_NONE;			// âûäåëèòü ìàêñèìóì

int HGLineWidth = 1;							// øèðèíà ëèíèé ãèñòîãðàììû

double Zoom = 0;								// ìàñøòàá ãèñòîãðàììû, 0 - àâòîìàñøòàá
int ModeWidth = 1;								// òîëùèíà ìîä
int ModeStyle = STYLE_SOLID;					// ñòèëü ìîä

// Óðîâíè
extern color ModeLevelColor = Green;			// öâåò óðîâíåé
int ModeLevelWidth = 1;							// òîëùèíà
extern int ModeLevelStyle = 2;					// ñòèëü

// Ñëóæåáíûå
extern string Id = "+tpor";						// ïðåôèêñ âñåõ îáúåêòîâ èíäèêàòîðà

int WaitSeconds = 1;							// ìèíèìàëüíîå âðåìÿ, â ñåêóíäàõ, ìåæäó îáíîâëåíèÿìè
int TickMethod = 1;								// ìåòîä èìèòàöèè òèêîâ: 0 - Low >> High, 1 - Open > Low(High) > High(Low) > Close, 2 - HLC, 3 - HL
												// +4 - áåç ó÷åòà îáú¸ìà, +8 - ñ ó÷åòîì îáú¸ìà è äëèíû áàðà
color TimeFromColor = White;						// ëåâàÿ ãðàíèöà äèàïàçîíà - öâåò
int TimeFromStyle = STYLE_DASH;					// ëåâàÿ ãðàíèöà äèàïàçîíà - ñòèëü

color TimeToColor = Red;						// ïðàâàÿ ãðàíèöà äèàïàçîíà - öâåò
int TimeToStyle = STYLE_DASH;					// ïðàâàÿ ãðàíèöà äèàïàçîíà - ñòèëü


string onp, tfn, ttn;
datetime lastTime = 0;	// ïîñëåäíåå âðåìÿ çàïóñêà

double hgPoint;			// ìèíèìàëüíîå èçìåíåíèå öåíû
int modeStep = 0;
int smooth = 0;

bool showHG, showModes, showMaxMode, showModeLevel;
bool hgBack = true;
bool hgUseRectangles = false;


#define ERR_HISTORY_WILL_UPDATED 4066


int init()
{
	onp = Id + " m" + RangeMode + " ";
	tfn = Id + "-from";
	ttn = Id + "-to";

	hgPoint = Point;
	
	bool is5digits = ((Digits == 3) || (Digits == 5)) && (MarketInfo(Symbol(), MODE_PROFITCALCMODE) == 0);
	
	//#1
	if (PriceStep == 0)
	{
		if (is5digits)
			hgPoint = Point * 10.0;
	}
	else
	{
		hgPoint = Point * PriceStep;
	}
		
	modeStep = ModeStep * Point / hgPoint;
	smooth = Smooth * Point / hgPoint;
	if (is5digits)
	{
		 modeStep *= 10;
		 smooth *= 10;
	}
	

	// íàñòðîéêè îòîáðàæåíèÿ	
	showHG = (HGColor != CLR_NONE) && (HGColor != -16777216);
	showModes = (ModeColor != CLR_NONE) && (ModeColor != -16777216);
	showMaxMode = (MaxModeColor != CLR_NONE) && (MaxModeColor != -16777216);
	showModeLevel = (ModeLevelColor != CLR_NONE) && (ModeLevelColor != -16777216);

	// êîððåêòèðóåì ïàðàìåòðû ñòèëÿ
	if (HGStyle == 1)
	{
		hgBack = false;
		hgUseRectangles = true;
	}
	else if (HGStyle == 2)
	{
		hgBack = true;
		hgUseRectangles = true;
	}
	
	return(0);
}

int start()
{
	if (GlobalVariableGet("+vl-freeze") == 1)
		return;

	datetime currentTime = TimeLocal();
	
	// âñåãäà îáíîâëÿåìñÿ íà íîâîì áàðå...
	if (Volume[0] > 1)
	{
		// ...è íå ÷àùå, ÷åì ðàç â íåñêîëüêî ñåêóíä
		if (currentTime - lastTime < WaitSeconds)
			return(0);
	}

	lastTime = currentTime;

	// óäàëÿåì ñòàðûå îáúåêòû
	clearChart(onp);

	// îïðåäåëÿåì ðàáî÷èé äèàïàçîí
	
	datetime timeFrom, timeTo;
	
	if (RangeMode == 0)	// ìåæäó äâóõ ëèíèé
	{
		timeFrom = GetObjectTime1(tfn);
		timeTo = GetObjectTime1(ttn);

		if ((timeFrom == 0) || (timeTo == 0))
		{
			// åñëè ãðàíèöû äèàïàçîíà íå çàäàíû, òî óñòàíàâëèâàåì èõ â âèäèìóþ ÷àñòü ýêðàíà
			datetime timeLeft = getBarTime(WindowFirstVisibleBar());
			datetime timeRight = getBarTime(WindowFirstVisibleBar() - WindowBarsPerChart());
			double r = timeRight - timeLeft;
			
			timeFrom = timeLeft + r / 3;
			timeTo = timeLeft + r * 2 / 3;


		}

		if (timeFrom > timeTo)
		{
			datetime dt = timeTo;
			timeTo = timeFrom;
			timeFrom = dt;
		}
	}
	else if (RangeMode == 2)	// îò ïðàâîé ëèíèè RangeMinutes ìèíóò
	{
		timeTo = GetObjectTime1(ttn);

		if (timeTo == 0)
		{
			// åñëè îòñ÷åò äèàïàçîíà íå çàäàí, òî óñòàíàâëèâàåì åãî â âèäèìóþ ÷àñòü ýêðàíà
			int bar = MathMax(0, WindowFirstVisibleBar() - WindowBarsPerChart() + 20);
			timeTo = getBarTime(bar);
		}
		else
			bar = iBarShift(NULL, 0, timeTo);

		bar += RangeMinutes/Period();
		timeFrom = Time[bar];// timeTo - RangeMinutes*60;

		drawVLine(tfn, timeFrom, TimeFromColor, 1, TimeFromStyle, false);
		if (ObjectFind(ttn) == -1)
			drawVLine(ttn, timeTo, TimeToColor, 1, TimeToStyle, false);
	}
	else if (RangeMode == 1)
	{
		timeFrom = iTime(Symbol(), PERIOD_M1, RangeMinutes);	// ïðîâåðèòü
		timeTo = iTime(Symbol(), PERIOD_M1, 0);
	}
	else
	{
		return(0);
	}

	if (getTimeBar(timeTo) < 0)
		timeTo = iTime(Symbol(), PERIOD_M1, 0);
		
	if (getTimeBar(timeFrom) < 0)
		timeFrom = iTime(Symbol(), PERIOD_M1, 0);

	if (ShowHorizon)
	{
	}

	int barFrom, barTo, m1BarFrom, m1BarTo;

	if (getRange(timeFrom, timeTo, barFrom, barTo, m1BarFrom, m1BarTo, DataPeriod))
	{
		// ïîëó÷àåì ãèñòîãðàììó
		double vh[], hLow;

		int count = getHGByRates(m1BarFrom, m1BarTo, TickMethod, vh, hLow, hgPoint, DataPeriod);

		if (count == 0)
			return(0);
		
		if (smooth != 0)
		{	
			count = smoothHG(vh, smooth);
			hLow -= smooth * hgPoint;
		}
			
		int rp;
		datetime time0;

		double windowTimeRange = WindowBarsPerChart()*Period()*60;
		rp = windowTimeRange*0.1;	// äèàïàçîí âðåìåíè äëÿ ðèñîâàíèÿ ãèñòîãðàììû


		// îïðåäåëåíèå ìàñøòàáà
		double zoom = Zoom*0.000001;
		if (zoom <= 0)
		{
			double maxVolume = vh[ArrayMaximum(vh)];
			zoom = WindowBarsPerChart()*0.1 / maxVolume;
		}

		int bar0;	// áàð íóëåâîé îòìåòêè ãèñòîãðàììû
		
		if (HGPosition == 0)		// ëåâàÿ ãðàíèöà îêíà
		{
			bar0 = WindowFirstVisibleBar();
		}
		else if (HGPosition == 1)	// ïðàâàÿ ãðàíèöà îêíà
		{
			bar0 = WindowFirstVisibleBar() - WindowBarsPerChart();
			zoom = -zoom; // ñïðàâà ïåðåâîðà÷èâàåì
		}
		else if (HGPosition == 2)	// ëåâàÿ ãðàíèöà äèàïàçîíà
		{
			bar0 = barFrom;
			zoom = -zoom; // ñïðàâà ïåðåâîðà÷èâàåì
		}
		else 						// 3 - ïðàâàÿ ãðàíèöà äèàïàçîíà
		{
			bar0 = barTo;
		}

		// ðèñóåì
		if (showHG)
			drawHG(onp + "hg ", vh, hLow, bar0, HGColor, HGColor, zoom, HGLineWidth, hgPoint);
	
		if (showModes || showMaxMode || showModeLevel)
			drawModes(vh, hLow, bar0, zoom, hgPoint);
	}
	
	return(0);
}

int deinit()
{
	// óäàëÿåì âñå ãèñòîãðàììû è èõ ïðîèçâîäíûå
	clearChart(onp);
	
	// óäàëåì ëèíèè òîëüêî ïðè ÿâíîì óäàëåíèè èíäèêàòîðà ñ ãðàôèêà, óäîáíî äëÿ îòëàäêè (ãðàíèöû îñòàþòñÿ íà òîì æå ìåñòå)
	// Ïðèìå÷àíèå: èç-çà îøèáêè äèçàéíà ÌÒ ýòà øòóêà íå ðàáîòàåò, äåèíèöèàëèçàöèè ïðè çàêðûòèè òåðìèíàëà ïðîèñõîäèò ñ ïðè÷èíîé 
	//		REASON_REMOVE, èç-çà ÷åãî ëèíèè òåðÿþòñÿ ïðè çàêðûòèè òåðìèíàëà, à ïðè ïåðåçàïóñêå óñòàíàâëèâàþòñÿ êóäà-òî ãëóáîêî 
	//		â èñòîðèþ, ò.ê. çäåñü åù¸ îäèí ãëþê - èíèöèàëèçàöèÿ ïðè çàïóñêå ïðîèñõîäèò äî ïåðâîãî ïîêàçà ÷àðòà.
	/*if (UninitializeReason() == REASON_REMOVE)
	{
		clearChart(tfn);
		clearChart(ttn);
	}*/
	
	return(0);
}

void DrawHLine(string name, double price, color lineColor = Gray, int width = 1, int style = STYLE_SOLID, bool back = true)
{
	if (ObjectFind(name) >= 0)
		ObjectDelete(name);

	if (price > 0 && ObjectCreate(name, OBJ_HLINE, 0, 0, price))
	{
		ObjectSet(name, OBJPROP_COLOR, lineColor);
		ObjectSet(name, OBJPROP_WIDTH, width);
		ObjectSet(name, OBJPROP_STYLE, style);
		ObjectSet(name, OBJPROP_BACK, back);
	}
}

datetime GetObjectTime1(string name)
{
	// ðåçóëüòàò ôóíêöèè ObjectGet â ñëó÷àå îòñóòñòâèè îáúåêòà íå äîêóìåíòèðîâàí ðàçðàáîò÷èêàìè ÿçûêà, ïîýòîìó èçâðàùàåìñÿ
 	if (ObjectFind(name) != -1)
		return(ObjectGet(name, OBJPROP_TIME1));
	else
		return(0);
}


// íàðèñîâàòü ìîäû ãèñòîãðàììû
void drawModes(double& vh[], double hLow, int barFrom, double zoom, double point)
{
	int modes[], modeCount, j;
	double price;

	// ïîèñê ìîä
	modeCount = getModesIndexes(vh, modeStep, modes);

	// ìàêñ. ìîäà
	double max = 0;
	if (showMaxMode)
	{
		for (j = 0; j < modeCount; j++)
			if (vh[modes[j]] > max)
				max = vh[modes[j]];
	}
	
	datetime timeFrom = getBarTime(barFrom);

	// óäàëÿåì ñòàðûå ìîäû è èõ óðîâíè, îíè ìîãóò ïåðåðèñîâûâàòüñÿ
	clearChart(onp + "mode ");
	clearChart(onp + "level ");

	// âñåãäà óæèðíÿåì ìîäû â ðåæèìàõ ðèñîâàíèÿ ïðÿìîóãîëüíèêàìè
	bool back = false;
	if (hgUseRectangles)
		back = true;

	string on;	

	for (j = 0; j < modeCount; j++)
	{
		double v = zoom * vh[modes[j]];

		// íå ðèñîâàòü êîðîòêèõ ëèíèé (ìåíüøå áàðà ÒÔ), ãëþ÷èò ïðè âûäåëåíèè ãðàíèö
		if (MathAbs(v) > 0)
		{
			price = hLow + modes[j]*point;
			datetime timeTo = getBarTime(barFrom - v);
	
			on = onp + "mode " + DoubleToStr(price, Digits);
			if (showMaxMode && (MathAbs(vh[modes[j]] - max) < point))	// ìàêñèìàëüíàÿ ìîäà
			{
				drawTrend(on, timeFrom, price, timeTo, price, MaxModeColor, ModeWidth, ModeStyle, back, false, 0, hgUseRectangles);

				// â ðåæèìå ðèñîâàíèÿ ïðÿìîóãîëüíèêàìè ìîäû ðèñóåì ëèíèÿìè, èíà÷å îíè ñêðûâàþòñÿ
				if (hgUseRectangles && back)
					drawTrend(on + "+", timeFrom, price, timeTo, price, MaxModeColor, ModeWidth, ModeStyle, false, false, 0, false);
			}
			else if (showModes)	// îáû÷íàÿ ìîäà
			{
				drawTrend(on, timeFrom, price, timeTo, price, ModeColor, ModeWidth, ModeStyle, back, false, 0, hgUseRectangles);

				// â ðåæèìå ðèñîâàíèÿ ïðÿìîóãîëüíèêàìè ìîäû ðèñóåì ëèíèÿìè, èíà÷å îíè ñêðûâàþòñÿ
				if (hgUseRectangles && back)
					drawTrend(on + "+", timeFrom, price, timeTo, price, ModeColor, ModeWidth, ModeStyle, false, false, 0, false);
			}

			// óðîâåíü
			if (showModeLevel)
				;
		}
	}
}

// ïîëó÷èòü íîìåð áàðà ïî âðåìåíè ñ ó÷åòîì âîçìîæíîãî âûõîäà çà äèàïàçîí ðåàëüíûõ äàííûõ
int getTimeBar(datetime time, int period = 0)
{
	if (period == 0)
		period = Period();

	int shift = iBarShift(Symbol(), period, time);
	int t = getBarTime(shift, period);
	
	if (t != time) // && shift == 0 ???
		shift = (iTime(Symbol(), period, 0) - time) / 60 / period;

	return(shift);	
}

// ïîëó÷èòü âðåìÿ ïî íîìåðó áàðà ñ ó÷åòîì âîçìîæíîãî âûõîäà çà äèàïàçîí áàðîâ (íîìåð áàðà ìåíüøå 0)
datetime getBarTime(int shift, int period = 0)
{
	if (period == 0)
		period = Period();

	if (shift >= 0)
		return(iTime(Symbol(), period, shift));
	else
		return(iTime(Symbol(), period, 0) - shift*period*60);
}

/// Î÷èñòèòü ãðàôèê îò ñâîèõ îáúåêòîâ
int clearChart(string prefix)
{
	int obj_total = ObjectsTotal();
	string name;
	
	int count = 0;
	for (int i = obj_total - 1; i >= 0; i--)
	{
		name = ObjectName(i);
		if (StringFind(name, prefix) == 0)
		{
			ObjectDelete(name);
			count++;
		}			
	}
	return(count);
}

void drawVLine(string name, datetime time1, color lineColor = Gray, int width = 1, int style = STYLE_SOLID, bool back = true)
{
	if (ObjectFind(name) >= 0)
		ObjectDelete(name);
		
	ObjectCreate(name, OBJ_VLINE, 0, time1, 0);
	ObjectSet(name, OBJPROP_COLOR, lineColor);
	ObjectSet(name, OBJPROP_BACK, back);
	ObjectSet(name, OBJPROP_STYLE, style);
	ObjectSet(name, OBJPROP_WIDTH, width);
}

void drawTrend(string name, datetime time1, double price1, datetime timeTo, double price2, 
	color lineColor, int width, int style, bool back, bool ray, int window, bool useRectangle)
{
	if (ObjectFind(name) >= 0)
		ObjectDelete(name);

	// åñëè ðèñîâàòü ïðÿìîóãîëüíèêàìè, òî ïðè íàëîæåíèè îíè íå ñìåøèâàþòñÿ
	if (useRectangle)
		ObjectCreate(name, OBJ_RECTANGLE, window, time1, price1 - hgPoint / 2.0, timeTo, price2 + hgPoint / 2.0);
	else
		ObjectCreate(name, OBJ_TREND, window, time1, price1, timeTo, price2);
	
	ObjectSet(name, OBJPROP_BACK, back);
	ObjectSet(name, OBJPROP_COLOR, lineColor);
	ObjectSet(name, OBJPROP_STYLE, style);
	ObjectSet(name, OBJPROP_WIDTH, width);
	ObjectSet(name, OBJPROP_RAY, ray);

}

// íàðèñîâàòü ãèñòîãðàììó (+öâåò +point)
void drawHG(string prefix, double& h[], double low, int barFrom, color bgColor, color lineColor, double zoom, int width, double point)
{
	double max = h[ArrayMaximum(h)];
	if (max == 0)
		return(0);

	int bgR = (bgColor & 0xFF0000) >> 16;
	int bgG = (bgColor & 0x00FF00) >> 8;
	int bgB = (bgColor & 0x0000FF);

	int lineR = (lineColor & 0xFF0000) >> 16;
	int lineG = (lineColor & 0x00FF00) >> 8;
	int lineB = (lineColor & 0x0000FF);
	
	int dR = lineR - bgR;
	int dG = lineG - bgG;
	int dB = lineB - bgB;

	int hc = ArraySize(h);
	for (int i = 0; i < hc; i++)
	{
		double price = NormalizeDouble(low + i*point, Digits);
		
		int barTo = barFrom - h[i]*zoom;
		
		// ðàñêðàñêà ãðàäèåíòîì
		double fade = h[i] / max;
		int r = MathMax(MathMin(bgR + fade * dR, 255), 0);
		int g = MathMax(MathMin(bgG + fade * dG, 255), 0);
		int b = MathMax(MathMin(bgB + fade * dB, 255), 0);
		color cl = (r << 16) + (g << 8) + b;
		
		datetime timeFrom = getBarTime(barFrom);
		datetime timeTo = getBarTime(barTo);

		if (barFrom != barTo)
			drawTrend(prefix + DoubleToStr(price, Digits), timeFrom, price, timeTo, price, cl, width, STYLE_SOLID, hgBack, false, 0, hgUseRectangles);
	}
}

// ïîëó÷èòü ïàðàìåòðû äèàïàçîíà
bool getRange(datetime timeFrom, datetime timeTo, int& barFrom, int& barTo, 
	int& p1BarFrom, int& p1BarTo, int period)
{
	// äèàïàçîí áàðîâ â òåêóùåì ÒÔ (äëÿ ðèñîâàíèÿ)

	barFrom = iBarShift(NULL, 0, timeFrom);
	datetime time = Time[barFrom];
	int bar = iBarShift(NULL, 0, time);
	time = Time[bar];
	if (time != timeFrom)
		barFrom--;
											
	barTo = iBarShift(NULL, 0, timeTo);
	time = Time[barTo];
	bar = iBarShift(NULL, 0, time);
	time = Time[bar];
	if (time == timeFrom)
		barTo++;

	if (barFrom < barTo)
		return(false);


	// äèàïàçîí áàðîâ ÒÔ period (äëÿ ïîëó÷åíèÿ äàííûõ)

	p1BarFrom = iBarShift(NULL, period, timeFrom);
	time = iTime(NULL, period, p1BarFrom);
	if (time != timeFrom)
		p1BarFrom--;
		
	p1BarTo = iBarShift(NULL, period, timeTo);
	time = iTime(NULL, period, p1BarTo);
	if (timeTo == time)
		p1BarTo++;
		
	if (p1BarFrom < p1BarTo)
		return(false);

	return(true);
}

/// Ïîëó÷èòü ãèñòîãðàììó ðàñïðåäåëåíèÿ öåí
///		m1BarFrom, m1BarTo - ãðàíèöû äèàïàçîíà, çàäàííûå íîìåðàìè áàðîâ ìèíóòîê
/// Âîçâðàùàåò:
///		ðåçóëüòàò - êîëè÷åñòâî öåí â ãèñòîãðàììå, 0 - îøèáêà
///		vh - ãèñòîãðàììà
///		hLow - íèæíÿÿ ãðàíèöà ãèñòîãðàììû
///		point - øàã öåíû
///		dataPeriod - òàéìôðåéì äàííûõ
int getHGByRates(int m1BarFrom, int m1BarTo, int tickMethod, double& vh[], double& hLow, double point, int dataPeriod)
{
	double rates[][6];
	double hHigh;

	// ïðåäïîëîæèòåëüíîå (è ìàêñèìàëüíîå) êîëè÷åñòâî ìèíóòîê
	int rCount = getRates(m1BarFrom, m1BarTo, rates, hLow, hHigh, dataPeriod);
	//Print("rCount: " + rCount);
	
	if (rCount != 0)
	{
		hLow = NormalizeDouble(MathRound(hLow / point) * point, Digits);
		hHigh = NormalizeDouble(MathRound(hHigh / point) * point, Digits);
		
		//Print("hLow: " + hLow);
		//Print("hHigh: " + hHigh);

		// èíèöèàëèçèðóåì ìàññèâ ãèñòîãðàììû
		int hCount = hHigh/point - hLow/point + 1;
		//Print("hCount: " + hCount);
		ArrayResize(vh, hCount);
		ArrayInitialize(vh, 0);

		int iCount = m1BarFrom - m1BarTo + 1;
		int hc = mql_GetHGByRates(rates, rCount, iCount, m1BarTo, tickMethod, point, hLow, hCount, vh);

		//Print("hc: " + hc);

		if (hc == hCount)
			return(hc);
		else
			return(0);
	}
	else
	{
		//Print("Error: no rates");
		return(0);
	}
}

/// Ïîëó÷èòü ãèñòîãðàììó ðàñïðåäåëåíèÿ öåí ñðåäñòâàìè MQL
int mql_GetHGByRates(double& rates[][6], int rcount, int icount, int ishift, int tickMethod, double point, 
	double hLow, int hCount, double& vh[])
{
	int pri;	// èíäåêñ öåíû
	double dv;	// îáúåì íà òèê

	int hLowI = MathRound(hLow / point);

	//Print(rcount);

	for (int j = 0; j < icount; j++)
	{
		//int i = rcount - 1 - j - ishift;
		int i = j + ishift;

		double o = rates[i][1];
		int oi = MathRound(o/point);

		double h = rates[i][3];
		int hi = MathRound(h/point);

		double l = rates[i][2];
		int li = MathRound(l/point);

		double c = rates[i][4];
		int ci = MathRound(c/point);

		double v = rates[i][5];
		

		int rangeMin = hLowI;
		int rangeMax = hLowI + hCount - 1;

		if (tickMethod == 0)						// ðàâíàÿ âåðîÿòíîñòü âñåõ öåí áàðà
		{
			dv = v / (hi - li + 1.0);
			for (pri = li; pri <= hi; pri++)
				vh[pri - hLowI] += dv;
		}
		else if (tickMethod == 1)					// èìèòàöèÿ òèêîâ
		{
			if (c >= o)		// áû÷üÿ ñâå÷à
			{
				dv = v / (oi - li + hi - li + hi - ci + 1.0);

				for (pri = oi; pri >= li; pri--)		// open --> low
					vh[pri - hLowI] += dv;

				for (pri = li + 1; pri <= hi; pri++)	// low+1 ++> high
					vh[pri - hLowI] += dv;
				
				for (pri = hi - 1; pri >= ci; pri--)	// high-1 --> close
					vh[pri - hLowI] += dv;
			}
			else			// ìåäâåæüÿ ñâå÷à
			{
				dv = v / (hi - oi + hi - li + ci - li + 1.0);

				for (pri = oi; pri <= hi; pri++)		// open ++> high
					vh[pri - hLowI] += dv;
				
				for (pri = hi - 1; pri >= li; pri--)	// high-1 --> low
					vh[pri - hLowI] += dv;
				
				for (pri = li + 1; pri <= ci; pri++)	// low+1 ++> close
					vh[pri - hLowI] += dv;
			}
		}
		else if (tickMethod == 2)					// òîëüêî öåíû áàðà
		{
			dv = v / 4.0;
			vh[oi - hLowI] += dv;
			vh[hi - hLowI] += dv;
			vh[li - hLowI] += dv;
			vh[ci - hLowI] += dv;
		}
		else if (tickMethod == 3)					// òîëüêî õàé è ëîó
		{
			dv = v / 2.0;
			vh[hi - hLowI] += dv;
			vh[li - hLowI] += dv;
		}
	}
	
	return(hCount);
}

/// Ïîëó÷èòü ìîäû íà îñíîâå ãèñòîãðàììû è ñãëàæåííîé ãèñòîãðàììû (áûñòðûé ìåòîä, áåç ñãëàæèâàíèÿ)
int getModesIndexes(double& vh[], int modeStep, int& modes[]) //, int& maxModeIndex
{
	int modeCount = 0;
	ArrayResize(modes, modeCount);

	int count = ArraySize(vh);
	
	// èùåì ìàêñèìóìû ïî ó÷àñòêàì
	for (int i = modeStep; i < count - modeStep; i++)
	{
		int maxFrom = i-modeStep;
		int maxRange = 2*modeStep + 1;
		int maxTo = maxFrom + maxRange - 1;

		int k = ArrayMaximum(vh, maxRange, maxFrom);
		
		if (k == i)
		{
			for (int j = i - modeStep; j <= i + modeStep; j++)
			{
				if (vh[j] == vh[k])
				{
					modeCount++;
					ArrayResize(modes, modeCount);
					modes[modeCount-1] = j;
				}
			}
		}
		
	}

	return(modeCount);
}


/// Ïîëó÷èòü ìèíóòêè äëÿ çàäàííîãî äèàïàçîíà (óêàçûâàåòñÿ â íîìåðàõ áàðîâ ìèíóòîê)
int getRates(int barFrom, int barTo, double& rates[][6], double& ilowest, double& ihighest, int period)
{
	// ïðåäïîëîæèòåëüíîå (è ìàêñèìàëüíîå) êîëè÷åñòâî ìèíóòîê
	int iCount = barFrom - barTo + 1;
	
	int count = ArrayCopyRates(rates, NULL, period);
	if (GetLastError() == ERR_HISTORY_WILL_UPDATED)
	{
		return(0);
	}
	else
	{
		if (count >= barFrom - 1)
		{
			ilowest = iLow(NULL, period, iLowest(NULL, period, MODE_LOW, iCount, barTo));
			ihighest = iHigh(NULL, period, iHighest(NULL, period, MODE_HIGH, iCount, barTo));
			return(count);
		}
		else
		{
			return(0);
		}
	}
}

int smoothHG(double& vh[], int depth)
{
	int vCount = ArraySize(vh);

	if (depth == 0)
		return(vCount);

	// ðàñøèðÿåì ìàññèâ (íåîáõîäèìî äëÿ êîððåêòíûõ ðàñ÷åòîâ)
	int newCount = vCount + 2 * depth;
	
	// ñäâèãàåì çíà÷åíèÿ è çàíóëÿåì õâîñòû
	double th[];
	ArrayResize(th, newCount);
	ArrayInitialize(th, 0);

	ArrayCopy(th, vh, depth, 0);

	ArrayResize(vh, newCount);
	ArrayInitialize(vh, 0);

	// ïîñëåäîâàòåëüíîå óñðåäíåíèå
	for (int d = 0; d < depth; d++)
	{
		for (int i = -d; i < vCount + d; i++)
		{
			vh[i+depth] = (th[i+depth-1] + th[i+depth] + th[i+depth+1]) / 3.0;
		}
		
		ArrayCopy(th, vh);
	}


	return(newCount);
}