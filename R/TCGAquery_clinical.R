#' @title Retrieve multiple tissue types not from the same patients.
#' @description
#'   TCGAquery_SampleTypes for a given list of samples and types,
#'    return the union of samples that are from theses type.
#' @param barcode is a list of samples as TCGA barcodes
#' @param typesample a character vector indicating tissue type to query.
#' Example:
#' \tabular{ll}{
#'TP \tab   PRIMARY SOLID TUMOR \cr
#'TR \tab   RECURRENT SOLID TUMOR \cr
#'TB \tab   Primary Blood Derived Cancer-Peripheral Blood \cr
#'TRBM \tab Recurrent Blood Derived Cancer-Bone Marrow \cr
#'TAP \tab  Additional-New Primary \cr
#'TM \tab   Metastatic \cr
#'TAM \tab  Additional Metastatic \cr
#'THOC \tab Human Tumor Original Cells \cr
#'TBM \tab  Primary Blood Derived Cancer-Bone Marrow \cr
#'NB \tab   Blood Derived Normal \cr
#'NT \tab   Solid Tissue Normal \cr
#'NBC \tab  Buccal Cell Normal \cr
#'NEBV \tab EBV Immortalized Normal \cr
#'NBM \tab  Bone Marrow Normal \cr
#'}
#' @export
#' @examples
#' # selection of normal samples "NT"
#' barcode <- c("TCGA-B0-4698-01Z-00-DX1","TCGA-CZ-4863-02Z-00-DX1")
#' # Returns the second barcode
#'  TCGAquery_SampleTypes(barcode,"TR")
#'  # Returns both barcode
#'  TCGAquery_SampleTypes(barcode,c("TR","TP"))
#' @return a list of samples / barcode filtered by type sample selected
TCGAquery_SampleTypes <- function(barcode,typesample){
    # Tumor AND Solid Tissue Normal NOT FROM THE SAME PATIENTS
    table.code <- c('01','02','03','04','05','06','07','08','09','10',
                    '11','12','13','14','20','40','50','60','61')
    names(table.code) <- c("TP","TR","TB","TRBM","TAP","TM","TAM","THOC",
                           "TBM","NB","NT","NBC","NEBV","NBM","CELLC","TRB",
                           "CELL","XP","XCL")

    if (sum(is.element(typesample,names(table.code))) == length(typesample)) {

        string <- substr(barcode, 14, 15)
        barcode.all <- NULL
        for (sample.i in typesample) {
            barcode.all <- union(barcode.all,
                                 barcode[grep(table.code[sample.i], string)])
        }
        return(barcode.all)
    }else{
        return("Error message: one or more sample types do not exist")
    }
}

#' @title Retrieve multiple tissue types from the same patients.
#' @description
#'   TCGAquery_MatchedCoupledSampleTypes
#' @param barcode barcode
#' @param typesample typesample
#' @examples
#'  TCGAquery_MatchedCoupledSampleTypes(c("TCGA-B0-4698-01Z-00-DX1",
#'                              "TCGA-B0-4698-02Z-00-DX1"),
#'                              c("TP","TR"))
#' @export
#' @return a list of samples / barcode filtered by type sample selected
TCGAquery_MatchedCoupledSampleTypes <- function(barcode,typesample){
    # Tumor AND Solid Tissue Normal FROM THE SAME PATIENTS
    table.code <- c('01','02','03','04','05','06','07','08','09','10',
                    '11','12','13','14','20','40','50','60','61')
    names(table.code) <- c("TP","TR","TB","TRBM","TAP","TM","TAM","THOC",
                           "TBM","NB","NT","NBC","NEBV","NBM","CELLC","TRB",
                           "CELL","XP","XCL")
    if(length(typesample)!=2){
        return("Error message: exactly two types need to be provided")
    }

    if(sum(is.element(typesample,names(table.code))) == length(typesample)) {

        string <- substr(barcode, 14, 15)
        barcode.1 <- barcode[grep(table.code[typesample[1]], string)]
        barcode.2 <- barcode[grep(table.code[typesample[2]], string)]


        barcode.common <- intersect(substr(barcode.1,1,12),
                                    substr(barcode.2,1,12))
        if(length(barcode.common) > 0){
        idx1 <- sapply(barcode.common, function(x) grep(x,barcode.1))
        idx2 <- sapply(barcode.common, function(x) grep(x,barcode.2))
        return(union(barcode.1[idx1], barcode.2[idx2]))

        }else{
            return("Error message: there exist no matched samples")
        }
    } else{
        return("Error message: one or more sample types do not exist")
    }
}

