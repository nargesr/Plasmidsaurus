# Plasmidsaurus

This is a snakemake pipeline to assemble and annotate a fastq of bacterial reads.

## Create conda environment
you can create a new environment by using [Plasmidsaurus_env.yml](workflow/envs/Plasmidsaurus_env.yml) and run

```
conda env create -f workflow/envs/Plasmidsaurus_env.yml
conda activate Plasmidsaurus
```

### RUN snakemake
Run `snakemake` at the repo's root directory. 

### Modify Input
To change/add fastq file(s), please modify `sample_names` at [config file](config/config.yaml).

To change number of CPUs, please modify `n_cpus` at [config file](config/config.yaml). The default is 8

### Expected outputs

All the Expected output will be available here: `results`

For this specific input, all the outputs would be here: `results/SRR30810013/*`

- Main outputs:
  - annotated genome GFF file: `results/SRR30810013/annotation_SRR30810013.gff`
  - annotated genome gbk file: `results/SRR30810013/annotation_SRR30810013.gbk`
  - Polished assemble genome: `results/SRR30810013/polish_assembly_SRR30810013.fasta`

- Useful Reports:
  - Preprocess and quality control of given reads: `results/SRR30810013/fastplong_SRR30810013.html` and `results/SRR30810013/fastplong_SRR30810013.json`
  - Assemble genome information (such as length or coverage): `results/SRR30810013/assembly_info.txt`
