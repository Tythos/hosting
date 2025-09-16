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

// API connection state management
let apiInitialized = false;
let apiShutdownInProgress = false;

// Helper function to ensure API is properly initialized
async function ensureApiInitialized() {
    if (apiInitialized && !apiShutdownInProgress) {
        return;
    }

    try {
        // Force shutdown if in progress
        if (apiShutdownInProgress) {
            await api.shutdown().catch(() => { });
            apiShutdownInProgress = false;
        }

        await api.init({
            serverURL: "http://actual_container:5006",
            password: ACTUAL_PASSWORD
        });

        await api.downloadBudget(ACTUAL_BUDGET, {
            password: ACTUAL_PASSWORD
        });

        apiInitialized = true;
    } catch (error) {
        console.error("Failed to initialize API:", error);
        apiInitialized = false;
        throw error;
    }
}

// Helper function to safely shutdown API
async function safeApiShutdown() {
    if (!apiInitialized || apiShutdownInProgress) {
        return;
    }

    try {
        apiShutdownInProgress = true;
        await api.shutdown();
    } catch (error) {
        console.error("Error during API shutdown:", error);
    } finally {
        apiInitialized = false;
        apiShutdownInProgress = false;
    }
}

/* --- these are private / non-exported functions and assume the api has been initialized but not yet shut down--- */
const getAllAccounts = async () => {
    // await ensureApiInitialized();
    const accounts = await api.getAccounts();
    // await safeApiShutdown();
    return Array.from(accounts);
};

const getAllTransactions = async (start_date, end_date) => {
    // maybe we do budgeted only?
    // await ensureApiInitialized();
    const accounts = await getAllAccounts();
    let transactions = [];
    for (let i = 0; i < accounts.length; i += 1) {
        transactions = [...transactions, ...await api.getTransactions(accounts[i].id, start_date, end_date)];
    }
    // await safeApiShutdown();
    return Array.from(transactions);
};

const getAllCategories = async () => {
    // await ensureApiInitialized();
    const categories = await api.getCategories();
    // await safeApiShutdown();
    return Array.from(categories);
};

app.use(cors());
app.use(express.json());

app.get("/health", (req, res) => {
    res.json({ status: "healthy", timestamp: new Date().toISOString() });
});

app.get("/months", async (req, res) => {
    try {
        await ensureApiInitialized();
        const budget_months = await api.getBudgetMonths();
        const months = budget_months.map((m) => {
            const parts = m.split("-");
            return {
                "identifier": m,
                "year": parseInt(parts[0]),
                "month": parseInt(parts[1])
            };
        });
        res.json(months);
    } catch (error) {
        console.error("Error in /months endpoint:", error);
        res.status(500).json({ error: "Failed to fetch months data" });
    }
});

app.get("/months/:identifier/budget", async (req, res) => {
    try {
        const identifier = req.params.identifier;
        await ensureApiInitialized();
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
        res.json(budget);
    } catch (error) {
        console.error("Error in /months/:identifier/budget endpoint:", error);
        res.status(500).json({ error: "Failed to fetch budget data" });
    }
});

app.get("/months/:identifier/transactions", async (req, res) => {
    try {
        const identifier = req.params.identifier;
        await ensureApiInitialized();
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
        res.json(transactions);
    } catch (error) {
        console.error("Error in /months/:identifier/transactions endpoint:", error);
        res.status(500).json({ error: "Failed to fetch transactions data" });
    }
});

/**
 * Retrieves details of the specific category in a group for the given month.
 * Objective here is to drive a "glideslope" presentation in Grafana within
 * which the average rate of a category consumption over the course of a month
 * is compared against the actual rate of expenditure from related
 * transactions. The category name and budgeted amount are returned, as well as
 * a datetime-amount time series built from this particular month's transaction
 * data across all accounts.
 * 
 * Note that we distinguish between a "category" glideslope and a "group"
 * glideslope, which aggregates identical data for all budgets and transactions
 * in a given set of categories (e.g., "5000 - Housing Expenses").
 * 
 * The getBudgetMonth() returns a Promise<Budget>, within which there is a
 * categoryGroups array. Each CategoryGroup object in that array will have a
 * categories list, within which each specific item will include "budgeted",
 * "spent", and "balance" properties. We are mainly interested in `budgeted`
 * since we will compute our own running total.
 */
