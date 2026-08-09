section .bss
    ; in variabila rezultat punem lungimea palindromului final
    rezultat resd 1
    ; in vectorul lungimi punem lungimile fiecarui cuvant din vectorul de cuvinte
    lungimi resd 1
    ; in rezultat_length retinem lungimea celui mai lung palindrom gasit pana acum
    rezultat_length resd 1
    ; in p retinem numarul de submultimi posibile, in cazul nostru 2^15
    p resd 1
    ; in variabila copie creem o copie a fiecarei sbmultimi posibile
    copie resd 1
    ; in lungime_string retinem lungimea rezultata din adunarea cuvintelor prezente in submultimea curenta
    lungime_string resd 1
    ; in variabila temp adaugam concatenarea mastii curente
    temp resd 1

section .text
global check_palindrome
global composite_palindrome

extern malloc
extern strcat
extern strcmp
extern strcpy
extern strlen
extern free

check_palindrome:
    ; create a new stack frame
    enter 0, 0
    push edi
    push esi
    push ebx
    push edx
    xor eax, eax
    ; sirul de caractere
    mov eax, [ebp + 8]
    ; lungimea sirului
    mov ebx, [ebp + 12]

    ; punem pe stiva eax intrucat vrem sa folosim registrul pentru impartire
    push eax
    ; salvam in eax care este lungimea sirului deoarece avem nevoie la impartire
    mov eax, ebx
    ; initializam edx unde vom pune restul cu 0
    mov edx, 0
    ; punem in ecx 2 intrucat vrem sa impartim la 2
    mov ecx, 2
    div ecx

    ; salvam rezultatul impartirii in ecx
    mov ecx, eax
    ; initializam edi cu 0 pentru a intra in loop
    mov edi, 0
    ; esi primeste lungimea sirului
    mov esi, ebx
    pop eax

    ; scadem 1 din esi intrucat numaratoarea caracterelor incepe de la 0
    sub esi, 1

;; in verificare_loop verificam fiecare caracter din prima jumatate cu cel corespondent
;; lui din a doua jumatate
verificare_loop:
    ; daca am ajuns aici, inseamna ca sirul este palindrom
    cmp edi, ecx
    jge e_palindrom

    mov edx, esi
    sub edx, edi
    ; calculam pana aici caracterul corespunzator din a doua jumatate, acesta se afla pe pozitia [eax + esi - edi]
    mov dl, byte [eax + edx]
    ; comparam caracterul respectiv cu cel care ii corespunde din prima jumatate
    cmp byte [eax + edi], dl
    je repeat
    ; daca am gasit diferente => nu e palindrom
    jne nu_e_palindrom

;; daca nu, continuam verificarea
repeat:
    ; incrementam edi cu 1 pentru a verifica urmatoarele caractere
    add edi, 1
    jmp verificare_loop


nu_e_palindrom:
    ; daca nu este palindrom returnam 0
    mov eax, 0
    jmp end_loop

e_palindrom:
    ; daca este palindrom returnam 1
    mov eax, 1

end_loop:
    pop edx
    pop ebx
    pop esi
    pop edi
    leave
    ret

composite_palindrome:
    ; creem un nou stack frame
    enter 0, 0
    xor eax, eax
    push esi
    push edi
    push edx
    push ebx
    ; vectorul de cuvinte
    mov ebx, [ebp + 8]
    ; numarul de cuvinte din vector
    mov edx, [ebp + 12]

    ; initializam char *rezultat = NULL
    mov dword [rezultat], 0
    ; initializam int *lungimi = NULL
    mov dword [lungimi], 0

    ; facem o copie a numarului de cuvinte in ecx
    mov ecx, [ebp + 12]
    ; inmultim len cu 4 (len * sizeof(int))
    imul ecx, 4
    ; dam push la registre pentru a nu le corupe valoarea pe parcursul executiei functiei externe
    push ebx
    push edx
    push edi
    push esi
    push ecx
    call malloc
    ; curata malloc de pe stiva
    add esp, 4
    ; dupa executie, dam pop la registre
    pop esi
    pop edi
    pop edx
    pop ebx

    ; returnam rezultatul functiei in lungimi, astfel => int *lungimi = malloc(len * sizeof(int))
    mov dword [lungimi], eax
    ; int rezultat_length = 0
    mov dword [rezultat_length], 0
    ; initializam ecx cu 0 intrucat il vom folosi in for-uri
    mov ecx, 0
loop_retinere_lungimi_cuvinte:
    ; facem un for care sa treaca prin toate cuvintele
    cmp ecx, [ebp + 12]
    jge shiftare

    ; salvam in eax strs[i]
    mov eax, [ebx + 4 * ecx]
    ; dam push la registre pentru a nu le corupe valoarea pe parcursul executiei functiei externe
    push ebx
    push edx
    push edi
    push esi
    push ecx
    push eax
    call strlen
    ; curata strlen de pe stiva
    add esp, 4
    ; dupa executie, dam pop la registre
    pop ecx
    pop esi
    pop edi
    pop edx
    pop ebx
    ; retinem in edi lungimea cuvantului strs[i]
    mov edi, eax

