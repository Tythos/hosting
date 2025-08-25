/**
 * horsemen/horsemen_image/server.js
 */

const express = require("express");
const cors = require("cors");
const api = require("@actual-app/api");

const ACTUAL_PASSWORD = process.env.ACTUAL_PASSWORD;
const ACTUAL_BUDGET = process.env.ACTUAL_BUDGET;
const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

app.get("/health", (req, res) => {
    res.json({ status: "healthy", timestamp: new Date().toISOString() });
});

app.get("/balance-sheet", async (req, res) => {
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
    let net_worth = 0;

    for (const account of budget) {
        const balance = await api.getAccountBalance(account.id, today);
        if (0 <= balance) {
            assets[account.name] = 1e-2 * balance;
        } else {
            liabilities[account.name] = -1e-2 * balance;
        }
        net_worth += 1e-2 * balance;
    }

    const balanceSheetData = {
        "datetime": today.toISOString(),
        "assets": assets,
        "liabilities": liabilities,
        "net_worth": net_worth
    };

    await api.shutdown();
    res.json(balanceSheetData);
});

app.get("/income-statement", async (req, res) => {
    if (!req.query.start_date) {
        res.status(400).json({ error: "start_date is required" });
        return;
    }
    if (!req.query.end_date) {
        res.status(400).json({ error: "end_date is required" });
        return;
    }
    const start_date = new Date(req.query.start_date); // assume ISO?
    const end_date = new Date(req.query.end_date);

    await api.init({
        serverURL: "http://actual_container:5006",
        password: ACTUAL_PASSWORD
    });

    await api.downloadBudget(ACTUAL_BUDGET, {
        password: ACTUAL_PASSWORD
    });

    const accounts = await api.getAccounts();
    const account_uuids = accounts.map((a) => a.id);
    const payees = await api.getPayees();
    const payee_uuids = payees.map((p) => p.id);
    const income_statement = [];

    // for each account, get transactions in the given window
    for (let i = 0; i < accounts.length; i += 1) {
        if (accounts[i].offbudget) { continue; } // only on-budget accounts can receive income
        const trans = await api.getTransactions(
            accounts[i].id,
            start_date,
            end_date
        );
        const income = trans.filter((t) => {
            // we consider a transaction "income" if it is positive (account increases), and either no payee or a payee that isn't a transfer
            const j = payee_uuids.indexOf(t.payee);
            if (t.amount >= 0 && j == -1) { return true; }
            const payee = payees[j];
            if (t.amount >= 0 && !account_uuids.includes(payee.transfer_acct)) { return true; }
            return false;
        });
        income.forEach((t) => {
            const j = payee_uuids.indexOf(t.payee);
            income_statement.push({
                "deposit": t.amount * 1e-2,
                "date": t.date,
                "into_account_id": accounts[i].id,
                "into_account_name": accounts[i].name,
                "from_payee_id": j < 0 ? null : payees[j].id,
                "from_payee_name": j < 0 ? null : payees[j].name
            });
        });
    }
    await api.shutdown();
    res.json(income_statement);
});

app.get("/", (req, res) => {
    res.json({
        message: "Financial Data API",
        endpoints: [
            "GET /health - Health check",
            "GET /api/balance-sheet - Balance sheet data"
        ]
    });
});

app.listen(PORT, "0.0.0.0", () => {
    console.log(`Financial Data API server running on port ${PORT}`);
    console.log(`Health check: http://localhost:${PORT}/health`);
    console.log(`Balance Sheet: http://localhost:${PORT}/api/balance-sheet`);
});
