//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <Arrays\ArrayDouble.mqh>
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayString.mqh>
//#include <Object.mqh>

#include <ere\sqlite.mqh>
//#include <RegularExpressions\\Regex.mqh>
#include <ere\include1v2.mqh>

#property indicator_chart_window

extern ENUM_SymbolCorner Symbol_Corner = TopLeft;
extern int cols=1;
extern int leftmargin=10;
extern int RowHeight=20;
extern int topMargin=10;
extern int ColRowFntSz =10;
extern bool ShowDataObjects = false;


long current_chart_id=ChartID(),iIndx;
string sIndiName=WindowExpertName();
int iLine=0,iCol=0,iPos=NULL,iStartHeader=20,iStartList=40;
int dColWidth,iFontSize,iSearchCount=0;
double dMargin1=8;
bool StopWritingVWAPS=false;

const string sDBPath="C:\\Users\\amos\\AppData\\Roaming\\MetaQuotes\\Terminal\\Common\\Files\\VWAP"+".db";
//Memory DB+ shared cache
//const string sDBPath="file:vwapdb?mode=memory&cache=shared";
const int iFlags=SQLITE_OPEN_NOMUTEX|SQLITE_OPEN_READWRITE;  //open in Multithreade mode
//SQLITE_READONLY|SQLITE_OPEN_NOMUTEX
SQLite db;



class TableColDefs{
   
   
   string mapTabCol;
   string typeColSymbol;
   int    contentType;
   
   public:
   double colWidth;
   string colHeader;
      
   enum ENUM_RowContentType{
      ENUM_RowContentType_TableTitle1  =0,
      ENUM_RowContentType_ColHeader1   =1,
      ENUM_RowContentType_RowHeader1   =2,
      ENUM_RowContentType_Data1        =3,
   };
   
   TableColDefs(string ColHeader,string MapTabCol, string TypeColSymbol, double ColWidth, int ContentType ):
      colHeader(ColHeader),
      mapTabCol(MapTabCol),
      typeColSymbol(TypeColSymbol),
      colWidth(ColWidth),
      contentType(ContentType){};
      //void  ValidateTableColDefs();
};

class CBasicSelectTable
{
      string sFont,sFontSymbol;
      int iFontSize2;
      color colorChn;      
      string symbolNames[];
      int symbolOrderCnt[];

   
      TableColDefs *colDefs[];
      string sql;
      string title;
      double tableMargin;
      int colCount;
      //CArrayString soCellNames;
        
   public:
      
      ~CBasicSelectTable(){
      
      };
      CBasicSelectTable(void){
            sFont = "Courier New Bold"; //(IsColHeader||IsTableTitle)?"Courier New Bold":"Courier New";
            sFontSymbol="Windings";
            iFontSize2=ColRowFntSz;  
            colorChn=clrWhiteSmoke;       
      };
      CBasicSelectTable(string TableTitle,double TableMargin, string Sql, TableColDefs* &ColDefs[]):  
         title(TableTitle),
         tableMargin(TableMargin), 
         colCount(ProcessDefs(ColDefs)){
         
            sFont = "Courier New Bold"; //(IsColHeader||IsTableTitle)?"Courier New Bold":"Courier New";
            sFontSymbol="Windings";
            iFontSize2=ColRowFntSz;  
            colorChn=clrWhiteSmoke;  
            sql=Sql;
         };


      int ProcessDefs(TableColDefs* &ColDefs[]){
         
         ArrayCopy(colDefs,ColDefs,0,0,WHOLE_ARRAY);        
         return ArraySize(colDefs);
      }

