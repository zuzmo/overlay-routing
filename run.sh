#!/bin/bash

if [[ -z $1 || -z $2 ]]; then
	echo "Invalid number of arguments."
	echo "Usage: bash run.sh config <node_name>"
else
	ruby node.rb "$1" "$2"
fi

