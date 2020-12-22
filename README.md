# UMLAUT 1.0
(IDL VERSION)
Unsupervised Machine Learning Algorithm based on Unbiased Topology 
By Ivano Baronchelli, May/2019 - April/2020
See also: Baronchelli et al. (2020 in preparation)



UMLAUT is a variant of the KNN (K-closest neighbor) algorithm.
- Given a set of reference data points (training set), for which
the value of N+1 parameters is known,
- Given one analysis data point with N parameters known and the
(N+1)-th parameter unknown,
--> UMLAUT estimates the value of the (N+1)-th parameter for the
analysis data point. To this purpose, UMLAUT finds the closest
data-points of the training set, in a N-dimensional space 
"associated" (see NOTE 1 below) with the parameter space.
After finding the closest data points, the unknown parameter
is obtained as the combination (ex. average) of the values assumed 
by the closest reference data points, along the (N+1)-th dimension. 

NOTES:
1) the "associated" N-dimensional space is NOT the parameter
   space itself. In fact, during the training phase,
   - every dimension is "ordinalized": the actual value assumed
      by each of the M data points of the reference sample along
      the N dimensions is replaced by the position (1,2,...,M)
      of the data point itself in a ordered scale
   - The N ordinalized dimensions are scaled following a weighting
      process that tries to minimize the dispersion along the 
      estimated (N+1)-th parameter.
2) The simplest configuration, with only one unknown
   parameteris (the [N+1]-th), is described above. However,
   UMLAUT can be used to determine many unknown parameters, with 
   no limitaions. Obviously, the value of the same parameters must 
   be known for the data points of the reference sample.
3) UMLAUT is originally designed for REGRESSION purposes, but
   it can also be used for CLASSIFICATION. However, the current
   version of UMLAUT does not support the weighting of the input
   parameters (dimensions) when UMLAUT is used for
   classification. 
4) UMLAUT can be trained and tested using the same sample (the
   keyword "test" must be set in this case). As demonstrated in
   Baronchelli et al. (2021), this configuration does not
   introduce overfitting problems, as the training is performed
   using a "leave one out" strategy, wehere the data point left
   out is properly the data point tested.

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
;           sample.
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
;        PDF for the output parameter BO (See also the "X_PDF" and
;        "PDF" parameters. The PDF is not provided under the
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










