export type GenerationStatus =
  | "queued"
  | "generating"
  | "completed"
  | "failed";

export interface GenerationRequest {
  uid: string;
  status: GenerationStatus;
  prompt?: string;
  baseImagePath: string;
  referenceImagePath?: string;
  resultImagePath?: string;
  errorMessage?: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
}

export interface UserDoc {
  email: string | null;
  displayName: string | null;
  role: "user" | "admin";
  credits: number;
  creditsResetAt?: FirebaseFirestore.Timestamp;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

export interface EntitlementDoc {
  isPro: boolean;
  productId?: string;
  periodType?: string;
  expiresAt?: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}
