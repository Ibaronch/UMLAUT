pro ex2

; Example 2
; Similarly to Example 1, in this example we consider 4 parameters
; (height, foot size, weight and forearm length) that correlate with
; the [N+1]-th parameter: the evaluation given by the people
; considered to a book titled "Physically average people are
; wonderful".
; With respect to Example 1, in this example:
; - we add an input parameter that does not correlate with the other
;   ones and/or with the [N+1]-th parameter. Consequently, in this
;   example N=5. 
; - Furthermore, in this example we consider independent training set
;   and a test sets that are much larger than in Example 1. The two
;   samples are read from exernal files (created using
;   create_dataset.pro, in this same folder). As shown in example 2B
;   (ex2B.pro), a similar test on the accuracy of UMLAUT can be
;   performed by using the same calibration set for both training and
;   test the algorithm. In the alternative test, the /test keyword of
;   UMLAUT must be set (see ex2B.pro for more information). 
; - The output is obtained as a multidimensional linear fit
;   (AVERAGE='fit') of the [N+1]-th parameter, measured by taking into
;   account the 10 data points (CLN=K=10) that are closer in the
;   parameter space. 
; - The input dimensions are optimized so that meaningful information
;   (with respect to the output) have larger weights (OPTIMIZE_DIM='yes')
;---------------------------
; Ivano Baronchelli Jan 2021 
;---------------------------

; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; READ TRAINING AND TEST SETS FROM FILES
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
readcol, "Set_training.txt",ID_trai, height, foot_size, weight, forearm_le, income, Book_score,format='i8,f,f,f,f,f,f'
readcol, "Set_Test.txt",ID_test, B_height, B_foot_size, B_weight, B_forearm_le, B_income, B_Book_score,format='i8,f,f,f,f,f,f'
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; READ TRAINING AND TEST SETS FROM FILES -END
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM 

; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; SHOW PROPERTIES OF THE DATA SETS
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM 

plot, height, foot_size,xtitle='Height',ytitle='Foot Size',psym=1,xrange=[1.30,2.10],yrange=[3.0,13.5],/xst, /yst, title='Input data (test set in red)',charsize=1.2
oplot, B_height, B_foot_size,psym=2,color=1000,symsize=0.5

fff='fff'
read, fff

plot, height, forearm_le,xtitle='Height',ytitle='Forearm length',psym=1,xrange=[1.30,2.10],yrange=[30,60.0],/xst, /yst, title='Input data (test set in red)',charsize=1.2
oplot, B_height, B_forearm_le,psym=2,color=1000,symsize=0.5

fff='fff'
read, fff

plot, height, weight,xtitle='Height',ytitle='Weight',psym=1,xrange=[1.30,2.10],yrange=[40.0,100.0],/xst, /yst, title='Input data (test set in red)',charsize=1.2
oplot, B_height, B_weight,psym=2,color=1000,symsize=0.5

fff='fff'
read, fff

plot, height, income,xtitle='Height',ytitle='Income',psym=1,xrange=[1.30,2.10],yrange=[900,4500],/xst, /yst, title='Input data (test set in red)',charsize=1.2
oplot, B_height, B_income,psym=2,color=1000,symsize=0.5

fff='fff'
read, fff

; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; SHOW PROPERTIES OF THE DATA SETS - END
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM 


; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; RUN UMLAUT
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; Set appropriate inputs for UMLAUT
AI=[[height],[foot_size],[weight],[forearm_le],[income]]
BI=Book_score; Guess "B_Book_score" for the test set, using UMLAUT
AO=[[B_height],[B_foot_size],[B_weight],[B_forearm_le],[B_income]]
NVV=[-99.0,-99.0,-99.0,-99.0,-99.0]
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Print, "Running UMLAUT"
RESULT=UMLAUT(AI,BI,AO,BO,SO,NVV,CLN=10,AVERAGE='fit',OPTIMIZE_DIM='yes',OUT_SCALINGS=OUT_SCALINGS)
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; RUN UMLAUT - END
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM


; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; SHOW PARAMETER SCALING COMPUTED BY UMLAUT
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
 N_PARAM=n_elements(AI[0,*])
 IN_SCALINGS=fltarr(N_PARAM)
 TT=0L
 WHILE TT lt N_PARAM do begin
  IN_SCALINGS[TT]=mean(OUT_SCALINGS[*,TT])
  TT=TT+1  
ENDWHILE
 print, 'Parameters scaling'
 print,"(height, foot_size, weight, forearm_le, income)"
 print,IN_SCALINGS
 plot, findgen(5)+1,IN_SCALINGS,title='Average weights of the input parameters',xtitle='Parameter',ytitle='Weight',charsize=1.2
 fff='fff'
 read,fff

; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; SHOW PARAMETER SCALING COMPUTED BY UMLAUT - END
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

 
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; COMPARE UMLAUT ESTIMATION WITH ACTUAL VALUE OF THE OUT PARAMETER
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
plot,B_Book_score,BO,title='Result of the test',xtitle='Actual book score',ytitle='Estimated book score',psym=1,charsize=1.2
oplot, [0,10],[0,10],color=1000
print, '.............................................'
print, 'Uncertainty on the estimation of the output'
print, '(sigma associated to estimated book score):'
print, sigma(B_Book_score-BO)
print, '.............................................'
fff='fff'
read, fff
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; COMPARE UMLAUT ESTIMATION WITH ACTUAL VALUE OF THE OUT PARAMETER - END
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM


; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; OTHER ANALYSIS
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

plot, height, Book_score,psym=1,xtitle='Height',ytitle='Book score',xrange=[1.40,2.10],yrange=[0,10.0],/xst, /yst,title='UMLAUT output (in red)',charsize=1.2
oplot, B_height, BO,psym=2,color=1000
fff='fff'
read, fff

plot, weight, Book_score,psym=1,xtitle='Weight',ytitle='Book score',xrange=[40.0,100.0],yrange=[0,10.0],/xst, /yst,title='UMLAUT output (in red)',charsize=1.2
oplot, B_weight, BO,psym=2,color=1000
fff='fff'
read, fff

plot, foot_size,Book_score,psym=1,xtitle='Foot size',ytitle='Book score',xrange=[3.0,13.5],yrange=[0,10.0],/xst, /yst,title='UMLAUT output (in red)',charsize=1.2
oplot, B_foot_size, BO,psym=2,color=1000
fff='fff'
read, fff

plot, forearm_le,Book_score,psym=1,xtitle='Forearm length',ytitle='Book score',xrange=[30,60.0],yrange=[0,10.0],/xst, /yst,title='UMLAUT output (in red)',charsize=1.2
oplot, B_forearm_le, BO,psym=2,color=1000
fff='fff'
read, fff

plot, income,Book_score,psym=1,xtitle='income',ytitle='Book score',xrange=[900,4500],yrange=[0,10.0],/xst, /yst,title='UMLAUT output',charsize=1.2
oplot, B_income, BO,psym=2,color=1000

; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; OTHER ANALYSIS - END
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

 stop
end
