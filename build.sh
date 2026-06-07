#!/bin/bash
# ─── Show — Build & Run ───
# cd /Users/lw/ai/show && bash build.sh

set -e
cd "$(dirname "$0")/ShowObjC"
bash build.sh
open -n "$(pwd)/Show.app"
echo "✅ Show.app launched"
