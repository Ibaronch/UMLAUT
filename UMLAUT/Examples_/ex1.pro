pro ex1
  
; Simple example of use of UMLAUT
; We consider 24 people (M=24), for which we know their  
; height, foot size, weight and forearm length (N=4). Some data, for
; some of them, are missing. For all of the 24 people, we know their
; evaluation of a book titled "Physically average people are
; wonderful". (the [N+1]-th parameter).
; Given the training set described, we use UMLAUT to forecast the
; evalutaion that will be given to the same book by 3 additional
; people (L=3) that are not included in the training set. For all
; these people, that represent our analysis set, we know the value of
; the N parameters but not the value of the [N+1]-th parameter that we
; try to estimate.

; For this example, UMLAUT is configured to take into account only the
; closest 4 data points (K=4) in the multi-dimensional parameter
; space. The output is given by the mean of book evaluation given by
; these 4 people. The parameters are not optimized (i.e. the
; dimensions of the multi-dimensional parameter space are not scaled)
;---------------------------
; Ivano Baronchelli Jan 2021 
;---------------------------
  

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; TRAINING SET 
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; Missing data are set to -99.
; Height
height=    [1.50,1.78,-99.,1.73,1.57,1.70,1.66,1.62,1.71,1.63,1.45,1.73,1.55,1.58,1.71,-99.,1.78,1.88,1.69,1.63,1.66,1.73,1.80,1.86]
; foot size
foot_size= [4   ,12  ,8   ,8   ,5   ,9   ,6   ,6   ,9   ,8   ,5   ,7   ,5   ,-99.,8   ,9   ,11  ,14  ,6   ,6   ,7   ,8   ,11  ,12]
; weight
weight=    [58.0,59.0,57.0,73.0,48.0,64.0,-99.,50.0,71.0,52.0,35.0,65.0,45.0,48.0,73.0,78.0,71.0,73.0,60.0,52.0,51.0,65.0,82.1,81.0]
; forearm length
forearm_le=[38.0,48.3,42.7,44.2,40.2,44.6,43.3,41.1,-99.,40.9,36.6,45.1,38.9,39.2,44.6,46.3,45.9,-99.,43.6,41.5,42.3,45.2,47.1,48.8]
; How much they like the book "Physically average people are wonderful" (1 to 10)
Book_score=[4.0 ,5.0 ,5.0 ,6.0 ,5.0 ,9.0 ,7.0 ,6.0 ,7.0 ,6.0 ,3.0 ,6.0 ,3.0 ,5.0 ,7.0 ,7.0 ,6.0 ,3.0 ,8.0 ,5.0 ,7.0 ,8.0 ,3.0 ,1.0]
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; ANALYSIS data point (3 people)
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; Height
B_height=    [1.49,1.70,1.83]
; Foot size
B_foot_size= [5   ,8   ,13]
; Weight
B_weight=    [51.0,72.0,82.1]
; Forearm length
B_forearm_le=[38.5,42.6,47.9]
; UNKNOWN PARAMETER: How much they like the book "Physically average people are wonderful" (1 to 10)
B_Book_score=fltarr(n_elements(height))
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

 plot, height, foot_size,xtitle='Height',ytitle='Foot Size',psym=1,xrange=[1.30,1.90],yrange=[3.0,13.5],/xst, /yst, title='Input data',charsize=1.2
 oplot, B_height, B_foot_size,psym=2,color=1000

fff='fff'
read, fff

plot, height, forearm_le,xtitle='Height',ytitle='Forearm length',psym=1,xrange=[1.30,1.90],yrange=[30,50.0],/xst, /yst, title='Input data',charsize=1.2
oplot, B_height, B_forearm_le,psym=2,color=1000

fff='fff'
read, fff

plot, height, weight,xtitle='Height',ytitle='Weight',psym=1,xrange=[1.30,1.90],yrange=[40.0,85.0],/xst, /yst, title='Input data',charsize=1.2
oplot, B_height, B_weight,psym=2,color=1000

fff='fff'
read, fff

AI=[[height],[foot_size],[weight],[forearm_le]]
BI=Book_score
AO=[[B_height],[B_foot_size],[B_weight],[B_forearm_le]]
NVV=[-99.0,-99.0,-99.0,-99.0]


; Guess "B_Book_score" for the three analysis people, using UMLAUT
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
RESULT=UMLAUT(AI,BI,AO,BO,SO,NVV,CLN=4,AVERAGE='mean',OPTIMIZE_DIM='no')
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


plot, height, Book_score,psym=1,xtitle='Height',ytitle='Book score',xrange=[1.30,1.90],yrange=[0,10.0],/xst, /yst,title='UMLAUT output',charsize=1.2
oplot, B_height, BO,psym=2,color=1000

fff='fff'
read, fff

plot, weight, Book_score,psym=1,xtitle='Weight',ytitle='Book score',xrange=[40.0,85.0],yrange=[0,10.0],/xst, /yst,title='UMLAUT output',charsize=1.2
oplot, B_weight, BO,psym=2,color=1000

fff='fff'
read, fff

plot, foot_size,Book_score,psym=1,xtitle='Foot size',ytitle='Book score',xrange=[3.0,13.5],yrange=[0,10.0],/xst, /yst,title='UMLAUT output',charsize=1.2
oplot, B_foot_size, BO,psym=2,color=1000

fff='fff'
read, fff

plot, forearm_le,Book_score,psym=1,xtitle='Forearm length',ytitle='Book score',xrange=[30,50.0],yrange=[0,10.0],/xst, /yst,title='UMLAUT output',charsize=1.2
oplot, B_forearm_le, BO,psym=2,color=1000

fff='fff'
read, fff


stop
end
