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

section .bss
    i resd 1
    j resd 1
    k resd 1 ; variabila indice o folosim pentru un for in care vom
             ; compara litera cu litera numele evenimentelor
    indice resd 1 ; variabila indice o folosim pentru un for in care vom
                  ; face swap litera cu litera intre numele evenimentelor
    ok resd 1 ; in variabila ok verificam daca mai trebuie sa comparam elementele
              ; cand ok = 1 => evenimentele au fost ordonate

section .text
    global sort_events
    extern printf

sort_events:
    ;; DO NOT MODIFY
    enter 0, 0
    pusha

    mov ebx, [ebp + 8]      ; vectorul de evenimente
    mov ecx, [ebp + 12]     ; numarul de evenimente
    ;; DO NOT MODIFY

    ;; Your code starts here

    mov dword [i], 0 ; initializam variabila i cu 0, in aceasta vom itera primul for
    mov dword [j], 0 ; initializam variabila j cu 0, in aceasta vom itera al doilea for
    mov dword [k], 0 ; initializam variabila k cu 0, cu ajutorul acesteia vom verifica
                     ; caracter cu caracter diferentele dintre doua cuvinte
    mov dword [indice], 0
    mov dword [ok], 0

;; in cele doua for-uri, start_loop_1 si start_loop_2 implementam algoritmul de sortare BubbleSort
;; primul for porneste de la 0 la n - 1
;; al doilea for porneste de la 0 la n - i - 1

start_loop_1:
    mov dword [ok], 0 ; ok = 0, daca ok = 1 inseamna ca am ordonat evenimentele
    mov edi, ecx
    sub edi, 1 ; in edi retinem valoarea n - 1
    cmp dword [i], edi
    jge end_loop ; daca am ajuns aici, inseamna ca evenimentele erau deja ordonate
                 ; si prin eticheta end_loop iesim din functie

start_loop_2:
    mov dword [k], 0 ; reinitializam k = 0 la fiecare comparatie a doua evenimente
    mov dword [indice], 0 ; reinitializam indice = 0 la fiecare comparatie a doua evenimente
    mov eax, edi
    sub eax, dword [i] ; in eax retinem valoarea n - i - 1
    cmp dword [j], eax
    jge end_loop2 ; daca am ajuns aici, trecem in eticheta end_loop2

    mov edx, dword [j]
    imul edx, event_size
    add edx, ebx ; calculam eveniment[j]

    mov esi, edx
    add esi, event_size ; calculam eveniment[j + 1]

;; mai intai, vom compara daca evenimentele sunt valide
;; daca eax < ecx => facem swap | daca eax > ecx => trecem la eticheta continuare_loop_2
;; daca evenimentele sunt egale d.p.d.v. al acestui criteriu => continuam cu verificarea anului

    push eax
    push ecx
    movzx eax, byte [edx + event.valid]
    movzx ecx, byte [esi + event.valid] ; event.valid este de tip byte => incarcam in registru
                                        ; un singur byte iar restul completam cu zero-uri
    cmp eax, ecx
    pop ecx
    pop eax
    jl swap_event
    jg continuare_loop_2
    je verificare_an

verificare_an:
    push eax
    ; event.date.year este de tip word => incarcam in ax doi bytes
    mov ax, [edx + event.date + date.year]
    cmp ax, [esi + event.date + date.year]
    pop eax
    jg swap_event ; daca primul an este mai mare => gresit! (facem swap)
    je verificare_luna ; daca avem acelasi an, comparam luna
    jl continuare_loop_2 ; daca al doilea an este mai mare => evenimentele sunt
                         ; deja in ordinea corecta


verificare_luna:
    push eax
    push ecx
    ; event.date.month este de tip byte => incarcam in registru
    ; un singur byte iar restul completam cu zero-uri
    movzx eax, byte [edx + event.date + date.month]
    movzx ecx, byte [esi + event.date + date.month]
    cmp eax, ecx
    pop ecx
    pop eax
    jg swap_event ; daca prima luna este mai mare => gresit! (facem swap)
    je verificare_zi ; daca avem aceeasi luna, comparam ziua
    jl continuare_loop_2 ; daca a doua luna este mai mare => evenimentele sunt
                         ; deja in ordinea corecta

