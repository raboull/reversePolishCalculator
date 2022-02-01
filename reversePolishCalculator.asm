
																	//use equate statements to define constants
						fp .req x29									//use equate to define the frame pointer
						lr .req x30									//use equate to define the link reference

																	//define registers that will be used often
						define(i_r, w19)							//define a register for the i variable
						define(c_r, w20)							//define a register for the c variable
						define(sptr_r, x21)							//define a register for the s array pointer
						define(lim_r, w22)							//define a register for the lim variable

																	//define constants in our program
						NUMBER = '0'								//Define the NUMBER constant
						TOOBIG = '9'								//Define the TOOBIG constant
						MAXVAL = 100								//Define the MAXVAL constant
						BUFSIZE = 100								//Define the BUFSIZE constant

																	//Declare and initialize global variables
						.data										//declare where the following code is to be stored in memory
						.global sp_m								//make the sp_m variable accessible to other compilation units
						.global val_m								//make the val_m variable accessible to other compilation units
						.global bufp_m								//make the bufp_m variable accessible to other compilation units
						.global buf_m								//make the buf_m variable accessible to other compilation units
sp_m:					.word	0									//allocate word length amount of memory and initialize its value to zero
val_m:					.skip MAXVAL*4								//allocate enough space for an array of ints with a length of MAXVAL
bufp_m:					.word	0									//allocate word length amount of memory and initialize its value to zero
buf_m:					.skip BUFSIZE*1								//allocate enough space for an array of chars with a length of BUFSIZE

						.text										//define the string constants used in the program
stack_full_err:			.string "error: stack full\n"				//define the stack_full_msg string constant and store in the .text memory section
stack_empt_err:			.string "error: stack empty\n"				//define the stack_empt_msg string constant and store in the .text memory section
too_many_c_err:			.string "ungetch: too many characters\n"	//define the too_many_c_msg string constant and store in the .text memory section


						.global push								//make the push label accessible to other compilation units
						.balign 4									//allign the following instructions to make sure that they are divisible by 4

push:					stp	fp, lr, [sp, -16]!						//creates a frame record and allocates memory for our local variables on the stack
						mov	fp, sp									//moves the fp to the current sp location

						adrp	x9, sp_m							//store the address of the global variable sp_m in register x9
						add	x9, x9, :lo12:sp_m						//complete the address location of the x9 register
						ldr	w10, [x9]								//store the content in address referenced by x9 in the w10 register

						cmp	w10, MAXVAL								//compare w10 value to the constant MAXVAL
						b.ge	else_push							//branch to the else label if  w10 is greater or equal to MAXVAL

																	//return val[sp++] = f;
						adrp	x11, val_m							//store the address of the val_m global variable in register x11
						add	x11, x11, :lo12:val_m					//complete the address location of the x11 register
						str	w0, [x11, w10, SXTW 2]					//store the input argument into val array at current index of sp_m

						add	w10, w10, 1								//increment the sp_m pointer value by 1
						str	w10, [x9]								//store the incremented sp_m value

						b	end_of_push								//branch to the end of this push function and exit in the usual way

else_push:				adrp	x0, stack_full_err					//store the address of the stack_full_err string as the first argument
						add	x0, x0, :lo12:stack_full_err			//complete the address of the stack_full_err string
						bl	printf									//branch and link to the printf function
						bl	clear									//branch and link to the clear function
						mov	w0, 0									//set the returning value of this function to zero

end_of_push:			ldp	fp, lr, [sp], 16						//deallocate stack memory used by push
						ret											//return control to the calling code


						.global pop									//make the pop label accessible to other compilation units
						.balign 4									//allign the following instruction to make sure that they are divisible by 4

pop:					stp	fp, lr, [sp, -16]!						//creates a frame record and allocates memory for our local variables on the stack
						mov	fp, sp									//moves the fp to the current sp location

						adrp	x9, sp_m							//store the address of the global variable sp_m in register x9
						add	x9, x9, :lo12:sp_m						//complete the address location of the x9 register
						ldr	w10, [x9]								//store the content in address referenced by x9 in the w10 register

						cmp	w10, 0									//compare w10 value to the zero value
						b.le	else_pop							//branch to the else_pop label if w10 is less or equal to zero

																	//return val[--sp]
						sub	w10, w10, 1								//decrement the sp_m pointer by 1
						adrp	x11, val_m							//store the address of the val_m global variable in register x11
						add	x11, x11, :lo12:val_m					//complete the address location of the x11 register
						ldr	w0, [x11, w10, SXTW 2]					//set the returning value of this function to val[--sp]
						str	w10, [x9]								//store the decremented sp_m value in sp_m

						b	end_of_pop								//branch to the end of this pop function and exit in the usual way

