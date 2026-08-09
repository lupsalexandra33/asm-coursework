section .bss
    ; in variabila i vom calcula lungimea fiecarui cuvant din get_words
    i resd 1

section .text
global sort
global get_words

; am declarat functia externa pe care o folosesc
extern qsort

comparare_cuvinte:
    ; creem un nou stack frame
    enter 0,0
    push ebx
    push edi
    push esi
    xor eax, eax

    ; adresa pointerului la primul cuvant (char **)
    mov ebx, [ebp + 8]
    ; adresa pointerului la cel de al doilea cuvant (char **)
    mov ecx, [ebp + 12]

    ; obtinem adresa de inceput a primului cuvant (char *)
    mov ebx, [ebx]
    ; obtinem adresa de inceput al celui de al doilea cuvant (char *)
    mov ecx, [ecx]

    ; initializam edi cu 0, in el calculam lungimea primului cuvant
    mov edi, 0
    ; initializam esi cu 0, in el calculam lungimea celui de al doilea cuvant
    mov esi, 0

strlen_1:
    ; verificam daca am ajuns la final de cuvant
    cmp byte [ebx + eax], 0
    je reatribuire_eax

    ; salvam in edi lungimea primului cuvant
    add edi, 1
    ; incrementam eax pentru a verifica urmatorul caracter
    add eax, 1
    jmp strlen_1

reatribuire_eax:
    ; reinitializam eax cu 0 pentru a afla lungimea celui de al doilea cuvant
    mov eax, 0

strlen_2:
    ; verificam daca am ajuns la final de cuvant
    cmp byte [ecx + eax], 0
    je comparare_rezultate

    ; salvam in esi lungimea celui de al doilea cuvant
    add esi, 1
    ; incrementam eax pentru a verifica urmatorul caracter
    add eax, 1
    jmp strlen_2

comparare_rezultate:
    ; comparam lungimea celor doua cuvinte
    cmp edi, esi
    ; daca primul cuvant e mai scurt => returnam in eax -1
    jl return_lower
    ; daca primul cuvant e mai lung => returnam in eax 1
    jg return_greater

    ; daca am ajuns aici inseamna ca cuvintele au aceeasi lungime
    ; reinitializam edi cu 0 intrucat avem nevoie de el la noua comparatie
    mov edi, 0

;; in strcmp_loop comparam litera cu litera cuvintele
strcmp_loop:
    ; in edx salvam caracterul primului cuvant
    movzx edx, byte [ebx + edi]
    ; in eax salvam caracterul celui de al doilea cuvant
    movzx eax, byte [ecx + edi]
    ; la prima litera diferita, ne mutam in unul din cele doua label-uri
    cmp dl, al
    jl return_lower
    jg return_greater

    ; verificam daca am ajuns la final de cuvant
    test edx, edx
    ; daca da => cuvintele sunt identice => returnam in eax 0
    je egalitate

    ; incrementam edi pentru compararea urmatorului caracter
    add edi, 1
    jmp strcmp_loop

return_lower:
    ; reaturnam -1 in eax
    mov eax, -1
    jmp end_loop_cmp

return_greater:
    ; returnam 1 in eax
    mov eax, 1
    jmp end_loop_cmp

egalitate:
    ; returnam 0 in eax
    mov eax, 0

end_loop_cmp:
    pop esi
    pop edi
    pop ebx
    leave
    ret

;; sort(char **words, int number_of_words, int size)
;  functia va trebui sa apeleze qsort pentru soratrea cuvintelor
;  dupa lungime si apoi lexicografix
sort:
    ; creem un nou stack frame
    enter 0, 0
    push ebx
    push ecx
    push edx
    xor eax, eax
    ; vector de cuvinte
    mov ebx, [ebp + 8]
    ; numarul de cuvinte
    mov ecx, [ebp + 12]
    ; dimensiunea unui cuvant
    mov edx, [ebp + 16]

    ;; adaugam pe stiva parametrii pentru qsort in ordine inversa
    push comparare_cuvinte
    push edx
    push ecx
    push ebx
    call qsort
    ; dupa apel, curatam stiva
    add esp, 16

