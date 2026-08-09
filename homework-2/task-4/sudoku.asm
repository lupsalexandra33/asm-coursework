%include "../include/io.mac"

extern printf
global check_row
global check_column
global check_box

section .bss
    array resb 9 ; am initializat vectorul array in care vom stoca elementele
                 ; cutiei din functia check_box

section .text


; int check_row(char* sudoku, int row);
check_row:

    push    ebp
    mov     ebp, esp
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov     esi, [ebp + 8]  ; vectorul ce contine 81 de elemente ce formeaza un sudoku
    mov     edx, [ebp + 12]  ; randul pe care trebuie sa il verificam

    mov edi, 0 ; edi primeste 0
    mov ebx, 0 ; ebx primeste 0, in acest registru vom parcurge element cu element linia

start_loop1_row:
    cmp ebx, 9
    jge end_loop_row ; daca ebx are o valoarea mai mare sau egala decat 9 inseamna ca
                     ; am terminat verificarile si randul este corect

    ;; pentru a ajunge la pozitia din rand aceasta se calculeaza astfel
    ;; fiecare rand avand 9 elemente => inceputul randului se afla la
    ;; pozitia edx * 9 + esi (esi pointeaza catre inceputul vectorului)
    ;; pentru a ne plimba prin rand, adaugam ebx
    mov edi, edx
    imul edi, 9
    add edi, esi
    cmp byte [edi + ebx], 0
    jle incorect_row ; daca elementul din rand este mai mic de 0, fals => eax
                     ; primeste 2 si se iese din rand prin eticheta end_check_row

    cmp byte [edi + ebx], 9
    jg incorect_row  ; daca elementul din rand este mai mare de 9, fals => eax
                     ; primeste 2 si se iese din rand prin eticheta end_check_row

    mov ecx, ebx ; pregatim urmatorul for care porneste de pozitia curenta din primul for + 1
    add ecx, 1
start_loop2_row:
    cmp ecx, 9
    jge reluare_row ; daca ecx are o valoarea mai mare sau egala decat 9 se trece
                    ; in eticheta reluare_row

    mov al, byte [edi + ebx] ; in al adaugam valoarea elementului de pe pozitia ebx
    cmp al, byte [edi + ecx]
    je incorect_row ; daca cele doua valori sunt egale, inseamna ca avem duplicate => eax
                    ; primeste 2 si se iese din rand prin eticheta end_check_row

    add ecx, 1 ; in cazul in care cele doua valori nu sunt egale, se trece la urmatorul
               ; element din cel de-al doilea for si se compara cu acelasi element din primul for
    jmp start_loop2_row

reluare_row: ; ajunsi in acest label, inseamna ca am verificat elementul din primul
             ; for cu toate elemente de dupa el din al doilea for
    add ebx, 1 ; trecem la urmatorul element
    jmp start_loop1_row

incorect_row:
    mov eax, 2 ; NOT_OKAY = 2
    jmp end_check_row

end_loop_row:
    mov eax, 1 ; OK = 1

end_check_row:
    ;; DO NOT MODIFY

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    leave
    ret


; int check_column(char* sudoku, int column);
check_column:
    ;; DO NOT MODIFY
    push    ebp
    mov     ebp, esp
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov     esi, [ebp + 8]  ; vectorul ce contine 81 de elemente ce formeaza un sudoku
    mov     edx, [ebp + 12]  ; coloana pe care trebuie sa o verificam

    mov edi, 0 ; edi primeste 0
    mov ebx, 0 ; ebx primeste 0, in acest registru vom parcurge element cu element linia

start_loop1_column:
    cmp ebx, 9
    jge end_loop_column ; daca ebx are o valoarea mai mare sau egala decat 9 inseamna ca
                        ; am terminat verificarile si coloana este corecta

    ;; pentru a ajunge la pozitia din coloana aceasta se calculeaza astfel
    ;; fiecare coloana avand 9 elemente => inceputul coloanei se afla la
    ;; pozitia curenta din for * 9 + numarul coloanei + esi
    ;; (esi pointeaza catre inceputul vectorului)
    ;; pentru a nu modifica direct ebx-ul intrucat avem nevoie de el pentru parcurgerea
    ;; vectorului, calculam in eax = ebx * 9 + edx + esi
    mov eax, ebx
    imul eax, 9
    add eax, edx

    cmp byte [esi + eax], 0
    jle incorect_column ; daca elementul din coloana este mai mic de 0, fals => eax
                        ; primeste 2 si se iese din coloana prin eticheta end_check_column


    cmp byte [esi + eax], 9
    jg incorect_column ; daca elementul din coloana este mai mare de 9, fals => eax
                       ; primeste 2 si se iese din coloana prin eticheta end_check_column

    mov ecx, ebx ; pregatim urmatorul for care porneste de pozitia curenta din primul for + 1
    add ecx, 1
