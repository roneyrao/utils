const path = require('path');
const fs = require('fs');
const { once } = require('events');
const { createReadStream } = require('fs');
const { createInterface } = require('readline');

const listFile = process.argv[2]
let root = process.argv[3]
if (!listFile || !root) {
  console.log('cli list_file_path root_folder_path')
  process.exit()
}


const REG_LEADING = /^import (\S+, +)?\{[^}]*$/
const REG_ENDING = /^[^}]*\} +from +[^}]+$/
const REG_SINGLE = /^import (?:.* from )?(['"])([^.'"][^'"]+)\1;?$/
//TODO
//require()
let Resolve
const Process = new Promise((res, rej) => {
  Resolve = res;
})
let total = 0

async function processLineByLine(inputfile, handler, cb) {
  try {
    const rl = createInterface({
      input: createReadStream(inputfile),
      crlfDelay: Infinity // contiguous as a single
    });

    rl.on('line', line => handler(line, rl))

    await once(rl, 'close');
    cb && cb()
    console.log('Processed', inputfile);
  } catch (err) {
    console.error(err);
  }
}


async function parseImports(filepath, set) {
  let leading

  function matchLine(line) {
    const m = line.match(REG_SINGLE)
    if (m) {
      let dep = m[2]
      const ix = dep.indexOf('/')
      if (ix > -1) {
        if (dep[0] === '@') {
          const ix2 = dep.indexOf('/', ix + 1)
          dep = dep.substring(0, ix2 === -1 ? undefined : ix2)
        } else {
          dep = dep.substr(0, ix)
        }
      }
      set.add(dep)
    }
  }

  function lineHandler(line, rl) {
    line = line.trim()

    if (!line) return

    if (line.startsWith('import')) {
      if (REG_LEADING.test(line)) {
        leading = line
      } else {
        matchLine(line)
      }
    } else if (leading) {
      leading += line
      if (REG_ENDING.test(line)) {
        matchLine(leading)
        leading = null
      }   
    } else if (!line.startsWith('//') && !line.startsWith('/*')) {
      rl.close()
      rl.removeAllListeners()
    }
  }

  function onDone() {
    if (leading) {
      console.error('Failed to parse', filepath)
    }

    total -= 1
    if (!total) Resolve()
  }

  await processLineByLine(filepath, lineHandler, onDone)
}

async function parseFileList() {
  const set = new Set()

  async function lineHandler(line, rl) {
    line = line.trim()
    if (!line) return
    total += 1
    await parseImports(path.resolve(root, line), set)
  }

  processLineByLine(listFile, lineHandler)

  await Process
  
  const str = JSON.stringify(Array.from(set), null, 2)
  console.log(str);
  fs.writeFileSync('deps.json', str, 'utf8')
  console.log('written in deps.json')
}

function mapPackageJson() {
  const rs = {}
  const list = require('./deps.json')
  const { dependencies, devDependencies } = require('../../ws/web-app-bk/package.json');
  [[dependencies, 'dependencies'], [devDependencies, 'devDependencies']].forEach(([deps, name]) => {
    console.log(name)
    rs[name] = {}
    const inside = rs[name]['inside'] = {}
    const out = rs[name]['outside'] = {}
    Object.entries(deps).forEach(([k, v]) => {
      const ix = list.indexOf(k)
      if (ix > -1) {
        inside[k] = v
        list.splice(ix, 1)
      } else {
        out[k] = v
      }
    })
    console.log('inside:', inside)
    console.log('out:', out)
  })
  rs.left = list
  console.log('left', list)
  const str = JSON.stringify(rs, null, 2)
  fs.writeFileSync('maps.json', str, 'utf8')
  console.log('written in maps.json')
}

// parseFileList()
mapPackageJson()
