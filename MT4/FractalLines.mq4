//+------------------------------------------------------------------+
//|                                                 FractalLines.mq4 |
//|                      Copyright � 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- input parameters
extern int  lines = 5;  //���������� ������� ����������� �����
extern int  MaxFractals = 10000;
extern bool ShowHorisontalLines = true;
extern bool ShowFractalLines = true; 
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//--- my variables
double bufUpPrice[10000];   //������ ��� Up ���������
double bufUpDate[10000];    //������ ��� Up ���������
double bufDownPrice[10000]; //������ ��� Down ���������
double bufDownDate[10000];  //������ ��� Down ���������
int Up = 0;    //������� Up ���������
int Down = 0;  //������� Down ���������
//+------------------------------------------------------------------+
//| ������� LevelCalculate ������� �������� ���� �������� �����������|
//| ����� �� ���������� ���������� ������������� ���������           |
//+------------------------------------------------------------------+
double LevelCalculate(double Price1, double Time1, double Price2,  
                      double Time2, double NewTime)
  {
   double level;
   if(Time2 != Time1) // �� ������ ������, ����� �� ���� ������� �� 0.
       level = (NewTime - Time1)*(Price2 - Price1) / (Time2-Time1) + Price1;
   else
       return(Price2);
   return(level);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 217);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexEmptyValue(0, 0.0);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 218);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexEmptyValue(1, 0.0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
//---- ��������� ����������� ��� ����� ����������   
   if(counted_bars > 0) 
       counted_bars--;
   int limit = Bars - counted_bars;
//�������, ��������� ������� � ������ �������� ����������� �����, ������ �������������
//���� �������������� � Rosha, �������, �� �������� :)    
   string arrowName; // ����� ����� ����������� ���������� ��� �������-�������
//����� ��������� ��������
//�������� ����������� �����
   int FractalUp = 0;
   int FractalDown = 0;
//������� �������� ��������
   int SimpleFractalUp = 0;
   int SimpleFractalDown = 0;
   double BuyFractalLevel = 0;  //������� �������� ����������� ����� Up
   double SellFractalLevel = 0; //������� �������� ����������� ����� Down
   double buf = 0; // �������� �������� ������� ��������, ���� 0, �� �������� ���
//---- �������� ����       
   for(int i = limit; i>0; i--)
     {   
       //������ ������� ����������� ������
       //��������� ������� ����������� ������ 
       BuyFractalLevel = LevelCalculate(bufUpPrice[Up], bufUpDate[Up], bufUpPrice[Up-1],
                                        bufUpDate[Up-1], Time[i]);
       //������� ������ ���������� ����������� ������ Up                              
       ObjectSet("LineUp" + Up, OBJPROP_TIME1, Time[i]);
       ObjectSet("LineUp" + Up, OBJPROP_PRICE1, BuyFractalLevel); 
       SellFractalLevel = LevelCalculate(bufDownPrice[Down], bufDownDate[Down], 
                                         bufDownPrice[Down-1], bufDownDate[Down-1], Time[i]);
       //������� ������ ���������� ����������� ������ Down                                
       ObjectSet("LineDown" + Down, OBJPROP_TIME1, Time[i]);
       ObjectSet("LineDown" + Down, OBJPROP_PRICE1, SellFractalLevel);
       //���� ������� ��������
       if(Close[i] > ObjectGet("SimpleUp" + Up, OBJPROP_PRICE1) && (Up > SimpleFractalUp))
         {
           arrowName = "SimleUpArrow" + Up;
           ObjectCreate(arrowName, OBJ_ARROW, 0, Time[i-1], Low[i-1] - Point*10);
           ObjectSet(arrowName, OBJPROP_ARROWCODE, 241);
           ObjectSet(arrowName, OBJPROP_COLOR, Brown);
           SimpleFractalUp = Up;             
         }
       if(Close[i] < ObjectGet("SimpleDown" + Down, OBJPROP_PRICE1) && 
          (Down > SimpleFractalDown))
         {
           arrowName = "SimleUpArrow" + Down;
           ObjectCreate(arrowName, OBJ_ARROW, 0, Time[i-1], High[i-1] + Point*10);
           ObjectSet(arrowName, OBJPROP_ARROWCODE, 242);
           ObjectSet(arrowName, OBJPROP_COLOR, Brown);
           SimpleFractalDown = Down;
         }
       //���� ������� ��������
       if((Close[i] > BuyFractalLevel) && (Up > FractalUp)) 
         {
           //������ ��������� �����
           arrowName = "UpArrow" + Up;
           ObjectCreate(arrowName, OBJ_ARROW, 0, Time[i-1], Low[i-1] - Point*10);
           ObjectSet(arrowName, OBJPROP_ARROWCODE, 241);
           ObjectSet(arrowName, OBJPROP_COLOR, Blue);
           FractalUp = Up;        
         }                                 
       if((Close[i] < SellFractalLevel) && (Down > FractalDown))
         {
           //������ ��������� �����
           arrowName = "DownArrow" + Down;
           ObjectCreate(arrowName, OBJ_ARROW, 0, Time[i-1], High[i-1] + Point*10);
           ObjectSet(arrowName, OBJPROP_ARROWCODE, 242);
           ObjectSet(arrowName, OBJPROP_COLOR, Red); 
           FractalDown = Down;       
         }
       //������ ��� �������  Up
       ExtMapBuffer1[i] = iFractals(NULL, 0, MODE_UPPER, i);
       //���� �� ����, �� ������� ��� � ������ ���������
       buf = iFractals(NULL, 0, MODE_UPPER, i);
       if(buf != 0)
         {
           Up++;
           bufUpPrice[Up] = iFractals(NULL, 0, MODE_UPPER, i);
           bufUpDate[Up] = Time[i];
           //������� ������� �������� �������� - ��� �������
           BuyFractalLevel = bufUpPrice[Up];
           if(Up > 1)
             {
               //������� �������
               ObjectCreate("SimpleUp" + Up, OBJ_TREND, 0, bufUpDate[Up], 
                            bufUpPrice[Up], Time[i-1], bufUpPrice[Up]);
               ObjectSet("SimpleUp" + Up, OBJPROP_COLOR, Aqua);
               ObjectSet("SimpleUp" + Up, OBJPROP_RAY, True);   
               //������ ����������� ����� �� 2 �����������
               ObjectCreate("LineUp" + Up, OBJ_TREND, 0, bufUpDate[Up], 
                            bufUpPrice[Up], bufUpDate[Up-1], bufUpPrice[Up-1]); 
               ObjectSet("LineUp" + Up, OBJPROP_COLOR, Blue);
               ObjectSet("LineUp" + Up, OBJPROP_RAY, False);
               //������� ���������� �����
               if(Up > lines + 1)
                 {
                   ObjectDelete("LineUp" + (Up - lines));
                   ObjectDelete("SimpleUp" + (Up - lines));                  
                 }
             }     
         }
       //����������� ����, �� �� Down ��������
       ExtMapBuffer2[i] = iFractals(NULL, 0, MODE_LOWER, i);
       buf = iFractals(NULL, 0, MODE_LOWER, i);    
       if(buf != 0)
         {
           Down++;
           bufDownPrice[Down] = iFractals(NULL, 0, MODE_LOWER, i);
           bufDownDate[Down] = Time[i];
           SellFractalLevel = bufDownPrice[Down];                           
           if(Down > 1)
             {
               ObjectCreate("SimpleDown" + Down, OBJ_TREND, 0, bufDownDate[Down], 
                            bufDownPrice[Down], Time[i-1], bufDownPrice[Down]);        
               ObjectSet("SimpleDown" + Down, OBJPROP_COLOR, LightCoral);
               ObjectSet("SimpleDown" + Down, OBJPROP_RAY, True);                
               ObjectCreate("LineDown" + Down, OBJ_TREND, 0, bufDownDate[Down], 
                            bufDownPrice[Down], bufDownDate[Down-1], bufDownPrice[Down-1]);        
               ObjectSet("LineDown" + Down, OBJPROP_COLOR, Red);
               ObjectSet("LineDown" + Down, OBJPROP_RAY, False);
               if(Down > lines + 1)
                 {
                   ObjectDelete("LineDown" + (Down - lines));
                   ObjectDelete("SimpleDown" + (Down - lines));
                 }            
             }   
         }           
       if(!ShowHorisontalLines)
         {   
           ObjectDelete("SimpleDown" + Down);              
           ObjectDelete("SimpleUp" + Up);                
         }
       if(!ShowFractalLines)
         {
           ObjectDelete("LineDown" + Down);        
           ObjectDelete("LineUp" + Up);
         }          
     }   
//----
   return(0);
  }
//+------------------------------------------------------------------+