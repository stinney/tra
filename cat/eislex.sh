#!/bin/sh
grep Liturgy ~/orc/qcat/00cat/qcat.tsv | cut -f1,5,14,22 >eisl-pre-ucsl.tsv