verificare_zi:
    push eax
    push ecx
    ; event.date.day este de tip byte => incarcam in registru
    ; un singur byte iar restul completam cu zero-uri
    movzx eax, byte [edx + event.date + date.day]
    movzx ecx, byte [esi + event.date + date.day]
    cmp eax, ecx
    pop ecx
    pop eax
    jg swap_event ; daca prima zi este mai mare => gresit! (facem swap)
    je sortare_strcmp ; daca avem aceeasi zi, comparam numele
    jl continuare_loop_2 ; daca a doua zi este mai mare => evenimentele sunt
                         ; deja in ordinea corecta

continuare_loop_2:
    add dword [j], 1 ; incrementam [j]
    jmp start_loop_2

;; in acest label comparam litera k din ambele evenimente
sortare_strcmp:
    push ebx
    mov ebx, dword [k]
    push eax
    push ecx
    movzx eax, byte [edx + ebx]
    movzx ecx, byte [esi + ebx]
    cmp eax, ecx
    pop ecx
    pop eax
    pop ebx
    jg swap_event ; daca litera din primul eveniment este mai mare => gresit! (facem swap)
    jl continuare_loop_2 ; daca litera din al doilea eveniment este mai mare =>
                         ; evenimentele sunt deja in ordinea corecta
    je continuare_verificare ; repetam verificarea pt urmatoarea litera

continuare_verificare:
    add dword [k], 1
    cmp dword [k], event.valid
    jl sortare_strcmp
    jmp continuare_loop_2

swap_event:
    mov dword [ok], 1 ; daca mutam doua evenimente, ok = 1

    push eax
    push ecx
    ;; am interschimbat campul valid (1 byte => am folosit al si cl)
    mov al, [edx + event.valid]
    mov cl, [esi + event.valid]
    mov [edx + event.valid], cl
    mov [esi + event.valid], al

    ;; am interschimbat campul day (1 byte => am folosit al si cl)
    mov al, [edx + event.date + date.day]
    mov cl, [esi + event.date + date.day]
    mov [edx + event.date + date.day], cl
    mov [esi + event.date + date.day], al

    ;; am interschimbat campul month (1 byte => am folosit al si cl)
    mov al, [edx + event.date + date.month]
    mov cl, [esi + event.date + date.month]
    mov [edx + event.date + date.month], cl
    mov [esi + event.date + date.month], al

    ;; am interschimbat campul year (2 bytes => am folosit ax si cx)
    mov ax, [edx + event.date + date.year]
    mov cx, [esi + event.date + date.year]
    mov [edx + event.date + date.year], cx
    mov [esi + event.date + date.year], ax
    pop ecx
    pop eax
    jmp interschimbare_nume ; trecem in for-ul de interschimbare a numelor evenimentelor

interschimbare_nume:
    cmp dword [indice], event.valid
    jge continuare_loop_2

    push eax
    push ebx
    push ecx
    mov ebx, dword [indice]
    ;; interschimbam litera cu litera (cate 1 byte => am folosit al si ah)
    mov al, [edx + ebx]
    mov ah, [esi + ebx]
    mov [edx + ebx], ah
    mov [esi + ebx], al
    pop ecx
    pop ebx
    pop eax

    add dword [indice], 1
    jmp interschimbare_nume

end_loop2: ; end_loop2 se activeaza la iesirea din cel de al doilea for
    add dword [i], 1 ; incrementam [i]
    mov dword [j], 0 ; resetam [j] la valoarea 0

    cmp dword [ok], 0
    je end_loop ; daca nu s-a produs nicio interschimbare => evenimentele
                ; au fost sortate in totalitate => iesim din functie

    jmp start_loop_1

end_loop:
    mov ebx, [ebp + 8] ; facem ca ebx sa primeasca cat avea la inceputul programului
    ;; Your code ends here

    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY