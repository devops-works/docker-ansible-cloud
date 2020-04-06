#!/bin/bash

# [[ -t 0 ]] && echo 'Interactive' || echo 'Not interactive'
[[ -t 0 ]] && /bin/bash -l || /bin/bash -c "$@"
