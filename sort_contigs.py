import click
from Bio import SeqIO


@click.command()
@click.option('--n', default=1, help='Number of contigs to extract')
@click.option('--input', help='Input FASTA file')
@click.option('--output', help='Output FASTA file')
def main(n, input, output):
    """Extracts the requsted number of longest contigs, and save them in order of descending length."""
    # Input and output FASTA file paths
    # input = "assembly/SRR10971381/transcripts.fasta"
    # output = "assembly/SRR10971381/transcripts.sorted.fasta"

    # Read the sequences from the FASTA file
    sequences = list(SeqIO.parse(input, "fasta"))

    # Sort sequences by length in decreasing order
    sorted_sequences = sorted(sequences, key=lambda seq: len(seq.seq), reverse=True)

    # Write the sorted sequences to a new FASTA file
    SeqIO.write(sorted_sequences[0:10], output, "fasta")

    print(f"The {n} longest contig(s) have been saved to {output}")


if __name__ == '__main__':
    main()
