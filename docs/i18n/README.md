# Documentación de Typst en español (es-AR, voseo)

Este fork agrega una traducción de la documentación oficial **sin modificar los
archivos de contenido upstream**, para que `git merge upstream/main` sea
(casi siempre) trivial. Todo lo no traducido cae al inglés.

```sh
cargo docit compile --format pdf --lang es-AR   # -> docs/dist/docs-es-AR.pdf
cargo docit compile --format pdf                # sin --lang: idéntico a upstream
```

El sitio web también se genera con la traducción (se publica en GitHub Pages):

```sh
cargo docit compile --format website --lang es-AR --release \
  --input base=/typst/ docs/i18n/es-AR/web.typ docs/dist/site-es-AR
# -> docs/dist/site-es-AR/typst/ (la ruta base `base` es parte de la salida)
```

`docs/i18n/es-AR/web.typ` es el punto de entrada propio del sitio: fija la ruta base
y agrega, en todas las páginas, el aviso de traducción no oficial (con enlace a
https://typst.app/docs) y un botón *Descargar el PDF* (en el aviso y en la barra
lateral) y un selector de tema (claro, oscuro o sistema; por defecto sigue al sistema,
sin tocar el CSS original). La paleta oscura está en `docs/i18n/es-AR/dark.css`:
redefine las variables y los colores fijos del CSS de upstream; si upstream agrega
colores nuevos, se ajusta ahí.

SEO: con `--input origin=https://host` el sitio agrega, en el `<head>` de cada
página (mediante la inserción `head` de `web.typ`, que upstream no usa), URL canónica,
`hreflang` hacia la página equivalente de typst.app/docs, Open Graph/Twitter Card
(con `social-card.png`), JSON-LD, precarga de las tipografías y un favicon; además
publica `sitemap.xml`, `robots.txt` y una página 404 en español. Las descripciones de
las páginas de funciones y tipos se arman con la primera frase traducida de su
documentación (`i18n-description` en `docs/src/i18n.rs`).

Revisión: la nota de la portada del PDF y la barra lateral de la web muestran el commit
(con enlace), su fecha, la última etiqueta (si el repositorio tiene alguna), la versión de
Typst del manifiesto y la fecha de compilación; todo sale de `git` y de `Cargo.toml` al
compilar (`stdx.revision`, en `docs/src/i18n.rs`). Los enlaces «código fuente» apuntan a
este repositorio en ese commit. El workflow clona con historial y etiquetas completos.

El favicon es un SVG hecho a mano (`brand/favicon.svg`, con el texto convertido a
trazados, porque usa una tipografía de pago). La miniatura social (`social-card.png`)
se genera con Typst a partir de `brand/social-card.typ` (con Reforma 1969); el comando
está en el encabezado del archivo.

El workflow `.github/workflows/docs-es-ar.yml` compila el PDF y el sitio en cada
push a `docs-translation` o a demanda (*Run workflow*), guarda el PDF como artifact
(`typst-docs-es-AR`) y despliega el sitio y el PDF (`/Documentación de Typst.pdf`) en GitHub
Pages. La ruta base es `/<repo>/`; con dominio propio, definí la variable de
repositorio `DOCS_BASE` (p. ej. `/`). Requiere *Settings → Pages → Source: GitHub
Actions* y permitir `docs-translation` en el entorno `github-pages`.

## Cómo funciona

| Fuente de texto | Mecanismo | Dónde vive la traducción |
| --- | --- | --- |
| `docs/content/**/*.typ`, `docs/components/preface.typ` | **Overlay de archivos**: con `--lang`, si existe `docs/i18n/<lang>/files/<ruta>`, se carga ese archivo en vez del original | `docs/i18n/es-AR/files/**` |
| Doc comments `///` de Rust | Hook en `live-docs` → `stdx.i18n-docs(path, key)` | `docs/i18n/es-AR/docs/<ruta .rs>.i18n` |
| Strings de UI de `docs/components/*.typ` | `stdx.ui("Definitions")` con fallback al inglés | `docs/i18n/es-AR/ui.toml` |
| Idioma del PDF | `set text(..stdx.text-lang)` (`lang: "es", region: "AR"`) | — |

Formato de los sidecars de doc comments (`src:` es el hash del markup inglés
original al traducir; así `status` detecta lo desactualizado):

