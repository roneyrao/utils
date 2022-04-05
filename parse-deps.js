var dependencyTree = require('dependency-tree');
const tree = dependencyTree({
  filename: process.argv[2],
  directory: './src',
})

const s = new Set()
function parse(obj) {
  Object.entries(obj).forEach(([p, o]) => {
    if (p.indexOf('node_modules') !== -1) {
      p = p.replace(/\\/g, '/')
      const m = p.match('.+/node_modules/(@[^/]+/[^/]+|[^/]+)/.+')
      if (m) {
        s.add(m[1])
      }
    } else {
       parse(o)
    }
  })
}

parse(tree)

console.log(s)

const fs = require('fs')
fs.writeFileSync('deps.json', JSON.stringify(tree), 'utf8')
console.log('Full deps written to deps.json')