#' @title stage_BRCA
#' @description
#'   stage_BRCA
#' @param barcode barcode
#' @param stage stage
#' @param clinical_patient_data clinical_patient_data
#' @keywords internal
#' @return stage_BRCA
# @examples
# # clin <- TCGAquery_clinic("BRCA","clinical_patient")
# clin <- clinBRCA
# stage_BRCA(c("TCGA-3C-AALK","TCGA-A2-A04Q","TCGA-A4-A04Q"),"stage_IX",clin)
stage_BRCA <- function(barcode, stage, clinical_patient_data){
    table.stages <- c("Stage I$|Stage IA$|Stage IB$", "Stage I$", "Stage IA$",
                      "Stage IB$", "Stage II$|Stage IIA$|Stage IIB$",
                      "Stage II$", "Stage IIA$", "Stage IIB$",
                      "Stage III$|Stage IIIA$|Stage IIIB$|Stage IIIC$",
                      "Stage III$", "Stage IIIA$", "Stage IIIB$",
                      "Stage IIIC$", "Stage IV$")
    names(table.stages) <- c("stage_IX", "stage_I", "stage_IA", "stage_IB",
                             "stage_IIX", "stage_IIA", "stage_IIB",
                             "stage_IIIX","stage_IIIA", "stage_IIIB",
                             "stage_IIIC", "stage_IV")

    if (is.element(stage, names(table.stages))) {
        clinical_patient_data <- as.data.frame(clinical_patient_data)
        print(table.stages[stage])
        stage.i <- clinical_patient_data[
            grep(table.stages[stage],
                 clinical_patient_data$pathologic_stage), ]
        stage.i <- stage.i[,"bcr_patient_barcode"]
        samples <- substr(barcode, 1, 12)
        barcode <- intersect(samples,stage.i)
    }else{
        return("Error message: stage does not exist")
    }
    return(barcode)
}

#' @title gender_BRCA
#' @description
#'   gender_BRCA
#' @param barcode barcode
#' @param gender gender
#' @param clinical_patient_data clinical_patient_data
#' @keywords internal
#' @return stage_BRCA
# @examples
# # clin <- TCGAquery_clinic("BRCA","clinical_patient")
# clin <- clinBRCA
# gender_BRCA (c("TCGA-3C-AALK","TCGA-A2-A04Q","TCGA-A4-A04Q"),"FEMALE",clin)
gender_BRCA <- function(barcode, gender, clinical_patient_data){

    if (is.element(gender,c("MALE", "FEMALE"))) {
        clinical_patient_data <- as.data.frame(clinical_patient_data)
        s.gender <- as.data.frame(clinical_patient_data)[
            grep(paste0("^", gender,"$"), clinical_patient_data$gender),
            ][,"bcr_patient_barcode"]
        samples <- substr(barcode, 1, 12)
        #find common patients between FEMALE and barcode data
        barcode <- intersect(samples,s.gender)
    }else{
        return("Error message gender doesn't exist")
    }

    return(barcode)
}

#' @title ER_status_BRCA
#' @description
#'   ER_status_BRCA
#' @param barcode barcode
#' @param ER ER
#' @param clinical_patient_data clinical_patient_data
#' @keywords internal
#' @return ER_status_BRCA
# @examples
# # clin <- TCGAquery_clinic("BRCA","clinical_patient")
# clin <- clinBRCA
# ER_status_BRCA(c("TCGA-3C-AALK","TCGA-A2-A04Q","TCGA-A4-A04Q"),
# "Positive",clin)
ER_status_BRCA <- function(barcode,ER, clinical_patient_data){
    ## ER should be "Positive" or "Negative"
    # consider only barcode and ER status
    idx <- grep("estrogen_receptor_status",colnames(clinical_patient_data))
    if(length(idx) > 0) idx <- idx[1]
    if (is.element(ER, c("Positive", "Negative"))) {
        status <- as.data.frame(clinical_patient_data)[
            grep(paste0("^",ER,"$"),
                 clinical_patient_data[,idx]), ][,"bcr_patient_barcode"]
        samples <- substr(barcode, 1, 12)
        #find common patients between ER status and barcode data
        barcode <- intersect(samples,status)
        return(barcode)
    }else{
        return("Error message: ER status does not exist")
    }
}