app.get("/glideslope/:identifier/category/:category_uuid", async (req, res) => {
    try {
        const identifier = req.params.identifier;
        const category_uuid = req.params.category_uuid;
        await ensureApiInitialized();
        const [year, month] = identifier.split("-").map(x => +x);
        const accounts = await api.getAccounts();
        const budget_month = await api.getBudgetMonth(identifier);
        const categories = budget_month.categoryGroups.flatMap(cg => cg.categories);
        const category = categories.find(c => c.id === category_uuid);
        if (!category) {
            res.status(404).json({ error: "Category not found" });
            return;
        }
        if (category.is_income) {
            res.status(400).json({ error: "Category is income (glideslope only supported for expenses)" });
            return;
        }

        // recommended category test: "5210 - Groceries"
        const bom = new Date(year, month - 1, 1);
        const eom = new Date(year, month, 0);
        let glideslope = {
            "category_name": category.name,
            "budgeted_amount": category.budgeted * 1e-2,
            "last_time_pct": 0.0, // facilitates date progression through month
            "underspending_pct": 0.0, // will calculate once actual glideslope has been accumulated
            "glideslope_series": [],
        };
        const budgeted_glideslope = [
            [bom, category.budgeted * 1e-2],
            [eom, 0.0]
        ];

        // now we must iterate over all transactions, which must be done on an account-by-account basis
        let actual_glideslope = []; // unsorted [datetime, cumulative, change]
        for (let i = 0; i < accounts.length; i += 1) {
            const transactions = await api.getTransactions(
                accounts[i].id,
                bom,
                eom
            );
            for (let j = 0; j < transactions.length; j += 1) {
                const t = transactions[j];
                if (t.category !== category_uuid) { continue; }
                if (!t.hasOwnProperty("amount")) { continue; }
                actual_glideslope.push([new Date(t.date), 0, 1e-2 * t.amount]);
            }
        }
        actual_glideslope.sort((a, b) => a[0].valueOf() - b[0].valueOf());

        // now that it is chronological, extend "actual glideslope" with cumulative (after transaction) amount
        let running_total = glideslope.budgeted_amount;
        for (let i = 0; i < actual_glideslope.length; i += 1) {
            running_total += actual_glideslope[i][2];
            actual_glideslope[i][1] = running_total;
        }
        glideslope["last_time_pct"] = (actual_glideslope[actual_glideslope.length - 1][0].valueOf() - bom.valueOf()) / (eom.valueOf() - bom.valueOf());

        // resample both series to a common grid
        const n_days = parseInt((new Date(year, month, 0) - new Date(year, month - 1, 1)) * 1e-3 / 86400) + 1;
        let i0 = 0; // index of first "actual" point after the current day
        for (let d = 1; d <= n_days; d += 1) {
            const pct = (d - 1) / (n_days - 1);

            // budgeted glideslope is linear decrease
            let budgeted = budgeted_glideslope[0][1] * (1 - pct);
            let actual = budgeted;

            // advance to first "actual" point after the current day
            while (i0 < actual_glideslope.length && actual_glideslope[i0][0].valueOf() < new Date(year, month - 1, d + 1).valueOf()) {
                i0 += 1;
            }
            if (d == 1) {
                // if there were no transactions on the first day, use initial budget
                if (i0 == 0) {
                    actual = budgeted_glideslope[0][1];
                } else {
                    actual = actual_glideslope[i0 - 1][1];
                }
            } else {
                // if there were no transactions on this day, use the most recent point
                actual = actual_glideslope[i0 - 1][1];
            }
            glideslope["glideslope_series"].push([new Date(year, month - 1, d), budgeted, actual]);
        }

        // finally, compute underspending percentage from last data point
        const last = glideslope["glideslope_series"][glideslope["glideslope_series"].length - 1];
        glideslope["underspending_pct"] = last[1] / budgeted_amount;

        res.json(glideslope);
    } catch (error) {
        console.error("Error in /months/:identifier/budget/:category endpoint:", error);
        res.status(500).json({ error: "Failed to fetch category budget details data" });
    }
});

/**
 * Like category glideslope, but for a group of categories.
 */
app.get("/glideslope/:identifier/group/:group_uuid", async (req, res) => {
    try {
        const identifier = req.params.identifier;
        const group_uuid = req.params.group_uuid;
        await ensureApiInitialized();
        const [year, month] = identifier.split("-").map(x => +x);
        const accounts = await api.getAccounts();
        const budget_month = await api.getBudgetMonth(identifier);
        const budget_groups = budget_month.categoryGroups;
        const group = budget_groups.find(g => g.id === group_uuid);
        if (!group) {
            res.status(404).json({ error: "Group not found" });
            return;
        }
        if (group.is_income) {
            res.status(400).json({ error: "Group is income (glideslope only supported for expenses)" });
            return;
        }

        // Group requires aggregated calculation of budgeted amount
        let budgeted_amount = 0;
        for (let i = 0; i < group.categories.length; i += 1) {
            budgeted_amount += group.categories[i].budgeted * 1e-2;
        }

        // recommended group test: "5200 - Food and Dining"
        const bom = new Date(year, month - 1, 1);
        const eom = new Date(year, month, 0);
        let glideslope = {
            "group_name": group.name,
            "budgeted_amount": budgeted_amount,
            "last_time_pct": 0.0, // facilitates date progression through month
            "underspending_pct": 0.0, // will calculate once actual glideslope has been accumulated
            "glideslope_series": [],
        };
        const budgeted_glideslope = [
            [bom, budgeted_amount],
            [eom, 0.0]
        ];

        // we must aggreegate a mapping of catgories to their group--or, a list of all catgories in the target group
        const groups = await api.getCategoryGroups();
        const group_uuids = groups.map(g => g.id);
        const i = group_uuids.indexOf(group_uuid);
        if (i == -1) {
            res.status(404).json({ error: "Group not found" });
            return;
        }
        const category_uuids = group.categories.map(c => c.id);

        // now we must iterate over all transactions, which must be done on an account-by-account basis
        let actual_glideslope = []; // unsorted [datetime, cumulative, change]
        for (let i = 0; i < accounts.length; i += 1) {
            const transactions = await api.getTransactions(
                accounts[i].id,
                bom,
                eom
            );
            for (let j = 0; j < transactions.length; j += 1) {
                const t = transactions[j];
                if (category_uuids.indexOf(t.category) < 0) { continue; }
                if (!t.hasOwnProperty("amount")) { continue; }
                actual_glideslope.push([new Date(t.date), 0, 1e-2 * t.amount]);
            }
        }
        actual_glideslope.sort((a, b) => a[0].valueOf() - b[0].valueOf());

        // now that it is chronological, extend "actual glideslope" with cumulative (after transaction) amount
        let running_total = glideslope.budgeted_amount;
        for (let i = 0; i < actual_glideslope.length; i += 1) {
            running_total += actual_glideslope[i][2];
            actual_glideslope[i][1] = running_total;
        }
        glideslope["last_time_pct"] = (actual_glideslope[actual_glideslope.length - 1][0].valueOf() - bom.valueOf()) / (eom.valueOf() - bom.valueOf());

        // resample both series to a common grid
        const n_days = parseInt((new Date(year, month, 0) - new Date(year, month - 1, 1)) * 1e-3 / 86400) + 1;
        let i0 = 0; // index of first "actual" point after the current day
        for (let d = 1; d <= n_days; d += 1) {
            const pct = (d - 1) / (n_days - 1);

            // budgeted glideslope is linear decrease
            let budgeted = budgeted_glideslope[0][1] * (1 - pct);
            let actual = budgeted;

            // advance to first "actual" point after the current day
            while (i0 < actual_glideslope.length && actual_glideslope[i0][0].valueOf() < new Date(year, month - 1, d + 1).valueOf()) {
                i0 += 1;
            }
            if (d == 1) {
                // if there were no transactions on the first day, use initial budget
                if (i0 == 0) {
                    actual = budgeted_glideslope[0][1];
                } else {
                    actual = actual_glideslope[i0 - 1][1];
                }
            } else {
                // if there were no transactions on this day, use the most recent point
                actual = actual_glideslope[i0 - 1][1];
            }
            glideslope["glideslope_series"].push([new Date(year, month - 1, d), budgeted, actual]);
        }

        // finally, compute underspending percentage from last data point
        const last = glideslope["glideslope_series"][glideslope["glideslope_series"].length - 1];
        glideslope["underspending_pct"] = last[1] / budgeted_amount;

        res.json(glideslope);
    } catch (error) {
        console.error("Error in /glideslope/:identifier/group/:group_uuid endpoint:", error);
        res.status(500).json({ error: "Failed to fetch group glideslope data" });
    }
});

