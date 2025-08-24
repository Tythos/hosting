/**
 * scripts/actual-connect.js
 */

const api = require("@actual-app/api");
const ACTUAL_PASSWORD = process.env.ACTUAL_PASSWORD;
const ACTUAL_BUDGET = process.env.ACTUAL_BUDGET;

(async () => {
    await api.init({
        serverURL: "http://actual_container:5006",
        password: ACTUAL_PASSWORD
    });

    await api.downloadBudget(ACTUAL_BUDGET, {
        password: ACTUAL_PASSWORD
    });
    const budget = await api.getAccounts();
    const today = new Date();
    budget.forEach(async (account) => {
        const balance = await api.getAccountBalance(account.id, today);
        console.log(account.name, balance);
    });
    await api.shutdown();
})();
