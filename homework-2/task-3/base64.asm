%include "../include/io.mac"

extern printf
global base64

section .data
	alphabet db 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
	fmt db "%d", 10, 0

section .bss
	contor resd 1 ; in variabila contor calculam numarul de caractere obtinut dupa criptare
	i resd 1 ; cu ajutorul variabilei i ne plimbam prin vectorul cu caractere necriptate
	lungime resd 1 ; in variabila lungime retinem valoarea n, intrucat registrul
				   ; ebx care retine valoarea va fi corupt dupa primul loop

section .text

base64:
	;; DO NOT MODIFY

    push ebp
    mov ebp, esp
	pusha

	mov esi, [ebp + 8] ; adresa vectorului sursa (a lui a)
	mov ebx, [ebp + 12] ; n
	mov edi, [ebp + 16] ; adresa vectorului destinatie (a lui target)
	mov edx, [ebp + 20] ; pointer la ptr_len

	;; DO NOT MODIFY
	; -- Your code starts here --

	mov eax, 0
	mov ecx, 0
	mov dword [i], 0 ; in lipsa de registre, am initializat in .bss variabila i
					 ; care va fi folosita pentru a parcurge cate 3 caractere
	mov dword [contor], 0 ; in variabila contor declarata in .bss calculam
						  ; numarul final de caractere rezultate dupa criptare
	mov dword [lungime], ebx ; in variabila lungime punem valoarea n
							 ; nu putem lucra in mod direct cu ebx intrucat valoarea
							 ; acestuia va fi corupta imediat dupa primul loop

start_loop:
	mov eax, dword [lungime]
	cmp dword [i], eax
	jge end_loop

	;; formam grupuri de cate 3 caractere (fiecare ocupand cate 8 biti) pe care
	;; dorim sa le punem intr-un registru de 24 de biti
	;; fiecare litera se va salva intr-un registru, iar la final toate se vor
	;; concatena intr-unul singur cu ajutorul instructiunii or

	movzx eax, byte [esi] ; salvam in eax primul caracter
	movzx ebx, byte [esi + 1] ; salvam in ebx al doilea caracter
	movzx ecx, byte [esi + 2] ; salvam in ecx al treilea caracter

	shl eax, 16 ; shiftam eax cu 16 pozitii la stanga iar restul se completeaza cu zero-uri

	shl ebx, 8 ; shiftam ebx cu 8 pozitii la stanga iar restul se completeaza cu zero-uri
	or eax, ebx ; facem 'sau' intre cele doua registre ca sa le concatenam
				; rezultatul se salveaza in eax

	or eax, ecx ; facem 'sau' intre cele doua registre ca sa le concatenam

;; criptam primul caracter
	mov ebx, eax ; copiem valoarea rezultata in registrul ebx
	shr ebx, 18 ; shiftam ebx cu 18 pozitii la dreapta pentru a pastra doar valoarea
				; caracterului respectiv iar restul se completeaza cu zero-uri

	;; lucrand cu cate 6 biti, luam valoarea 63 = 0011 1111 -> masca de 6 biti
	;; facand and intre cele ebx si 63, salvam doar ultimii 6 biti
	and ebx, 63
	mov bl, [alphabet + ebx] ; se ia de la inceputul lui alphabet si se ajunge
							 ; la pozitia ebx din sirul declarat in .data
							 ; astfel aflam caracterul obtinut dupa codificare
	mov [edi], bl ; adaugam caracterul obtinut dupa codificare in edi

;; criptam al doilea caracter
	mov ebx, eax
	shr ebx, 12 ; shiftam ebx cu 12 pozitii la dreapta pentru a pastra doar valoarea
				; caracterului respectiv iar restul se completeaza cu zero-uri
	and ebx, 63
	mov bl, [alphabet + ebx]
	mov [edi + 1], bl ; adaugam caracterul obtinut dupa codificare in edi

;; criptam al treilea caracter
	mov ebx, eax
	shr ebx, 6 ; shiftam ebx cu 6 pozitii la dreapta pentru a pastra doar valoarea
			   ; caracterului respectiv iar restul se completeaza cu zero-uri
	and ebx, 63
	mov bl, [alphabet + ebx]
	mov [edi + 2], bl ; adaugam caracterul obtinut dupa codificare in edi

;; criptam al patrulea caracter
	mov ebx, eax
	and ebx, 63
	mov bl, [alphabet + ebx]
	mov [edi + 3], bl ; adaugam caracterul obtinut dupa codificare in edi

	add dword [contor], 4 ; in variabila contor adaugam 4 caractere, intrucat
						  ; fiecare grup de 3 * 8 biti = 24 se transforma in 4
						  ; caractere de forma 4 * 6
	add esi, 3 ; mutam registrul cu 3 pozitii inainte, intrucat am convertit primele 3
			   ; caractere din string
	add dword [i], 3 ; adunam +3 pentru a continua for-ul
	add edi, 4 ; avansam cu 4 caractere in vectorul target
	jmp start_loop

end_loop:
	mov edx, [ebp + 20] ; facem ca edx sa primeasca cat avea la inceputul programului
	mov ecx, dword [contor]
	mov [edx], ecx ; ptr_len primeste valoarea finala a lui ecx
	; -- Your code ends here --


	;; DO NOT MODIFY

	popa
	leave
	ret

	;; DO NOT MODIFY