app.get("/accounts", async (req, res) => {
    try {
        await ensureApiInitialized();
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
        res.json(account_summaries);
    } catch (error) {
        console.error("Error in /accounts endpoint:", error);
        res.status(500).json({ error: "Failed to fetch accounts data" });
    }
});

app.get("/groups", async (req, res) => {
    try {
        await ensureApiInitialized();
        const cgs = await api.getCategoryGroups();
        const groups = cgs.map(cg => {
            return {
                "id": cg.id,
                "name": cg.name,
                "is_income": cg.is_income,
                "category_uuids": cg.categories.map(c => c.id)
            };
        });
        res.json(groups);
    } catch (error) {
        console.error("Error in /groups endpoint:", error);
        res.status(500).json({ error: "Failed to fetch group data" });
    }
});

app.get("/categories", async (req, res) => {
    try {
        await ensureApiInitialized();
        const cgs = await api.getCategoryGroups();
        let categories = [];
        for (let i = 0; i < cgs.length; i += 1) {
            categories.push({
                "group_uuid": cgs[i].id,
                "group_name": cgs[i].name,
                "is_income_group": cgs[i].is_income,
                "categories": cgs[i].categories.map(c => {
                    return {
                        "category_uuid": c.id,
                        "category_name": c.name,
                        "is_income_category": c.is_income
                    };
                })
            });
        }
        res.json(categories);
    } catch (error) {
        console.error("Error in /categories endpoint:", error);
        res.status(500).json({ error: "Failed to fetch categories data" });
    }
});

app.get("/payees", async (req, res) => {
    try {
        await ensureApiInitialized();
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
        res.json(payee_summaries);
    } catch (error) {
        console.error("Error in /payees endpoint:", error);
        res.status(500).json({ error: "Failed to fetch payees data" });
    }
});

app.get("/balance-sheet", async (req, res) => {
    try {
        await ensureApiInitialized();

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

        res.json(balanceSheetData);
    } catch (error) {
        console.error("Error in /balance-sheet endpoint:", error);
        res.status(500).json({ error: "Failed to fetch balance sheet data" });
    }
});

app.get("/income-statement", async (req, res) => {
    try {
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

        await ensureApiInitialized();

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
            for (let j = 0; j < income.length; j += 1) {
                const k = payee_uuids.indexOf(income[j].payee);
                income_statement.push({
                    "deposit": 1e-2 * income[j].amount,
                    "date": income[j].date,
                    "is_transfer": income[j].hasOwnProperty("transfer_id") && income[j].transfer_id != null ? true : false,
                    "into_account_id": accounts[i].id,
                    "into_account_name": accounts[i].name,
                    "from_payee_id": j < 0 ? null : payees[k].id,
                    "from_payee_name": j < 0 ? null : payees[k].name
                });
            }
        }
        res.json(income_statement);
    } catch (error) {
        console.error("Error in /income-statement endpoint:", error);
        res.status(500).json({ error: "Failed to fetch income statement data" });
    }
});

app.get("/cashflow/:identifier/by_group/:group_uuid", async (req, res) => {
    try {
        const identifier = req.params.identifier;
        const group_uuid = req.params.group_uuid;
        await ensureApiInitialized();
        const [year, month] = identifier.split("-").map(x => +x);
        const accounts = await api.getAccounts();
        const budget_month = await api.getBudgetMonth(identifier);
        const budget_groups = budget_month.categoryGroups;
        const group = budget_groups.find(g => g.id === group_uuid);
        if (!group) {
            res.status(404).json({ error: "Group not found" });
            return;
        }

        // recommended group test: "5200 - Food and Dining"
        const bom = new Date(year, month - 1, 1);
        const eom = new Date(year, month, 0);
        let transactions = [];

        // we must aggreegate a list of all categories in the target group
        const groups = await api.getCategoryGroups();
        const group_uuids = groups.map(g => g.id);
        const i = group_uuids.indexOf(group_uuid);
        if (i == -1) {
            res.status(404).json({ error: "Group not found" });
            return;
        }
        const category_uuids = group.categories.map(c => c.id);

        // now we must iterate over all transactions, which must be done on an account-by-account basis
        for (let i = 0; i < accounts.length; i += 1) {
            const account_transactions = await api.getTransactions(
                accounts[i].id,
                bom,
                eom
            );
            for (let j = 0; j < account_transactions.length; j += 1) {
                const t = account_transactions[j];
                if (category_uuids.indexOf(t.category) < 0) { continue; }
                const k = category_uuids.indexOf(t.category);
                const category = group.categories[k];
                if (!t.hasOwnProperty("amount")) { continue; }
                transactions.push({
                    "uuid": t.id ? t.id : null,
                    "account": t.account,
                    "date": t.date,
                    "amount": t.amount * 1e-2,
                    "payee_uuid": t.payee,
                    "payee_name": t.payee_name,
                    "imported_payee": t.imported_payee,
                    "category_uuid": t.category,
                    "category_name": category.name,
                    "is_income_category": category.is_income
                });
            }
        }
        transactions.sort((a, b) => a.date.valueOf() - b.date.valueOf());
        res.json(transactions);
    } catch (error) {
        console.error("Error in /cashflow/:identifier/by_group endpoint:", error);
        res.status(500).json({ error: "Failed to fetch cashflow by group data" });
    }
});

app.get("/cashflow/:identifier/summary", async (req, res) => {
    try {
        const identifier = req.params.identifier;
        const [year, month] = identifier.split("-").map(x => +x);
        const start_date = new Date(year, month - 1, 1);
        const end_date = new Date(year, month, 0);
        await ensureApiInitialized();
        const accounts = await getAllAccounts();
        const transactions = await getAllTransactions(start_date, end_date);
        const categories = await getAllCategories();
        const account_uuids = accounts.map((a) => a.id);
        const category_uuids = categories.map((c) => c.id);
        const cashflow_summary = {
            "total_income": 0,
            "total_expenses": 0,
            "total_investment": 0,
            "net_cash": 0,
            "num_transactions": transactions.length
        };
        for (let i = 0; i < transactions.length; i += 1) {
            const account = accounts[account_uuids.indexOf(transactions[i].account)];
            const category = categories[category_uuids.indexOf(transactions[i].category)];
            if (account.offbudget) { continue; } // cashflow at the budgeting boundary
            if (!account || !category) {
                console.warn(`Transaction ${transactions[i].id} has no account or category`);
                continue;
            }
            if (category.name.startsWith("3")) { // equity deposits (negative)
                cashflow_summary.total_investment += -transactions[i].amount * 1e-2;
            } else if (category.name.startsWith("4")) { // income deposits (positive)
                cashflow_summary.total_income += transactions[i].amount * 1e-2;
            } else if (category.name.startsWith("5")) { // expense withdrawls (negative)
                cashflow_summary.total_expenses += -transactions[i].amount * 1e-2;
            } else { // some other series not included in cashflow summary
                continue;
            }
        }
        cashflow_summary.net_cash = cashflow_summary.total_income - cashflow_summary.total_expenses - cashflow_summary.total_investment;
        res.json(cashflow_summary);
    } catch (error) {
        console.error("Error in /cashflow-summary/:identifier endpoint:", error);
        res.status(500).json({ error: "Failed to fetch cashflow summary data", details: error.message });
    }
});

