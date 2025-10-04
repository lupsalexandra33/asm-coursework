## TEMA 3 PCLP2 : Cosminel cel Pasionat

### Mod de implementare al task-urilor:

1. <ins> Task 1: </ins>
   
Am pus numarul de noduri n in ebx si in ecx pointer la inceput de array. Cum
la finalul functiei trebuie sa returnam in eax pointer catre inceputul listei,
adica catre head, vom considera de la inceput ca in eax vom retine head-ul. In
implementare vom avea nevoie de doua for-uri, unul pentru a parcurge toate
valorile de la 1 la n, iar altul ce contine toate elementele in care il cautam
pe cel curent din primul for ce trebuie pus in lista. Pentru parcurgerea celor
doua loop-uri initializam atat variabila i declarata in .bss cat si edx cu 0. In
cel de-al doilea for, cand gasim elementul ce trebuie adaugat in lista,
verificam daca eax == 0, adica daca nu am mai adaugat niciun element in lista,
caz in care mergem in eticheta primul_element, unde atat head-ul (eax) cat si
tail-ul (edi) primesc adresa elementului respectiv. In cazul in care eax are
deja elemente, reinitializam coada (edi si edi + 4 (next-ul)). In cazul ambelor
etichete, atat primul_element cat si adaugare_nod, la finalul adaugarii
elementului in lista, incrementam variabila i si reinitializam edx cu 0. In cel
de al doilea for, daca v[edx] != i, inseamna ca nu am gasit elementul si
incrementam edx. La finalul for-urilor, intram in eticheta end_loop si iesim din
functie, intrucat rezultatul functiei se afla deja in eax.

3. <ins> Task 2: </ins>

In cadrul acestui task am avut de implementat doua functii: sort si
get_words. Am inceput cu get_words, iar apoi am facut sort. Pentru a rezolva
sort, am mai implementat o functie, comparare_cuvinte.\

Ca variabile, am initializat in .bss variabila i, pe care am folosit-o la
functia get_words.

-> Functia get_words:

Am pus in ebx string-ul, in ecx vectorul de stringuri in care salvam
cuvintele iar in edx am stocat numarul de cuvinte. Am initializat eax cu 0,
intrucat vrem sa comparam cuvintele caracter cu caracter, incepand de la 0.
Punem in edi inceputul string-ului iar in acesta variabila vom retine mereu
pointer catre cuvantul curent. Facem acest lucru intrucat eax va fi
reinitializat cu 0 pentru fiecare cuvant, edi va continua sa creasca pe tot
parcursul verificarii string-ului. Initializam variabila i cu 0, in cadrul ei
vom calcula lungimea cuvantului actual. Initializam si registrul esi cu 0, in
cadrul lui vom contoriza numarul de cuvinte. Intram in eticheta loop_cuvinte, in
care verificam daca ajungem la un delimitator, caz in care intram in eticheta
cuvant_nou. In caz contrar, in eticheta new_char incrementam atat eax, cat si i.
In cazul in care sirul a ajuns la terminatorul de sir, mergem in eticheta
ultimul_cuvant, in care verificam daca variabila i este nenula, caz in care mai
adaugam un cuvant in vector. In momentul identificarii unui delimitator, trecem
in eticheta cuvant_nou, in care adaugam terminatorul de sir cuvantului si
incrementam apoi eax cu 1 pentru a muta cursorul care tine evidenta pe ce
pozitie ne aflam in string cu un caracter inainte. Salvam in vector adresa se
inceput a cuvantului curent, iar apoi mutam pointer-ul catre finalul cuvantului,
adaugand variabila i. Incrementam si edi pentru a fi la acelasi nivel cu eax.
Apoi intram in eticheta verificare_delimitatori, unde vrem sa vedem cati
delimitatori mai exista pana la inceputul urmatorului cuvant, daca mai exista
intram in eticheta repeat, unde incrementam atat eax cat si edi. Cand trecem de
toti delimitatorii, reinitializam variabila i cu 0 pentru a calcula lungimea
noului cuvant, incrementam esi deoarece vrem sa continuam ci urmatorul cuvant
apoi reintram in loop_cuvinte. La finalul codului, in eticheta end_loop,
incarcam in eax adresa primului cuvant din words[0].

-> Functia sort:

