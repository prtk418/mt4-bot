// Define indicator inputs
input int ATRPeriod = 10; // Average True Range Period
input double Multiplier = 3.0; // Multiplier for the ATR value to define the Supertrend
input int ATRPeriodX = 10; // Average True Range Period
input double MultiplierX = 3.0; // Multiplier for the ATR value to define the Supertrend


// Global variables for storing the current and previous SuperTrend states

// Buffers for Heiken Ashi values
double haOpen[];
double haClose[];
double haHigh[];
double haLow[];
double haOpenX[];
double haCloseX[];
double haHighX[];
double haLowX[];

// Buffers for Supertrend
double upperBand[];
double lowerBand[];
double trend[];
double upperBandX[];
double lowerBandX[];
double trendX[];

double lastTrend = 0;
double lastTrendX = 0;

// Indicator buffers setup
enum {UPPER_BAND, LOWER_BAND, TREND};
enum {UPPER_BANDX, LOWER_BANDX, TRENDX};

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(6);
   SetIndexBuffer(UPPER_BAND, upperBand, INDICATOR_DATA);
   SetIndexBuffer(LOWER_BAND, lowerBand, INDICATOR_DATA);
   SetIndexBuffer(TREND, trend, INDICATOR_DATA);
   SetIndexBuffer(UPPER_BANDX, upperBandX, INDICATOR_DATA);
   SetIndexBuffer(LOWER_BANDX, lowerBandX, INDICATOR_DATA);
   SetIndexBuffer(TRENDX, trendX, INDICATOR_DATA);
  
   ArraySetAsSeries(haOpen, true);
   ArraySetAsSeries(haClose, true);
   ArraySetAsSeries(haHigh, true);
   ArraySetAsSeries(haLow, true);
   ArraySetAsSeries(haOpenX, true);
   ArraySetAsSeries(haCloseX, true);
   ArraySetAsSeries(haHighX, true);
   ArraySetAsSeries(haLowX, true);
  
   return(INIT_SUCCEEDED);
   
  }


void CalculateHeikenAshi()
  {
   int totalBars = iBars(NULL, PERIOD_H1); //H1 means 1 hour
   for(int i = 0; i < totalBars; i++)
     {
      double open = iOpen(NULL, PERIOD_H1, i);
      double close = iClose(NULL, PERIOD_H1, i);
      double high = iHigh(NULL, PERIOD_H1, i);
      double low = iLow(NULL, PERIOD_H1, i);
      
      if(i == 0)
        {
         haOpen[i] = (open + close) / 2.0;
         haClose[i] = (open + high + low + close) / 4.0;
         haHigh[i] = high;
         haLow[i] = low;
        }
      else
        {
         haOpen[i] = (haOpen[i-1] + haClose[i-1]) / 2.0;
         haClose[i] = (open + high + low + close) / 4.0;
         haHigh[i] = MathMax(high, MathMax(haOpen[i], haClose[i]));
         haLow[i] = MathMin(low, MathMin(haOpen[i], haClose[i]));
        }
     }
  }

void CalculateHeikenAshiX()
  {
   int totalBars = iBars(NULL, PERIOD_H4); // H4 means 4 hours 
   for(int i = 0; i < totalBars; i++)
     {
      double open = iOpen(NULL, PERIOD_H1, i);
      double close = iClose(NULL, PERIOD_H1, i);
      double high = iHigh(NULL, PERIOD_H1, i);
      double low = iLow(NULL, PERIOD_H1, i);
      
      if(i == 0)
        {
         haOpenX[i] = (open + close) / 2.0;
         haCloseX[i] = (open + high + low + close) / 4.0;
         haHighX[i] = high;
         haLowX[i] = low;
        }
      else
        {
         haOpenX[i] = (haOpenX[i-1] + haCloseX[i-1]) / 2.0;
         haCloseX[i] = (open + high + low + close) / 4.0;
         haHighX[i] = MathMax(high, MathMax(haOpenX[i], haCloseX[i]));
         haLowX[i] = MathMin(low, MathMin(haOpenX[i], haCloseX[i]));
        }
     }
  }



