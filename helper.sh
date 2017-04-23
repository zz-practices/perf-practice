#!/bin/bash

if [ $# != 1 ] ; then 
    echo "USAGE: $0 COMMAND" 
    echo " e.g.: $0 redis-server" 
    exit 1; 
fi 

trap "" 2

echo "step 1: Perf record, Hit Ctrl-C to end"
perf record -e cpu-clock -g -p `pgrep $1` --all-user

echo "step 2: Perf script"
perf script -i perf.data &> perf.unfold

echo "step 3: stackcollapse-perf.pl"
wget https://raw.githubusercontent.com/brendangregg/FlameGraph/master/stackcollapse-perf.pl 2> /dev/null
chmod +x stackcollapse-perf.pl
./stackcollapse-perf.pl perf.unfold &> perf.folded
rm -f stackcollapse-perf.pl

echo "step 4: flamegraph.pl"
wget https://raw.githubusercontent.com/brendangregg/FlameGraph/master/flamegraph.pl 2> /dev/null
chmod +x flamegraph.pl
./flamegraph.pl perf.folded > perf.svg
rm -f flamegraph.pl

echo "result: perf.svg"
