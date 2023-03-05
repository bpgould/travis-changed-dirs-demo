#!/bin/bash

base64 /dev/urandom | head -c 1000 > src/file.txt