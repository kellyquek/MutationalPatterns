#' Make mutation count matrix of 96 trinucleotides with transcriptional
#' strand information
#'
#' Make a mutation count matrix for 96 trinucleotides, for both the
#' transcribed and untranscribed strand of gene bodies.
#'
#' Mutations outside gene bodies are not counted.
#'
#' @param vcf_list List of collapsed vcf objects
#' @param ref_genome BSGenome reference genome object 
#' @param genes GRanges object with definition of gene bodies, including
#' strand information
#'
#' @return 192 mutation count matrix (96 * 2 strands)
#'
#' @import GenomicRanges
#'
#' @examples
#' ## See the 'read_vcfs_as_granges()' example for how we obtained the
#' ## following data:
#' vcfs <- readRDS(system.file("states/read_vcfs_as_granges_output.rds",
#'                 package="MutationalPatterns"))
#'
#' ## Exclude mitochondrial and allosomal chromosomes.
#' autosomal <- extractSeqlevelsByGroup(species="Homo_sapiens",
#'                                     style="UCSC",
#'                                     group="auto")
#'
#' vcfs = lapply(vcfs, function(x) keepSeqlevels(x, autosomal))
#'
#' ## Load the corresponding reference genome.
#' ref_genome = "BSgenome.Hsapiens.UCSC.hg19"
#' library(ref_genome, character.only = TRUE)
#'
#' ## You can obtain the known genes from the UCSC hg19 dataset using
#' ## Bioconductor:
#' # source("https://bioconductor.org/biocLite.R")
#' # biocLite("TxDb.Hsapiens.UCSC.hg19.knownGene")
#' # library("TxDb.Hsapiens.UCSC.hg19.knownGene")
#'
#' ## For this example, we preloaded the data for you:
#' genes_hg19 <- readRDS(system.file("states/genes_hg19.rds",
#'                         package="MutationalPatterns"))
#'
#' mut_mat_s = mut_matrix_stranded(vcfs, ref_genome, genes_hg19)
#'
#' @seealso
#' \code{\link{read_vcfs_as_granges}},
#' \code{link{mut_matrix}}
#'
#' @export

mut_matrix_stranded = function(vcf_list, ref_genome, genes)
{
    df = data.frame()
    for(i in seq(vcf_list))
    {
        type_context = type_context(vcf_list[[i]], ref_genome)
        strand = strand_from_vcf(vcf_list[[i]], genes)
        row = mut_192_occurrences(type_context, strand)
        df = rbind(df, row)
    }

    names(df) = names(row)
    row.names(df) = names(vcf_list)

    # transpose
    return(t(df))
}