app.get("/cashflow/:identifier/income", async (req, res) => {
    try {
        const identifier = req.params.identifier;
        const [year, month] = identifier.split("-").map(x => +x);
        const start_date = new Date(year, month - 1, 1);
        const end_date = new Date(year, month, 0);
        await ensureApiInitialized();
        const accounts = await getAllAccounts();
        const transactions = await getAllTransactions(start_date, end_date);
        const categories = await getAllCategories();
        const account_uuids = accounts.map((a) => a.id);
        const category_uuids = categories.map((c) => c.id);
        const income_breakdown = {}; // maps relevant categories to sum and count
        for (let i = 0; i < transactions.length; i += 1) {
            const account = accounts[account_uuids.indexOf(transactions[i].account)];
            const category = categories[category_uuids.indexOf(transactions[i].category)];
            if (account.offbudget) { continue; } // cashflow at the budgeting boundary
            if (!account || !category) {
                console.warn(`Transaction ${transactions[i].id} has no account or category`);
                continue;
            }
            if (category.name.startsWith("4")) { // income deposits (positive)
                if (!income_breakdown.hasOwnProperty(category.name)) {
                    income_breakdown[category.name] = {
                        "sum": 0,
                        "count": 0,
                        "name": category.name
                    };
                }
                income_breakdown[category.name].sum += transactions[i].amount * 1e-2;
                income_breakdown[category.name].count += 1;
            } else { // some other series not included in cashflow summary
                continue;
            }
        }
        const keys = Object.keys(income_breakdown);
        for (let j = 0; j < keys.length; j += 1) {
            const key = keys[j];
            income_breakdown[key]["average_transaction_amount"] = income_breakdown[key].sum / income_breakdown[key].count;
        }
        res.json(Object.values(income_breakdown));
    } catch (error) {
        console.error("Error in /cashflow/:identifier/income endpoint:", error);
        res.status(500).json({ error: "Failed to fetch cashflow summary data", details: error.message });
    }
});

app.get("/cashflow/:identifier/expenses", async (req, res) => {
    try {
        const identifier = req.params.identifier;
        const [year, month] = identifier.split("-").map(x => +x);
        const start_date = new Date(year, month - 1, 1);
        const end_date = new Date(year, month, 0);
        await ensureApiInitialized();
        const accounts = await getAllAccounts();
        const transactions = await getAllTransactions(start_date, end_date);
        const categories = await getAllCategories();
        const account_uuids = accounts.map((a) => a.id);
        const category_uuids = categories.map((c) => c.id);
        const expenses_breakdown = {}; // maps relevant categories to sum and count
        for (let i = 0; i < transactions.length; i += 1) {
            const account = accounts[account_uuids.indexOf(transactions[i].account)];
            const category = categories[category_uuids.indexOf(transactions[i].category)];
            if (account.offbudget) { continue; } // cashflow at the budgeting boundary
            if (!account || !category) {
                console.warn(`Transaction ${transactions[i].id} has no account or category`);
                continue;
            }
            if (category.name.startsWith("5")) { // expense withdrawls (negative)
                if (!expenses_breakdown.hasOwnProperty(category.name)) {
                    expenses_breakdown[category.name] = {
                        "sum": 0,
                        "count": 0,
                        "name": category.name
                    };
                }
                expenses_breakdown[category.name].sum += transactions[i].amount * -1e-2;
                expenses_breakdown[category.name].count += 1;
            } else { // some other series not included in cashflow summary
                continue;
            }
        }
        const keys = Object.keys(expenses_breakdown);
        for (let j = 0; j < keys.length; j += 1) {
            const key = keys[j];
            expenses_breakdown[key]["average_transaction_amount"] = expenses_breakdown[key].sum / expenses_breakdown[key].count;
        }
        res.json(Object.values(expenses_breakdown));
    } catch (error) {
        console.error("Error in /cashflow/:identifier/expenses endpoint:", error);
        res.status(500).json({ error: "Failed to fetch cashflow summary data", details: error.message });
    }
});

app.get("/", (req, res) => {
    res.json({
        message: "Financial Data API",
        endpoints: [
            "GET /health - Health check",
            "GET /months - List of months with budget data",
            "GET /months/:identifier/budget - Budget data for a given month",
            "GET /months/:identifier/transactions - Transactions for a given month",
            "GET /accounts - List of accounts",
            "GET /categories - List of categories",
            "GET /payees - List of payees",
            "GET /income-statement - Income statement data",
            "GET /balance-sheet - Balance sheet data",
        ]
    });
});

const server = app.listen(PORT, "0.0.0.0", () => {
    console.log(`Financial Data API server running on port ${PORT}`);
    console.log(`Health check: http://localhost:${PORT}/health`);
    console.log(`Balance Sheet: http://localhost:${PORT}/balance-sheet`);
});

// Graceful shutdown handling
process.on('SIGTERM', async () => {
    console.log('SIGTERM received, shutting down gracefully...');
    await safeApiShutdown();
    server.close(() => {
        console.log('Server closed');
        process.exit(0);
    });
});

process.on('SIGINT', async () => {
    console.log('SIGINT received, shutting down gracefully...');
    await safeApiShutdown();
    server.close(() => {
        console.log('Server closed');
        process.exit(0);
    });
});
