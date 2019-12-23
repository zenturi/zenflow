#!/bin/sh
rm -f ZenFlow.zip
zip -r ZenFlow.zip src *.hxml *.json *.md run.n
haxelib submit ZenFlow.zip $HAXELIB_PWD --always