#' @title PR_status_BRCA
#' @description
#'   PR_status_BRCA
#' @param barcode barcode
#' @param PR PR
#' @param clinical_patient_data clinical_patient_data
#' @keywords internal
#' @return PR_status_BRCA
# @examples
# # clin <- TCGAquery_clinic("BRCA","clinical_patient")
# clin <- clinBRCA
# PR_status_BRCA(c("TCGA-3C-AALK","TCGA-A2-A04Q","TCGA-A4-A04Q"),
# "Positive",clin)
PR_status_BRCA  <- function(barcode,PR, clinical_patient_data){
    ## PR should be "Positive" or "Negative"

    if(is.element(PR, c("Positive", "Negative"))){
        #for breast cancer
        status <- as.data.frame(clinical_patient_data)[
            grep(paste0("^", PR, "$"),
                 clinical_patient_data$pr_status_by_ihc), ][,"bcr_patient_barcode"]

        samples <- substr(barcode, 1, 12)
        #find common patients between PR status and barcode data
        barcode <- intersect(samples,status)
    }else{
        return("Error message: PR status does not exist")
    }

    return(barcode)

}

#' @title HER_status_BRCA
#' @description
#'   HER_status_BRCA
#' @param barcode barcode
#' @param HER HER
#' @param clinical_patient_data clinical_patient_data
#' @keywords internal
#' @return HER_status_BRCA
# @examples
# # clin <- TCGAquery_clinic("BRCA","clinical_patient")
# clin <- clinBRCA
# HER_status_BRCA(c("TCGA-3C-AALK","TCGA-A2-A04Q","TCGA-A4-A04Q"),
# "Positive",clin)
HER_status_BRCA  <- function(barcode, HER, clinical_patient_data){
    if (is.element(HER, c("Positive", "Negative"))) {
        clinical_patient_data <- as.data.frame(clinical_patient_data)
        idx <- grep("immunohistochemistry_receptor_",colnames(clinical_patient_data))
        if(length(idx) > 0) idx <- idx[1]
        #for breast cancer HER+
        status <- as.data.frame(clinical_patient_data)[
            grep(paste0("^",HER,"$"),
                 clinical_patient_data[,idx],), ][,"bcr_patient_barcode"]
        samples <- substr(barcode, 1, 12)
        #find common patients between HER+ e barcode data
        barcode <- intersect(samples,status)
        return(barcode)
    }else{
        return("Error message: HER status does not exist")
    }


}

#' @title clinical_data_site_cancer
#' @description
#'   clinical_data_site_cancer
#' @param cancer cancer
#' @keywords internal
# @examples clinical_data_site_cancer("gbm")
#' @return clinical_data_site_cancer
clinical_data_site_cancer <- function(cancer){
    return(paste0("https://tcga-data.nci.nih.gov/tcgafiles/",
                  "ftp_auth/distro_ftpusers/anonymous/tumor/",
                  cancer,"/bcr/biotab/clin/"))
}

#' @title Get the clinical information
#' @description
#'   Get the clinical information
#' @param tumor a character vector indicating cancer type Examples:
#' \tabular{lllll}{
#'OV   \tab BRCA \tab CESC \tab ESCA \tab PCPG\cr
#'LUSC \tab LGG  \tab SKCM \tab KICH \tab CHOL\cr
#'GBM  \tab UCEC \tab PRAD \tab PAAD \tab THYM\cr
#'KIRC \tab THCA \tab SARC \tab LAML \tab TGCT\cr
#'COAD \tab KIRP \tab HNSC \tab ACC  \tab UVM \cr
#'READ \tab BLCA \tab DLBC \tab UCS  \tab FPPP\cr
#'LUAD \tab LIHC \tab STAD \tab MESO \tab CNTL
#'}
#' For information about cancer types: https://tcga-data.nci.nih.gov/tcga/
#' @param clinical_data_type a character vector indicating the types of
#' clinical data Example:
#' \tabular{ll}{
#' biospecimen_aliquot \tab biospecimen_analyte \cr
#' biospecimen_cqcf \tab biospecimen_diagnostic_slides \cr
#' biospecimen_normal_control \tab biospecimen_portion \cr
#' biospecimen_protocol \tab biospecimen_sample \cr
#' biospecimen_shipment_portion \tab biospecimen_slide \cr
#' biospecimen_tumor_sample \tab clinical_cqcf \cr
#' clinical_drug \tab clinical_follow_up_v1.5 \cr
#' clinical_follow_up_v2.1 \tab clinical_follow_up_v4.0 \cr
#' clinical_follow_up_v4.0_nte \tab clinical_nte \cr
#' clinical_omf_v4.0 \tab clinical_patient \cr
#' clinical_radiation
#'}
#' @export
#' @importFrom RCurl getURL
#' @return clinic data
#' @examples
#' data <- TCGAquery_clinic("LGG","clinical_drug")
TCGAquery_clinic <- function(tumor,clinical_data_type){
    query <- TCGAquery(tumor = tumor, platform = "bio", level=2)
    TCGAdownload(query,type = clinical_data_type)
    clinical_patient <- TCGAprepare(query,type = clinical_data_type, dir = ".")
    return(clinical_patient)
}



