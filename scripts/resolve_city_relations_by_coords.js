import fs from "fs";
import axios from "axios";

const OVERPASS_URLS = [
  "https://overpass-api.de/api/interpreter",
  "https://overpass.kumi.systems/api/interpreter"
];

const INPUT_FILE = "./data/cities.json";
const OUTPUT_FILE = "./data/cities_osm.json";

const REQUEST_DELAY_MS = 1200;
const RETRIES = 2;

// --------------------------------------------------

const sleep = (ms) => new Promise(r => setTimeout(r, ms));

const cities = JSON.parse(fs.readFileSync(INPUT_FILE, "utf8"));

async function runQuery(query, serverIndex = 0) {
  const url = OVERPASS_URLS[serverIndex % OVERPASS_URLS.length];

  const res = await axios.post(
    url,
    query,
    { headers: { "Content-Type": "text/plain" }, timeout: 60000 }
  );

  if (!res.data || !res.data.elements) {
    throw new Error("Non-JSON response");
  }

  return res.data.elements;
}

// --------------------------------------------------
// 🔑 Kernlogik: Relation über Koordinaten bestimmen
// --------------------------------------------------

async function resolveCity(city, attempt = 0) {
  const { city: name, cityAscii, adminName, lat, lng } = city;

  if (lat == null || lng == null) return null;

  const nameCandidates = [
    adminName,
    cityAscii,
    name
  ].filter(Boolean);

  const query = `
[out:json][timeout:25];
is_in(${lat}, ${lng})->.a;
relation(pivot.a)
  ["boundary"="administrative"];
out ids tags;
`;

  try {
    const relations = await runQuery(query, attempt);

    if (!relations.length) return null;

    let best = null;

    for (const r of relations) {
      const tags = r.tags || {};

      const rName = tags.name || "";

      const nameScore = nameCandidates.some(n =>
        rName.toLowerCase().includes(n.toLowerCase())
      ) ? 100 : 0;

      const adminLevel = parseInt(tags.admin_level ?? "99", 10);
      const levelScore = adminLevel <= 8 ? (20 - adminLevel) : 0;

      const totalScore = nameScore + levelScore;

      if (!best || totalScore > best.score) {
        best = {
          id: r.id,
          name: rName,
          adminLevel,
          score: totalScore
        };
      }
    }

    return best;

  } catch (err) {
    if (attempt < RETRIES) {
      await sleep(2000);
      return resolveCity(city, attempt + 1);
    }
    return null;
  }
}

// --------------------------------------------------

async function run() {
  const result = [];

  for (const city of cities) {
    const displayName = city.city ?? city.cityAscii ?? "unknown";

    console.log(`🔍 Resolving ${displayName}`);

    if (city.lat == null || city.lng == null) {
      console.warn("⚠ Missing coordinates, skipped");
      continue;
    }

    const resolved = await resolveCity(city);

    if (!resolved) {
      console.warn(`⚠ Could not resolve ${displayName}`);
      continue;
    }

    // 🔒 ROBUSTE ID-ERZEUGUNG (BUGFIX)
    const cityKey =
      (city.cityAscii ?? city.city ?? "unknown")
        .toLowerCase()
        .replace(/\s+/g, "_");

    const countryKey =
      (city.countryCode ?? "xx")
        .toLowerCase();

    result.push({
      id: `${cityKey}_${countryKey}`,
      name: city.city ?? city.cityAscii ?? "unknown",
      countryCode: city.countryCode ?? null,
      relationId: resolved.id,
      adminLevel: resolved.adminLevel
    });

    console.log(
      `  → relation ${resolved.id} (admin_level ${resolved.adminLevel})`
    );

    await sleep(REQUEST_DELAY_MS);
  }

  fs.writeFileSync(
    OUTPUT_FILE,
    JSON.stringify(result, null, 2),
    "utf8"
  );

  console.log(`\n✅ cities_osm.json generated (${result.length} cities)`);
}

// ▶ Start
run();