retinere_lungime:
    ; retinem in esi vectorul lungimi
    mov esi, dword [lungimi]
    ; lungimi[i] = strlen(strs[i])
    mov dword [esi + 4 * ecx], edi
    ; incrementam ecx-ul pentru urmatoare iteratie
    add ecx, 1
    jmp loop_retinere_lungimi_cuvinte

shiftare:
    ; punem in ecx numarul de cuvinte din vector (len)
    mov ecx, [ebp + 12]
    ; punem in eax 1 pentru a respecta conventia excutiei instructiunii shl
    mov eax, 1
    shl eax, cl
    ; int p = 1 << len
    mov dword [p], eax
    ; folosim ecx pentru primul for ce urmeaza
    mov ecx, 1

loop_masca:
    cmp ecx, dword [p]
    jge palindrom_rezultat

    ; int copie = masca curenta (ecx)
    mov dword [copie], ecx
    ; int lungime_string = 0
    mov dword [lungime_string], 0

    ; folosim edi pentru al doilea for ce urmeaza
    mov edi, 0

loop_digits:
    ; dupa ce realizam lungimea totala a concatenarii sirurilor din masca respectiva, intram in verif_length
    cmp edi, [ebp + 12]
    jge verif_length

    ; punem in eax variabila copie
    mov eax, dword [copie]
    ; verificam daca variabila copie e para sau impara
    and eax, 1
    ; daca e para, cuvantul nu este adaugat in masca => trecem la urmatorul bit din masca
    cmp eax, 0
    je next_word_loop

;; daca e impara, adaugam lungimea cuvantului in variabila lungime_string
suma_lungimi:
    ; punem in esi vectorul lungimi
    mov esi, dword [lungimi]
    ; punem in eax lungimea cuvantului ce trebuie adaugat in lungime_string
    mov eax, [esi + 4 * edi]
    add dword [lungime_string], eax
    jmp next_word_loop

next_word_loop:
    ; punem in eax variabila copie
    mov eax, dword [copie]
    ; impartim variabila la 2 prin shiftare la dreapta pe biti
    shr eax, 1
    ; punem noua variabila a copiei in copie
    mov dword [copie], eax
    ; incrementam edi pentru a trece la urmatorul cuvant
    add edi, 1
    jmp loop_digits

verif_length:
    ; punem lungimea celui mai lung palindrom gasit in eax
    mov eax, dword [rezultat_length]
    ; comparam cu lungimea cuvintelor din masca actuala => daca este mai mic lungime_string, nu are rost sa continuam
    cmp dword [lungime_string], eax
    jl next_masca

    ; punem in eax variabila lungime_string
    mov eax, dword [lungime_string]
    ; adaugam 1 pentru terminatorul de sir
    add eax, 1
    ; dam push la registre pentru a nu le corupe valoarea pe parcursul executiei functiei externe
    push edx
    push ecx
    push eax
    call malloc
    ; curata malloc de pe stiva
    add esp, 4
    ; dupa executie, dam pop la registre
    pop ecx
    pop edx

    ; char *temp = malloc(lungime_string + 1)
    mov dword [temp], eax
    ; punem in eax temp
    mov eax, dword [temp]
    ; temp[0] = '\0'
    mov byte [eax], 0
    ; copie = masca curenta
    mov dword [copie], ecx
    ; folosim edi pentru for-ul ce urmeaza
    mov edi, 0

loop_concatenare:
    ; daca am depasit numarul de cuvante, trebuie sa adaugam terminatorul de sir concatenarii curente
    cmp edi, [ebp + 12]
    jge adauga_terminator_sir

    ; punem in eax variabila copie
    mov eax, dword [copie]
    ; verificam daca variabila copie e para sau impara
    and eax, 1
    ; daca e para, cuvantul nu este adaugat in masca => trecem la urmatorul bit din masca
    cmp eax, 0
    je next_word

    ; punem in eax temp
    mov eax, dword [temp]
    ; punem in edx cuvantul curent
    mov edx, [ebx + 4 * edi]

    ; dam push la registre pentru a nu le corupe valoarea pe parcursul executiei functiei externe
    push ecx
    push edx
    push eax
    call strcat
    ; curata strcat de pe stiva
    add esp, 8
    ; dupa executie, dam pop la registre
    pop ecx

