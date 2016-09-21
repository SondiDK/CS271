TITLE Assignment1     (Assignment1.asm)

; Author: Daniel Beyer / beyerda@oregonstate.edu
; Course / Project ID: CS271 / Assignment1                 Date: 06/30/16
; Description: This program performs the following tasks:
; 1. Displays my name name and program title on the output screen
; 2. Displays instructions for the user
; 3. Prompts user for two numbers
; 4. Calculates sum, different, product, (integer) quotient, and remainder of numbers
; 5. Displays terminating message
; 6. Extra Credit: 

INCLUDE Irvine32.inc

; (insert constant definitions here)

.data

; user input
input1	DWORD	?
input2	DWORD	?	
choice	DWORD	?

; strings
title1		BYTE	"Assignment 1: Elementary Arithmetic", 0
name1		BYTE	"by Daniel Beyer", 0
instr1		BYTE	"Enter 2 numbers and I'll show you the sum, difference, product, quotient, and remainder", 0
instr2		BYTE	"Extra Credit: User chooses to continue or exit", 0
prompt_1	BYTE	"Enter first number: ", 0
prompt_2	BYTE	"Enter second number: ", 0
goodbye		BYTE	"Impressed? Bye!", 0
plus		BYTE	" + ", 0
minus		BYTE	" - ", 0
product		BYTE	" x ", 0
division	BYTE	" / ", 0
equals		BYTE	" = ", 0
remainder	BYTE	" remainder: ", 0
EC_prompt	BYTE	"Extra Credit: Would you like to try again? Enter 1 to start over or 0 to quit", 0

;calcResults
sum_res		DWORD	?
sub_res		DWORD	?
prod_res	DWORD	?
div_res		DWORD	?
rem_res		DWORD	?		

.code
main PROC

; intro
mov		edx, OFFSET title1			; Introduction
call	WriteString
call	CrLF
mov		edx, OFFSET name1
call	WriteString
call	CrLF

Begin:
; data input
mov		edx, OFFSET instr1			; Instructions
call	WriteString
call	CrLF
mov		edx, OFFSET instr2
call	WriteString
call	CrLF

mov		edx, OFFSET prompt_1		; Prompts for user input
call	WriteString
call	ReadInt
mov		input1, eax

mov		edx, OFFSET prompt_2
call	WriteString
call	ReadInt
mov		input2, eax
call	CrLF

; calculate sum, difference, product, and division results
; sum result
mov		eax, input1
add		eax, input2
mov	sum_res, eax					; answer stored in variable

; difference result
mov		eax, input1
sub		eax, input2
mov	sub_res, eax				; answer stored in variable

; product result
mov		eax, input1
mov		ebx, input2
mul		ebx
mov		prod_res, eax				; answer stored in variable

; division result
mov		edx, 0						; initialize to 0
mov		eax, input1
mov		ebx, input2
div		ebx
mov		div_res, eax				; answer and remainder stored in variables
mov		rem_res, edx

; results display
; display sum
mov		eax, input1
call	WriteDec
mov		edx, OFFSET plus
call	WriteString
mov		eax, input2
call	WriteDec
mov		edx, OFFSET equals
call	WriteString
mov		eax, sum_res
call	WriteDec
call	CrLF

; display difference
mov		eax, input1
call	WriteDec
mov		edx, OFFSET minus
call	WriteString
mov		eax, input2
call	WriteDec
mov		edx, OFFSET equals
call	WriteString
mov		eax, sub_res
call	WriteDec
call	CrLF

; display product
mov		eax, input1
call	WriteDec
mov		edx, OFFSET product
call	WriteString
mov		eax, input2
call	WriteDec
mov		edx, OFFSET equals
call	WriteString
mov		eax, prod_res
call	WriteDec
call	CrLF

; display division result with remainder
mov		eax, input1
call	WriteDec
mov		edx, OFFSET division
call	WriteString
mov		eax, input2
call	WriteDec
mov		edx, OFFSET equals
call	WriteString
mov		eax, div_res
call	WriteDec
mov		edx, OFFSET remainder
call	WriteString
mov		eax, rem_res
call	WriteDec
call	CrLF

; Extra Credit - ask if want to start over			; Extra Credit, jumps to Begin if user enters 1
mov		edx, OFFSET EC_prompt
call	WriteString
call	ReadInt
mov		choice, eax
mov		eax, 1
cmp		eax, choice
je		Begin

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
