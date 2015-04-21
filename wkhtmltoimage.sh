#!/bin/sh
xvfb-run -a /usr/bin/wkhtmltoimage "$@"