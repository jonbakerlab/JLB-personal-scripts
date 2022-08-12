# Assorted bash loops to get statistics on given genomes

for datafile in *.fna ;do
    echo $datafile >> filenames.txt
done

for datafile in *.fna ;do
    grep -c -h '>' $datafile >> contig-nums.txt
done

for datafile in *.fna ;do
    head -q -n 1 $datafile >> file-headers.txt ;done

for datafile in *.fna ;do
grep -v ">" $datafile | tr -d '\n' | wc -c >> total-length.txt ;done

paste filenames.txt file-headers.txt contig-nums.txt total-length.txt > refs-data.txt

for datafile in *.fna ;do
awk 'BEGIN{RS=">";FS="\n";print "name\tA\tC\tG\tT\tN\tlength\tGC%"}NR>1{sumA=0;sumT=0;sumC=0;sumG=0;sumN=0;seq="";for (i=2;i<=NF;i++) seq=seq""$i; k=length(seq); for (i=1;i<=k;i++) {if (substr(seq,i,1)=="T") sumT+=1; else if (substr(seq,i,1)=="A") sumA+=1; else if (substr(seq,i,1)=="G") sumG+=1; else if (substr(seq,i,1)=="C") sumC+=1; else if (substr(seq,i,1)=="N") sumN+=1}; print $1"\t"sumA"\t"sumC"\t"sumG"\t"sumT"\t"sumN"\t"k"\t"(sumC+sumG)/k*100}' $datafile ;done

for datafile in *refined ;do ; grep -v ">" $datafile | tr -d '\n' | wc -c ;done

# Get number of reads in a fastq file
echo $(cat 27_reads-nanopore-nohuman.fastq|wc -l)/4|bc
