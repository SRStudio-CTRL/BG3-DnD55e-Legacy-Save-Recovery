# Community Validation Status

This page tracks independent community testing of the legacy-save recovery method.

**Feedback thread:** [Issue #1 — Community Testing & Feedback](https://github.com/SRStudio-CTRL/BG3-DnD55e-Legacy-Save-Recovery/issues/1)

> The method remains experimental. A PASS on one save/configuration does not prove universal compatibility.

## Current evidence

### Original investigation

| Character | Affected state | Donor | Recovery | Save/Reload | Normal level-up after recovery | Later respec open/cancel |
|---|---:|---:|---|---|---|---|
| Wyll | N6 | Wyll N6 | ✅ PASS | ✅ PASS | ✅ N6 → N7 | ✅ PASS |
| Gale | N6 | Gale N6 | ✅ PASS | Tested successfully during recovery work | Recovered successfully | Recovered successfully |
| Gale | N3 | Gale N6, first 3 entries | ✅ PASS | Tested successfully during recovery work | Recovered successfully | Recovered successfully |

Additional older Wyll/Gale saves were also recovered with the same principle during the original investigation.

These rows are **author testing**, not independent community validation.

## Independent community results

| Test | Character | Level | Act | DnD 5.5e | Other mods | Hardware | Result | Evidence |
|---|---|---:|---|---|---|---|---|---|
| — | — | — | — | — | — | — | Awaiting reports | [Submit feedback](https://github.com/SRStudio-CTRL/BG3-DnD55e-Legacy-Save-Recovery/issues/1) |

## Result definitions

- **✅ PASS** — recovery completes, save/reload works, and subsequent tested progression/respec behavior is normal.
- **⚠️ PARTIAL** — recovery completes or improves the save, but an anomaly remains or part of the validation sequence fails.
- **❌ FAIL** — recovery aborts, freezes, crashes, or does not restore progression behavior.
- **🟦 ABORTED SAFELY** — guard checks reject the operation before the recovery respec. This is useful diagnostic evidence and should still be reported.

## What we are looking for

Independent reports across different:

- Wyll/Gale levels
- Act 1 / Act 2 / Act 3 saves
- campaign ages
- DnD 5.5e versions
- BG3 / BG3SE versions
- mod lists and load orders
- single-player / multiplayer campaigns
- CPUs, GPUs, RAM and Windows configurations

Screenshots of the BG3SE console, Withers respec, errors and before/after behavior are welcome in Issue #1.

## Evidence policy

Results should not be upgraded to PASS merely because the OneShot prints `FIX READY`.

For a strong PASS, we prefer confirmation of:

1. first recovery respec confirmed at level 1;
2. character rebuilt normally;
3. new manual save created;
4. save reloaded successfully;
5. normal subsequent level-up tested where possible;
6. later Withers respec opened and cancelled normally.

Failures and partial results are as important as successes.

---

**Original investigation & recovery method: SRStudio-CTRL**