end_loop_sort:
    ; punem in eax pointer catre adresa de inceput a vectorului de cuvinte sortat
    mov eax, [ebx]
    pop edx
    pop ecx
    pop ebx
    leave
    ret

;; get_words(char *s, char **words, int number_of_words)
;  separa stringul s in cuvinte si salveaza cuvintele in words
;  number_of_words reprezinta numarul de cuvinte
get_words:
    ; create a new stack frame
    enter 0, 0
    xor eax, eax
    ; string-ul s (textul)
    mov ebx, [ebp + 8]
    ; vector de stringuri in care salvam cuvintele
    mov ecx, [ebp + 12]
    ; numarul de cuvinte
    mov edx, [ebp + 16]

    ; initializam eax cu 0 ca sa plece de la primul caracter
    mov eax, 0
    ; punem si in edi inceputul string-ului iar in acesta variabila vom retine mereu pointer catre cuvant
    mov edi, ebx
    ; initializam variabila i cu 0
    mov dword [i], 0
    ; in esi contorizam numarul de cuvinte
    mov esi, 0

loop_cuvinte:
    ; comparam byte-ul cu punct
    cmp byte [ebx + eax], '.'
    je cuvant_nou
    ; comparam byte-ul cu virgula
    cmp byte [ebx + eax], ','
    je cuvant_nou
    ; comparam byte-ul cu newline, am pus valoarea numerica pentru a evita warning-ul
    cmp byte [ebx + eax], 10
    je cuvant_nou
    ; comparam byte-ul cu spatiu
    cmp byte [ebx + eax], ' '
    je cuvant_nou

new_char:
    ; verificam daca am terminat sirul
    cmp byte [ebx + eax], 0
    je ultimul_cuvant

    ; incrementam ca sa aflam treptat lungimea cuvantului actual
    add dword [i], 1
    ; incrementam eax pentru a verifica urmatorul caracter
    add eax, 1
    jmp loop_cuvinte

cuvant_nou:
    ; adaugam terminatorul de sir cuvantului
    mov byte [ebx + eax], 0
    ; incrementam eax intrucat vrem sa trecem la urmatorul caracter
    add eax, 1

    ; comparam sa vedem la ce cuvant ne aflam
    cmp esi, edx
    jge end_loop

    ; salvam în words[esi] adresa de inceput a cuvantului curent
    mov [ecx + 4 * esi], edi
    ; incrementam variabila i pentru ca a mai crescut lungimea cuvantului curent
    add edi, dword [i]
    ; adaugam in edi cate caractere am adaugat pt a avea pointer-ul la acelasi nivel cu eax
    add edi, 1

;; in verificare_delimitatori trecem peste toti delimitatorii care mai afla pana
;; la inceputul urmatorului cuvant
verificare_delimitatori:
    ; comparam byte-ul cu punct
    cmp byte [ebx + eax], '.'
    je repeat
    ; comparam byte-ul cu virgula
    cmp byte [ebx + eax], ','
    je repeat
    ; comparam byte-ul cu newline, am pus valoarea numerica pentru a evita warning-ul
    cmp byte [ebx + eax], 10
    je repeat
    ; comparam byte-ul cu spatiu
    cmp byte [ebx + eax], ' '
    je repeat

    ; reinitializam variabila i cu 0 pentru a calcula lungimea noului cuvant
    mov dword [i], 0
    ; continuam cu urmatorul cuvant
    add esi, 1
    jmp loop_cuvinte

;; la fiecare delimitator incrementam atat eax, cat si edi
repeat:
    ; incrementam eax pentru a trece la urmatorul caracter
    add eax, 1
    ; incrementam si edi pentru a avea pointer-ul la acelasi nivel cu eax
    add edi, 1
    jmp verificare_delimitatori

ultimul_cuvant:
    ; ajunsi la finalul string-ului, verificam daca am procesat toate cuvintele
    cmp dword [i], 0
    je end_loop

    ; daca i != 0, inseamna ca mai avem de adaugat in vector un cuvant
    mov [ecx + 4 * esi], edi
    ; incrementam esi pentru a mai marca inca un cuvant peste care am trecut
    add esi, 1

end_loop:
    ; incarcam in eax adresa primului cuvant din words[0]
    mov eax, [ecx]
    leave
    ret

