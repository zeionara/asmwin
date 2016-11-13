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
       LOCAL source_positive, source_negative_and_destination_positive, to_multiplying, source_positive_and_destination_positive, lp_multiplying, to_end_of_multiplying, finish
    push esi
    xor esi,esi
    push edi
    push ebp
    mov ebp, esp

    ; check sign of rgs
    shl rgs, 12
    rcl rgs, 1
    jnc source_positive ;if sign = 0
        ;source negative
        rcr rgs, 1
        shr rgs, 12

        not rgs
        inc rgs

        shl rgd, 12
        rcl rgd, 1
        jnc source_negative_and_destination_positive
            ;source_negative_and_destination_negative
            rcr rgd, 1
            shr rgd, 12

            not rgd
            inc rgd
            ;result is positive
            jmp to_multiplying
            source_negative_and_destination_positive:; and source negative
              rcr rgd, 1
              shr rgd, 12
              inc ebp
              ;rezult is negative
              jmp to_multiplying
    source_positive:
        rcr rgs, 1
        shr rgs, 12

        shl rgd, 12
        rcl rgd, 1
        jnc source_positive_and_destination_positive
            ;source_positive_and_destination_negative
            rcr rgd, 1
            shr rgd, 12

            not rgd
            inc rgd
            inc ebp
            ;rezult is negative
            jmp to_multiplying
        source_positive_and_destination_positive:
            rcr rgd, 1
            shr rgd, 12
            ;rezult is positive
    to_multiplying:



      mov edi, 20
      shl rgs, 12
      lp_multiplying:
        dec edi
        cmp edi, 0
        jl to_end_of_multiplying
        ;next step of multiplying
        rcl rgs, 1
        jnc lp_multiplying ;we have to don't shift destination
            push ecx
            mov ecx, edi
            shl rgd, cl ;we have to shift destination
            add esi, rgd  ;and we have to accumulate rezult too
            shr rgd, cl
            pop ecx
            jmp lp_multiplying
    to_end_of_multiplying:
    mov rgd, esi ;in destination - accumulated multiply
    cmp ebp, esp ;if equals - rezult is positive
    je finish
        ;else we need to change sign
        not rgd
        inc rgd
    finish:
    pop ebp
    pop edi
    pop esi
endm



data segment
  del db 0FFh
  mas db 200h DUP (0)
  num dw 16

  ;outputting
  rezultheader db "Rezult",0
  rezulthello db "Here is rezult array after multiplying:",13
  binreprez db 420 DUP (0),0
  newline1 db 13,0

  sourceheader db "Source",0
  sourcehello db "Here is source array before multiplying:",13
  binrep db 320 DUP (0),0
  newline2 db 13,0
data ends

text segment
start:
  ;filling source array
  CALL fillsource

  ;showing source
  CALL showsource

  ;showing rezult
  CALL showrezult

;showRezult

  ;end
  ret


fillsource proc
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

  ret
fillsource endp

showsource proc

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

push 0
push offset sourceheader
push offset sourcehello
push 0
call MessageBoxA@16

ret
showsource endp

showrezult proc

xor ecx, ecx
push edi
xor edi,edi
push eax
xor eax,eax
push esi
xor esi,esi
lp2:
  xor edx, edx
  readEl edx, dl, mas, ecx
  mov eax,edx

  inc ecx
  cmp ecx,15
  jg exitlp2

  xor edx, edx
  readEl edx, dl, mas, ecx

  mulEls edx,eax

  shl eax, 12

  mov binreprez[edi],13
  inc edi
  mov esi,edi
  push edi
  lpin3:
    pop edi
    rcl eax, 1
    jnc contin31
      mov binreprez[edi],31h
      inc edi
      jmp contin32
    contin31:
      mov binreprez[edi],30h
      inc edi
  contin32:
    push edi
    sub edi,esi
    cmp edi,20
    jl lpin3
  pop edi

  jmp lp2
  exitlp2:

;;;;;;;;;;;;;;;;;;;;

xor edx, edx
xor ecx, ecx
readEl edx, dl, mas, ecx

mulEls edx,eax

shl eax, 12

mov binreprez[edi],13
inc edi
mov esi,edi
push edi
lpin31:
  pop edi
  rcl eax, 1
  jnc contin311
    mov binreprez[edi],31h
    inc edi
    jmp contin321
  contin311:
    mov binreprez[edi],30h
    inc edi
contin321:
  push edi
  sub edi,esi
  cmp edi,20
  jl lpin31
pop edi

;;;;;;;;;;;;;;;;;;;;

pop esi
pop eax
pop edi

push 0
push offset rezultheader
push offset rezulthello
push 0
call MessageBoxA@16

ret
showrezult endp




text ends
end start