#' @title Filter samples using clinical data
#' @description
#'   This function will return the samples that matches all filters.
#'   Filters available: HER, ER,gender,PR, stage.
#' @param barcode List of barcodes
#' @param clinical_patient_data clinical_patient_data obtained with clinic function
#' Ex: clinical_patient_data <- TCGAquery_clinic("LGG","clinical_patient")
#' @param HER  her2 neu immunohistochemistry receptor status: "Positive" or "Negative"
#' @param gender "MALE" or "FEMALE"
#' @param PR  Progesterone receptor status: "Positive" or "Negative"
#' @param stage Pathologic Stage: "stage_IX", "stage_I", "stage_IA", "stage_IB", "stage_IIX",
#' "stage_IIA", "stage_IIB", "stage_IIIX","stage_IIIA", "stage_IIIB",
#' "stage_IIIC", "stage_IV" -
#' @param ER Estrogen receptor status: "Positive" or "Negative"
#' @export
#' @return List of samples that matches the filters
#' @examples
#' # clin <- TCGAquery_clinic("BRCA","clinical_patient")
#' clin <- clinBRCA
#' bar <- c("TCGA-G9-6378-02A-11R-1789-07", "TCGA-CH-5767-04A-11R-1789-07",
#'         "TCGA-G9-6332-60A-11R-1789-07", "TCGA-G9-6336-01A-11R-1789-07",
#'         "TCGA-G9-6336-11A-11R-1789-07", "TCGA-G9-7336-11A-11R-1789-07",
#'         "TCGA-G9-7336-04A-11R-1789-07", "TCGA-G9-7336-14A-11R-1789-07",
#'         "TCGA-G9-7036-04A-11R-1789-07", "TCGA-G9-7036-02A-11R-1789-07",
#'         "TCGA-G9-7036-11A-11R-1789-07", "TCGA-G9-7036-03A-11R-1789-07",
#'         "TCGA-G9-7036-10A-11R-1789-07", "TCGA-BH-A1ES-10A-11R-1789-07",
#'         "TCGA-BH-A1F0-10A-11R-1789-07", "TCGA-BH-A0BZ-02A-11R-1789-07",
#'         "TCGA-B6-A0WY-04A-11R-1789-07", "TCGA-BH-A1FG-04A-11R-1789-08",
#'         "TCGA-D8-A1JS-04A-11R-2089-08", "TCGA-AN-A0FN-11A-11R-8789-08",
#'         "TCGA-AR-A2LQ-12A-11R-8799-08", "TCGA-AR-A2LH-03A-11R-1789-07",
#'         "TCGA-BH-A1F8-04A-11R-5789-07", "TCGA-AR-A24T-04A-55R-1789-07",
#'         "TCGA-AO-A0J5-05A-11R-1789-07", "TCGA-BH-A0B4-11A-12R-1789-07",
#'         "TCGA-B6-A1KN-60A-13R-1789-07", "TCGA-AO-A0J5-01A-11R-1789-07",
#'         "TCGA-AO-A0J5-01A-11R-1789-07", "TCGA-G9-6336-11A-11R-1789-07",
#'         "TCGA-G9-6380-11A-11R-1789-07", "TCGA-G9-6380-01A-11R-1789-07",
#'         "TCGA-G9-6340-01A-11R-1789-07","TCGA-G9-6340-11A-11R-1789-07")
#'
#' TCGAquery_clinicFilt(c("TCGA-3C-AALK","TCGA-A2-A04Q","TCGA-A4-A04Q"),clin,
#' HER="Positive", gender="FEMALE",ER="Positive")
TCGAquery_clinicFilt <- function(barcode,
                                 clinical_patient_data,
                                 HER=NULL,
                                 ER=NULL,
                                 gender=NULL,
                                 PR=NULL,
                                 stage=NULL){

    x <- NULL

    if (!is.null(PR)) {
        res.pr <- PR_status_BRCA(barcode,PR, clinical_patient_data)
        message(paste0("PR ",PR," Samples:"))
        message(paste(paste("\t",res.pr,"\n")))

        if (is.null(x)) x <- res.pr
    }

    if (!is.null(ER)) {
        res.er <- ER_status_BRCA(barcode,ER, clinical_patient_data)
        message(paste0("ER ",ER," Samples:"))
        message(paste(paste("\t",res.er,"\n")))

        if (is.null(x)) {
            x <- res.er
        } else {
            x <- intersect(x,res.er)
        }
    }

    if (!is.null(HER)) {
        res.her <- HER_status_BRCA(barcode,HER, clinical_patient_data)
        message(paste0("HER ",HER," Samples:"))
        message(paste(paste("\t",res.her,"\n")))
        if (is.null(x)) {
            x <- res.her
        } else {
            x <- intersect(x,res.her)
        }

    }
    if (!is.null(stage)) {
        res.stage <- stage_BRCA(barcode,stage, clinical_patient_data)
        message(paste0("Stage ",stage," Samples:"))
        message(paste(paste("\t",res.stage,"\n")))
        if (is.null(x)) {
            x <- res.stage
        } else {
            x <- intersect(x,res.stage)
        }

    }
    if (!is.null(gender)) {
        res.gender <- gender_BRCA(barcode,gender, clinical_patient_data)
        message(paste0("GENDER ",gender," Samples:"))
        message(paste(paste("\t",res.gender,"\n")))
        if (is.null(x)) {
            x <- res.gender
        } else {
            x <- intersect(x,res.gender)
        }

    }

    return(x)
}



