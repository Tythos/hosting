/**
 * horsemen/horsemen_image/app.js
 */

const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3001;

// Enable CORS for Grafana integration
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Balance Sheet endpoint with static test data
app.get('/api/balance-sheet', (req, res) => {
  const balanceSheetData = {
    "data": [
      {
        "account_type": "Assets",
        "category": "Cash & Cash Equivalents", 
        "account_name": "Checking Account",
        "balance": 5000.00,
        "timestamp": new Date().toISOString()
      },
      {
        "account_type": "Assets",
        "category": "Cash & Cash Equivalents",
        "account_name": "Savings Account",
        "balance": 15000.00,
        "timestamp": new Date().toISOString()
      },
      {
        "account_type": "Assets",
        "category": "Investments",
        "account_name": "Brokerage Account", 
        "balance": 25000.00,
        "timestamp": new Date().toISOString()
      },
      {
        "account_type": "Assets",
        "category": "Fixed Assets",
        "account_name": "Home Value",
        "balance": 350000.00,
        "timestamp": new Date().toISOString()
      },
      {
        "account_type": "Liabilities",
        "category": "Credit Cards",
        "account_name": "Chase Visa",
        "balance": -2500.00,
        "timestamp": new Date().toISOString()
      },
      {
        "account_type": "Liabilities",
        "category": "Loans",
        "account_name": "Mortgage",
        "balance": -275000.00,
        "timestamp": new Date().toISOString()
      },
      {
        "account_type": "Liabilities",
        "category": "Loans",
        "account_name": "Car Loan",
        "balance": -18000.00,
        "timestamp": new Date().toISOString()
      }
    ]
  };

  res.json(balanceSheetData);
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'Financial Data API',
    endpoints: [
      'GET /health - Health check',
      'GET /api/balance-sheet - Balance sheet data'
    ]
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Financial Data API server running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
  console.log(`Balance Sheet: http://localhost:${PORT}/api/balance-sheet`);
});