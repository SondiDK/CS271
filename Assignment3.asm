TITLE Assignment3     (Assignment3.asm)

; Author: Daniel Beyer / beyerda@oregonstate.edu
; Course / Project ID: CS271 / Assignment3                 Date: 07/022/16
; Description: This program calculates composite numbers. The user is promped to enter an integer in 
; the range [1-400], n, and the program verifies that 1<=n<=400.  If n is out of range, the user is 
; reprompted until they enter a valid integer.  The program then calculates and displays all the composite
; numbers up to and including the nth composite.  The results are displayed 10 per line with 3 spaces between.  


INCLUDE Irvine32.inc

UPPER_Limit = 400
LOWER_Limit = 1

.data

introTitle		BYTE	"Assignment 3 - Composite Numbers", 0
introName		BYTE	"by Daniel Beyer", 0
ec1				BYTE	"EC: EC1 - Aligned output columns", 0
userInstr		BYTE	"The user will enter an integer (n) from 1-400 and this program calculates and displays all composite numbers up to and including the nth composite.", 0
prompt_1		BYTE	"Please enter the number of composites to display (1 - 400):", 0
errorRange		BYTE	"Out of range. Try again.", 0
finished		BYTE	"Results certified by Daniel Beyer.  Goodbye", 0
spaces			BYTE	"   ", 0

user_num		DWORD	?
currCompNum		DWORD	?
currLoopNum		DWORD	?
counter			DWORD	0

.code
main PROC

call intro

call getUserData

call showComposites

;call farewell

	exit	
main ENDP

; Procedure: intro 
; Greets user and gives brief instructions
; Receives: none
; Returns: none
; Preconditions: none
; Registers changed: edx
intro PROC

	mov		edx, OFFSET introTitle
	call	WriteString
	call	Crlf
	mov		edx, OFFSET introName
	call	WriteString
	call	Crlf
	mov		edx, OFFSET ec1
	call	WriteString
	call	Crlf
	mov		edx, OFFSET userInstr
	call	WriteString
	call	Crlf
	ret

intro ENDP

; Procedure: getUserData
; Prompts user for integer 1-400 and calls validate procedure
; Receives: None
; Returns: user input saved in variable user_num
; Registers changed: edx
getUserData PROC
	
	mov		edx, OFFSET prompt_1
	call	WriteString
	call	ReadInt
	mov		user_num, eax
	call	validate
	ret

getUserData ENDP

; Procedure: validate
; Validates that user input is between 1 and 400.  If not, user is reprompted until a valid input is used
; Receives: user_num, UPPER_Limit
; Returns: valid input integer, or error message if outside upper and lower limits
; Registers changed: eax, edx
validate PROC

	cmp		user_num, UPPER_Limit
	jg		invalidNum
	cmp		user_num, LOWER_Limit
	jl		invalidNum
	jmp		validNum
	
	invalidNum:
		mov		edx, OFFSET errorRange
		call	WriteString
		call	Crlf
		call	getUserData
		
	validNum:
		ret 

validate ENDP

; Procedure: showComposites
; Displays composite numbers up to and including user-defined input. 10 per line with 5 spaces between each
; Receives: user_num
; Returns: Output composite numbers to screen
; Registers changed: eax, ecx
showComposites PROC

	mov		ecx, user_num
	mov		eax, 4
	mov		currLoopNum, eax


	mainLoop:
		call	isComposite
		mov		eax, currCompNum
		call	WriteDec
		mov		edx, OFFSET spaces
		call	WriteString
		mov		al, 9			;columns aligned here using tab spaces
		call	WriteChar

		;Output formatting handled below
		inc		counter
		mov		eax, counter
		mov		edx, 0
		mov		ebx, 10
		div		ebx
		cmp		edx, 0
		jne		sameLine
		call	Crlf

		sameLine:
		loop	mainLoop
		ret

showComposites ENDP

; Procedure: isComposite
; Determine next composite number
; Receives: user_num
; Returns: next composite number
; Registers changed: eax, ebx
isComposite	PROC

	innerLoop:
	xor		edx, edx
	mov		eax, currLoopNum
	mov		ebx, 2
	div		ebx
	cmp		edx, 0
	je		yesCompNum		;even number and therefore composite
	inc		ebx
	oddLoop:
		xor		edx, edx
		xor		eax, eax
		cmp		ebx, currLoopNum 
		je		noCompNum
		mov		eax, currLoopNum
		div		ebx
		cmp		edx, 0
		je		yesCompNum
		add		ebx, 2
		jmp		oddLoop
	yesCompNum:
		mov		eax, currLoopNum
		mov		currCompNum, eax
		inc		currLoopNum
		jmp		done

	noCompNum:
		inc		currLoopNum
		jmp		innerLoop

	done:
		ret

isComposite ENDP

END main
