#SEYED YAHYA NIKOUEI PROJECT 2- DNS

import datetime
from datetime import datetime

with open('dnslog.txt', 'r') as file:       # reading the text file
    file_contents = (file.read()).split()
    
    leng = len(file_contents)
    leng = leng/10; #each request has 10 parts in the dnslog file, so if we divide 
    #lenght by 10 we have request number
    j = 1 # value of the sub request for a main request
    cam1 = datetime.strptime('00:00:10.000', '%H:%M:%S.%f') 
    cam2 = datetime.strptime('00:00:40.000', '%H:%M:%S.%f')
    cam = cam2 - cam1 # later we need to compare two time differences and here we create one of them. 
    # simply using a value like "cam1" gives a error because it cannot compare one time 
    #difference with one time object
    
    w = [] # to save the list of the subrequests that happen for a main request
    # we save everything in an array named w because we need to go to the end of the 
    #subrequests to have the number of subrequests and then we can save them in a file
    v = (file_contents[7])+" "
    vv = " Time(s) at: " + file_contents[0]+" "+file_contents[1]
    # I used two parts named v and vv for the name of the main request and time of it, 
    #because in the middle I need to add the number of subrequests that I will have when another 
    #main request happens.
    w.append(str(j) + ". " + file_contents[7]) # each sub request appends to the w
    f = open('report.txt', 'w')
    
    for i in range (0,(leng-1)):
        i = 10*i #doing this so we can have access to the number in file_contents array
        tim = file_contents[i+1] # time part for each dns request
        tim1 = file_contents[10+i+1] # time part of the next dns request to be able to compare them 
         
        a =  datetime.strptime(tim, '%H:%M:%S.%f')
        a1 = datetime.strptime(tim1, '%H:%M:%S.%f')
        qq = a1 - a # time difference of the two dns requests in a row
        
        if qq < cam : # if the time difference is less than 30 seconds then it is not a main request
            if file_contents[(10+i)+7] != file_contents[(i)+7]: # we do not want the same request 
                #appears twice
                j +=1
                w.append(str(j)+ ". " + file_contents[(10+i)+7]) # we collect everything to save it 
                #in the file
        else: # following is for main requests
            
            if i!= 0: # the first request was handled before this loop

                f.write(v+str(j)+vv+"\n") # save previous requests to file and start from 
                #the beginning for new request
                print v+str(j)+vv
                for z in w:
                    f.write(z+"\n") # here we save the previous request's 
                    #subrequests list to the file
 
                j = 1 # for the new request reset everything
                w = [] 
                v = "\n" + file_contents[(10+i)+7]+" " # to save the name of the main request
                vv = " " + "Time(s) at: " +file_contents[10+i]+" "+ tim1 # to save time of the 
                #main request
                w.append(str(j) + ". " + file_contents[(10+i)+7]) # the main request should also 
                #appear at the list
                
    f.write(v+str(j)+vv+"\n") # saving the last main request list
    print v+str(j)+vv
    for z in w:
        f.write(z+"\n")
        print z
    f.close()     
