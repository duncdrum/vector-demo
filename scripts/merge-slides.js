const fs = require('fs')
const path = require('path')

const slidesDir = path.join(__dirname, '..', 'workshop-slides')
const out = path.join(slidesDir, 'workshop-slides.md')

const parts = [
  'marp-frontmatter.md',
  'w-01-title.md',
  'w-02-tasks.md'
].map((file) => fs.readFileSync(path.join(slidesDir, file), 'utf8'))

fs.writeFileSync(out, parts.join('\n'))
console.log('Merged workshop-slides/workshop-slides.md')
