TITLE Assignment4     (Assignment4.asm)

; Author: Daniel Beyer / beyerda@oregonstate.edu
; Course / Project ID: CS271 / Assignment4                 Date: 07/25/16
; Description: This program performs the following tasks:
; 1. Introduces the program
; 2. Get a user request in the range [min = 10...max = 200]
; 3. Generates request random integers in the range [lo = 100...hi = 999],
; storing them in consecutive elements in an array
; 4. Displays the list of integers, 10 per line
; 5. Sorts the list in descending order
; 6. Calculates and displays the median value, rounded to nearest integer, and displays the sorted list

INCLUDE Irvine32.inc

; Constants
min = 10
max = 200
lo = 100
hi = 999

.data
introTitle			BYTE	"Assignment 4 - Arrays", 0
introName			BYTE	"by Daniel Beyer", 0
uinstr_1			BYTE	"This program will generate a user-defined number of random integers", 0
uinstr_2			BYTE	"It will display them in unsorted order first", 0
uinstr_3			BYTE	"It will then sort the list in descending order and calculate and display the median", 0
uinstr_4			BYTE	"Finally, it will display the sorted list", 0
extra_cr1			BYTE	"EC1: Other? I changed the text color to green, passed these parameters by value to the stack.", 0
user_prompt			BYTE	"Enter the number of random integers to display (from 10 to 200)", 0

spaces				BYTE	"     ", 0
invalid_input		BYTE	"Invalid input, please try again", 0
sorted_list			BYTE	"SORTED LIST: ", 0
unsorted_list		BYTE	"UNSORTED LIST: ", 0
median_msg			BYTE	"Median number is: ", 0

request				DWORD	?
array	DWORD	max		DUP(?)

color_1				DWORD	2
color_2				DWORD	16



.code
main PROC

	call	Randomize

	push	color_1
	push	color_2
	call	funColor

	call	introduction

	push	OFFSET request			;@request
	call	getData

	push	OFFSET array			;@array
	push	request					;value of request
	call	fillArray

	push	OFFSET unsorted_list
	push	OFFSET array			;@array
	push	request					;value of request
	call	displayArr

	push	OFFSET array
	push	request
	call	sortList

	push	OFFSET array
	push	request
	call	displayMedian

	push	OFFSET sorted_list
	push	OFFSET array			;@array
	push	request					;value of request
	call	displayArr


	exit	
main ENDP

;--------------------------------------------------------------
; Procedure: funColor
; Changes color output to green for extra credit (Other?)
; Receives: color_1 and color_2 values
; Returns: None
; Preconditions: color_1 and color_2 are valid integers between 0 and 16
; Registers changed: eax, esp
;----------------------------------------------------------------------
funColor	PROC
	
	push	ebp
	mov		ebp, esp
	mov		eax, [ebp+8]		;color_1
	imul	eax, 16
	add		eax, [ebp+12]		;color_2
	call	setTextColor
	pop		ebp
	ret		8
funColor	ENDP

;--------------------------------------------------------------
; Procedure: introduction 
; Greets user and gives brief instructions
; Receives: none
; Returns: none
; Preconditions: none
; Registers changed: edx
;---------------------------------------------------------------------
introduction	PROC

	mov		edx, OFFSET introTitle
	call	WriteString
	call	Crlf
	mov		edx, OFFSET introName
	call	WriteString
	call	Crlf
	mov		edx, OFFSET uinstr_1
	call	WriteString
	call	Crlf
	mov		edx, OFFSET uinstr_2
	call	WriteString
	call	Crlf
	mov		edx, OFFSET uinstr_3
	call	WriteString
	call	Crlf
	mov		edx, OFFSET uinstr_4
	call	WriteString
	call	Crlf
	mov		edx, OFFSET extra_cr1
	call	WriteString
	call	Crlf
	call	Crlf
	ret
introduction ENDP

;------------------------------------------------------------------------
; Procedure: getData
; Obtains and validates an integer from the user between 10 and 200
; Receives: request passed by reference
; Returns: request
; Preconditions: min and max are positive integers
; Registers changed: edx, eax
;--------------------------------------------------------------------------------
getData		PROC
	push	ebp						;set up stack frame
	mov		ebp, esp
