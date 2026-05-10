import { onSchedule } from "firebase-functions/v2/scheduler";
import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { firestorePaths, storagePaths } from "../shared/paths.js";

// Runs every hour, deletes generation_requests older than 24h and their Storage files
export const cleanupExpiredGenerations = onSchedule(
  { schedule: "every 60 minutes", region: "europe-west6" },
  async () => {
    const db = getFirestore();
    const now = Timestamp.now();

    const expired = await db
      .collection(firestorePaths.generationRequests)
      .where("expiresAt", "<=", now)
      .limit(100)
      .get();

    if (expired.empty) return;

    const bucket = getStorage().bucket();
    const batch = db.batch();

    await Promise.all(
      expired.docs.map(async (doc) => {
        const { uid } = doc.data() as { uid: string };
        const id = doc.id;

        // Delete Storage files (ignore errors if already gone)
        await Promise.allSettled([
          bucket.file(storagePaths.baseImage(uid, id)).delete(),
          bucket.file(storagePaths.referenceImage(uid, id)).delete(),
          bucket.file(storagePaths.resultImage(uid, id)).delete(),
        ]);

        batch.delete(doc.ref);
      })
    );

    await batch.commit();
    void FieldValue; // used implicitly via batch
  }
);
