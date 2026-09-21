workflow {

    samples = params.samples ?: null
    trim_align = params.trim_align ?: false
    downsample = params.downsample ?: false
    read_target = params.read_target ?: null
    trimming_flags = params.trimming_flags ?: null
    aligner = params.aligner ?: null
    exclude_flags = params.exclude_flags ?: null
    ref_genome = params.ref_genome ?: null
    ref_scaffold_name = params.ref_scaffold_name ?: null
    ref_ploidy_file = params.ref_ploidy_file ?: null

    if (
        samples == null ||
        (trim_align && downsample && read_target == null) ||
        (trim_align && trimming_flags == null) ||
        (trim_align && aligner != "gpu" && aligner != "mem" && aligner != "aln") ||
        (trim_align && exclude_flags == null) ||
        ref_genome == null ||
        ref_scaffold_name == null ||
        ref_ploidy_file == null
        ) {
            exit(1, "Required options are unset or incorrectly set in options.yaml.")
    }

    def ref_index = file(ref_genome.toString() + ".fai", checkIfExists: true)
    def samples_csv = file(samples, checkIfExists: true)

    file(ref_genome, checkIfExists: true)
    file(ref_ploidy_file, checkIfExists: true)
    if (trim_align) { file(trimming_flags, checkIfExists: true) }
    
    check_ref_contig_names(ref_index)
    check_sample_csv(samples_csv)

}

process check_ref_contig_names {

    cpus { 1 }
    memory { 1.GB }
    time { 15.m }

    input:
    path(ref_index)

    script:
    """
    while read -r contig size pos base_per_line byte_per_line; do
        if grep -qE '^[[:alnum:]]+\$' <<< \$contig;
            then : ;
            else
                echo "ERROR: Contig name \$contig is not alphanumeric."
                exit 1
        fi
    done < ${ref_index}
    """
}

process check_sample_csv {

    cpus { 1 }
    memory { 1.GB }
    time { 15.m }

    input:
    path(sample_csv)

    script:
    """
    while IFS=, read -r sample sex lane fasta_a fasta_b; do
        if grep -qE '^[[:alnum:]]+\$' <<< \$sample;
            then : ;
            else
                echo "ERROR: Sample name \$sample is not alphanumeric."
                exit 1
        fi
    done < ${sample_csv}
    """
}
