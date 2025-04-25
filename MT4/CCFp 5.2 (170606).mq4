// +------------------------------------------------------------------+
// |
// | original made by Semen Semenich
// | updated by mladen
// | updated by mambomango
// |
// +------------------------------------------------------------------+

#property description "CCFp"
#property version "5.2"

#property indicator_separate_window
#property indicator_buffers 11

#property strict

#define INPUTVARDELIMITER          "****************************************************************"

#define MAXPAIRS 11

extern string             Time_Frame            = "Current time frame";
extern string             SymbolsPrefix         = "";
extern string             SymbolsSuffix         = "";

extern bool               showOnlySymbolOnChart = false;
extern bool               USD                   = true;
extern bool               EUR                   = true;
extern bool               GBP                   = true;
extern bool               CHF                   = true;
extern bool               JPY                   = true;
extern bool               AUD                   = true;
extern bool               CAD                   = true;
extern bool               NZD                   = true;
extern bool               NOK                   = true;
extern bool               SEK                   = true;
extern bool               SGD                   = true;

extern color              Color_USD             = White;
extern color              Color_EUR             = Yellow;
extern color              Color_JPY             = Red;
extern color              Color_GBP             = Green;
extern color              Color_CHF             = Orange;
extern color              Color_CAD             = Gray;
extern color              Color_AUD             = LawnGreen;
extern color              Color_NZD             = Purple;
extern color              Color_NOK             = Aqua;
extern color              Color_SEK             = Olive;
extern color              Color_SGD             = Pink;

extern int                Line_Width            = 1;

sinput string             HeadingSection        = INPUTVARDELIMITER; // Heading Rows
extern string             Indicator_Name        = "CCFp: ";
extern string             HeadingFontName       = "Arial Black";
extern int                StartPos              = 12;

sinput string             LevelSection          = INPUTVARDELIMITER; // Threshold Levels
extern bool               ShowLevel             = true;
extern double             LevelUp2              =  0.015;
extern double             LevelUp1              =  0.007;
extern double             LevelDn1              = -0.007;
extern double             LevelDn2              = -0.015;

sinput string             CalculationSection    = INPUTVARDELIMITER; // Period Calculation from bar CalcBarA to bar CalcBarB
extern int                CalcBarA              = 0;
extern int                CalcBarB              = 1;

sinput string             PanelSection          = INPUTVARDELIMITER; // Panel Position
extern bool               ShowPanel             = true;
extern int                PanelSubWindow        = 1;
extern ENUM_BASE_CORNER   PanelCorner           = CORNER_RIGHT_LOWER;
extern string             PanelFontName         = "Arial";
extern int                PanelMarginX          = 0;
extern int                PanelMarginY          = 0;

sinput string             MovingAverageSection  = INPUTVARDELIMITER; // Moving Average parameters
extern ENUM_MA_METHOD     MaMethod              = MODE_LWMA;
extern ENUM_APPLIED_PRICE MaAppliedPrice        = PRICE_WEIGHTED;
extern int                mn_per                = 6;
extern int                mn_fast               = 2;
extern int                w_per                 = 6;
extern int                w_fast                = 2;
extern int                d_per                 = 9;
extern int                d_fast                = 3;
extern int                h4_per                = 12;
extern int                h4_fast               = 6;
extern int                h1_per                = 18;
extern int                h1_fast               = 6;
extern int                m30_per               = 21;
extern int                m30_fast              = 6;
extern int                m15_per               = 24;
extern int                m15_fast              = 6;
extern int                m5_per                = 30;
extern int                m5_fast               = 6;
extern int                m1_per                = 36;
extern int                m1_fast               = 6;
extern bool               Interpolate           = true;

//
int          MaFast = 0;
int          MaSlow = 0;

double       arrUSD[];
double       arrEUR[];
double       arrGBP[];
double       arrCHF[];
double       arrJPY[];
double       arrAUD[];
double       arrCAD[];
double       arrNZD[];
double       arrNOK[];
double       arrSEK[];
double       arrSGD[];

// string symbol[] = {"", "", "", "", "", "", "", "", "", "", "", "GBPJPY"};
string       symbols[];

string       indicatorFileName;
bool         returnBars;
bool         calculateValue;
int          iTimeFrame = 0;
const string sColorKey  = "~";

string       names[MAXPAIRS];
int          colors[MAXPAIRS];

double       values[MAXPAIRS];
double       valuea[MAXPAIRS];

