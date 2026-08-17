# Impact Gap-Finder Pipeline

Automated triangulation of Impact's missing field mappings using SpawnPK's shape signatures and RuneLite-API canonical concepts as inputs. Output is consumed automatically by the existing Copilot mapper UI — no operator workflow change.

## What it does

```
runelite-api-1.11.12.jar
       ↓ (1) ConceptRegistryExtractor
       ↓
  concepts.json  ←  688 canonical method-concepts across 24 RL-API interfaces
       ↓
       + spawnpk-client-mapping.json + spawnpk fingerprints
       + impact-r112/field-mapping.properties (existing confirmed)
       + impact-r112/verified-mappings.json (existing field guesses)
       ↓ (2) ShapeAggregator
       ↓
  concept-shapes.json  ←  per-concept multi-source evidence
       ↓
       + impact codebase112.dat (full jar)
       ↓ (3) GapTriangulator
       ↓
  copilot-briefs.json  ←  candidate field rankings per gap concept
  triangulator-report.txt  ← human-readable diagnostic
       ↓ (4) VerifiedMappingsInjector
       ↓
  verified-mappings.json  ← enriched with [XSRV] markers per field
```

## How the operator uses it

**No new tool, no new UI.** The operator opens the existing Copilot mapper UI exactly as before. When they focus a logical field (e.g. `Player.combatLevel`) and call `scan_candidates`, the candidate list shows `[XSRV]` markers in the guess column for fields that the triangulator identified as cross-server matches. Example:

```
Oc  I  int (combatLevel/skullIcon/overheadIcon/team) [XSRV] Player.getCombatLevel(#1,s=71)
OF  I  int (combatLevel/skullIcon/overheadIcon/team) [XSRV] Player.getCombatLevel(#3,s=69)
Or  I  int (combatLevel/skullIcon/overheadIcon/team) [XSRV] Player.getCombatLevel(#4,s=68)
i   I  int (combatLevel/skullIcon/overheadIcon/team)
b   I  int (combatLevel/skullIcon/overheadIcon/team)
```

`(#N,s=K)` means rank N out of the candidates we considered, shape-match score K. Higher score = stronger SpawnPK structural agreement. Use this as your starting point for runtime verification.

## How to run

```bash
cd vanilla-injector

# Run all four stages in order (each writes its own output file):
./gradlew :signature-scanner:compileJava

CP="$(find ~/.gradle -name 'asm-9.4.jar' | head -1):$(find ~/.gradle -name 'asm-tree-9.4.jar' | head -1)"
CLASSPATH="signature-scanner/build/classes/java/main:$CP"

cd ..   # back to repo root
java -cp "vanilla-injector/$CLASSPATH" com.privbot.signaturescanner.ConceptRegistryExtractor
java -cp "vanilla-injector/$CLASSPATH" com.privbot.signaturescanner.ShapeAggregator
java -cp "vanilla-injector/$CLASSPATH" com.privbot.signaturescanner.GapTriangulator
java -cp "vanilla-injector/$CLASSPATH" com.privbot.signaturescanner.VerifiedMappingsInjector
```

## Why this is the right design

- **Composes with existing tooling** — the Copilot's `scan_candidates` tool reads `verified-mappings.json`. We enrich that file. Zero Copilot code changes.
- **Conservative auto-promotion** — entries that conflict with Impact's already-confirmed mappings are demoted to briefs. The system never silently disagrees with hand-verified knowledge.
- **Idempotent** — re-running replaces our `[XSRV]` markers in place. Original file backed up to `verified-mappings.json.pre-injection.bak`.
- **Descriptor-aware** — Impact's obfuscator produces multiple fields with the same name on the same class but different descriptors (e.g. `a/n.O` exists as `int`, `boolean`, AND `String` simultaneously). The injector keys by `(class, name, descriptor)` to disambiguate.

## Limitations

The triangulator only helps for concepts that have **both**:
1. A SpawnPK mapping anchored to a SpawnPK class that we can map to an Impact class
2. An Impact class anchor in `class-mapping.properties`

Coverage today:
- 688 canonical concepts total
- 63 have SpawnPK shapes after interface-strict matching
- 27 already confirmed in Impact (no work needed)
- ~32 actionable gap concepts get briefs
- ~600 concepts have no triangulation evidence — those still need the Copilot's runtime-observation workflow from cold

To increase coverage further, you'd need a third independent source — e.g., RuneLite's public deob mappings for any OSRS revision, or fingerprints captured from another mapped private server.

## Conflict log

The triangulator detected and refused to auto-promote 4 entries that disagreed with existing Impact mappings:

| Concept | Triangulator pick | Impact's existing | Resolution |
|---|---|---|---|
| `CollisionData.flags` | `O` | `CollisionMap.clippingData = O` | ✅ same field, different concept name — already mapped |
| `NPCComposition.combatLevel` | `U` | `combatLevel.candidates = U,r` | ⚠ Impact had two candidates; triangulator picked one but didn't auto-promote because of the `.candidates` list. Brief queued. |
| `Node.next` | `U` | `CacheableNode.next = O` | ⚠ Disagreement — one of them is wrong. Send to Copilot for runtime verification. |
| `Node.previous` | `O` | `CacheableNode.previous = U` | ⚠ Same — likely the existing mapping has next/prev swapped, OR our SpawnPK source has them swapped. Verify via runtime. |

The `Node.next/previous` conflict is interesting: SpawnPK and Impact disagree on which obf field is which, and one of them is wrong. The Copilot's runtime observation is the right tool to break the tie — observe a known linked-list traversal and see which field actually points forward.
