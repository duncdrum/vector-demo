# Workshop: Semantic Search with eXist-db 7

**XML Prague 2026.06.04 eXist-db Users Meetup and Workshop**

Hands-on exercises with vector KNN, embedding, and Lucene 10 in eXist-db 7.

- **Live site:** https://duncdrum.github.io/vector-demo/
- **Slides:** https://duncdrum.github.io/vector-demo/slides/

## Quick start

**Prerequisites:** Docker and a browser.

**Image:** `duncdrum/existdb:experimental`

```bash
docker run -d --name exist-semantic \
    -p 8080:8080 -p 8443:8443 \
    duncdrum/existdb:experimental
```

Open **eXide** at http://localhost:8080/exist/apps/eXide/index.html

## Workshop tasks

| # | Task | Est. time |
|---|------|-----------|
| 1 | [Set up a collection with vector index](workshop/task-01-setup.md) | 5 min |
| 2 | [Basic KNN search](workshop/task-02-basic-search.md) | 5 min |
| 3 | [Different similarity functions](workshop/task-03-similarity.md) | 5 min |
| 4 | [Filters and facets](workshop/task-04-filters.md) | 5 min |
| 5 | [Embedding and end-to-end search](workshop/task-05-embedding.md) | 10 min |
| 6 | [Reindex lifecycle](workshop/task-06-reindex.md) | 5 min |
| 7 | [Advanced edge cases](workshop/task-07-advanced.md) | 5 min |

Run each XQuery in eXide. [Solutions](workshop/solutions/) are included for self-paced use.

See [workshop/README.md](workshop/README.md) for tips and module imports.

## Slides

Source lives in [`workshop-slides/`](workshop-slides/):

- [`marp-frontmatter.md`](workshop-slides/marp-frontmatter.md) — Marp theme and styles
- [`w-01-title.md`](workshop-slides/w-01-title.md) — title, prerequisites, tips
- [`w-02-tasks.md`](workshop-slides/w-02-tasks.md) — task slides

Edit the fragments, then merge and build:

```bash
npm install
npm run slides:merge   # writes workshop-slides/workshop-slides.md
npm run build          # site + slides → _site/
npm run slides:preview # local preview server
```

The workshop command used at XML Prague:

```bash
npx @marp-team/marp-cli@latest --html --allow-local-files workshop-slides/workshop-slides.md -o workshop-slides/workshop-slides.html
```

## GitHub Pages

Pushes to `main` build the static site via [`.github/workflows/pages.yml`](.github/workflows/pages.yml) and deploy to GitHub Pages.

Enable once: repo **Settings → Pages → Source: GitHub Actions**.

## License

[Creative Commons Attribution 4.0 International (CC BY 4.0)](LICENSE)
