global bezierFun

section	.text

bezierFun:
	push rbp
	mov rbp, rsp
	
	mov QWORD [rbp - 16], rdi  ;pX
	mov QWORD [rbp - 24], rsi  ;pY
	mov QWORD [rbp - 32], rdx  ;pixels
	mov DWORD [rbp - 40], ecx  ;imageWidth
	
	pxor xmm0, xmm0    ;xmmo = 0
	movss DWORD [rbp - 4], xmm0  ;t
	movss DWORD [rbp - 8], xmm0  ;(1 - t)
	
	mov eax, 1
	cvtsi2ss xmm5, eax ;xmm5 = 1
	cvtsi2ss xmm6, eax
	
	mov eax, 2000
	cvtsi2ss xmm7, eax
	divss xmm6, xmm7   ;xmm6 = increment
	
.loop:
    ucomiss xmm5, DWORD [rbp - 4]
    jb .end
    
    pxor xmm0, xmm0
    movss xmm1, DWORD [rbp - 4]   ;xmm1 = t
    movss xmm2, xmm5
    subss xmm2, xmm1    ;xmm2 = (1 - t)
    movss DWORD [rbp - 8], xmm2   ;odłożenie (1 - t) na stosie
    movss xmm3, xmm0  ;xakt = 0
    movss xmm4, xmm0  ;yakt = 0
    
    ;0)
    ;-----------------------------------------------------
    
    mulss xmm2, xmm2    ;(1 - t) ^ 2
    mulss xmm2, xmm2    ;(1 - t) ^ 4
    
    mov rax, QWORD [rbp - 16]
    mov ebx, DWORD [rax]
    cvtsi2ss xmm7, ebx  ;xmm7 = (float) pX[0]
    mulss xmm7, xmm2    ;xmm7 = pX[0] * (1 - t) ^ 4
    movss xmm3, xmm7    ;xakt = pX[0] * (1 - t) ^ 4
    
    mov rax, QWORD [rbp - 24]
    mov ebx, DWORD [rax]
    cvtsi2ss xmm7, ebx  ;xmm7 = (float) pY[0]
    mulss xmm7, xmm2
    movss xmm4, xmm7    ;yakt = pY[0] * (1 - t) ^ 4
    
    ;1)
    ;-----------------------------------------------------
    
    movss xmm2, DWORD [rbp - 8]
    mulss xmm2, DWORD [rbp - 8]    ;(1 - t) ^ 2
    mulss xmm2, DWORD [rbp - 8]    ;(1 - t) ^ 3
    mov eax, 4
    cvtsi2ss xmm7, eax
    mulss xmm7, xmm2
    mulss xmm7, xmm1    ;xmm7 = 4 * (1 - t)^3 * t
    
    mov rax, QWORD [rbp - 16]
    add rax, 4
    mov ebx, DWORD [rax]  ;ebx = pX[1]
    cvtsi2ss xmm8, ebx
    mulss xmm8, xmm7    ;xmm8 = pX[1] * 4 * (1 - t)^3 * t
    addss xmm3, xmm8    ;xakt += xmm8
    
    mov rax, QWORD [rbp - 24]
    add rax, 4
    mov ebx, DWORD [rax]  ;ebx = pY[1]
    cvtsi2ss xmm8, ebx
    mulss xmm8, xmm7    ;xmm8 = pY[1] * 4 * (1 - t)^3 * t
    addss xmm4, xmm8    ;yakt += xmm8
    
    ;2)
    ;-----------------------------------------------------
    
    movss xmm2, [rbp - 8]
    mulss xmm2, xmm2    ;(1 - t)^2
    mulss xmm1, xmm1    ;t^2
    mov eax, 6
    cvtsi2ss xmm7, eax
    mulss xmm7, xmm1
    mulss xmm7, xmm2    ;xmm7 = 6 * (1 - t)^2 * t^2
    
    mov rax, QWORD [rbp - 16]
    add rax, 8
    mov ebx, DWORD [rax]  ;ebx = pX[2]
    cvtsi2ss xmm8, ebx
    mulss xmm8, xmm7    ;xmm8 = pX[2] * 6 * (1 - t)^2 * t^2
    addss xmm3, xmm8    ;xakt += xmm8
    
    mov rax, QWORD [rbp - 24]
    add rax, 8
    mov ebx, DWORD [rax]  ;ebx = pY[2]
    cvtsi2ss xmm8, ebx
    mulss xmm8, xmm7    ;xmm8 = pY[2] * 6 * (1 - t)^2 * t^2
    addss xmm4, xmm8    ;yakt += xmm8
    
    ;3)
    ;-----------------------------------------------------
    
    movss xmm2, DWORD [rbp - 8]   ;(1 - t)
    movss xmm1, DWORD [rbp - 4]
    mulss xmm1, DWORD [rbp - 4]
    mulss xmm1, DWORD [rbp - 4]   ;t^3
    mov eax, 4
    cvtsi2ss xmm7, eax
    mulss xmm7, xmm1
    mulss xmm7, xmm2    ;xmm7 = 4 * (1 - t) * t^3
    
    mov rax, QWORD [rbp - 16]
    add rax, 12
    mov ebx, DWORD [rax]  ;ebx = pX[3]
    cvtsi2ss xmm8, ebx
    mulss xmm8, xmm7    ;xmm8 = pX[3] * 4 * (1 - t) * t^3
    addss xmm3, xmm8    ;xakt += xmm8
    
    mov rax, QWORD [rbp - 24]
    add rax, 12
    mov ebx, DWORD [rax]  ;ebx = pY[3]
    cvtsi2ss xmm8, ebx
    mulss xmm8, xmm7    ;xmm8 = pY[3] * 4 * (1 - t) * t^3
    addss xmm4, xmm8    ;xakt += xmm8
    
    ;4)
    ;-----------------------------------------------------
    
    movss xmm1, DWORD [rbp - 4]
    mulss xmm1, xmm1    ;t^2
    mulss xmm1, xmm1    ;t^4
    
    mov rax, QWORD [rbp - 16]
    add rax, 16
    mov ebx, DWORD [rax]  ;ebx = pX[4]
    cvtsi2ss xmm8, ebx
    mulss xmm8, xmm1    ;xmm8 = pX[4] * t^4
    addss xmm3, xmm8    ;xakt += xmm8
    
    mov rax, QWORD [rbp - 24]
    add rax, 16
    mov ebx, DWORD [rax]  ;ebx = pY[4]
    cvtsi2ss xmm8, ebx
    mulss xmm8, xmm1    ;xmm8 = pY[4] * t^4
    addss xmm4, xmm8    ;xakt += xmm8
    
.draw:
    cvtss2si ebx, xmm3  ;konwersja xakt do int i wrzucenie do ebx
    cvtss2si eax, xmm4  ;konwersja yakt do int i wrzucenie do eax
    mov ecx, DWORD [rbp - 40] ;imageWidth do ecx
    
    mul ecx
    add eax, ebx    ;eax = y * imageWidth + x
    
    cdqe
    lea rbx, [0 + rax * 4]
    mov rax, QWORD [rbp - 32]
    add rax, rbx
    mov DWORD [rax], 0
    
.increment:
    movss xmm1, DWORD [rbp - 4]
    addss xmm1, xmm6    ;t += increment
    movss DWORD [rbp - 4], xmm1   ;odłóż nowe t na stos
    jmp .loop
    
.end:
    pop rbp
    ret
    
    
