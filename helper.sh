#!/bin/bash

if [ $# != 1 ] ; then 
    echo "USAGE: $0 COMMAND" 
    echo " e.g.: $0 redis-server" 
    exit 1; 
fi 

PID_LIST=`pgrep $1`

if [ -z "$PID_LIST" ]
then
    echo "err: $1 not found"
    exit 1
fi

trap "" 2

echo "step 1: Perf record, Hit Ctrl-C to end"
for PID in $PID_LIST
do
    echo "pid: "$PID
    perf record -e cpu-clock -g -p $PID --all-user
    break
done

echo "step 2: Perf script"
if [ ! -f "perf.data" ]; then  
    echo "err: perf.data is not found"
    exit 1  
fi
perf script -i perf.data &> perf.unfold
rm -f perf.data

echo "step 3: stackcollapse-perf.pl"
wget https://raw.githubusercontent.com/brendangregg/FlameGraph/master/stackcollapse-perf.pl 2> /dev/null
chmod +x stackcollapse-perf.pl
./stackcollapse-perf.pl perf.unfold &> perf.folded
rm -f stackcollapse-perf.pl perf.unfold

echo "step 4: flamegraph.pl"
wget https://raw.githubusercontent.com/brendangregg/FlameGraph/master/flamegraph.pl 2> /dev/null
chmod +x flamegraph.pl
./flamegraph.pl perf.folded > perf.svg
rm -f flamegraph.pl perf.folded

echo "result: perf.svg"