# This function will preprare the colData for TCGAPrepare
# The idea is to add usefull information to the object
# that will help the users to understand their samples
# ref: TCGA codeTablesReport - Table: Sample type
#' @importFrom S4Vectors DataFrame
#' @importFrom stringr str_match
#' @importFrom xlsx read.xlsx2
colDataPrepare <- function(barcode,query){

    code <- c('01','02','03','04','05','06','07','08','09','10','11',
              '12','13','14','20','40','50','60','61')
    shortLetterCode <- c("TP","TR","TB","TRBM","TAP","TM","TAM","THOC",
                         "TBM","NB","NT","NBC","NEBV","NBM","CELLC","TRB",
                         "CELL","XP","XCL")

    definition <- c("Primary solid Tumor",
                    "Recurrent Solid Tumor",
                    "Primary Blood Derived Cancer - Peripheral Blood",
                    "Recurrent Blood Derived Cancer - Bone Marrow",
                    "Additional - New Primary",
                    "Metastatic",
                    "Additional Metastatic",
                    "Human Tumor Original Cells",
                    "Primary Blood Derived Cancer - Bone Marrow",
                    "Blood Derived Normal",
                    "Solid Tissue Normal",
                    "Buccal Cell Normal",
                    "EBV Immortalized Normal",
                    "Bone Marrow Normal",
                    "Control Analyte",
                    "Recurrent Blood Derived Cancer - Peripheral Blood",
                    "Cell Lines",
                    "Primary Xenograft Tissue",
                    "Cell Line Derived Xenograft Tissue")
    aux <- DataFrame(code = code,shortLetterCode,definition)

    # in case multiple equal barcode
    regex <- paste0("[:alnum:]{4}-[:alnum:]{2}-[:alnum:]{4}",
                    "-[:alnum:]{3}-[:alnum:]{3}-[:alnum:]{4}-[:alnum:]{2}")
    samples <- str_match(barcode,regex)[,1]

    ret <- DataFrame(sample = samples,
                     barcode = barcode,
                     patient = substr(barcode, 1, 12),
                     code = substr(barcode, 14, 15))
    ret <- merge(ret,aux, by = "code", sort = FALSE)
    ret <- ret[match(barcode,ret$barcode),]

    df <- do.call(rbind,
                  lapply(seq_along(samples),
                         function(i) {
                             idx <- grep(str_match(samples[i],regex)[1,1],query$barcode)
                             # exception case: same barcodes!
                             # we will select the correct row
                             if (length(idx) > 1) {
                                 idx2 <- grep(samples[i],barcode)
                                 idx <- idx[match(i,idx2)]
                             }
                             aux <- query[idx,]
                             return(data.frame(
                                 disease = unique(aux$Disease),
                                 platform = unique(aux$Platform),
                                 center = unique(aux$Center)
                             ))
                         }
                  ))

    ret <- cbind(ret,df)

    for (i in unique(query$Disease)) {
        if (grepl("lgg|gbm|luad|stad|coad|read", i,ignore.case = TRUE)) {
            subtype <- TCGAquery_subtype(i)
            if (any(ret$patient %in% subtype$patient)) {
                ret <- merge(ret, subtype,
                             all.x = TRUE ,
                             sort = FALSE,
                             by = "patient")
            }
        } else if (grepl("brca", i,ignore.case = TRUE)) {
            subtype <- TCGAquery_subtype(i)
            if (any(ret$sample %in% subtype$sample)) {
                ret <- merge(ret, subtype,
                             all.x = TRUE ,
                             sort = FALSE,
                             by = "sample")
            }
        }
    }

    ret <- ret[match(barcode,ret$barcode),]

    rownames(ret) <- ret$barcode
    ret$code <- NULL
    ret$barcode <- NULL

    return(DataFrame(ret))
}