      void drawTabularCell(string Label, int contentType, double x, double y, int ColPos, int RowPos)
      { 
      
            //Print("X:"+x+":Y="+y);
            string sObjName,sObjName2,sObjNameSuffix;

            if(contentType==ENUM_RowContentType_TableTitle1)
            {
                 sObjNameSuffix = "_TabTit";
                 colorChn = clrWhite;
            }
            else if(contentType==ENUM_RowContentType_ColHeader1){
                  //Print("drawTabularCell");
                  sObjNameSuffix = "_ColHed_"+(string)ColPos;
                  colorChn = clrSkyBlue;  
            }
            else if(contentType==ENUM_RowContentType_RowHeader1){
                  sObjNameSuffix = "_RowHed_"+Label; //+"_"+(string)RowPos;
                  colorChn = clrSkyBlue; 
            }
            else if(contentType==ENUM_RowContentType_Data1){
                  sObjNameSuffix = "_Data_"+Label+"_"+ (string)RowPos ;//(string)ColPos+"_"+;
                  Label="-";
                  
                  colorChn = clrBlack;
            } 
            /*  
            else{
                  sObjNameSuffix = "_Back_"+Label+"_"+ (string)RowPos ;//(string)ColPos+"_"+;
                  Label=" ";
                  
                  colorChn = clrBlack;
            }   
            */
            
            //sObjName=sIndiName+sObjNameSuffix;
            //soCellNames.Add(sObjName);
            ;
            //sObjName2=sIndiName+sObjNameSuffix+"_RecGrhcs";
            
            //ObjectDelete(sObjName2);
            //ObjectCreate(sObjName2,OBJ_RECTANGLE_LABEL,0,0,0,0,0); 
            //ObjectSetInteger(ChartID(),sObjName2,OBJPROP_BACK,false);         
            //ObjectSet(sObjName2,OBJPROP_CORNER,0);//Symbol_Corner
            //ObjectSet(sObjName2,OBJPROP_XDISTANCE, x);//;(dColWidth*iCol)+dMargin1);
            //ObjectSet(sObjName2,OBJPROP_YDISTANCE, y);            
            
            
            //ObjectSetInteger(ChartID(),sObjName2,OBJPROP_COLOR,clrChocolate); 
            //int Remainder=MathMod(RowPos,2);
            
           /* 
            switch(contentType){
            case ENUM_RowContentType_Data1:
               //if(ColPos!=0){
                  switch(Remainder)
                  {
                     case 1:ObjectSetInteger(ChartID(),sObjName2,OBJPROP_BGCOLOR,clrGray);break;
                     //case 0:ObjectSetInteger(ChartID(),sObjName2,OBJPROP_BGCOLOR,clrBlack);break;
                  }
               //};
               break;
               default:
                  
                  ObjectSetInteger(ChartID(),sObjName2,OBJPROP_BGCOLOR,clrAliceBlue);
               
            }
            */
            //ObjectDelete(sObjName);
            //ObjectCreate(sObjName,OBJ_LABEL,0,0,0,0,0);
            //ObjectSet(sObjName,OBJPROP_CORNER,0);//Symbol_Corner
            //ObjectSet(sObjName,OBJPROP_XDISTANCE, x);//;(dColWidth*iCol)+dMargin1);
            //ObjectSet(sObjName,OBJPROP_YDISTANCE, y);
            //ObjectSetText(sObjName,Label,iFontSize2,sFont,colorChn);
            
      }

      void drawStandardTabular()
      {
            double Cummx=0,Cummy=0; //GV;
            //int leftmargin=200,RowHeight=15, topMargin=10;
            int iSymbolCount=0;
            string sComment,sLabel;
            
            //Row Header
            Cummx=leftmargin; 
            Cummy=topMargin;
            drawTabularCell(title,ENUM_RowContentType_TableTitle1,Cummx,Cummy,NULL,NULL);
         
            Cummy=Cummy+RowHeight;
            Cummx=leftmargin;

            //Column Header
            for(int i=0; i<colCount; i++)
            {
               drawTabularCell(colDefs[i].colHeader, ENUM_RowContentType_ColHeader1, Cummx,Cummy,i, NULL);  
               Cummx = Cummx + colDefs[i].colWidth;
               //Print(Cummx +"_"+ Cummy);
            }
            
            Cummy=Cummy+RowHeight;
            Cummx=leftmargin;

            //Data Cells
            for(int iRow=0; iRow<SymbolsTotal(true); iRow++)
            {
               sComment= SymbolName(iRow,true);
               //symbolNames[iRow]="";
               //symbolNames[iRow]=sComment;
               /*
               for(int orderpos=0; orderpos >= 0; orderpos--)
               {
                  if(OrderSelect(orderpos, SELECT_BY_POS, MODE_TRADES))
                  {
                       //symbolNames[]
                       if(OrderSymbol() == sComment)
                       {
                           //symbolOrderCnt[iRow]+=1;
                           iSymbolCount++;
                       }
                  }
               }*/
               iSymbolCount=0;
               //sLabel = (iSymbolCount>0)? sComment +"<"+(string)iSymbolCount:sComment;
               //sLabel = (Symbol()==sComment)?sLabel = "*"+sLabel:sLabel;
               sLabel=sComment;             
               drawTabularCell(sLabel, ENUM_RowContentType_RowHeader1,Cummx,Cummy,NULL, iRow);
     
               for (int iCol2 = 0 ; iCol2 <colCount;iCol2++){ 
                  
                  //sLabel = "-";
                  if(iCol2>0){
                     
                     drawTabularCell(sLabel, ENUM_RowContentType_Data1, Cummx,Cummy,iRow, iCol2);
                  };
                  
                  Cummx = Cummx + colDefs[iCol2].colWidth;    
               }

               Cummx=leftmargin;
               Cummy = Cummy+ RowHeight;
            }
            
            //objetc string 
      } 
      
