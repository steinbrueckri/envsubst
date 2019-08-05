#!/usr/bin/env sh
set -e

WORKDIR=/workdir

if [[ -z $1 ]] 
then
  echo "please provide filename in workdir"
  exit 1
fi

FILENAME=$1
PROCESSED_FILENAME=${2:-/processed/$FILENAME}

echo "Processing $WORKDIR/$FILENAME to $PROCESSED_FILENAME"
envsubst < $WORKDIR/$FILENAME > $PROCESSED_FILENAME