#' @importFrom xlsx read.xlsx2
getsubtypes <- function(tumor = NULL, path = ".") {

    dir.create(path, showWarnings = FALSE, recursive = TRUE)
    root <- "https://tcga-data.nci.nih.gov/docs/publications/"

    if(grepl("lgg",tumor,ignore.case = TRUE)){
        link <- paste0(root,"lgg_2015/S1.Table.Revision.xlsx")
    }
    if(grepl("gbm",tumor,ignore.case = TRUE)){
        link <- paste0(root,"gbm_2013/supplement/Molecular_subtype_classification.xlsx")
    }

    if (grepl("luad",tumor,ignore.case = TRUE)){
        link <- paste0(root,"luad_2014/tcga.luad.gene.expression.subtypes.20121025.csv")
    }

    if (grepl("stad",tumor,ignore.case = TRUE)){
        link <- paste0(root,"stad_2014/STAD%20Master%20Patient%20Table%2020140207.xlsx")
    }

    if (grepl("brca",tumor,ignore.case = TRUE)){
        link <- paste0(root,"brca_2012/BRCA.547.PAM50.SigClust.Subtypes.txt")
    }

    # COAD and READ are in the zip file inside
    #http://www.nature.com/nature/journal/v487/n7407/full/nature11252.html#supplementary-information

    fname <- paste0(path, "/", basename(link))
    fname <- gsub(" ","_",fname)
    link <- gsub(" ","%20",link)

    suppressWarnings(
        if (!file.exists(fname)) {
            download(link,fname, quiet = TRUE,  mode = "wb")
        }
    )

    message("Adding subytpes information for", tumor, "samples")
    message(paste0("Source:", link))

    if (grepl("lgg",tumor,ignore.case = TRUE)){
        subtype <- read.xlsx2(fname,1,stringAsFactor=FALSE, header=TRUE)
        subtype <- merge(subtype,read.xlsx2(fname,2,stringAsFactor=FALSE, header=TRUE))
    }
    if (grepl("gbm",tumor,ignore.case = TRUE)){
        subtype <- read.xlsx2(fname,1,stringAsFactor=FALSE, header=TRUE, startRow = 3)
    }
    if (grepl("luad",tumor,ignore.case = TRUE)){
        subtype <- read.csv(fname)
    }
    if (grepl("stad",tumor,ignore.case = TRUE)){
        subtype <- read.xlsx2(fname,1,stringAsFactor=FALSE, header=TRUE)
    }

    if (grepl("brca",tumor,ignore.case = TRUE)){
        subtype <- fread(link,header = TRUE)
        setnames(subtype,1,"sample")
        return(subtype)
    }
    colnames(subtype)[1] <- "patient"

    return(subtype)
}

#' @title Retrieve molecular subtypes for a given tumor
#' @description
#'   TCGAquery_subtype Retrieve molecular subtypes for a given tumor
#' @param tumor is a cancer Examples:
#' \tabular{lllll}{
#' lgg   \tab gbm \tab luad \tab stad \tab brca\cr
#' coad \tab read \tab  \tab  \tab
#'}
#' @export
#' @examples
#' dataSubt <- TCGAquery_subtype(tumor = "lgg")
#' @return a data.frame with barcode and molecular subtypes
TCGAquery_subtype <- function(tumor){
    if (grepl("lgg|gbm|luad|stad|brca|coad|read", tumor,ignore.case = TRUE)) {
        # COAD and READ are in the same object
        #
        if(tolower(tumor) == "read") tumor <- "coad"
        return(get(paste0(tolower(tumor),".subtype")))
    } else {
        stop("For the moment we have only subtype for: LGG, GBM, STAD, BRCA, READ, COAD and LUAD")
    }
}
