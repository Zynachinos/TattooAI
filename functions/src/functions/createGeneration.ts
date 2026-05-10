import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { firestorePaths, storagePaths } from "../shared/paths.js";
import { generateTattoo } from "../lib/gemini.js";
import type { UserDoc } from "../shared/types.js";

const IMAGE_MODEL =
  process.env.IMAGE_MODEL ?? "gemini-2.0-flash-exp";

export const createGeneration = onCall(
  {
    region: "europe-west6",
    enforceAppCheck: false,
    timeoutSeconds: 300,
    memory: "1GiB",
    secrets: ["GEMINI_API_KEY"],
  },
  async (request) => {
    // ── Auth ─────────────────────────────────────────────────────────────────
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Login required.");
    }
    const uid = request.auth.uid;
    const db = getFirestore();

    // ── Input ─────────────────────────────────────────────────────────────────
    const { requestId, prompt } = request.data as {
      requestId?: string;
      prompt?: string;
    };
    if (!requestId) {
      throw new HttpsError("invalid-argument", "requestId is required.");
    }

    // ── Entitlement check ─────────────────────────────────────────────────────
    const entDoc = await db.doc(firestorePaths.entitlement(uid)).get();
    const isPro = (entDoc.data()?.isPro as boolean | undefined) ?? false;
    if (!isPro) {
      throw new HttpsError("permission-denied", "Pro subscription required.");
    }

    // ── Credit check (atomic) ─────────────────────────────────────────────────
    const userRef = db.doc(firestorePaths.user(uid));
    const userData = (await userRef.get()).data() as UserDoc | undefined;
    if (!userData || userData.credits <= 0) {
      throw new HttpsError("resource-exhausted", "No credits remaining this week.");
    }

    // ── Read existing Firestore doc (created by client) ───────────────────────
    const reqRef = db.doc(firestorePaths.generationRequest(requestId));
    const reqSnap = await reqRef.get();
    if (!reqSnap.exists) {
      throw new HttpsError("not-found", "Generation request not found.");
    }
    const reqData = reqSnap.data() as {
      baseImagePath: string;
      referenceImagePath?: string;
    };

    // ── Mark as generating + deduct credit atomically ─────────────────────────
    const batch = db.batch();
    batch.update(reqRef, {
      status: "generating",
      updatedAt: FieldValue.serverTimestamp(),
    });
    batch.update(userRef, {
      credits: FieldValue.increment(-1),
      updatedAt: FieldValue.serverTimestamp(),
    });
    await batch.commit();

    // ── Call Gemini ───────────────────────────────────────────────────────────
    let resultBuffer: Buffer;
    try {
      resultBuffer = await generateTattoo({
        baseImagePath: reqData.baseImagePath,
        referenceImagePath: reqData.referenceImagePath,
        prompt: prompt ?? undefined,
        model: IMAGE_MODEL,
      });
    } catch (err) {
      // refund credit on Gemini failure
      await userRef.update({ credits: FieldValue.increment(1), updatedAt: FieldValue.serverTimestamp() });
      await reqRef.update({ status: "failed", errorMessage: String(err), updatedAt: FieldValue.serverTimestamp() });
      throw new HttpsError("internal", "Image generation failed.");
    }

    // ── Upload result to Storage ──────────────────────────────────────────────
    const resultPath = storagePaths.resultImage(uid, requestId);
    const bucket = getStorage().bucket();
    await bucket.file(resultPath).save(resultBuffer, {
      metadata: { contentType: "image/jpeg" },
    });

    // ── Mark completed ────────────────────────────────────────────────────────
    await reqRef.update({
      status: "completed",
      resultImagePath: resultPath,
      updatedAt: FieldValue.serverTimestamp(),
    });

    return { requestId, resultImagePath: resultPath };
  }
);
