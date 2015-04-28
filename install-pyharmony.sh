#!/bin/bash

LIB=~/bin/lib
if [ ! -d $LIB ]; then
	mkdir -p $LIB;
	cd $LIB

	git clone https://github.com/petele/pyharmony

fi