In cadrul functiei sort, am pus in ebx vectorul de cuvinte, in ecx
numarul de cuvinte si in edx dimensiunea unui cuvant. Apoi, pentru apelul qsort
am adaugat pe stiva in ordine inversa paramterii necesari: vectorul, numarul de
cuvinte, dimensiunea unui cuvant si functia auxiliara creata, comparare_cuvinte.
In aceasta functie, am luat de pe stiva atat adresa pointerului la primul
cuvant, cat si la cel de al doilea. Pentru ambele obtinem adresa de inceput.
Apoi, vom calcula pe rand lungimea celor doua string-uri, in strlen_1 si
strlen_2. Inainte de intrarea in aceste etichete, initializam edi si esi cu 0
intrucat in ele vom calcula lungimile. Ambele label-uri fac acelasi lucru,
compara daca byte-ul este insusi terminatorul de sir, caz in care in cadrul lui
strlen_1, intram in reatribuire_eax, unde facem eax 0 pentru urmatorul calcul.
In cadrul lui strlen_2, intram in functia comparare_rezultate, in care vrem sa
vedem care din cele doua cuvinte are lungimea mai mare: daca primul cuvant este
mai lung, eax = 1 si iesim din functie, daca al doilea cuvant este mai lung,
eax = -1 si iesim din functie. In cazul in care cele doua cuvinte au aceeasi
lungime, verificam din punct de vedere lexicograifc. Reinitializam edi cu 0
pentru a parcurge cele doua cuvinte litera cu litera. La prima litera diferita,
ne mutam in unul din cele doua label-uri care fac eax 1 sau -1. In cazul in care
am ajuns la finalul cuvantului, inseamna ca cele doua cuvinte sunt egale si
eax = 0. Dupa apelul functiei qsort in functia sort, curatam stiva, iar la final
punem in eax pointer catre adresa de inceput a vectorului de cuvinte sortat.

4. <ins> Task 3: </ins>

In cadrul acestei functii am avut de implementat Fibonacci recursiv, pentru
care stim urmatoarele reguli: pentru n < k => returnam 0 in functia recursiva
(in eax), pentru n == k => returnam 1 in eax, iar pentru n > k => adunam
recursiv ultimii k termeni intr-un for. Astfel, am pus in ebx valoarea lui n, in
edx valoarea lui k, iar apoi am initializat alte doua registre, edi cu 0, in el
vom calcula suma, si ecx cu 1, intrucat urmeaza un for de la 1 la k. Vom calcula
in regsitrul esi n - i, apoi dam push la ecx si edx pentru a nu le corupe
valoarea pe parcursul executiei functiei externe. Punem pe stiva in ordine
inversa parametrii functiei, k, respectiv n - i si apelam recursiv functia kfib.
Dupa executie eliberam stiva si dam pop la registre. Adaugam rezultatul apelului
in suma iar apoi trecem la urmatoarea iteratie. In cazul in care n == k, intram
in eticheta return_k1, unde eax = 1 si se iese apoi din functie prin label-ul
end, iar daca n < k, se intra in return_k0 unde eax = 0 si tot asa se iese din
functie prin apelul etichetei end. La finalul for-ului, intram in eticheta
end_loop, unde salvam in eax rezultatul functiei si iesim din functie.

5. <ins> Task 4: </ins>

In cadrul acestui task am avut de implementat 2 functii, check_palindrome si
composite_palindrome. Pentru cel de al doilea subtask, am implementat in .bss 7
variabile pe care o sa le explic in detaliu cand explic functia. Totodata, tot
pentru acel subtask am apelat de a lungul rezolvarii 6 functii externe: malloc,
strcat, strcmp, strcpy, strlen si free.

-> Functia check_palindrome:

