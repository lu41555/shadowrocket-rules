#!/bin/sh

failures=0

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  failures=$((failures + 1))
}

count_exact() {
  awk -v expected="$2" '$0 == expected { count++ } END { print count + 0 }' "$1"
}

line_exact() {
  awk -v expected="$2" '$0 == expected { print NR; exit }' "$1"
}

assert_count() {
  actual=$(count_exact "$1" "$2")
  [ "$actual" -eq "$3" ] || fail "$1: expected $3 occurrence(s) of '$2', found $actual"
}

full='shadowrocket-cn-direct-overseas-proxy.conf'
simple='shadowrocket-cn-direct-overseas-proxy-simple.conf'
basic='youtube-adblock-basic.sgmodule'
mitm='youtube-adblock-mitm-v2.sgmodule'

for file in "$full" "$simple"; do
  assert_count "$file" 'IP-CIDR,100.100.100.100/32,DIRECT,no-resolve' 1
  assert_count "$file" 'IP-CIDR,100.64.0.0/10,DIRECT,no-resolve' 1
  assert_count "$file" 'IP-CIDR,100.0.0.0/8,PROXY,no-resolve' 1
  assert_count "$file" 'DOMAIN-SUFFIX,tailscale.com,DIRECT' 1
  assert_count "$file" 'DOMAIN-SUFFIX,tailscale.io,DIRECT' 1
  assert_count "$file" 'DOMAIN-SUFFIX,ts.net,DIRECT' 1
  assert_count "$file" 'DOMAIN-SUFFIX,tailscale.com,PROXY' 0
  assert_count "$file" 'DOMAIN-SUFFIX,tailscale.io,PROXY' 0
  assert_count "$file" 'DOMAIN-SUFFIX,ts.net,PROXY' 0

  quad_line=$(line_exact "$file" 'IP-CIDR,100.100.100.100/32,DIRECT,no-resolve')
  tailscale_line=$(line_exact "$file" 'IP-CIDR,100.64.0.0/10,DIRECT,no-resolve')
  range_line=$(line_exact "$file" 'IP-CIDR,100.0.0.0/8,PROXY,no-resolve')
  if [ -z "$quad_line" ] || [ -z "$tailscale_line" ] || [ -z "$range_line" ] ||
     [ "$quad_line" -ge "$range_line" ] || [ "$tailscale_line" -ge "$range_line" ]; then
    fail "$file: Tailscale DIRECT rules must appear before the 100/8 PROXY rule"
  fi

  if grep -Eq '^tun-excluded-routes = .*100\.(0\.0\.0/8|64\.0\.0/10|100\.100\.100/32)' "$file"; then
    fail "$file: Tailscale addresses must not be excluded from the tunnel"
  fi
done

if grep -Eq '^[^#].* = (url-test|fallback),' "$full"; then
  fail "$full: automatic proxy policy group found"
fi

awk '
  function is_same_or_child(child, parent, suffix) {
    if (child == parent) return 1
    suffix = "." parent
    return length(child) > length(suffix) && substr(child, length(child) - length(suffix) + 1) == suffix
  }
  BEGIN { in_rules = 0; bad = 0; seen_count = 0 }
  /^\[Rule\]$/ { in_rules = 1; next }
  in_rules && /^\[/ { in_rules = 0 }
  in_rules && /^DOMAIN-SUFFIX,/ {
    count = split($0, fields, ",")
    domain = fields[2]
    policy = fields[3]
    for (i = 1; i <= seen_count; i++) {
      if (is_same_or_child(domain, seen_domain[i]) && policy != seen_policy[i]) {
        print "FAIL: " FILENAME ": line " seen_line[i] " " seen_domain[i] " -> " seen_policy[i] \
          " shadows line " FNR " " domain " -> " policy > "/dev/stderr"
        bad = 1
      }
    }
    seen_count++
    seen_domain[seen_count] = domain
    seen_policy[seen_count] = policy
    seen_line[seen_count] = FNR
  }
  END { exit bad }
' "$full" || failures=$((failures + 1))

youtube_line=$(line_exact "$full" 'DOMAIN-SUFFIX,youtubei.googleapis.com,YouTube')
google_line=$(line_exact "$full" 'DOMAIN-SUFFIX,googleapis.com,Google')
if [ -z "$youtube_line" ] || [ -z "$google_line" ] || [ "$youtube_line" -ge "$google_line" ]; then
  fail "$full: youtubei.googleapis.com must appear before googleapis.com"
fi

awk '
  BEGIN {
    in_groups = 0
    in_rules = 0
    bad = 0
    builtins["DIRECT"] = 1
    builtins["REJECT"] = 1
    builtins["PROXY"] = 1
  }
  /^\[Proxy Group\]$/ { in_groups = 1; in_rules = 0; next }
  /^\[Rule\]$/ { in_groups = 0; in_rules = 1; next }
  /^\[/ { in_groups = 0; in_rules = 0 }
  in_groups && /^[^#].* = / {
    name = $0
    sub(/ = .*/, "", name)
    groups[name] = 1
  }
  in_rules && /^[^#]/ {
    count = split($0, fields, ",")
    policy = fields[count]
    if (policy == "no-resolve") policy = fields[count - 1]
    if (!(policy in builtins) && !(policy in groups)) {
      print "FAIL: unknown policy " policy " in " $0 > "/dev/stderr"
      bad = 1
    }
  }
  END { exit bad }
' "$full" || failures=$((failures + 1))

for forbidden in \
  'DOMAIN-SUFFIX,google-analytics.com,REJECT' \
  'DOMAIN-SUFFIX,play.google.com/log,REJECT' \
  'DOMAIN-SUFFIX,app-measurement.com,REJECT' \
  'DOMAIN-SUFFIX,firebaseinstallations.googleapis.com,REJECT' \
  'DOMAIN-SUFFIX,firebaselogging.googleapis.com,REJECT'; do
  if grep -Fqx "$forbidden" "$basic"; then
    fail "$basic: broad or invalid rule remains: $forbidden"
  fi
done

pinned_count=$(grep -Ec 'script-path=https://raw\.githubusercontent\.com/Maasea/sgmodule/[0-9a-f]{40}/Script/Youtube/youtube\.response\.js' "$mitm")
[ "$pinned_count" -eq 2 ] || fail "$mitm: expected two commit-pinned script URLs, found $pinned_count"

if grep -q 'Maasea/sgmodule/master/' "$mitm"; then
  fail "$mitm: mutable master script URL found"
fi

if [ "$failures" -ne 0 ]; then
  printf '%s rule check(s) failed.\n' "$failures" >&2
  exit 1
fi

printf 'All rule checks passed.\n'
