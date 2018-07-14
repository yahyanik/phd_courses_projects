from __future__ import division
import csv
import re
import os
from collections import Counter
from pip._vendor.requests.packages.chardet.latin1prober import FREQ_CAT_NUM
from itertools import islice, izip

with open('text.txt', 'r') as file:       # reading the text file
    file_contents = file.read()
jom = (file_contents.lower().count('.')+file_contents.lower().count('?')+file_contents.lower().count('!')+file_contents.lower().count(':'))  
print'total sentences:', jom
#counting sentences with the usage of their ending
the_jom = (file_contents.lower().count('. the')+file_contents.lower().count('? the')+file_contents.lower().count('! the')+file_contents.lower().count('" the')+file_contents.lower().count(': the'))
print'total sentences with THE:',  the_jom, "\nfrequency of sentences with THE:" , (the_jom/jom)
# counting sentences starting with the. every thing is in lower case so we do this once with "the"
file_contents = file_contents.replace("'s", "")
file_contents = file_contents.replace("'t", "")
file_contents = file_contents.replace(".", "")
file_contents = file_contents.replace(",", "")
file_contents = file_contents.replace("\"", "")
file_contents = file_contents.replace("/", " ")
file_contents = file_contents.replace(":", "")
file_contents = file_contents.replace("-", " ")
file_contents = file_contents.replace("!", "")
file_contents = file_contents.replace("?", "")

e = len(file_contents.split()) # number of words according to the space dividing them
print 'Total words:', e
k = []
zz1 = []
words = re.findall(r'\w+', file_contents.lower())
zz = Counter(words).most_common(e)
# we include the frequncy to the list
for g in zz:
    tedad = g[1]
    freq = tedad/e
    k = list(g)
    k.append(freq)
    zz1.append(k)
    # the following line gives the word combinations we wanted and .most_common gives the first item in that list
print "the most frequent word combination and the times it appeared: ", Counter(izip(words, islice(words, 1, None))).most_common(1)

# saving the results
with open("result.csv", "wb") as fou:
    writer = csv.writer(fou)
    writer.writerow(zz1)
os.system("pause")
