import {
  GoogleGenerativeAI,
  HarmCategory,
  HarmBlockThreshold,
} from "@google/generative-ai";
import { getStorage } from "firebase-admin/storage";

const SAFETY = [
  { category: HarmCategory.HARM_CATEGORY_HARASSMENT, threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH },
  { category: HarmCategory.HARM_CATEGORY_HATE_SPEECH, threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH },
  { category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT, threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH },
  { category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT, threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH },
];

async function readStorageImage(path: string): Promise<{ data: string; mimeType: string }> {
  const bucket = getStorage().bucket();
  const [buffer] = await bucket.file(path).download();
  return {
    data: buffer.toString("base64"),
    mimeType: "image/jpeg",
  };
}

export async function generateTattoo(params: {
  baseImagePath: string;
  referenceImagePath?: string;
  prompt?: string;
  model: string;
}): Promise<Buffer> {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) throw new Error("GEMINI_API_KEY not set");

  const genAI = new GoogleGenerativeAI(apiKey);
  const gemini = genAI.getGenerativeModel({
    model: params.model,
    safetySettings: SAFETY,
  });

  const baseImg = await readStorageImage(params.baseImagePath);

  const parts: object[] = [
    {
      inlineData: { data: baseImg.data, mimeType: baseImg.mimeType },
    },
  ];

  if (params.referenceImagePath) {
    const refImg = await readStorageImage(params.referenceImagePath);
    parts.push({ inlineData: { data: refImg.data, mimeType: refImg.mimeType } });
  }

  const descriptionPart = params.prompt?.trim()
    ? `Design description: ${params.prompt.trim()}.`
    : "";
  const refPart = params.referenceImagePath
    ? "Use the second image as the tattoo style and design reference."
    : "";

  parts.push({
    text: [
      "You are a professional tattoo artist.",
      "The first image shows the body part where the tattoo will be placed.",
      refPart,
      "Generate a photorealistic image showing a high-quality tattoo",
      "placed on the exact body part shown — as if freshly done by a skilled artist.",
      "The tattoo should look like real ink on skin: sharp lines, proper shading.",
      descriptionPart,
      "Output only the final image, no text.",
    ]
      .filter(Boolean)
      .join(" "),
  });

  const result = await gemini.generateContent({
    contents: [{ role: "user", parts: parts as never[] }],
    generationConfig: {
      // @ts-expect-error responseModalities is not yet in typedefs
      responseModalities: ["IMAGE"],
    },
  });

  const imagePart = result.response.candidates?.[0]?.content?.parts?.find(
    (p) => p.inlineData?.mimeType?.startsWith("image/")
  );
  if (!imagePart?.inlineData?.data) {
    throw new Error("Gemini returned no image");
  }

  return Buffer.from(imagePart.inlineData.data, "base64");
}
