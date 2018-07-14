#!/usr/bin/python
global load_num ; global add_num; global mul_num; global div_num; global branch_num#shows when the load or the save is going to be finished-so this number is going to be added with the cycle periods 
global commit
global reg # is an array for the registers
global memory #an array to show the memory values
global last_use # an array to show when the registry is going to be free, its index is the same as the FT
global FT # an array to show the flouting point registrs
global i # to have the number of the instructions
global k_load ;global k_add; global k_mul; global k_div
global ISSUE
global reg_in_use
reg_in_use = [0]*31
load_num = 0; add_num = 0; mul_num = 0; div_num = 0; branch_num = 0
ISSUE = [0]
memory = [45,12,0,0,10,135,254,127,18,4,55,8,2,98,13,5,233,158,167] # memory values Ivan gave us in the project
reg = [5]*31
last_use = [0]*31
FT = [0]*31
k_load = 2+1 # number to show the cycles to finish an instruction- right now i gave them numbers to be easier to test the program- in the end the user should give us that number
k_add = 3+1
k_mul = 7+1
k_div = 40+1
commit = 0 # to have a number for commit cycles
iss = [] #for issue in the end
##############################################################################################################################
def load (instruct):
    global load_num ;global commit;global reg ;global memory ;global last_use ;global FT ;global i ;global k_load ;global ISSUE ;global reg_in_use
    load_num = max (ISSUE[i],load_num)+1 # for issue we have only one unit- so we should be sure that there is no loads before. the max between the last load or the ith instruction
    ISSUE.append(load_num)
    reg_name = (instruct.split()[1]).replace("F","")[0] # FT address to load to
    add = instruct.split()[2] 
    offset = add.split("(")[0] # address offset
    mem = ((add.replace(")","")).split("(")[1]).split("$")[1] # memory address to load from which is in $*
    FT[int(reg_name)] = memory[(int(offset)+reg[int(mem)])] # loading
    load_num = max(last_use[int(reg_name)],load_num)+k_load # waiting for the registry to be free and issue- add the cycles its gana take
    last_use[int(reg_name)] = load_num # save the number when this FT is going to be free, load is finished
    
def save (instruct):
    global load_num ;global commit;global reg ;global memory ;global last_use ;global FT ;global i ;global k_load ;global ISSUE ;global reg_in_use
    load_num = max (ISSUE[i],load_num)+1
    ISSUE.append(load_num)
    reg_name = (instruct.split()[1]).replace("F","")[0]
    add = instruct.split()[2]
    offset = add.split("(")[0]
    mem = ((add.replace(")","")).split("(")[1]).split("$")[1]
    memory[(int(offset)+reg[int(mem)])] = FT[int(reg_name)]
    load_num = max(last_use[int(reg_name)],load_num)+k_load # because save is just reading the FT, then there is no need to have last_use updated


    
def add (instruct):
    global add_num ;global commit;global reg ;global memory ;global last_use ;global FT ;global i ;global k_add ;global ISSUE ;global reg_in_use
    add_num = max (ISSUE[i],add_num)+1
    ISSUE.append(add_num)
    reg_name1 = (instruct.split()[1]).replace("$","")[0]
    reg_name2 = (instruct.split()[2]).replace("$","")[0]
    reg_name3 = (instruct.split()[3]).replace("$","")[0]
    reg[int(reg_name1)] = reg[int(reg_name2)]+reg[int(reg_name3)]
    add_num = max(reg_in_use[int(reg_name1)],reg_in_use[int(reg_name2)],reg_in_use[int(reg_name3)],add_num)+k_add
    last_use[int(reg_name1)] = add_num

    
def addi(instruct):
    global add_num ;global commit;global reg ;global memory ;global last_use ;global FT ;global i ;global k_add ;global ISSUE ;global reg_in_use
    add_num = max (ISSUE[i],add_num)+1
    ISSUE.append(add_num)
    reg_name1 = (instruct.split()[1]).replace("$","")[0]
    reg_name2 = (instruct.split()[2]).replace("$","")[0]
    reg_name3 = (instruct.split()[3])
    reg[int(reg_name1)] = reg[int(reg_name2)]+int(reg_name3)
    add_num = max(reg_in_use[int(reg_name1)],reg_in_use[int(reg_name2)],add_num)+k_add
    last_use[int(reg_name1)] = add_num


