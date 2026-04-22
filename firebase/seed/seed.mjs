#!/usr/bin/env node
// Populate the local Firebase emulator suite from `fixtures.json`.
//
// Requires the emulator ports defined in `docker/firebase/env/.env.example`
// (FIREBASE_AUTH_PORT, FIREBASE_FIRESTORE_PORT, FIREBASE_STORAGE_PORT) to
// be reachable on 127.0.0.1. The script is idempotent:
//   - auth users are upserted by UID
//   - firestore documents are set with `merge: false` so a re-run replaces them
//   - storage placeholders are overwritten
//
// Usage:
//   FIREBASE_PROJECT=demo-vocastock \
//   FIREBASE_AUTH_PORT=19099 \
//   FIREBASE_FIRESTORE_PORT=18080 \
//   FIREBASE_STORAGE_PORT=19199 \
//   node firebase/seed/seed.mjs
//
// Flags:
//   --reset   Delete all previously seeded users / documents before writing.

import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import admin from "firebase-admin";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const projectId = process.env.FIREBASE_PROJECT ?? "demo-vocastock";
const authPort = process.env.FIREBASE_AUTH_PORT ?? "19099";
const firestorePort = process.env.FIREBASE_FIRESTORE_PORT ?? "18080";
const storagePort = process.env.FIREBASE_STORAGE_PORT ?? "19199";
const pubsubPort = process.env.FIREBASE_PUBSUB_PORT ?? "18085";

// firebase-admin reads these env vars to target the emulator.
process.env.FIRESTORE_EMULATOR_HOST = `127.0.0.1:${firestorePort}`;
process.env.FIREBASE_AUTH_EMULATOR_HOST = `127.0.0.1:${authPort}`;
process.env.FIREBASE_STORAGE_EMULATOR_HOST = `127.0.0.1:${storagePort}`;
process.env.PUBSUB_EMULATOR_HOST = `127.0.0.1:${pubsubPort}`;

// Topic / subscription pairs created at seed time so command-api can
// publish without having to auto-create on first publish. Workers pull
// from the `.sub` subscriptions.
const PUBSUB_TOPICS = [
  "workflow.explanation-jobs",
  "workflow.image-jobs",
  "workflow.retry-jobs",
  "billing.purchase-jobs",
];

const resetFlag = process.argv.includes("--reset");

async function main() {
  const fixturesPath = resolve(__dirname, "fixtures.json");
  const raw = await readFile(fixturesPath, "utf8");
  const fixtures = JSON.parse(raw);

  admin.initializeApp({
    projectId,
    storageBucket: fixtures.storage?.bucket ?? `${projectId}.appspot.com`,
  });

  const auth = admin.auth();
  const firestore = admin.firestore();
  const bucket = admin.storage().bucket();

  if (resetFlag) {
    await resetAll(auth, firestore);
  }

  await seedAuth(auth, fixtures.auth?.users ?? []);
  await seedFirestore(firestore, fixtures.firestore?.actors ?? []);
  await seedStorage(bucket, fixtures.storage?.placeholders ?? []);
  await seedPubSub(projectId, PUBSUB_TOPICS);

  console.log("[vocastock] seed completed");
  console.log(
    `[vocastock]   auth:     ${fixtures.auth?.users?.length ?? 0} users`,
  );
  const actorCount = fixtures.firestore?.actors?.length ?? 0;
  const vocabCount = (fixtures.firestore?.actors ?? []).reduce(
    (sum, actor) => sum + (actor.vocabularyExpressions?.length ?? 0),
    0,
  );
  console.log(
    `[vocastock]   firestore: ${actorCount} actors, ${vocabCount} vocabulary expressions`,
  );
  console.log(
    `[vocastock]   storage:  ${fixtures.storage?.placeholders?.length ?? 0} placeholder objects`,
  );
  console.log("[vocastock] emulator UI: http://127.0.0.1:14000");
}

async function resetAll(auth, firestore) {
  console.log("[vocastock] --reset: clearing existing auth users and firestore data");
  const { users } = await auth.listUsers(1000);
  if (users.length > 0) {
    await auth.deleteUsers(users.map((u) => u.uid));
  }
  const actors = await firestore.collection("actors").listDocuments();
  for (const actorRef of actors) {
    await deleteCollection(firestore, actorRef.collection("vocabularyExpressions"));
    await deleteCollection(firestore, actorRef.collection("explanations"));
    await deleteCollection(firestore, actorRef.collection("images"));
    await deleteCollection(firestore, actorRef.collection("subscription"));
    await actorRef.delete();
  }
}

async function deleteCollection(firestore, collectionRef) {
  const snapshot = await collectionRef.get();
  if (snapshot.empty) return;
  const batch = firestore.batch();
  for (const doc of snapshot.docs) {
    batch.delete(doc.ref);
  }
  await batch.commit();
}

