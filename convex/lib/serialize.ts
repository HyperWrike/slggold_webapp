import type { Doc } from "../_generated/dataModel";

/** Convex stores `_id`; the Flutter app expects `id` (string). */
export function docWithId<T extends Record<string, unknown>>(
  doc: T & { _id: unknown },
): Record<string, unknown> {
  const { _id, ...rest } = doc;
  return { ...rest, id: String(_id) };
}

export function docsWithId<T extends { _id: unknown }>(docs: T[]) {
  return docs.map((d) => docWithId(d as T & Record<string, unknown>));
}

export type ProfileDoc = Doc<"profiles">;
