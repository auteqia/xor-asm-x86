section .bss
    buffer resb 1024       ; Tampon pour stocker les données du fichier
    key resb 1             ; Stockage de la clé XOR
    filepath resb 256      ; Stockage du chemin du fichier
    bytes_read resq 1      ; Stockage du nombre d'octets lus

section .rodata   ; 📌 Variables constantes
    prompt_file db "Entrez le chemin du fichier : ", 0
    prompt_key db "Entrez une clé de chiffrement (1 caractère) : ", 0
    format_str db "%255s", 0       ; format string pour scanf
    format_char db " %c", 0        ; capture 1 seul caractère, avec espace pour éviter le bug du \n
    read_mode db "rb", 0           ; mode lecture
    write_mode db "wb", 0          ; mode écriture
    error_msg db "[Erreur] : impossible d'ouvrir le fichier", 10, 0
    success_msg db "Le fichier a été correctement traité", 10, 0

section .text
    extern printf, scanf, fopen, fread, fwrite, fclose
    global main

section .text
    extern printf, scanf, fopen, fread, fwrite, fclose
    global main

main:
    push rbp
    mov rbp, rsp

    
    mov rdi, prompt_file ; demande le chemin (max 256 bytes)
    xor rax, rax ; clear
    call printf ; affiche prompt_file
    mov rdi, format_str 
    mov rsi, filepath
    xor rax, rax
    call scanf

    mov rdi, prompt_key ; met le prompt dans rdi
    xor rax, rax ;clear rax
    call printf ;demande la clé de chiffrement
    mov rdi, format_char 
    mov rsi, key
    xor rax, rax
    call scanf ;lis l'entrée utilisateur
    test rax, rax
    jz exit_program


    mov rdi, filepath ;ouverture en lecture du fichier
    mov rsi, read_mode
    call fopen
    test rax, rax
    jz error
    mov r12, rax  ; sauvegarde le pointeur du fichier

read_xor_write_loop:
    mov rdi, buffer ; lire bloc de données
    mov rsi, 1
    mov rdx, 1024
    mov rcx, r12
    call fread     ; retourne le nombre d'octets lus dans RAX 
    test rax, rax
    jz close_file  ; quitter si EOF
    mov [bytes_read], rax  ; Sauvegarde du nombre d'octets lus


    mov rcx, rax
    mov rsi, buffer
    mov al, [key] ; charger la clé XOR

xor_loop:
    test rcx, rcx 
    jz write_file 
    xor byte [rsi], al  ; XOR sur chaque octet du buffer
    inc rsi ; incrémenter l'octet
    loop xor_loop ; loop sur les octets

write_file:
    mov rdi, filepath 
    mov rsi, write_mode ;ouverture du fichier en modification
    call fopen ;appel de fopen pour ouvrir le fichier
    test rax, rax 
    jz error
    mov r13, rax  ; sauvegarder le pointeur du fichier

    mov rdi, buffer ; 
    mov rsi, 1
    mov rdx, [bytes_read]  ;écrire les octets traités 
    mov rcx, r13
    call fwrite ; appel de fwrite

    
    mov rdi, r13
    call fclose ; fermeture du fichier
    jmp read_xor_write_loop;check si fini le fichier

close_file:
    mov rdi, r12
    call fclose ;ferme le fichier
    mov rdi, success_msg ; affiche le message de validation
    call printf
    jmp exit_program ;quit

error:
    mov rdi, error_msg
    call printf

exit_program:
    leave
    ret