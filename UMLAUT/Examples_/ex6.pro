pro ex6

; Example 6
; Similar to Example 2, but instead of computing the output parameter
; through a regression process, here we use UMLAUT for CLASSIFICATION
; purposes. In particular, we replace the continuous variable "book
; score" (ranging from 0.0 to 10.0) with a discrete parameter
; called "book_appreciation" (with "yes" or "no" as only possibilities).
; - book_appreciation='yes' when Book_score > 5 and
; - book_appreciation='no' when Book_score <= 5
; UMLAUT doesn't have any knowledge of the Book_score parameter.
; In the final plots we show the results of the classification process
; performed by UMLAUT. In the y-axes, we show the book score parameter
; while in the x-axes we show the various parameters exploited by UMLAUT
; for its classification. Different UMLAUT classifications are shown
; using different colors. A perfect classification (100% accuracy)
; would result in all the red squares located above the horizonatal
; line (corresponding to Book_score = 5) and all the yellow squares
; located below the same line.
  
;---------------------------
; Ivano Baronchelli Jan 2021 
;---------------------------

; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; READ TRAINING AND TEST SETS FROM FILES
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
readcol, "Set_training.txt",ID_trai, height, foot_size, weight, forearm_le, income, Book_score,Book_apprec,format='i8,f,f,f,f,f,f,A'
readcol, "Set_Test.txt",ID_test, B_height, B_foot_size, B_weight, B_forearm_le, B_income, B_Book_score,B_Book_apprec,format='i8,f,f,f,f,f,f,A'
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
BI=Book_apprec; Guess "B_Book_score" for the test set, using UMLAUT
AO=[[B_height],[B_foot_size],[B_weight],[B_forearm_le],[B_income]]
NVV=[-99.0,-99.0,-99.0,-99.0,-99.0]
CLAS_VECT=['yes','no']; All the possibilities
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Print, "Running UMLAUT"
RESULT=UMLAUT(AI,BI,AO,BO,SO,NVV,CLN=10,AVERAGE='weighted',scope="classification",CLAS_VECT=CLAS_VECT,CLAS_PROB=CLAS_PROB,CLAS_UNC=CLAS_UNC)
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; RUN UMLAUT - END
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

 
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; COMPARE UMLAUT CLASSIFICATION WITH ACTUAL CLASSIFICATION
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
print, '.............................................'
print, 'Number of correct classifications (and %):'
print, n_elements(where(BO eq B_Book_apprec)), ' (',strcompress(string(100.*n_elements(where(BO eq B_Book_apprec))/float(n_elements(BO)))),' %)'
print, '.............................................'
fff='fff'
read, fff
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; COMPARE UMLAUT CLASSIFICATION WITH ACTUAL CLASSIFICATION - END
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM



; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; OTHER ANALYSIS
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
IDX_YES=where(BO eq 'yes')
IDX_NO=where(BO eq 'no')

plot, B_height, B_Book_score,psym=3,xtitle='Height',ytitle='Book score',xrange=[1.40,2.10],yrange=[0,10.0],/xst, /yst,title='TEST set classification (UMLAUT)',charsize=1.2
oplot,[0,10000],[5,5]
oplot, B_height[IDX_YES], B_Book_score[IDX_YES],psym=4,color=1000
oplot, B_height[IDX_NO], B_Book_score[IDX_NO],psym=4,color=65000
fff='fff'
read, fff

plot, B_weight, B_Book_score,psym=3,xtitle='Weight',ytitle='Book score',xrange=[40.0,100.0],yrange=[0,10.0],/xst, /yst,title='TEST set classification (UMLAUT)',charsize=1.2
oplot,[0,10000],[5,5]
oplot, B_weight[IDX_YES], B_Book_score[IDX_YES],psym=4,color=1000
oplot, B_weight[IDX_NO], B_Book_score[IDX_NO],psym=4,color=65000
fff='fff'
read, fff

plot, B_foot_size,B_Book_score,psym=3,xtitle='Foot size',ytitle='Book score',xrange=[3.0,13.5],yrange=[0,10.0],/xst, /yst,title='TEST set classification (UMLAUT',charsize=1.2
oplot,[0,10000],[5,5]
oplot, B_foot_size[IDX_YES], B_Book_score[IDX_YES],psym=4,color=1000
oplot, B_foot_size[IDX_NO], B_Book_score[IDX_NO],psym=4,color=65000
fff='fff'
read, fff

plot, B_forearm_le,B_Book_score,psym=3,xtitle='Forearm length',ytitle='Book score',xrange=[30,60.0],yrange=[0,10.0],/xst, /yst,title='TEST set classification (UMLAUT)',charsize=1.2
oplot,[0,10000],[5,5]
oplot, B_forearm_le[IDX_YES], B_Book_score[IDX_YES],psym=4,color=1000
oplot, B_forearm_le[IDX_NO], B_Book_score[IDX_NO],psym=4,color=65000
fff='fff'
read, fff

plot, B_income,B_Book_score,psym=3,xtitle='income',ytitle='Book score',xrange=[900,4500],yrange=[0,10.0],/xst, /yst,title='TEST set classification (UMLAUT)',charsize=1.2
oplot,[0,10000],[5,5]
oplot, B_income[IDX_YES], B_Book_score[IDX_YES],psym=4,color=1000
oplot, B_income[IDX_NO], B_Book_score[IDX_NO],psym=4,color=65000

; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
; OTHER ANALYSIS - END
; MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

 stop
end
