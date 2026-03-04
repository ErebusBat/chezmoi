#!/usr/bin/env zsh
cd ~/.restic

./agent-kick local.restic.15m    -k 3600   #  3,600s = 1h
./agent-kick local.restic.daily  -k 28800  # 28,800s = 8h
./agent-kick local.restic.hourly -k 1800   #  1,800s = 30m
