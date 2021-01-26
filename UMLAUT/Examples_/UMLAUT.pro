FUNCTION UMLAUT, AI, BI, AO, BO, SO, NVV, CLN=CLN, MIN_CLN=MIN_CLN, TYPE_CLN=TYPE_CLN, AVERAGE=AVERAGE, test=test,fit_thresh=fit_thresh,scope=scope,CLAS_VECT=CLAS_VECT,CLAS_PROB=CLAS_PROB,CLAS_UNC=CLAS_UNC,GETPDF=GETPDF, X_PDF=X_PDF, PDF=PDF,def_x_PDF=def_x_PDF,PSM=PSM,SO_TYPE=SO_TYPE,OPTIMIZE_DIM=OPTIMIZE_DIM,BAL=BAL,OUT_SCALINGS=OUT_SCALINGS,IN_SCALINGS=IN_SCALINGS

; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;           UMLAUT 1.0
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; Unsupervised Machine Learning Algorithm based on Unbiased Topology 
; By Ivano Baronchelli, May/2019 - April/2020
; See also: Baronchelli et al. (2021)

; UMLAUT is a variant of the KNN (K-closest neighbor) algorithm.
; - Given a set of reference data points (training set), for which
;    the value of N+1 parameters is known,
; - given one analysis data point with N parameters known and the
;    (N+1)-th parameter unknown,
; -> UMLAUT computes the value of the (N+1)-th parameter for the
;    analysis data point. To this purpose, UMLAUT finds the closest
;    data-points, from a reference sample, in a N-dimensional space
;    "associated" (see NOTE 1 below) with the parameter space.
;    After finding the closest data points, the unknown parameter
;    is obtained as the combination of the values assumed by the
;    closest reference data points, along the (N+1)-th dimension. 
; >> NOTES:
;    1) the "associated" N-dimensional space is NOT the parameter
;       space itself. During the training phase,
;      - every dimension is "ordinalized": the actual value assumed
;         by each of the M data points of the reference sample along
;         the N dimensions is replaced by the position (1,2,...,M)
;         of the data point itself in a ordered scale
;      - The N ordinalized dimensions are scaled following a
;         weighting process that tries to minimize the dispersion
;         associated with the estimated (N+1)-th parameter.
;    2) The simplest configuration, with only one unknown
;       parameter (the [N+1]-th), is described above. In reality,
;       UMLAUT can be used to determine many (no limitations)
;       unknown parameters. Obviously, the same parameters must be
;       known for the data points of the reference sample.
;    3) UMLAUT is originally designed for REGRESSION purposes, but
;       it can also be used for CLASSIFICATION. However, the current
;       version of UMLAUT does not support the weighting of the input
;       parameters (dimensions) when UMLAUT is used for
;       classification. 
;    4) UMLAUT can be trained and tested using the same sample (the
;       keyword "test" must be set in this case). As demonstrated in
;       Baronchelli et al. (2021), This configuration does not
;       introduce overfitting problems, as the training is performed
;       using a "leave one out" strategy, wehere the data point left
;       out is properly the data point tested.
  
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; INPUT PARAMETERS:
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; AI= input array AI[N,M] characterized by:
;      --> N dimensions (indipendent input parameters)
;      --> M elements (elements or data points used to train the
;          algorithm). 
;      The NxM values in AI are those assumed by the N input
;      parameters for each of the M data point of the training set.
;      For every data point in this array, the value of the
;      indipendent variable B (the N+1 unknown parameter) is known.
; BI= input vector BI[M] containing the values assumed by the
;     M elements of the training sample along the (N+1)-th independent
;     dimension (B).
;     If there are more than just one independent variable that the
;     user wants to estimate, then BI[M,O] is a MxO array. Here, "O"
;     is the number of parameters that the user wants to estimate for
;     the analysis data point (they are known for the data points
;     in the training sample). When UMLAUT is used for classification
;     purposes, then BI contains the labels associated with the
;     training data points
; AO= Input array AO[N,L] similar to AI, characterized by:
;      --> N dimensions (number of indipendent input parameters)
;      --> L elements (number of analysis data points for which the
;          user wants to compute the indipendent variable B). 
;          The parameter B will be estimated for the L datapoints;
; NVV= Input N dimensional vector specifying, for each of the N
;       dimensions considered, the Not Valid Values that should not
;       be considered (example: -99., 0, etc...). When one of the 
;       dimensions, for a certain datum, assumes the value specified
;       in NVV, that dimension is not considered.
; CLN= Number of closest elements to be considered for evaluating 
;       the indipendent variable. Default is 10
; CLN_MIN= when TYPE_CLN is set to "min_max", CLN_MIN sets the minimum
;          value of CLN to be considered (whereas CLN is considered
;          the maximum, in this case). This parameter is not taken
;          into account when the scope parameter is set to
;          "classification". 
; TYPE_CLN= if this keyword is not set, or if it is set to the default
;           option 'fixed', then CLN represents the amount of closest
;           datapoints that will be considered by UMLAUT to determine
;           BO. With TYPE_CLN='fixed' (or not set), the CLN_MIN option
;           is not taken into account. If TYPE_CLN is set to
;           "min_max", then the algorithm automatically finds, for
;           each element in AO, the best value of CLN that should be
;           used, ranging from CLN_MIN and CLN (that are set by the
;           user).  TYPE_CLN is set to 'fixed' when
;           scope='classification'.
; AVERAGE= Type of average to be considered. Options are: "median",
;           "mean", "mode", "weighted", "fit".
;           - Default option when scope="regression" is "mean".
;           - Default option when scope="classification" is "mode".
;           Besides "median" and "mean", whose meaning is clear, the
;           "weighted" option distributes the weights normally, with
;           CLN assumed to be sigma of that distribution. In order of
;           N-dimensional distance, the i-th element is weigthed as:
;           W=exp{- (i^2) /(2*CLN^2)}
;           Using the option "fit", B (the [N+1]-th parameter) is
;           obtained from a N-dimensional linear fit of the closest
;           reference data points. This option is particularly useful
;           when the values assumed by some of the N parameters of the
;           analysis data point(s) are located at the border of (or
;           outside) the range of values expressed by the training
;           sample. After selecting the closest reference elements,
;           the data points having the (N+1)th parameter that differs
;           from the average more than "fit_thresh" times the
;           dispersion, are excluded from the fit. The fit_thresh
;           paramter is optional.
;           The "mode" option is valid only for "classification"
;           purposes (scope="classification"), and it represents
;           the default option in this configuration. However, in this 
;           case, also the "weighted" option is available. When UMLAUT
;           is used for classification purposes, then the options
;           "median", "mean" and "fit" have no sense, as the output is
;           not a real number but it is a label. In this case, the
;           output label can be obtained as the "mode" (default) of the
;           closest data points of the training set or as the
;           "weighted" mode. The weighting factor is computed as
;           described above and it takes into account the distances
;           from the analysis data point.  
; BAL= when this keyword is set (/BAL), (only for scope=classification
;       configuration), the estimated output label of the analysis data
;       point is obtained by weighting the probabilities associated to
;       each possible label (CLAS_PROB output) taking into account the
;       fraction of training data points that are labelled with the
;       same label, with respect to the total. 
; test= setting this keyword, the closest datapoint of the training
;        set is not taken into account when computing the output
;        parameter (BO). This configuration should be used when
;        UMLAUT is trained and tested on ovrelapping or even identical
;        datasets. Notice that training UMLAUT in this way does not
;        introduce overfitting problems, as the "leave one out"
;        testing strategy is adopted (See Baronchelli et al. 2021).
; scope= set this keyword to "regression" or to "classification".
;         Defaulft is regression.
;         - If set to regression, BI must contain real numbers
;         (example BI[0]=3.45, BI[1]=2.21, BI[3]=1.5, BI[4]=5.7
;         etc...). In this case, UMLAUT provides the best estimation
;         of the output parameter (BO array) as a real number.
;         - If set to "classification", BI must contain a discrete
;         classification for each of the single data point of the
;         training set (example BI[0]='OII', BI[1]='Ha',
;         BI[3]='Hb',BI[4]='Ha', etc...). Moreover,
;           > in the input vector "CLAS_VECT", the user must specify
;             the different possibilities (labels);
;           > in the output array "CLAS_PROB", UMLAUT provides the
;             probabilities associated to each of the possible input 
;             labels.
;           > in the output array "CLAS_UNC", UMLAUT provides the
;             poissonian uncertainties associated to each of the
;             probabilities indicated in "CLAS_PROB".
;         Example:
;           > CLAS_VECT=["Ha", "Hb", "OIII", "OII"] (input vector);
;           > CLAS_PROB=[0.6,0.1,0.2,0.1] (output vector for one
;             single analysis data point).
;           > CLAS_UNC=[0.12,0.02,0.03,0.01] (output vector for one
;             single analysis data point).
;         Under the "classification" configuration, TYPE_CLN is set to
;         "fixed" and the AVERAGE keyword is not considered (the
;         output is not an average).   
;GETPDF=setting this keyword, (/GETPDF), UMLAUT provides an output
;        PDF for the output parameter BO (See also the "X_PDF", "PDF",
;        and "PSM" parameters. The PDF is not provided under the
;        scope="classification" configuration.
;def_x_PDF=setting this keyword (/def_x_PDF) "X_PDF" (see below) is
;           not considered as an input. Instead, x_PDF will be
;           overwritten by a default scale automatically selected by
;           UMLAUT. If scope="classification", this parameter is not
;           taken into account.
;PSM=smoothing factor applied to the output PDF. A good compromise
;     for this parameter is PSM ~1/1000 - 1/200 of the total number
;     of data points in the training set. If scope="classification",
;     this parameter is not taken into account.
;OPTIMIZE_DIM=set to "yes" (default) to let the algorithm free to
;              weight the input dimensions after their
;              ordinalization. If scope="classification", dimensions
;              are not optimized.
;SO_TYPE=Type of uncertainties that will be incuded in the output
;         vector SO These uncertainties are associated with the
;         estimated values of the output parameter B (BO). OPTIONS: 
;         sigma --> sigma(default),
;         perc  --> percentiles 16%-84%,
;         aver  --> average between sigma and symmetrized percentiles
;IN_SCALINGS=optional NxO elements input vector containing the weights
;             associated to each of the N input parameters
;             (dimensions). If more than one single output parameter B
;             has to be estimated (O>1), than the user can provide a
;             different set of weights, one for each of the output
;             parameters to estimate. Notice that the this vector can
;             be obtained from previous runs of UMLAUT. In fact, the
;             output vector OUT_SCALINGS provides the list of weights
;             used for each of the analysis data points. Hence,
;             each of the N elements of IN_SCALINGS can be obtained
;             as the average weights reported in OUT_SCALINGS (along
;             each of the N dimensions), computed in previous
;             runs. In an iterative strategy, at each run of UMLAUT,
;             the IN_SCALING values of the previous iterations can be
;             multiplied for the weights obtained from the newer
;             iterations, in order to obtain more and more precise
;             weights at the end. 
;fit_thresh=optional parameter to be used when "AVERAGE" is set to
;            "fit".  After selecting  the closest reference elements,
;            the data points having the (N+1)th parameter that differs
;            from the average more than "fit_thresh" times the
;            dispersion, are excluded from the fit. The fit_thresh
;            paramter is optional.
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; OUTPUT PARAMETERS:
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; BO=output vector BO[L] with L elements. It contains the output
;     estimations of the (N+1)th parameter (B) for all the analysis
;     data points. For each of the analysis data point, the values of
;     the N parameters are specified in the input array AO (see
;     above).  If there are more than just one independent variable
;     that the user wants to estimate, then BO is a LxO array. Here,
;     "O" is the number of parameters that the user wants to estimate
;     for the analysis data point (they must be known for the data
;     points in the training sample).  
; SO=output vector SO[L] containing the values of dispersion
;     associated with the estimations of the independent parameter B,
;     (specified in BO). The type of uncertainty that the user wants
;     to use (sigma/percentiles) can be specified in the "SO_TYPE"
;     array. 
; CLAS_VECT=see (input parameter "scope" )
; CLAS_PROB=see (input parameter "scope" )
; CLAS_UNC=see (input parameter "scope" )
; PDF= Output Probability Distribution Functions. One PDF for every
;      datum is given in utput. The PDF is computed in the binning
;      decided by the user if X_PDF is set to a particular vector. 
; OUT_SCALINGS=LxNxO vector specifying, for each of the L analysis
;               elements and for each of the N input dimensions
;               (parameters), the weight used to compute the output
;               value of the unknown paramter B. If more than one
;               output parameter has to be estimated (O>1), then the
;               weights are estimated for each of the output
;               parameters computed.
; -------------------------------------------------------------------

; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; INPUT/OUTPUT PARAMETERS:
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; X_PDF= x values for the output Probability Distribution Functions.
;        > IF the "def_x_PDF" keyword is set, X_PDF is considered an
;        output and it corresponds to the vector BI.
;        > if the "def_x_PDF" keyword is NOT set, X_PDF is an input
;        vector that should be defined by the user.
;        When the user wants to estimate just one single output
;        parameter (i.e., BI and BO are LxO arrays with O=1), then
;        X_PDF is a one dimensional vector made of H elements (the
;        number of elements H depends on how the user set "X_PDF"
;        itself and "def_x_PDF". Instead, when O>1, X_PDF is a HxO
;        array of elements.
; --------------------------------------------------------------------
; ADDITIONAL NOTES:
; - When UMLAUT evaluates one of the input dimensions, if there are
;    too few elements in the training set with a valid value along the
;    same dimension (less than 3*CLN), then the dimension is not
;    considered at all. 
; - In the classification configuration, the output array BO is always
;    consiered as an array of strings. 
; --------------------------------------------------------------------
; Dimensions and corresponding cycling variables in this program:
; O --> OO -  output dimensios to estimate
; L --> LL -  analysis data points
; N --> EE and NN -  known dimensions 
; --------------------------------------------------------------------



;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
 ; INTERNAL PARAMETERS
;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
 N_EXP_step=+1. ; "expansion" or "scaling" factor
 Prize1=0.2 ; Positive prize to dimensions that decrease
            ; the sigma on the output parameter when expanded
 Prize2=-0.1 ; negative prize to dimensions that increase
             ; the sigma on the output parameter when expanded 
 Prize3=0.4 ; Special prize for the dimension that provides
            ; the lowest (best) value of sigma when expanded
 MAX_MM=25 ; Maximum number of iterations per analysis element
;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM


if not(keyword_set(scope)) then scope='regression'

; IF AO includes only one analysis element,
; and it is not set as an array
; but just as a one-dimensional vector
if n_elements(size(AO,/dimensions)) lt 2 then begin
 print, "UWUWUWUWUWUWUWUW"
 print, "UMLAUT warning:"
 print, "One-dimensional array AO detected, whereas a NxL array is expected."
 print, "The elements of AO will be considered as if they were the values "
 print, "assumed along the the N-th dimensions by one single analyis data point"
 print, "UWUWUWUWUWUWUWUW"
 AO_tmp=AO
 AO=AI[0,*]
 AO[0,*]=AO_tmp
endif


N_DIM=n_elements(AI[0,*]) ; Number of input dimensions (N)
O_DIM=n_elements(BI[0,*]) ; Number of output dimensions (O)
M_ELE=n_elements(AI[*,0]) ; Number of training data points (M)
L_ELE=n_elements(AO[*,0]) ; Number of analysis data points (L)



SO=dblarr(L_ELE,O_DIM)
SO[*,*]=-99.
if not(keyword_set(SO_TYPE)) then SO_TYPE="sigma" ; Default for SO_TYPE

if scope eq 'regression' then begin
 BO=dblarr(L_ELE,O_DIM)
 BO[*,*]=-99.
endif

if scope eq 'classification' then begin
 BO=strarr(L_ELE,O_DIM)
 BO[*,*]="-99."
 TYPE_CLN='fixed'
 CLAS_PROB=dblarr(L_ELE,n_elements(CLAS_VECT),O_DIM)
 CLAS_UNC=dblarr(L_ELE,n_elements(CLAS_VECT),O_DIM)
endif

if not(keyword_set(AVERAGE)) and scope eq 'regression' then AVERAGE='mean' ; Default type of average is the mean
if not(keyword_set(AVERAGE)) and scope eq 'classification' then AVERAGE='mode' ; Default type of average is the mode

if not(keyword_set(CLN)) then CLN=10 ; Number of closest sources to be considered

if not(keyword_set(test)) then CLOSEST=0
if keyword_set(test) then begin
 CLOSEST=1
 CLN=CLN+1
endif


if not(keyword_set(TYPE_CLN)) then TYPE_CLN='fixed'

if TYPE_CLN eq 'fixed' then MIN_CLN=CLN

MIN_CLN=CLOSEST+MIN_CLN

if not(keyword_set(OPTIMIZE_DIM)) then OPTIMIZE_DIM='yes'

; Overall sigma of the BI distribution 
if scope eq 'regression' then begin
 SIGMA_COMPARE=dblarr(O_DIM)
 OO=0L  
 while OO lt O_DIM do begin
  SIGMA_COMPARE_perc=percentiles(BI[*,OO], value=[0.16,0.84])
  SIGMA_COMPARE_el=0.5*abs(SIGMA_COMPARE_perc[1]-SIGMA_COMPARE_perc[0])
  SIGMA_COMPARE[OO]=(SIGMA_COMPARE_el+SIGMA(BI[*,OO]))/2.
 OO=OO+1
 endwhile
endif

PDF=0.
if keyword_set(GETPDF) and scope eq 'regression' then begin
 if keyword_set(def_x_PDF) then begin
  X_PDF=dblarr(n_elements(BI[*,0]),O_DIM)
  PDF=dblarr(L_ELE,n_elements(BI[*,0]),O_DIM)
 endif
 if not keyword_set(def_x_PDF) then begin
  X_PDF=X_PDF
  PDF=dblarr(L_ELE,n_elements(X_PDF[*,0]),O_DIM)
 endif

 ;-----------------------------------------
 X_PDF0=dblarr(n_elements(BI[*,0]),O_DIM)
 OO=0L
 while OO lt O_DIM do begin
  X_PDF0[*,OO]=BI[*,OO]
  X_PDF0[*,OO]=X_PDF0[sort(X_PDF0[*,OO]),OO]
  UNIDX=uniq(X_PDF0[*,OO])
  X_PDF0[0:n_elements(UNIDX)-1,OO]=X_PDF0[UNIDX,OO]
; if n_elements(X_PDF0[*,OO])-1 gt n_elements(UNIDX) then begin
  if n_elements(X_PDF0[*,OO]) gt n_elements(UNIDX) then begin
   X_PDF0[n_elements(UNIDX):n_elements(X_PDF0[*,OO])-1,OO]=min(X_PDF0[*,OO])-99.
  endif
  if keyword_set(def_x_PDF) then begin
   X_PDF[*,OO]=X_PDF0[*,OO]
  endif
  OO=OO+1
 endwhile
;-----------------------------------------
endif

; TEST TEST TEST TEST TEST TEST TEST
 OUT_SCALINGS=dblarr(L_ELE,n_elements(AI[0,*]),O_DIM)
 OUT_SCALINGS[*]=-99.
; TEST TEST TEST TEST TEST TEST TEST

; OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
;           ORDINALIZATION
; OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO

; Rescale the input N dimensions to a constant density scale). This
; transforms the physical scale along each dimension into
; an ORDINAL SCALE 
AI_NEW=AI
AO_NEW=AO ; Values are set in the next passage

EE=0L
WHILE EE LT N_DIM DO BEGIN  ; Cycle on the N dimensions
 ;--------------------------------------
 ;1) SET Nan to NVV (Not valid values)
 ADD_NVV_AI_idx=where(AI[*,EE] ne AI[*,EE])
 ADD_NVV_AO_idx=where(AO[*,EE] ne AO[*,EE])
 if ADD_NVV_AI_idx[0] ne -1 then AI[ADD_NVV_AI_idx,EE]=NVV[EE]
 if ADD_NVV_AO_idx[0] ne -1 then AO[ADD_NVV_AO_idx,EE]=NVV[EE]

 ;---------------------------------------
 ; 2 Set the values of the rescaled AI array
 IDX_V=where(AI[*,EE] ne NVV[EE]); Valid values
 IDX1=sort(AI[IDX_V,EE]) ; Sorted indexes (only for valid values)
 AI_NEW[IDX_V[IDX1],EE]=findgen(n_elements(IDX1))/double(n_elements(IDX1))
 
   ;---------------------------------------
 ; 3) Set the values for the rescaled AO array
 LL=0L
 WHILE LL LT L_ELE DO BEGIN  ; Cycle on the analysis elements (data points)
  AO_NEW[LL,EE]=NVV[EE]

  IF AO[LL,EE] ne NVV[EE] THEN BEGIN ; only for valid AO values

   Dist=AI[*,EE]-AO[LL,EE]

   IDXV1=where(Dist gt 0 and AI[*,EE] ne NVV[EE])
   IDXV2=where(Dist lt 0 and AI[*,EE] ne NVV[EE])
   V1=min(abs(Dist))
   V2=V1
   IDXV1B=[-1]
   IDXV2B=[-1]
   if IDXV1[0] ne -1 then V1=min(Dist[IDXV1],IDXV1B); min index written in IDXV1B
   if IDXV2[0] ne -1 then V2=max(Dist[IDXV2],IDXV2B); min index written in IDXV2B
   ; IDXV1B=where(Dist eq V1)
   ; IDXV2B=where(Dist eq V2)
   IDXV1B=IDXV1B[0]
   IDXV2B=IDXV2B[0]

  
   if IDXV1[0] ne -1 and IDXV2[0] ne -1 then AO_NEW[LL,EE]=interpol([AI_NEW[IDXV1[IDXV1B[0]],EE],AI_NEW[IDXV2[IDXV2B[0]],EE]],[AI[IDXV1[IDXV1B[0]],EE],AI[IDXV2[IDXV2B[0]],EE]],AO[LL,EE])
   ; KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
   if IDXV1[0] eq -1 and IDXV2[0] ne -1 then AO_NEW[LL,EE]=AI_NEW[IDXV2[IDXV2B[0]],EE]
   if IDXV1[0] ne -1 and IDXV2[0] eq -1 then AO_NEW[LL,EE]=AI_NEW[IDXV1[IDXV1B[0]],EE]
   if IDXV1[0] eq -1 and IDXV2[0] eq -1 then AO_NEW[LL,EE]=NVV[EE];min(AI_NEW[EE,*])
   ; KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK

  ENDIF

  LL=LL+1
 ENDWHILE

 EE=EE+1
