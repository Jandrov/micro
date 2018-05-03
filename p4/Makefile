##################################################################
# MICROPROCESSOR-BASED SYSTEMS
# LAB SESSION 4
# FILE: MAKEFILE
# AUTHORS: Emilio Cuesta Fernandez - Alejandro Sanchez Sanz
# COUPLE NUMBER: 8
# GROUP: 2351
##################################################################


all: p4a.com p4b.exe p4c.exe

p4a.com: p4a.obj
    tlink /v /t p4a

p4b.exe: p4b.obj
    tlink /v p4b

p4c.exe: p4c.obj
    tlink /v p4c

p4a.obj: p4a.asm
    tasm /zi p4a.asm ,, p4a.lst

p4b.obj: p4b.asm
    tasm /zi p4b.asm ,, p4b.lst

p4c.obj: p4c.asm
    tasm /zi p4c.asm ,, p4c.lst

clean: 
	del *.com
    del *.exe
    del *.obj
    del *.lst
    del *.map
    
