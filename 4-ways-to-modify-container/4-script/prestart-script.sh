#!/usr/bin/env bash

set -x
echo '<h2>Page prepared by a script executed before entrypoint container</h2>' > /usr/share/nginx/html/index.html

exec /docker-entrypoint.sh