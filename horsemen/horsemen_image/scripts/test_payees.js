/**
 * horsemen/horsemen_image/scripts/test_trans.js
 */

const api = require("@actual-app/api");

const ACTUAL_PASSWORD = process.env.ACTUAL_PASSWORD;
const ACTUAL_BUDGET = process.env.ACTUAL_BUDGET;
const PAYEE_UUID = process.env.PAYEE_UUID;

(async () => {
    await api.init({
        serverURL: "http://actual_container:5006",
        password: ACTUAL_PASSWORD
    });

    await api.downloadBudget(ACTUAL_BUDGET, {
        password: ACTUAL_PASSWORD
    });

    const payees = await api.getPayees();
    console.log(payees.filter((p) => p.id == PAYEE_UUID));
    
    await api.shutdown();
})();
