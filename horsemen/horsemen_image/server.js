/**
 * horsemen/horsemen_image/app.js
 */

const express = require('express');
const cors = require('cors');
const api = require("@actual-app/api");
const ACTUAL_PASSWORD = process.env.ACTUAL_PASSWORD;
const ACTUAL_BUDGET = process.env.ACTUAL_BUDGET;

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
app.get('/balance-sheet', async (req, res) => {
    await api.init({
        serverURL: "http://actual_container:5006",
        password: ACTUAL_PASSWORD
    });

    await api.downloadBudget(ACTUAL_BUDGET, {
        password: ACTUAL_PASSWORD
    });

    const budget = await api.getAccounts();
    const today = new Date();
    let assets = {};
    let liabilities = {};
    budget.forEach(async (account) => {
        const balance = await api.getAccountBalance(account.id, today);
        if (0 <= balance) {
            assets[account.name] = 1e-2 * balance;
        } else {
            liabilities[account.name] = -1e-2 * balance;
        }
    });

    const balanceSheetData = {
        "datetime": today.toISOString(),
        "assets": assets,
        "liabilities": liabilities
    };

    await api.shutdown();
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