from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
from collections import defaultdict

positions = defaultdict(list)
with open('T47D-TRPS1_peaks.bed') as f:
    for line in f:
        name, start, stop = line.split()
        positions[name].append((int(start), int(stop)))

records = SeqIO.to_dict(SeqIO.parse(open('../../REF/hg38/hg38.fa'), 'fasta'))

short_seq_records = []
for name in positions:
    for (start, stop) in positions[name]:
        long_seq_record = records[name]
        long_seq = long_seq_record.seq
        alphabet = long_seq.alphabet
        short_seq = str(long_seq)[start-1:stop]
        short_seq_record = SeqRecord(Seq(short_seq, alphabet), id=name, description='')
        short_seq_records.append(short_seq_record)

with open('T47D-TRPS1_peaks.fasta', 'w') as f:
    SeqIO.write(short_seq_records, f, 'fasta')
