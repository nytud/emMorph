#!/bin/bash
if [ "$hpldir" != "" ]; then export ROOT="$hpldir"; fi
if [ "$ROOT" == "" ]; then export ROOT=..; fi
export bsort="$ROOT"/pl/generic
export humlogdir="$ROOT"/gen/
