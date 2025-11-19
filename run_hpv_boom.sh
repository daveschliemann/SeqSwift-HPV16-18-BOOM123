#!/usr/bin/env bash
set -euo pipefail

echo "=== SeqSwift HPV16+18 BOOM – automated CI verification ==="

mkdir -p Data output

echo "Downloading reference genomes..."
curl -L -o Data/hpv16.fasta "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=NC_001526.4&rettype=fasta"
curl -L -o Data/hpv18.fasta "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=NC_001357.1&rettype=fasta"

echo "Building binary references..."
python3 - <<PY
import struct
for name in ['hpv16', 'hpv18']:
    seq = ''.join(l.strip() for l in open(f'Data/{name}.fasta') if not l.startswith('>')).upper()
    with open(f'{name}_ref.bin', 'wb') as f:
        f.write(struct.pack('<I', len(seq)))
        for b in seq:
            f.write(struct.pack('B', {'A':0,'C':1,'G':2,'T':3}.get(b,4)))
    print(f'Built {name}_ref.bin: {len(seq)} bp')
PY

echo "Running SeqSwift BOOM..."
time python3 seqswift_processor.py --input Data --ref hpv16_ref.bin,hpv18_ref.bin --output output/hpv_boom_run.txt

cat output/hpv_boom_run.txt
echo "BOOM verified on $(date)"
