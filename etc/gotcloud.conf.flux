ONE_BWA = 1
# Set number of bwa threads per bwa run.
BWA_THREADS = -t 3

# Skip verifyBamID & run 2 step dedup/recab
PER_MERGE_STEPS = qplot index recab

# Run 2 step dedup/recab
recab_RUN_DEDUP = dedup_LowMem $(dedup_PARAMS) $(dedup_USER_PARAMS) --

# Bin
recab_BINNING = --binMid --binQualS 2,3,10,20,25,30,35,40,50

# Have recalibration write CRAM:
recab_EXT = recal.cram
recab_OUT = -.ubam
index_EXT = $(recab_EXT).crai
qplot_IN = -.ubam
GEN_CRAM = | $(SAMTOOLS_EXE) view -C -T $(REF) - > $(basename $@)
VIEW_CRAM = $(SAMTOOLS_EXE) view -uh -T $(REF) $(basename $<) |

#KEEP_TMP = 1
KEEP_LOG = 1

FASTQ_LIST = $(OUT_DIR)/fastq.list

SAMTOOLS_SORT_EXE = /home/software/rhel6/med/samtools/1.2/bin/samtools
BWA_RM_FASTQ = 1

recab_USER_PARAMS = --maxBaseQual 44

[cleanUpBam2fastq]
BAM_LIST = $(OUT_DIR)/bam.list
