const path = require('path');
const fs = require('fs');
const { once } = require('events');
const { createReadStream } = require('fs');
const { createInterface } = require('readline');

const listFile = process.argv[2]
let root = process.argv[3]
if (!listFile || !root) {
  console.log('cli list_relative_file_path root_folder_path')
  process.exit()
}

 /* * adfaf/ */
const REG_LEADING_IMPORT = /^import (\S+, +)?\{[^}]*$/
const REG_ENDING_IMPORT = /^[^}]*\} +from +[^}]+$/
const REG_LEADING_COMMENT = /^\s*\/\*.*$/
const REG_ENDING_COMMENT = /^.*\*\/\s*$/
const REG_IMPORT = /^import (?:.* from )?(['"])([^'"]+)\1;?\s*$/
const REG_REQUIRE = /^.*(?:=\s*)?require\((['"])([^'"]+)\1\);?\s*$/
const REG_COMMENT = /^\s*(\/\/.*)|(\/\*.*\*\/)\s*$/

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
  let multiline, multicomment

  function matchLine(line) {
    const m = line.match(REG_IMPORT) || line.match(REG_REQUIRE)
    if (m) {
      let dep = m[2]
      if (!dep.startsWith('.')) { // skip local deps
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
    return m
  }

  function lineHandler(line, rl) {
    line = line.trim()

    if (!line) return

    if (multiline) {
      multiline += line
      if (REG_ENDING_IMPORT.test(line)) {
        matchLine(multiline)
        multiline = null
      }   
    } else if (multicomment) {
      if (REG_ENDING_COMMENT.test(line)) {
        multicomment = false
      }   
    } else if (!matchLine(line) && !REG_COMMENT.test(line)) {
      if (REG_LEADING_IMPORT.test(line)) {
        multiline = line
      } else if (REG_LEADING_COMMENT.test(line)) {
        multicomment = true
      } else {
        console.log('last line', line)
        rl.close()
        rl.removeAllListeners()
      }
    }
  }

  function onDone() {
    if (multiline || multicomment) {
      console.error('Failed to parse', filepath)
    }

    total -= 1
    if (!total) Resolve()
  }

  await processLineByLine(filepath, lineHandler, onDone)
}

/*
 * parse 3rd deps from files
 * whose relative path in the first argument
 * the second is their folder path
 */
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

/*
 * mapping out the parsed 3rd deps
 * in dependencies/devDependencies
 */
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

parseFileList()
// mapPackageJson()
