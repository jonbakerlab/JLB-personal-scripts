# cat jon-map-short.sh
#!/bin/bash

# This script will map short reads to a given genome assembly and then extract only the mapped reads

# Define list of arguments expected in the input
optstring=":c:1:2:"

while getopts ${optstring} arg; do
  case "${arg}" in
    c) GENOME_FILE=${OPTARG};;
    1) SHORT_READ_FILE_1=${OPTARG};;
    2) SHORT_READ_FILE_2=${OPTARG};;

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
echo "Short-read file #1 is: " $SHORT_READ_FILE_1
echo ""
echo "Short-read file #2 is: " $SHORT_READ_FILE_2
echo ""
OUTPUT_SAM_FILE="${GENOME_FILE%.fa}.short-read.sam"
echo "The output SAM file will be called: " $OUTPUT_SAM_FILE
echo ""
BAM_INITIAL="${OUTPUT_SAM_FILE%.sam}.bam"
echo "The initial BAM file will be called: " $BAM_INITIAL
echo ""
BAM_SORTED="${BAM_INITIAL%.bam}.sorted.bam"
echo "The sorted BAM file will be called: " $BAM_SORTED
echo ""
MAPPED_SHORT_READS_1=${BAM_SORTED%.sorted.bam}.mapped-short_1.fastq
echo "The mapped short reads file #1 will be called: " $MAPPED_SHORT_READS_1
echo ""
MAPPED_SHORT_READS_2=${BAM_SORTED%.sorted.bam}.mapped-short_2.fastq
echo "The mapped short reads file #1 will be called: " $MAPPED_SHORT_READS_2
echo ""

bwa index $GENOME_FILE

echo -e "Finished bwa index \n"

bwa mem \
    -t 18 \
    -o $OUTPUT_SAM_FILE \
    $GENOME_FILE \
    $SHORT_READ_FILE_1 \
    $SHORT_READ_FILE_2

echo -e "Finished bwa mem \n"

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
    -f 0x2 \
    -@ 18 \
    -1 $MAPPED_SHORT_READS_1 \
    -2 $MAPPED_SHORT_READS_2 \
    $BAM_SORTED

echo -e "Finished samtools fastq \n"

echo "done"