      string GetDataSymbol(double x){
         
         if(x==0) return " S";
         if(x==1) return " B";
         if(x==2) return "";
         else return "-";
      }
      
      void GetWriteVWAPS()
      {
         double c2,c3,c4,c5,c6,c7,c8,c9,c10,c11; //GV;
         string c1;
         string sSQL="";
         string cellName;
         color bgColor;
         //string objName;
         StringAdd(sSQL,"select * from VWAP;");
         
         SQLiteQuery* query = db.Prepare(sSQL);
         
         if(!query)
           {
            PrintFormat("Invalid query: (%d) %s", db.ErrCode(), db.ErrMsg());
           }
         int count;
         for(count= 0; query.Next() == SQLITE_ROW; ++count)
         {
            
            c1     = query.GetString(0); //Currency
            c2     = query.GetDouble(1);
            c3     = query.GetDouble(2);
            c4     = query.GetDouble(3);
            c5     = query.GetDouble(4);
            c6     = query.GetDouble(5);
            c7     = query.GetDouble(6);
            c8     = query.GetDouble(7);
            c9     = query.GetDouble(8);
            c10    = query.GetDouble(9);
            c11    = query.GetDouble(10);
            
            //cellName=sIndiName+"_RowHed_"+c1;
            //ObjectSetText(cellName,(string)query.GetString(0),iFontSize2,sFont,clrYellow);
            //ObjectSetText("MrktObsSet12_WAP_Meter3_Data_"+c1+"_1",GetDataSymbol(query.GetDouble(1)),iFontSize2,sFont,clrSkyBlue);
            
            cellName=sIndiName+"_Data_"+c1;    
            
            
            ObjectSetText(cellName+"_1",GetDataSymbol(c10),iFontSize2,sFont,clrBlack);
             
            //bgColor=(Bid>c2)?clrDarkGreen:clrDarkRed;
           // ObjectSetInteger(ChartID(),"MrktObsSet12_WAP_Meter3_Data_1",OBJPROP_BGCOLOR,clrYellowGreen);
            
            //bgColor=(Bid>c2)?clrDarkGreen:clrDarkRed;
            //ObjectSetInteger(ChartID(),cellName+"_2",OBJPROP_BGCOLOR,bgColor);
            ObjectSetText(cellName+"_2",GetDataSymbol(c9),iFontSize2,sFont,clrBlack);
            
            //bgColor=(Bid>c3)?clrDarkGreen:clrDarkRed;
            //ObjectSetInteger(ChartID(),cellName+"_3",OBJPROP_BGCOLOR,bgColor);
            ObjectSetText(cellName+"_3",GetDataSymbol(c8),iFontSize2,sFont,clrBlack);
            
            //bgColor=(Bid>c4)?clrDarkGreen:clrDarkRed;
            //ObjectSetInteger(ChartID(),cellName+"_4",OBJPROP_BGCOLOR,bgColor);
            ObjectSetText(cellName+"_4",GetDataSymbol(c7),iFontSize2,sFont,clrBlack);
            
            //bgColor=(1>c5)?clrDarkGreen:clrDarkRed;
            //ObjectSetInteger(ChartID(),cellName+"_5",OBJPROP_BGCOLOR,bgColor);
            ObjectSetText(cellName+"_5",GetDataSymbol(c6),iFontSize2,sFont,clrBlack);
        
            //bgColor=(Bid>c6)?clrDarkGreen:clrDarkRed;
            //ObjectSetInteger(ChartID(),cellName+"_6",OBJPROP_BGCOLOR,bgColor);
            ObjectSetText(cellName+"_6",GetDataSymbol(c5),iFontSize2,sFont,clrBlack);
            
            //bgColor=(Bid>c7)?clrDarkGreen:clrDarkRed;
            //ObjectSetInteger(ChartID(),cellName+"_7",OBJPROP_BGCOLOR,bgColor);
            ObjectSetText(cellName+"_7",GetDataSymbol(c4),iFontSize2,sFont,clrBlack);
            
            //bgColor=(Bid>c8)?clrDarkGreen:clrDarkRed;
            //ObjectSetInteger(ChartID(),cellName+"_8",OBJPROP_BGCOLOR,bgColor);
            ObjectSetText(cellName+"_8",GetDataSymbol(c3),iFontSize2,sFont,clrBlack);
            
            ObjectSetText(cellName+"_9",GetDataSymbol(c2),iFontSize2,sFont,clrBlack);
             
            //ObjectSetText(cellName+"_10",GetDataSymbol(c10),iFontSize2,sFont,clrSkyBlue);           
            //Print(c1);
            /*    
            c1     = query.GetDouble(0);
            c2     = query.GetDouble(1);
            c3     = query.GetDouble(2);
            c4     = query.GetDouble(3);
            c5     = query.GetDouble(4);
            c6     = query.GetDouble(5);
            c7     = query.GetDouble(6);
            c8     = query.GetDouble(7);
            c8     = query.GetDouble(8);
            c9     = query.GetDouble(9);
            

            //rslt.Add(Row);
            //c1 always 0 at weekends
            //Print(c1+":"+c2+":"+c3+":"+c4+":"+c5+":"+c6+":"+c7+":"+c8);
            */
         }
         //Print("COUNT:"+count);
         delete query; 
         
         //return rslt;
      }
      
      
      void GetWrite_CVS_VWAPS(){
         string sObjNameSuffix="", symbol="";
         int handle,size;
         for(int row=0; row<SymbolsTotal(true); row++){
            for(int col=1; col <colCount;col++){
               //MrktObsSet12_WAP_MeterV4_00_Data_AUDCAD_2
               //cellName="MrktObsSet12_WAP_Meter3_Data_"+c1; 
               symbol=SymbolName(row,true);
               sObjNameSuffix = "MrkObsSet12_VWAPCollectToFile_"+symbol+"_"+ (string)col+".csv";
               
               handle=FileOpen(sObjNameSuffix,FILE_READ);
               if(handle!=0)
               {
                  size = (int)FileSize(handle);
                  string str = FileReadString(handle,size);
                  Print(sObjNameSuffix+":"+ str);   
                  FileClose(handle);
                  
               }
               else{
               }
            }  
         }
      }
};


