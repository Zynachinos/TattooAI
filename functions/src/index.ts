import { initializeApp } from "firebase-admin/app";
import { setGlobalOptions } from "firebase-functions/v2";

initializeApp();
setGlobalOptions({ region: "europe-west6", maxInstances: 10 });

export { createGeneration } from "./functions/createGeneration.js";
export { syncRevenueCatEntitlement } from "./functions/syncEntitlement.js";
export { cleanupExpiredGenerations } from "./functions/cleanupGenerations.js";
