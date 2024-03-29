% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/TCGAanalyze.R
\name{TCGAanalyze_DEA}
\alias{TCGAanalyze_DEA}
\title{Differentially expression analysis (DEA) using edgeR package.}
\usage{
TCGAanalyze_DEA(mat1, mat2, Cond1type, Cond2type, method = "exactTest",
  fdr.cut = 1, logFC.cut = 0)
}
\arguments{
\item{mat1}{numeric matrix, each row represents a gene,
each column represents a sample with Cond1type}

\item{mat2}{numeric matrix, each row represents a gene,
each column represents a sample with Cond2type}

\item{Cond1type}{a string containing the class label of the samples in mat1
(e.g., control group)}

\item{Cond2type}{a string containing the class label of the samples in mat2
(e.g., case group)}

\item{method}{is 'glmLRT' (1) or 'exactTest' (2).
(1) Fit a negative binomial generalized log-linear model to
the read counts for each gene
(2) Compute genewise exact tests for differences in the means between
two groups of negative-binomially distributed counts.}

\item{fdr.cut}{is a threshold to filter DEGs according their p-value corrected}

\item{logFC.cut}{is a threshold to filter DEGs according their logFC}
}
\value{
table with DEGs containing for each gene logFC, logCPM, pValue,and FDR
}
\description{
TCGAanalyze_DEA allows user to perform Differentially expression analysis (DEA),
   using edgeR package to identify differentially expressed genes (DEGs).
    It is possible to do a two-class analysis.

    TCGAanalyze_DEA performs DEA using following functions from edgeR:
    \enumerate{
    \item edgeR::DGEList converts the count matrix into an edgeR object.
    \item edgeR::estimateCommonDisp each gene gets assigned the same dispersion estimate.
    \item edgeR::exactTest performs pair-wise tests for differential expression between two groups.
    \item edgeR::topTags takes the output from exactTest(), adjusts the raw p-values using the
    False Discovery Rate (FDR) correction, and returns the top differentially expressed genes.
    }
}
\examples{
dataNorm <- TCGAbiolinks::TCGAanalyze_Normalization(dataBRCA, geneInfo)
dataFilt <- TCGAanalyze_Filtering(tabDF = dataBRCA, method = "quantile", qnt.cut =  0.25)
samplesNT <- TCGAquery_SampleTypes(colnames(dataFilt), typesample = c("NT"))
samplesTP <- TCGAquery_SampleTypes(colnames(dataFilt), typesample = c("TP"))
dataDEGs <- TCGAanalyze_DEA(dataFilt[,samplesNT],
                      dataFilt[,samplesTP],"Normal", "Tumor")
}

