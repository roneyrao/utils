" list of "key: string of value" to following json
" to post for the jira table update

let template =<< END
{
  "type": "table",
  "attrs": {
    "isNumberColumnEnabled": false,
    "layout": "default",
    "localId": "f25ce09b-da8c-47ad-9019-38dba4e762c8"
  },
  "content": [{
    "type": "tableRow",
    "content": [{
      "type": "tableHeader",
      "attrs": {},
      "content": [{
        "type": "paragraph",
        "content": [{
          "type": "text",
          "text": "Project Name",
          "marks": [{
            "type": "strong"
          }]
        }]
      }]
    }, {
      "type": "tableHeader",
      "attrs": {},
      "content": [{
        "type": "paragraph",
        "content": [{
          "type": "text",
          "text": "String Key",
          "marks": [{
            "type": "strong"
          }]
        }]
      }]
    }, {
      "type": "tableHeader",
      "attrs": {},
      "content": [{
        "type": "paragraph",
        "content": [{
          "type": "text",
          "text": "Actual content",
          "marks": [{
            "type": "strong"
          }]
        }]
      }]
    }]
  }, {
    "type": "tableRow",
    "content": [{
      "type": "tableCell",
      "attrs": {},
      "content": [{
        "type": "paragraph",
        "content": [{
          "type": "text",
          "text": "web-app"
        }]
      }]
    }, {
      "type": "tableCell",
      "attrs": {},
      "content": [{
        "type": "paragraph",
        "content": [{
          "type": "text",
          "text": "current-account-number",
          "marks": [{
            "type": "code"
          }]
        }]
      }]
    }, {
      "type": "tableCell",
      "attrs": {},
      "content": [{
        "type": "paragraph",
        "content": [{
          "type": "text",
          "text": "Current account number",
          "marks": [{
            "type": "code"
          }]
        }]
      }]
    }]
  }]
}
END

norm G
let lines = line(".") - 1
put =template
silent! s/tableRow
norm GN[{hhv$%"rd

function! ProcessLine()
  norm ggdt:
  silent! s/tableRow
  norm GN[{%"rp
  silent! s/"text":
  norm GNNWwvi"p
  norm ggd2l
  silent! s/^"//
  silent! s/^['"]//
  silent! s/['"]$//
  silent! s/"/\\"/g
  norm 0d$"_dd
  silent! s/"text":
  norm GNWwvi"p
endfunction

for i in range(0, lines)
  call ProcessLine()
endfor
