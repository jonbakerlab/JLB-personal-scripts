# cat jon-map-long.sh
#!/bin/bash

# This script will map nanopore long reads to a genome assembly and extract only the mapped reads to a .fastq file

# Define list of arguments expected in the input
optstring=":c:l:"

while getopts ${optstring} arg; do
  case "${arg}" in
    c) GENOME_FILE=${OPTARG};;
    l) LONG_READ_FILE=${OPTARG};;

    ?)
      echo "Invalid option: -${OPTARG}."
      echo
      usage
      ;;
  esac
done

echo ""
echo "The contigs file is: " $GENOME_FILE
echo ""
echo "The long-read file is: " $LONG_READ_FILE
echo ""
OUTPUT_SAM_FILE="${GENOME_FILE%.fa}.long-read.sam"
echo "The output SAM file will be called: " $OUTPUT_SAM_FILE
echo ""
BAM_INITIAL="${OUTPUT_SAM_FILE%.sam}.bam"
echo "The initial BAM file will be called: " $BAM_INITIAL
echo ""
BAM_SORTED="${BAM_INITIAL%.bam}.sorted.bam"
echo "The sorted BAM file will be called: " $BAM_SORTED
echo ""
MAPPED_LONG_READS=${BAM_SORTED%.sorted.bam}.mapped-long.fastq
echo "The mapped long reads file will be called: " $MAPPED_LONG_READS
echo ""

minimap2 \
    -ax map-ont \
    -t 18 \
    --sam-hit-only \
    $GENOME_FILE \
    $LONG_READ_FILE > $OUTPUT_SAM_FILE

echo -e "Finished minimap2 \n"

samtools view \
    -b \
    -@ 18 \
    $OUTPUT_SAM_FILE > $BAM_INITIAL

echo -e "Finished samtools view \n"

anvi-init-bam \
    $BAM_INITIAL \
    -o $BAM_SORTED \
    -T 18

echo -e "Finished anvi-init-bam \n"

samtools fastq \
    -F 4 \
    -@ 18 \
    $BAM_SORTED > $MAPPED_LONG_READS

echo -e "Finished samtools fastq \n"

echo "done"
