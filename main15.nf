/*
 * Copyright (c) 2013-2019, Centre for Genomic Regulation (CRG).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * This Source Code Form is "Incompatible With Secondary Licenses", as
 * defined by the Mozilla Public License, v. 2.0.
 *
 */


/*
 * Proof of concept of a RNAseq pipeline implemented with Nextflow
 *
 * Authors:
 * - Paolo Di Tommaso <paolo.ditommaso@gmail.com>
 * - Emilio Palumbo <emiliopalumbo@gmail.com>
 * - Evan Floden <evanfloden@gmail.com>
 */
nextflow.preview.dsl=2 

/*
 * Default pipeline parameters. They can be overriden on the command line eg.
 * given `params.foo` specify on the run command line `--foo some_value`.
 */

params.reads = "$baseDir/data/ggal/ggal_gut_{1,2}.fq"
params.transcripts = "$baseDir/data/ggal/transcriptome_*.fa"
params.outdir = "results"
params.multiqc = "$baseDir/multiqc"

log.info """\
 R N A S E Q - N F   P I P E L I N E
 ===================================
 transcript1  : ${params.transcript1}
 transcript2  : ${params.transcript2}
 reads        : ${params.reads}
 outdir       : ${params.outdir}
 """

include './rnaseq-analysis-2' params(params)
include './fun-library'

workflow {
	main:
	getInputForRnaseq(params.transcripts, params.reads) | rnaseq_analysis
	publish:
	rnaseq_analysis.out.fastqc to: 'results/fastqc_files'
	rnaseq_analysis.out.quant to: 'results/quant_files'
	rnaseq_analysis.out.multiqc to: 'results/multiqc_report'
}

workflow.onComplete {
	log.info ( workflow.success ? "\nDone! Open the following report in your browser --> $params.outdir/multiqc_report.html\n" : "Oops .. something went wrong" )
}
