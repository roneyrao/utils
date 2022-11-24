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
#   -H 'Cookie: logged_in=yes; user_session=pIfxNvvILgkQeRnNDjQRnAkq0f-KBdKPkTACGfOiVrPafQCv; __Host-user_session_same_site=pIfxNvvILgkQeRnNDjQRnAkq0f-KBdKPkTACGfOiVrPafQCv; dotcom_user=roney-nd; _octo=GH1.1.1540121932.1660144039; _device_id=6f75f62ffd571dd698a0a673d61312f2; tz=Asia%2FShanghai; color_mode=%7B%22color_mode%22%3A%22auto%22%2C%22light_theme%22%3A%7B%22name%22%3A%22light%22%2C%22color_mode%22%3A%22light%22%7D%2C%22dark_theme%22%3A%7B%22name%22%3A%22dark%22%2C%22color_mode%22%3A%22dark%22%7D%7D; preferred_color_mode=dark; tz=Asia%2FShanghai; _gh_sess=gxa4Fig1Kay4evJjfHLvi3%2BiPKg%2Bqp4lYWf47GVQAOtncDUjI4yDkmu79w1MS4k46DazV9fjkEprFyAwbbxEzePykZnRtqyJDHhOxUkXhYKNjV1lcMa7DXlseKb1Asioc8I%2FUBSZ%2Fm4KcxTzjgyudb5hMaT%2Fx4Rcdt1hZb5Vj4n7G3ja3p0R2b0b6daqUoT7%2BGuDTeCcyQVEAdS%2FITj1Oyqh1Odxxvf400jP2GnZS8%2FV3HBtFUFUFK0kHnS%2Fn8iLX5Ki3a%2BYhX5tyDJvbKVMsoLocDv9xf6bbGCxAh9WHj1FssbSUXUdS3tOkyxlFRycrkS%2Bf5Ay2d1%2FTt%2Fc6IPOvHYWq9cYAlBIeN4dfonO82jwbznfSsPMFAVvxPddTEcSMa2RZfEnnTcOSo93FOyHF%2BWzliqHz3Y4x1YL8kIIV6s7QEmY%2B438lt2IvI3PccJ3y7%2FrWCrQAxUUnxgxOa5jHASTeiB%2BKs%2FLPaPBGyPrvVb2h%2FqHzmp%2FrLV5viz4b13wSPETiQ68DVS3WrXKZXnVpnvXlFlXnhWjBD7Nb1%2FP1SEH51JZiinD%2BHRAx%2FYTRwuY%2FXQXl2lso3NzO%2FBvwUWYEWveqqkCAcxVfrrw02TU2lqJhK3Z0G4tdIc4vgFMWId3Jm3%2FBAgFmIeJjVq0zBk43hTENqqR3Vle2CcjAAeeLBzwgs0YZd3W2PIMPx3Q98s%2FwaP6ECTSNHWNDlr88aPfByni%2B0g8tSdVMuzdHJD68pzREGmOWmi8UA4PNrnRBXBEdxB4sjBeecCmp5GYMDyOvWMk68xjkiqVZN4dk1HAkZZMxxT1yNOHsj%2F4BkM3SgGyrvqZJA1kzh9oBieD4Iktqbl8O7I3DLO6n%2BhT0BoA4qqLqnQ4T5qTKBYJiiaqLmS01oxVMKcTf9LLapnTTI1DMXytFfEFQGEUYvU4GIM%2FclD1DdUmCF1HGMUSCp7hs%2B2QL%2F%2BcqoiR9gZnk4PjnS8SYwy6HlIFq%2BumaC274ZDgeVYoYyFV0QVBsaa%2BykcyP5YOHf%2F1OK%2FC%2B8W2rLcqifiqwU%2FPrOLtRkp8uHnbAg%3D%3D--gGNVZRurVkw5Cv4o--mNpi2dP17Sc3vtgR8W%2B%2F9g%3D%3D; has_recent_activity=1' \
#   -H 'Upgrade-Insecure-Requests: 1' \
#   -H 'Sec-Fetch-Dest: document' \
#   -H 'Sec-Fetch-Mode: navigate' \
#   -H 'Sec-Fetch-Site: same-origin' \
#   --compressed -L \
#   -x socks5://$(hostname).local:8888; \
#   echo; \
# } | sed -E -n '/Summary of all failing tests/,${
#   s/^[^[:space:]]+ (.+)/\1/mg
#   s/\r//g
#   p
# }' > last_ut.log

