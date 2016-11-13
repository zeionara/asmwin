.586
.model flat, stdcall

extern MessageBoxA@16:near

includelib D:\Applications\masm32\lib\user32.lib

addEl macro rg, rgl, mas, index
      LOCAL nonparity, lp1, toexit, lp2
    push esi
    push edi
    push rg

    xor esi, esi
    mov edi, index

    rcr edi, 1
    jc nonparity
        clc
        lp1:
            add esi, 5
            dec edi
            cmp edi, 0
        jge lp1

        sub esi, 5
        add esi, 2
        shl rg, 4
        add rgl, byte ptr mas[esi]
        mov byte ptr mas[esi], rgl ;write least 4 bit

        dec esi
        shr rg, 8
        mov byte ptr mas[esi], rgl ;write middle 8 bit

        dec esi
        shr rg, 8
        mov byte ptr mas[esi], rgl ;write greatest 8 bit

        jmp toexit
    nonparity:

        clc
        add esi, 2
        lp2:
            add esi, 5
            dec edi
            cmp edi, 0
        jge lp2

        ;sub esi, 5
        add esi, 2
        mov byte ptr mas[esi], rgl ;write least 8 bit

        dec esi
        shr rg, 8
        mov byte ptr mas[esi], rgl ;write middle 8 bit

        dec esi
        shr rg, 8
        and rgl, 0Fh
        add rgl, byte ptr mas[esi]
        mov byte ptr mas[esi], rgl ;write greatest 4 bit
    toexit:
    pop rg
    pop edi
    pop esi
endm

readEl macro rg, rgl, mas, index
       LOCAL nonparity, lp1, toexit, lp2
    push esi
    push edi

    xor esi,esi
    mov edi, index

    rcr edi, 1
    jc nonparity
        clc
        lp1:
            add esi, 5
            dec edi
            cmp edi, 0
        jge lp1

        sub esi,5
        mov rgl, byte ptr mas[esi] ;read greatest 8 bit
        shl rg, 8

        inc esi
        mov rgl, byte ptr mas[esi] ;read middle 8 bit
        shl rg, 8

        inc esi
        mov rgl, byte ptr mas[esi] ;read least 4 bit
        shr rg, 4

        jmp toexit
    nonparity:
        clc
        add esi, 2
        lp2:
            add esi, 5
            dec edi
            cmp edi, 0
        jge lp2

        ;sub esi,5
        mov rgl, byte ptr mas[esi] ;read greatest 4 bit
        and rgl, 0Fh
        shl rg, 8

        inc esi
        mov rgl, byte ptr mas[esi] ;read middle 8 bit
        shl rg, 8

        inc esi
        mov rgl, byte ptr mas[esi] ;read least 8 bit

    toexit:
    pop edi
    pop esi
endm

mulEls macro rgs, rgd
    push esi
    push edi
    push bp
    mov bp, sp

    ; check sign of rgs
    shl rgs, 12
    rcl rgs, 1
    jnc $+02Fh
        rcr rgs, 1
        shr rgs, 12

        not rgs
        inc rgs

        shl rgd, 12
        rcl rgd, 1
        jnc $+010h
            rcr rgd, 1
            shr rgd, 12

            not rgd
            inc rgd
            jmp $+032h

            rcr rgd, 1
            shr rgd, 12
            inc bp
        jmp $+028h

        rcr rgs, 1
        shr rgs, 12

        shl rgd, 12
        rcl rgd, 1
        jnc $+011h
            rcr rgd, 1
            shr rgd, 12

            not rgd
            inc rgd
            inc bp
            jmp $+09h

            rcr rgd, 1
            shr rgd, 12
    ;cont:

    mov edi, 20
    shl rgs, 12
    ;lp1:
        dec di
        cmp di, 0
        jl $+016h

        rcl rgs, 1
        jnc $-09h
            push cx
            mov cx, di
            shl rgd, cl
            add esi, rgd
            shr rgd, cl
            pop cx
            jmp $-018h

    ;toexit:
    mov rgd, esi
    cmp bp, sp
    je $+09h
        not rgd
        inc rgd

    ;finish:
    pop bp
    pop edi
    pop esi
endm

data segment
  del db 0FFh
  mas db 200h DUP (0)
  num dw 16

  ;outputting
  rezultheader db "Rezult",0
  rezulthello db "Here is rezult array after multiplying:",0
  sourceheader db "Source",0
  sourcehello db "Here is source array before multiplying:",13
  binrep db 220 DUP (0),0
  newline db 13,0
data ends

text segment
start:
  ;filling source array
  mov eax, 1
  addEl eax, al, mas, 0

  mov eax, 2
  addEl eax, al, mas, 1

  mov eax, 3
  addEl eax, al, mas, 2

  mov eax, 4
  addEl eax, al, mas, 3

  mov eax, 5
  addEl eax, al, mas, 4

  mov eax, 6
  addEl eax, al, mas, 5

  mov eax, 7
  addEl eax, al, mas, 6

  mov eax, -4
  addEl eax, al, mas, 7

  mov eax, -3
  addEl eax, al, mas, 8

  mov eax, -2
  addEl eax, al, mas, 9

  mov eax, 105
  addEl eax, al, mas, 10

  mov eax, 2
  addEl eax, al, mas, 11

  mov eax, -12
  addEl eax, al, mas, 12

  mov eax, 13
  addEl eax, al, mas, 13

  mov eax, 66h
  addEl eax, al, mas, 14

  mov eax, 6
  addEl eax, al, mas, 15

  ;showing rezult
  xor ecx,ecx
  xor eax,eax

  xor edx, edx
  xor ecx, ecx
  push edi
  xor edi,edi
  push eax
  xor eax,eax
  push esi
  xor esi,esi
  lp1:
    xor edx, edx
    readEl edx, dl, mas, ecx
    mov eax,edx
    shl eax, 12

    mov binrep[edi],13
    inc edi
    mov esi,edi
    push edi
    lpin3:
      pop edi
      rcl eax, 1
      jnc contin31
        mov binrep[edi],31h
        inc edi
        jmp contin32
      contin31:
        mov binrep[edi],30h
        inc edi
    contin32:
      push edi
      sub edi,esi
      cmp edi,20
      jl lpin3
    pop edi
    inc cx
    cmp cx,15
    jle lp1

  pop esi
  pop eax
  pop edi
  pop edx

  push 0
  push offset sourceheader
  push offset sourcehello
  push 0
  call MessageBoxA@16

  ;end
  ret





text ends
end start
