import os

ACC='SRR10971381'
SRA_DIR='sra'
FASTQ_DIR='fastq'
ASSEMBLY_DIR='assembly/'+ACC
THREADS=os.cpu_count()

rule all:
    input:
        # expand("{assembly_dir}/assembly_graph_with_scaffolds.gfa", assembly_dir=ASSEMBLY_DIR),
        expand("{assembly_dir}/scaffolds.fasta", assembly_dir=ASSEMBLY_DIR),
        # expand("{assembly_dir}/transcripts.sorted.fasta", assembly_dir=ASSEMBLY_DIR),
        expand("{assembly_dir}/transcript1.fasta", assembly_dir=ASSEMBLY_DIR)

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

rule assemble_genome:
    output:
        contigs = expand("{assembly_dir}/transcripts.fasta", assembly_dir=ASSEMBLY_DIR),
        hard_filtered_contigs = expand("{assembly_dir}/hard_filtered_transcripts.fasta", assembly_dir=ASSEMBLY_DIR),
        soft_filtered_contigs = expand("{assembly_dir}/soft_filtered_transcripts.fasta", assembly_dir=ASSEMBLY_DIR),
        assembly_grap_with_scaffolds = expand("{assembly_dir}/assembly_graph_with_scaffolds.gfa", assembly_dir=ASSEMBLY_DIR)
    input:
        rules.compress_fastq1_file.output,
        rules.compress_fastq2_file.output
    shell:
        "spades.py -o assembly -t {THREADS} -k 25 --rnaviral --checkpoints last -1 {input[0]} -2 {input[1]}  > {ASSEMBLY_DIR}/spades.txt"

rule make_scaffolds:
    output:
        scaffolds = expand("{assembly_dir}/scaffolds.fasta", assembly_dir=ASSEMBLY_DIR)
    input:
        rules.assemble_genome.output.assembly_grap_with_scaffolds
    shell:
        "gfatools gfa2fa  {rules.assemble_genome.output.assembly_grap_with_scaffolds} >  {output}"

rule extract_longest_contigs:
    output:
        longest_contigs = expand("{assembly_dir}/transcripts.sorted.fasta", assembly_dir=ASSEMBLY_DIR),
    input:
        rules.assemble_genome.output.contigs
    shell:
        # This could also be done with seqkit
        "python sort_contigs.py --n 10 --input {input} --output {output}"

rule reverse_complement_1st_contig:
    output:
        first_contig = expand("{assembly_dir}/transcript1.fasta", assembly_dir=ASSEMBLY_DIR),
    input:
        rules.extract_longest_contigs.output
    shell:
        # Why on Earth does tsnakemake stop on the ne---xt (commented) line, when its exit code is 0??
        # "seqkit seq -t dna -v -r -p {input} | seqkit head -n 1 > {output}"
        # Workaround below
        "seqkit seq -t dna -v -r -p {input}  > {ASSEMBLY_DIR}/tmp.fasta; "
        "seqkit head -n 1 {ASSEMBLY_DIR}/tmp.fasta > {output}; "
        "rm {ASSEMBLY_DIR}/tmp.fasta"

# Note to self: make renamed FASTA file, input to prokka

"""
rule annotate_with_prokka
    output:
        first_contig = expand("{assembly_dir}/prokka/prokka.gff", assembly_dir=ASSEMBLY_DIR),
    input:

          prokka --kingdom Viruses --force --outdir assembly/SRR10971381/prokka --prefix prokka assembly/SRR10971381/transcript1.renamed.fasta
"""
