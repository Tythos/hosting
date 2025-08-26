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

app.get("/months", async (req, res) => {
    await api.init({
        serverURL: "http://actual_container:5006",
        password: ACTUAL_PASSWORD
    });
    await api.downloadBudget(ACTUAL_BUDGET, {
        password: ACTUAL_PASSWORD
    });
    const budget_months = await api.getBudgetMonths();
    const months = budget_months.map((m) => {
        const parts = m.split("-");
        return {
            "identifier": m,
            "year": parseInt(parts[0]),
            "month": parseInt(parts[1])
        };
    });
    await api.shutdown();
    res.json(months);
});

app.get("/months/:identifier/budget", async (req, res) => {
    const identifier = req.params.identifier;
    await api.init({
        serverURL: "http://actual_container:5006",
        password: ACTUAL_PASSWORD
    });
    await api.downloadBudget(ACTUAL_BUDGET, {
        password: ACTUAL_PASSWORD
    });
    const budget_month = await api.getBudgetMonth(identifier);
    const budget = budget_month.categoryGroups.map(cg => {
        return {
            "category": cg.name,
            "is_income": cg.is_income,
            "line_items": cg.categories.map(c => {
                return {
                    "name": c.name,
                    "is_income": c.is_income,
                    "amount_budgeted": c.budgeted,
                    "amount_spent": c.spent
                };
            })
        };
    });
    await api.shutdown();
    res.json(budget);
});

app.get("/months/:identifier/transactions", async (req, res) => {
    const identifier = req.params.identifier;
    await api.init({
        serverURL: "http://actual_container:5006",
        password: ACTUAL_PASSWORD
    });
    await api.downloadBudget(ACTUAL_BUDGET, {
        password: ACTUAL_PASSWORD
    });
    let transactions = [];
    const accounts = await api.getAccounts();
    const [year, month] = identifier.split("-").map(x => +x);
    const payees = await api.getPayees();
    const payee_uuids = payees.map(p => p.id);
    const budget_month = await api.getBudgetMonth(identifier);
    const categories = budget_month.categoryGroups.flatMap(cg => cg.categories);
    const category_uuids = categories.map(c => c.id);
    for (let i = 0; i < accounts.length; i += 1) {
        const trans = await api.getTransactions(
            accounts[i].id,
            new Date(year, month - 1, 1),
            new Date(year, month, 0)
        );
        transactions.push(...trans.map(t => {
            const j = payee_uuids.indexOf(t.payee);
            const k = category_uuids.indexOf(t.category);
            return {
                "account": accounts[i].name,
                "payee": j < 0 ? null : payees[j].name,
                "category": k < 0 ? null : categories[k].name,
                "is_transfer": t.hasOwnProperty("transfer_id") && t.transfer_id != null ? true : false,
                "amount": 1e-2 * t.amount
            };
        }));
    }
    await api.shutdown();
    res.json(transactions);
});

app.get("/accounts", async (req, res) => {
    await api.init({
        serverURL: "http://actual_container:5006",
        password: ACTUAL_PASSWORD
    });
    await api.downloadBudget(ACTUAL_BUDGET, {
        password: ACTUAL_PASSWORD
    });
    const accounts = await api.getAccounts();
    let account_summaries = [];
    for (let i = 0; i < accounts.length; i += 1) {
        const balance = await api.getAccountBalance(accounts[i].id);
        account_summaries.push({
            "name": accounts[i].name,
            "balance": 1e-2 * balance,
            "is_off_budget": accounts[i].offbudget
        });
    }
    await api.shutdown();
    res.json(account_summaries);
});

app.get("/categories", async (req, res) => {
    await api.init({
        serverURL: "http://actual_container:5006",
        password: ACTUAL_PASSWORD
    });
    await api.downloadBudget(ACTUAL_BUDGET, {
        password: ACTUAL_PASSWORD
    });
    const cgs = await api.getCategoryGroups();
    let categories = [];
    for (let i = 0; i < cgs.length; i += 1) {
        categories.push({
            "group_name": cgs[i].name,
            "is_income_group": cgs[i].is_income,
            "categories": cgs[i].categories.map(c => {
                return {
                    "category_name": c.name,
                    "is_income_category": c.is_income
                };
            })
        });
    }
    await api.shutdown();
    res.json(categories);
});

app.get("/payees", async (req, res) => {
    await api.init({
        serverURL: "http://actual_container:5006",
        password: ACTUAL_PASSWORD
    });
    await api.downloadBudget(ACTUAL_BUDGET, {
        password: ACTUAL_PASSWORD
    });
    const categories = await api.getCategories();
    const category_uuids = categories.map(c => c.id);
    const payees = await api.getPayees();
    let payee_summaries = [];
    for (let i = 0; i < payees.length; i += 1) {
        const j = category_uuids.indexOf(payees[i].category);
        payee_summaries.push({
            "name": payees[i].name,
            "category_name": j < 0 ? null : categories[j].name,
            "is_transfer": payees[i].hasOwnProperty("transfer_acct") && payees[i].transfer_acct != null ? true : false
        });
    }
    await api.shutdown();
    res.json(payee_summaries);
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