//CBasicSelectTable DisplatTable;

int init()
{
   db.Open(sDBPath,iFlags);
   if(!db.IsOpen())
     {
      Alert(StringFormat("Cannot open database %s: %s", sDBPath, db.ErrMsg()));
      return 1;
     }
   
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0);
   IndiGlobalIsLoaded(true);
   CleanChart(sIndiName);
   
   
   //DRAW TABLE
   string sTableTitle="'Ere";
   double dTableMargin3=10;
   /*
   string sql="select "+
              " a.symbol, ifnull(max(a.vwap), 1)as vwap_43200, "+
              " b.vwap as VWAP_10080,"+
              " c.vwap as VWAP_1440,"+
              " d.vwap as VWAP_240 ,  "+
              " e.vwap as VWAP_60,"+
              " f.vwap as VWAP_30,"+
              " g.vwap as VWAP_15,"+
              " h.vwap as VWAP_5,"+
              " i.vwap as VWAP_1"+
              " from  VWAP_1         a "+
              " left outer join VWAP_5   b on a.Symbol=b.symbol"+
              " left outer join VWAP_15   c on a.Symbol=c.symbol"+
              " left outer join VWAP_30    d on a.Symbol=d.symbol"+
              " left outer join VWAP_60     e on a.Symbol=e.symbol"+
              " left outer join VWAP_240     f on a.Symbol=f.symbol "+
              " left outer join VWAP_1440  g on a.Symbol=g.symbol "+
              " left outer join VWAP_10080     h on a.Symbol=h.symbol"+
              " left outer join vwap_43200     i on a.Symbol=i.symbol";
   */
   
   string sql="select * from VWAP";
   
   TableColDefs *colDef_pointers[10];
   //QryRsltColNm *rsltCols[1];
   
   colDef_pointers[0]=new TableColDefs("Symbol" ,""   ,""    ,70,ENUM_RowContentType_ColHeader1);
   colDef_pointers[1]=new TableColDefs("1M"      ,""   ,"X"   ,17,ENUM_RowContentType_ColHeader1);
   colDef_pointers[2]=new TableColDefs("1W"      ,""   ,"X"   ,17,ENUM_RowContentType_ColHeader1);
   colDef_pointers[3]=new TableColDefs("1D"      ,""   ,"X"   ,17,ENUM_RowContentType_ColHeader1);
   colDef_pointers[4]=new TableColDefs("4H"      ,""   ,"X"   ,17,ENUM_RowContentType_ColHeader1);
   colDef_pointers[5]=new TableColDefs("1H"      ,""   ,"X"   ,17,ENUM_RowContentType_ColHeader1);
   colDef_pointers[6]=new TableColDefs("30"      ,""   ,"X"   ,17,ENUM_RowContentType_ColHeader1);
   colDef_pointers[7]=new TableColDefs("15"      ,""   ,"X"   ,17,ENUM_RowContentType_ColHeader1);
   colDef_pointers[8]=new TableColDefs("05"      ,""   ,"X"   ,17,ENUM_RowContentType_ColHeader1);
   colDef_pointers[9]=new TableColDefs("01"      ,""   ,"X"   ,17,ENUM_RowContentType_ColHeader1);
   //string CellNames[];
   
   //Pointer to object https://www.mql5.com/en/forum/326664
   CBasicSelectTable *DisplayVWAPTable = new  CBasicSelectTable(sTableTitle,dTableMargin3,sql, colDef_pointers);   
   
   DisplayVWAPTable.drawStandardTabular();
   //DisplayVWAPTable.GetWriteVWAPS();

   for(int i=0;i<ArraySize(colDef_pointers);i++)
   {
      if(CheckPointer(colDef_pointers[i])!=POINTER_INVALID)
      {
         if(CheckPointer(colDef_pointers[i])==POINTER_DYNAMIC) delete(colDef_pointers[i]);
      }
   } 
   
   delete(DisplayVWAPTable);
   
   
   
   EventSetTimer(3);   

   return(0);
}

