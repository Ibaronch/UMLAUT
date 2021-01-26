pro create_datasets

; Creates the training and test sets for the examples in this folder.
; NOTE: each time this program is run, different samples of random
; data are created (the datasets are similar only statistically)

  
N_new_el=50 ; 50 times the amount of data points in the Base sample (see below)


;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; Base sample for training and test SETs 
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; The training and test sets will be created based on this core
; sample. An additional parameter (income) will be added. This
; paramter (randomly generated) is not correlated with the other
; paramters or with the output.
  
; Height
  height=    [1.55,1.60,1.625,1.65,1.67,1.69,1.70,1.71,1.72,1.73,1.74,1.745,1.748,1.75,1.752,1.755,1.76,1.77,1.78,1.79,1.80,1.825,1.85,1.90]
; foot size
foot_size= [4.2,4.4,4.6,4.8,5.0,5.2,5.4,5.6,5.8,6.0,6.25,6.5,6.75,6.9,7.0,7.1,7.33,7.66,8.0,8.5,9.0,9.5,10.0,10.5]
; weight
weight=    [50.0,52.0,54.0,56.0,58.0,60.0,62.0,64.0,66.0,67.0,68.0,69.0,70.0,71.0,72.0,73.0,74.0,76.0,78.0,80.0,82.0,84.0,86.0,88.0]
; forearm length
forearm_le=[38.5,39.0,39.5,40.0,40.5,41.0,41.5,42.0,42.25,42.4,42.5,42.6,42.75,43.0,43.5,44.0,44.5,45.0,45.5,46.0,46.5,47.0,47.5,48.0]
; How much they like the book "Physically average people are wonderful" (1 to 10)
Book_score=[1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,8.25,8.5,8.75,9,9,8.75,8.5,8.25,8.0,7.0,6.0,5.0,4.0,3.0,2.0,1.0]
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

N_el=n_elements(height) ; number of elements in the core sample

; CREATE ARRAYS FOR THE COMPLETE DATASET
new_height=fltarr(N_new_el*N_el)
new_foot_size=fltarr(N_new_el*N_el)
new_weight=fltarr(N_new_el*N_el)
new_forearm_le=fltarr(N_new_el*N_el)
new_income=fltarr(N_new_el*N_el)
new_Book_score=fltarr(N_new_el*N_el)
new_Book_apprec=strarr(N_new_el*N_el)

RR=0L
while RR lt N_new_el do begin
 ; Height
 RAN1=randomu(seed,N_el)-randomu(seed,N_el)+randomu(seed,N_el)-randomu(seed,N_el)+randomu(seed,N_el)-randomu(seed,N_el)+randomu(seed,N_el)-randomu(seed,N_el)
 new_height[RR*N_el:(RR+1)*N_el-1]=height+mean(height)*RAN1*0.02
 ; foot size
 RAN1=randomu(seed,N_el)-randomu(seed,N_el)+randomu(seed,N_el)-randomu(seed,N_el)+randomu(seed,N_el)-randomu(seed,N_el)+randomu(seed,N_el)-randomu(seed,N_el)
 new_foot_size[RR*N_el:(RR+1)*N_el-1]=foot_size+mean(foot_size)*RAN1*0.05
; new_foot_size=float(round(new_foot_size))
 ; weight
 RAN1=randomu(seed,N_el)-randomu(seed,N_el)+randomu(seed,N_el)-randomu(seed,N_el)+randomu(seed,N_el)-randomu(seed,N_el)+randomu(seed,N_el)-randomu(seed,N_el)
 new_weight[RR*N_el:(RR+1)*N_el-1]=weight+mean(weight)*RAN1*0.1
 ; forearm length
 RAN1=randomu(seed,N_el)-randomu(seed,N_el)+randomu(seed,N_el)-randomu(seed,N_el)+randomu(seed,N_el)-randomu(seed,N_el)+randomu(seed,N_el)-randomu(seed,N_el)
 new_forearm_le[RR*N_el:(RR+1)*N_el-1]=forearm_le+mean(forearm_le)*RAN1*0.02
 ; income
 RAN1=randomu(seed,N_el)-randomu(seed,N_el)+randomu(seed,N_el)-randomu(seed,N_el)+randomu(seed,N_el)-randomu(seed,N_el)+randomu(seed,N_el)-randomu(seed,N_el)
 new_income[RR*N_el:(RR+1)*N_el-1]=2500*(1+RAN1*0.3)
; How much they like the book "Physically average people are wonderful" (1 to 10)
 RAN1=randomu(seed,N_el)-randomu(seed,N_el)+randomu(seed,N_el)-randomu(seed,N_el)+randomu(seed,N_el)-randomu(seed,N_el)+randomu(seed,N_el)-randomu(seed,N_el)
 new_Book_score[RR*N_el:(RR+1)*N_el-1]=Book_score+mean(Book_score)*RAN1*0.1
; new_Book_score=float(round(new_Book_score))

RR=RR+1
endwhile

new_Book_apprec[where(new_Book_score gt 5)]='yes'
new_Book_apprec[where(new_Book_score le 5)]='no'

; RANDOMIZATION OF THE ORDER
IDX_RAN=sort(randomu(seed,N_new_el*N_el))
new_height=     new_height[IDX_RAN]
new_foot_size=  new_foot_size[IDX_RAN]
new_weight=     new_weight [IDX_RAN]
new_forearm_le= new_forearm_le[IDX_RAN]
new_Book_score= new_Book_score[IDX_RAN]
new_Book_apprec=new_Book_apprec[IDX_RAN]

; WRITE TRAINING SET AND TEST SET IN TWO SEPARATE FILES

openw, fo1, "Set_training.txt", /get_lun
openw, fo2, "Set_Test.txt", /get_lun
openw, fo3, "Set_complete.txt", /get_lun
printf, fo1,"      ID     height   foot_size    weight  forearm_le  income     Book_score  Book_apprec"
printf, fo2,"      ID     height   foot_size    weight  forearm_le  income     Book_score  Book_apprec"
printf, fo3,"      ID     height   foot_size    weight  forearm_le  income     Book_score  Book_apprec"


MM=0L
while MM lt n_elements(new_height) do begin
   
; TRAINING SAMPLE
if MM lt n_elements(new_height)/2 then printf, fo1, MM, new_height[MM], new_foot_size[MM], new_weight[MM], new_forearm_le[MM], new_income[MM], new_Book_score[MM],new_Book_apprec[MM],format='(i8,1x,6(f10.4,1x),A5,1x)'
; TEST SAMPLE
if MM ge n_elements(new_height)/2 then printf, fo2, MM, new_height[MM], new_foot_size[MM], new_weight[MM], new_forearm_le[MM], new_income[MM], new_Book_score[MM],new_Book_apprec[MM],format='(i8,1x,6(f10.4,1x),A5,1x)'
; COMPLETE SAMPLE
printf, fo3, MM, new_height[MM], new_foot_size[MM], new_weight[MM], new_forearm_le[MM], new_income[MM], new_Book_score[MM],new_Book_apprec[MM],format='(i8,1x,6(f10.4,1x),A5,1x)'

MM=MM+1
endwhile

free_lun, fo1,fo2
close, fo1,fo2



stop
end
