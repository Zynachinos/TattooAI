import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import { firestorePaths, storagePaths } from "../shared/paths.js";
import type { UserDoc } from "../shared/types.js";

// Phase 7.2 — IMAGE_MODEL env var overrides the default
const IMAGE_MODEL = process.env.IMAGE_MODEL ?? "gemini-2.5-flash-preview-05-20";

export const createGeneration = onCall(
  { region: "europe-west6", enforceAppCheck: false },
  async (request) => {
    // ── Auth check ──────────────────────────────────────────────────────────
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Login required.");
    }
    const uid = request.auth.uid;
    const db = getFirestore();

    // ── Entitlement check (server-side) ─────────────────────────────────────
    const entDoc = await db.doc(firestorePaths.entitlement(uid)).get();
    const isPro = (entDoc.data()?.isPro as boolean | undefined) ?? false;
    if (!isPro) {
      throw new HttpsError("permission-denied", "Pro subscription required.");
    }

    // ── Credit check ────────────────────────────────────────────────────────
    const userDoc = await db.doc(firestorePaths.user(uid)).get();
    const userData = userDoc.data() as UserDoc | undefined;
    if (!userData || userData.credits <= 0) {
      throw new HttpsError(
        "resource-exhausted",
        "No credits remaining this week."
      );
    }

    // ── Input validation ────────────────────────────────────────────────────
    const { requestId, prompt } = request.data as {
      requestId?: string;
      prompt?: string;
    };
    if (!requestId) {
      throw new HttpsError("invalid-argument", "requestId is required.");
    }

    const baseImagePath = storagePaths.baseImage(uid, requestId);

    // ── Create Firestore request doc ─────────────────────────────────────────
    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);
    await db.doc(firestorePaths.generationRequest(requestId)).set({
      uid,
      status: "queued",
      ...(prompt ? { prompt } : {}),
      baseImagePath,
      expiresAt: Timestamp.fromDate(expiresAt),
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    // ── Deduct credit ────────────────────────────────────────────────────────
    await db.doc(firestorePaths.user(uid)).update({
      credits: FieldValue.increment(-1),
      updatedAt: FieldValue.serverTimestamp(),
    });

    // ── TODO Phase 7.2: call Gemini, write result, update status ────────────
    // const result = await generateWithGemini({ baseImagePath, referenceImagePath, prompt, model: IMAGE_MODEL });
    // await db.doc(firestorePaths.generationRequest(requestId)).update({ status: "completed", resultImagePath: result.path, updatedAt: FieldValue.serverTimestamp() });
    void IMAGE_MODEL; // used in Phase 7.2

    return { requestId };
  }
);
