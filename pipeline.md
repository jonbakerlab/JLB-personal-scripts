# AnnoTree gene analysis to make Streptococcus protein trees

### Get protein sequences from AnnoTree

1. Go to <annotree.uwaterloo.ca> and launch the tool

2. Next to the search bar, click the arrow to the left and switch to Taxonomy, enter Streptococcus..should autocomplete to "Streptococcus (genus)", select that and click search

3. Click the farthest out node on the red leaf expand to "family" or "genus" after it expands, repeat expanding to "species" until you have only the 420 Streptococcus genomes in the tree

4. Switch the search bar back to annotation, add your KEGG KO or Pfam annotation number and search...tree will now highlight which Streptococcus species have that gene (for some it might be almost all)

5. Click the center node of the tree with the gene of interest highlighted, it will show the number of Streptococcus genomes that had hits. At the bottom click "Download All Sequences"

The table you get from that should be a CSV with `SearchId	geneId	gtdbId	sequence	tax` as the columns

### Check sequence lengths in the fasta file (from seqkit conda env)
`seqkit stats annotree_hits.faa`

### Run `table-to-faa.py` (will need to have pandas and argparse installed)
#### `python table-to-faa.py --input input.csv --output output.faa`

```py
import pandas as pd
import argparse
import sys

def main():
    parser = argparse.ArgumentParser(
        description="Convert a table of protein sequences to FASTA, "
                    "adding species name (from tax column) to FASTA headers."
    )

    parser.add_argument(
        "--input", "-i",
        required=True,
        help="Input table (CSV or TSV)"
    )

    parser.add_argument(
        "--output", "-o",
        required=True,
        help="Output FASTA file (.faa)"
    )

    parser.add_argument(
        "--gene-col",
        default="geneId",
        help="Column name for gene ID (default: geneId)"
    )

    parser.add_argument(
        "--seq-col",
        default="sequence",
        help="Column name for amino acid sequence (default: sequence)"
    )

    parser.add_argument(
        "--tax-col",
        default="tax",
        help="Column name for taxonomy string (default: tax)"
    )

    parser.add_argument(
        "--sep",
        default=",",
        help="Field separator: ',' for CSV, '\\t' for TSV (default: ',')"
    )

    args = parser.parse_args()

    # Load table
    try:
        df = pd.read_csv(args.input, sep=args.sep)
    except Exception as e:
        sys.exit(f"ERROR reading input file: {e}")

    # Check required columns
    for col in (args.gene_col, args.seq_col, args.tax_col):
        if col not in df.columns:
            sys.exit(f"ERROR: column '{col}' not found in table")

    written = 0

    with open(args.output, "w") as out:
        for _, row in df.iterrows():

            gene = str(row[args.gene_col]).strip()
            seq  = str(row[args.seq_col]).strip()
            tax  = str(row[args.tax_col]).strip()

            # Skip missing data
            if gene == "nan" or seq == "nan" or tax == "nan":
                continue

            # Extract species name (after final semicolon)
            species = tax.split(";")[-1]
            species = species.replace("s__", "").replace(" ", "_")

            header = f"{species}_{gene}"

            # Clean sequence
            seq = "".join(seq.split())

            out.write(f">{header}\n")
            for i in range(0, len(seq), 60):
                out.write(seq[i:i+60] + "\n")

            written += 1

    print(f"Wrote {written} protein sequences to {args.output}")

if __name__ == "__main__":
    main()
```

Muscle doesn't like the '*' as stop codons, remove stop codons with:
`sed 's/\*//g' fabKtest.faa > fabKtest.noStop.faa`


### Align with muscle (default Anvio aligner)
`muscle -in annotree_hits-4_fixed.faa -out annotree_hits-4_fixed-aligned.faa`

### Trim with trimal (default Anvio trimmer)
`trimal -in annotree_hits-4_fixed-aligned.faa -out annotree_hits-4_fixed-nogaps.faa -gt 0.5`

### Run iqtree
`iqtree -s annotree_hits-4_fixed-nogaps.faa -nt 12 -m WAG -bb 1000`

### View tree at Interactive Tree of Life (iToL) at <itol.embl.de>
Click "Upload" and drag your `iqtree-output.faa.contree`

