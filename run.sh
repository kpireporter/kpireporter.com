#!/usr/bin/env bash

DIR="$(cd "$(dirname ${BASH_SOURCE[0]})" >/dev/null && pwd)"
export JEKYLL_VERSION=4
export JEKYLL_ENV=${JEKYLL_ENV:-}

docker run -it --rm \
  --publish 127.0.0.1:4000:4000 \
  --volume="$DIR/site:/srv/jekyll" \
  --volume="kpireporter_com_gems:/usr/gem" \
  jekyll/jekyll:$JEKYLL_VERSION \
  "$@"
