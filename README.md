# Quantova throughput

A reproducible measurement of the Quantova node's execution throughput. Everything it builds
is public, and every figure is checked against the sequential state root before it is trusted.
One command clones the stack, builds it, and prints these numbers on your own machine.

## Verify it yourself

Install Rust from https://rustup.rs and have git available, then run

```
bash bench.sh
```

It clones the public node repo, builds in release, and runs the three harnesses. Each checks
its parallel result against the sequential state root before it prints, so a wrong build cannot
produce a flattering number. The first build compiles the whole stack and takes a few minutes.

## What holds

The node holds around 44,000 transfers a second, with a floor of 41,000 that stays flat across
a twenty second run. Each transfer runs the full block path, a module lattice signature verify,
a virtual machine transfer, and an account write back.

The throughput survives contention. With a third of the transfers colliding on a small set of
hot accounts it stays at 47,000 a second, against 47,700 on a fully independent workload, so the
parallelism is real and not the product of a workload chosen to spread cleanly. At half the cores
it still clears 36,500, past the 25,000 target.

The ceiling is serial state access, not the cryptography and not the compute. Parallel signature
verification runs at 70,000 a second and the virtual machine on its own at 1,380,000, both far
above the transfer figure. What is left serial is the sparse Merkle state, read to build each
transfer and written back in block order, and that is where the remaining headroom lives.

## The figures

Measured on an Apple M4, ten cores, four performance and six efficiency, 16 GB, release build.

Full block execution, signature verify plus virtual machine transfer plus account write back.

| workload | sequential | parallel | speedup |
| --- | --- | --- | --- |
| independent | 21,696 | 47,712 | 2.20x |
| a third contended | 21,954 | 47,021 | 2.14x |
| independent, half the cores | | 36,469 | |

Sustained over twenty seconds, floor 41,431, median 44,085, peak 45,894 a second.

Signature verification, 12,327 on one core and 70,039 across ten.

Virtual machine transfer alone, 215,672 on one core and 1,381,895 across ten.

## What is measured and what is not

These are execution figures, the node's compute path. Finalised throughput end to end, once
consensus, the network, attestation aggregation, and finality are folded in, is measured by the
qtv-live and qtv-widearea harnesses in the same node repo and is the figure a published claim
should rest on. Absolute numbers track the core count of the machine, the shape holds across
hardware.
