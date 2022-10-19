#!/bin/bash

if [ -z $1 ]; then
  echo 'Pass the link to "View raw logs"'
  exit
fi

# { curl $1 \
#   -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:105.0) Gecko/20100101 Firefox/105.0' \
#   -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' \
#   -H 'Accept-Language: en-US,en;q=0.5' \
#   -H 'Accept-Encoding: gzip, deflate, br' \
#   -H 'Referer: https://github.com/EdmodoWorld/web-app/actions/runs/3233979104' \
#   -H 'Connection: keep-alive' \
#   -H 'Cookie: logged_in=yes; _ga=GA1.2.2004647568.1595495136; user_session=pIfxNvvILgkQeRnNDjQRnAkq0f-KBdKPkTACGfOiVrPafQCv; __Host-user_session_same_site=pIfxNvvILgkQeRnNDjQRnAkq0f-KBdKPkTACGfOiVrPafQCv; dotcom_user=roney-nd; _octo=GH1.1.1540121932.1660144039; _device_id=6f75f62ffd571dd698a0a673d61312f2; tz=Asia%2FShanghai; color_mode=%7B%22color_mode%22%3A%22auto%22%2C%22light_theme%22%3A%7B%22name%22%3A%22light%22%2C%22color_mode%22%3A%22light%22%7D%2C%22dark_theme%22%3A%7B%22name%22%3A%22dark%22%2C%22color_mode%22%3A%22dark%22%7D%7D; preferred_color_mode=dark; tz=Asia%2FShanghai; _gh_sess=UHSVVW5%2B%2FO7C4Oos0bsUsmNGGSVhkiC6ZvTu9KFucnRgAV%2FhF0n2POvV%2BPQ%2F%2FAt9v5UEftLnyH98SE6v6xk8jSoojSXupwn5oXbWaE%2FvoLQ1%2Fzg%2FE4buDO3VyDmBS4c46%2BQCoSFdcLhpBlrlcsBLfGhs8vmddoXmkaemvPJHv043wHG5MTQxy2V7oYaVJjQET5Bk8ZWPJBczsm5Wl0FuUTr2YaixQvRORv7uN5jifMx7uIWTuEeyy5hSo18YqNmNR7hXPeZ5rK%2FDMCxXeI4uk6EJuSyFpGyCVtlFQWGkNDfxPylRcUGEKU55siIO8ZeSVFuINsGW25mSFEBAeojU3JQmXaMzGJSn5mz%2F9mNOMLaOVc3ko8HV6CO7jnrxv0Lot5NnS5RtFPzIgrR%2BN2aGmnXQxQxcESn5v56q7tRPlTfjxzsBs4S6PmOFGMwG5IlNrd4y0QivY9MH1WKIPUVa6EDeWVfqwKaxxwVb4jSAwH30eBC0PJ8ktchJJ3wTTq2oqg9PCYw7py4%2Be11TEOdgCpmEMryukfhGajAgv3GtYWcQAcpoUrWXFJK%2Fv6wWsXM6RDH5dY485IsDVg2cB2XeCsHgwcmm2o7SdtKbwXgNGhnvQA7%2FJl3I2PU69eTCYaoo5hErNwf6AFl3rP9ei3%2B0XoZAEI%2BK%2FifuU73s5InQlKXR%2BMpYQlvnD4IlPDhBHhFG8PkGsyW%2FKLDlZeojeRjbsql5f74%3D--7z45ztans%2FcQAdU7--tsu1yIBk1Q9VsUfDb61y%2Fw%3D%3D; has_recent_activity=1' \
#   -H 'Upgrade-Insecure-Requests: 1' \
#   -H 'Sec-Fetch-Dest: document' \
#   -H 'Sec-Fetch-Mode: navigate' \
#   -H 'Sec-Fetch-Site: same-origin' \
#   --compressed -L -x socks://$(hostname).local:8888; \
#   echo; \
# } | sed -E -n '/Summary of all failing tests/,${
#   s/^[^[:space:]]+ (.+)/\1/mg
#   s/\r//g
#   p
# }' > last_ut.log

# non-snapshots
sed -E -n \
  -e '1{x;s/^/0/;x}' \
  -e '{
    /\bFAIL\b/{
      :read
      N
      /\n[[:space:]]{2}●/{ # spec header
        s/^\n+//
        H; s/.+// # save and clear
        x
        s/([[:digit:]]+)(.*)/echo "$((\1+1))\2"/e # increase count 
        x
        b read
      }
      /\n.+\bFAIL\b/{ # another FAIL found, save previous and clear
        s/^\n+//
        H
        s/.+//
        b read
      }
      /\nPost job cleanup/{ # output and quit when end
        s/^\n+//
        H
        x
        s/([[:digit:]]+)\n(.*)/\2\n======= Failed spec count: \1 =======/p
        q
      }
      /\n {6}at Object\.toMatchSnapshot.+/{
        s/.+// # clear snapshot spec
        x
=;p
        s/([[:digit:]]+)(.*)/echo "$((\1-1))\2"/e # decrease count
        s/(.+)\n.+$/\1/ # remove this header
        x
      }
      b read
    }
  }' last_ut.log

files=`sed -E -n '/\bFAIL\b/{s/^FAIL ([^()]+)( \(.+\))?$/\1/p}' last_ut.log`

echo
echo "======= Failed files count $(echo "$files" | wc -l) ======="
echo "$files"
echo
echo npm test -- -u $files
echo

sed -E -n '/Test Suites: /{N;N;p}' last_ut.log

#echo npm test -- -u $files
