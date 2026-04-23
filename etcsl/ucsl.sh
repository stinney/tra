#!/bin/sh
(cd t ; for a in *.atf ; do mv $a `/bin/echo -n $a | cut -d= -f1`.tra ; done )
rm -f ${ORACC}/ucsl/etcsl/00atf/*
for a in 00atf/*.atf ; do
    Q=`/bin/echo -n $a | cut -d/ -f2 | cut -d. -f1`
    tra=t/$Q.tra
    ucsl="$ORACC/ucsl/etcsl/00atf/$Q.atf"
    if [ -r $tra ]; then
	cat $a @tra-line $tra >$ucsl
    else
	cp $a $ucsl
    fi
done
