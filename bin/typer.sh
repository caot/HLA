#!/bin/bash
# Author: Xie Chao
set -e

S3=$1
ID=$2
OUT=hla-$ID

[[ $# -ne 2 ]] && {
    echo "usage: $(basename "$0") [S3://path.bam] [sample_id]";
    exit 1;
}
BIN="`dirname \"$0\"`"

mkdir -p $OUT
TEMP=temp-$RANDOM-$RANDOM-$RANDOM

echo "Extracting reads from S3"
samtools view -u $S3 chr6:29886751-33090696 > $TEMP
samtools view -L $BIN/../data/hla.bed $TEMP > ${TEMP}.sam
$BIN/preprocess.pl ${TEMP}.sam | gzip > $OUT/$ID.fq.gz
rm $TEMP
rm ${TEMP}.sam
echo "Aligning reads to IMGT database"
$BIN/align.pl $OUT/$ID.fq.gz $OUT/$ID.tsv.gz
echo "Typing"
$BIN/typing.r $OUT/$ID.tsv.gz $OUT/$ID.hla
echo "Reporting"
$BIN/report.py -in $OUT/$ID.hla -out $OUT/$ID.json -subject $ID -sample $ID