ENDWHILE

; OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
;           ORDINALIZATION - END -
; OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO


; OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
;   Evaluate valid data points to compare with
; OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO

LL=0L
WHILE LL LT L_ELE DO BEGIN ; Cycle on the evaluation elements

 ; Valid dimensions N for the data point LL under evaluation.
 VDK=where(AO_NEW[LL,*] ne NVV) ; indexes of Valid Dimensions for this LL
;                               (Dimensions for which this analysis
;                               datum (LL) has a valid value) 

 if VDK[0] ne -1 then begin ; if there is one valid dimension at least...
 
; Only valid values in arrays AI and BI will be considered.
; Only input dimensions N for which the LL element has a valid
; value will be taken into account. Sources in the training set
; with no valid values in one of these VDK dimensions will not be
; considered, UNLESS there are too few data points to compare with.

 VECT_VALID_M=lonarr(M_ELE) ; 1=valid data point. 0=not valid
 VECT_VALID_M[*]=1

 ; FIND VALID COMPARISON DATA POINTS IN THE TRAINING SET
 NN=0L
 WHILE NN LT n_elements(VDK) DO BEGIN ; Cycle on the valid dimensions
  NVM=where(AI_NEW[*,VDK[NN]] eq NVV[NN]) ; not valid training data points (total=M) 
  ;1) Don't consider this dimension if there are too few datapoints available:
  ;    in the training set:
  if n_elements(AI_NEW[*,VDK[NN]])-n_elements(NVM) lt 3.*CLN then begin
     VDK=VDK[where(VDK ne NN)]; remove index from VDK (don't consider this dimension)
  endif else begin
  ;2) Otherwise, remove all the data points of the training set that 
  ;    don't have the same dimensions available: 
   if NVM[0] ge 0 then VECT_VALID_M[NVM]=0
  endelse
  NN=NN+1
 ENDWHILE

 M_ELE_OK_idx=where(VECT_VALID_M eq 1) ; indexes of usable training datapoints
 M_ELE_OK=n_elements(M_ELE_OK_idx) ; Number of usable training datapoints

 ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
 ;           DIMENSIONS SCALING 
 ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
 N_EXP=dblarr(n_elements(VDK),O_DIM)
 N_EXP[*,*]=1.
 N_EXP_step=+1. ; "expansion" or "scaling" factor
 ;Prize1=0.2
 ;Prize2=-0.1
 ;Prize3=0.4

 vect_exp=lonarr(n_elements(VDK),O_DIM)
 vect_exp[*,*]=0
 EXIT=strarr(O_DIM)
 EXIT[*]='no'

 AI2_TOT=dblarr(M_ELE_OK,O_DIM)
 DISTANCES=dblarr(M_ELE_OK,O_DIM); multi-dimensional distances from data point K
 AI2_TOT_1EXP=dblarr(M_ELE_OK,n_elements(VDK),O_DIM)
 DISTANCES_1EXP=dblarr(M_ELE_OK,n_elements(VDK),O_DIM) ; multi-dimensional distances from data point K (one dimension expanded)
 IDX_SD_X=lonarr(M_ELE_OK,O_DIM)  ; Indexes of sorted distances along each dimension
 IDX_SD_1EXP=lonarr(M_ELE_OK,n_elements(VDK),O_DIM)  ; 
 NEW_CLN=lonarr(n_elements(VDK),O_DIM)

 PC_SIG_B_SAVE=dblarr(n_elements(VDK),O_DIM)

 NEW_CLN[*,*]=CLN
 AI_NEW2=AI_NEW
 AO_NEW2=AO_NEW


 
