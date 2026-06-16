const fs = require('fs')
const path = require('path')

const siteSrc = path.join(__dirname, '..', 'site')
const siteOut = path.join(__dirname, '..', '_site')

fs.rmSync(siteOut, { recursive: true, force: true })
fs.mkdirSync(siteOut, { recursive: true })
fs.mkdirSync(path.join(siteOut, 'slides'), { recursive: true })

for (const file of fs.readdirSync(siteSrc)) {
  fs.copyFileSync(path.join(siteSrc, file), path.join(siteOut, file))
}

console.log('Copied site/ to _site/')