async function seedAuth(auth, users) {
  for (const user of users) {
    try {
      await auth.deleteUser(user.uid);
    } catch (error) {
      if (error.code !== "auth/user-not-found") {
        throw error;
      }
    }
    await auth.createUser({
      uid: user.uid,
      email: user.email,
      password: user.password,
      emailVerified: user.emailVerified ?? false,
      displayName: user.displayName,
    });
    if (user.customClaims) {
      await auth.setCustomUserClaims(user.uid, user.customClaims);
    }
    console.log(`[vocastock]   auth:       ✓ ${user.email} (uid=${user.uid})`);
  }
}

async function seedFirestore(firestore, actors) {
  for (const actor of actors) {
    const actorRef = firestore.collection("actors").doc(actor.id);
    await actorRef.set(actor.data ?? {});

    if (actor.subscription) {
      await actorRef
        .collection("subscription")
        .doc("current")
        .set(actor.subscription);
    }

    for (const entry of actor.vocabularyExpressions ?? []) {
      await actorRef
        .collection("vocabularyExpressions")
        .doc(entry.id)
        .set(entry);
    }

    for (const explanation of actor.explanations ?? []) {
      await actorRef
        .collection("explanations")
        .doc(explanation.id)
        .set(explanation);
    }

    for (const image of actor.images ?? []) {
      await actorRef.collection("images").doc(image.id).set(image);
    }

    for (const learningState of actor.learningStates ?? []) {
      await actorRef
        .collection("learningStates")
        .doc(learningState.id)
        .set(learningState);
    }

    const vocabCount = actor.vocabularyExpressions?.length ?? 0;
    const explanationCount = actor.explanations?.length ?? 0;
    const imageCount = actor.images?.length ?? 0;
    const learningStateCount = actor.learningStates?.length ?? 0;
    console.log(
      `[vocastock]   firestore:  ✓ actor=${actor.id} ` +
        `(${vocabCount} vocabs, ${explanationCount} explanations, ${imageCount} images, ${learningStateCount} learningStates)`,
    );
  }
}

async function seedPubSub(projectId, topics) {
  // The PubSub emulator exposes the same REST surface as production
  // Google PubSub. Creating a topic is idempotent (emulator returns 409
  // when it already exists); we treat that as success.
  const host = process.env.PUBSUB_EMULATOR_HOST;
  if (!host) {
    console.log("[vocastock]   pubsub:   skipped (PUBSUB_EMULATOR_HOST not set)");
    return;
  }
  for (const topic of topics) {
    await ensureTopic(host, projectId, topic);
    await ensureSubscription(host, projectId, topic, `${topic}.sub`);
  }
}

async function ensureTopic(host, projectId, topicId) {
  const url = `http://${host}/v1/projects/${projectId}/topics/${topicId}`;
  const response = await fetch(url, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({}),
  });
  if (response.ok || response.status === 409) {
    console.log(`[vocastock]   pubsub:     ✓ topic=${topicId}`);
    return;
  }
  const body = await response.text();
  throw new Error(
    `failed to create pubsub topic ${topicId}: HTTP ${response.status} ${body}`,
  );
}

async function ensureSubscription(host, projectId, topicId, subscriptionId) {
  const url = `http://${host}/v1/projects/${projectId}/subscriptions/${subscriptionId}`;
  const response = await fetch(url, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      topic: `projects/${projectId}/topics/${topicId}`,
      ackDeadlineSeconds: 30,
    }),
  });
  if (response.ok || response.status === 409) {
    console.log(`[vocastock]   pubsub:     ✓ subscription=${subscriptionId}`);
    return;
  }
  const body = await response.text();
  throw new Error(
    `failed to create pubsub subscription ${subscriptionId}: HTTP ${response.status} ${body}`,
  );
}

async function seedStorage(bucket, placeholders) {
  // 1x1 transparent PNG (8-bit, greyscale). 67 bytes.
  const onePixelPng = Buffer.from(
    "89504e470d0a1a0a0000000d49484452000000010000000108060000001f15c4890000000d4944415478da63f8ff9f0100050001007173b2e80000000049454e44ae426082",
    "hex",
  );
  for (const placeholder of placeholders) {
    const file = bucket.file(placeholder.path);
    await file.save(onePixelPng, {
      contentType: placeholder.contentType ?? "image/png",
      metadata: {
        metadata: {
          seeded: "true",
          description: placeholder.description ?? "",
        },
      },
    });
    console.log(`[vocastock]   storage:    ✓ ${placeholder.path}`);
  }
}

main().catch((error) => {
  console.error("[vocastock] seed failed:", error);
  process.exitCode = 1;
});
