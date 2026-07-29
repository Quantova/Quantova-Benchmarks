#!/usr/bin/env bash
# Quantova execution throughput, reproduce it on your own machine.
#
# Clones the public node repo if it is not already here, builds in release, and runs the
# three execution harnesses. Each one checks the parallel executor against the sequential
# state root before it reports a number, so a wrong build cannot produce a flattering
# figure. Requires Rust (install from https://rustup.rs) and git.
#
# Usage:  bash bench.sh
set -euo pipefail

REPO="${QUANTOVA_CHAIN_DIR:-Quantova-Chain}"
if [ ! -d "$REPO" ]; then
  echo "cloning Quantova-Chain ..."
  git clone https://github.com/Quantova/Quantova-Chain.git "$REPO"
fi
cd "$REPO"

echo
echo "=============================================================="
echo " 1/3  sustained execution throughput, held constant for 20s"
echo "=============================================================="
cargo run --release --example sustained_tps -p qtv-node -- 100000 20

echo
echo "=============================================================="
echo " 2/3  independent and contended workloads, plus the VM alone"
echo "=============================================================="
cargo run --release --example parallel_bench -p qtv-node

echo
echo "=============================================================="
echo " 3/3  signature verification throughput"
echo "=============================================================="
cargo run --release --example verify_bench -p qtv-node

echo
echo "Done. On modern hardware you should see full block execution above the 25000 tx/s"
echo "target on both the independent and the contended workload, parallel verify well above"
echo "target, and the virtual machine far above it. Your absolute numbers depend on your CPU."
