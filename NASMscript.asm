default rel
global _main
extern _exit
extern _puts        ; C function to print a string
extern _printf

section .data
    msg db "hello", 0
    fmt db "%d", 0    ; "%d\n"
    fmt_char db "%c", 0

    PLACEHOLDER
    ;rogram: dd 1,3,3,-1

    length equ ($ - program) / 4

    programBase dq 0    ; 8 bytes, initialized to 0
    stackBase   dq 0
    varsBase    dq 0
    loopBase    dq 0

endCode equ 0 
pushCode equ 1 ;(num to store)Pushes number to STACK
popCode equ 2  ;gets rid of top number in STACK
printCode equ 3  ;(var/-1 for stack top)
printStrCode equ 4

inputCode equ 5
storeCode equ 6 ;(name,num to store)
loadCode equ 7  ;(var) loads to STACK
popToVarCode equ 8 ;(var)pops top STACK value into specified var

loopCode equ 9 ;(var to check, value to be equal) if equal break loop
endLoopCode equ 10
ifCode equ 11

addCode equ 13   ;add top 2 numbers in STACK
multCode equ 14
subtractCode equ 15
divideCode equ 16
modCode equ 17

greaterThenCode equ 19 ;takes top to STACK values, returns 1 if bottom is greater
notEqualCode equ 21



section .bss
    stack resd 256
    vars resd 256
    loopStack resd 256
    buf resb 64        ; buffer to store input

section .text

str_to_int:
    xor rax, rax
    xor rcx, rcx

.loop:
    movzx rcx, byte [rsi]
    cmp rcx, 10         ; newline
    je .done
    cmp rcx, 0          ; null terminator
    je .done
    sub rcx, 48         ; convert ASCII to digit
    imul rax, 10
    add rax, rcx
    inc rsi
    jmp .loop

.done:
    ret