else_pop:				adrp	x0, stack_empt_err					//store the address of the stack_empt_err string as the first argument
						add	x0, x0, :lo12:stack_empt_err			//complete the address of the stack_empt_err string
						bl	printf									//branch and link to the printf function
						bl	clear									//branch and link to the clear function
						mov	w0, 0									//set the returning value of this functino to zero

end_of_pop:				ldp	fp, lr, [sp], 16						//deallocate stack memory used by push
						ret											//return control to the calling code


						.global clear								//make the clear label accessible to other compilation units
						.balign 4									//allign the following instructions to make sure that they are divisible by 4

clear:					stp 	fp, lr, [sp, -16]!					//creates a frame record and allocatets memory for our local variables on the stack
						mov	fp, sp									//moves the fp to the current sp location

						adrp	x9, sp_m							//store the address of the global variable sp_m in register x9
						add	x9, x9, :lo12:sp_m						//complete the address location of the x9 register
						str	wzr, [x9]								//store a zero value at the address of x9

end_of_clear:			ldp	fp, lr, [sp], 16						//deallocate stack memory used by push
						ret											//return control to the calling code

						.global getop								//make the getop label accessible to other compilation units
						.balign 4									//allign the following instructions to make sure that they are divisible by 4

getop:					stp	fp, lr, [sp, -16]!						//creates a frame record and allocates memory for our lacal variables on the stack
						mov	fp, sp									//moves the fp to the current sp location

						mov	sptr_r, x0								//assign the passed s* argument into the sptr_r register
						mov	lim_r, w1								//assign the passed lim argument into the lim_r register

																	//while((c = getch()) == ' ' || c == '\t' || c == '\n')
while_getop_1:			bl	getch									//branch and link to the getch function
						mov	c_r, w0									//assign the returned character from the getch function to the c_r register

						cmp	c_r, ' '								//compare c_r value to the space character
						b.eq	while_getop_1						//branch to while_getop_1 if c_r is a space character

						cmp	c_r, '\t'								//compare c_r value to the tab character
						b.eq	while_getop_1						//branch to while_getop_1 if c_r is a tab character

						cmp	c_r, '\n'								//compare c_r value to the new line character
						b.eq	while_getop_1						//branch to while_getop_1 if c_r is a new line character

																	//if (c < '0' || c > '9')
						cmp	c_r, '0'								//compare c_r value to the zero character
						b.lt	if_getop_1							//branch to the if_getop_1 label if c_r is less than zero

						cmp	c_r, '9'								//compare c_r value to the 9 character
						b.gt	if_getop_1							//branch to the if_getop_1 label if c_r is greater than 9

						b	after_if_1								//branch to the after_if_1 label otherwise

if_getop_1:				mov	w0, c_r									//set the returning value of this function to a value at c_r
						b	end_of_getop							//branch to the end_of_getop label and exit in the usual way

after_if_1:				str	c_r, [sptr_r]							//store  the value of c_r into s[0]

																	//for (i = 1; (c = getchar()) >= '0' && c <= '9'; i++)
						mov	i_r, 1									//store value of 1 into the i_r register
						b	test_if_getop_2							//branch to the test_if_getop_2 label

																	//if (i < lim)
if_getop_2:				cmp	i_r, lim_r								//compare values at i_r and lim_r
						b.ge	end_if_getop_2						//branch to end_if_getop_2 if i_r is greater or equal than lim_r
						strb	c_r, [sptr_r, i_r, SXTW]			//store the value of c_r into s[i]

end_if_getop_2:			add	i_r, i_r, 1								//increment the value at i_r by 1

test_if_getop_2:		bl	getchar									//branch and link to the getchar function in the C library
						mov	c_r, w0									//assign the returned character from the getchar function to c_r
						cmp	c_r, '0'								//compare c_r with the zero character
						b.lt	if_getop_3							//branch to the if_getop_3 label if c_r is less than the zero character

						cmp	c_r, '9'								//compare c_r with the 9 character
						b.le	if_getop_2							//branch to the if_getop_2 label if c_r is less than the nine character
									//if (i < lim)
if_getop_3:				cmp	i_r, lim_r								//compare values at i_r and lim_r
						b.ge	else_getop							//branch to the else_getop lavel if i_r is greater or eaqual to lim_r

						mov	w0, c_r									//set the returning value of this function to a value at c_r
						bl	ungetch									//branch and link to the ungetch label

						mov	w11, 0									//store the null character in register w11
						strb	w11, [sptr_r, i_r, SXTW]			//store the null character at s[i]
						mov	w0, NUMBER								//set the returning value of this function to the NUMBER constant
						b	end_of_getop							//branch to the end_of_getop label and exit in the usual way

																	//else
																	//while (c != '\n' && c != EOF)
else_getop:				cmp	c_r, '\n'								//compare c_r value to the new line character
						b.eq	continue_else_getop					//branch to the continue_else_getop label if c_r is equal to the new line character

						cmp	c_r, -1									//compare c_r value to -1
						b.eq	continue_else_getop					//branch to the continue_else_getop label if c_r is equal to -1

						bl	getchar									//branch and link to the getchar function from the standard C library
						mov	c_r, w0									//assign the returned character from the getchar function to c_r
						b	else_getop								//branch to the else_getop label

continue_else_getop:	mov	w11, 0									//store the null character in register w11
						sub	lim_r, lim_r, 1							//decrement the lim_r value by 1
						strb	w11, [sptr_r, lim_r, SXTW]			//store the null character at s[lim-1]
						mov	w0, TOOBIG								//set the returning value of this function to the TOOBIG constant

end_of_getop:			ldp	fp, lr, [sp], 16						//deallocate stack memory used by getop
						ret											//return control to the calling code


						.global getch								//make the getch label accessible to other compilation units
						.balign 4									//allign the following instructions to make sure that they are divisible by 4

getch:					stp	fp, lr, [sp, -16]!						//creates a frame record and allocates memory for our local variables on the stack
						mov	fp, sp									//moves the fp to the current sp location

						adrp	x9, bufp_m							//store the address of the global variable bufp_m in register x9
						add	x9, x9, :lo12:bufp_m					//complete the address location of the x9 register
						ldr	w10, [x9]								//store the content in address reference by x9 in the w10 register

						cmp	w10, 0									//compare w10 value to the zero value
						b.le	else_getch							//branch to the else_getch label if w10 is less or equal to zero

						adrp	x11, buf_m							//store the base address of the global variable buf_m array in register x11
						add	x11, x11, :lo12:buf_m					//complete the address location of the x11 register

						sub	w10, w10, 1								//decrement the bufp_m variable value by 1
						str	w10, [x9]								//store the decremented bufp_m value
						ldr	w0, [x11, w10, SXTW 2]					//set the returning value of this function to buf[--bufp]

						b	end_of_getch							//branch to the end of this getch function and exit in the usual way

else_getch:				bl	getchar									//branch and link to the standard io library getchar function

end_of_getch:			ldp	fp, lr, [sp], 16						//deallocate stack memory used by getch
						ret											//return control to the calling code


						.global ungetch								//meke the ungetch lavel accessible to other copilation units
						.balign 4									//allign the following instructions to make sure they they are divisible by 4

ungetch:				stp	fp, lr, [sp, -16]!						//creates a frame record and allocates memory for our local variables on the stack
						mov	fp, sp									//moves the fp to the current sp location

						adrp	x9, bufp_m							//store the address of the global variable bufp_m in register x9
						add	x9, x9, :lo12:bufp_m					//complete the address location stored in the x9 register
						ldr	w10, [x9]								//store the content in address reference by x9 in the w10 register

						cmp	w10, BUFSIZE							//compare w10 value to BUFSIZE
						b.le	else_ungetch						//branch to the else_ungetch label if w10 is less or equal to BUFSIZE

						adrp	x0, too_many_c_err					//store the address of the too_many_c_err string as the first argument
						add	x0, x0, :lo12:too_many_c_err			//complete the address of the stack_empt_err string
						bl	printf									//branch and link to the printf function

						b	end_of_ungetch							//branch to the end of this ungetch function and exit in the usual way

else_ungetch:			adrp	x11, buf_m							//store the base address of the gloval variable buf_m array in register x11
						add	x11, x11, :lo12:buf_m					//complete the address location of the buf_m variable
						str	w0, [x11, w10, SXTW 2]					//buf[bufp] = c

						add	w10, w10, 1								//increment value of bufp_m by 1
						str	w10, [x9]								//store the incremented bufp_m value in the bufp_m global variable

end_of_ungetch:			ldp	fp, lr, [sp], 16						//deallocate stack memory used by ungetch
						ret											//return control to the calling code
