/**
 * horsemen/horsemen_image/scripts/test_trans.js
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
    const accounts = await api.getAccounts();
    const account_uuids = accounts.map((a) => a.id);
    const end_date = new Date();
    const dt_s = 30 * 86400; // 30 days
    const start_date = new Date(end_date.valueOf() - dt_s * 1e3);
    const payees = await api.getPayees();
    const payee_uuids = payees.map((p) => p.id);
    for (let i = 0; i < accounts.length; i++) {
        const trans = await api.getTransactions(
            accounts[i].id,
            start_date,
            end_date
        );
        console.log(accounts[i].name, trans.filter((t)=> {
            const i = payee_uuids.indexOf(t.payee);
            if (i == -1) { return true; } // no payee (yet?)
            const payee = payees[i];
            return t.amount >= 0 && !account_uuids.includes(payee.transfer_acct);
        }));
    }
    await api.shutdown();
})();