# non-snapshots
NORM='\n==NORMALS=='
SNAP='\n==SNAPSHOTS=='
FINAL="
h
s/^([^\n]+)(.*)($NORM).+$/\2/
s/\n/ /g
s/.*/npm test -- -u &/
x
s/^([[:digit:]]+),([[:digit:]]+),([[:digit:]]+),([[:digit:]]+)(.*)($NORM)(.*)($SNAP)(.*)$/\
======= Failed Non-Snapshot Specs =======\n\
\9\n\n\
======= Failed Snapshots count [\2], files [\4] =======\n\
Files only contain snapshots:\n\
npm test -- -u --watchAll=false \7\n\
\n\
======= Failed Non-Snapshot Specs count [\1], files [\3] =======\n\
\5\n/
G
p
"
function GET_PREVIOUS_SPEC_HANDLER() { echo "
# snapshots, just count
/\n {4}expect\(received\)\.toMatchSnapshot\(\)\n/{
  x
  s/^([[:digit:]]+,)([[:digit:]]+)(.*)/echo \'\1\'\$((\2+1))\'\3\'/e # increase count
  x
  b spec_skip_normal_$1
}

# normal, save all before this line
H
x
s/^([[:digit:]]+)(.+)/echo \$((\1+1))\'\2\'/e # increase count
s/(.+\n)[^\n]+/\1/ # remove current line
x

:spec_skip_normal_$1
s/.+\n([^\n]+)/\1/ # clear previous
";}
function GET_PREVIOUS_FILE_HANDLER() { echo "
x
# Snapshots when 'FAIL ...' is the last line
/^(([[:digit:]]+,){3})([[:digit:]]+)(.+)($SNAP)(.*\n)(FAIL )([^(\n]+)( \([^\n]+\))?$/{
  s//echo \'\1\'\$((\3+1))\'\4 \8\5\6\7\8\9\'/e;
  b file_skip_normal_$1
}
# or it's normal
s/^(([[:digit:]]+,){2})([[:digit:]]+)(.+)($NORM.*)(\nFAIL )([^(\n]+)( \([^\n]+\))?(\n.+$)/echo \'\1\'\$((\3+1))\'\4\n\7\5\6\7\8\9\'/e;
:file_skip_normal_$1
G
";}

sed -E -n \
  -e "1{x;s/^/0,0,0,0$NORM$SNAP/;x}" \
  -e "{
    /\bFAIL /{
      s/^\n+//; # clear empty lines
      H;
      s/.*//

      :read
      N
      /.+\n {2}●/{ # next spec
        $(GET_PREVIOUS_SPEC_HANDLER spec)
        b read
      }
      /\nFAIL /{ # another FAIL found, increase file number and append
        $(GET_PREVIOUS_SPEC_HANDLER file)
        $(GET_PREVIOUS_FILE_HANDLER file)
        x
        s/.+//
        b read
      }
      /\nPost job cleanup/{ # output and quit when end
        $(GET_PREVIOUS_SPEC_HANDLER clean)
        $(GET_PREVIOUS_FILE_HANDLER clean)
        $FINAL
        q
      }
      b read
    }
  }" last_ut.log
#| tee -a last_ut.log
  # }" last_ut.log  | tee >(
  #   cmd=$(sed -n '/Files only contain snapshots:/{n;p}')
  #   eval "$cmd&"
  # )

