ACC='SRR10971381'
SRA_DIR='sra'
FASTQ_DIR='fastq'
THREADS=16

rule all:
    input:
        expand("{fastq_dir}/{acc}_1.fastq.gz", acc=ACC, fastq_dir=FASTQ_DIR),
        expand("{fastq_dir}/{acc}_2.fastq.gz", acc=ACC, fastq_dir=FASTQ_DIR)

rule download_reads:
    output:
        sra = expand("{sra_dir}/{acc}/{acc}.sra", sra_dir=SRA_DIR, acc=ACC)
    shell:
        "prefetch -v {ACC} -O {SRA_DIR}"

rule convert_sra_to_fastq:
    output:
        fastq1 = expand("{fastq_dir}/{acc}_1.fastq", acc=ACC, fastq_dir=FASTQ_DIR),
        fastq2 = expand("{fastq_dir}/{acc}_2.fastq", acc=ACC, fastq_dir=FASTQ_DIR)
    input:
        rules.download_reads.output
    shell:
        "fasterq-dump -v -O {FASTQ_DIR} --split-files {input}"

rule compress_fastq1_file:
    output:
        fastq1_gz = expand("{fastq_dir}/{acc}_1.fastq.gz", acc=ACC, fastq_dir=FASTQ_DIR),
    input:
        rules.convert_sra_to_fastq.output.fastq1
    shell:
        "bgzip -@ {THREADS} {input};"
        "seqkit stats -j {THREADS} {output}" # Send this to a log file, instead of cluttering the output of snakemake

rule compress_fastq2_file:
    output:
        fastq2_gz = expand("{fastq_dir}/{acc}_2.fastq.gz", acc=ACC, fastq_dir=FASTQ_DIR),
    input:
        rules.convert_sra_to_fastq.output.fastq2
    shell:
        "bgzip -@ {THREADS} {input};"
        "seqkit stats -j {THREADS} {output}"


spades.py -o assembly -t 16 -k 25 --rna -1 fastq/SRR10971381_1.fastq.gz -2 fastq/SRR10971381_2.fastq.gz  > spades.txt