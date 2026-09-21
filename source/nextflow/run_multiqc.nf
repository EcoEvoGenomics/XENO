workflow {

    run_multiqc(params.results_dir)

}

process run_multiqc {

    publishDir "${params.publish_dir}", saveAs: { filename -> "$filename" }, mode: 'copy'
    
    container "quay.io/biocontainers/multiqc:1.28--pyhdfd78af_0"
    cpus 1
    memory 3.GB
    time 2.h

    input:
    path(results_dir)

    output:
    path('multiqc_report.html')

    script:
    """
    multiqc \
    --config ${projectDir}/source/config/multiqc.yaml \
    --force \
    ${results_dir}
    mv *multiqc_report.html multiqc_report.html
    """
}
