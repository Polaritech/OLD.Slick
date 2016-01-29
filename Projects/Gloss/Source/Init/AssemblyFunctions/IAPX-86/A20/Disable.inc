;=============================================================================;
; GLOSS - Generic Loader for Operating SystemS                                ;
; An extensible and configurable bootloader.                                  ;
;-----------------------------------------------------------------------------;
; Copyright (C) 2013-2016 ~ Adrian J. Collado       [acollado@polaritech.com] ;
; Copyright (C) 2015-2016 ~ Polaritech, Inc.         [https://polaritech.com] ;
; All Rights Reserved                                                         ;
;=============================================================================;

; This code is assembled to be run in 16-Bit mode on any CPU that is an 8086 or
; newer. This basically means that any CPU that can run x86 code can run the
; following code.
[BITS 16]
[CPU 8086]

; The following function is located in the .TEXT section of the executable.
[SECTION .TEXT]

; This file requires several other assembly files. However, as they are all
; assembled seperately, the functions necessary will be included using the
; EXTERN directive.
[EXTERN IAPX86.A20.Check.Wrap]
[EXTERN IAPX86.A20.Toggle.Fast]
[EXTERN IAPX86.A20.Toggle.BIOS]
[EXTERN IAPX86.A20.Toggle.PS2]

; Enables the A20 Line using several functions.
[GLOBAL IAPX86.A20.Enable]
IAPX86.A20.Enable:
	; Our A20 Line enabling function uses each of our different toggling
	; functions in conjunction with the check function to enable the A20 Line
	; for us. The first thing we do, however, is store some state.
	push ax

	; Next, we check the current A20 Line value. We also set the A20 Line
	; status flag in our flags variable to enabled (we will reset it later on 
	; the off-chance we can't enable the A20 Line).
	mov ax, [Data.Flags]
	or ax, 0x04
	mov [Data.Flags], ax
	call IAPX86.A20.Check.Wrap
	jnc IAPX86.A20.Enable.Exit

	; Now we attempt to enable the A20 Line using the BIOS. After trying this
	; method, we check if the A20 Line is enabled using our check function.
	call IAPX86.A20.Toggle.BIOS
	call IAPX86.A20.Check.Wrap
	jnc IAPX86.A20.Enable.Exit

	; If the BIOS function didn't work, we attempt to enable the A20 Line using
	; the PS/2 Controller. It is reasonable to assume that if the BIOS function
	; failed, then the PS/2 function will succeed. We then check the A20 Line
	; status again.
	call IAPX86.A20.Toggle.PS2
	call IAPX86.A20.Check.Wrap
	jnc IAPX86.A20.Enable.Exit

	; Our last and final hope is to try the Fast A20 method. On some systems
	; attempting this method can be extremely bad, but if we reach this point
	; then we have nothing to lose. After calling the Fast A20 method, we once
	; again check the A20 Line status.
	call IAPX86.A20.Toggle.Fast
	call IAPX86.A20.Check.Wrap
	jnc IAPX86.A20.Enable.Exit

	; If we reach this point, we cannot use any odd MiBs, as the A20 Line is
	; disabled. We thus set the A20 Line status flag in our flags variable to
	; disabled. It is possible for the bootloader to continue, however, as it
	; will only use the even MiBs of memory.
	mov ax, [Data.Flags]
	and ax, 0xfffffffb
	mov [Data.Flags], ax

	IAPX86.EnableA20.Exit:
		; The final thing we do is restore state and return to the calling
		; function.
		pop ax
		ret