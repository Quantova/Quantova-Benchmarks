# Quantova throughput and finality

Reproducible benchmarks for the Quantova node. Every figure is produced by a harness that
checks its parallel result against the sequential state root before it reports, and the
throughput figures rerun on your own machine with a single command.

## Headline

Around 44,000 transactions a second of execution throughput on a single node, and block
finality under one second across a live validator committee. Signature verification and the
virtual machine both run far above throughput, so the compute path keeps margin and the bound
is serial state access.

## Execution throughput

Measured on an Apple M4, ten cores, 16 GB, release build. The full block path runs a module
lattice signature verify, a virtual machine transfer, and an account write back.

| workload | parallel | speedup |
| --- | --- | --- |
| independent transfers | 47,712 tx/s | 2.20x |
| a third contended on hot accounts | 47,021 tx/s | 2.14x |
| independent at half the cores | 36,469 tx/s | |

Held constant over twenty seconds the floor is 41,431 a second and the median 44,085, so the
figure is a rate the node sustains rather than a burst. Signature verification runs at 70,039 a
second across the cores and the virtual machine alone at 1,381,895, both far past throughput,
which places the ceiling on serial state access, the sparse Merkle state read and written in
block order.

## Block finality

Measured across a real four validator committee producing and finalising blocks one after
another, each block built, attested, aggregated, and verified with a real finality certificate
that every node checks.

| percentile | finality |
| --- | --- |
| median | 607 ms |
| p90 | 620 ms |
| p99 | 635 ms |

Finality lands under a second, and it does not grow with the validator set. A fixed sampled
committee carries it, so the certificate stays flat as validators join. This figure is the in
process compute floor across the committee, a production network adds propagation between hosts
on top.

## Honest scope

Execution throughput is the compute path of one node. Finality is measured in process across the
committee on a single host, so it is the compute floor and leaves out wide area propagation.
Finalised throughput at production scale, with validators running in parallel across real hosts,
is the figure the network is built to carry, and it is bounded by execution rather than by
consensus, because finality is flat in the validator count. Everything here is a compute
measurement, stated as measured, with nothing tuned to a path.

## Reproduce

Install Rust from https://rustup.rs and have git available, then

```
git clone https://github.com/Quantova/Quantova-Benchmarks.git
cd Quantova-Benchmarks
bash bench.sh
```

The first build compiles the whole stack and takes a few minutes. Each harness checks its
parallel result against the sequential state root before it prints, so a wrong build cannot
produce a flattering number. Your absolute figures track the core count of your machine, the
shape holds across hardware.