; MAX_MM=MAX_MM_SET;25
 MM=0L

 WEXIT=where(EXIT eq 'no')
 WHILE MM lt MAX_MM and WEXIT[0] ne -1 DO BEGIN

 AI2_TOT[*,WEXIT]=0.
 DISTANCES[*,WEXIT]=0.
 AI2_TOT_1EXP[*,*,WEXIT]=0.
 PC_SIG_B_SAVE[*,*]=0.

 DISTANCES_1EXP[*,*,WEXIT]=0.
 IDX_SD_X[*,WEXIT]=-99
 IDX_SD_1EXP[*,*,WEXIT]=-99
      
   
 OO=0L
 while OO lt O_DIM do begin ; Cycle on the output DIMENSIONS
  if EXIT[OO] eq 'no' then begin
   ; TEST TEST TEST TEST TEST TEST TEST TEST TEST
   if keyword_set(IN_SCALINGS) then begin
   N_EXP[*,OO]=IN_SCALINGS[VDK,OO]
   endif
   ; TEST TEST TEST TEST TEST TEST TEST TEST TEST

   NN=0L
   WHILE NN LT n_elements(VDK) DO BEGIN ; Cycle on the available DIMENSIONS
    ; Method: uses only calibration datapoints with a valid value for 
    ; all the same N-dimensions (listed in the VDK vector) as those  
    ; available for the evaluation element
    Projected_D0=AI_NEW[M_ELE_OK_idx,VDK[NN]]-AO_NEW[LL,VDK[NN]] ; projected distances
    Projected_D0=Projected_D0*N_EXP[NN,OO] ; NOTE: PROJECTED DISTANCES ARE EXPANDED, not the original coordinates!
    AI2_TOT[*,OO]=AI2_TOT[*,OO]+(Projected_D0)^2 ; Dimensions not expanded (MM=0) or expanded as best solution indicates
    AI2_TOT_1EXP[*,NN,OO]=((Projected_D0*1.*(N_EXP[NN,OO]+N_EXP_step))^2)-(Projected_D0^2) ; one additional dim. expansion (completed below)
    NN=NN+1 
   ENDWHILE ; WHILE on the N (input) DIMENSIONS

  DISTANCES[*,OO]=sqrt(AI2_TOT[*,OO]) ; multi-dimensional distances from data point LL

  IDX_SD_OO=SORT(DISTANCES[*,OO]) ; Indexes of sorted distances
  ; Sigma for the elements in the selection (no dimension expansion)
  ;PSIG_A=percentiles(BI[M_ELE_OK_idx[IDX_SD_OO[CLOSEST:CLN-1]],OO], value=[0.16,0.84])
  ;PERCEN_SIGMA_A=(PSIG_A[1]-PSIG_A[0])/2.
  if scope eq 'regression' then PERCEN_SIGMA_A=SIGMA(BI[M_ELE_OK_idx[IDX_SD_OO[CLOSEST:CLN-1]],OO])
  if scope eq 'regression' then PERCEN_SIGMA_LOW=PERCEN_SIGMA_A ; reference
  vect_exp[*,OO]=0
  EXIT[OO]='yes'

  if scope eq 'classification' then OPTIMIZE_DIM='no'
  
  if OPTIMIZE_DIM eq 'yes' then begin
   NN=0L
   WHILE NN LT n_elements(VDK) DO BEGIN ; Cycle on the available input DIMENSIONS
    AI2_TOT_1EXP[*,NN,OO]=AI2_TOT[*,OO]+AI2_TOT_1EXP[*,NN,OO]
    DISTANCES_1EXP[*,NN,OO]=sqrt(AI2_TOT_1EXP[*,NN,OO])
    IDX_SD_1EXP=SORT(DISTANCES_1EXP[*,NN,OO]) ; Indexes of sorted distances
    ; 1) Compute sigma to compare
    ;PSIG_B=percentiles(BI[M_ELE_OK_idx[IDX_SD_1EXP[CLOSEST:CLN-1]],OO], value=[0.16,0.84])
    ;PERCEN_SIGMA_B=(PSIG_B[1]-PSIG_B[0])/2.
    PERCEN_SIGMA_B=SIGMA(BI[M_ELE_OK_idx[IDX_SD_1EXP[CLOSEST:CLN-1]],OO])
    PC_SIG_B_SAVE[NN,OO]=PERCEN_SIGMA_B
    ; 2) compare sigma and set prizes
    if PERCEN_SIGMA_B lt PERCEN_SIGMA_A then begin ;and PERCEN_SIGMA_B lt PERCEN_SIGMA_LOW then begin
     N_EXP[NN,OO]=N_EXP[NN,OO]+ Prize1*N_EXP_step 
     vect_exp[NN,OO]=1
     EXIT[OO]='no'
    endif
    if PERCEN_SIGMA_B ge PERCEN_SIGMA_A then begin
     if N_EXP[NN,OO] gt 0 then begin
      N_EXP[NN,OO]=N_EXP[NN,OO]+Prize2*N_EXP_step
      EXIT[OO]='no'
     endif
     if N_EXP[NN,OO] le 0 then begin
      N_EXP[NN,OO]=0.
     endif
    endif
    
    NN=NN+1
   ENDWHILE ; WHILE on N (input) DIMENSIONS
   

   if total(vect_exp[*,OO]) le 0 then begin
    ;EXIT[OO]='yes'
    N_EXP_step=N_EXP_step/2.  ; expansion factor
    if N_EXP_step lt 0.01 then EXIT[OO]='yes'
   endif
   if total(vect_exp[*,OO]) gt 0 then begin
    ; Special prize to the dimension expressing the lowest sigma
    PRIZE_ID=where(PC_SIG_B_SAVE[*,OO] eq min(PC_SIG_B_SAVE[*,OO]))
    N_EXP[PRIZE_ID[0],OO]=N_EXP[PRIZE_ID[0],OO]+Prize3*N_EXP_step
   endif   

  endif ; if OPTIMIZE_DIM eq 'yes'
  

   if where(N_EXP[*,OO] gt 0) eq [-1] then begin
    EXIT[OO]='yes'
    N_EXP[*,OO]=1
   endif

  endif  ;if EXIT[OO] eq 'no' 

  ; TEST TEST TEST TEST TEST TEST TEST TEST TEST
 OUT_SCALINGS[LL,VDK,OO]=N_EXP[*,OO]/max(N_EXP[*,OO])
  ; TEST TEST TEST TEST TEST TEST TEST TEST TEST

  OO=OO+1
 ENDWHILE ; WHILE on O (output) DIMENSIONS 

