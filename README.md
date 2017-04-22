# perf-practice
perf practice

## FlameGraph

### tools
```
git clone https://github.com/brendangregg/FlameGraph
```

### helper
```shell
#!/bin/bash

trap "killall -9 perf" 2

echo "step 1: Perf record, Hit Ctrl-C to end"
perf record -e cpu-clock -g -p `pgrep $1` --all-user

echo "step 2: Perf script"
perf script -i perf.data &> perf.unfold

echo "step 3: stackcollapse-perf.pl"
./stackcollapse-perf.pl perf.unfold &> perf.folded

echo "step 4: flamegraph.pl"
./flamegraph.pl perf.folded > perf.svg

```
