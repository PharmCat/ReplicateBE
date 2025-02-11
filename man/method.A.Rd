\encoding{utf-8}
\name{method.A}
\alias{method.A}
\title{
  Comparative BA-calculation for Average Bioequivalence with Expanding Limits by the EMA's 'Method A'
}

\description{
  This function performs the required calculations for the mixed (or aggregate)
  \acronym{BE} decision via Average Bioequivalence with Expanding Limits
  (\acronym{ABEL}) based on \acronym{ANOVA} (\sQuote{Method A}) as recommended in \emph{Annex I}.
}

\usage{
method.A(alpha = 0.05, path.in = "~/", path.out = "~/",
         file, set = "", ext, na = ".", sep = ",", dec = ".",
         logtrans = TRUE, ola = FALSE, print = TRUE, details = FALSE,
         adjust = FALSE, verbose = FALSE, ask = FALSE,
         plot.bxp = FALSE, fence = 2, data = NULL)
}

\arguments{
  \item{alpha}{
    Type I Error (\acronym{TIE}) probability (nominal level of the test).
    Conventionally set to 0.05, resulting in a
    \ifelse{html}{\out{100(1&ndash;2&alpha;)}}{\eqn{100(1-2\alpha)}{100(1-2alpha)}}
    confidence interval.
  }
  \item{path.in}{
    Path to the data file for import. If missing or not existing the
    user’s home folder \verb{"~/"} will be used.
  }
  \item{path.out}{
    Path to safe the result file if \code{print=TRUE}. The user must have
    write-permission to the directory. If missing or not existing the
    user’s home folder \verb{"~/"} will be used.
  }
  \item{file}{
    Name of the dataset for import (\emph{without} extension). Must be
    a string (\emph{i.e.}, enclosed in single or double quotation marks).
  }
  \item{set}{
    Name of the sheet of an Excel-file (mandatory). Must be a string
    (\emph{i.e.}, enclosed in single or double quotation marks).
  }
  \item{ext}{
    File-extension enclosed in single or double quotation marks.
    Acceptable are \verb{"CSV"} and \verb{"csv"} for comma delimited
    variables (\acronym{CSV}) or \verb{"XLS"}, \verb{"xls"}, \verb{"XLSX"},
    and \verb{"xlsx"} for Excel-files.
  }
  \item{na}{
    Character string denoting missing values. Acceptable are \verb{"NA"}
    (not available), \verb{"ND"} (not determined), \verb{"."} (\acronym{SAS}),
    \verb{"Missing"} (Phoenix WinNonlin), and \verb{""} (\acronym{Excel};
    empty cell). Missings will be converted to \verb{NA} in the imported
    data. Defaults to \verb{"."}.
  }
  \item{sep}{
    Variable separator in the \acronym{CSV}-file. Acceptable are \verb{","}
    (comma -- \verb{ASCII 44}), \verb{";"} (semicolon -- \verb{ASCII 59}),
    and \verb{"\\t"} (tabulator -- \verb{ASCII 9}). Defaults to \verb{","}.
  }
  \item{dec}{
    Decimal separator in the \acronym{CSV}-file. Acceptable are \verb{"."}
    (period -- \verb{ASCII 46}) or \verb{","} (comma -- \verb{ASCII 44}).
    Defaults to \verb{"."}.
  }
  \item{logtrans}{
    If \code{TRUE} (default) the raw data (provided in column \verb{PK})
    will be internally log-transformed and used in the calculations.
    If \code{FALSE} the already log-transformed data (provided in the
    column \verb{logPK}) will be used in the calculations.
  }
  \item{ola}{
    Defaults to \code{FALSE}. If \code{TRUE} an outlier analysis based
    on the studentized and standardized residuals of the model estimating
    \code{CVwR} is performed.
  }
  \item{print}{
    If \code{TRUE} (default), the function prints its results to a
    file. If \code{FALSE}, returns a data.frame of results.
  }
  \item{details}{
    Defaults to \code{FALSE}. If \code{TRUE}, the function sends its
    results in 7-digits precision to a data.frame.
  }
  \item{adjust}{
    Defaults to \code{FALSE}.\cr
    If \code{TRUE}, the empiric Type I Error is evaluated via simulations
    (by \link[PowerTOST]{scABEL.ad} of library PowerTOST). Currently
    implemented designs are \verb{TRTR|RTRT}, \verb{TRT|RTR}, and
    \verb{TRR|RTR|RRT}. If the \acronym{TIE} exceeeds the nominal level of
    the test \code{alpha}, \ifelse{html}{\out{&alpha;}}{\eqn{\alpha}{alpha}}
    is iteratively adjusted until
    \ifelse{html}{\out{TIE&nbsp;=&nbsp;alpha&nbsp;&plusmn;&nbsp;1E-6}}{\eqn{TIE~=~alpha~\pm~1E-6}}.\cr
    If \code{ola=TRUE} and outlier(s) found which lead to an -- always lower --
    recalculated \code{CVwR}, the assessment is repeated for its value.
  }
  \item{verbose}{
    Defaults to \code{FALSE}. If \code{TRUE} the ANOVA-table is send to
    the console. If \code{ola=TRUE} additional information about outliers
    are shown.
  }
  \item{ask}{
    Defaults to \code{FALSE}. If \code{TRUE} the user will be asked whether
    an already existing result file (and if outliers are found, the box plot)
    should be overwritten.
  }
  \item{plot.bxp}{
    Only observed if \code{ola=TRUE} and at least one outlier is found.
    If \code{FALSE} (default) the box plot will be shown in the graphics
    device. If \code{TRUE} the box plot will be saved in \acronym{PNG} format
    to \code{path.out}.
  }
  \item{fence}{
    Only observed if \code{ola=TRUE}. The limit for outlier detection as
    a multiplier of the interquartile range. Defaults to 2. Less outliers
    will be detected with higher values (not recommended).
  }
  \item{data}{
    Specification of one of the internal reference datasets (\verb{rds01}
    -- \verb{rds28}). If given, \verb{path.in}, \verb{file}, \verb{set},
    and \verb{ext} are ignored. For its use see the examples.\cr
    If not given, defaults to \code{NULL} (\emph{i.e.}, import data
    from a file).
  }
}

