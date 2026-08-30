# Extraer este kit a `fgomsan/grok-bots`

El kit versionado (raíz de repo, no un subdirectorio de ModelBar) se publica
como el tag **`grok-bots-v<VERSION>`** en ModelBar. Ese tag apunta a un commit
donde `bots/`, `.grok/skills/` y `routines/` están en la raíz. No uses un tag
`v*` — eso dispara el release de la app ModelBar.

`https://github.com/fgomsan/grok-bots` ya existe (README de GitHub). Hay que
**force-push** el kit encima de ese commit.

## Opción A — tag versionado (recomendado)

En un Mac autenticado como **fgomsan** con write en `grok-bots`:

```bash
git clone --branch grok-bots-v0.1.0 --single-branch --depth 1 \
  https://github.com/fgomsan/modelbar.git grok-bots-kit
cd grok-bots-kit
git remote add grok-bots https://github.com/fgomsan/grok-bots.git
git push --force grok-bots HEAD:main
```

O, si ya tienes este árbol:

```bash
./grok-bots/scripts/publish.sh --force   # anidado en ModelBar
./scripts/publish.sh --force             # el kit ya es la raíz git
```

`--force` solo hace falta mientras `main` sea el README generado por GitHub
(SHA `2e4369a2a4182a0593021a411de8c10407aa5f6f`). `publish.sh` fuerza ese
placeholder automáticamente; cualquier otro `main` exige `--force` explícito.

Tarball: `./scripts/package.sh` → `grok-bots-<VERSION>.tar.gz` (también en el
GitHub Release del tag, con `Latest` sin tocar el de ModelBar).

Comprueba:

```bash
git ls-remote https://github.com/fgomsan/grok-bots.git HEAD
# en el repo: bots/librarian, .grok/skills/, routines/, VERSION
```

## Opción B — rama split

```bash
git clone --branch cursor/grok-bots-split-ff28 --single-branch \
  https://github.com/fgomsan/modelbar.git grok-bots-kit
cd grok-bots-kit
./scripts/publish.sh --force
```

No abras un PR de `cursor/grok-bots-split-ff28` contra `main` de ModelBar.

## Opción C — dar acceso a Cursor

GitHub → Settings → Applications → **Cursor** → Repository access → añade
`fgomsan/grok-bots`. Un Cloud Agent podrá empujar después.

## Qué no hacer

- No mezclar este kit en `main` de ModelBar como si fuera la app.
- No etiquetar el kit como `v0.1.0` en ModelBar (choca con el release de la app).
- No pegar tokens en perfiles, skills ni routines.
