# Contributing

## Branches

- `main` — stable milestones
- `develop` — active integration
- `feature/<topic>` — focused implementation work
- `verification/<topic>` — verification work
- `pd/<topic>` — physical-design work

## Commit style

Use concise, engineering-focused commits:

- `rtl: add register file`
- `rtl: implement branch unit`
- `uvm: add load-store sequence`
- `sva: add x0 invariant`
- `sim: add Questa regression script`
- `pd: add Sky130 floorplan configuration`
- `docs: update architecture`

## Pull requests

Each PR should have:

1. a clear objective
2. tests run
3. expected vs. actual behavior
4. coverage/assertion impact when applicable
5. synthesis or timing impact when applicable

Do not merge code that introduces unexplained assertion failures or breaks the reproducible regression.