\details{
  The model for the estimation of \code{CVwR} is\cr
  \code{lm(log(PK) ~ sequence + subject\%in\%sequence + period, data = data[data$treatment == "R", ])}\cr
  where all effects are fixed.\cr
  The model for the treatment comparison is\cr
  \code{lm(log(PK) ~ sequence + subject\%in\%sequence + period + treatment, data = data)}\cr
  where all effects are fixed.\cr\cr
  Tested designs
  \itemize{
    \item 4-period 2-sequence full replicates\cr
      \verb{TRTR | RTRT}\cr
      \verb{TRRT | RTTR}\cr
      \verb{TTRR | RRTT}
    \item 2-period 4-sequence replicate\cr
      \verb{TR | RT | TT | RR } (Balaam’s design)
    \item 4-period 4-sequence full replicates\cr
      \verb{TRTR | RTRT | TRRT | RTTR}\cr
      \verb{TRRT | RTTR | TTRR | RRTT}
    \item 3-period 2-sequence full replicates\cr
      \verb{TRT | RTR}\cr
      \verb{TRR | RTT}
    \item 3-period (partial) replicates\cr
      \verb{TRR | RTR | RRT}\cr
      \verb{TRR | RTR } (extra-reference design)
  }
  Data structure
  \itemize{
    \item Columns must have the headers \code{subject}, \code{period},
    \code{sequence}, \code{treatment}, \code{PK}, and/or \code{logPK}.\cr
    Any order of columns is acceptable.\cr
    Uppercase and mixed case headers will be internally converted to lowercase headers.
    \itemize{
      \item \code{subject} must be integer numbers or (any combination of) alphanumerics\cr
      \verb{[A-Z, a-z, -, _, #, 0-9]}
      \item \code{period} must be integer numbers.
      \item \code{sequence} must be contained in the tested designs (numbers or
      \emph{e.g.}, \verb{ABAB} are not acceptable).
      \item The Test treatment must be coded \code{T} and the Reference \code{R}.
    }
  }
}

\value{
Prints results to a file if argument \code{print = TRUE} (default).\cr
If argument \code{print = FALSE}, returns a data.frame with the elements:
  \tabular{ll}{
    \code{Design} \tab \emph{e.g.}, TRTR|RTRT\cr
    \code{Method} \tab A\cr
    \code{n} \tab total number of subjects\cr
    \code{nTT} \tab number of subjects with two treatments of \code{T} (full replicates only)\cr
    \code{nRR} \tab number of subjects with two treatments of \code{R}\cr
    \code{Sub/seq} \tab number of subjects per sequence\cr
    \code{Miss/seq} \tab if the design is unbalanced, number of missings per sequence\cr
    \code{Miss/per} \tab if the design is incomplete, number of missings per period\cr
    \code{alpha} \tab nominal level of the test\cr
    \code{DF} \tab degrees of freedom of the treatment comparison\cr
    \code{CVwT(\%)} \tab intra-subject coefficient of variation of the test treatment (full replicates only)\cr
    \code{CVwR(\%)} \tab intra-subject coefficient of variation of the reference treatment\cr
    \code{sw.ratio} \tab ratio of intrasubject variabilities of \code{T} and \code{R} (full replicates only)\cr
    \code{sw.ratio.CL} \tab upper confidence limit of \code{sw.ratio} (full replicates only)
  }
\itemize{
  \item{If reference-scaling is applicable (\emph{i.e.}, \code{CVwR(\%)} >30\%):}{
    \tabular{ll}{
      \code{EL.lo(\%)} \tab lower expanded limit\cr
      \code{EL.hi(\%)} \tab upper expanded limit
    }
  }
  \item{If reference-scaling is not applicable (\emph{i.e.}, \code{CVwR(\%)} \ifelse{html}{\out{&le;}}{\eqn{\leq}}30\%):}{
    \tabular{ll}{
      \code{BE.lo(\%)} \tab conventional lower limit (\emph{i.e.}, \verb{ 80})\cr
      \code{BE.hi(\%)} \tab conventional upper limit (\emph{i.e.}, \verb{125})
    }
  }
}
  \tabular{ll}{
    \code{CI.lo(\%)} \tab lower confidence limit of the treatment comparison\cr
    \code{CI.hi(\%)} \tab upper confidence limit of the treatment comparison\cr
    \code{PE(\%)} \tab point estimate of the treatment comparison (aka \acronym{GMR})\cr
    \code{CI} \tab assessment whether the \ifelse{html}{\out{100(1&ndash;2&alpha;)}}{\eqn{100(1-2\alpha)}{100(1-2alpha)}} \acronym{CI} lies entirely within the acceptance range (\verb{pass|fail})\cr
    \code{GMR} \tab assessment whether the \acronym{PE} lies entirely within the \acronym{GMR}-restriction 80.00\%\enc{–}{-}125.00\% (\verb{pass|fail})\cr
    \code{BE} \tab mixed (aggregate) assessment whether the study demonstrates bioequivalence (\verb{pass|fail})\cr
    \code{log.half-width} \tab half-width of the confidence interval in log-scale
  }
If \code{ola=TRUE} and at least one outlier was detected:
  \tabular{ll}{
    \code{outlier} \tab outlying subject(s)\cr
    \code{CVwR.new(\%)} \tab intra-subject coefficient of variation of \code{R}; recalculated after exclusion of outlier(s)\cr
    \code{sw.ratio.new} \tab ratio of intrasubject variabilities of \code{T} and \code{R} after exclusion of outlier(s); full replicates only\cr
    \code{sw.ratio.new.CL} \tab upper confidence limit of \code{sw.ratio.new} (full replicates only)
  }
\itemize{
  \item{If reference-scaling is applicable (\emph{i.e.}, \code{CVwR.new(\%)} >30\%):}{
    \tabular{ll}{
      \code{EL.new.lo(\%)} \tab recalculated lower expanded limit\cr
      \code{EL.newhi(\%)} \tab  recalculated upper expanded limit
    }
  }
  \item{If reference-scaling is not applicable (\emph{i.e.}, \code{CVwR.new(\%)} \ifelse{html}{\out{&le;}}{\eqn{\leq}}30\%):}{
    \tabular{ll}{
      \code{BE.new.lo(\%)} \tab conventional lower limit (\emph{i.e.}, \verb{ 80})\cr
      \code{BE.new.hi(\%)} \tab conventional upper limit (\emph{i.e.}, \verb{125})
    }
  }
}
  \tabular{ll}{
    \code{CI.new} \tab assessment whether the \ifelse{html}{\out{100(1&ndash;2&alpha;)}}{\eqn{100(1-2\alpha)}{100(1-2alpha)}} \acronym{CI} lies entirely within the new acceptance range (\verb{pass|fail})\cr
    \code{GMR.new} \tab assessment whether the \acronym{PE} lies entirely within the \acronym{GMR}-restriction 80.00\%\enc{–}{-}125.00\% (\verb{pass|fail})\cr
    \code{BE.new} \tab mixed (aggregate) assessment whether the study demonstrates bioequivalence (\verb{pass|fail})\cr
  }
}

\section{Warning}{
  Files may contain a commentary header. If reading from a \acronym{CSV}-file,
  \emph{each} line of the commentary header \emph{must} start with \verb{"# "}
  (hash-space -- \verb{ASCII 35-32}). If reading from an \acronym{XLS}-file
  all lines preceding the column headers are treated as a comment.
}

\section{Clarification}{
  The \sQuote{graphical} presentation in the result file gives the confidence
  limits with filled black squares and the point estimate as a white rhombus.
  If a confidence limit exceeds the maximum possible expansion limit, it is
  shown as a triangle. Expanded limits are given as double vertical lines.
  Unscaled limits, the \acronym{GMR} restriction, and 100\% are given with
  single vertical lines. The \sQuote{resolution} is approximatelly 0.5\% and
  therefore, not all symbols might be shown. The \acronym{CI} and \acronym{PE} take presedence
  over the limits and the expanded limits over unscaled ones.
}

\note{
  The \acronym{EMA}’s model specified as \sQuote{Method B} in \emph{Annex I} assumes
  equal [\emph{sic}] intra-subject variances of test and reference (like in
  \ifelse{html}{\out{2&times;2&times;2}}{\eqn{2 \times 2 \times 2}{2x2x2}}
  trials) -- even if proven false in one of the full replicate designs (were
  \emph{both} \ifelse{html}{\out{CV<sub>wT</sub>}}{\eqn{CV_{wT}}{CVwT}} and
  \ifelse{html}{\out{CV<sub>wR</sub>}}{\eqn{CV_{wR}}{CVwR}} can be estimated).
  Hence, amongst biostatisticians it is called the \dQuote{crippled model}
  because the replicative nature of the study is ignored.\cr
  The half-width of the \acronym{CI} in log-scale allows a comparison of
  methods (B \emph{v.s.} A) where a higher value \emph{might} point towards
  a more conservative decision. In the provided reference datasets -- with
  one exception -- the conclusion of \acronym{BE} (based on the mixed
  \acronym{CI} and \acronym{GMR} criteria) agrees between \sQuote{Method A}
  and \sQuote{Method B}. However, for the highly incomplete dataset 14
  \sQuote{Method A} was \emph{liberal} (passing by \acronym{ANOVA} but
  failing by the mixed effects model).\cr\cr
  Reference-scaling is acceptable for \ifelse{html}{\out{C<sub>max</sub>}}{\eqn{C_{max}}}
  (immediate release products) and \ifelse{html}{\out{C<sub>max,ss</sub>}}{\eqn{C_{max,ss}}},
  \ifelse{html}{\out{C<sub>&tau;,ss</sub>}}{\eqn{C_{\tau,ss}}}, and
  \ifelse{html}{\out{<sub>partial</sub>AUC}}{\eqn{_{partial}AUC}} (modified
  release products). However, quoting the \acronym{BE} guideline:\cr
    \cite{The applicant should justify that the calculated intra-subject
    variability is a reliable estimate and that it is not the result of
    outliers.}\cr
  Quoting the Q&A on the Revised EMA Bioequivalence Guideline:\cr
    \cite{\ldots a study could be acceptable if the bioequivalence
    requirements are met both including the outlier subject (using the
    scaled average bioequivalence approach and the within-subject CV with
    this subject) and after exclusion of the outlier (using the within-subject
    CV without this subject).\cr
    An outlier test is not an expectation of the medicines agencies but
    outliers could be shown by a box plot. This would allow the medicines
    agencies to compare the data between them.}\cr\cr
  The \acronym{EMA}’s method of reference-scaling for highly
  variable drugs / drug products is currently recommended in other jurisdictions
  as well (\emph{e.g.}, the \acronym{WHO}; \acronym{ASEAN} States, Australia,
  Brazil, Egypt, the Russian Federation, the Eurasian Economic Union,
  the East African Community, New Zealand).\cr\cr
  The \acronym{WHO} accepts reference-scaling for AUC (4-period full replicate
  studies are mandatory in order to assess the variability associated with each product).
  It is an open issue how this assessment should be done. In Population Bioequivalence (\acronym{PBE})
  and Individual Bioequivalence (\acronym{IBE}) the
  \ifelse{html}{\out{<em>s<sub>wT</sub></em>}}{\eqn{s_{wT}}}/\ifelse{html}{\out{<em>s<sub>wR</sub></em>}}{\eqn{s_{wR}}}
  ratio was assessed and similar variability was concluded for a ratio
  within 0.667–1.500. However, the power of comparing variabilities
  in a study designed to demonstrate \acronym{ABE} is low. This was one of the
  reasons why \acronym{PBE} and \acronym{IBE} were not implemented
  in regulatory practice. An alternative approach is given in the
  \acronym{FDA}’s guidance on warfarin. Variabilities are
  considered comparable if the upper confidence limit of
  \ifelse{html}{\out{<em>&sigma;<sub>wT</sub></em>}}{\eqn{\sigma_{wT}}}/\ifelse{html}{\out{<em>&sigma;<sub>wR</sub></em>}}{\eqn{\sigma_{wR}}} is less than or equal to 2.5.\cr\cr
  \strong{Program offered for Use without any Guarantees and Absolutely No Warranty. No Liability is accepted for any Loss and Risk to Public Health Resulting from Use of this R-Code.}
}

\author{
Helmut \enc{Schütz}{Schuetz}, Michael Tomashevskiy, Detlew Labes
}

\references{

  European Medicines Agency, Committee for Medicinal Products for Human Use. \emph{Guideline on the Investigation of Bioequivalence.} London, 20 January 2010. \href{https://www.ema.europa.eu/en/documents/scientific-guideline/guideline-investigation-bioequivalence-rev1_en.pdf}{CPMP/EWP/QWP/1401/98 Rev. 1/ Corr **}

  3\ifelse{html}{\out{<sup>rd</sup>}}{\eqn{^{rd}}} \acronym{EGA} Symposium on Bioequivalence.
  \emph{Questions and Answers on the Revised \acronym{EMA} Bioequivalence Guideline.} London, 1 June 2010. \href{https://www.medicinesforeurope.com/wp-content/uploads/2016/03/EGA_BEQ_QA_WEB_QA_1_32.pdf}{open access}

  European Medicines Agency. \emph{Clinical pharmacology and pharmacokinetics: questions and answers. 3.1 Which statistical method for the analysis of a bioequivalence study does the Agency recommend? Annex I}. London, 21 September 2016. \href{https://www.ema.europa.eu/en/documents/other/31-annex-i-statistical-analysis-methods-compatible-ema-bioequivalence-guideline_en.pdf}{EMA/582648/2016}

 European Medicines Agency, Committee for Medicinal Products for Human Use. \emph{Guideline on the pharmacokinetic and clinical evaluation of modified release dosage forms.}London, 20 November 2014. \href{https://www.ema.europa.eu/en/documents/scientific-guideline/guideline-pharmacokinetic-clinical-evaluation-modified-release-dosage-forms_en.pdf}{EMA/CPMP/EWP/280/96 Corr1}

  World Health Organization, Prequalification Team: medicines. \emph{Guidance Document: Application of reference-scaled criteria for AUC in bioequivalence studies conducted for submission to PQTm.} Geneva, 22 November 2018. \href{https://extranet.who.int/prequal/sites/default/files/documents/AUC_criteria_November2018.pdf}{open access}

  Food and Drug Administration, Office of Generic Drugs. \emph{Draft Guidance on Warfarin Sodium.} Rockville, December 2012. \href{https://www.accessdata.fda.gov/drugsatfda_docs/psg/Warfarin_Sodium_tab_09218_RC12-12.pdf}{open access}

  Labes D, \enc{Schütz}{Schuetz} H. \emph{Inflation of Type I Error in the Evaluation of Scaled Average Bioequivalence, and a Method for its Control.} Pharm Res. 2016;33(11):2805--14. \doi{10.1007/s11095-016-2006-1}
}

\seealso{
  \tabular{ll}{
    \code{\link{method.B}} \tab evaluation by a linear mixed effects model\cr
    \code{\link{ABE}} \tab evaluation for conventional (unscaled) Average Bioeqivalence
  }
}

\examples{
# Importing from a CSV-file, using most of the defaults: variable
# separator colon, decimal separator period, no outlier-analyis,
# print to file.
# Note: You must adapt the path-variables. The example reads from
# the data provided by the library. Write-permissions must be granted
# for 'path.out' in order to save the result file. If 'path.out' is
# not specified, results are written to the home folder.
\donttest{
path.in <- paste0(find.package("replicateBE"), "/extdata/")
method.A(path.in = path.in, file = "DS", set = "01", ext = "csv")
# Should result in:
#   CVwT               :  35.16\%
#   swT                :   0.34138
#   CVwR               :  46.96\% (reference-scaling applicable)
#   swR                :   0.44645
#   Expanded limits    :  71.23\% ... 140.40\% [100exp(±0.760·swR)]
#   swT / swR          :   0.7647 (similar variabilities of T and R)
#   sw-ratio (upper CL):   0.9324 (comparable variabilities of T and R)
#   Confidence interval: 107.11\% ... 124.89\%  pass
#   Point estimate     : 115.66\%              pass
#   Mixed (CI & PE)    :                      pass
#
# Internal reference dataset 01 used and results to the home
# folder. Additional outlier-analyis and box plot saved as PNG
# (accidental overwriting prevented).
method.A(ola = TRUE, ask = TRUE, plot.bxp = TRUE, data = rds01)
# Should give the same as above. Additionally:
#   Outlier fence      :  2×IQR of studentized residuals.
#   Recalculation due to presence of 2 outliers (subj. 45|52)
#   CVwR (outl. excl.) :  32.16\% (reference-scaling applicable)
#   swR (recalculated) :   0.31374
#   Expanded limits    :  78.79\% ... 126.93\% [100exp(±0.760·swR)]
#   swT / swR (recalc.):   1.0881 (similar variabilities of T and R)
#   sw-ratio (upper CL):   1.3282 (comparable variabilities of T and R)
#   Confidence interval: pass
#   Point estimate     : pass
#   Mixed (CI & PE)    : pass
# Same dataset. Show information about outliers and the ANOVA-table.
method.A(ola = TRUE, verbose = TRUE, data = rds01)}
# Generate the data.frame of results (7-digits precision) and show
# in the console
x <- method.A(ola = TRUE, details = TRUE, print = FALSE, data = rds01)
print(x, row.names = FALSE)
#
# Assess the Type I Error and iteratively adjust alpha if necessary.
# Not run: due to timing policy of CRAN for examples
\donttest{
method.A(adjust = TRUE, data = rds01)}
# Should give in the result file:
#   Assessment of the empiric Type I Error (TIE); 1,000,000 studies simulated.
#     TIE not > nominal 0.05; consumer risk is controlled.
#
# Same with recalculation based on outliers, iteratively adjust alpha
# if necessary
\donttest{
method.A(ola = TRUE, adjust = TRUE, data = rds01)}
# Should give in the result file:
#   Assessment of the empiric Type I Error (TIE) based on original CVwR;
#   1,000,000 studies simulated.
#     TIE not > nominal 0.05; consumer risk is controlled.
#   Assessment of the empiric Type I Error (TIE) based on recalculated CVwR;
#   1,000,000 studies in each of the 8 iterations simulated.
#     TIE for alpha 0.050000         : 0.07018
#     TIE for adjusted alpha 0.033416: 0.05000
#
# Repeat the evaluation with the adjusted alpha.
\donttest{
method.A(alpha = 0.033416, ola = TRUE, adjust = TRUE, data = rds01)}
# Should give in the result file:
#   alpha              :   0.033416 (93.3168\% CI)
#   Confidence interval: 106.16\% ... 126.00\%  pass
#   Point estimate     : 115.66\%              pass
#   Mixed (CI & PE)    :                      pass
#   Assessment based on recalculated CVwR 32.16\%
#   Confidence interval: pass
#   Point estimate     : pass
#   Mixed (CI & PE)    : pass
#   Assessment of the empiric Type I Error (TIE) based on original CVwR;
#   1,000,000 studies simulated.
#     TIE not > nominal 0.05; consumer risk is controlled.
#   Assessment of empiric Type I Error (TIE) based on recalculated CVwR;
#   1,000,000 studies in each of the 8 iterations simulated.
#     TIE for alpha 0.033416         : 0.05000
#     TIE not > nominal 0.05; consumer risk is controlled.
}