Am pus in eax sirul de caractere si in ebx lungimea sirului, apoi am dat
push la eax intrucat vrem sa-l folosim si in alte scopuri de a lungul functiei.
Astfel, calculam in eax care este jumatatea lungimii sirului, iar apoi
initializam registrul edi cu 0. Dam pop la eax intrucat vrem sa revenim la
valoarea sa initiala, apoi copiem in esi lungimea sirului pe care o scadem cu 1,
intrucat numaratoarea caractelor incepe de la 0 si practic ultimul caracter se
va afla pe pozitia n - 1. Apoi in cadrul unui for comparam caracter cu caracter,
pe cel din prima jumatate daca este echivalent cu cel care ii corespunde din a
doua jumatate. Daca gasim diferente, intram in eticheta nu_e_palindrom, unde
eax = 0 si se iese apoi din functie prin eticheta end_loop. Daca caracterele
sunt identice, intram in eticheta repeat, unde incrementam edi pentru a trece la
urmatorul caracter ce trebuie comparat. In noua bucla, fix inainte de
comparatie, se modifica si esi, acesta fiind decrementat mereu cu valoarea lui
edi. Daca ajungem sa iesim din for deoarece edi >= ecx, inseamna ca string-ul
este palindrom si intram in eticheta e_palindrom, unde il initializam pe eax = 1
si iesim apoi din functie.

-> Functia composite_palindrome:

