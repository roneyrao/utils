const path = require('path');
const dependencyTree = require('dependency-tree');

const toSlash = path.sep !== '/'

const entry = process.argv[2]
let root = process.argv[3]
if (!entry || !root) {
  console.log('cli entry_file_path root_folder_path')
  process.exit()
}

root = path.resolve(root);
const rootLen = root.length + 1

const visited = {}
dependencyTree({
  filename: entry,
  directory: root,
  visited,
  filter: function(depPath, hostPath) { // bypass nested 3rd
    return hostPath.indexOf('node_modules') === -1
  }
})

const List3rd = new Set()
function parsePath(p) {
  let is3rd = p.indexOf('node_modules') !== -1
  if (!is3rd) {
    p = p.substr(rootLen)
  }
  if (toSlash) {
    p = p.replace(/\\/g, '/')
  }

  let prefix
  if (is3rd) {
    const m = p.match('(.+/node_modules/(@[^/]+/[^/]+|[^/]+)/).+')
    if (m) {
      prefix = m[1]
      p = m[2]
      List3rd.add(p)
    } else {
      throw new Error('failed to parse package name for: ', p);
    }
    is3rd = true
  }

  return {name: p, is3rd, prefix}
}
// parse 3rd and shorten path
function parseMap(obj) {
  const o3rd = {}
  const oLocal = {}
  Object.entries(obj).forEach(([p, o]) => {
    const { name, is3rd, prefix } = parsePath(p)

    if (is3rd) {
      p = p.substr(prefix.length)
      if (toSlash) {
        p = p.replace(/\\/g, '/')
      }
      o3rd[name] = p
    } else {
      oLocal[name] = parseList(Object.keys(o))
    }
  })

  const result = {}
  Object.keys(o3rd).forEach(k => {
    result[k] = o3rd[k]
  })
  Object.keys(oLocal).forEach(k => {
    result[k] = oLocal[k]
  })

  return result
}

function parseList(list) {
  const o3rd = []
  const oLocal = []
  list.forEach((p) => {
    const { name, is3rd } = parsePath(p)

    if (is3rd) {
      o3rd.push(name)
    } else {
      oLocal.push(name)
    }
  })
  return o3rd.concat(oLocal)
}

const result = parseMap(visited)

const ls = Array.from(List3rd).sort()
console.log(ls)

const fs = require('fs')
fs.writeFileSync('deps.json', JSON.stringify(result, null, 2), 'utf8')
console.log('Full deps written to deps.json')
