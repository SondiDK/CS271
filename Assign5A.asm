TITLE: Assignment5A - Designing low-level I/O procedures     (Assign5A.asm)

; Author: Daniel Beyer
; Course / Project ID CS 271                Date: 08/03/16
; Description: The user is prompted for 10 unsigned decimal integers small enough to fit inside 32 bit registers.
; 1. User's numeric input is validated the hard way: read as a string and converted to numeric form. If user enters 
; non-digits or a number that is too large, an error message will display and the number is discarded.
; 2. Conversion routines must use lodsb and stosb operators.
; 3. All procedure parameters must be passed on the system stack
; 4. Addresses of prompts, identifying strings, and other memory locations should be passed by address to macros.
; 5. Used registers must be saved and restored by called procedures and macros.
; 6. Stack must be cleaned up by call procedure.

INCLUDE Irvine32.inc

MAX = 4294967295

.data

;strings
	intro1		BYTE	"PROGRAMMING ASSIGNMENT 5A: Designing low-level I/O procedures", 0
	intro2		BYTE	"Written by: Daniel Beyer", 0
	instr1		BYTE	"Please provide 10 unsigned decimal integers.", 0
	instr2		BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 0
	instr3		BYTE	"After you have finished inputting the raw numbers, I will display a list of the integers, their sum, and average.", 0
	userlist	BYTE	"You entered the following numbers: ", 0
	usersum		BYTE	"The sum of these numbers is: ", 0
	useravg		BYTE	"The average of these numbers is: ", 0
	signoff		BYTE	"Thanks for playing!", 0
	spaces		BYTE	",  ", 0

	prompt1		BYTE	"Please enter an unsigned number: ", 0
	error1		BYTE	"ERROR: You did not enter an unsigned number or your number as too big.", 0
;variables
	array		DWORD	10 DUP (?)			;array to hold numbers
	charbuffer	BYTE	100 DUP(?)			;char entry from user
	usernum		DWORD	0
	charcount	DWORD	?
	avg			DWORD	?
	sum			DWORD	?
	numTostr		BYTE	100 DUP(?)

;macros
;-------------------------------------------------------------------------------
; Macro: getString
; Gets number from user to add to array
; Receives: prompt1, var
; Returns: None
; Registers used: edx, ecx, eax
;------------------------------------------------------------------------------
mgetString MACRO   varName
		push	ecx
		push	edx
		mov		edx, OFFSET prompt1
		call	WriteString
		mov		edx, varName
		mov		ecx, 20
		call	ReadString
		pop		edx
		pop		ecx
ENDM

;--------------------------------------------------------------------------
; Macro: displayString
; Displays messages
; Receives: string
; Returns: output to console
; Registers used: edx
;-----------------------------------------------------------------------------
mdisplayString	MACRO buffer
		push	edx
		mov		edx, buffer
		call	WriteString
		pop		edx
ENDM



.code
main PROC

push	OFFSET intro1			;24
push	OFFSET intro2			;20
push	OFFSET instr1			;16
push	OFFSET instr2			;12
push	OFFSET instr3			;8
call	introduction

push	OFFSET prompt1			;48
push	OFFSET charbuffer		;44
push	OFFSET usernum			;40
push	OFFSET array			;36
call	ReadVal

push	OFFSET usersum			;52		
push	OFFSET useravg			;48		
push	OFFSET array			;44
push	OFFSET sum				;40
push	OFFSET avg				;36
call	sumAvg


push	OFFSET spaces			;48
push	OFFSET userlist			;44
push	OFFSET numTostr			;40
push	OFFSET array			;36
call	writeVal

push	OFFSET signoff
call	farewell
exit	
main ENDP

;--------------------------------------------------------------
; Procedure: introduction 
; Greets user and gives brief instructions
; Receives: intro1, intro 2, instr1, instr2, instr3
; Returns: output to console
; Preconditions: none
; Registers changed: None
;---------------------------------------------------------------------
introduction	PROC
	push	ebp
	mov		ebp, esp
	pushad

	mdisplayString[ebp+24]
	call	CrLf
	mdisplayString[ebp+20]
	call	CrLf
	mdisplayString[ebp+16]
	call	CrLf
	mdisplayString[ebp+12]
	call	CrLf
	mdisplayString[ebp+8]
	call	CrLf

	popad
	pop		ebp
	ret		16

introduction	ENDP

