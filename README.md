replicateBE
================

  - [Comparative BA-calculation for the EMA’s Average Bioequivalence
    with Expanding Limits
    (ABEL)](#comparative-ba-calculation-for-the-emas-average-bioequivalence-with-expanding-limits-abel)
  - [Introduction](#intro)
      - [Methods](#methods)
          - [Estimation of *CV<sub>wR</sub>* (and *CV<sub>wT</sub>* in
            full replicate
            designs)](#estimation-of-cvwr-and-cvwt-in-full-replicate-designs)
          - [Method A](#methodA)
          - [Method B](#methodB)
          - [Average Bioequivalence](#ABE)
      - [Tested designs](#designs)
          - [Four period (full) replicates](#per4_full)
          - [Three period (full) replicates](#per3_full)
          - [Two period (full) replicate](#per2_full)
          - [Three period (partial) replicates](#per3_part)
      - [Cross-validation](#cross)
  - [Examples](#examples)
  - [Installation](#installation)

<!-- README.md is generated from README.Rmd. Please edit that file -->

Built 2019-08-26 with R 3.6.1.

## Comparative BA-calculation for the EMA’s Average Bioequivalence with Expanding Limits (ABEL)

**Package offered for Use without any Guarantees and Absolutely No
Warranty. No Liability is accepted for any Loss and Risk to Public
Health Resulting from Use of this R-Code.**

## Introduction

The library provides data sets (internal `.rda` and in CSV-format in
`/extdata/`) which support users in a black-box performance
qualification (PQ) of their software installations. Users can perform
analysis of their own data imported from CSV- and Excel-files. The
methods given by the EMA in [Annex
I](https://www.ema.europa.eu/en/documents/other/31-annex-i-statistical-analysis-methods-compatible-ema-bioequivalence-guideline_en.pdf "EMA/582648/2016, 21 September 2016")
for reference-scaling according to the EMA’s [Guideline on the
Investigation of
Bioequivalence](https://www.ema.europa.eu/en/documents/scientific-guideline/guideline-investigation-bioequivalence-rev1_en.pdf "EMA, January 2010")
are implemented. Potential influence of outliers on the variability of
the reference can be assessed by box plots of studentized and
standardized residuals as suggested at a joint [EGA/EMA
workshop](https://www.medicinesforeurope.com/wp-content/uploads/2016/03/EGA_BEQ_QA_WEB_QA_1_32.pdf "London, June 2010").  
In full replicate designs the variability of test and reference
treatments can be assessed by *s<sub>wT</sub>*/*s<sub>wR</sub>* and the
upper confidence limit of *σ<sub>wT</sub>*/*σ<sub>wR</sub>* (required
for the [WHO’s
approach](https://extranet.who.int/prequal/sites/default/files/documents/AUC_criteria_November2018.pdf "Geneva, November 2018")
for reference-scaling of *AUC*).

<small>[↑ TOC](#readme)</small>

### Methods

#### Estimation of *CV<sub>wR</sub>* (and *CV<sub>wT</sub>* in full replicate designs)

Called internally by functions `method.A()` and `method.B()`. A linear
model of log-transformed pharmacokinetic (PK) responses and effects  
    *sequence*, *subject(sequence)*, *period*  
where all effects are fixed (*i.e.*, ANOVA). Estimated by the function
`lm()` of library `stats`.

``` r
modCVwR <- lm(log(PK) ~ sequence + subject%in%sequence + period,
                        data = data[data$treatment == "R", ])
modCVwT <- lm(log(PK) ~ sequence + subject%in%sequence + period,
                        data = data[data$treatment == "T", ])
```

<small>[↑ TOC](#readme)</small>

#### Method A

Called by function `method.A()`. A linear model of log-transformed PK
responses and effects  
    *sequence*, *subject(sequence)*, *period*, *treatment*  
where all effects are fixed (*i.e.*, ANOVA). Estimated by the function
`lm()` of library `stats`.

``` r
modA <- lm(log(PK) ~ sequence + subject%in%sequence + period + treatment,
                     data = data)
```

<small>[↑ TOC](#readme)</small>

#### Method B

Called by function `method.B()`. A linear model of log-transformed PK
responses and effects  
    *sequence*, *subject(sequence)*, *period*, *treatment*  
where *subject(sequence)* is a random effect and all others are fixed.  
Three options are provided

1.  Estimated by the function `lme()` of library `nlme`. Employs degrees
    of freedom equivalent to SAS’ `DDFM=CONTAIN` and Phoenix WinNonlin’s
    `DF Residual`. Implicitly preferred according to the Q\&A document
    and hence, the default of the function.

<!-- end list -->

``` r
modB <- lme(log(PK) ~ sequence +  period + treatment, random = ~1|subject,
                      data = data)
```

2.  Estimated by the function `lmer()` of library `lmerTest`. Employs
    Satterthwaite’s approximation of the degrees of freedom
    `method.B(..., option = 1)` equivalent to SAS’ `DDFM=SATTERTHWAITE`
    and Phoenix WinNonlin’s `DF Satterthwaite`. This is the only
    available method in SPSS.

<!-- end list -->

``` r
modB <- lmer(log(PK) ~ sequence + period + treatment + (1|subject),
                       data = data)
```

3.  Estimated by the function `lmer()` of library `lmerTest`. Employs
    the Kenward-Roger approximation `method.B(..., option = 3)`. This is
    the only available method in JMP.

<!-- end list -->

``` r
modB <- lmer(log(PK) ~ sequence + period + treatment + (1|subject),
                       data = data)
```

<small>[↑ TOC](#readme)</small>

#### Average Bioequivalence

Called by function `ABE()`. The model is identical to
[Method A](#methodA). Conventional BE limits (80.00 – 125.00%) are
employed by default. Tighter limits for narrow therapeutic index drugs
(EMA 90.00 – 111.11%) or wider limits (75.00 – 133.33% for
*C<sub>max</sub>* according to the guideline of the Gulf Cooperation
Council (Bahrain, Kuwait, Oman, Qatar, Saudi Arabia, and the United Arab
Emirates) can be specified.

<small>[↑ TOC](#readme)</small>

### Tested designs

#### Four period (full) replicates

`TRTR | RTRT`  
`TRRT | RTTR`  
`TTRR | RRTT`  
`TRTR | RTRT | TRRT | RTTR` <small>(confounded effects, *not
recommended*)</small>  
`TRRT | RTTR | TTRR | RRTT` <small>(confounded effects, *not
recommended*)</small>

#### Three period (full) replicates

`TRT | RTR`  
`TRR | RTT`

#### Two period (full) replicate

`TR | RT | TT | RR` <small>(Balaam’s design; *not recommended* due to
poor power characteristics)</small>

#### Three period (partial) replicates

`TRR | RTR | RRT`  
`TRR | RTR` <small>(Extra-reference design; biased in the presence of
period effects, *not recommended*)</small>

<small>[↑ TOC](#readme)</small>

### Cross-validation

Details about the reference datasets:

``` r
help("data", package = "replicateBE")
?replicateBE::data
```

Results of the 28 reference datasets agree with ones obtained in SAS
(9.4), Phoenix WinNonlin (6.4 – 8.1), STATISTICA (13), SPSS (22.0),
Stata (15.0), and JMP (10.0.2).

<small>[↑ TOC](#readme)</small>

## Examples

  - Evaluation of the internal reference dataset 01 of [Annex
    II](https://www.ema.europa.eu/en/documents/other/31-annex-ii-statistical-analysis-bioequivalence-study-example-data-set_en.pdf "EMA, 21 September 2016")
    by Method A.

<!-- end list -->

``` r
library(replicateBE)
res <- method.A(verbose = TRUE, details = TRUE, print = FALSE,
                data = rds01)

Data set DS01 by Method A 
────────────────────────── 
Analysis of Variance Table

Response: log(PK)
                  Df    Sum Sq   Mean Sq  F value     Pr(>F)    
sequence           1   0.00765 0.0076519  0.04783  0.8270958    
period             3   0.69835 0.2327836  1.45494  0.2278285    
treatment          1   1.76810 1.7680980 11.05095  0.0010405 ** 
sequence:subject  75 214.12956 2.8550608 17.84467 < 2.22e-16 ***
Residuals        217  34.71895 0.1599952                        
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

treatment T – R:
  Estimate Std. Error    t value   Pr(>|t|) 
0.14547400 0.04650870 3.12788000 0.00200215 
217 Residual Degrees of Freedom

cols <- c(12, 15:19) # Relevant columns
print(round(res[cols], 2), row.names=FALSE)

CVwR(%) EL.lo(%) EL.hi(%) CI.lo(%) CI.hi(%)  PE(%)
  46.96    71.23    140.4   107.11   124.89 115.66
```

<small>[↑ TOC](#readme)</small>

  - Same dataset evaluated by Method B. Outlier assessment,
    recalculation of *CV<sub>wR</sub>* after exclusion of outliers, new
    expanded limits.

<!-- end list -->

``` r
res <- method.B(ola = TRUE, verbose = TRUE, details = TRUE, print = FALSE,
                data = rds01)

Outlier analysis
 (externally) studentized residuals
 Limits (2×IQR whiskers): -1.717435, 1.877877
 Outliers:
 subject sequence  stud.res
      45     RTRT -6.656940
      52     RTRT  3.453122

 standarized (internally studentized) residuals
 Limits (2×IQR whiskers): -1.69433, 1.845333
 Outliers:
 subject sequence stand.res
      45     RTRT -5.246293
      52     RTRT  3.214663

Data set DS01: Method B by lme (option=2; equivalent to SAS’ DDFM=CONTAIN) 
────────────────────────────────────────────────────────────────────────── 
            numDF denDF       F-value p-value
(Intercept)     1   217 6162.79177905  <.0001
sequence        1    75    0.01402184  0.9061
period          3   217    0.82478701  0.4815
treatment       1   217    9.86464146  0.0019

treatment T – R:
       Value    Std.Error           DF      t-value      p-value 
1.460882e-01 4.651301e-02 2.170000e+02 3.140803e+00 1.919596e-03

cols <- c(25, 28:29, 17:19) # Relevant columns
print(round(res[cols], 2), row.names=FALSE)

CVwR.new(%) EL.new.lo(%) EL.new.hi(%) CI.lo(%) CI.hi(%)  PE(%)
      32.16        78.79       126.93   107.17   124.97 115.73
```

<small>[↑ TOC](#readme)</small>

## Installation

Install the released version from CRAN

``` r
install.packages("replicateBE", repos = "https://cloud.r-project.org/")
```

Install the development version from GitHub:

``` r
# install.packages("devtools", repos = "https://cloud.r-project.org/")
devtools::install_github("Helmut01/replicateBE")
```

<small>[↑ TOC](#readme)</small>
