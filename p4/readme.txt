;**************************************************************************
; MICROPROCESSOR-BASED SYSTEMS
; LAB SESSION 4
; FILE: readme.txt
; AUTHORS: Emilio Cuesta Fernandez - Alejandro Sanchez Sanz
; COUPLE NUMBER: 8
; GROUP: 2351
;**************************************************************************

We have taken some decisions during the implementation of these exercises, sometimes because the wording wasn't so clear, other times in order to add some useful functionalities for the exercise or for another one:
    * We started developing exercises p4a.asm and p4b.asm (exercises 1 and 2), but as we had to modify p4a.asm for the 3rd exercise, we have decided to keep the
      original file from exercise 1. It is called p4a1.asm, and you can generate the p4a1.com typing 'make origin'. That generates p4a1.com and p4b.exe, in order
      to test exercises 1 and 2. Anyway, those exercises can also be tested with p4a.com and p4b.exe, generated with 'make'.
    * We've decided to add 2 extra functionalities to the INT55h (in p4a1.asm just the first one):
    	- AH = 08h -> It is used to check if our driver is installed or not. It stores a 1 in AH.
    	- AH = 07h -> It is used to check if RTC is printing or not. It stores the printing flag in AH.
    * We've decided to add a functionality to p4a.asm and p4a1.asm, which is showing an error message when wrong parameters are introduced.
    * We've found a way to store the previous values of the interruption vector and registers A and B, like using a global variable, but that solution has 
      troubles with the design of introducing parameters. Because of that, we have decided to fill those gaps with zeros when we uninstall them.
    * We've decided that we can just uninstall our own driver. We've also decided that we can install our driver when there is nothing installed or if the user
      confirms that typing 'y'. 
    * We had to configure RTC with a frequency of 1 Hz but the minimum value we can obtain with register A is 2 Hz. Our solution to simulate the 1 Hz frequency is 
      using a global variable COUNTER, which starts with a value of 2 and it is decreased in each interruption 70h. When it is 1 we don't do anything and when it 
      is 0 we print and restart the counter to 2. Doing so we accomplish the 1 Hz behaviour. 
