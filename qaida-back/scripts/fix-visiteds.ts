import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import mongoose, { Types } from 'mongoose';

const envCandidates = [
  path.resolve(process.cwd(), 'src/core/.env'),
  path.resolve(process.cwd(), '.env'),
];

for (const envPath of envCandidates) {
  if (fs.existsSync(envPath)) {
    dotenv.config({ path: envPath });
  }
}

const DATABASE_URL = process.env.DATABASE_URL;

if (!DATABASE_URL) {
  throw new Error('DATABASE_URL is not set');
}

const VALID_STATUSES = new Set(['VISITED', 'PROCESSING', 'SKIP']);

function isObjectId(value: any): boolean {
  return !!value && (value._bsontype === 'ObjectId' || value instanceof Types.ObjectId);
}

function toObjectId(value: any): Types.ObjectId | null {
  if (isObjectId(value)) return value as Types.ObjectId;

  if (typeof value === 'string' && /^[a-fA-F0-9]{24}$/.test(value)) {
    return new Types.ObjectId(value);
  }

  if (
    value &&
    typeof value === 'object' &&
    typeof value.$oid === 'string' &&
    /^[a-fA-F0-9]{24}$/.test(value.$oid)
  ) {
    return new Types.ObjectId(value.$oid);
  }

  return null;
}

function toDate(value: any): Date | null {
  if (!value) return null;

  if (value instanceof Date) {
    return isNaN(value.getTime()) ? null : value;
  }

  if (typeof value === 'string' || typeof value === 'number') {
    const d = new Date(value);
    return isNaN(d.getTime()) ? null : d;
  }

  if (value?.$date?.$numberLong) {
    const d = new Date(Number(value.$date.$numberLong));
    return isNaN(d.getTime()) ? null : d;
  }

  if (value?.$date) {
    const d = new Date(value.$date);
    return isNaN(d.getTime()) ? null : d;
  }

  return null;
}

function statusPriority(status: string): number {
  switch (status) {
    case 'VISITED':
      return 3;
    case 'SKIP':
      return 2;
    case 'PROCESSING':
      return 1;
    default:
      return 0;
  }
}

async function main() {
  await mongoose.connect(DATABASE_URL);

  const db = mongoose.connection.db;
  if (!db) throw new Error('No database connection');

  const visiteds = db.collection('visiteds');
  const invalidBackup = db.collection('visiteds_invalid_backup');
  const duplicatesBackup = db.collection('visiteds_duplicates_backup');

  console.log('Connected to DB');

  // 1) Normalize and remove invalid documents
  const allDocs = await visiteds.find({}).toArray();

  let normalizedCount = 0;
  let invalidCount = 0;

  for (const doc of allDocs) {
    const normalizedUserId = toObjectId(doc.user_id);
    const normalizedPlaceId = toObjectId(doc.place_id);

    const rawVisitedTime = doc.visited_time ?? doc.visited_at;
    const normalizedVisitedTime = toDate(rawVisitedTime);

    const normalizedStatus =
      typeof doc.status === 'string' && VALID_STATUSES.has(doc.status)
        ? doc.status
        : null;

    const reasons: string[] = [];
    const $set: Record<string, any> = {};
    const $unset: Record<string, any> = {};

    if (!normalizedUserId) reasons.push('invalid user_id');
    if (!normalizedPlaceId) reasons.push('invalid place_id');
    if (!normalizedVisitedTime) reasons.push('missing_or_invalid visited_time/visited_at');
    if (!normalizedStatus) reasons.push('missing_or_invalid status');

    if (reasons.length > 0) {
      await invalidBackup.insertOne({
        source: 'visiteds',
        original_id: doc._id,
        reasons,
        payload: doc,
        moved_at: new Date(),
      });

      await visiteds.deleteOne({ _id: doc._id });
      invalidCount += 1;
      continue;
    }

    if (!isObjectId(doc.user_id)) {
      $set.user_id = normalizedUserId;
    }

    if (!isObjectId(doc.place_id)) {
      $set.place_id = normalizedPlaceId;
    }

    if (!doc.visited_time || doc.visited_time?.toString?.() !== normalizedVisitedTime.toString()) {
      $set.visited_time = normalizedVisitedTime;
    }

    if (doc.visited_at !== undefined) {
      $unset.visited_at = '';
    }

    if (Object.keys($set).length > 0 || Object.keys($unset).length > 0) {
      const update: Record<string, any> = {};
      if (Object.keys($set).length > 0) update.$set = $set;
      if (Object.keys($unset).length > 0) update.$unset = $unset;

      await visiteds.updateOne({ _id: doc._id }, update);
      normalizedCount += 1;
    }
  }

  console.log(`Normalized docs: ${normalizedCount}`);
  console.log(`Removed invalid docs to backup: ${invalidCount}`);

  // 2) Remove duplicates if any
  const cleanedDocs = await visiteds
    .find(
      {},
      {
        projection: {
          _id: 1,
          user_id: 1,
          place_id: 1,
          status: 1,
          visited_time: 1,
        },
      },
    )
    .toArray();

  const groups = new Map<string, any[]>();

  for (const doc of cleanedDocs) {
    const userId = String(doc.user_id);
    const placeId = String(doc.place_id);
    const key = `${userId}__${placeId}`;

    if (!groups.has(key)) groups.set(key, []);
    groups.get(key)!.push(doc);
  }

  let duplicateGroups = 0;
  let duplicateDocsRemoved = 0;

  for (const [, docs] of groups.entries()) {
    if (docs.length <= 1) continue;

    duplicateGroups += 1;

    docs.sort((a, b) => {
      const statusDiff = statusPriority(b.status) - statusPriority(a.status);
      if (statusDiff !== 0) return statusDiff;

      const aTime = toDate(a.visited_time)?.getTime() ?? 0;
      const bTime = toDate(b.visited_time)?.getTime() ?? 0;
      if (bTime !== aTime) return bTime - aTime;

      return String(b._id).localeCompare(String(a._id));
    });

    const keepDoc = docs[0];
    const removeDocs = docs.slice(1);

    if (removeDocs.length > 0) {
      await duplicatesBackup.insertOne({
        keep: keepDoc,
        removed: removeDocs,
        moved_at: new Date(),
      });

      await visiteds.deleteMany({
        _id: { $in: removeDocs.map((doc) => doc._id) },
      });

      duplicateDocsRemoved += removeDocs.length;
    }
  }

  console.log(`Duplicate groups found: ${duplicateGroups}`);
  console.log(`Duplicate docs removed: ${duplicateDocsRemoved}`);

  // 3) Create unique index
  const indexes = await visiteds.indexes();
  const hasUniqueIndex = indexes.some(
    (idx) => idx.name === 'uniq_user_place_visit',
  );

  if (!hasUniqueIndex) {
    await visiteds.createIndex(
      { user_id: 1, place_id: 1 },
      { unique: true, name: 'uniq_user_place_visit' },
    );
    console.log('Unique index created: uniq_user_place_visit');
  } else {
    console.log('Unique index already exists: uniq_user_place_visit');
  }

  await mongoose.disconnect();
  console.log('Done');
}

main().catch(async (error) => {
  console.error('fix-visiteds failed:', error);
  try {
    await mongoose.disconnect();
  } catch {}
  process.exit(1);
});