; print, MM,N_EXP[*,*]
 
 WEXIT=where(EXIT eq 'no')
 MM=MM+1
ENDWHILE

 
DISTANCES=sqrt(AI2_TOT)        ; multi-dimensional distances from data point LL

 ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
 ;           DIMENSIONS SCALING - END
 ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM


;CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
;           FIND BEST VALUE OF CLN
;CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
  NEW_CLN2=lonarr(O_DIM)

  OO=0L
  WHILE OO lt O_DIM  DO BEGIN
   IDX_SD_OO=SORT(DISTANCES[*,OO]) ; Indexes of sorted distances

   ; OPTION A: use CLN set by the user
   IF TYPE_CLN eq 'fixed' then begin
   NEW_CLN2[*]=CLN
   ENDIF
   ; OPTION B: compute best CLN between MIN_CLN and CLN (set by the user)
   IF TYPE_CLN eq 'min_max' then begin
    SIGMA_REF=SIGMA_COMPARE[OO]
    TT=MIN_CLN;+1;CLOSEST+1
    NEW_CLN2[OO]=MIN_CLN
    WHILE TT le CLN DO BEGIN
     PSIG=percentiles(BI[M_ELE_OK_idx[IDX_SD_OO[CLOSEST:TT-1]],OO], value=[0.16,0.84])
     PERCEN_SIGMA=(PSIG[1]-PSIG[0])/2.
     if PERCEN_SIGMA le SIGMA_REF and PERCEN_SIGMA gt 0 and TT ge CLOSEST+1 then begin
      SIGMA_REF=PERCEN_SIGMA
      NEW_CLN2[OO]=TT
     endif
     TT=TT+1 
    ENDWHILE
   ENDIF
;CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
;           FIND BEST VALUE OF CLN -END
;CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

   
   ; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ; CLASSIFICATION xxxxxxxxxxxxxxxxxxxxxxxxxxx
   ; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   if scope eq 'classification' then begin
    NPOSS=n_elements(CLAS_VECT[*,OO])
    PROB_REF=0.
    CLAS_REF=0
    UNC_REF=0.
    JJ=0L
    while JJ lt NPOSS do begin
     POX1=where(BI[M_ELE_OK_idx[IDX_SD_OO[CLOSEST:NEW_CLN2[OO]-1]],OO] eq CLAS_VECT[JJ,OO])
     NEL_POX1=n_elements(POX1) ; If POX1[0]=-1 counts one element! 
     ; Balancing factor
     bfact= float(n_elements(where(BI[M_ELE_OK_idx[IDX_SD_OO],OO] eq CLAS_VECT[JJ,OO])))/float(n_elements(IDX_SD_OO))
     ; NWNWNWNWNWNWNWNWNWNWNWNWNWNWNWNW
     ; NOT WEIGHTED CLASSIFICATION
     ; NWNWNWNWNWNWNWNWNWNWNWNWNWNWNWNW
      if AVERAGE eq 'mode' then begin
      CLAS_PROB[LL,JJ,OO]=float(NEL_POX1)/float(NEW_CLN2[OO]-CLOSEST)
      CLAS_UNC[LL,JJ,OO]=sqrt(float(NEL_POX1))/float(NEW_CLN2[OO]-CLOSEST)
      if keyword_set(BAL) then begin
       CLAS_PROB[LL,JJ,OO]=(1/Bfact)*CLAS_PROB[LL,JJ,OO]
       CLAS_UNC[LL,JJ,OO]=sqrt(1/Bfact)*CLAS_UNC
      endif
      IF POX1[0] eq -1 then CLAS_PROB[LL,JJ,OO]=0.
      IF POX1[0] eq -1 then CLAS_UNC[LL,JJ,OO]=-99.
     endif
     ; NWNWNWNWNWNWNWNWNWNWNWNWNWNWNWNW
     ; WEIGHTED CLASSIFICATION 
     ; NWNWNWNWNWNWNWNWNWNWNWNWNWNWNWNW
     if AVERAGE eq 'weighted' then begin
      ; weight computed for ALL the data points in the training sample 
      POX2=1+where(BI[M_ELE_OK_idx[IDX_SD_OO[CLOSEST:n_elements(IDX_SD_OO)-1]],OO] eq CLAS_VECT[JJ,OO]) ; must start from 1, not 0!
      ;W1=exp(-0.5*(((findgen(M_ELE_OK-CLOSEST))/float(NEW_CLN2[OO]-CLOSEST))^2))
      W1C=exp(-0.5*(((float(POX2))/float(NEW_CLN2[OO]-CLOSEST))^2))
      W1C_all=exp(-0.5*(((1.+findgen(M_ELE_OK-CLOSEST))/float(NEW_CLN2[OO]-CLOSEST))^2))
      CLAS_PROB[LL,JJ,OO]=total(W1C)/total(W1C_all)
      CLAS_UNC[LL,JJ,OO]=sqrt(float(NEL_POX1))/float(NEW_CLN2[OO]-CLOSEST) ; USE POX1 NOT POX2 !
      ;stop
      if keyword_set(BAL) then begin
       ;bfact=float(n_elements(POX2))/float(n_elements(IDX_SD_OO)-(1+CLOSEST)) ; Balancing factor
       CLAS_PROB[LL,JJ,OO]=(1/Bfact)*CLAS_PROB[LL,JJ,OO]
       CLAS_UNC[LL,JJ,OO]=sqrt(1/Bfact)*CLAS_UNC[LL,JJ,OO]
      endif
      IF POX2[0]-1 eq -1 then CLAS_PROB[LL,JJ,OO]=0.
      IF POX2[0]-1 eq -1 then CLAS_UNC[LL,JJ,OO]=-99.
     endif

     ; SET REFERENCE PROBABILITY LINE
     if CLAS_PROB[LL,JJ] gt PROB_REF then begin
      PROB_REF=CLAS_PROB[LL,JJ,OO]
      CLAS_REF=CLAS_VECT[JJ,OO]
      UNC_REF=CLAS_UNC[LL,JJ,OO]
     endif
     
     JJ=JJ+1
    endwhile 

    ; NORMALIZATION AFTER BALANCING
    NORM_P=total(CLAS_PROB[LL,*,OO])
    CLAS_PROB[LL,*,OO]=CLAS_PROB[LL,*,OO]/NORM_P
    CLAS_UNC[LL,*,OO]=CLAS_UNC[LL,*,OO]/NORM_P
    PROB_REF=PROB_REF/NORM_P
    UNC_REF=UNC_REF/NORM_P
    
    val99=where(CLAS_UNC[LL,*,OO] eq -99.)
    if val99[0] ge 0 then CLAS_UNC[LL,val99,OO]=-99. ; reset -99 values to -99.

    
    BO[LL,OO]=CLAS_REF
    SO[LL,OO]=UNC_REF ;sqrt(float(NEL_POX))/n_elements(NEW_CLN2)

   endif ; if scope eq 'classification'
   
 
  ; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  ; REGRESSION xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  ; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  if scope eq 'regression' then begin

    BO_0=BI[M_ELE_OK_idx[IDX_SD_OO[CLOSEST:NEW_CLN2[OO]-1]],OO]
    BO_IDX_OK=where(BO_0 eq BO_0)
    IF SO_TYPE eq 'sigma' or SO_TYPE eq 'aver' then begin
     SO_1A=SIGMA(BI[M_ELE_OK_idx[IDX_SD_OO[CLOSEST:CLN-1]],OO]) ; more conservative sigma computed on the maximum possible value of CLN
     SO_1=SO_1A
    ENDIF
    IF SO_TYPE eq 'perc' or SO_TYPE eq 'aver' then begin
     SO_1perc=percentiles(BI[M_ELE_OK_idx[IDX_SD_OO[CLOSEST:CLN-1]],OO],value=[0.16,0.5,0.84])
     SO_1B=max([abs(SO_1perc[1]-SO_1perc[0]),abs(SO_1perc[2]-SO_1perc[1])])   
     ;SO_1B=(SO_1perc[2]-SO_1perc[0])/2.
     SO_1=SO_1B
    ENDIF
    IF SO_TYPE eq 'aver' then begin
     SO_1C=(SO_1A+SO_1B)/2.
     SO_1=SO_1C
    ENDIF

    
    ; Value along the unknown dimension expected for this element
   ; VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
    ; median 
   ; VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
    if AVERAGE eq 'median' then begin
     if BO_IDX_OK[0] ne -1 then BO_1=median(BO_0[BO_IDX_OK])
     if BO_IDX_OK[0] eq -1 then BO_1=median(BO_0)
    endif
   ; VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
    ; mean 
   ; VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
    if AVERAGE eq 'mean' then begin
     if BO_IDX_OK[0] ne -1 then BO_2=mean(BO_0[BO_IDX_OK])
     if BO_IDX_OK[0] eq -1 then BO_2=mean(BO_0)
    endif
   ; VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
    ; weighted average
   ; VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
    ; weight used for the weigthed option
    if AVERAGE eq 'weighted' or AVERAGE eq 'fit' then begin
     ;W1=exp(-0.5*(((findgen(M_ELE_OK-CLOSEST))/float(NEW_CLN2[OO]-CLOSEST))^2))
      W1=exp(-0.5*(((1+findgen(M_ELE_OK-CLOSEST))/float(NEW_CLN2[OO]-CLOSEST))^2))
     BO_3=total(BI[M_ELE_OK_idx[IDX_SD_OO[CLOSEST:M_ELE_OK-1]],OO]*W1)/total(W1)
    endif
   ; VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
   ; N-dimensional linear fit of the closest datapoints
   ; (MULTIPLE LINEAR REGRESSION METHOD) 
   ; VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
   if AVERAGE eq 'fit' then begin
   IDX_DIM_OK=where(N_EXP[*,OO] gt 0)
   VDK_O=VDK[IDX_DIM_OK]    
   ; MULTIPLE LINEAR REGRESSION METHOD (n-dimensional linear fit)
    BO_4=-99.
    CLN_FIT=NEW_CLN2[OO]
    ; if NEW_CLN2[OO]-CLOSEST le n_elements(VDK_O) then CLN_FIT=min([n_elements(VDK_O)+1,CLN])
    if NEW_CLN2[OO]-CLOSEST le n_elements(VDK_O) then CLN_FIT=n_elements(VDK_O)+1
    ; Variables used for the fit option
    X_REGR=dblarr(n_elements(VDK_O),CLN_FIT-CLOSEST)
    Y_REGR=dblarr(CLN_FIT-CLOSEST)
    PP=0L
    WHILE PP lt n_elements(VDK_O) do begin
     ;X_REGR[PP,*]=AI_NEW2[M_ELE_OK_idx[IDX_SD_OO[CLOSEST:CLN_FIT-1]],VDK_O[PP]]
     X_REGR[PP,*]=AI_NEW2[M_ELE_OK_idx[IDX_SD_OO[CLOSEST:CLN_FIT-1]],VDK_O[PP]]*N_EXP[IDX_DIM_OK[PP],OO]
     PP=PP+1
    ENDWHILE
    Y_REGR[*]=BI[M_ELE_OK_idx[IDX_SD_OO[CLOSEST:CLN_FIT-1]],OO]
    BETA_COEFF=REGRESS(X_REGR,Y_REGR,const=const_REGR,STATUS=STATUS)
    ;IF STATUS EQ 0 then BO_4=total(AO_NEW2[LL,VDK_O]*BETA_COEFF)+const_REGR
    IF STATUS EQ 0 then BO_4=total(AO_NEW2[LL,VDK_O]*N_EXP[IDX_DIM_OK,OO]*BETA_COEFF)+const_REGR
    IF STATUS EQ 1 or STATUS EQ 2 or (STATUS EQ 0 and BO_4 ne BO_4) then begin
       BO_4=mean(BO_0[BO_IDX_OK])
       print, "n-dimensional linear Regression didn't work, returning status: ",strcompress(string(STATUS))
       print, "the mean is used instead"
    ENDIF
    if BO_4 ne BO_4 then stop
    ; The next option uses the average when the difference
    ; between fit and average is greater than 
    ;fit_thresh*sigma (sigma from the average)
    if keyword_set(fit_thresh) then begin
