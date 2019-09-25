;++
;
; Copyright (c) Microsoft Corporation
;
; Module Name:
;
;     blidt.asm
;
; Abstract:
;
;     This module implements IDT functions for the boot loader.
;
; Environment:
;
;     Boot loader.
;
;--

include bl.inc

.code

extrn ?BlTrapFatal@@YAX_KPEAU_BL_TRAP_CONTEXT@@@Z:near
        
;++
;
; VOID
; BlTrapEnter(
;     VOID
;     )
;
; Routine Description:
;
;   Entry point for incoming exceptions.
;
;--

        align 16
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; The IDT_ENTER building macros insure that each IDT target has
;;; an offset of form BlTrapEnter + 0x10 * interrupt_number.
;;;

IDT_ENTER_NOERR MACRO num:req
        push    77h ; No error
        call    @f
        align   8
ENDM

IDT_ENTER_ERR   MACRO num:req
        call    @f
        align   8
ENDM

        align 16
?BlTrapEnter@@YAXXZ proc
        IDT_ENTER_NOERR       000h                      ; #DE Divide-by-Zero
        IDT_ENTER_NOERR       001h                      ; #DB Debug Exception
        IDT_ENTER_NOERR       002h                      ; NMI Non-Maskable-Interrupt
        IDT_ENTER_NOERR       003h                      ; #BP Breakpoint
        IDT_ENTER_NOERR       004h                      ; #OF OVerflow
        IDT_ENTER_NOERR       005h                      ; #BR Bound-Range
        IDT_ENTER_NOERR       006h                      ; #UD Invalid Opcode
        IDT_ENTER_NOERR       007h                      ; #NM Device Not Available
        IDT_ENTER_ERR         008h                      ; #DF Double Fault
        IDT_ENTER_NOERR       009h                      ; Unused (was x87 segment except)
        IDT_ENTER_ERR         00ah                      ; #TS Invalid TSS
        IDT_ENTER_ERR         00bh                      ; #NP Sgement Not Present
        IDT_ENTER_ERR         00ch                      ; #SS Stack Exception
        IDT_ENTER_ERR         00dh                      ; #GP General Protection
        IDT_ENTER_ERR         00eh                      ; #PF Page Fault
        IDT_ENTER_NOERR       00fh                      ; Reserved
        IDT_ENTER_NOERR       010h                      ; #MF x87 Math Error
        IDT_ENTER_ERR         011h                      ; #AC Alignment Check
        IDT_ENTER_NOERR       012h                      ; #MC Machine Check
        IDT_ENTER_NOERR       013h                      ; #XF SIMD Exception

        inum = 014h                                     ; 014h to 020h
        WHILE inum LE 020h
                IDT_ENTER_NOERR       inum
                inum = inum + 1
        ENDM
@@:
        push    rax
        push    rbx
        push    rcx
        push    rdx
        push    rsi
        push    rdi
        push    rbp
        push    r8
        push    r9
        push    r10
        push    r11
        push    r12
        push    r13
        push    r14
        push    r15
        mov     rax, rsp
        add     rax, 88
        push    rax
        mov     rax, cr2
        push    rax

        mov     rdx, rsp
        mov     rcx, [rdx].BL_TRAP_CONTEXT.TrapNum
        mov     rax, ?BlTrapEnter@@YAXXZ
        sub     rcx, rax
        shr     rcx, 3
        mov     [rdx].BL_TRAP_CONTEXT.TrapNum, rcx
        push    rdx
        push    rcx
        call    ?BlTrapFatal@@YAX_KPEAU_BL_TRAP_CONTEXT@@@Z
@@:
        jmp @b

?BlTrapEnter@@YAXXZ endp
        
;++
;
; VOID
; BlTrapSetIdtr(
;     PIDTR Idtr
;     )
;
; Routine Description:
;
;   This function sets the IDTR register.
;
; Arguments:
;
;   Idtr        - Supplies the data to write to the IDTR register.
;
;--

?BlTrapSetIdtr@@YAXPEAU_IDTR@@@Z proc

        lidt    fword ptr [rcx]
        ret

?BlTrapSetIdtr@@YAXPEAU_IDTR@@@Z endp
        
end