next_word:
    ; punem in eax variabila copie
    mov eax, dword [copie]
    ; impartim variabila la 2 prin shiftare la dreapta pe biti
    shr eax, 1
    ; punem noua variabila a copiei in copie
    mov dword [copie], eax
    ; incrementam edi pentru a prelucra urmatorul cuvant
    add edi, 1
    jmp loop_concatenare

adauga_terminator_sir:
    ; punem in eax vectorul temp
    mov eax, dword [temp]
    ; adaugam lungime string pentru a stii ce bit trebuie initializat cu terminatorul de sir
    add eax, dword [lungime_string]
    ; temp[lungime_string] = '\0'
    mov byte [eax], 0

    ; dam push la registre pentru a nu le corupe valoarea pe parcursul executiei functiei externe
    push ecx
    push dword [lungime_string]
    push dword [temp]
    ; verificam daca cuvantul realizat este plaindrom sau nu
    call check_palindrome
    ; curata temp si lungime_string la care am dat push de pe stiva
    add esp, 8
    ; dupa executie, dam pop la registre
    pop ecx
    ; daca este palindrom, verificam daca indeplineste conitiile in caz contrar eliberam temp
    cmp eax, 0
    jnz indeplinire_conditii
    jmp clean_temp

indeplinire_conditii:
    ; punem in eax lungime_string
    mov eax, dword [lungime_string]
    ; daca lungime_string >= rezultat_length => continuam if-ul in caz contrar eliberam temp
    cmp eax, dword [rezultat_length]
    jg alocare_sir
    je if_secund
    jl clean_temp

if_secund:
    ; daca rezultat nu este NULL verificam urmatoarea conditie, daca este trecem in eticheta alocare_sir
    cmp dword [rezultat], 0
    jne if_tert
    je alocare_sir

if_tert:
    ; dam push la registre pentru a nu le corupe valoarea pe parcursul executiei functiei externe
    push ecx
    push edx
    push dword [rezultat]
    push dword [temp]
    call strcmp
    ; curata strcmp de pe stiva
    add esp, 8
    ; dupa executie, dam pop la registre
    pop edx
    pop ecx

    ; daca rezultat e mai mic lexicografic, nu continuam si eliberam temp
    cmp eax, 0
    jl alocare_sir
    jge clean_temp

clean_temp:
    ; verificam dacă temp este NULL
    cmp dword [temp], 0
    je next_masca

    ; dam push la registre pentru a nu le corupe valoarea pe parcursul executiei functiei externe
    push ecx
    push edx
    push dword [temp]
    call free
    ; curata free de pe stiva
    add esp, 4
    ; dupa executie, dam pop la registre
    pop edx
    pop ecx

    jmp next_masca

;; daca am gasit un string valid, noul rezultat va deveni acel palindrom
alocare_sir:
    ; punem in esi lungime_string
    mov esi, dword [lungime_string]
    ; rezultat_length = lungime_string
    mov dword [rezultat_length], esi

    ; verificam daca rezultat contine in momentul actual ceva, daca nu nu dam free
    cmp dword [rezultat], 0
    je skip_eliberare

    ; dam push la registre pentru a nu le corupe valoarea pe parcursul executiei functiei externe
    push ecx
    push edx
    push dword [rezultat]
    ; eliberam continutul actual al lui rez
    call free
    ; curata free de pe stiva
    add esp, 4
    ; dupa executie, dam pop la registre
    pop edx
    pop ecx

skip_eliberare:
    ; eax primeste lungime_string
    mov eax, esi
    ; adaugam 1 pentru terminatorul de sir
    add eax, 1
    ; dam push la registre pentru a nu le corupe valoarea pe parcursul executiei functiei externe
    push ecx
    push eax
    ; alocam cu malloc rezultat cu (lungime_string + 1)
    call malloc
    ; curata malloc de pe stiva
    add esp, 4
    ; dupa executie, dam pop la registre
    pop ecx
    mov dword [rezultat], eax

    ; dam push la registre pentru a nu le corupe valoarea pe parcursul executiei functiei externe
    push ecx
    push dword [temp]
    push dword [rezultat]
    ; rezultat primeste noul palindrom gasit
    call strcpy
    ; curata strcpy de pe stiva
    add esp, 8
    ; dupa executie, dam pop la registre
    pop ecx

    jmp clean_temp

next_masca:
    ; incrementam ecx pentru urmatoarul subset
    add ecx, 1
    jmp loop_masca

palindrom_rezultat:
    ; dam push la registre pentru a nu le corupe valoarea pe parcursul executiei functiei externe
    push ecx
    push edx
    push dword [lungimi]
    ; eliberam continutul vectroului ce retine lungimile
    call free
    ; curata free de pe stiva
    add esp, 4
    ; dupa executie, dam pop la registre
    pop edx
    pop ecx

    ; punem in eax palindromul final gasit
    mov eax, dword[rezultat]
    pop ebx
    pop edx
    pop edi
    pop esi
    leave
    ret
