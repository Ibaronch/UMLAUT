pro ex3

; Example 3
; Similarly to Examples 2 and 2B, in this example we consider 5
; parameters (height, foot size, weight, forearm length and income),
; one of which (income) does not correlate with the [N+1]-th
; parameter. Also in this case the [N+1]-th parameter is represented
; by the evaluation given by the people considered to a book
; titled "Physically average people are wonderful". 
; Compared to Example 2, in this test:
; - UMLAUT is run two times. During the first run, UMLAUT computes the
;   scaling factors associated to each of the input parameters, for
;   each of the analysis data considered (OUT_SCALINGS). In the second
;   run, we input UMLAUT with the average scaing factors (IN_SCALINGS,
;   one single value for each of the input parameters). In the second
;   run, we prevent UMLAUT from further scaling the input parameters
;   by setting the option OPTIMIZE_DIM to 'no'.
; The configuration adopted in this example allows UMLAUT to clearly
; separate the training phase, in which the scaling parameters are
; computed, from the analysis phase, where the knowledge learnt by
; UMLAUT is applied to the analysis dataset.
; PROs and CONs of this approach:
; PROs:
; - While the first run (training phase) is slow, the second one
;   (analysis) is fast. When a very large amount of data has to be
;   analyzed using UMLAUT, whereas the traning dataset is small, the
;   configuration shown in this example allows to sensibly reduce the
;   overall computational time.
; CONs:
; - Compared to the "single UMLAUT run" configuration, the output is
;   less precise. In fact, in the single run configuration, the
;   training of UMLAUT is performed taking into account the region of
;   the parameter space that is close to each specific analysis data
;   points considered. Instead, in the double run configuration, the
;   training is performed considering the average scaling of the
;   parameter space. These scaling factors may be very well suited for
;   some of the analysis data points but not for all of them.
 
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
; FIRST UMLAUT RUN
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; Set appropriate inputs for UMLAUT
AI=[[height],[foot_size],[weight],[forearm_le],[income]]
BI=Book_score; Guess "B_Book_score" for the test set, using UMLAUT
AO=[[B_height],[B_foot_size],[B_weight],[B_forearm_le],[B_income]]
NVV=[-99.0,-99.0,-99.0,-99.0,-99.0]
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Print, "UMLAUT - first run"
T1=SYSTIME( 1, /SECONDS )
RESULT=UMLAUT(AI,BI,AO,BO,SO,NVV,CLN=10,AVERAGE='fit',OPTIMIZE_DIM='yes',OUT_SCALINGS=OUT_SCALINGS)
T2=SYSTIME( 1, /SECONDS )
print, 'First RUN elapsed Time [s]:',T2-T1
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; FIRST UMLAUT RUN - END
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
; SECOND UMLAUT RUN
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
Print, "UMLAUT - Second run"
T3=SYSTIME( 1, /SECONDS )
RESULT=UMLAUT(AI,BI,AO,BO,SO,NVV,CLN=10,AVERAGE='fit',OPTIMIZE_DIM='no',IN_SCALINGS=IN_SCALINGS)
T4=SYSTIME( 1, /SECONDS )
print, 'Second RUN elapsed Time [s]:',T4-T3

; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; SECOND UMLAUT RUN - END
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
