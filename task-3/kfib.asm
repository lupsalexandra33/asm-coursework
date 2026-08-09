section .text
global kfib

kfib:
    ; creem un nou stack frame
    enter 0, 0
    xor eax, eax
    push ebx
    push edi
    push esi
    ; valoarea lui n
    mov ebx, [ebp + 8]
    ; valoarea lui k
    mov edx, [ebp + 12]

    ;; mai intai, vom compara relatia dintre n si k
    ;; daca n < k => return 0 in functia recursiva
    ;; daca n == k => return 1 in functia recursiva
    ;; daca n > k => adunam recursiv ultimii k termeni intr-un for
    cmp ebx, edx
    je return_k1
    jl return_k0

    ;; daca nu intra in una din cele doua etichete => avem de calculat suma recursiva
    ;; aceasta va fi calculata in registrul edi
    mov edi, 0
    ; initializam ecx cu 1 pentru a tine evidenta for-ului
    mov ecx, 1

suma_kfib:
    cmp ecx, edx
    ; daca am ajuns in acest label => suma a fost calculata iar astfel eax = edi si intra in end
    jg end_loop

    ; pentru a nu pierde valoarea originala a lui n vom lucra cu copiile acestuia salvate in esi
    mov esi, ebx
    ; calculam n - i
    sub esi, ecx
    ; dam push la registre pentru a nu le corupe valoarea pe parcursul executiei functiei externe
    push ecx
    push edx

    ;; adaugam pe stiva in ordine inversa parametrii de care avem nevoie pentru
    ;; apelarea functiei recursive

    push edx
    push esi
    call kfib
    ; dupa apel, curatam stiva
    add esp, 8
    ; dupa executie, dam pop la registre
    pop edx
    pop ecx

    ; adaugam rezultatul apelului in suma
    add edi, eax
    ; trecem la urmatoarea iteratie
    add ecx, 1
    jmp suma_kfib

return_k0:
    ; daca n < k => return 0 in functia recursiva
    mov eax, 0
    jmp end

return_k1:
    ; daca n == k => return 1 in functia recusriva
    mov eax, 1
    jmp end

end_loop:
    ; salvam in eax suma recursiva calculata in edi
    mov eax, edi
    jmp end

;; ajunsi in acest label, curatam stiva si returnam adresa
end:
    pop esi
    pop edi
    pop ebx
    leave
    ret
