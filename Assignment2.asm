TITLE Assignment2     (Assignment2.asm)

; Author: Daniel Beyer / beyerda@oregonstate.edu
; Course / Project ID: CS271 / Assignment2                 Date: 07/08/16
; Description: This program calculates Fibonacci numbers
; 1. Displays the program title and programmer's name
; 2. Prompts the user for their name and greets them
; 3. Prompts user to enter number of Fibonacci terms to display (1-46)
; 4. Validates user input
; 5. Calculates and displays Fibonacci numbers up to and include nth term
; 6. Results are dispayed 5 terms per line with 5 spaces between them
; 7. Displays parting message including user's name 

INCLUDE Irvine32.inc

UPPER_Limit = 46

.data

introTitle		BYTE	"Assignment 2 - Fibonacci Numbers", 0
introName		BYTE	"by Daniel Beyer", 0
userInstr		BYTE	"You will enter number of the Fibonacci terms to display and this program will display the Fibonacci numbers", 0
prompt_1		BYTE	"Please enter your name:", 0
userGreet		BYTE	"Hello, ", 0
prompt_2		BYTE	"Enter number of Fibonacci terms to display (between 1 and 46)", 0
errorRange		BYTE	"Out of range. Enter a number in [1...46]", 0
finished		BYTE	"Results certified by Daniel Beyer", 0
finished_1		BYTE	"Goodbye, ", 0
valid_1			BYTE	"I will display ", 0
valid_2			BYTE	" Fibonacci numbers", 0
ec_intro		BYTE	"**EC: Do something incredible - changed background color to blue!", 0

userName		DWORD	35 DUP(0)
userNum			DWORD	?					;number of terms to display
fibSum			DWORD	?					;running Fibonacci sum
spaces			BYTE	"     ", 0
fib1			DWORD	?					;current number to add to Fibonacci sum 
counter			DWORD	?					;counter for maintaining 5 terms per line


.code
main PROC


;-Extra Credit-
; changes background color to light blue and keeps text color as white
mov ax,0
mov al,097H  ;Text to white, blue background
call settextcolor


;-Introduction-

mov		edx, OFFSET introTitle
call	WriteString
call	CrLf
mov		edx, OFFSET ec_intro
call	WriteString
call	CrLf

mov		edx, OFFSET introName
call	WriteString
call	CrLf

;-userInstructions-

mov		edx, OFFSET userInstr
call	WriteString
call	CrLf

;-getUserData-

mov		edx, OFFSET prompt_1
call	WriteString
mov		edx, OFFSET userName
mov		ecx, SIZEOF userName
call	ReadString
mov		edx, OFFSET userGreet
call	WriteString
mov		edx, OFFSET userName
call	WriteString 
call	CrLf
call	CrLf

;input validation loop
loop_validation:
mov		edx, OFFSET prompt_2
call	WriteString
call	ReadInt
mov		userNum, eax

;If user input > 1, jump to error message
mov		eax, userNum
cmp		eax, 46
jg		error_message

;If user input < 1, jump to error message
mov		eax, userNum
cmp		eax, 1
jl		error_message

;If user input is in range, jump to end of loop
jmp		end_loop

error_message:
mov		edx, OFFSET errorRange
call	WriteString
call	CrLf
jmp		loop_validation				;loop reprompts user for new numbers


end_loop:	
mov		edx, OFFSET valid_1
call	WriteString
mov		eax, userNum
call	WriteDec
mov		edx, OFFSET valid_2
call	WriteString
call	CrLf

;-displayFibs-

;initial conditions
mov		eax, 0
mov		ebx, 1
mov		ecx, userNum
mov		fibSum, 1
mov		fib1, 0
mov		counter, 0

;print initial "1" 
mov		eax, fibSum
call	WriteDec
dec		ecx

;If user input was "1", jump to ending farewell
cmp		userNum, 1
je		farewell

fibLoop:
;main math operations happen here

mov		eax, fibSum
add		eax, fib1
mov		fibSum, eax

mov		fib1, ebx
mov		edx, OFFSET spaces
call	WriteString
mov		ebx, fibSum

cmp		counter, 5
jl		contRow						;if counter has reached 5, new line is started

call	CrLf
mov		counter, 0

;Fibonacci numbers are displayed here
contRow:
call	WriteDec
mov		edx, counter
inc		edx
mov		counter, edx

loop fibLoop

;-Farewell-

farewell:
call	CrLf
mov		edx, OFFSET finished
call	WriteString
call	CrLf
mov		edx, OFFSET finished_1
call	WriteString
mov		edx, OFFSET userName
call	WriteString
call	CrLf



	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