void OnTimer(){

   if(!StopWritingVWAPS){
      CBasicSelectTable *DisplayVWAPTable = new  CBasicSelectTable();   
      //DisplayVWAPTable.drawStandardTabular();
      DisplayVWAPTable.GetWriteVWAPS();
   }
  
}



int deinit()
  {
   IndiGlobalIsLoaded(false);
   CleanChart(sIndiName);
   IndiGlobalRemoveVarByString(sIndiName);
   return(0);
  }


int start()
  {

   return(0);

  }

void OnChartEvent(const int id,         // Event identifier  Event
                  const long& lparam,   // Event parameter of long type X
                  const double& dparam, // Event parameter of double type Y
                  const string& sparam) // Event parameter of string type  Name of the graphical object, on which the event occurred
{

   string sObjName,DoChartName;
   string Curr;
   string ChartNamePrefix="MrktObsSet12_WAP_Meter3_RowHed_";
   string OtherChartsIDSuffix="_TF";
   string NameParts[]; //Obs Set|Indi|ContentType|Symbol
   long Chartid;
   int tf;
   
   switch (id){
   case CHARTEVENT_OBJECT_CLICK :
      StopWritingVWAPS=true; 
      
      sObjName=ObjectGetString(0,sparam,OBJPROP_NAME,0);
      //Print(sObjName);
      StringSplit(sObjName,'_',NameParts);
      ///Print(NameParts[4]);
      
      
      if(NameParts[4]== "RowHed"||NameParts[4]== "Data")
      {       
         //Print("here");
         for(int i=0;i<=GlobalVariablesTotal(); i++){
            if(StringFind(GlobalVariableName(i),OtherChartsIDSuffix,0)!=-1){
               //Print("GV Name=" +GlobalVariableName(i));
               
               DoChartName=StringSubstr(GlobalVariableName(i),0,StringLen(GlobalVariableName(i))-3);
               Chartid=(long)DoChartName;
               
               tf=ChartPeriod(Chartid);
               ChartSetSymbolPeriod(Chartid,NameParts[5],tf);      
            }
            
         } 
         ChartSetSymbolPeriod(0,Curr, Period()); 
         
      }
      StopWritingVWAPS=false;
   }
}

