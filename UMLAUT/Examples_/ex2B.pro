pro ex2B

; Example 2-B
; Difference with Example 2:
; - The same sample used for training UMLAUT is also used to test
;   it. The "/test" keyword of UMLAUT is set to this purpose. This
;   configuration allows the user to estimate accuracy and precision
;   of UMLAUT exploiting the entire available reference dataset (no
;   need to divide it into training and test sets), WITHOUT
;   INTRODUCING OVERFITTING PROBLEMS. This is possible thanks to
;   the so called "leave one out" validation strategy (see Baronchelli
;   et al. 2020 for more details). This possibility presents some
;   interesting advantages. First of all, there is no need to create 
;   multiple datasets from a given reference sample (less coding
;   required outside UMLAUT). UMLAUT can be directly inputed with the
;   entire reference sample. Secondarily, if the amount of data that
;   can be used to train and test UMLAUT is limited, then dividing the
;   sample in two separate samples reduces the accuracy. Using the
;   entire sample allows to use more data, resulting in a more precise
;   estimation of the actual accuracy. Note: the difference in the
;   estimated accuracy between the two different approaches (ex2 and
;   ex2B) is low when large training and test sets are used.
; IMPORTANT:  We stress on the fact that no overfitting is introduced;
; see literature on the "leave one out strategy" (Allen 1974; Stone
; 1974; Hastie et al. 2001) and Baronchelli et al 2021 for theoretical
; and empirical demonstrations of this approach. 
;---------------------------
; Ivano Baronchelli Jan 2021 
;---------------------------


  
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; READ COMPLETE SAMPLE FROM FILE
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
  readcol, "Set_complete.txt",ID_trai, height, foot_size, weight, forearm_le, income, Book_score,format='i8,f,f,f,f,f,f'
  ; set the test sample identical to the training sample 
  ID_test=ID_trai
  B_height=height
  B_foot_size=foot_size
  B_weight=weight
  B_forearm_le=forearm_le
  B_income=income
  B_Book_score=Book_score
  ; Training and test set are now IDENTICAL!
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; READ COMPLETE SAMPLE FROM FILE - END
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
RESULT=UMLAUT(AI,BI,AO,BO,SO,NVV,CLN=10,AVERAGE='fit',OPTIMIZE_DIM='yes',OUT_SCALINGS=OUT_SCALINGS,/test)
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
