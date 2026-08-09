section .bss
    ; in variabila i ne plimbam prin toate valorile de la 1 la n
    i resd 1

section .text
global sort

;   struct node {
;    int val;
;    struct node* next;
;   };

;; struct node* sort(int n, struct node* node);
;   The function will link the nodes in the array
;   in ascending order and will return the address
;   of the new found head of the list
; @params:
;   n -> the number of nodes in the array
;   node -> a pointer to the beginning in the array
;   @returns:
;   the address of the head of the sorted list
sort:
    ; creem un nou stack frame
    enter 0, 0
    ; in eax salvam head-ul pentru ca tot aici trebuie sa returnam lista
    xor eax, eax
    ; n
    mov ebx, [ebp + 8]
    ; pointer la inceput de array
    mov ecx, [ebp + 12]

    ; i primeste 1 pt primul for
    mov dword [i], 1
    ; edx se foloseste drept contor pt al doilea for
    mov edx, 0

;; facem un loop de la 1 la n pentru a parcurge toate valorile
start_loop_1:
    ; daca variabila i depaseste n-ul, inseamna ca am terminat de sortat si trecem in eticheta end_loop
    cmp dword [i], ebx
    jg end_loop

;; facem un al doilea loop de la 0 la n in care sortam toate elementele
start_loop_2:
    cmp edx, ebx
    jg skip

    ; dam push la eax intrucat avem nevoie de registru
    push eax
    ; eax primeste valoarea curenta pe care trebuie sa o adaugam in lista
    mov eax, dword [i]
    ; daca v[edx] == i inseamna ca am gasit elementul ce trebuie adaugat in lista
    cmp dword [ecx + 8 * edx], eax
    ; dam pop la eax
    pop eax
    ; daca nu, continuam cautarea
    jne skip

    ; comparam eax cu 0 pentru a vedea daca elementul ce urmeaza a fi adaugat e primul
    cmp eax, 0
    je primul_element
    jg adaugare_nod

skip:
    ; incrementam edx pentru a continua cautarea cu urmatorul element
    add edx, 1
    jmp start_loop_2

primul_element:
    ; dam push la ebx intrucat avem nevoie de registru
    push ebx
    ; salvam in ebx adresa elementului ce trebuie adaugat in lista
    lea ebx, [ecx + 8 * edx]
    ; punem in eax (head) adresa nodului
    mov eax, ebx
    ; fiind primul nod, punem si in edi (tail) adresa nodului
    mov edi, ebx
    ; dam pop la ebx
    pop ebx
    ; incrementam i-ul intrucat vrem sa cautam acum in vector urmatoarea valoare
    add dword [i], 1
    ; reinitializam edx cu 0 pentru urmatoarea cautare prin vector
    mov edx, 0
    jmp start_loop_1

adaugare_nod:
    ; dam push la ebx intrucat avem nevoie de registru
    push ebx
    ; salvam in ebx adresa elementului ce trebuie adaugat in lista
    lea ebx, [ecx + 8 * edx]
    ; tail->next = node
    mov [edi + 4], ebx
    ; tail = node
    mov edi, ebx
    ; dam pop la ebx
    pop ebx
    ; incrementam i-ul intrucat vrem sa cautam acum in vector urmatoarea valoare
    add dword [i], 1
    ; reinitializam edx cu 0 pentru urmatoarea cautare prin vector
    mov edx, 0
    jmp start_loop_1

end_loop:
    leave
    ret

