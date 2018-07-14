# SEYED YAHYA NIKOUEI CNS class of 2016 - final project
import getopt
import glob
import subprocess
from collections import Counter
import re
import sys
import parser
import argparse

#############################################################################################
def nmapOcheck(scannerIP,scan_packet):              #nmap -O
    found = 0
    n = 0
    for w in (scan_packet):
        if ((scan_packet[n].find(scannerIP) != -1)) and ((scan_packet[n].find(': ICMP echo request,') != -1)):
    #after knowing there was an scan if these keywords are found in an packet then it was an -O scan 
            outputfile.write('    scan type: nmap -O\n')
            print ('    scan type: nmap -O\n')
            found = 1
            return found
            break
        else:
            n += 1
    return found

#############################################################################################
def nmapFandsncheck(IP):                     #nmap -F and nmap -sn
    found = 0
    if (IP < 2):
        outputfile.write('    scan type: nmap -F\n')
        print ('    scan type: nmap -F\n')
        found = 1
        return found
    elif (IP == 0):
        outputfile.write('    scan type: nmap -sn\n')
        print ('    scan type: nmap -sn\n')
        found = 1
        return found
    else:
        return found

#############################################################################################
def nmapsVcheck(scannerIP,scan_packet):                           #nmap -sV
    found = 0
    n = 0
    for w in (scan_packet):
        if ((scan_packet[n].find(scannerIP) != -1)) and ((scan_packet[n].find(': Flags [F.], seq ') != -1)):
                # this keyword only exists in -sV scan    
            outputfile.write('    scan type: nmap -sV\n')
            print ('    scan type: nmap -sV\n')
            found = 1
            return found
            break
        else:
            n += 1
    return found

############################################################################################
def scan_type(scan_packet, scannerIP, IP,i):  
    found = 0   # to show what type of scans                             
    # in this function we check to for the scan type
    found = nmapOcheck(scannerIP,scan_packet)         #nmap -O check        
    if found == 0 :
        found = nmapFandsncheck(IP)            # nmap -F check and nmap -sn check
    if found == 0:
        found = nmapsVcheck(scannerIP,scan_packet)    # nmap -sV check
    if found == 0:
    #The scan that does not suit any of the previous check should be nmap -sS
        outputfile.write('    scan type: nmap -sS\n')
        print ('    scan type: nmap -sS\n')

##############################################################################################
def main(line) :        # after reading the files 
    i = -1              # loop iterater
    j = 1               # a pointer to show if a scan is detected
    IP = 0              # a counter of scanner IP repitition
    scan_packet = []    # to save the packets after scan detection
    scan_num = 0        # shows the number of scans in each file
    scannerIP = '0000'    
    victimIP = '0000'
    for word in line:
        i += 1     
        if (re.findall(r'ARP, Reply \S+ is-at \S+',word)) and \
            re.findall(r'oui Unknown',word) and re.findall(r'length 46',word) and \
            j == 1 and (re.findall(r'ARP,',line[i - 1])) and re.findall(r'Broadcast',line[i - 1]):              
        #moshkel az iene.. mese module1 halesh kon
        #Find the strings with 'ARP', 'Reply','oui Unknown' ,'length 46' and the last
        #line should have "Broadcast' in it to find the starting point of the scan
            if scan_num != 0 :
                scan_type (scan_packet, scannerIP, IP,i)    
            scan_num += 1
            IP = 0
            scan_packet = []
            victimIP = word.split()[4]
            scannerIP = (line[i - 1].split()[7]).replace(",","")
            t = (word.split())[0].replace("\"","")
            j = 0
            outputfile.write('    scanned from %s at %s\n' % (scannerIP, t))
            print ('    scanned from %s at %s\n' % (scannerIP, t))
        if (re.findall(r'ARP, Reply \S+ is-at \S+',word)) and re.findall(r'oui Unknown',word)\
          and re.findall(r'length 46',word) and (word.find(scannerIP) != -1) :
            IP += 1
        scan_packet.append(word) 
        if (re.findall(r'ARP, Reply \S+ is-at \S+',word)) and re.findall(r'oui Unknown',word) and re.findall(r'length 46',word)\
             and not(re.findall(r'ARP,',line[i - 1])) and not(re.findall(r'oui Unknown',line[i - 1]))\
             and not(re.findall(r'ARP',line[i - 1])) and not(re.findall(r'Broadcast',line[i - 1])):
        # to make it ready for the next scan, after one scan is detected we should be ready if another scan starts 
            j = 1
    if scan_num != 0 :
        scan_type (scan_packet, scannerIP, IP,i)             # this part is for the last scan in the loop

########################################################################################
line = []
outputfile = open('Report.txt', 'w')       # the file used to save the report
parser = argparse.ArgumentParser()         # this function handels the command-line options
parser.add_argument("--online", nargs='?', default="check_string_for_empty")
args = parser.parse_args()

if args.online == "check_string_for_empty" :      
    # if there is no command-line option then there should be a file to read from
    for files in glob.glob('*.log'):
        with open(files, 'r') as file:
            file_contents = file.read()
        line = file_contents.split('\n')
        line = file_contents.split('\n')
        outputfile.write('%s -->\n' % files)
        print ('%s -->\n' % files)
        main(line)                             # main function to handle the data
else :                                         # otherwise it should read from the line 
    file1 = sys.stdin.readlines()
#    line = file1.replace("\n","")           # what is read from the file is put into a array called line
#    line = line.replace(",","")
    outputfile.write('online given file -->\n')
    print ('online given file -->\n')
        #        line = file_contents.split('\n')                       #esme file nis ienja
        #outputfile.write('%s -->\n' % files)
    main(file1)

outputfile.close()
