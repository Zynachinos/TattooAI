export const firestorePaths = {
  user: (uid: string) => `users/${uid}`,
  entitlement: (uid: string) => `entitlements/${uid}`,
  generationRequest: (id: string) => `generation_requests/${id}`,
  generationRequests: "generation_requests",
} as const;

export const storagePaths = {
  baseImage: (uid: string, requestId: string) =>
    `users/${uid}/generation_requests/${requestId}/base.jpg`,
  referenceImage: (uid: string, requestId: string) =>
    `users/${uid}/generation_requests/${requestId}/reference.jpg`,
  resultImage: (uid: string, requestId: string) =>
    `users/${uid}/generation_requests/${requestId}/result.jpg`,
} as const;