def addd (instruct) :
    global add_num ;global commit;global reg ;global memory ;global last_use ;global FT ;global i ;global k_add ;global ISSUE ;global reg_in_use
    add_num = max (ISSUE[i],add_num)+1
    ISSUE.append(add_num)
    reg_name1 = (instruct.split()[1]).replace("F","")[0]
    reg_name2 = (instruct.split()[2]).replace("F","")[0]
    reg_name3 = (instruct.split()[3]).replace("F","")[0]
    FT[int(reg_name1)] = FT[int(reg_name2)]+FT[int(reg_name3)]
    add_num = max(last_use[int(reg_name1)],last_use[int(reg_name2)],last_use[int(reg_name3)],add_num)+k_add
    last_use[int(reg_name1)] = add_num


def subd (instruct):
    global add_num ;global commit;global reg ;global memory ;global last_use ;global FT ;global i ;global k_add ;global ISSUE ;global reg_in_use
    add_num = max (ISSUE[i],add_num)+1
    ISSUE.append(add_num)
    reg_name1 = (instruct.split()[1]).replace("F","")[0]
    reg_name2 = (instruct.split()[2]).replace("F","")[0]
    reg_name3 = (instruct.split()[3]).replace("F","")[0]
    FT[int(reg_name1)] = FT[int(reg_name2)]-FT[int(reg_name3)]
    add_num = max(last_use[int(reg_name1)],last_use[int(reg_name2)],last_use[int(reg_name3)],add_num)+k_add
    last_use[int(reg_name1)] = add_num


def subi(instruct):
    global add_num ;global commit;global reg ;global memory ;global last_use ;global FT ;global i ;global k_add ;global ISSUE ;global reg_in_use
    add_num = max (ISSUE[i],add_num)+1
    ISSUE.append(add_num)
    reg_name1 = (instruct.split()[1]).replace("F","")[0]
    reg_name2 = (instruct.split()[2]).replace("F","")[0]
    reg_name3 = (instruct.split()[3])
    FT[int(reg_name1)] = FT[int(reg_name2)]-int(reg_name3)
    add_num = max(last_use[int(reg_name1)],reg_in_use[int(reg_name2)],add_num)+k_add
    last_use[int(reg_name1)] = add_num

def multd(instruct):
    global mul_num ;global commit;global reg ;global memory ;global last_use ;global FT ;global i ;global k_mul ;global ISSUE ;global reg_in_use
    mul_num = max (ISSUE[i],mul_num)+1
    ISSUE.append(mul_num)
    reg_name1 = (instruct.split()[1]).replace("F","")[0]
    reg_name2 = (instruct.split()[2]).replace("F","")[0]
    reg_name3 = (instruct.split()[3]).replace("F","")[0]
    FT[int(reg_name1)] = FT[int(reg_name2)]*FT[int(reg_name3)]
    mul_num = max(last_use[int(reg_name1)],last_use[int(reg_name2)],last_use[int(reg_name3)],mul_num)+k_mul
    last_use[int(reg_name1)] = mul_num
    
def divd(instruct):
    global div_num ;global commit;global reg ;global memory ;global last_use ;global FT ;global i ;global k_div ;global ISSUE ;global reg_in_use
    div_num = max (ISSUE[i],div_num)+1
    ISSUE.append(div_num)
    reg_name1 = (instruct.split()[1]).replace("F","")[0]
    reg_name2 = (instruct.split()[2]).replace("F","")[0]
    reg_name3 = (instruct.split()[3]).replace("F","")[0]
    FT[int(reg_name1)] = FT[int(reg_name2)]/FT[int(reg_name3)]
    div_num = max(last_use[int(reg_name1)],last_use[int(reg_name2)],last_use[int(reg_name3)],div_num)+k_div
    last_use[int(reg_name1)] = div_num
    

     
#########################################################################################################################################

with open('instructions.txt', 'r') as file:
    file_contents = file.read()
file_contents = file_contents.replace(",", "")
file = file_contents.split("\n")
i = 0
z = 1
wat_do = []
while z:
    instruct = file[i]
    wat_do.append((instruct.split())[0])
    try :
        if wat_do[i] == "LD":
            load(instruct)
        elif wat_do[i] == "SD":
            save(instruct)
        elif wat_do[i] == "ADD":
            add(instruct)
        elif wat_do[i] == "ADDI":
            addi(instruct)
        elif wat_do[i] == "ADD.D":
            addd(instruct)
        elif wat_do[i] == "SUB.D":
            subd(instruct)
        elif wat_do[i] == "SUBI":
            subi(instruct)
        elif wat_do[i] == "MULT.D":
            multd(instruct)
        elif wat_do[i] == "DIV.D":
            divd(instruct)
        elif wat_do[i] == "BEQ":
            beq(instruct)
        elif wat_do[i] == "BNE":
            bne(instruct)
        else :
            k = 'k'+2
    except IOError:
        print ("instruction not preset : Error loading the instruction, compile Error")        
    i = i+1
    if i>(len(file)-1):
        z = 0

