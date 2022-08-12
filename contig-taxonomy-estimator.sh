# taxonomy-of-circular-contigs.sh
#!/bin/bash

# This script will estimate the taxonomy of a given contig

# Define list of arguments expected in the input
optstring=":c:t:"

while getopts ${optstring} arg; do
  case "${arg}" in
    c) CONTIG=${OPTARG};;
    t) THREADS=${OPTARG};;

    ?)
      echo "Invalid option: -${OPTARG}."
      echo
      usage
      ;;
  esac
done

echo ""
echo "The contig is: " $CONTIG
echo ""
echo "The number of threads used is: " $THREADS
echo ""
IDLIST_FILE="${CONTIG}.txt"
echo "The contig list file will be called: " $IDLIST_FILE
echo ""
CONTIG_FASTA_FILE="${CONTIG}.fa"
echo "The contigs fasta file will be called: " $CONTIG_FASTA_FILE
echo ""
CONTIGS_DATABASE="${CONTIG}.contigs.db"
echo "The contigs database will be called: " $CONTIGS_DATABASE
echo ""
CONTIGS_NAME="${CONTIG}_contigs_db"
echo "The contigs database name will be: " $CONTIGS_NAME
echo ""
TRNA_FILE="${CONTIG}-trnas.txt"
echo "The tRNA taxonomy file will be called: " $TRNA_FILE


echo $CONTIG > ${CONTIG}.txt

/usr/local/devel/BCIS/assembly/tools/extractFasta -i assembly.fasta -idlist $IDLIST_FILE -o $CONTIG_FASTA_FILE

anvi-gen-contigs-database -f ${CONTIG_FASTA_FILE}_1.fasta -o $CONTIGS_DATABASE -n $CONTIGS_NAME -T $THREADS

anvi-scan-trnas -c $CONTIGS_DATABASE -T $THREADS

anvi-run-trna-taxonomy -c $CONTIGS_DATABASE -T $THREADS -P $THREADS

anvi-estimate-trna-taxonomy -c $CONTIGS_DATABASE -o $TRNA_FILE
