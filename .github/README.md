# Documentación de Typst en español rioplatense

> **Traducción no oficial.** Este repositorio es un *fork* de [typst/typst](https://github.com/typst/typst) cuyo único propósito es mantener una traducción de la **documentación** de Typst al español de Argentina (voseo). No es una publicación de Typst GmbH ni cuenta con su aval. Ante cualquier duda, prevalece la [documentación oficial en inglés](https://typst.app/docs).
>
> *This fork only maintains an unofficial Rioplatense Spanish translation of Typst's documentation. For Typst itself (the compiler, issues, releases), go to [typst/typst](https://github.com/typst/typst).*

## Leer la documentación

- 🌐 **Sitio web:** <https://jassielof.github.io/typst/>
- 📄 **PDF:** <https://jassielof.github.io/typst/docs-es-AR.pdf>
- 🇬🇧 **Documentación oficial:** <https://typst.app/docs>

Ambos se generan automáticamente con GitHub Actions en cada cambio de la rama `docs-translation` (la rama predeterminada de este repositorio).

## Qué hay (y qué no) en este repositorio

Este fork **no modifica Typst**: el compilador, la biblioteca y los archivos de contenido de la documentación son los de upstream. La traducción vive aparte, en [`docs/i18n/es-AR/`](../docs/i18n/README.md), y se aplica al compilar la documentación con `--lang es-AR`:

```sh
cargo docit compile --format pdf --lang es-AR      # docs/dist/docs-es-AR.pdf
cargo docit compile --format pdf                   # sin --lang: idéntico a upstream
```

Está traducido: el tutorial, la referencia, las guías, el registro de cambios, los comentarios de documentación del código y la interfaz del PDF y de la web. Lo que no está traducido cae al inglés. Los detalles (cómo funciona, cómo sincronizar con upstream, tipografías, parches, limitaciones) están en [`docs/i18n/README.md`](../docs/i18n/README.md).

## Sobre la traducción

- La traducción fue generada con inteligencia artificial (Claude Sonnet 5.5, de Anthropic), bajo la dirección y revisión de [Jassiel Ovando](https://github.com/jassielof), y puede contener errores o imprecisiones.
- Sigue un voseo consistente (*usá, podés, tenés*), las normas de la RAE y un vocabulario rioplatense técnico; el glosario y las reglas están en [`docs/i18n/es-AR/`](../docs/i18n/es-AR/).
- ¿Encontraste un error de traducción o de redacción? Abrí un *issue* o un *pull request* en este repositorio. Los errores de Typst o de la documentación original van en [typst/typst](https://github.com/typst/typst/issues).

## Licencias y créditos

- Typst y su documentación: © Laurenz Mädje, Martin Haug y The Typst Project Developers, bajo la [Apache License 2.0](../LICENSE).
- Traducción: se distribuye bajo los mismos términos que el contenido original.
- Tipografías (en `docs/i18n/es-AR/fonts/`, cada una con su licencia): [Reforma](https://www.pampatype.com/reforma) de PampaType / Universidad Nacional de Córdoba (CC BY-ND 4.0), [Chivo Mono](https://fonts.google.com/specimen/Chivo+Mono) e [IBM Plex Math](https://github.com/IBM/plex) (SIL OFL 1.1).