string       sTfTable[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int          iMinuteTfTable[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

// +------------------------------------------------------------------
// |
// +------------------------------------------------------------------
int init()
{
    IndicatorDigits(6);

    SetIndexBuffer(0, arrUSD);
    SetIndexBuffer(1, arrEUR);
    SetIndexBuffer(2, arrGBP);
    SetIndexBuffer(3, arrCHF);
    SetIndexBuffer(4, arrJPY);
    SetIndexBuffer(5, arrAUD);
    SetIndexBuffer(6, arrCAD);
    SetIndexBuffer(7, arrNZD);
    SetIndexBuffer(8, arrNOK);
    SetIndexBuffer(9, arrSEK);
    SetIndexBuffer(10, arrSGD);

    indicatorFileName = WindowExpertName();

    returnBars        = (Time_Frame == "returnBars");
    if (returnBars)
        return (0);

    calculateValue = (Time_Frame == "calculateValue");
    if (calculateValue)
        return (0);

    iTimeFrame = stringToTimeFrame(Time_Frame);
    switch (iTimeFrame)
      {
         case PERIOD_M1 :  MaSlow = m1_per;  MaFast = m1_fast;  break;
         case PERIOD_M5 :  MaSlow = m5_per;  MaFast = m5_fast;  break;
         case PERIOD_M15 : MaSlow = m15_per; MaFast = m15_fast; break;
         case PERIOD_M30 : MaSlow = m30_per; MaFast = m30_fast; break;
         case PERIOD_H1 :  MaSlow = h1_per;  MaFast = h1_fast;  break;
         case PERIOD_H4 :  MaSlow = h4_per;  MaFast = h4_fast;  break;
         case PERIOD_D1 :  MaSlow = d_per;   MaFast = d_fast;   break;
         case PERIOD_W1 :  MaSlow = w_per;   MaFast = w_fast;   break;
         case PERIOD_MN1 : MaSlow = mn_per;  MaFast = mn_fast;  break;
      }

    if (ShowLevel)
      {
          SetLevelValue(0, LevelUp2);
          SetLevelValue(1, LevelUp1);
          SetLevelValue(2, LevelDn1);
          SetLevelValue(3, LevelDn2);
      }

    USD = check("USD", USD);
    EUR = check("EUR", EUR);
    GBP = check("GBP", GBP);
    CHF = check("CHF", CHF);
    JPY = check("JPY", JPY);
    AUD = check("AUD", AUD);
    CAD = check("CAD", CAD);
    NZD = check("NZD", NZD);
    NOK = check("NOK", NOK);
    SEK = check("SEK", SEK);
    SGD = check("SGD", SGD);

    if (USD)
      { Indicator_Name = StringConcatenate(Indicator_Name, " USD"); names[0] = "USD"; colors[0] = Color_USD; }
    if (EUR)
      { Indicator_Name = StringConcatenate(Indicator_Name, " EUR"); names[1] = "EUR"; colors[1] = Color_EUR; }
    if (GBP)
      { Indicator_Name = StringConcatenate(Indicator_Name, " GBP"); names[2] = "GBP"; colors[2] = Color_GBP; }
    if (CHF)
      { Indicator_Name = StringConcatenate(Indicator_Name, " CHF"); names[3] = "CHF"; colors[3] = Color_CHF; }
    if (JPY)
      { Indicator_Name = StringConcatenate(Indicator_Name, " JPY"); names[4] = "JPY"; colors[4] = Color_JPY; }
    if (AUD)
      { Indicator_Name = StringConcatenate(Indicator_Name, " AUD"); names[5] = "AUD"; colors[5] = Color_AUD; }
    if (CAD)
      { Indicator_Name = StringConcatenate(Indicator_Name, " CAD"); names[6] = "CAD"; colors[6] = Color_CAD; }
    if (NZD)
      { Indicator_Name = StringConcatenate(Indicator_Name, " NZD"); names[7] = "NZD"; colors[7] = Color_NZD; }

    if (NOK)
      { Indicator_Name = StringConcatenate(Indicator_Name, " NOK"); names[8] = "NOK"; colors[8] = Color_NOK; }
    if (SEK)
      { Indicator_Name = StringConcatenate(Indicator_Name, " SEK"); names[9] = "SEK"; colors[9] = Color_SEK; }
    if (SGD)
      { Indicator_Name = StringConcatenate(Indicator_Name, " SGD"); names[10] = "SGD"; colors[10] = Color_SGD; }

    IndicatorShortName(Indicator_Name);

    return (0);
}  // init()


// +------------------------------------------------------------------
// |
// +------------------------------------------------------------------
void addSymbol(string tSymbol)
{
    ArrayResize(symbols, ArraySize(symbols) + 1);
    symbols[ArraySize(symbols) - 1] = SymbolsPrefix + tSymbol + SymbolsSuffix;
}


//
//
//
int getLimit(int limit, string tSymbol)
{
    if (tSymbol != Symbol())
        limit = MathMax(MathMin(Bars - 1, iCustom(tSymbol, iTimeFrame, indicatorFileName, "returnBars", 0, 0) * iTimeFrame / Period()),
                        limit);

    return (limit);
}


// +------------------------------------------------------------------
// |
// +------------------------------------------------------------------
int start()
{
    int i, counted_bars = IndicatorCounted();

    if (counted_bars < 0)
        return (-1);

    if (counted_bars > 0)
        counted_bars--;
    int limit = MathMin(Bars - counted_bars, Bars - 1);
    if (returnBars)
      {
          arrUSD[0] = limit;
          return (0);
      }

    static bool initialized = false;
    if (!initialized)
      {
          initialized = true;
          int cur = StartPos;
          int st  = 23;

          if (USD)
            { sl(0, sColorKey, cur, Color_USD, "USD"); cur += st;  }
          if (EUR)
            { sl(1, sColorKey, cur, Color_EUR, "EUR"); cur += st; addSymbol("EURUSD"); }
          if (GBP)
            { sl(2, sColorKey, cur, Color_GBP, "GBP"); cur += st; addSymbol("GBPUSD"); }
          if (CHF)
            { sl(3, sColorKey, cur, Color_CHF, "CHF"); cur += st; addSymbol("USDCHF"); }
          if (JPY)
            { sl(4, sColorKey, cur, Color_JPY, "JPY"); cur += st; addSymbol("USDJPY"); }
          if (AUD)
            { sl(5, sColorKey, cur, Color_AUD, "AUD"); cur += st; addSymbol("AUDUSD"); }
          if (CAD)
            { sl(6, sColorKey, cur, Color_CAD, "CAD"); cur += st; addSymbol("USDCAD"); }
          if (NZD)
            { sl(7, sColorKey, cur, Color_NZD, "NZD"); cur += st; addSymbol("NZDUSD"); }

          if (NOK)
            { sl(8, sColorKey, cur, Color_NOK, "NOK"); cur += st; addSymbol("USDNOK"); }
          if (SEK)
            { sl(9, sColorKey, cur, Color_SEK, "SEK"); cur += st; addSymbol("USDSEK"); }
          if (SGD)
            { sl(10, sColorKey, cur, Color_SGD, "SGD"); cur += st; addSymbol("USDSGD"); }
      }

    for (int t = 0; t < ArraySize(symbols); t++)
        limit = getLimit(limit, symbols[t]);

    ArrayInitialize(values, -1);
    if (calculateValue || iTimeFrame == Period())
      {
          double EURUSD_Fast = 0, EURUSD_Slow = 0,
                 GBPUSD_Fast = 0, GBPUSD_Slow = 0,
                 AUDUSD_Fast = 0, AUDUSD_Slow = 0,
                 NZDUSD_Fast = 0, NZDUSD_Slow = 0,
                 USDCAD_Fast = 0, USDCAD_Slow = 0,
                 USDCHF_Fast = 0, USDCHF_Slow = 0,
                 USDJPY_Fast = 0, USDJPY_Slow = 0,
                 USDNOK_Fast = 0, USDNOK_Slow = 0,
                 USDSEK_Fast = 0, USDSEK_Slow = 0,
                 USDSGD_Fast = 0, USDSGD_Slow = 0;
          for (i = 0 ; i < limit-1; i++)
            {
                if (EUR)
                  {
                      EURUSD_Fast = ma("EURUSD", MaFast, MaMethod, MaAppliedPrice, i);
                      EURUSD_Slow = ma("EURUSD", MaSlow, MaMethod, MaAppliedPrice, i);
                      if (!EURUSD_Fast || !EURUSD_Slow)
                          break;
                  }
                if (GBP)
                  {
                      GBPUSD_Fast = ma("GBPUSD", MaFast, MaMethod, MaAppliedPrice, i);
                      GBPUSD_Slow = ma("GBPUSD", MaSlow, MaMethod, MaAppliedPrice, i);
                      if (!GBPUSD_Fast || !GBPUSD_Slow)
                          break;
                  }
                if (AUD)
                  {
                      AUDUSD_Fast = ma("AUDUSD", MaFast, MaMethod, MaAppliedPrice, i);
                      AUDUSD_Slow = ma("AUDUSD", MaSlow, MaMethod, MaAppliedPrice, i);
                      if (!AUDUSD_Fast || !AUDUSD_Slow)
                          break;
                  }
                if (NZD)
                  {
                      NZDUSD_Fast = ma("NZDUSD", MaFast, MaMethod, MaAppliedPrice, i);
                      NZDUSD_Slow = ma("NZDUSD", MaSlow, MaMethod, MaAppliedPrice, i);
                      if (!NZDUSD_Fast || !NZDUSD_Slow)
                          break;
                  }
                if (CAD)
                  {
                      USDCAD_Fast = ma("USDCAD", MaFast, MaMethod, MaAppliedPrice, i);
                      USDCAD_Slow = ma("USDCAD", MaSlow, MaMethod, MaAppliedPrice, i);
                      if (!USDCAD_Fast || !USDCAD_Slow)
                          break;
                  }
                if (CHF)
                  {
                      USDCHF_Fast = ma("USDCHF", MaFast, MaMethod, MaAppliedPrice, i);
                      USDCHF_Slow = ma("USDCHF", MaSlow, MaMethod, MaAppliedPrice, i);
                      if (!USDCHF_Fast || !USDCHF_Slow)
                          break;
                  }
                if (JPY)
                  {
                      USDJPY_Fast = ma("USDJPY", MaFast, MaMethod, MaAppliedPrice, i) / 100.0;
                      USDJPY_Slow = ma("USDJPY", MaSlow, MaMethod, MaAppliedPrice, i) / 100.0;
                      if (!USDJPY_Fast || !USDJPY_Slow)
                          break;
                  }


                if (NOK)
                  {
                      USDNOK_Fast = ma("USDNOK", MaFast, MaMethod, MaAppliedPrice, i);
                      USDNOK_Slow = ma("USDNOK", MaSlow, MaMethod, MaAppliedPrice, i);
                      if (!USDNOK_Fast || !USDNOK_Slow)
                          break;
                  }
                if (SEK)
                  {
                      USDSEK_Fast = ma("USDSEK", MaFast, MaMethod, MaAppliedPrice, i);
                      USDSEK_Slow = ma("USDSEK", MaSlow, MaMethod, MaAppliedPrice, i);
                      if (!USDSEK_Fast || !USDSEK_Slow)
                          break;
                  }
                if (SGD)
                  {
                      USDSGD_Fast = ma("USDSGD", MaFast, MaMethod, MaAppliedPrice, i);
                      USDSGD_Slow = ma("USDSGD", MaSlow, MaMethod, MaAppliedPrice, i);
                      if (!USDSGD_Fast || !USDSGD_Slow)
                          break;
                  }

                //
                //
                // Xusd pair
                // if(Yusd) and(YX)=Yusd(s)/Xusd(s)-Yusd(f)/Xusd(f)
                // if(Yusd) and(XY)=usdX(f)/Yusd(f)-usdX(s)/Yusd(s)
                // if(usdY) and(YX)=usdX(s)*usdY(s)-usdX(f)*usdY(f)
                // if(usdY) and(XY)=usdY(f)*Xusd(f)-usdY(s)*Xusd(s)

                // usdX pair
                // if(Yusd) and(YX)= Yusd(s)*usdX(s)-Yusd(f)*usdX(f)
                // if(Yusd) and(XY)=usdX(f)*Yusd(f)-usdX(s)*Yusd(s)
                // if(usdY) and(YX)=usdX(s)/usdY(s)-usdX(f)/usdY(f)
                // if(usdY) and(XY)= usdY(f)/usdX(f)-usdY(s)/usdX(s)

                if (USD)
                  {
                      arrUSD[i] = 0;
                      if (EUR) arrUSD[i] += EURUSD_Slow - EURUSD_Fast;
                      if (GBP) arrUSD[i] += GBPUSD_Slow - GBPUSD_Fast;
                      if (AUD) arrUSD[i] += AUDUSD_Slow - AUDUSD_Fast;
                      if (NZD) arrUSD[i] += NZDUSD_Slow - NZDUSD_Fast;
                      if (CHF) arrUSD[i] += USDCHF_Fast - USDCHF_Slow;
                      if (CAD) arrUSD[i] += USDCAD_Fast - USDCAD_Slow;
                      if (JPY) arrUSD[i] += USDJPY_Fast - USDJPY_Slow;
                      values[0] = arrUSD[i];
                  }
                if (EUR)
                  {
                      arrEUR[i] = 0;
                      if (USD) arrEUR[i] += EURUSD_Fast - EURUSD_Slow;
                      if (GBP) arrEUR[i] += EURUSD_Fast / GBPUSD_Fast - EURUSD_Slow / GBPUSD_Slow;
                      if (AUD) arrEUR[i] += EURUSD_Fast / AUDUSD_Fast - EURUSD_Slow / AUDUSD_Slow;
                      if (NZD) arrEUR[i] += EURUSD_Fast / NZDUSD_Fast - EURUSD_Slow / NZDUSD_Slow;
                      if (CHF) arrEUR[i] += EURUSD_Fast * USDCHF_Fast - EURUSD_Slow * USDCHF_Slow;
                      if (CAD) arrEUR[i] += EURUSD_Fast * USDCAD_Fast - EURUSD_Slow * USDCAD_Slow;
                      if (JPY) arrEUR[i] += EURUSD_Fast * USDJPY_Fast - EURUSD_Slow * USDJPY_Slow;
                      values[1] = arrEUR[i];
                  }
                if (GBP)
                  {
                      arrGBP[i] = 0;
                      if (USD) arrGBP[i] += GBPUSD_Fast - GBPUSD_Slow;
                      if (EUR) arrGBP[i] += EURUSD_Slow / GBPUSD_Slow - EURUSD_Fast / GBPUSD_Fast;
                      if (AUD) arrGBP[i] += GBPUSD_Fast / AUDUSD_Fast - GBPUSD_Slow / AUDUSD_Slow;
                      if (NZD) arrGBP[i] += GBPUSD_Fast / NZDUSD_Fast - GBPUSD_Slow / NZDUSD_Slow;
                      if (CHF) arrGBP[i] += GBPUSD_Fast * USDCHF_Fast - GBPUSD_Slow * USDCHF_Slow;
                      if (CAD) arrGBP[i] += GBPUSD_Fast * USDCAD_Fast - GBPUSD_Slow * USDCAD_Slow;
                      if (JPY) arrGBP[i] += GBPUSD_Fast * USDJPY_Fast - GBPUSD_Slow * USDJPY_Slow;
                      values[2] = arrGBP[i];
                  }
                if (AUD)
                  {
                      arrAUD[i] = 0;
                      if (USD) arrAUD[i] += AUDUSD_Fast - AUDUSD_Slow;
                      if (EUR) arrAUD[i] += EURUSD_Slow / AUDUSD_Slow - EURUSD_Fast / AUDUSD_Fast;
                      if (GBP) arrAUD[i] += GBPUSD_Slow / AUDUSD_Slow - GBPUSD_Fast / AUDUSD_Fast;
                      if (NZD) arrAUD[i] += AUDUSD_Fast / NZDUSD_Fast - AUDUSD_Slow / NZDUSD_Slow;
                      if (CHF) arrAUD[i] += AUDUSD_Fast * USDCHF_Fast - AUDUSD_Slow * USDCHF_Slow;
                      if (CAD) arrAUD[i] += AUDUSD_Fast * USDCAD_Fast - AUDUSD_Slow * USDCAD_Slow;
                      if (JPY) arrAUD[i] += AUDUSD_Fast * USDJPY_Fast - AUDUSD_Slow * USDJPY_Slow;
                      values[5] = arrAUD[i];
                  }
                if (NZD)
                  {
                      arrNZD[i] = 0;
                      if (USD) arrNZD[i] += NZDUSD_Fast - NZDUSD_Slow;
                      if (EUR) arrNZD[i] += EURUSD_Slow / NZDUSD_Slow - EURUSD_Fast / NZDUSD_Fast;
                      if (GBP) arrNZD[i] += GBPUSD_Slow / NZDUSD_Slow - GBPUSD_Fast / NZDUSD_Fast;
                      if (AUD) arrNZD[i] += AUDUSD_Slow / NZDUSD_Slow - AUDUSD_Fast / NZDUSD_Fast;
                      if (CHF) arrNZD[i] += NZDUSD_Fast * USDCHF_Fast - NZDUSD_Slow * USDCHF_Slow;
                      if (CAD) arrNZD[i] += NZDUSD_Fast * USDCAD_Fast - NZDUSD_Slow * USDCAD_Slow;
                      if (JPY) arrNZD[i] += NZDUSD_Fast * USDJPY_Fast - NZDUSD_Slow * USDJPY_Slow;
                      values[7] = arrNZD[i];
                  }
                if (CAD)
                  {
                      arrCAD[i] = 0;
                      if (USD) arrCAD[i] += USDCAD_Slow - USDCAD_Fast;
                      if (EUR) arrCAD[i] += EURUSD_Slow * USDCAD_Slow - EURUSD_Fast * USDCAD_Fast;
                      if (GBP) arrCAD[i] += GBPUSD_Slow * USDCAD_Slow - GBPUSD_Fast * USDCAD_Fast;
                      if (AUD) arrCAD[i] += AUDUSD_Slow * USDCAD_Slow - AUDUSD_Fast * USDCAD_Fast;
                      if (NZD) arrCAD[i] += NZDUSD_Slow * USDCAD_Slow - NZDUSD_Fast * USDCAD_Fast;
                      if (CHF) arrCAD[i] += USDCHF_Fast / USDCAD_Fast - USDCHF_Slow / USDCAD_Slow;
                      if (JPY) arrCAD[i] += USDJPY_Fast / USDCAD_Fast - USDJPY_Slow / USDCAD_Slow;
                      values[6] = arrCAD[i];
                  }
                if (CHF)
                  {
                      arrCHF[i] = 0;
                      if (USD) arrCHF[i] += USDCHF_Slow - USDCHF_Fast;
                      if (EUR) arrCHF[i] += EURUSD_Slow * USDCHF_Slow - EURUSD_Fast * USDCHF_Fast;
                      if (GBP) arrCHF[i] += GBPUSD_Slow * USDCHF_Slow - GBPUSD_Fast * USDCHF_Fast;
                      if (AUD) arrCHF[i] += AUDUSD_Slow * USDCHF_Slow - AUDUSD_Fast * USDCHF_Fast;
                      if (NZD) arrCHF[i] += NZDUSD_Slow * USDCHF_Slow - NZDUSD_Fast * USDCHF_Fast;
                      if (CAD) arrCHF[i] += USDCHF_Slow / USDCAD_Slow - USDCHF_Fast / USDCAD_Fast;
                      if (JPY) arrCHF[i] += USDJPY_Fast / USDCHF_Fast - USDJPY_Slow / USDCHF_Slow;
                      values[3] = arrCHF[i];
                  }
                if (JPY)
                  {
                      arrJPY[i] = 0;
                      if (USD) arrJPY[i] += USDJPY_Slow - USDJPY_Fast;
                      if (EUR) arrJPY[i] += EURUSD_Slow * USDJPY_Slow - EURUSD_Fast * USDJPY_Fast;
                      if (GBP) arrJPY[i] += GBPUSD_Slow * USDJPY_Slow - GBPUSD_Fast * USDJPY_Fast;
                      if (AUD) arrJPY[i] += AUDUSD_Slow * USDJPY_Slow - AUDUSD_Fast * USDJPY_Fast;
                      if (NZD) arrJPY[i] += NZDUSD_Slow * USDJPY_Slow - NZDUSD_Fast * USDJPY_Fast;
                      if (CAD) arrJPY[i] += USDJPY_Slow / USDCAD_Slow - USDJPY_Fast / USDCAD_Fast;
                      if (CHF) arrJPY[i] += USDJPY_Slow / USDCHF_Slow - USDJPY_Fast / USDCHF_Fast;
                      values[4] = arrJPY[i];
                  }


                // ////////////////////////////////////////////////////////////////////////////////////
                
                if (showOnlySymbolOnChart && NOK)
                  {
                      if (USD)
                        {
                            arrUSD[i] = 0;
                            if (EUR) arrUSD[i] += EURUSD_Slow - EURUSD_Fast;
                            if (GBP) arrUSD[i] += GBPUSD_Slow - GBPUSD_Fast;
                            if (JPY) arrUSD[i] += USDJPY_Fast - USDJPY_Slow;
                            if (NOK) arrUSD[i] += USDNOK_Fast - USDNOK_Slow;
                            if (SEK) arrUSD[i] += USDSEK_Fast - USDSEK_Slow;
                            values[0] = arrUSD[i];
                        }
                      if (EUR)
                        {
                            arrEUR[i] = 0;
                            if (USD) arrEUR[i] += EURUSD_Fast - EURUSD_Slow;
                            if (GBP) arrEUR[i] += EURUSD_Fast / GBPUSD_Fast - EURUSD_Slow / GBPUSD_Slow;
                            if (JPY) arrEUR[i] += EURUSD_Fast * USDJPY_Fast - EURUSD_Slow * USDJPY_Slow;
                            if (NOK) arrEUR[i] += USDNOK_Fast * EURUSD_Fast - USDNOK_Slow * EURUSD_Slow;
                            if (SEK) arrEUR[i] += USDSEK_Fast * EURUSD_Fast - USDSEK_Slow * EURUSD_Slow;
                            values[1] = arrEUR[i];
                        }
                      if (GBP)
                        {
                            arrGBP[i] = 0;
                            if (USD) arrGBP[i] += GBPUSD_Fast - GBPUSD_Slow;
                            if (EUR) arrGBP[i] += EURUSD_Slow / GBPUSD_Slow - EURUSD_Fast / GBPUSD_Fast;
                            if (JPY) arrGBP[i] += GBPUSD_Fast * USDJPY_Fast - GBPUSD_Slow * USDJPY_Slow;
                            if (NOK) arrGBP[i] += USDNOK_Fast * GBPUSD_Fast - USDNOK_Slow * GBPUSD_Slow;
                            if (SEK) arrGBP[i] += USDSEK_Fast * GBPUSD_Fast - USDSEK_Slow * GBPUSD_Slow;
                            values[2] = arrGBP[i];
                        }
                      if (JPY)
                        {
                            arrJPY[i] = 0;
                            if (USD) arrJPY[i] += USDJPY_Slow - USDJPY_Fast;
                            if (EUR) arrJPY[i] += EURUSD_Slow * USDJPY_Slow - EURUSD_Fast * USDJPY_Fast;
                            if (GBP) arrJPY[i] += GBPUSD_Slow * USDJPY_Slow - GBPUSD_Fast * USDJPY_Fast;
                            if (NOK) arrJPY[i] += USDJPY_Slow / USDNOK_Slow - USDJPY_Fast / USDNOK_Fast;
                            if (SEK) arrJPY[i] += USDJPY_Slow / USDSEK_Slow - USDJPY_Fast / USDSEK_Fast;
                            values[4] = arrJPY[i];
                        }
                      if (NOK)
                        {
                            arrNOK[i] = 0;
                            if (USD) arrNOK[i] += USDNOK_Slow - USDNOK_Fast;
                            if (EUR) arrNOK[i] += EURUSD_Slow * USDNOK_Slow - EURUSD_Fast * USDNOK_Fast;
                            if (GBP) arrNOK[i] += GBPUSD_Slow * USDNOK_Slow - GBPUSD_Fast * USDNOK_Fast;
                            if (JPY) arrNOK[i] += USDJPY_Fast / USDNOK_Fast - USDJPY_Slow / USDNOK_Slow;
                            if (SEK) arrNOK[i] += USDSEK_Fast / USDNOK_Fast - USDSEK_Slow / USDNOK_Slow;
                            values[8] = arrNOK[i];
                        }

                      if (SEK)
                        {
                            arrSEK[i] = 0;
                            if (USD) arrSEK[i] += USDSEK_Slow - USDSEK_Fast;
                            if (EUR) arrSEK[i] += EURUSD_Slow * USDSEK_Slow - EURUSD_Fast * USDSEK_Fast;
                            if (GBP) arrSEK[i] += GBPUSD_Slow * USDSEK_Slow - GBPUSD_Fast * USDSEK_Fast;
                            if (JPY) arrSEK[i] += USDJPY_Fast / USDSEK_Fast - USDJPY_Slow / USDSEK_Slow;
                            if (NOK) arrSEK[i] += USDSEK_Slow / USDNOK_Slow - USDSEK_Fast / USDNOK_Fast;
                            values[9] = arrSEK[i];
                        }
                  }

                if (showOnlySymbolOnChart && SEK)
                  {
                      if (USD)
                        {
                            arrUSD[i] = 0;
                            if (EUR) arrUSD[i] += EURUSD_Slow - EURUSD_Fast;
                            if (GBP) arrUSD[i] += GBPUSD_Slow - GBPUSD_Fast;
                            if (JPY) arrUSD[i] += USDJPY_Fast - USDJPY_Slow;
                            if (NOK) arrUSD[i] += USDNOK_Fast - USDNOK_Slow;
                            if (SEK) arrUSD[i] += USDSEK_Fast - USDSEK_Slow;
                            values[0] = arrUSD[i];
                        }
                      if (EUR)
                        {
                            arrEUR[i] = 0;
                            if (USD) arrEUR[i] += EURUSD_Fast - EURUSD_Slow;
                            if (GBP) arrEUR[i] += EURUSD_Fast / GBPUSD_Fast - EURUSD_Slow / GBPUSD_Slow;
                            if (JPY) arrEUR[i] += EURUSD_Fast * USDJPY_Fast - EURUSD_Slow * USDJPY_Slow;
                            if (NOK) arrEUR[i] += USDNOK_Fast * EURUSD_Fast - USDNOK_Slow * EURUSD_Slow;
                            if (SEK) arrEUR[i] += USDSEK_Fast * EURUSD_Fast - USDSEK_Slow * EURUSD_Slow;
                            values[1] = arrEUR[i];
                        }
                      if (GBP)
                        {
                            arrGBP[i] = 0;
                            if (USD) arrGBP[i] += GBPUSD_Fast - GBPUSD_Slow;
                            if (EUR) arrGBP[i] += EURUSD_Slow / GBPUSD_Slow - EURUSD_Fast / GBPUSD_Fast;
                            if (JPY) arrGBP[i] += GBPUSD_Fast * USDJPY_Fast - GBPUSD_Slow * USDJPY_Slow;
                            if (NOK) arrGBP[i] += USDNOK_Fast * GBPUSD_Fast - USDNOK_Slow * GBPUSD_Slow;
                            if (SEK) arrGBP[i] += USDSEK_Fast * GBPUSD_Fast - USDSEK_Slow * GBPUSD_Slow;
                            values[2] = arrGBP[i];
                        }
                      if (JPY)
                        {
                            arrJPY[i] = 0;
                            if (USD) arrJPY[i] += USDJPY_Slow - USDJPY_Fast;
                            if (EUR) arrJPY[i] += EURUSD_Slow * USDJPY_Slow - EURUSD_Fast * USDJPY_Fast;
                            if (GBP) arrJPY[i] += GBPUSD_Slow * USDJPY_Slow - GBPUSD_Fast * USDJPY_Fast;
                            if (NOK) arrJPY[i] += USDJPY_Slow / USDNOK_Slow - USDJPY_Fast / USDNOK_Fast;
                            if (SEK) arrJPY[i] += USDJPY_Slow / USDSEK_Slow - USDJPY_Fast / USDSEK_Fast;
                            values[4] = arrJPY[i];
                        }
                      if (NOK)
                        {
                            arrNOK[i] = 0;
                            if (USD) arrNOK[i] += USDNOK_Slow - USDNOK_Fast;
                            if (EUR) arrNOK[i] += EURUSD_Slow * USDNOK_Slow - EURUSD_Fast * USDNOK_Fast;
                            if (GBP) arrNOK[i] += GBPUSD_Slow * USDNOK_Slow - GBPUSD_Fast * USDNOK_Fast;
                            if (JPY) arrNOK[i] += USDJPY_Fast / USDNOK_Fast - USDJPY_Slow / USDNOK_Slow;
                            if (SEK) arrNOK[i] += USDSEK_Fast / USDNOK_Fast - USDSEK_Slow / USDNOK_Slow;
                            values[8] = arrNOK[i];
                        }

                      if (SEK)
                        {
                            arrSEK[i] = 0;
                            if (USD) arrSEK[i] += USDSEK_Slow - USDSEK_Fast;
                            if (EUR) arrSEK[i] += EURUSD_Slow * USDSEK_Slow - EURUSD_Fast * USDSEK_Fast;
                            if (GBP) arrSEK[i] += GBPUSD_Slow * USDSEK_Slow - GBPUSD_Fast * USDSEK_Fast;
                            if (JPY) arrSEK[i] += USDJPY_Fast / USDSEK_Fast - USDJPY_Slow / USDSEK_Slow;
                            if (NOK) arrSEK[i] += USDSEK_Slow / USDNOK_Slow - USDSEK_Fast / USDNOK_Fast;
                            values[9] = arrSEK[i];
                        }
                  }

                if (showOnlySymbolOnChart && SGD)
                  {
                      if (USD)
                        {
                            arrUSD[i] = 0;
                            if (EUR) arrUSD[i] += EURUSD_Slow - EURUSD_Fast;
                            if (GBP) arrUSD[i] += GBPUSD_Slow - GBPUSD_Fast;
                            if (AUD) arrUSD[i] += AUDUSD_Slow - AUDUSD_Fast;
                            if (CHF) arrUSD[i] += USDCHF_Fast - USDCHF_Slow;
                            if (JPY) arrUSD[i] += USDJPY_Fast - USDJPY_Slow;
                            if (SGD) arrUSD[i] += USDSGD_Fast - USDSGD_Slow;
                            values[0] = arrUSD[i];
                        }
                      if (EUR)
                        {
                            arrEUR[i] = 0;
                            if (USD) arrEUR[i] += EURUSD_Fast - EURUSD_Slow;
                            if (GBP) arrEUR[i] += EURUSD_Fast / GBPUSD_Fast - EURUSD_Slow / GBPUSD_Slow;
                            if (AUD) arrEUR[i] += EURUSD_Fast / AUDUSD_Fast - EURUSD_Slow / AUDUSD_Slow;
                            if (CHF) arrEUR[i] += EURUSD_Fast * USDCHF_Fast - EURUSD_Slow * USDCHF_Slow;
                            if (JPY) arrEUR[i] += EURUSD_Fast * USDJPY_Fast - EURUSD_Slow * USDJPY_Slow;
                            if (SGD) arrEUR[i] += USDSGD_Fast * EURUSD_Fast - USDSGD_Slow * EURUSD_Slow;
                            values[1] = arrEUR[i];
                        }
                      if (GBP)
                        {
                            arrGBP[i] = 0;
                            if (USD) arrGBP[i] += GBPUSD_Fast - GBPUSD_Slow;
                            if (EUR) arrGBP[i] += EURUSD_Slow / GBPUSD_Slow - EURUSD_Fast / GBPUSD_Fast;
                            if (AUD) arrGBP[i] += GBPUSD_Fast / AUDUSD_Fast - GBPUSD_Slow / AUDUSD_Slow;
                            if (CHF) arrGBP[i] += GBPUSD_Fast * USDCHF_Fast - GBPUSD_Slow * USDCHF_Slow;
                            if (JPY) arrGBP[i] += GBPUSD_Fast * USDJPY_Fast - GBPUSD_Slow * USDJPY_Slow;
                            if (SGD) arrGBP[i] += USDSGD_Fast * GBPUSD_Fast - USDSGD_Slow * GBPUSD_Slow;
                            values[2] = arrGBP[i];
                        }
                      if (JPY)
                        {
                            arrJPY[i] = 0;
                            if (USD) arrJPY[i] += USDJPY_Slow - USDJPY_Fast;
                            if (EUR) arrJPY[i] += EURUSD_Slow * USDJPY_Slow - EURUSD_Fast * USDJPY_Fast;
                            if (GBP) arrJPY[i] += GBPUSD_Slow * USDJPY_Slow - GBPUSD_Fast * USDJPY_Fast;
                            if (AUD) arrJPY[i] += AUDUSD_Slow * USDJPY_Slow - AUDUSD_Fast * USDJPY_Fast;
                            if (CHF) arrJPY[i] += USDJPY_Slow / USDCHF_Slow - USDJPY_Fast / USDCHF_Fast;
                            if (SGD) arrJPY[i] += USDJPY_Slow / USDSGD_Slow - USDJPY_Fast / USDSGD_Fast;
                            values[4] = arrJPY[i];
                        }
                      if (AUD)
                        {
                            arrAUD[i] = 0;
                            if (USD) arrAUD[i] += AUDUSD_Fast - AUDUSD_Slow;
                            if (EUR) arrAUD[i] += EURUSD_Slow / AUDUSD_Slow - EURUSD_Fast / AUDUSD_Fast;
                            if (GBP) arrAUD[i] += GBPUSD_Slow / AUDUSD_Slow - GBPUSD_Fast / AUDUSD_Fast;
                            if (CHF) arrAUD[i] += AUDUSD_Fast * USDCHF_Fast - AUDUSD_Slow * USDCHF_Slow;
                            if (JPY) arrAUD[i] += AUDUSD_Fast * USDJPY_Fast - AUDUSD_Slow * USDJPY_Slow;
                            if (SGD) arrAUD[i] += USDSGD_Fast * AUDUSD_Fast - USDSGD_Slow * AUDUSD_Slow;
                            values[5] = arrAUD[i];
                        }
                      if (CHF)
                        {
                            arrCHF[i] = 0;
                            if (USD) arrCHF[i] += USDCHF_Slow - USDCHF_Fast;
                            if (EUR) arrCHF[i] += EURUSD_Slow * USDCHF_Slow - EURUSD_Fast * USDCHF_Fast;
                            if (GBP) arrCHF[i] += GBPUSD_Slow * USDCHF_Slow - GBPUSD_Fast * USDCHF_Fast;
                            if (AUD) arrCHF[i] += AUDUSD_Slow * USDCHF_Slow - AUDUSD_Fast * USDCHF_Fast;
                            if (JPY) arrCHF[i] += USDJPY_Fast / USDCHF_Fast - USDJPY_Slow / USDCHF_Slow;
                            if (SGD) arrCHF[i] += USDSGD_Fast / USDCHF_Fast - USDSGD_Slow / USDCHF_Slow;
                            values[3] = arrCHF[i];
                        }

                      if (SGD)
                        {
                            arrSGD[i] = 0;
                            if (USD) arrSGD[i] += USDSGD_Slow - USDSGD_Fast;
                            if (EUR) arrSGD[i] += EURUSD_Slow * USDSGD_Slow - EURUSD_Fast * USDSGD_Fast;
                            if (GBP) arrSGD[i] += GBPUSD_Slow * USDSGD_Slow - GBPUSD_Fast * USDSGD_Fast;
                            if (AUD) arrSGD[i] += AUDUSD_Slow * USDSGD_Slow - AUDUSD_Fast * USDSGD_Fast;
                            if (CHF) arrSGD[i] += USDSGD_Slow / USDCHF_Slow - USDSGD_Fast / USDCHF_Fast;
                            if (JPY) arrSGD[i] += USDJPY_Fast / USDSGD_Fast - USDJPY_Slow / USDSGD_Slow;
                            values[10] = arrSGD[i];
                        }
                  }

                // //////////////////////////////////////////////////

                if (i == 0)
                    ArrayCopy(valuea, values);
            }

          for (i = limit-2; i >= 0; i--)
            {
                int    vzFontSize  = 10;
                int    vz2FontSize = 14;
                // int vz2FontSize = 10;
                double calc, calc2, digit0;
                string vz, vz2, vzup = "++", vzdown = " -- ";
                string vz2FontName = PanelFontName;
                string vz2up       = "+", vz2down = "--";
                // string vz2FontName = "Webdings";
                // string vz2up = "5", vz2down = "6";
                color  updown, vz2up_color = LimeGreen, vz2down_color = Red;


                if (showOnlySymbolOnChart)
                  { digit0 = 10000; }
                else { digit0 = 1000; }


                if (arrUSD[i + CalcBarA] > arrUSD[i + CalcBarB])
                  { vz = vzup; }
                else
                  { vz = vzdown; }
                  
                calc  = fabs((arrUSD[i + CalcBarA] - arrUSD[i + CalcBarB]) * digit0);
                calc2 = fabs((arrUSD[i + CalcBarA + 1] - arrUSD[i + CalcBarB + 1]) * digit0);
                if (calc > calc2)
                  { vz2    = vz2up;
                    updown = vz2up_color; }
                else
                  { vz2    = vz2down;
                    updown = vz2down_color; }
                if (ShowPanel)
                  {
                      ObjectCreate("usd", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                      ObjectSet("usd", OBJPROP_CORNER, PanelCorner);
                      ObjectSet("usd", OBJPROP_XDISTANCE, PanelMarginX + 17);
                      ObjectSet("usd", OBJPROP_YDISTANCE, PanelMarginY);
                      ObjectSetText("usd", "USD " + vz + DoubleToStr(calc, 3), vzFontSize, PanelFontName, Color_USD);

                      ObjectCreate("usd2", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                      ObjectSet("usd2", OBJPROP_CORNER, PanelCorner);
                      ObjectSet("usd2", OBJPROP_XDISTANCE, PanelMarginX + 2);
                      ObjectSet("usd2", OBJPROP_YDISTANCE, PanelMarginY);
                      ObjectSetText("usd2", vz2, vz2FontSize, vz2FontName, updown);
                  }


                if (arrEUR[i + CalcBarA] > arrEUR[i + CalcBarB])
                  { vz = vzup; }
                else
                  { vz = vzdown; }
                calc  = fabs((arrEUR[i + CalcBarA] - arrEUR[i + CalcBarB]) * digit0);
                calc2 = fabs((arrEUR[i + CalcBarA + 1] - arrEUR[i + CalcBarB + 1]) * digit0);
                if (calc > calc2)
                  { vz2    = vz2up;
                    updown = vz2up_color; }
                else
                  { vz2    = vz2down;
                    updown = vz2down_color; }
                if (ShowPanel)
                  {
                      ObjectCreate("eur", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                      ObjectSet("eur", OBJPROP_CORNER, PanelCorner);
                      ObjectSet("eur", OBJPROP_XDISTANCE, PanelMarginX + 17);
                      ObjectSet("eur", OBJPROP_YDISTANCE, PanelMarginY + 14);
                      ObjectSetText("eur", "EUR " + vz + DoubleToStr(calc, 3), vzFontSize, PanelFontName, Color_EUR);

                      ObjectCreate("eur2", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                      ObjectSet("eur2", OBJPROP_CORNER, PanelCorner);
                      ObjectSet("eur2", OBJPROP_XDISTANCE, PanelMarginX + 2);
                      ObjectSet("eur2", OBJPROP_YDISTANCE, PanelMarginY + 14);
                      ObjectSetText("eur2", vz2, vz2FontSize, vz2FontName, updown);
                  }


                if (arrGBP[i + CalcBarA] > arrGBP[i + CalcBarB])
                  { vz = vzup; }
                else
                  { vz = vzdown; }
                calc  = fabs((arrGBP[i + CalcBarA] - arrGBP[i + CalcBarB]) * digit0);
                calc2 = fabs((arrGBP[i + CalcBarA + 1] - arrGBP[i + CalcBarB + 1]) * digit0);
                if (calc > calc2)
                  { vz2    = vz2up;
                    updown = vz2up_color; }
                else
                  { vz2    = vz2down;
                    updown = vz2down_color; }
                if (ShowPanel)
                  {
                      ObjectCreate("gbp", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                      ObjectSet("gbp", OBJPROP_CORNER, PanelCorner);
                      ObjectSet("gbp", OBJPROP_XDISTANCE, PanelMarginX + 17);
                      ObjectSet("gbp", OBJPROP_YDISTANCE, PanelMarginY + 28);
                      ObjectSetText("gbp", "GBP " + vz + DoubleToStr(calc, 3), vzFontSize, PanelFontName, Color_GBP);

                      ObjectCreate("gbp2", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                      ObjectSet("gbp2", OBJPROP_CORNER, PanelCorner);
                      ObjectSet("gbp2", OBJPROP_XDISTANCE, PanelMarginX + 2);
                      ObjectSet("gbp2", OBJPROP_YDISTANCE, PanelMarginY + 28);
                      ObjectSetText("gbp2", vz2, vz2FontSize, vz2FontName, updown);
                  }


                if (arrCHF[i + CalcBarA] > arrCHF[i + CalcBarB])
                  { vz = vzup; }
                else
                  { vz = vzdown; }
                calc  = fabs((arrCHF[i + CalcBarA] - arrCHF[i + CalcBarB]) * digit0);
                calc2 = fabs((arrCHF[i + CalcBarA + 1] - arrCHF[i + CalcBarB + 1]) * digit0);
                if (calc > calc2)
                  { vz2    = vz2up;
                    updown = vz2up_color; }
                else
                  { vz2    = vz2down;
                    updown = vz2down_color; }
                if (ShowPanel)
                  {
                      ObjectCreate("chf", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                      ObjectSet("chf", OBJPROP_CORNER, PanelCorner);
                      ObjectSet("chf", OBJPROP_XDISTANCE, PanelMarginX + 17);
                      ObjectSet("chf", OBJPROP_YDISTANCE, PanelMarginY + 42);
                      ObjectSetText("chf", "CHF " + vz + DoubleToStr(calc, 3), vzFontSize, PanelFontName, Color_CHF);

                      ObjectCreate("chf2", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                      ObjectSet("chf2", OBJPROP_CORNER, PanelCorner);
                      ObjectSet("chf2", OBJPROP_XDISTANCE, PanelMarginX + 2);
                      ObjectSet("chf2", OBJPROP_YDISTANCE, PanelMarginY + 42);
                      ObjectSetText("chf2", vz2, vz2FontSize, vz2FontName, updown);
                  }


                if (arrJPY[i + CalcBarA] > arrJPY[i + CalcBarB])
                  { vz = vzup; }
                else
                  { vz = vzdown; }
                calc  = fabs((arrJPY[i + CalcBarA] - arrJPY[i + CalcBarB]) * digit0);
                calc2 = fabs((arrJPY[i + CalcBarA + 1] - arrJPY[i + CalcBarB + 1]) * digit0);
                if (calc > calc2)
                  { vz2    = vz2up;
                    updown = vz2up_color; }
                else
                  { vz2    = vz2down;
                    updown = vz2down_color; }
                if (ShowPanel)
                  {
                      ObjectCreate("jpy", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                      ObjectSet("jpy", OBJPROP_CORNER, PanelCorner);
                      ObjectSet("jpy", OBJPROP_XDISTANCE, PanelMarginX + 135);
                      ObjectSet("jpy", OBJPROP_YDISTANCE, PanelMarginY + 0);
                      ObjectSetText("jpy", "JPY " + vz + DoubleToStr(calc, 3), vzFontSize, PanelFontName, Color_JPY);

                      ObjectCreate("jpy2", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                      ObjectSet("jpy2", OBJPROP_CORNER, PanelCorner);
                      ObjectSet("jpy2", OBJPROP_XDISTANCE, PanelMarginX + 120);
                      ObjectSet("jpy2", OBJPROP_YDISTANCE, PanelMarginY + 0);
                      ObjectSetText("jpy2", vz2, vz2FontSize, vz2FontName, updown);
                  }


                if (arrAUD[i + CalcBarA] > arrAUD[i + CalcBarB])
                  { vz = vzup; }
                else
                  { vz = vzdown; }
                calc  = fabs((arrAUD[i + CalcBarA] - arrAUD[i + CalcBarB]) * digit0);
                calc2 = fabs((arrAUD[i + CalcBarA + 1] - arrAUD[i + CalcBarB + 1]) * digit0);
                if (calc > calc2)
                  { vz2    = vz2up;
                    updown = vz2up_color; }
                else
                  { vz2    = vz2down;
                    updown = vz2down_color; }
                if (ShowPanel)
                  {
                      ObjectCreate("aud", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                      ObjectSet("aud", OBJPROP_CORNER, PanelCorner);
                      ObjectSet("aud", OBJPROP_XDISTANCE, PanelMarginX + 135);
                      ObjectSet("aud", OBJPROP_YDISTANCE, PanelMarginY + 14);
                      ObjectSetText("aud", "AUD " + vz + DoubleToStr(calc, 3), vzFontSize, PanelFontName, Color_AUD);

                      ObjectCreate("aud2", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                      ObjectSet("aud2", OBJPROP_CORNER, PanelCorner);
                      ObjectSet("aud2", OBJPROP_XDISTANCE, PanelMarginX + 120);
                      ObjectSet("aud2", OBJPROP_YDISTANCE, PanelMarginY + 14);
                      ObjectSetText("aud2", vz2, vz2FontSize, vz2FontName, updown);
                  }


                if (arrCAD[i + CalcBarA] > arrCAD[i + CalcBarB])
                  { vz = vzup; }
                else
                  { vz = vzdown; }
                calc  = fabs((arrCAD[i + CalcBarA] - arrCAD[i + CalcBarB]) * digit0);
                calc2 = fabs((arrCAD[i + CalcBarA + 1] - arrCAD[i + CalcBarB + 1]) * digit0);
                if (calc > calc2)
                  { vz2    = vz2up;
                    updown = vz2up_color; }
                else
                  { vz2    = vz2down;
                    updown = vz2down_color; }
                if (ShowPanel)
                  {
                      ObjectCreate("cad", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                      ObjectSet("cad", OBJPROP_CORNER, PanelCorner);
                      ObjectSet("cad", OBJPROP_XDISTANCE, PanelMarginX + 135);
                      ObjectSet("cad", OBJPROP_YDISTANCE, PanelMarginY + 28);
                      ObjectSetText("cad", "CAD " + vz + DoubleToStr(calc, 3), vzFontSize, PanelFontName, Color_CAD);

                      ObjectCreate("cad2", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                      ObjectSet("cad2", OBJPROP_CORNER, PanelCorner);
                      ObjectSet("cad2", OBJPROP_XDISTANCE, PanelMarginX + 120);
                      ObjectSet("cad2", OBJPROP_YDISTANCE, PanelMarginY + 28);
                      ObjectSetText("cad2", vz2, vz2FontSize, vz2FontName, updown);
                  }


                if (arrNZD[i + CalcBarA] > arrNZD[i + CalcBarB])
                  { vz = vzup; }
                else
                  { vz = vzdown; }
                calc  = fabs((arrNZD[i + CalcBarA] - arrNZD[i + CalcBarB]) * digit0);
                calc2 = fabs((arrNZD[i + CalcBarA + 1] - arrNZD[i + CalcBarB + 1]) * digit0);
                if (calc > calc2)
                  { vz2    = vz2up;
                    updown = vz2up_color; }
                else
                  { vz2    = vz2down;
                    updown = vz2down_color; }
                if (ShowPanel)
                  {
                      ObjectCreate("nzd", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                      ObjectSet("nzd", OBJPROP_CORNER, PanelCorner);
                      ObjectSet("nzd", OBJPROP_XDISTANCE, PanelMarginX + 135);
                      ObjectSet("nzd", OBJPROP_YDISTANCE, PanelMarginY + 42);
                      ObjectSetText("nzd", "NZD " + vz + DoubleToStr(calc, 3), vzFontSize, PanelFontName, Color_NZD);

                      ObjectCreate("nzd2", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                      ObjectSet("nzd2", OBJPROP_CORNER, PanelCorner);
                      ObjectSet("nzd2", OBJPROP_XDISTANCE, PanelMarginX + 120);
                      ObjectSet("nzd2", OBJPROP_YDISTANCE, PanelMarginY + 42);
                      ObjectSetText("nzd2", vz2, vz2FontSize, vz2FontName, updown);
                  }


                if (showOnlySymbolOnChart)
                  {
                      if (arrNOK[i + CalcBarA] > arrNOK[i + CalcBarB])
                        { vz = vzup; }
                      else
                        { vz = vzdown; }
                      calc  = fabs((arrNOK[i + CalcBarA] - arrNOK[i + CalcBarB]) * digit0);
                      calc2 = fabs((arrNOK[i + CalcBarA + 1] - arrNOK[i + CalcBarB + 1]) * digit0);
                      if (calc > calc2)
                        { vz2    = vz2up;
                          updown = vz2up_color; }
                      else
                        { vz2    = vz2down;
                          updown = vz2down_color; }
                      if (ShowPanel)
                        {
                            ObjectCreate("nok", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                            ObjectSet("nok", OBJPROP_CORNER, PanelCorner);
                            ObjectSet("nok", OBJPROP_XDISTANCE, PanelMarginX + 17);
                            ObjectSet("nok", OBJPROP_YDISTANCE, PanelMarginY + 56);
                            ObjectSetText("nok", "NOK " + vz + DoubleToStr(calc, 3), vzFontSize, PanelFontName, Color_NOK);

                            ObjectCreate("nok2", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                            ObjectSet("nok2", OBJPROP_CORNER, PanelCorner);
                            ObjectSet("nok2", OBJPROP_XDISTANCE, PanelMarginX + 2);
                            ObjectSet("nok2", OBJPROP_YDISTANCE, PanelMarginY + 56);
                            ObjectSetText("nok2", vz2, vz2FontSize, vz2FontName, updown);
                        }


                      if (arrSEK[i + CalcBarA] > arrSEK[i + CalcBarB])
                        { vz = vzup; }
                      else
                        { vz = vzdown; }
                      calc  = fabs((arrSEK[i + CalcBarA] - arrSEK[i + CalcBarB]) * digit0);
                      calc2 = fabs((arrSEK[i + CalcBarA + 1] - arrSEK[i + CalcBarB + 1]) * digit0);
                      if (calc > calc2)
                        { vz2    = vz2up;
                          updown = vz2up_color; }
                      else
                        { vz2    = vz2down;
                          updown = vz2down_color; }
                      if (ShowPanel)
                        {
                            ObjectCreate("sek", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                            ObjectSet("sek", OBJPROP_CORNER, PanelCorner);
                            ObjectSet("sek", OBJPROP_XDISTANCE, PanelMarginX + 135);
                            ObjectSet("sek", OBJPROP_YDISTANCE, PanelMarginY + 56);
                            ObjectSetText("sek", "SEK " + vz + DoubleToStr(calc, 3), vzFontSize, PanelFontName, Color_SEK);

                            ObjectCreate("sek2", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                            ObjectSet("sek2", OBJPROP_CORNER, PanelCorner);
                            ObjectSet("sek2", OBJPROP_XDISTANCE, PanelMarginX + 120);
                            ObjectSet("sek2", OBJPROP_YDISTANCE, PanelMarginY + 56);
                            ObjectSetText("sek2", vz2, vz2FontSize, vz2FontName, updown);
                        }


                      if (arrSGD[i + CalcBarA] > arrSGD[i + CalcBarB])
                        { vz = vzup; }
                      else
                        { vz = vzdown; }
                      calc  = fabs((arrSGD[i + CalcBarA] - arrSGD[i + CalcBarB]) * digit0);
                      calc2 = fabs((arrSGD[i + CalcBarA + 1] - arrSGD[i + CalcBarB + 1]) * digit0);
                      if (calc > calc2)
                        { vz2    = vz2up;
                          updown = vz2up_color; }
                      else
                        { vz2    = vz2down;
                          updown = vz2down_color; }
                      if (ShowPanel)
                        {
                            ObjectCreate("sgd", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                            ObjectSet("sgd", OBJPROP_CORNER, PanelCorner);
                            ObjectSet("sgd", OBJPROP_XDISTANCE, PanelMarginX + 17);
                            ObjectSet("sgd", OBJPROP_YDISTANCE, PanelMarginY + 70);
                            ObjectSetText("sgd", "SGD " + vz + DoubleToStr(calc, 3), vzFontSize, PanelFontName, Color_SGD);

                            ObjectCreate("sgd2", OBJ_LABEL, PanelSubWindow, 0, 0, 0, 0);
                            ObjectSet("sgd2", OBJPROP_CORNER, PanelCorner);
                            ObjectSet("sgd2", OBJPROP_XDISTANCE, PanelMarginX + 2);
                            ObjectSet("sgd2", OBJPROP_YDISTANCE, PanelMarginY + 70);
                            ObjectSetText("sgd2", vz2, vz2FontSize, vz2FontName, updown);
                        }
                  }
            }

          return (0);
      }


    for (i = limit; i >= 0; i--)
      {
          int y = iBarShift(NULL, iTimeFrame, Time[i]);

          if (USD) arrUSD[i] = iCustom(NULL, iTimeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, MaAppliedPrice, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, NOK, SEK, SGD, 0, y);
          if (EUR) arrEUR[i] = iCustom(NULL, iTimeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, MaAppliedPrice, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, NOK, SEK, SGD, 1, y);
          if (GBP) arrGBP[i] = iCustom(NULL, iTimeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, MaAppliedPrice, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, NOK, SEK, SGD, 2, y);
          if (CHF) arrCHF[i] = iCustom(NULL, iTimeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, MaAppliedPrice, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, NOK, SEK, SGD, 3, y);
          if (JPY) arrJPY[i] = iCustom(NULL, iTimeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, MaAppliedPrice, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, NOK, SEK, SGD, 4, y);
          if (AUD) arrAUD[i] = iCustom(NULL, iTimeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, MaAppliedPrice, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, NOK, SEK, SGD, 5, y);
          if (CAD) arrCAD[i] = iCustom(NULL, iTimeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, MaAppliedPrice, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, NOK, SEK, SGD, 6, y);
          if (NZD) arrNZD[i] = iCustom(NULL, iTimeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, MaAppliedPrice, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, NOK, SEK, SGD, 7, y);

          if (NOK) arrNOK[i] = iCustom(NULL, iTimeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, MaAppliedPrice, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, NOK, SEK, SGD, 8, y);
          if (SEK) arrSEK[i] = iCustom(NULL, iTimeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, MaAppliedPrice, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, NOK, SEK, SGD, 9, y);
          if (SGD) arrSGD[i] = iCustom(NULL, iTimeFrame, indicatorFileName, "calculateValue", SymbolsPrefix, SymbolsSuffix, MaMethod, MaFast, MaSlow, MaAppliedPrice, USD, EUR, GBP, CHF, JPY, AUD, CAD, NZD, NOK, SEK, SGD, 10, y);

          if (USD) values[0] = arrUSD[i];
          if (EUR) values[1] = arrEUR[i];
          if (GBP) values[2] = arrGBP[i];
          if (CHF) values[3] = arrCHF[i];
          if (JPY) values[4] = arrJPY[i];
          if (AUD) values[5] = arrAUD[i];
          if (CAD) values[6] = arrCAD[i];
          if (NZD) values[7] = arrNZD[i];

          if (NOK) values[8] = arrNOK[i];
          if (SEK) values[9] = arrSEK[i];
          if (SGD) values[10] = arrSGD[i];


          if (i == 0)
              ArrayCopy(valuea, values);
          if (!Interpolate || y == iBarShift(NULL, iTimeFrame, Time[i - 1]))
              continue;


          if (USD) interpolate(arrUSD, iTime(NULL, iTimeFrame, y), i);
          if (EUR) interpolate(arrEUR, iTime(NULL, iTimeFrame, y), i);
          if (GBP) interpolate(arrGBP, iTime(NULL, iTimeFrame, y), i);
          if (JPY) interpolate(arrJPY, iTime(NULL, iTimeFrame, y), i);
          if (CHF) interpolate(arrCHF, iTime(NULL, iTimeFrame, y), i);
          if (AUD) interpolate(arrAUD, iTime(NULL, iTimeFrame, y), i);
          if (CAD) interpolate(arrCAD, iTime(NULL, iTimeFrame, y), i);
          if (NZD) interpolate(arrNZD, iTime(NULL, iTimeFrame, y), i);

          if (NOK) interpolate(arrNOK, iTime(NULL, iTimeFrame, y), i);
          if (SEK) interpolate(arrSEK, iTime(NULL, iTimeFrame, y), i);
          if (SGD) interpolate(arrSGD, iTime(NULL, iTimeFrame, y), i);
      }

    return (0);
}  // start()


// -------------------------------------------------------------------
//
// -------------------------------------------------------------------
bool check(string what, bool otherwise)
{
    if (showOnlySymbolOnChart)
        if (StringFind(Symbol(), what) != -1)
            return (true);
        else return (false);

    return (otherwise);
}


// -------------------------------------------------------------------
//
// -------------------------------------------------------------------
void interpolate(double& buffer[], datetime time, int i)
{
    int n;

    for (n = 1; (i + n) < Bars && Time[i + n] >= time; n++)
        continue;

    if (buffer[i] == EMPTY_VALUE || buffer[i + n] == EMPTY_VALUE)
        n = -1;
    double increment = (buffer[i + n] - buffer[i]) / n;
    for (int k = 1; k < n; k++)
        buffer[i + k] = buffer[i] + k * increment;
}


//
//
//
double ma(string sSymbol, int ma_period, int ma_method, int applied_price, int iShift)
{
    return ( iMA(SymbolsPrefix + sSymbol + SymbolsSuffix, PERIOD_CURRENT, ma_period, 0, ma_method, applied_price, iShift) );
}


// +------------------------------------------------------------------
// |
// +------------------------------------------------------------------
void sl(int LineIndx, string sym, int Xpixels, color LineColr, string LabelTxt)
{
    int    window      = WindowFind(Indicator_Name);
    string object_name = Indicator_Name + LineIndx;

    if (ObjectCreate(object_name, OBJ_LABEL, window, 0, 0))
        ObjectSet(object_name, OBJPROP_XDISTANCE, Xpixels + 25);
    ObjectSet(object_name, OBJPROP_YDISTANCE, 5);
    ObjectSetText(object_name, sym, 18, HeadingFontName, LineColr);

    SetIndexStyle(LineIndx, DRAW_LINE, STYLE_SOLID, Line_Width, LineColr);
    SetIndexLabel(LineIndx, LabelTxt);
}


// +-------------------------------------------------------------------
// |
// +-------------------------------------------------------------------
int stringToTimeFrame(string sTF)
{
    sTF = stringUpperCase(sTF);
    for (int i = ArraySize(iMinuteTfTable) - 1; i >= 0; i--)
        if (sTF == sTfTable[i] || sTF == "" + iMinuteTfTable[i])
            return (MathMax(iMinuteTfTable[i], Period()));

    return (Period());
}


string timeFrameToString(int iTF)
{
    for (int i = ArraySize(iMinuteTfTable) - 1; i >= 0; i--)
        if (iTF == iMinuteTfTable[i])
            return (sTfTable[i]);

    return ("");
}


//
//
//
string stringUpperCase(string str)
{
    string s = str;

    for (int length = StringLen(str) - 1; length >= 0; length--)
      {
          int tchar = StringGetChar(s, length);
          if ((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
              s = StringSetChar(s, length, tchar - 32);
          else if (tchar > -33 && tchar < 0)
              s = StringSetChar(s, length, tchar + 224);
      }

    return (s);
}


//
//
//
int deinit()
{
    int i;

    for (i = 0; i < MAXPAIRS; i++)
        ObjectDelete(Indicator_Name + i);
    for (i = 0; i < MAXPAIRS; i++)
        ObjectDelete(Indicator_Name + ":" + i);
    for (i = 0; i < MAXPAIRS; i++)
        ObjectDelete(Indicator_Name + ":n" + i);

    ObjectDelete("Spread");

    ObjectDelete("usd");
    ObjectDelete("usd2");
    ObjectDelete("eur");
    ObjectDelete("eur2");
    ObjectDelete("gbp");
    ObjectDelete("gbp2");
    ObjectDelete("chf");
    ObjectDelete("chf2");
    ObjectDelete("cad");
    ObjectDelete("cad2");
    ObjectDelete("jpy");
    ObjectDelete("jpy2");
    ObjectDelete("nzd");
    ObjectDelete("nzd2");
    ObjectDelete("aud");
    ObjectDelete("aud2");

    ObjectDelete("nok");
    ObjectDelete("nok2");
    ObjectDelete("sek");
    ObjectDelete("sek2");
    ObjectDelete("sgd");
    ObjectDelete("sgd2");

    return (0);
}


