%include "../include/io.mac"

extern printf
global remove_numbers

section .data
	fmt db "%d", 10, 0

section .text

; function signature:
; void remove_numbers(int *a, int n, int *target, int *ptr_len);

remove_numbers:
	;; DO NOT MODIFY
	push    ebp
	mov     ebp, esp
	pusha

	mov     esi, [ebp + 8] ; adresa vectorului sursa (a lui a)
	mov     ebx, [ebp + 12] ; n
	mov     edi, [ebp + 16] ; adresa vectorului destinatie (a lui target)
	mov     edx, [ebp + 20] ; pointer la ptr_len

	;; DO NOT MODIFY

	mov ecx, 0 ; ecx primeste 0, in acest registru vom tine evidenta lungimii vectorului target
			   ; la finalul parcurgerii vectorului a, ptr_len primeste valoarea finala a lui ecx
	mov eax, 0 ; eax primeste 0, in acest registru vom parcurge element cu element vectorul a

start_loop:
	cmp eax, ebx
	jge end_loop ; daca eax are o valoarea mai mare sau egala decat ebx
				 ; (care tine numarul de elemente al vectorului a) se iese din for

	mov edx, dword [esi + eax * 4] ; edx=a[eax]
	test edx, 1 ; verificam daca a[eax] este impar
	jne skip ; in caz afirmativ, trecem peste acest element

	;; urmeaza sa verificam daca numarul este putere a lui 2

	push ebx ; salvam valoarea actuala din ebx
	mov ebx, edx ; in ebx vom avea valoarea lui a[eax]
	sub ebx, 1 ; ebx devine a[eax]-1
	and ebx, edx ; facem & intre a[eax] si a[eax]-1
	test ebx, ebx ; daca rezultatul este 0, programul va intra in skip
	pop ebx ; revenim la valoarea initiala a lui ebx
	je skip

	mov edx, [esi + eax * 4] ; edx = a[eax]
    mov [edi + ecx * 4], edx ; target[ecx] = edx
	add ecx, 1 ; crestem ecx cu 1
	add eax, 1 ; crestem eax cu 1
	jmp start_loop

skip:
	add eax, 1
	jmp start_loop

end_loop:
	mov edx, [ebp + 20] ; facem ca edx sa primeasca cat avea la inceputul programului
	mov [edx], ecx ; ptr_len primeste valoarea finala a lui ecx

	;; DO NOT MODIFY

	popa
	leave
	ret

	;; DO NOT MODIFY