;     if abs(BO_4-mean(BO_0)) gt fit_thresh*SO_1 then BO_4=mean(BO_0)
     if abs(BO_4-mean(BO_0)) gt fit_thresh*SO_1 then BO_4=BO_3
    endif
;    SO_1=max([SO_1,abs(BO_4-mean(BO_0))])
    ; VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
    endif
   
   if AVERAGE eq 'median' then BO[LL,OO]=BO_1
   if AVERAGE eq 'mean' then BO[LL,OO]=BO_2
   if AVERAGE eq 'weighted' then BO[LL,OO]=BO_3
   if AVERAGE eq 'fit' then BO[LL,OO]=BO_4
  
   SO[LL,OO]=SO_1
  endif
  

 ; UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
 ; DETERMINING THE PDF (FOR THIS LL ELEMENT)
 ; UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
  IF keyword_set(GETPDF) and scope eq 'regression' then begin
   PDF0=dblarr(n_elements(BI[*,OO]),n_elements(BI[*,OO]))
   PDF0[*,*]=0.

  ; TEST TEST TEST TEST
;       if LL eq 0 then    set_plot, 'x'
  ; TEST TEST TEST TEST
     
   BI_CLOSE_SORT=BI[M_ELE_OK_idx[sort(BI[M_ELE_OK_idx,OO])]]
       
   LL2=CLOSEST
  WHILE LL2 lt M_ELE_OK do begin
   IDX_USD=where(X_PDF0[*,OO] eq BI[M_ELE_OK_idx[IDX_SD_OO[LL2[0]]],OO]) ; idx ordered using DISTANCE in the phase space

   
   ;W1A=exp(-0.5*(((LL2-CLOSEST)/float(NEW_CLN2[OO]-CLOSEST))^2))
   W1A=exp(-0.5*(((1+LL2-CLOSEST)/float(NEW_CLN2[OO]-CLOSEST))^2))
                 ; IMPORTANT:
; DO NOT consider multiple IDX_USD. JUST COUNT ONE OF THEM!
; IN OTHER WORDS, DON'T MULTIPLY W1A by n_elements(IDX_USD) !
; Each repetition is already accounted for due to the while cycle.
; Using this approach, the analysis datum can be excluded from the
; training set, when the /test keyword is set. Otherwise it would not!
      
   if IDX_USD[0] eq -1 then stop ; error

   TEC_USE='1'
   ; TECHNIQUE 1
   if TEC_USE eq '1' then PDF0[LL,IDX_USD]=PDF0[LL,IDX_USD]+W1A
   
   ; TECHNIQUE 2 (ALTERNATIVE - NOT USED)
   if TEC_USE eq '1' then begin
    IDX_USD2=where(BI_CLOSE_SORT eq BI[M_ELE_OK_idx[IDX_SD_OO[LL2[0]]],OO]) ; idx ordered as increasing BI parameter
    LOC_PDF_P=long(CLN)          ; When computing the PDF, local points to compute the data density 
    if IDX_USD2[0] gt LOC_PDF_P and IDX_USD2[0] lt M_ELE_OK-(LOC_PDF_P+1) then PDF0[LL,IDX_USD]=PDF0[LL,IDX_USD]+W1A*(BI_CLOSE_SORT[IDX_USD2[0]+LOC_PDF_P]-BI_CLOSE_SORT[IDX_USD2[0]-LOC_PDF_P])/(LOC_PDF_P*2.)
    if IDX_USD2[0] le LOC_PDF_P then PDF0[LL,IDX_USD]=PDF0[LL,IDX_USD]+W1A*(BI_CLOSE_SORT[IDX_USD2[0]+LOC_PDF_P]-BI_CLOSE_SORT[IDX_USD2[0]])/LOC_PDF_P
    if IDX_USD2[0] ge M_ELE_OK-(LOC_PDF_P+1) then PDF0[LL,IDX_USD]=PDF0[LL,IDX_USD]+W1A*(BI_CLOSE_SORT[IDX_USD2[0]]-BI_CLOSE_SORT[IDX_USD2[0]-LOC_PDF_P])/LOC_PDF_P
   endif
   
   LL2=LL2+1
  ENDWHILE

  
  if keyword_set(def_x_PDF) then begin
   PDF[LL,*,OO]=PDF0[LL,*]/max(PDF0[LL,*])
  endif

  if not keyword_set(def_x_PDF) then begin
   USR=0L
   while USR lt n_elements(X_PDF[*,OO])-1 do begin
    USR_IDC=where(X_PDF0[*,OO] ge X_PDF[USR,OO] and X_PDF0[*,OO] lt X_PDF[USR+1,OO])
    if USR_IDC[0] ne -1 then PDF[LL,USR,OO]=total(PDF0[LL,USR_IDC])
    USR=USR+1
   endwhile
   if keyword_set(PSM) then begin
    ;if keyword_set(PSM) then PDF[LL,*,OO]=smooth(PDF[LL,*,OO],PSM)
    ;;;if keyword_set(PSM) then PDF[LL,*,OO]=gauss_smooth(PDF[LL,*,OO],PSM)
    EDGE_ARR=fltarr(PSM)
    EDGE_ARR[*]=0.
    SM_ARR=smooth([EDGE_ARR,reform(PDF[LL,*,OO]),EDGE_ARR],PSM)
    PDF[LL,*,OO]=SM_ARR[PSM:n_elements(SM_ARR)-(PSM+1)]
   endif
   PDF[LL,*,OO]=PDF[LL,*,OO]/MAX(PDF[LL,*,OO])
  endif
  
  
