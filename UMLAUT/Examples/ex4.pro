pro ex4

; Example 4
; This example is similar to Example 2. The only differece is that
; here UMLAUT computes a probability distribution function (PDF).
; NOTES:
; 1) The estimation of the output parameter performed by UMLAUT
; (BO) is independent from the computation of the PDF. For example,
; UMLAUT can estimate the value of the output parameter using the mean
; computed over the closest data points, or using a multi-dimensional
; fit (as in this example). The computation of the PDF is not
; influenced by the method used to compute the output parameter.
; 2) The PDF provided by UMLAUT can be used to estimate the output
; parameter using methods that are different from those already
; available in UMLAUT ("mean", "median", "mode", "weighted", and
; "fit"). For example, the user can decide to use the position of the
; peak of the PDF or the weighted average of the PDF as best estimator
; of the output parameter. Similarly, an alternative estimation of the
; uncertainty associated with the output parameter can be obtained
; from the PDF. 
; - In this program, we show how to properly compute an output PDF using
; UMLAUT, and we show how the output parameter can be obtained from
; this PDF.
  
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
; Base for the Probability distribution function:
X_PDF=findgen(100)/10.; [0.0, 0.1, 0.2,...., 9.9, 10.0]
X_PDF=findgen(50)/5.; [0.0, 0.2, 0.4,...., 9.8, 10.0]
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Print, "Running UMLAUT"
RESULT=UMLAUT(AI,BI,AO,BO,SO,NVV,CLN=10,AVERAGE='fit',OPTIMIZE_DIM='yes',/GETPDF, X_PDF=X_PDF,PDF=PDF,PSM=2)
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; RUN UMLAUT - END
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

BO_PDF=BO ; creates an array similar to that used for the UMLAUT output
BO_PDF[*]=-99.
QQ=''
HH=0L
WHILE HH lt n_elements(BO) do begin
 ; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
 ; ESTIMATE OUTPUT PARAMETER FROM PDF (example)
 ; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
 IDX_max=where(PDF[HH,*] gt 0.8*max(PDF[HH,*])) ;PDF's indexes with values > 80% of the peak.
 BO_PDF[HH]=mean(X_PDF[IDX_max])
 print, BO_PDF[HH]
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; ESTIMATE OUTPUT PARAMETER FROM PDF (example) -END
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; VISUALIZATION OF PDFs from UMLAUT 
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
 if strupcase(QQ) ne 'Q' then begin
  plot, X_PDF,PDF[HH,*],xrange=[-0.5,10.5],yrange=[0,1.2],/xst, /yst, title='Probability distribution function (press "Q" to quit)',charsize=1.2,xtitle="Book score",ytitle="Estimated probability (Peak normalized to 1.0)"
  oplot,[B_Book_score[HH],B_Book_score[HH]],[0,10],color=3000,thick=2,linestyle=2
  oplot,[BO_PDF[HH],BO_PDF[HH]],[0,10],color=65000,thick=2,linestyle=2
  xyouts,B_Book_score[HH]+0.1,1.025,'Actual score',color=3000,charsize=1.4
  xyouts,BO_PDF[HH]+0.1,1.125,'Score from PDF',color=65000,charsize=1.4
  print, 'press Q to quit the visualization'
  read,QQ
 endif
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; VISUALIZATION OF PDFs from UMLAUT -END
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

HH=HH+1
ENDWHILE


; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; COMPARE UMLAUT ESTIMATION WITH ACTUAL VALUE OF THE OUT PARAMETER
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
plot,B_Book_score,BO_PDF,title='Result of the test',xtitle='Actual book score',ytitle='Estimated book score (PDF)',psym=1,charsize=1.2
oplot, [0,10],[0,10],color=1000
print, '.............................................'
print, 'Uncertainty on the estimation of the output'
print, '(sigma associated to the book score estimated' 
print, 'from the PDF):'
print, sigma(B_Book_score-BO_PDF)
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
oplot, B_height, BO_PDF,psym=2,color=1000
fff='fff'
read, fff

plot, weight, Book_score,psym=1,xtitle='Weight',ytitle='Book score',xrange=[40.0,100.0],yrange=[0,10.0],/xst, /yst,title='UMLAUT output (in red)',charsize=1.2
oplot, B_weight, BO_PDF,psym=2,color=1000
fff='fff'
read, fff

plot, foot_size,Book_score,psym=1,xtitle='Foot size',ytitle='Book score',xrange=[3.0,13.5],yrange=[0,10.0],/xst, /yst,title='UMLAUT output (in red)',charsize=1.2
oplot, B_foot_size, BO_PDF,psym=2,color=1000
fff='fff'
read, fff

plot, forearm_le,Book_score,psym=1,xtitle='Forearm length',ytitle='Book score',xrange=[30,60.0],yrange=[0,10.0],/xst, /yst,title='UMLAUT output (in red)',charsize=1.2
oplot, B_forearm_le, BO,psym=2,color=1000
fff='fff'
read, fff

plot, income,Book_score,psym=1,xtitle='income',ytitle='Book score',xrange=[900,4500],yrange=[0,10.0],/xst, /yst,title='UMLAUT output',charsize=1.2
oplot, B_income, BO_PDF,psym=2,color=1000

; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; OTHER ANALYSIS - END
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

 stop
end