start_loop2_column:
    cmp ecx, 9
    jge reluare_column ; daca ecx are o valoarea mai mare sau egala decat 9
                       ; se trece in eticheta reluare_column

    ;; pozitia curenta din for * 9 + numarul coloanei + esi
    ;; pentru a nu modifica direct ecx-ul intrucat avem nevoie de el pentru parcurgerea
    ;; vectorului, calculam in edi = ecx * 9 + edx + esi
    mov edi, ecx
    imul edi, 9
    add edi, edx

    ;; pozitia curenta din for * 9 + numarul coloanei + esi
    ;; pentru a nu modifica direct ebx-ul intrucat avem nevoie de el pentru parcurgerea
    ;; vectorului, calculam in eax = ebx * 9 + edx + esi
    mov eax, ebx
    imul eax, 9
    add eax, edx

    mov al, byte [esi + eax] ; in al adaugam valoarea elementului de pe pozitia ebx
    cmp al, byte [esi + edi]
    je incorect_column ; daca cele doua valori sunt egale, inseamna ca avem duplicate => eax
                       ; primeste 2 si se iese din coloana prin eticheta end_check_column

    add ecx, 1 ; in cazul in care cele doua valori nu sunt egale, se trece la urmatorul
               ; element din cel de-al doilea for si se compara cu acelasi element din primul for
    jmp start_loop2_column

reluare_column: ; ajunsi in acest label, inseamna ca am verificat elementul din primul
                ; for cu toate elemente de dupa el din al doilea for
    add ebx, 1 ; trecem la urmatorul element
    jmp start_loop1_column

incorect_column:
    mov eax, 2 ; NOT_OKAY = 2
    jmp end_check_column

end_loop_column:
    mov eax, 1 ; OK = 1

end_check_column:
    ;; DO NOT MODIFY

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    leave
    ret

    ;; DO NOT MODIFY


; int check_box(char* sudoku, int box);
check_box:

    push    ebp
    mov     ebp, esp
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov     esi, [ebp + 8]  ; vectorul ce contine 81 de elemente ce formeaza un sudoku
    mov     edx, [ebp + 12]  ; box-ul pe care trebuie sa-l verificam

    mov eax, edx ; in eax punem valoarea box-ului, intrucat valoarea registrului
                 ; edx se va schimba odata cu efectuarea operatiei div
    mov edx, 0 ; initializam edx cu 0 pentru a afla restul rezultat din operatia div
    mov ecx, 3 ; ecx primeste valoarea impartitorului, 3
    div ecx
    ;; formula de start a box-ului este start = ((box / 3) * 27) + ((box % 3) * 3)
    ;; box / 3 se salveaza in eax (catul)
    ;; box % 3 se salveaza in edx (restul)
    imul edx, 3
    imul eax, 27
    add eax, edx ; in eax retinem pozitia de start calculata
    mov edi, eax
    add edi, esi ; in edi calculam valoarea pozitiei efective din vector, dupa
                 ; ce am adaugat si esi, registrul care pointeaza catre vectorul sudoku
    mov ecx, 0 ; initializam ecx cu 0
    mov ebx, 0 ; initializam ebx cu 0

salvare_valori: ; in acest registru, cu ajutorul variabilei array initializate in .bss,
                ; salvam toate valorile din box. In acest fel, putem verifica mai usor
                ; duplicatele si corectitudinea numerelor
    cmp ebx, 9
    jge verificare_duplicate

    cmp ebx, 3 ; daca ajungem in a 3-a pozitie a for-ului, inseamna ca am iesit din cutie
               ; iar pentru a ajunge iar in parametrii acesteia se trece in label-ul
               ; next_row
    je next_row

    cmp ebx, 6 ; daca ajungem in a 6-a pozitie a for-ului, inseamna ca am iesit din cutie
               ; iar pentru a ajunge iar in parametrii acesteia se trece in label-ul
               ; next_row
    je next_row

continuare:
    movzx eax, byte [edi + ebx]
    mov [array + ebx], eax ; salvam fiecare element din box in array

    add ebx, 1 ; crestem ebx cu 1
    jmp salvare_valori

verificare_duplicate:
    cmp ecx, 9
    jge end_loop ; daca ecx are o valoarea mai mare sau egala decat 9 inseamna ca
                 ; am terminat verificarile si box-ul este corect

    movzx eax, byte [array + ecx]
    cmp eax, 0
    jle incorect_box ; daca elementul din box este mai mic de 0, fals => eax
                     ; primeste 2 si se iese din box prin eticheta end_check_box
    cmp eax, 9
    jg incorect_box ; daca elementul din box este mai mare de 9, fals => eax
                    ; primeste 2 si se iese din box prin eticheta end_check_box

    mov ebx, ecx ; cel de al doilea for porneste de la valoarea for-ului curent + 1
    add ebx, 1

start_loop_2:
    cmp ebx, 9
    jge end_loop_2 ; daca ebx are o valoarea mai mare sau egala decat 9 se trece
                   ; in eticheta end_loop_2

    movzx eax, byte [array + ecx]
    cmp al, byte [array + ebx]
    je incorect_box ; daca cele doua valori sunt egale, inseamna ca avem duplicate => eax
                    ; primeste 2 si se iese din box prin eticheta end_check_box

    add ebx, 1 ; in cazul in care cele doua valori nu sunt egale, se trece la urmatorul
               ; element din cel de-al doilea for si se compara cu acelasi element din primul for
    jmp start_loop_2

end_loop_2: ; ajunsi in acest label, inseamna ca am verificat elementul din primul
            ; for cu toate elemente de dupa el din al doilea for
    add ecx, 1 ; trecem la urmatorul element
    jmp verificare_duplicate

incorect_box:
    mov eax, 2 ; NOT_OKAY = 2
    jmp end_check_box

next_row:
    add edi, 6 ; pentru a reintra in parametrii cutiei mutam pozitia lui edi cu
               ; 6 pozitii inainte
    jmp continuare ; continuam cu salvarea elementelor

end_loop:
    mov eax, 1 ; OKAY = 1

end_check_box:
    ;; DO NOT MODIFY

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    leave
    ret

    ;; DO NOT MODIFY
