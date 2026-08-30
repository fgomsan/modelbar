# Extraer este kit a `fgomsan/grok-bots`

El árbol listo para ser la **raíz** del repo propio está en la rama
`cursor/grok-bots-split-ff28` de ModelBar. No abras un PR de esa rama contra
`main` de ModelBar: sustituiría la app.

`https://github.com/fgomsan/grok-bots` ya existe (commit inicial con README).
Hay que **force-push** el kit encima de ese README.

## Opción A — un comando desde este árbol (recomendado)

En un Mac con `gh` o `git` autenticado como **fgomsan** y con write en
`grok-bots`:

```bash
# Desde ModelBar, con grok-bots/ anidado:
./grok-bots/scripts/publish.sh --force

# O desde un clone que ya es la raíz del kit:
./scripts/publish.sh --force
```

`--force` solo hace falta mientras `main` sea el README generado por GitHub
(SHA `2e4369a2a4182a0593021a411de8c10407aa5f6f`). El script lo detecta y
puede forzar solo ese placeholder; para cualquier otro `main`, exige `--force`
explícito.

Comprueba:

```bash
git ls-remote https://github.com/fgomsan/grok-bots.git HEAD
# en el repo: bots/ librarian, .grok/skills/, routines/, VERSION
```

## Opción B — clone de la rama split

```bash
git clone --branch cursor/grok-bots-split-ff28 --single-branch \
  https://github.com/fgomsan/modelbar.git grok-bots-kit
cd grok-bots-kit
git remote add grok-bots https://github.com/fgomsan/grok-bots.git
git push --force grok-bots cursor/grok-bots-split-ff28:main
```

## Opción C — dar acceso a Cursor

GitHub → Settings → Applications → **Cursor** → Repository access → añade
`fgomsan/grok-bots`. Un Cloud Agent podrá empujar sin `--force` una vez el
placeholder ya no esté.

## Qué no hacer

- No mezclar este kit en `main` de ModelBar como si fuera la app.
- No hacer PR de `cursor/grok-bots-split-ff28` hacia ModelBar `main`.
- No pegar tokens en `EXTRACT.md`, perfiles, skills ni routines.