```
@@ Array::first  [src:77a04e05]
Devuelve el primer ítem del array...
```

`state.json` guarda el hash de cada archivo fuente traducido. El changelog no
se traduce. Todo el código nuevo está en `docs/src/i18n.rs`, `docs/i18n/**`,
`tools/i18n/**` y `.github/workflows/docs-es-ar.yml`.

### Hooks en archivos upstream (todo el diff fuera de esas rutas)

`docs/src/args.rs` (flag `--lang`), `docs/src/main.rs` (`mod i18n`, campo
`lang`, ruta de salida, subcomando `i18n-dump`), `docs/src/world.rs` (init,
overlay en `load`/`resolve`, `stdx`), `docs/components/live.typ` (2 líneas),
`docs/components/styling.typ` (1 línea), `docs/components/category.typ`
(strings de UI → `stdx.ui(...)`). Cada hook es un commit propio, así que se
pueden revertir o rebasar por separado. Verificalo con:

```sh
git diff upstream/main --stat -- ':!docs/i18n' ':!tools/i18n' ':!docs/src/i18n.rs' ':!.github/workflows/docs-es-ar.yml'
```

## Flujo de sincronización con upstream

```sh
git remote add upstream https://github.com/typst/typst   # una sola vez
git fetch upstream
git merge upstream/main                                   # debería ser limpio
python3 tools/i18n status                                 # nuevo / desactualizado / huérfano
# traducir lo pendiente en una sesión de Claude Code (ver abajo); no hace falta API key
python3 tools/i18n check                                  # valida estructura
cargo docit compile --format pdf --lang es-AR
```

Comandos de `tools/i18n` (solo Python 3.11+, sin dependencias; los que leen
doc comments usan `cargo docit i18n-dump`, el mismo parser del build):

- `status [-v] [--no-docs]`: cuenta y lista unidades `new` / `outdated` / `orphan`.
- `check [--strict] [--no-docs]`: verifica que la traducción conserve bloques de
  código (y su cantidad), llamadas `#...`, `@refs`, `<labels>`, URLs, texto `raw`,
  balance de `[]`/`{}`, glosario y voseo. En la referencia los ejemplos deben
  quedar intactos; en el tutorial solo se admite traducir prosa de ejemplo.
- `export FILE` / `import [--force] FILE`: para doc comments de Rust, vuelcan las
  entradas pendientes de un `.rs` (con los bloques de código enmascarados) y
  vuelven a incorporar la traducción ya hecha.
- `translate [--only SUBSTR] [--limit N] [--dry-run]` (**opcional**, requiere una
  API key y no se usa en este fork): llama a la API de
  Anthropic (`ANTHROPIC_API_KEY`; modelo con `I18N_MODEL`) con temperatura baja,
  un lote por archivo, y reintenta una vez si `check` falla. Solo retraduce lo
  pendiente y actualiza hashes.
- `stamp PATH...`: marca como al día una traducción hecha a mano. Para una
  entrada de doc comment, usá `crates/.../archivo.rs::Clave`.

Reglas y glosario que recibe el traductor: `docs/i18n/es-AR/rules.md` y
`glossary.toml`.

### Traducir lo pendiente sin API key

Este fork se mantiene desde una sesión de Claude Code, sin API propia. Para
sincronizar, pedile a la sesión que haga: merge de `upstream/main`, `status`,
traducir cada unidad `new`/`outdated` siguiendo `rules.md` y `glossary.toml`
(archivos del overlay: editar la copia en `files/`; doc comments: `export` /
`import` o editar el `.i18n`), `stamp`, `check` y compilar con `--lang es-AR
--deny-warnings`.

### Resolver conflictos

Los hooks están separados del código upstream por líneas en blanco y son de una
o pocas líneas. Un merge real solo conflictúa si upstream modifica **esas mismas
líneas vecinas**; en ese caso, conservá ambos lados (el cambio upstream y la
línea `i18n::...`). Para archivos copiados en el overlay (p. ej.
`components/preface.typ`), `status` los marca `outdated` cuando cambia el
original: reaplicá la traducción sobre el archivo nuevo.

### Último merge real (2026-10-01)

Se fusionaron 6 commits de `upstream/main` (16 archivos: `crates/typst-pdf`,
`typst-library`, `typst-macros`, tests). Resultado:

- Merge **sin conflictos**: ninguno de esos commits tocó los archivos con hooks
  (`docs/src/**`, `docs/components/**`) ni `docs/content/**`.
- `status` detectó exactamente lo que cambió en la documentación: 2 entradas
  `outdated` (`TextElem::body` y `TextElem::text`, cuyos doc comments se
  ampliaron). Se retradujeron y se re-sellaron con `stamp`; el resto de las
  1472 entradas y los 29 archivos del overlay quedaron `ok`.
- La compilación sin `--lang` sigue siendo idéntica a upstream.

Riesgo residual: cada hook es una línea vecina a código upstream; si upstream
reformatea o edita esas líneas exactas habrá conflicto (se resuelve
conservando ambos lados, ver arriba).

### Probar una fusión sin riesgo

```sh
git checkout -b sync-test docs-translation
git merge upstream/main          # o una rama de prueba con cambios en doc comments
python3 tools/i18n status        # ¿marca lo modificado como outdated?
git checkout docs-translation && git branch -D sync-test
```

## Tipografías

Las fuentes están en `docs/i18n/es-AR/fonts/`, cada una en su carpeta tal como se
descarga (con su licencia): `Reforma/` (CC BY-ND 4.0, PampaType), `ChivoMono/` y
`IBMPlexMath/` (OFL). Se cargan solo con `--lang`, de forma recursiva; se omiten las
variantes duplicadas que vienen en las mismas descargas (carpetas `*webfont*`, `ttf`,
`woff`, `woff2`, `css`, `scss`, `__MACOSX` y los `*VariableFont*`). Los nombres se
cambian desde `ui.toml` (`"HK Grotesk" = "Reforma 2018"`, `"Cascadia Mono" = "Chivo
Mono"`, `"New Computer Modern Math" = "IBM Plex Math"`; los títulos usan Reforma
1918). `fonts/skip.txt` lista fragmentos de ruta de archivos que no se cargan (hoy, la
variante Blanca de Reforma, para que el peso regular use Gris). Si una fuente falta,
se usa la original sin warnings.

Para la web, `web.typ` publica los `.woff2` (Reforma, IBM Plex Math) y los `.ttf`
variables (Chivo Mono) de esas mismas carpetas y redefine las familias de los CSS
originales. Si cambiás las carpetas, actualizá las rutas de `web.typ`.

## Parches de líneas (`patches/`)

Para archivos upstream que cambian seguido (el changelog, `assets/docs.js`) no se
copia el archivo: `patches/<ruta>.toml` guarda pares `"línea original" = "línea
traducida"` que `docs/src/i18n.rs` aplica línea por línea (ignorando la sangría)
al archivo upstream. Si upstream agrega o cambia una línea, solo esa línea queda en
inglés. `python3 tools/i18n status` lista las líneas `new` (sin traducir) y las
claves `outdated` (que ya no coinciden con ninguna línea) de los parches.

## Textos sueltos (`ui.toml`)

`ui.toml` traduce, por coincidencia exacta con el texto en inglés, las etiquetas
de la interfaz y los textos de variantes/detalles que no salen de doc comments
(atributos de Rust, enums, módulos HTML/ARIA). Para listar lo que falta:
`I18N_MISSING=1 cargo docit compile --format pdf --lang es-AR 2>&1 | grep ^I18N_MISSING`.
Los nombres propios (estilos de citas, revistas) se dejan en inglés a propósito.

## Limitaciones conocidas

- En modo `watch`, los cambios en `ui.toml` y en los `.i18n` no recargan en
  caliente (los archivos del overlay sí).
- Los sidecars se usan aunque estén desactualizados (`status` avisa; no hay
  fallback automático al inglés por hash).
- El colofón (`files/components/preface.typ`) incluye un aviso visible de que
  la traducción **no es oficial**, hecha con IA (Claude Sonnet 5.5), con enlace a
  https://typst.app/docs. Hay que conservarlo al reaplicar el overlay.
- Sin traducir (cae al inglés): los ejemplos de código fuera del tutorial, los
  nombres propios (estilos de cita, revistas) y las etiquetas de interfaz sin hook.
- `check` marca un falso positivo conocido en `PdfFormat` (un span `raw` que
  cruza un salto de línea en el original).
