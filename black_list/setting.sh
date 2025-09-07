#!/bin/bash

# hostname is pc(pc is pc)

# Import functions
. ../util.sh
filter_hash _black-list.csv  black-list.csv        
g++ black-list.cpp -o black-list
sudo ./black-list
