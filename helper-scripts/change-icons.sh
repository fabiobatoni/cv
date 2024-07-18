#!/usr/bin/env bash
set -eou pipefail

cd `dirname $0`
for f in $(find . -type f \( -name '*.adoc' ! -name 'icons.*' \) | xargs grep -l 'icon:')
do
  sed -i 's,icon:\(.*\)\[\] ,{icon-\1},g' $f
done
