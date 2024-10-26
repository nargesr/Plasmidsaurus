configfile: 'config/config.yaml'

# Assemble genome using given Oxford Nanopore long reads
# Flye: https://github.com/mikolmogorov/Flye
rule assemble_genome:
    input:
        clean_fastq=expand(f"{config['output_dir']}/{{sample_name}}/clean_{{sample_name}}.fastq.gz",
            sample_name=config["sample_names"])
    output:
        assembly=f"{config['output_dir']}/{{sample_name}}/assembly.fasta",
        flye_assembly_info=f"{config['output_dir']}/{{sample_name}}/assembly_info.txt",
    params:
        output_dir=f"{config['output_dir']}/{{sample_name}}",
        sample_name=lambda wildcards: wildcards.sample_name,
    threads:
        config['n_cpus']
    log:
        f"logs/{{sample_name}}/flye.log"
    shell:
        """(
        flye \
            --nano-raw {input.clean_fastq} \
            --out-dir {params.output_dir} \
            --threads {threads}
        ) >{log} 2>&1"""

# Polish assemble genome using given Oxford Nanopore long reads and assembly file
# minimap2: https://github.com/lh3/minimap2
# racon: https://github.com/isovic/racon
rule polish_genome:
    input:
        clean_fastq=expand(f"{config['output_dir']}/{{sample_name}}/clean_{{sample_name}}.fastq.gz",
            sample_name=config["sample_names"]),
        assembly=f"{config['output_dir']}/{{sample_name}}/assembly.fasta",
    output:
        align_assembly=f"{config['output_dir']}/{{sample_name}}/alignment_{{sample_name}}.paf",
        polish_assembly=f"{config['output_dir']}/{{sample_name}}/polish_assembly_{{sample_name}}.fasta",
    params:
        sample_name=lambda wildcards: wildcards.sample_name,
    threads:
        config['n_cpus']
    log:
        f"logs/{{sample_name}}/polish.log"
    shell:
        """(
        minimap2 \
            -x map-ont \
            -t {threads} \
            {input.assembly} \
            {input.clean_fastq} > \
            {output.align_assembly}

        racon \
            -t {threads} \
            {input.clean_fastq} \
            {output.align_assembly} \
            {input.assembly} > \
            {output.polish_assembly}
        ) >{log} 2>&1"""

# Annotate prokaryotic genome
# prokka: https://github.com/tseemann/prokka
rule annotate_genome:
    input:
        polish_assembly=expand(f"{config['output_dir']}/{{sample_name}}/polish_assembly_{{sample_name}}.fasta",
            sample_name=config["sample_names"]),
    output:
        annotation=f"{config['output_dir']}/{{sample_name}}/annotation_{{sample_name}}.gff",
    params:
        output_dir=f"{config['output_dir']}/{{sample_name}}",
        sample_name=lambda wildcards: wildcards.sample_name,
    threads:
        config['n_cpus']
    log:
        f"logs/{{sample_name}}/prokka.log"
    shell:
        """(
        prokka --force \
            --outdir {params.output_dir} \
            --prefix annotation_{wildcards.sample_name} \
            --cpus {threads} {input.polish_assembly}
        ) >{log} 2>&1"""