pro ex5

; Example 5
; Similar to Example 2, but in this case we use UMLAUT to estimate two
; parameters (forearm length and Book score) at the same time instead
; of just one, as in the previous examples.
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

;IN THIS EXAMPLE forearm_le is considered an unknown variable
;plot, height, forearm_le,xtitle='Height',ytitle='Forearm length',psym=1,xrange=[1.30,2.10],yrange=[30,60.0],/xst, /yst, title='Input data (test set in red)',charsize=1.2
;oplot, B_height, B_forearm_le,psym=2,color=1000,symsize=0.5

;fff='fff'
;read, fff

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
AI=[[height],[foot_size],[weight],[income]]
BI=[[Book_score],[forearm_le]]; Guess "B_Book_score" and B_forearm_le for the test set, using UMLAUT
AO=[[B_height],[B_foot_size],[B_weight],[B_income]]
NVV=[-99.0,-99.0,-99.0,-99.0]
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Print, "Running UMLAUT"
RESULT=UMLAUT(AI,BI,AO,BO,SO,NVV,CLN=10,AVERAGE='fit',OPTIMIZE_DIM='yes',OUT_SCALINGS=OUT_SCALINGS)
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; RUN UMLAUT - END
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; COMPARE UMLAUT ESTIMATION WITH ACTUAL VALUE OF THE OUT PARAMETERS
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
plot,B_Book_score,BO[*,0],title='Result of the test',xtitle='Actual book score',ytitle='Estimated book score',psym=1,charsize=1.2
oplot, [-100,100],[-100,100],color=1000
print, '.............................................'
print, 'Uncertainty on the estimation of the 1st output'
print, '(sigma associated to estimated book score):'
print, sigma(B_Book_score-BO[*,0])
print, '.............................................'
fff='fff'
read, fff

plot,B_forearm_le,BO[*,1],title='Result of the test',xtitle='Actual forearm length',ytitle='Estimated forearm length',psym=1,charsize=1.2,xrange=[35,50],yrange=[35,50],/xst,/yst
oplot, [-100,100],[-100,100],color=1000
print, '.............................................'
print, 'Uncertainty on the estimation of the 2nd output'
print, '(sigma associated to estimated forearm length):'
print, sigma(B_forearm_le-BO[*,1])
print, '.............................................'
fff='fff'
read, fff

; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; COMPARE UMLAUT ESTIMATION WITH ACTUAL VALUE OF THE OUT PARAMETERS - END
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM


; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; OTHER ANALYSIS
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; FIRST PARAMETER (Book score)
plot, height, Book_score,psym=1,xtitle='Height',ytitle='Book score',xrange=[1.40,2.10],yrange=[0,10.0],/xst, /yst,title='UMLAUT output (in red)',charsize=1.2
oplot, B_height, BO[*,0],psym=2,color=1000
fff='fff'
read, fff

plot, weight, Book_score,psym=1,xtitle='Weight',ytitle='Book score',xrange=[40.0,100.0],yrange=[0,10.0],/xst, /yst,title='UMLAUT output (in red)',charsize=1.2
oplot, B_weight, BO[*,0],psym=2,color=1000
fff='fff'
read, fff

plot, foot_size,Book_score,psym=1,xtitle='Foot size',ytitle='Book score',xrange=[3.0,13.5],yrange=[0,10.0],/xst, /yst,title='UMLAUT output (in red)',charsize=1.2
oplot, B_foot_size, BO[*,0],psym=2,color=1000
fff='fff'
read, fff

plot, income,Book_score,psym=1,xtitle='income',ytitle='Book score',xrange=[900,4500],yrange=[0,10.0],/xst, /yst,title='UMLAUT output',charsize=1.2
oplot, B_income, BO[*,0],psym=2,color=1000

; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; SECOND PARAMETER (Forearm length)

plot, height, forearm_le,psym=1,xtitle='Height',ytitle='Forearm length',xrange=[1.40,2.10],yrange=[35,50],/xst, /yst,title='UMLAUT output (in red)',charsize=1.2
oplot, B_height, BO[*,1],psym=2,color=1000
fff='fff'
read, fff

plot, weight, forearm_le,psym=1,xtitle='Weight',ytitle='Forearm length',xrange=[40.0,100.0],yrange=[35,50],/xst, /yst,title='UMLAUT output (in red)',charsize=1.2
oplot, B_weight, BO[*,1],psym=2,color=1000
fff='fff'
read, fff

plot, foot_size, forearm_le,psym=1,xtitle='Foot size',ytitle='Forearm length',xrange=[3.0,13.5],yrange=[35,50],/xst, /yst,title='UMLAUT output (in red)',charsize=1.2
oplot, B_foot_size, BO[*,1],psym=2,color=1000
fff='fff'
read, fff

plot, income, forearm_le,psym=1,xtitle='income',ytitle='Forearm length',xrange=[900,4500],yrange=[35,50],/xst, /yst,title='UMLAUT output',charsize=1.2
oplot, B_income, BO[*,1],psym=2,color=1000



; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; OTHER ANALYSIS - END
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

 stop
end
