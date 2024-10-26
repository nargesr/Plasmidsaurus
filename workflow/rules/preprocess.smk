configfile: 'config/config.yaml'

# preprocess (quality control) for long reads
# fastplong; https://github.com/OpenGene/fastplong
rule quality_filter:
    input:
        fastq = expand(f"{config['fastq_dir']}/{{sample_name}}.fastq.gz",
            sample_name=config["sample_names"])
    output:
        clean_fastq = f"{config['output_dir']}/{{sample_name}}/clean_{{sample_name}}.fastq.gz",
        fastplong_html_report=f"{config['output_dir']}/{{sample_name}}/fastplong_{{sample_name}}.html",
        fastplong_json_report=f"{config['output_dir']}/{{sample_name}}/fastplong_{{sample_name}}.json",
    params:
        output_dir = f"{config['output_dir']}/{{sample_name}}",
        sample_name= lambda wildcards: wildcards.sample_name,
    threads:
        config['n_cpus']
    log:
        f"logs/{{sample_name}}/fastplong.log"
    shell:
        """(
        mkdir -p {params.output_dir}
        fastplong \
            -i {input.fastq} \
            -o {output.clean_fastq} \
            -h {output.fastplong_html_report} \
            -j {output.fastplong_json_report} \
            --thread {threads} \
            --qualified_quality_phred 5 \
            --length_required 5
        ) >{log} 2>&1"""