;      plot, X_PDF0[*,OO],PDF0[LL,*]/max(PDF0[LL,*]),xrange=[0,3.0],xtitle='redshift',ytitle='P',charsize=1.5,charthick=1.5
;      ;plothist,X_PDF0[*,OO],bin=0.05,/overplot,/fill,/fline,forient=25,peak=1
;      plothist,BI[M_ELE_OK_idx,OO],bin=0.05,/overplot,/fill,/fline,forient=25,peak=1
;      oplot, X_PDF[*,OO],PDF[LL,*,OO],color=65000
;      oplot,[BO[LL,OO],BO[LL,OO]],[0,10],thick=3,color=1000,linestyle=2
;      oplot,[BO[LL,OO],BO[LL,OO]]-SO[LL,OO],[0,10],thick=3,color=1000,linestyle=2
;      oplot,[BO[LL,OO],BO[LL,OO]]+SO[LL,OO],[0,10],thick=3,color=1000,linestyle=2
;      oplot, X_PDF0[*,OO],PDF0[LL,*]/max(PDF0[LL,*]),thick=1.5
;      oplot,BI[M_ELE_OK_idx[IDX_SD_OO[0]],OO]*[1.,1.],[0,10],color=31000,thick=3
;      ;BO[LL,OO]=mean(X_PDF[where(PDF[LL,*,OO] gt 0.95*max(PDF[LL,*,OO])),OO])
;      ;SO[LL,OO]=0.5*0.68*int_tabulated(X_PDF[*,OO],PDF[LL,*,OO])
;      oplot,[BO[LL,OO],BO[LL,OO]],[0,10],thick=3,color=65000,linestyle=1
;
;      print, SO[LL,OO],'******'
;     fff='fff'
;     read, fff

  ENDIF
  
  
  OO=OO+1 
 endwhile 


 ; UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
 ; DETERMINING THE PDF (FOR THIS LL ELEMENT) - END
 ; UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU

 endif
 
 
 
 LL=LL+1
ENDWHILE

;RETURN,NONE
END
