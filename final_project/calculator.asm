;Bryce Lin
;CPSC240-13 Final Project
;CWID: 886216571
;Description: This program is a calculator that  take multiple numbers 
;		and operation inputs and calculate the result of the 
;		formula that user inputed.
;Example inputs:
;		2x2+5-1=
;		8x1/8+3-6=
;		2=
;		3x3x3x3=

%macro print 0
	mov	rax, SYS_WRITE
	mov	rdi, STD_OUT
	syscall
%endmacro

%macro nl 0
	mov	rsi, NL
	mov	rdx, 1
	print
%endmacro

section .data
	prompt		db	"Please enter the equation: ", 0
	lenP		dq	$-prompt-1 
	errorMessage1	db	"Input error, Please make sure the input format is ", 0x22, "a+b-...xc/d=", 0x22, 
			db	0xA, "No space is allow in the input.", 0xA, 
			db	"Equal sign is needed at the end of equation.", 0xA, 0
	lenE1		dq	$-errorMessage1-1
	lenA		dq	3
	input_actual	dq	0			;actual length from user input
	negative	db	0			;flag for the negative sign

	NL		db	0xA

	SYS_READ	equ	0
	SYS_WRITE	equ	1
	SYS_EXIT	equ	60

	STD_IN		equ	0
	STD_OUT		equ	1
	INPUT_LEN	equ	50
section .bss
	input	resb INPUT_LEN				;store the user input
	answer	resb 60					;store the answer in reverse order
section .text
	global	_start
_start:
	mov	rsi, prompt				;prompt user to enter the equation
	mov	rdx, qword[lenP]
	print

	mov	rax, SYS_READ				;take user input
	mov	rdi, STD_IN
	mov	rsi, input
	mov	rdx, INPUT_LEN
	syscall

	dec	rax					;save the length of the array that
	mov	qword[input_actual], rax		;user actually input.

	nl
	
	mov	rax, 0					;read the first number and other 
	mov	rsi, input				;variable initialization
	mov	r8, 0
	mov	r9, 0
	mov	al, byte[rsi]
	and	al, 0x0F
	inc	rsi
calculation:
	mov	r8, 0					;initialize the r8 and r9 to 0
	mov	r9, 0
	mov	r8b, byte[rsi]				;mov operator into r8b
	inc	rsi					;mov index to next character
	mov	r9b, byte[rsi]				;mov integer 0-9 into r9b
	inc	rsi					;mov index to next character
	cmp	r8b, 0x3D				;will end the calculation when
	je	endOfCal				;the last digit is '='

	cmp	r9b, 0x30				;make sure the number is between 0-9
	jl	inputError1				;or else jump to input error
	cmp	r9b, 0x39
	jg	inputError1

	and	r9b, 0x0F				;convert ascii to number

	cmp	r8b, 0x2A				;go through all possible operation
	je	multing					;with comparing r8b
	cmp	r8b, 0x78
	je	multing
	cmp	r8b, 0x2B
	je	adding
	cmp	r8b, 0x2D
	je	subing
	cmp	r8b, 0x2F
	je	diving
	jmp	inputError1

multing:						;multiply rax by the next number
	imul	r9
	jmp	calculation
adding:							;adding rax by the next number
	add	rax, r9
	jmp	calculation
subing:							;subtracting rax by the next number
	sub	rax, r9
	jmp	calculation
diving:							;dividing rax by the next number
	cqo
	idiv	r9
	jmp	calculation

endOfCal:						;end of calculation
	cmp	rax, 0					;check if the rax is a negative number or not
	jge	pos					;if rax is positive, jump to pos
	mov	byte[negative], 1			;set negative flag to 1 (true)
	neg	rax					;flip rax to positive number
pos:
	mov	r10, 10					;initialize for the Ascii translation
	mov	r9, answer				;r10 for divisor, r9 for the array address 
	mov	byte[r9], 0xA				;save the 0x10 into first element since
	inc	r9					;this array will be printing in reverse order
 
loopAscii:
	cqo						;convert rax to rdx:rax
	div	r10					;rdx:rax divide by 10
	mov	byte[r9], dl				;save the value into the array
	add	byte[r9], 0x30				;add 0x30 to the array

	inc	r9					;move to the next address of the array	
	cmp	rax, 0					;check if rax turn into 0 yet or not
	ja	loopAscii				;jump to loopAscii if rax > 0

	mov	rsi, input				;print out user input
	mov	rdx, qword[input_actual]
	print


	cmp	byte[negative], 0			;checking negative flag
	je	loopPrint				;jump to loopPrint if flag = 0
	mov	byte[r9], 0x2D				;add negative sign at the end of the array

loopPrint:						;for printing the array in reverse.
	mov	rsi, r9
	mov	rdx, 1
	print

	dec	r9					;compare r9 to the array at index 0, if
	cmp	r9, answer				;r9 haven't reach index 0 yet, keep subtract
	jae	loopPrint				;r9 until it reach index 0.
	jmp exit

inputError1:						;show error message when the user input
	mov	rsi, errorMessage1			;the number in the wrong way
	mov	rdx, qword[lenE1]
	print
	jmp	exit

exit:	
	nl						;exit successfuly
	mov	rax, SYS_EXIT
	mov	rdi, 0
	syscall