Inainte de a incepe explicarea codului, voi vorbi despre variabilele
initializate in .bss si voi explica ce rol au ele pe parcursul codului. Pentru
implementarea acestui subtask am folosit metoda mastilor pe biti, astfel avem
variabilele: in rezultat punem lungimea palindromului final, in vectorul lungimi
punem lungimile fiecarui cuvant din vectorul de cuvinte, in rezultat_length
retinem lungimea celui mai lung palindrom gasit pana acum, in p retinem numarul
de submultimi posibile, in cazul nostru 2^15, in copie creem o copie a fiecarei
submultimi posibile, in lungime_string retinem lungimea rezultata din adunarea
cuvintelor prezente in submultimea curenta iar in variabila temp adaugam
concatenarea mastii curente. In ceea ce priveste codul, am inceput prin a pune
in ebx vectorul de cuvinte si in edx numarul de cuvinte din vector. Initializam
atat char *rezultat = NULL, cat si int *lungimi = NULL. Apoi copiem in ecx
numarul de cuvinte din vector, pe care il inmultim apoi cu 4 pentru a obtine
relatia (len * sizeof(int)). Dam push la registre pentru a nu le corupe valoarea
pe parcursul executiei functiei externe, apoi dam push la ecx si apelam functia
malloc, care prin conventie salveaza rezultatul in eax; dam pop la registre iar
apoi punem in variabila lungimi eax-ul, el fiind astfel vectorul in care vom
retine lungimile cuvintelor. Initializam si rezultat_length cu 0, dar si ecx,
intrucat vom aveam nevoie de el in urmatorul for, ce incepe la eticheta
loop_retinere_lungimi_cuvinte. Trecand astfel prin toate cuvintele, salvam in
eax strs[i], apoi dam push la registre pentru a nu le corupe valoarea pe
parcursul executiei functiei externe. Dam push si la eax si apelam strlen, fiind
functie externa eax primeste prin conventie rezultatul functiei, si anume
lungimea lui strs[i], pe care, dupa ce eliberam stiva si dam pop la celelalte
registre, i-o atribuie registrului edi. Ajunsi in eticheta retinere_lungime,
punem in vectorul lungimi la pozitia ecx valoarea salvata in edi, incrementam
ecx, iar apoi repetam procesul pana se iese din for. Odata iesiti din for,
intram in eticheta shiftare, unde calculam 1 << edx, si salvam rezultatul in
variabila p. Initializam ecx cu 1, intrucat vrem sa parcurgem toate mastile de
la 1 pana la p (2^15 = 32768), fiecare masca reprezentand o submultime posibila
de cuvinte din vectorul initial. La fiecare pas in acest for, masca curenta
(reprezentata de valoarea lui ecx) indica ce cuvinte sunt incluse in submultimea
respectiva — daca bitul i al mastii este 1, inseamna ca cuvantul i este prezent
in submultime. In variabila copie facem o copie a mastii curente, iar apoi
initializam variabila lungime_string cu 0, unde calculam suma lungimilor tuturor
cuvintelor incluse in masca curenta. Initializam registrul edi cu 0, intrucat il
vom folosi in urmatorul for, loop_digits, care este de la 0 la [ebp + 12] - 1.
Pentru fiecare cuvant luam variabila copie si verificam daca este impara sau
para, adica daca exista sau nu cuvantul in masca curenta (in ecx). Daca cuvantul
nu este adaugat in masca intram in eticheta next_word_loop, unde punem in eax
variabila copie, impartim variabila la 2 prin shiftare la dreapta pe biti, punem
noua variabila a copiei in copie, iar apoi incrementam edi pentru a trece la
urmatorul cuvant. In caz contrar, intram in suma_lungimi, care adauga in
lungime_string valoarea de pe pozitia edi din vectorul lungimi. Ulterior, tot in
next_word_loop se ajunge pentru a se repeta procesul pentru a verifica toate
cuvintele. Dupa ce iesim din loop_digits, intram in verif_length, unde comparam
lungimea celui mai lung palindrom gasit cu lungimea cuvintelor din masca actuala
=> daca este mai mic lungime_string, nu are rost sa continuam, intram in
eticheta next_masca. In caz contrar, adaugam in registrul eax
lungime_string + 1, dam push la celelalte registre pentru a nu le corupe
valoarea pe parcursul executiei functiei externe, dam push si la eax apoi apelam
functia malloc al carei rezultat se salveaza tot in eax. Curatam stiva si dam
pop la registre, apoi ii atribuim lui temp memoria alocata cu malloc salvata in
eax. Initializam temp[0] = '\0', apoi similar ca la loop_digits, facem o copie
mastii curente in copie, initializam edi cu 0 si intram in loop_concatenare,
unde similar ca la loop_digits verificam daca cuvantul de pe pozitia i se afla
sau nu in masca prin realizarea operatiei and intre masca si 1. Daca cuvantul se
afla in masca, punem in edx cuvantul curent si in eax temp si apelam functia
strcat care ne adauga cuvantul in temp. Curatam stiva, dam pop la registre, apoi
intram in eticheta next_word, in care am fi intrat direct daca cuvantul nu se
afla in masca curenta. Impartim variabila copie la 2 prin shiftare la dreapta pe
biti, punem noua variabila a copiei in copie, apoi incrementam edi pentru a
prelucra urmatorul cuvant. Daca am depasit numarul de cuvante, trebuie sa
adaugam terminatorul de sir concatenarii curente, lucru pe care il facem in
eticheta adauga_terminator_sir, astfel temp[lungime_string] = '\0'. Dam push la
ecx pentru a nu ii corupe valoarea pe parcursul executiei functiei externe, apoi
dam push la cuvantul salvat in temp si la lungimea sa salvata in variabila
lungime_string, si apelam functia realizata anterior, check_palindrome, pentru a
vedea daca concatenarea rezultata este palindrom sau nu. Daca nu este, nu are
rost sa mai continuam, astfel curatam temp in eticheta clean_temp, in caz
contrar verificam daca palindromul nostru este unul mai bun decat cel gasit pana
acum sau nu. Astfel verificam daca lungime_string > rezultat_length, daca da
intram in eticheta alocare_sir, in caz contrar verificam daca au aceeasi
lungime, daca au verificam daca rezultat == NULL,daca este intram in
alocare_sir, daca nu verificam cu strcmp daca noul cuvant gasit este mai mic din
punct de vedere lexicografic. Daca este mai mic, intram in alocare_sir, in caz
contrar conditiile nu se respecta drept urmare palindromul gasit nu este o
optiune mai buna asa ca trecem la urmatoarea masca dar inainte curatam ce se
afla in temp cu free prin label-ul clean_temp. Daca am gasit un string valid,
noul rezultat va deveni acel palindrom. Astfel in alocare_sir, verificam daca
rezultat continea deja un string, daca da ii dam free deoarece vrem sa punem un
string mai bun, daca nu trecem direct la faza de alocare. Punem in eax
lungime_string la care adaugam 1 pentru terminatorul de sir, dam push la
registre pentru a nu le corupe valoarea pe parcursul executiei functiei externe,
si alocam cu malloc rezultat cu (lungime_string + 1). Apoi cu ajutorul functiei
externe strcpy, punem in rezultat palindromul salvat in temp. La final eliberam
temp prin eticheta clean_temp care la final la randul ei ne va trimite in
next_masca unde incrementam ecx-ul si continuam procesul explicat pentru
urmatoarea masca. Odata procesate toate mastile, ajungem in label-ul
palindrom_rezultat, unde vrem sa eliberam continutul vectroului ce retine
lungimile. Inainte vom da push la registre pentru a nu le corupe valoarea pe
parcursul executiei functiei externe, iar dupa apelul functiei le vom da pop. Nu
in cele din urma, punem in eax palindromul rezultat si iesim din functie.