_main:
    ;push rbp            ; \  stack alignment —
    ;mov  rbp, rsp       ; /  macOS requires this at start of every function

    lea rax, [rel loopStack]
    mov [rel loopBase], rax
    mov r14,0 ;loop stack tracker

    lea rax, [rel vars]
    mov [rel varsBase], rax

    lea rax, [rel stack];stack address
    mov [rel stackBase],rax
    mov r13, 0;how far into stack we at

    lea rax, [rel program];program address
    mov [rel programBase], rax
    mov r12, 0;how far into program we are

    .programLoop:
        mov rax, [rel programBase]
        mov eax, [rax+r12*4]
        inc r12

        cmp eax, printCode
        je .print
        cmp eax, printStrCode
        je .printStr
        cmp eax, pushCode
        je .push    
        cmp eax, popCode
        je .pop 
        cmp eax, addCode
        je .add
        cmp eax, subtractCode
        je .subtract
        cmp eax, multCode
        je .multiply
        cmp eax, divideCode
        je .divide
        cmp eax, modCode
        je .mod
        cmp eax,inputCode
        je .input
        cmp eax,storeCode
        je .storeVar
        cmp eax,loadCode
        je .loadVar
        cmp eax,popToVarCode
        je .popToVar
        cmp eax,loopCode
        je .loop
        cmp eax,endLoopCode
        je .endLoop
        cmp eax,ifCode
        je .if
        cmp eax,greaterThenCode
        je .greaterThen
        cmp eax,notEqualCode
        je .notEqualTo
        cmp eax, endCode
        je .end

    .push:
        mov rbx, [rel programBase]
        mov eax,[rbx+r12*4] ;check what arguement is(next number in program list)
        mov rbx, [rel stackBase]
        mov [rbx+r13*4],eax ;copy down the argument into the stack
        inc r13 ;update stack length

        inc r12 ;update current input looked at because argument was used
        jmp .programLoop

    .pop:
        dec r13
        jmp .programLoop

    .print:
        mov rbx, [rel programBase]
        mov eax, [rbx+r12*4]
        inc r12

        cmp eax,0
        jge .printVar
        mov rbx, [rel stackBase]
        mov eax, [rbx+r13*4-4]
        jmp .printToTerminal

        .printVar:
        mov rbx, [rel varsBase]
        mov eax, [rbx+rax*4]
        
        .printToTerminal:
        lea rdi,[rel fmt]     
        mov rsi, rax 
        xor eax, eax    
        call _printf

        jmp .programLoop

    .printStr:
        mov rbx, [rel programBase]
        mov eax, [rbx+r12*4]
        inc r12

        cmp eax, 0
        je .programLoop

        lea rdi,[rel fmt_char]     
        mov rsi, rax
        xor eax, eax         
        call _printf

        jmp .printStr

    .add:
        mov rbx, [rel stackBase]
        mov eax, [rbx+r13*4-4]     ;move top of stack into eax
        dec r13
        add eax,[rbx+r13*4-4]    ;add next top to eax
        mov [rbx+r13*4-4],eax

        jmp .programLoop

    .subtract:
        mov rbx, [rel stackBase]
        mov eax, [rbx+r13*4-8]     ;move top of stack into eax
        dec r13
        sub eax,[rbx+r13*4]    ;add next top to eax
        mov [rbx+r13*4-4],eax
        

        jmp .programLoop
        
    .multiply:
        mov rbx, [rel stackBase]
        mov eax, [rbx+r13*4-4]     ;move top of stack into eax
        dec r13
        imul eax,[rbx+r13*4-4]    ;add next top to eax
        mov [rbx+r13*4-4],eax

        jmp .programLoop

    .divide:
        mov rbx, [rel stackBase]
        mov ecx, [rbx+r13*4-4]     ;move top of stack into eax
        dec r13
        mov eax, [rbx+r13*4-4]
        cdq
        idiv ecx   ;divide first by second
        mov [rbx+r13*4-4],eax

        jmp .programLoop

    .mod:
        mov rbx, [rel stackBase]
        mov ecx, [rbx+r13*4-4]     ;move top of stack into eax
        dec r13
        mov eax, [rbx+r13*4-4]
        cdq
        idiv ecx   ;divide first by second
        mov [rbx+r13*4-4],edx

        jmp .programLoop

    .input:
        mov rbx, [rel stackBase]

        mov rax, 0x2000003  ; syscall: read
        mov rdi, 0          ; fd: stdin
        lea rsi, [rel buf]  ; buffer address
        mov rdx, 64         ; max bytes to read
        syscall

        lea rsi, [rel buf]
        call str_to_int

        mov rcx, [rel stackBase]
        mov [rcx+r13*4],rax

        inc r13 ;update stack length

        jmp .programLoop

    .storeVar:
        mov rbx, [rel programBase]
        mov eax, [rbx+r12*4]
        inc r12
        mov rbx, [rel programBase]
        mov ebx, [rbx+r12*4]
        inc r12
        mov rcx, [rel varsBase]
        mov [rcx+rax*4], ebx
        jmp .programLoop

    .loadVar:
        mov rbx, [rel programBase]
        mov eax, [rbx+r12*4] ;check what arguement is(next number in program list)
        inc r12 ;update current input looked at because argument was used
        mov rbx, [rel varsBase]
        mov eax,[rbx+rax*4]
        mov rbx, [rel stackBase]
        mov [rbx+r13*4],eax ;copy down the argument into the stack

        inc r13 ;update stack length
       
        jmp .programLoop

    .popToVar:
        mov rbx, [rel programBase]
        mov eax, [rbx+r12*4] ;var to give to
        mov rbx, [rel stackBase]
        mov ecx, [rbx+r13*4-4]  ;number being given
        mov rbx, [rel varsBase]

        mov [rbx+rax*4], ecx
        inc r12
        dec r13

        jmp .programLoop

    .loop:
        mov rcx, [rel programBase]  
        mov eax, [rcx+r12*4]    ;number at programs next position(var)
        mov ebx, [rcx+r12*4+4]  ;type of value being compared
        mov edx, [rcx+r12*4+8]  ;number/var being compared

        add r12,3  ;move program counter up

        mov rcx, [rel loopBase]
        mov [rcx+r14*4],eax
        inc r14
        mov [rcx+r14*4],ebx
        inc r14
        mov [rcx+r14*4],edx
        inc r14
        mov [rcx+r14*4],r12d
        inc r14
                
        jmp .programLoop

    .endLoop:
        mov rcx, [rel loopBase] 
        mov eax, [rcx+r14*4-16]  ;var address 
        mov rcx, [rel varsBase]
        mov eax, [rcx+rax*4]    ;var value

        mov rcx, [rel loopBase]
        mov ebx, [rcx+r14*4-12] ;get compare type
        cmp ebx, 1
        je .loopCompareTypeIsNum

            mov ebx, [rcx+r14*4-8]    ;get compare value
            mov rcx, [rel varsBase]
            mov ebx, [rcx+rbx*4]    ;get compare value
        jmp .figuredOutLoopCompareType

        .loopCompareTypeIsNum:
            mov ebx, [rcx+r14*4-8]    ;get compare value
        .figuredOutLoopCompareType:

        cmp eax, ebx
        je .exitLoop
        mov rcx, [rel loopBase]
        mov r12d, [rcx+r14*4-4]     ;program counter to where loop starts

        jmp .programLoop

        .exitLoop:

        sub r14, 4

        jmp .programLoop

    .if:
        mov rcx, [rel programBase]
        mov eax, [rcx+r12*4]

        mov ebx, [rcx+r12*4+4]
        add r12, 2

        mov rcx, [rel varsBase]
        mov eax, [rcx+rax*4]

        cmp eax, ebx

        je .ifIsTrue

    ;find next end inside same scope
        mov edx, 0      ;counter for nested if statments
        mov rcx, [rel programBase]
        .checkIfNextIsEnd:
        mov eax, [rcx+r12*4]
        inc r12
        mov ebx, [rcx+r12*4]

        cmp eax, 11 ;check if another if is inside
        jne .noIfStatment
            add edx,2

        .noIfStatment:
        cmp eax, 12
        jne .checkIfNextIsEnd
        cmp ebx, 12
        jne .checkIfNextIsEnd

        cmp edx,0   ;if no nest if statments exit we good
        je .noNestedIfStatments
        dec edx
        jmp .checkIfNextIsEnd

        .noNestedIfStatments:

        inc r12

        jmp .programLoop

        .ifIsTrue:

        jmp .programLoop

    .greaterThen:
        mov rbx,[rel stackBase]
        mov eax,[rbx+r13*4-4]
        mov ecx,[rbx+r13*4-8]

        dec r13
        cmp ecx,eax
        jg .ISgreater
        .isNOTgreater:
            mov dword [rbx+r13*4-4],0
            jmp .programLoop
        .ISgreater:
            mov dword [rbx+r13*4-4],1
            jmp .programLoop

    .notEqualTo:
        mov rbx,[rel stackBase]
        mov eax,[rbx+r13*4-4]
        mov ecx,[rbx+r13*4-8]

        dec r13
        cmp ecx,eax
        jne .isNOTequal
        .ISequal:
            mov dword [rbx+r13*4-4],0
            jmp .programLoop
        .isNOTequal:
            mov dword [rbx+r13*4-4],1
            jmp .programLoop
        
    .comment:
        mov rbx, [rel programBase]
        mov eax, [rbx+r12*4]
        inc r12
        cmp eax, 5
        jne .comment
        jmp .programLoop

    .end:
    xor rdi,rdi
    call _exit

    

;nasm -f macho64 hello.asm -o hello.o
;clang -arch x86_64 -o hello hello.o