getDataLoop:


	mov		ebx, [ebp+8]			;get address of request into ebx
	mov		edx, OFFSET user_prompt 
	call	WriteString
	call	ReadInt
	mov		[ebx], eax			;store user input at address in ebx

	;input validation
	
	cmp		eax, min
	jl		invalid_num
	cmp		eax, max
	jg		invalid_num
	jmp		valid_num

invalid_num:
	
	mov		edx, OFFSET invalid_input
	call	WriteString
	call	Crlf
	jmp		getDataLoop

valid_num:

	
	pop		ebp
	ret		4
getData		ENDP

;------------------------------------------------------------------------
; Procedure: fillArray
; Fills array with random numbers
; Receives: request by value, array by reference
; Returns: array filled with user-specified (request) number of random integers
; Preconditions: Request is an integer between 10 and 200
; Registers changed: eax, edi
;---------------------------------------------------------------------------------
fillArray	PROC

	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+12]			;@array in edi
	mov		ecx, [ebp+8]			;value of request as loop control

L1:
	;generate random number (Source: Lecture 20, CS271)
	mov		eax, hi
	sub		eax, lo
	inc		eax
	call	RandomRange
	add		eax, lo

	;insert random number into array
	mov		[edi], eax
	add		edi, 4
	loop	L1

	pop		ebp
	ret		8
fillArray	ENDP

;-----------------------------------------------------------------
; Procedure: display
; Displays list of random numbers in array
; Receives: address of array, value of request(number of random integers)
; Returns: Displays array
; Preconditions: array is populated by values
; Registers changed: eax
;-------------------------------------------------------------------
displayArr		PROC

	push	ebp
	mov		ebp, esp
	mov		edx, [ebp+16]
	call	WriteString
	call	Crlf
	mov		esi, [ebp+12]			;@array
	mov		ecx, [ebp+8]			;value of request as loop control

L1:
	mov		eax, [esi]				;get current element
	call	WriteDec
	mov		edx, OFFSET spaces
	call	WriteString
	add		esi, 4					;next element
	loop	L1

	pop		ebp
	ret		8
displayArr		ENDP

;--------------------------------------------------------------------------------
; Procedure: sortList
; Sorts array in descending order
; Receives: address of arry and value of request
; Returns: None
; Preconditions: Populated array
; Registers changed: eax, ecx, edx, ebx
;-----------------------------------------------------------------------------------
sortList	PROC
	push	ebp
	mov		ebp, esp

	mov		ecx, [ebp+8]		;value of request
	dec		ecx
L1:
	push	ecx
	mov		esi, [ebp+12]
L2:
	mov		eax, [esi]
	cmp		[esi+4], eax
	jl		continue
	xchg	eax, [esi+4]
	mov		[esi], eax
continue:
	add		esi, 4
	sub		ecx, 1
	cmp		ecx, 0
	jg		L2
	pop		ecx
	sub		ecx, 1
	cmp		ecx, 0
	jg		L1
	pop		ebp
	ret		8
sortList		ENDP

;----------------------------------------------------------------------------------------------
; Procedure: displayMedian
; Calculates and displays the median number from the sorted array
; Receives: address of array and value of request
; Returns: Displays median
; Preconditions: Populated sorted array
; Registers changed: eax
;--------------------------------------------------------------------------
displayMedian	PROC
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+12]		;array
	mov		eax, [ebp+8]		;request
	
	mov		edx, 0
	mov		ebx, 2
	div		ebx					;eax = request / 2
	cmp		edx, 0				;if remainder = 0, number is even and need to find avg of middle 2 numbers
	je		evenNum
	mov		eax, [edi+eax*4]
	jmp		endDisplayMedian

	evenNum:
		mov		ebx, [edi+eax*4]
		sub		eax, 1
		mov		eax, [edi+eax*4]
		add		eax, ebx
		mov		ebx, 2
		mov		edi, 0
		div		ebx
	endDisplayMedian:
		call	Crlf
		mov		edx, OFFSET median_msg
		call	WriteString
		call	WriteDec
		call	Crlf

		pop		ebp
		ret		8
displayMedian ENDP
END main