//+------------------------------------------------------------------+
//| Supertrend Calculation for H1 timeframe                          |
//+------------------------------------------------------------------+
void CalculateSupertrend()
  {
   int totalBars = iBars(NULL, PERIOD_H1);
   for(int i = 0; i < totalBars; i++)
     {
      double atr = iATR(NULL, PERIOD_H1, ATRPeriod, i);

      // Example calculation logic for upper and lower bands
      // This is simplified and needs to be adapted based on the Supertrend formula
      upperBand[i] = (haHigh[i] + haLow[i]) / 2 + (Multiplier * atr);
      lowerBand[i] = (haHigh[i] + haLow[i]) / 2 - (Multiplier * atr);

      // Determine trend
      if(i == 0)
         trend[i] = 0; // Assuming no trend at the start
      else
        {
         if(close > upperBand[i-1])
            trend[i] = 1; // Uptrend
         else if(close < lowerBand[i-1])
            trend[i] = -1; // Downtrend
         else
            trend[i] = trend[i-1]; // No change
        }
     }
  }

  //+------------------------------------------------------------------+
  //| Supertrend Calculation for H4 timeframe                          |
  //+------------------------------------------------------------------+
  void CalculateSupertrendX()
    {
     int totalBars = iBars(NULL, PERIOD_H4);
     for(int i = 0; i < totalBars; i++)
       {
        double atr = iATR(NULL, PERIOD_H4, ATRPeriodX, i);

        // Example calculation logic for upper and lower bands
        // This is simplified and needs to be adapted based on the Supertrend formula
        upperBandX[i] = (haHighX[i] + haLowX[i]) / 2 + (Multiplier * atr);
        lowerBandX[i] = (haHighX[i] + haLowX[i]) / 2 - (Multiplier * atr);

        // Determine trend
        if(i == 0)
           trendX[i] = 0; // Assuming no trend at the start
        else
          {
           if(close > upperBandX[i-1])
              trendX[i] = 1; // Uptrend
           else if(close < lowerBandX[i-1])
              trendX[i] = -1; // Downtrend
           else
              trendX[i] = trendX[i-1]; // No change
          }
       }
    }
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Calculate the Supertrend & SupertrendX for the latest data
    
    CalculateHeikenAshi();
    CalculateHeikenAshiX();
    CalculateSupertrend();
    CalculateSupertrendX();

    // Check for trend changes to decide on trading actions
    if(trend == 1 && lastTrend <= 0)
    {
        CloseSellPositions();
        OpenBuyOrder();
    }
    else if(trend == -1 && lastTrend >= 0)
    {
        CloseBuyPositions();
        OpenSellOrder();
    }
    
    if(trendX == 1 && lastTrendX <= 0)
    
    {
        CloseSellPositions();
    }
    
    else if(trendX == -1 && lastTrendX >= 0)
    
    {    
        CloseBuyPositions();
      
    }
    
    lastTrend = trend; // Update last trend after actions
    lastTrendX = trendX; // Update last trend after actions
}

//+------------------------------------------------------------------+
//| OpenBuyOrder function                                            |
//+------------------------------------------------------------------+
void OpenBuyOrder()
{
    if(OrderSelect(0, SELECT_BY_POS) && OrderType() == OP_BUY)
        return; // Already have a buy order

    int ticket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, 2, 0, 0, "Supertrend Buy", 0, 0, clrGreen);
    if(ticket < 0)
        Print("Error opening BUY order: ", GetLastError());
    else
        Print("BUY order opened: ", ticket);
}

//+------------------------------------------------------------------+
//| OpenSellOrder function                                           |
//+------------------------------------------------------------------+
void OpenSellOrder()
{
    if(OrderSelect(0, SELECT_BY_POS) && OrderType() == OP_SELL)
        return; // Already have a sell order

    int ticket = OrderSend(Symbol(), OP_SELL, LotSize, Bid, 2, 0, 0, "Supertrend Sell", 0, 0, clrRed);
    if(ticket < 0)
        Print("Error opening SELL order: ", GetLastError());
    else
        Print("SELL order opened: ", ticket);
}

//+------------------------------------------------------------------+
//| CloseBuyPositions function                                       |
//+------------------------------------------------------------------+
void CloseBuyPositions()
{
    for(int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol() && OrderType() == OP_BUY)
        {
            // Close buy order
            if(!OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrNONE))
                Print("Error closing BUY order: ", GetLastError());
        }
    }
}

//+------------------------------------------------------------------+
//| CloseSellPositions function                                      |
//+------------------------------------------------------------------+
void CloseSellPositions()
{
    for(int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol() && OrderType() == OP_SELL)
        {
            // Close sell order
            if(!OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrNONE))
                Print("Error closing SELL order: ", GetLastError());
        }
    }
}

// Additional functions for your trading logic

// OnDeinit function to clean up
void OnDeinit(const int reason) {
   // Cleanup code here
}
