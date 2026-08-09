%include "../include/io.mac"

; declare your structs here

; structura date
struc date
    .day: resb 1
    .month: resb 1
    .year: resw 1
endstruc

; structura event
struc event ; are 31 + 1 + 1 + 1 + 2 = 36 bytes
    .name: resb 31
    .valid: resb 1
    .date: istruc date
        at date.day, resb 1 ; 0 bytes => date.data se afla la 31 + 1 = 32
        at date.month, resb 1 ; 1 byte => date.month se afla la 31 + 1 + 1 = 33
        at date.year, resw 1 ; 2 bytes => date.year se afla la 31 + 1 + 2 = 34
    iend
endstruc

section .data

section .text
    global check_events
    extern printf

check_events:
    ;; DO NOT MODIFY
    enter 0,0
    pusha

    mov ebx, [ebp + 8]      ; vectorul de evenimente
    mov ecx, [ebp + 12]     ; numarul total de evenimente
    ;; DO NOT MODIFY

    ;; Your code starts here
    mov edx, 0 ; edx primeste 0, in acest registru vom parcurge element cu
               ; element vectorul de evenimente
start_loop:
    cmp edx, ecx
    jge end_loop ; daca edx are o valoarea mai mare sau egala decat ecx
                 ; (care tine numarul de elemente al vectorului de evenimente) se iese din for

    movzx eax, word [ebx + event.date + date.year] ; ii atribuim lui eax anul evenimentului
    cmp eax, 1990
    jl false ; daca anul este mai mic decat 1990, evenimentul nu are cum sa existe => valid = 0

    cmp eax, 2030
    jg false ; daca anul este mai mare decat 2030, evenimentul nu are cum sa existe => valid = 0

    movzx eax, byte [ebx + event.date + date.month] ; ii atribuim lui eax luna evenimentului
    cmp eax, 1
    jl false ; daca luna este mai mica de 1, evenimentul nu are cum sa existe => valid = 0

    cmp eax, 12
    jg false ; daca luna este mai mare de 12, evenimentul nu are cum sa existe => valid = 0

    movzx eax, byte [ebx + event.date + date.day] ; ii atribuim lui eax ziua evenimentului
    cmp eax, 1
    jl false ; daca ziua este mai mica de 1, evenimentul nu are cum sa existe => valid = 0

    movzx eax, byte [ebx + event.date + date.month] ; ii atribuim lui eax luna evenimentului
    test eax, 1 ; verificam daca numarul este impar cu ajutorul instructiunii test
    jne luni_impare ; in caz afirmativ, trecem pe cazul lunilor impare
    je luni_pare ; in caz contrar, trecem pe cazul lunilor pare

luni_impare:
    cmp eax, 7 ; se intra in verificare_31 pentru lunile mai mici sau egale cu 7
               ; si in verificare_30 pentru luna a 9-a si a 11-a
    jle verificare_31
    jg verificare_30

luni_pare:
    cmp eax, 2 ; creem un caz special pentru luna a 2-a, intrucat este singura
               ; de 28 de zile
    je verificare_februarie

    cmp eax, 6 ; se intra in verificare_30 pentru lunile mai mici sau egale cu 6
               ; si in verificare_31 pentru luna a 8-a, a 10-a si a 12-a
    jle verificare_30
    jg verificare_31

verificare_30:
    movzx eax, byte [ebx + event.date + date.day] ; ii atribuim lui eax ziua evenimentului
    cmp eax, 30 ; daca se respecta conditia ca ultima zi a lunii sa fie 30,
                ; trecem la urmatorul eveniment prin intermediul continue_loop
    jle continue_loop
    jg false ; in caz contrar, evenimentul nu are cum sa existe => valid = 0

verificare_31:
    movzx eax, byte [ebx + event.date + date.day] ; ii atribuim lui eax ziua evenimentului
    cmp eax, 31 ; daca se respecta conditia ca ultima zi a lunii sa fie 31,
                ; trecem la urmatorul eveniment prin intermediul continue_loop
    jle continue_loop
    jg false ; in caz contrar, evenimentul nu are cum sa existe => valid = 0

verificare_februarie:
    movzx eax, byte [ebx + event.date + date.day] ; ii atribuim lui eax ziua evenimentului
    cmp eax, 28 ; daca se respecta conditia ca ultima zi a lunii sa fie 28,
                ; trecem la urmatorul eveniment prin intermediul continue_loop
    jle continue_loop
    jg false ; in caz contrar, evenimentul nu are cum sa existe => valid = 0

continue_loop:
    mov byte [ebx + event.valid], 1 ; daca am ajuns in acest punct fara sa trecem prin
                           ; label-ul false, evenimentul exista => valid = 1
    add ebx, event_size ; trecem la urmatorul eveniment prin mutarea lui ebx cu 36 de bytes
    add edx, 1 ; crestem edx cu 1
    jmp start_loop

false:
    mov byte [ebx + event.valid], 0
    add ebx, event_size ; trecem la urmatorul eveniment prin mutarea lui ebx cu 36 de bytes
    add edx, 1 ; crestem edx cu 1
    jmp start_loop

end_loop:
    ;; Your code ends here

    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY