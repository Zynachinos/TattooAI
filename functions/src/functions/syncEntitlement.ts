import { onRequest } from "firebase-functions/v2/https";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { firestorePaths } from "../shared/paths.js";
import type { EntitlementDoc } from "../shared/types.js";

// Phase 8.1 — RevenueCat webhook
// Configure in RevenueCat dashboard: Settings → Integrations → Webhooks
// Set Authorization header to REVENUECAT_WEBHOOK_SECRET env var

export const syncRevenueCatEntitlement = onRequest(
  { region: "europe-west6" },
  async (req, res) => {
    // ── Method check ────────────────────────────────────────────────────────
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    // ── Signature check ─────────────────────────────────────────────────────
    const secret = process.env.REVENUECAT_WEBHOOK_SECRET;
    if (secret && req.headers.authorization !== secret) {
      res.status(401).send("Unauthorized");
      return;
    }

    const event = req.body as {
      event?: {
        type?: string;
        app_user_id?: string;
        product_id?: string;
        period_type?: string;
        expiration_at_ms?: number;
      };
    };

    const { type, app_user_id: uid, product_id, period_type, expiration_at_ms } =
      event.event ?? {};

    if (!uid) {
      res.status(400).send("Missing app_user_id");
      return;
    }

    const db = getFirestore();
    const isPro = type !== "EXPIRATION" && type !== "CANCELLATION";

    const entitlement: Omit<EntitlementDoc, "updatedAt"> & {
      updatedAt: FieldValue;
    } = {
      isPro,
      productId: product_id ?? null as unknown as undefined,
      periodType: period_type ?? null as unknown as undefined,
      expiresAt: expiration_at_ms
        ? (FirebaseFirestore.Timestamp.fromMillis(expiration_at_ms) as FirebaseFirestore.Timestamp)
        : null as unknown as undefined,
      updatedAt: FieldValue.serverTimestamp(),
    };

    await db.doc(firestorePaths.entitlement(uid)).set(entitlement, { merge: true });

    // ── Reset credits on new subscription period ─────────────────────────────
    if (type === "RENEWAL" || type === "INITIAL_PURCHASE" || type === "TRIAL_STARTED") {
      await db.doc(firestorePaths.user(uid)).update({
        credits: 6, // AppConfig.creditsPerWeek
        creditsResetAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    res.status(200).send("OK");
  }
);