;------------------------------------------------------------------------------
; Procedure: ReadVal
; Invokes getString macro to get the string of digits from the user, then converts the strong to numeric and 
; validates the user input
; Receives: prompt1, usernum, charcount, array, charbuffer, error1
; Returns: None
; Preconditions: parameters passed successfully
; Registers changed: eax, ebx, ecx, ebx, ebp, edi, esi
;---------------------------------------------------
ReadVal		PROC
	pushad
	mov		ebp, esp
	cld
	mov		ecx, 10
	mov		edi, [ebp+36]
	mov		eax, 1

outerLoop:



	push	edi				;edi = array		
	push	ecx				;ecx = outer loop count

		innerLoop:
			mgetString	[ebp+44]		
			mov		ecx, eax			
			mov		edi, [ebp+40]		;final int stored at edi	
			mov		ebx, 0
			mov		[edi], ebx			
			mov		esi, [ebp+44]		;charbuffer stored in esi	
			cmp		ecx, 10
			jg		invalidIn			;if greater than 10 digits, num too large

			;conversion from string to int
			str2int:
				mov		eax, [edi]		;current value of int into eax	
				mov		ebx, 10
				mul		ebx				;eax * 10	
				mov		[edi], eax		;int back into edi	

				lodsb						
				
				;input validation
				cmp		al, 48
				JL		invalidIn		
				cmp		al, 57
				JG		invalidIn

				sub		al, 48				
				add		[edi], al			
				loop	str2int

			Jmp		endInner

			invalidIn:
				mdisplayString OFFSET error1
				Jmp		innerLoop
			endInner:

	pop		ecx						
	mov		eax, [edi]				
	pop		edi						
	stosd							

					
	loop	outerLoop

	popad
	ret	9


ReadVal		ENDP

;------------------------------------------------------------------------------
; Procedure: sumAvg
; Handles calculating and displaying the sum and average of the int array
; Receives: array, sum, average, usersum, useravg
; Returns: None
; Preconditions: parameters passed successfully
; Registers changed: None
;---------------------------------------------------
sumAvg		PROC

	pushad
	mov		ebp, esp
	mov		ecx, 10
	mov		edi, [ebp+44]				;array
	mov		eax, 0
	
	sumLoop:
		add		eax, [edi]
		add		edi, 4
		loop	sumLoop
		
	;mov		esi, [ebp+40]					;saving sum
	;mov		[esi], eax

	call	CrLf
	mdisplayString [ebp+52]
	call	WriteDec
	call	CrLf
	
	mov		edx, 0
	mov		ebx, 10
	div		ebx								;finding average
	
	;mov		esi, [ebp+36]
	;mov		[esi], eax						;saving average

	mdisplayString [ebp+48]
	call	WriteDec
	call	CrLf


	popad
	ret		20
sumAvg		ENDP	

;------------------------------------------------------------------------------
; Procedure: writeVal
; Converts int array back to string to display to screen
; Receives:  spaces(56), userlist(52),numTostr(48), array(44), 
; Returns: None
; Preconditions: parameters passed successfully
; Registers changed: eax, ebx, ecx, ebx, ebp, edi, esi
;---------------------------------------------------		
writeVal		PROC

	pushad
	mov		ebp, esp

	mov		edi, [ebp+36]					;int array
	mov		ecx, 10
	mdisplayString[ebp+44]
	call	CrLf

	
	L1:
		push	ecx
		mov		eax, [edi]
		mov		ecx, 10
		xor		bx, bx						;used to count number of digits
		
	division:
		xor		edx, edx
		div		ecx
		push	dx
		inc		bx
		test	eax, eax
		jnz		division					;if eax not zero, move on
		
		mov		cx, bx
		mov		esi, [ebp+40]				 ;numTostr				
	nextInt:
		pop		ax
		add		ax, '0'						
		mov		[esi], ax
		
		mdisplayString [ebp+40]				;numTostr
		
		loop nextInt
		
		pop		ecx
		
		mdisplayString [ebp+48]
		mov		edx, 0
		mov		ebx, 0
		add		edi, 4
		loop	L1
		call	CrLf


		

		popad
		ret 8
writeVal ENDP 

;------------------------------------------------------------
; Procedure: farewell
; Signoff message
; Receives: signoff
; Returns: message to console
; Preconditions: None
; Registers changed: None
;-----------------------------------------------------------
farewell	PROC
	push	ebp
	mov		ebp, esp
	
	mdisplayString[ebp+8]
	call	CrLf

	pop ebp
	ret	4	
	
farewell		ENDP	
END main

