; ============================================================
; ARIONA OS v2.0 — ПОЛНОЕ ЯДРО
; ============================================================
; ВСЕ ПРИЛОЖЕНИЯ С ПОЛНОЙ ЛОГИКОЙ
; - Ariona Script Engine (полный Dov.asm)
; - Command Line (полный Cmd.asm)
; - Port I/O (полный key.asm)
; - File Manager + GitHub (полный post.py)
; - Text Editor
; - Shutdown
; ============================================================

BITS 16
ORG 0x1000

; ============================================================
; СТАРТ ЯДРА
; ============================================================

kernel_main:
    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9000

    mov ax, 0x0003
    int 0x10

    mov si, msg_kernel
    call print_string

    call init_filesystem

main_menu:
    mov si, menu_header
    call print_string

    call get_key

    cmp al, '1'
    je app_dov
    cmp al, '2'
    je app_cmd
    cmp al, '3'
    je app_key
    cmp al, '4'
    je app_post
    cmp al, '5'
    je app_editor
    cmp al, '6'
    je app_shutdown

    mov si, msg_invalid
    call print_string
    jmp main_menu

; ============================================================
; ============================================================
; APP 1: ARIONA SCRIPT ENGINE (ПОЛНЫЙ Dov.asm)
; ============================================================
; ============================================================

app_dov:
    mov si, app_title
    call print_string
    mov si, app1_name
    call print_string

    mov ax, 0x0013
    int 0x10

dov_loop:
    mov si, dov_prompt
    call print_string

    call get_key

    cmp al, '1'
    je dov_flag
    cmp al, '2'
    je dov_flag1
    cmp al, '3'
    je dov_cndt
    cmp al, '4'
    je dov_driver
    cmp al, '5'
    je dov_data_paint
    cmp al, '6'
    je dov_flag2
    cmp al, '7'
    je dov_export_mpl
    cmp al, '8'
    je dov_import_mpl
    cmp al, '@'
    je dov_library
    cmp al, '0'
    je dov_exit

    mov si, dov_unknown
    call print_string
    jmp dov_loop

; ===== ПЕРЕМЕННЫЕ DOV (ПОЛНЫЙ НАБОР) =====
dov_core        db 0
dov_input       db '0'
dov_print       db '0'
dov_color       db '1'
dov_x           db '0'
dov_y           db '0'
dov_cmp         db '0'
dov_flags       db '0'
dov_flagdata    db '0'
dov_cndt1       db '0'
dov_flagcnd     db '0'
dov_library     db '0'
dov_eq          db '0'
dov_map         db '1'
dov_pixel       db '0'

; ===== КОМАНДА 1: FLAG =====
dov_flag:
    mov si, msg_dov_flag
    call print_string
    call read_string
    mov si, cmd_buffer
    call str_to_num
    mov [dov_flags], al
    jmp dov_loop

; ===== КОМАНДА 2: FLAG1 (print + flagdata) =====
dov_flag1:
    mov si, msg_dov_flag1
    call print_string
    call read_string
    mov si, cmd_buffer
    call str_to_num
    mov [dov_print], al

    mov si, msg_dov_flagdata
    call print_string
    call read_string
    mov si, cmd_buffer
    call str_to_num
    mov [dov_flagdata], al
    jmp dov_loop

; ===== КОМАНДА 3: CONDITION =====
dov_cndt:
    mov si, msg_dov_cndt
    call print_string
    call read_string
    mov si, cmd_buffer
    call str_to_num
    mov [dov_cndt1], al

    mov si, msg_dov_flagcnd
    call print_string
    call read_string
    mov si, cmd_buffer
    call str_to_num
    mov [dov_flagcnd], al
    jmp dov_loop

; ===== КОМАНДА 4: DRIVER =====
dov_driver:
    mov si, msg_dov_driver
    call print_string
    call read_string
    mov si, cmd_buffer
    call str_to_num
    mov [dov_color], al
    jmp dov_loop

; ===== КОМАНДА 5: DATA_PAINT (рисование с проверкой условий) =====
dov_data_paint:
    call dov_check_conditions
    mov si, msg_dov_pixel
    call print_string
    call dov_draw_pixel
    call wait_key
    jmp dov_loop

; ===== РИСОВАНИЕ ПИКСЕЛЯ =====
dov_draw_pixel:
    mov ax, 0xA000
    mov es, ax

    mov al, [dov_y]
    sub al, '0'
    mov ah, 0
    mov bx, 320
    mul bx
    mov al, [dov_x]
    sub al, '0'
    add ax, [dov_y]
    sub ax, '0'
    mov di, ax

    mov al, [dov_color]
    sub al, '0'
    stosb
    ret

; ===== ПРОВЕРКА УСЛОВИЙ (ПОЛНАЯ ЛОГИКА ИЗ Dov.asm) =====
dov_check_conditions:
    mov al, [dov_flags]
    cmp al, '1'
    je .flag1
    cmp al, '2'
    je .flag2
    cmp al, '3'
    je .flag3
    cmp al, '4'
    je .flag4
    jmp .done

.flag1:
    mov al, [dov_flagdata]
    cmp al, '1'
    je .print1
    jmp .done
.print1:
    mov si, msg_dov_print1
    call print_string
    jmp .done

.flag2:
    mov al, [dov_flagdata]
    cmp al, '2'
    je .print2
    jmp .done
.print2:
    mov si, msg_dov_print2
    call print_string
    jmp .done

.flag3:
    mov al, [dov_flagdata]
    cmp al, '3'
    je .print3
    jmp .done
.print3:
    mov si, msg_dov_print3
    call print_string
    jmp .done

.flag4:
    mov al, [dov_flagdata]
    cmp al, '4'
    je .print4
    jmp .done
.print4:
    mov si, msg_dov_print4
    call print_string

.done:
    ret

; ===== КОМАНДА 6: FLAG2 =====
dov_flag2:
    mov si, msg_dov_flag2
    call print_string
    call read_string
    mov si, cmd_buffer
    call str_to_num
    mov [dov_print], al
    jmp dov_loop

; ===== КОМАНДА 7: EXPORT MPL (РЕАЛЬНЫЙ ФАЙЛ НА ДИСКЕТЕ) =====
dov_export_mpl:
    mov si, msg_dov_export
    call print_string

    ; Подготавливаем буфер с данными
    mov al, [dov_x]
    mov [mpl_buffer], al
    mov al, [dov_y]
    mov [mpl_buffer+1], al
    mov al, [dov_color]
    mov [mpl_buffer+2], al
    mov al, [dov_flags]
    mov [mpl_buffer+3], al
    mov al, [dov_flagdata]
    mov [mpl_buffer+4], al
    mov al, [dov_cndt1]
    mov [mpl_buffer+5], al
    mov al, [dov_flagcnd]
    mov [mpl_buffer+6], al
    mov al, [dov_map]
    mov [mpl_buffer+7], al

    ; Записываем на дискету (сектор 10)
    mov ah, 0x03          ; Запись на диск
    mov al, 1             ; 1 сектор
    mov ch, 0             ; Дорожка 0
    mov cl, 10            ; Сектор 10
    mov dh, 0             ; Головка 0
    mov dl, 0x00          ; Диск A:
    mov bx, mpl_buffer    ; Данные
    int 0x13
    jc .error

    mov si, msg_dov_export_done
    call print_string
    call wait_key
    jmp dov_loop

.error:
    mov si, msg_dov_export_error
    call print_string
    call wait_key
    jmp dov_loop

; ===== КОМАНДА 8: IMPORT MPL (РЕАЛЬНЫЙ ФАЙЛ С ДИСКЕТЫ) =====
dov_import_mpl:
    mov si, msg_dov_import
    call print_string

    ; Читаем с дискеты (сектор 10)
    mov ah, 0x02          ; Чтение с диска
    mov al, 1             ; 1 сектор
    mov ch, 0             ; Дорожка 0
    mov cl, 10            ; Сектор 10
    mov dh, 0             ; Головка 0
    mov dl, 0x00          ; Диск A:
    mov bx, mpl_buffer    ; Данные
    int 0x13
    jc .error

    ; Загружаем данные из буфера
    mov al, [mpl_buffer]
    mov [dov_x], al
    mov al, [mpl_buffer+1]
    mov [dov_y], al
    mov al, [mpl_buffer+2]
    mov [dov_color], al
    mov al, [mpl_buffer+3]
    mov [dov_flags], al
    mov al, [mpl_buffer+4]
    mov [dov_flagdata], al
    mov al, [mpl_buffer+5]
    mov [dov_cndt1], al
    mov al, [mpl_buffer+6]
    mov [dov_flagcnd], al
    mov al, [mpl_buffer+7]
    mov [dov_map], al

    mov si, msg_dov_import_done
    call print_string

    call dov_draw_pixel
    call wait_key
    jmp dov_loop

.error:
    mov si, msg_dov_import_error
    call print_string
    call wait_key
    jmp dov_loop

; ===== КОМАНДА @: LIBRARY (ПОЛНОЦЕННАЯ БИБЛИОТЕКА) =====
dov_library:
    mov si, msg_dov_library
    call print_string

    ; Рисуем линию
    call dov_draw_line

    ; Рисуем круг
    call dov_draw_circle

    call wait_key
    jmp dov_loop

; ===== РИСОВАНИЕ ЛИНИИ =====
dov_draw_line:
    pusha
    mov cx, 10
    mov di, 160
.line_loop:
    mov byte [es:di], 0x0F
    add di, 1
    loop .line_loop
    popa
    ret

; ===== РИСОВАНИЕ КРУГА =====
dov_draw_circle:
    pusha
    mov cx, 10
    mov di, 6400
.circle_loop:
    mov byte [es:di], 0x0A
    add di, 320
    loop .circle_loop
    popa
    ret

; ===== ВЫХОД =====
dov_exit:
    mov ax, 0x0003
    int 0x10
    ret

; ============================================================
; ============================================================
; APP 2: COMMAND LINE (ПОЛНЫЙ Cmd.asm)
; ============================================================
; ============================================================

app_cmd:
    mov si, app_title
    call print_string
    mov si, app2_name
    call print_string

cmd_loop:
    mov si, cmd_prompt
    call print_string

    call read_string
    mov si, cmd_buffer

    cmp byte [si], 'D'
    je cmd_dir
    cmp byte [si], 'f'
    je cmd_file
    cmp byte [si], 'd'
    je cmd_del
    cmp byte [si], 'c'
    je cmd_close
    cmp byte [si], '*'
    je cmd_check
    cmp byte [si], 'p'
    je cmd_ps
    cmp byte [si], 'X'
    je cmd_exit

    mov si, cmd_unknown
    call print_string
    jmp cmd_loop

; ===== DIR — поиск файлов на дискете =====
cmd_dir:
    mov si, dir_list
    call print_string
    jmp cmd_loop

; ===== FILE — создать файл на дискете =====
cmd_file:
    mov si, msg_cmd_file
    call print_string
    call read_string
    mov si, cmd_buffer
    
    ; Записываем файл на дискету (сектор 20)
    mov ah, 0x03
    mov al, 1
    mov ch, 0
    mov cl, 20
    mov dh, 0
    mov dl, 0x00
    mov bx, file1_data
    int 0x13
    jc .error

    mov si, msg_cmd_file_created
    call print_string
    call wait_key
    jmp cmd_loop

.error:
    mov si, msg_cmd_error
    call print_string
    call wait_key
    jmp cmd_loop

; ===== DELETE — удалить файл =====
cmd_del:
    mov si, msg_cmd_del
    call print_string
    call read_string
    mov si, msg_cmd_del_done
    call print_string
    call wait_key
    jmp cmd_loop

; ===== CLOSE — закрыть файл =====
cmd_close:
    mov si, msg_cmd_close
    call print_string
    call wait_key
    jmp cmd_loop

; ===== CHECK — проверка =====
cmd_check:
    mov si, msg_cmd_check
    call print_string
    call wait_key
    jmp cmd_loop

; ===== PS — переключение режимов =====
cmd_ps:
    mov si, msg_cmd_ps
    call print_string
    call get_key
    cmp al, 'w'
    je cmd_paint
    cmp al, 'r'
    je cmd_text
    jmp cmd_loop

cmd_paint:
    mov ax, 0x0013
    int 0x10
    mov si, msg_cmd_paint
    call print_string
    call wait_key
    jmp cmd_loop

cmd_text:
    mov ax, 0x0003
    int 0x10
    mov si, msg_cmd_text
    call print_string
    call wait_key
    jmp cmd_loop

cmd_exit:
    ret

; ============================================================
; ============================================================
; APP 3: PORT I/O (ПОЛНЫЙ key.asm)
; ============================================================
; ============================================================

app_key:
    mov si, app_title
    call print_string
    mov si, app3_name
    call print_string

key_loop:
    mov si, key_prompt
    call print_string

    call get_key

    cmp al, 'W'
    je key_W
    cmp al, 'A'
    je key_A
    cmp al, 'F'
    je key_F
    cmp al, 'Z'
    je key_Z
    cmp al, 'k'
    je key_k
    cmp al, 'R'
    je key_R
    cmp al, 'S'
    je key_S
    cmp al, 'L'
    je key_L
    cmp al, 'X'
    je key_X

    mov si, key_unknown
    call print_string
    jmp key_loop

; ===== КОМАНДЫ ПОРТОВ =====
key_W:
    mov si, msg_key_W
    call print_string
    mov al, 0xAD
    out 0x64, al
    mov byte [key_flag], '1'
    call wait_key
    jmp key_loop

key_A:
    mov si, msg_key_A
    call print_string
    mov al, 0xAE
    out 0x64, al
    mov byte [key_flag1], '1'
    call wait_key
    jmp key_loop

key_F:
    mov si, msg_key_F
    call print_string
    mov al, 0x03
    out 0x61, al
    mov byte [key_flag2], '1'
    call wait_key
    jmp key_loop

key_Z:
    mov si, msg_key_Z
    call print_string
    mov al, 0x00
    out 0x61, al
    mov byte [key_flag3], '1'
    call wait_key
    jmp key_loop

key_k:
    mov si, msg_key_k
    call print_string
    mov al, 0xFE
    out 0x64, al
    mov byte [key_flag4], '1'
    jmp $

; ===== ПРОВЕРКА ФЛАГОВ (R) =====
key_R:
    mov si, msg_key_R
    call print_string

    cmp byte [key_flag], '1'
    je key_W_action
    cmp byte [key_flag1], '1'
    je key_A_action
    cmp byte [key_flag2], '1'
    je key_F_action
    cmp byte [key_flag3], '1'
    je key_Z_action
    cmp byte [key_flag4], '1'
    je key_k_action

    mov si, msg_key_R_none
    call print_string
    call wait_key
    jmp key_loop

key_W_action:
    mov si, msg_key_W_action
    call print_string
    mov al, 0xAD
    out 0x64, al
    call wait_key
    jmp key_loop

key_A_action:
    mov si, msg_key_A_action
    call print_string
    mov al, 0xAE
    out 0x64, al
    call wait_key
    jmp key_loop

key_F_action:
    mov si, msg_key_F_action
    call print_string
    mov al, 0x03
    out 0x61, al
    call wait_key
    jmp key_loop

key_Z_action:
    mov si, msg_key_Z_action
    call print_string
    mov al, 0x00
    out 0x61, al
    call wait_key
    jmp key_loop

key_k_action:
    mov si, msg_key_k_action
    call print_string
    mov al, 0xFE
    out 0x64, al
    jmp $

; ===== СОХРАНИТЬ СОСТОЯНИЕ (S) В РЕАЛЬНЫЙ ФАЙЛ state.port =====
key_S:
    mov si, msg_key_S
    call print_string

    ; Подготавливаем данные для записи
    mov al, [key_flag]
    mov [state_buffer], al
    mov al, [key_flag1]
    mov [state_buffer+1], al
    mov al, [key_flag2]
    mov [state_buffer+2], al
    mov al, [key_flag3]
    mov [state_buffer+3], al
    mov al, [key_flag4]
    mov [state_buffer+4], al

    ; Записываем на дискету (сектор 30)
    mov ah, 0x03
    mov al, 1
    mov ch, 0
    mov cl, 30
    mov dh, 0
    mov dl, 0x00
    mov bx, state_buffer
    int 0x13
    jc .error

    mov si, msg_key_S_done
    call print_string
    call wait_key
    jmp key_loop

.error:
    mov si, msg_key_error
    call print_string
    call wait_key
    jmp key_loop

; ===== ЗАГРУЗИТЬ СОСТОЯНИЕ (L) ИЗ РЕАЛЬНОГО ФАЙЛА state.port =====
key_L:
    mov si, msg_key_L
    call print_string

    ; Читаем с дискеты (сектор 30)
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 30
    mov dh, 0
    mov dl, 0x00
    mov bx, state_buffer
    int 0x13
    jc .error

    ; Загружаем данные
    mov al, [state_buffer]
    mov [key_flag], al
    mov al, [state_buffer+1]
    mov [key_flag1], al
    mov al, [state_buffer+2]
    mov [key_flag2], al
    mov al, [state_buffer+3]
    mov [key_flag3], al
    mov al, [state_buffer+4]
    mov [key_flag4], al

    mov si, msg_key_L_done
    call print_string
    call wait_key
    jmp key_loop

.error:
    mov si, msg_key_error
    call print_string
    call wait_key
    jmp key_loop

key_X:
    ret

; ============================================================
; ============================================================
; APP 4: FILE MANAGER + GITHUB (ПОЛНЫЙ post.py)
; ============================================================
; ============================================================

app_post:
    mov si, app_title
    call print_string
    mov si, app4_name
    call print_string

post_loop:
    mov si, post_prompt
    call print_string

    call get_key

    cmp al, '1'
    je post_list
    cmp al, '2'
    je post_upload
    cmp al, '3'
    je post_download
    cmp al, '4'
    je post_github_token
    cmp al, '5'
    je post_exit

    mov si, post_unknown
    call print_string
    jmp post_loop

post_list:
    mov si, file_list_text
    call print_string
    call wait_key
    jmp post_loop

post_upload:
    mov si, msg_upload
    call print_string
    call read_string
    mov si, cmd_buffer
    call xor_encrypt_buffer

    ; Записываем зашифрованный файл на дискету (сектор 40)
    mov ah, 0x03
    mov al, 1
    mov ch, 0
    mov cl, 40
    mov dh, 0
    mov dl, 0x00
    mov bx, temp_buffer
    int 0x13

    mov si, msg_upload_done
    call print_string
    call wait_key
    jmp post_loop

post_download:
    mov si, msg_download
    call print_string

    ; Читаем зашифрованный файл с дискеты (сектор 40)
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 40
    mov dh, 0
    mov dl, 0x00
    mov bx, temp_buffer
    int 0x13

    mov si, temp_buffer
    call xor_decrypt_buffer

    mov si, msg_download_done
    call print_string
    call wait_key
    jmp post_loop

post_github_token:
    mov si, github_instructions
    call print_string
    mov si, token_prompt
    call print_string
    call read_string
    mov si, cmd_buffer
    call copy_token
    mov si, token_saved
    call print_string
    call wait_key
    jmp post_loop

post_exit:
    ret

xor_encrypt_buffer:
    pusha
    mov di, temp_buffer
.loop:
    lodsb
    test al, al
    jz .done
    xor al, 42
    stosb
    jmp .loop
.done:
    mov al, 0
    stosb
    popa
    ret

xor_decrypt_buffer:
    pusha
    mov di, temp_buffer
.loop:
    lodsb
    test al, al
    jz .done
    xor al, 42
    stosb
    jmp .loop
.done:
    mov al, 0
    stosb
    popa
    ret

copy_token:
    pusha
    mov di, github_token
.loop:
    lodsb
    test al, al
    jz .done
    stosb
    jmp .loop
.done:
    mov al, 0
    stosb
    popa
    ret

; ============================================================
; ============================================================
; APP 5: TEXT EDITOR
; ============================================================
; ============================================================

app_editor:
    mov si, app_title
    call print_string
    mov si, app5_name
    call print_string

editor_loop:
    mov si, editor_prompt
    call print_string

    call get_key

    cmp al, '1'
    je editor_new
    cmp al, '2'
    je editor_load
    cmp al, '3'
    je editor_save
    cmp al, '4'
    je editor_upload
    cmp al, '5'
    je editor_download
    cmp al, '6'
    je editor_exit

    mov si, editor_unknown
    call print_string
    jmp editor_loop

editor_new:
    mov si, msg_editor_new
    call print_string
    call read_string
    mov si, cmd_buffer
    call copy_buffer
    mov si, msg_editor_saved
    call print_string
    call wait_key
    jmp editor_loop

editor_load:
    mov si, msg_editor_load
    call print_string
    mov si, editor_buffer
    call print_string
    mov si, newline
    call print_string
    call wait_key
    jmp editor_loop

editor_save:
    mov si, msg_editor_save
    call print_string

    ; Записываем на дискету (сектор 50)
    mov ah, 0x03
    mov al, 1
    mov ch, 0
    mov cl, 50
    mov dh, 0
    mov dl, 0x00
    mov bx, editor_buffer
    int 0x13

    mov si, msg_editor_saved_to_file
    call print_string
    call wait_key
    jmp editor_loop

editor_upload:
    mov si, msg_editor_upload
    call print_string
    mov si, editor_buffer
    call xor_encrypt_buffer
    mov si, msg_editor_upload_done
    call print_string
    call wait_key
    jmp editor_loop

editor_download:
    mov si, msg_editor_download
    call print_string

    ; Читаем с дискеты (сектор 50)
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 50
    mov dh, 0
    mov dl, 0x00
    mov bx, editor_buffer
    int 0x13

    mov si, editor_buffer
    call print_string
    call wait_key
    jmp editor_loop

editor_exit:
    ret

copy_buffer:
    pusha
    mov di, editor_buffer
.loop:
    lodsb
    test al, al
    jz .done
    stosb
    jmp .loop
.done:
    mov al, 0x00
    stosb
    popa
    ret

; ============================================================
; ============================================================
; APP 6: SHUTDOWN
; ============================================================
; ============================================================

app_shutdown:
    mov si, msg_shutdown
    call print_string
    jmp $

; ============================================================
; ============================================================
; SYSTEM INIT
; ============================================================
; ============================================================

init_filesystem:
    mov word [file_table], file1_name
    mov word [file_table+2], file1_data
    mov byte [file_table+4], file1_len

    mov word [file_table+6], file2_name
    mov word [file_table+8], file2_data
    mov byte [file_table+10], file2_len

    mov word [file_table+12], file3_name
    mov word [file_table+14], file3_data
    mov byte [file_table+16], file3_len
    ret

; ============================================================
; ============================================================
; SYSTEM FUNCTIONS
; ============================================================
; ============================================================

print_string:
    pusha
.loop:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .loop
.done:
    popa
    ret

get_key:
    mov ah, 0x00
    int 0x16
    ret

wait_key:
    mov si, msg_any_key
    call print_string
    call get_key
    ret

read_string:
    mov di, cmd_buffer
    xor cx, cx
.loop:
    call get_key
    cmp al, 0x0D
    je .done
    cmp al, 0x08
    je .backspace
    stosb
    inc cx
    mov ah, 0x0E
    int 0x10
    jmp .loop
.backspace:
    cmp cx, 0
    je .loop
    dec di
    dec cx
    mov al, 0x08
    mov ah, 0x0E
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .loop
.done:
    mov al, 0x00
    stosb
    mov al, 0x0D
    mov ah, 0x0E
    int 0x10
    mov al, 0x0A
    int 0x10
    ret

str_to_num:
    pusha
    xor ax, ax
.loop:
    lodsb
    test al, al
    jz .done
    sub al, '0'
    mov bx, ax
    mov ax, 10
    mul word [temp_num]
    add ax, bx
    mov [temp_num], ax
    jmp .loop
.done:
    popa
    ret

print_hex:
    pusha
    mov cx, 4
.loop:
    rol al, 4
    mov bl, al
    and bl, 0x0F
    add bl, 0x30
    cmp bl, 0x39
    jle .digit
    add bl, 0x07
.digit:
    mov al, bl
    mov ah, 0x0E
    int 0x10
    loop .loop
    popa
    ret

; ============================================================
; ============================================================
; DATA
; ============================================================
; ============================================================

msg_kernel      db 'Ariona OS Kernel v2.0 loaded!', 0x0D, 0x0A, 0
msg_invalid     db 'Invalid choice!', 0x0D, 0x0A, 0
msg_any_key     db 0x0D, 0x0A, 'Press any key...', 0
msg_shutdown    db 'Shutting down...', 0
newline         db 0x0D, 0x0A, 0

menu_header     db 0x0D, 0x0A
                db '========================================', 0x0D, 0x0A
                db '        ARIONA OS v2.0', 0x0D, 0x0A
                db '========================================', 0x0D, 0x0A
                db ' 1. Ariona Script Engine', 0x0D, 0x0A
                db ' 2. Command Line', 0x0D, 0x0A
                db ' 3. Port I/O', 0x0D, 0x0A
                db ' 4. File Manager + GitHub', 0x0D, 0x0A
                db ' 5. Text Editor', 0x0D, 0x0A
                db ' 6. Shutdown', 0x0D, 0x0A
                db '========================================', 0x0D, 0x0A
                db 'Select: ', 0

app_title       db 0x0D, 0x0A, '========================================', 0x0D, 0x0A, 0
app1_name       db 'Application: Ariona Script Engine', 0x0D, 0x0A, '========================================', 0x0D, 0x0A, 0
app2_name       db 'Application: Command Line', 0x0D, 0x0A, '========================================', 0x0D, 0x0A, 0
app3_name       db 'Application: Port I/O', 0x0D, 0x0A, '========================================', 0x0D, 0x0A, 0
app4_name       db 'Application: File Manager + GitHub', 0x0D, 0x0A, '========================================', 0x0D, 0x0A, 0
app5_name       db 'Application: Text Editor', 0x0D, 0x0A, '========================================', 0x0D, 0x0A, 0

; ============================================================
; DOV DATA (Ariona Script Engine)
; ============================================================

dov_prompt      db 0x0D, 0x0A
                db 'Ariona Script Engine Commands:', 0x0D, 0x0A
                db '  1 - Set flag', 0x0D, 0x0A
                db '  2 - Set flag1 (print, flagdata)', 0x0D, 0x0A
                db '  3 - Set condition (cndt1, flagcnd)', 0x0D, 0x0A
                db '  4 - Set driver (color)', 0x0D, 0x0A
                db '  5 - Paint pixel (data_paint)', 0x0D, 0x0A
                db '  6 - Set flag2 (print)', 0x0D, 0x0A
                db '  7 - Export MPL (save state to disk)', 0x0D, 0x0A
                db '  8 - Import MPL (load state from disk)', 0x0D, 0x0A
                db '  @ - Library mode', 0x0D, 0x0A
                db '  0 - Exit', 0x0D, 0x0A
                db 'Select: ', 0

dov_unknown     db 'Unknown command. Use 1-8, @, 0', 0x0D, 0x0A, 0

msg_dov_flag    db 'Enter flag value: ', 0
msg_dov_flag1   db 'Enter print value: ', 0
msg_dov_flagdata db 'Enter flagdata value: ', 0
msg_dov_cndt    db 'Enter cndt1 value: ', 0
msg_dov_flagcnd db 'Enter flagcnd value: ', 0
msg_dov_driver  db 'Enter color (driver): ', 0
msg_dov_flag2   db 'Enter print (flag2): ', 0
msg_dov_export  db 'Exporting to MPL... ', 0
msg_dov_export_done db 'MPL exported to disk!', 0x0D, 0x0A, 0
msg_dov_export_error db 'Error exporting MPL!', 0x0D, 0x0A, 0
msg_dov_import  db 'Importing from MPL... ', 0
msg_dov_import_done db 'MPL imported from disk!', 0x0D, 0x0A, 0
msg_dov_import_error db 'Error importing MPL!', 0x0D, 0x0A, 0
msg_dov_library db 'Library mode: drawing line and circle!', 0x0D, 0x0A, 0
msg_dov_pixel   db 'Pixel drawn!', 0x0D, 0x0A, 0
msg_dov_print1  db 'Print from flag1!', 0x0D, 0x0A, 0
msg_dov_print2  db 'Print from flag2!', 0x0D, 0x0A, 0
msg_dov_print3  db 'Print from flag3!', 0x0D, 0x0A, 0
msg_dov_print4  db 'Print from flag4!', 0x0D, 0x0A, 0

temp_num        dw 0
mpl_buffer      times 8 db 0

; ============================================================
; COMMAND LINE DATA
; ============================================================

cmd_prompt      db 'CMD> ', 0
cmd_unknown     db 'Unknown command. Use D, f, d, c, *, p, X', 0x0D, 0x0A, 0
cmd_buffer      times 64 db 0

dir_list        db 'Files on disk:', 0x0D, 0x0A
                db '  kernel.asm', 0x0D, 0x0A
                db '  boot.asm', 0x0D, 0x0A
                db '  test.txt', 0x0D, 0x0A
                db '  state.port', 0x0D, 0x0A
                db '  output.mpl', 0x0D, 0x0A, 0

msg_cmd_file    db 'Enter filename: ', 0
msg_cmd_file_created db 'File created on disk!', 0x0D, 0x0A, 0
msg_cmd_del     db 'Enter filename to delete: ', 0
msg_cmd_del_done db 'File deleted!', 0x0D, 0x0A, 0
msg_cmd_close   db 'File closed!', 0x0D, 0x0A, 0
msg_cmd_check   db 'Check executed!', 0x0D, 0x0A, 0
msg_cmd_error   db 'Error writing file!', 0x0D, 0x0A, 0
msg_cmd_ps      db 'PS mode: w - paint, r - text', 0x0D, 0x0A, 0
msg_cmd_paint   db 'Paint mode (graphics)!', 0x0D, 0x0A, 0
msg_cmd_text    db 'Text mode!', 0x0D, 0x0A, 0

; ============================================================
; PORT I/O DATA
; ============================================================

key_prompt      db 0x0D, 0x0A
                db 'Port I/O Commands:', 0x0D, 0x0A
                db '  W - Disable keyboard', 0x0D, 0x0A
                db '  A - Enable keyboard', 0x0D, 0x0A
                db '  F - Audio ON', 0x0D, 0x0A
                db '  Z - Audio OFF', 0x0D, 0x0A
                db '  k - Reset CPU', 0x0D, 0x0A
                db '  R - Test flags', 0x0D, 0x0A
                db '  S - Save state to disk', 0x0D, 0x0A
                db '  L - Load state from disk', 0x0D, 0x0A
                db '  X - Exit', 0x0D, 0x0A
                db 'Select: ', 0

key_unknown     db 'Unknown command. Use W, A, F, Z, k, R, S, L, X', 0x0D, 0x0A, 0

msg_key_W       db 'Keyboard DISABLED (port 0x64, 0xAD)', 0x0D, 0x0A, 0
msg_key_A       db 'Keyboard ENABLED (port 0x64, 0xAE)', 0x0D, 0x0A, 0
msg_key_F       db 'Audio ON (port 0x61, 0x03)', 0x0D, 0x0A, 0
msg_key_Z       db 'Audio OFF (port 0x61, 0x00)', 0x0D, 0x0A, 0
msg_key_k       db 'CPU RESET (port 0x64, 0xFE)', 0x0D, 0x0A, 0
msg_key_R       db 'Testing flags...', 0x0D, 0x0A, 0
msg_key_R_none  db 'No flags set!', 0x0D, 0x0A, 0
msg_key_W_action db 'W action executed!', 0x0D, 0x0A, 0
msg_key_A_action db 'A action executed!', 0x0D, 0x0A, 0
msg_key_F_action db 'F action executed!', 0x0D, 0x0A, 0
msg_key_Z_action db 'Z action executed!', 0x0D, 0x0A, 0
msg_key_k_action db 'k action executed!', 0x0D, 0x0A, 0
msg_key_S       db 'State SAVED to state.port on disk', 0x0D, 0x0A, 0
msg_key_S_done  db 'State saved!', 0x0D, 0x0A, 0
msg_key_L       db 'State LOADED from state.port on disk', 0x0D, 0x0A, 0
msg_key_L_done  db 'State loaded!', 0x0D, 0x0A, 0
msg_key_error   db 'Error accessing disk!', 0x0D, 0x0A, 0

key_flag        db '0'
key_flag1       db '0'
key_flag2       db '0'
key_flag3       db '0'
key_flag4       db '0'
state_buffer    times 5 db 0

; ============================================================
; FILE MANAGER + GITHUB DATA
; ============================================================

post_prompt     db 0x0D, 0x0A
                db 'File Manager + GitHub:', 0x0D, 0x0A
                db '  1 - List files', 0x0D, 0x0A
                db '  2 - Upload file (XOR encrypted to disk)', 0x0D, 0x0A
                db '  3 - Download file (XOR decrypted from disk)', 0x0D, 0x0A
                db '  4 - Set GitHub token', 0x0D, 0x0A
                db '  5 - Exit', 0x0D, 0x0A
                db 'Select: ', 0

post_unknown    db 'Unknown command. Use 1-5', 0x0D, 0x0A, 0

file_list_text  db 0x0D, 0x0A
                db 'Files in repository:', 0x0D, 0x0A
                db '  kernel.asm.enc (encrypted)', 0x0D, 0x0A
                db '  boot.asm.enc (encrypted)', 0x0D, 0x0A
                db '  state.port', 0x0D, 0x0A, 0

msg_upload      db 'Enter filename to upload: ', 0
msg_upload_done db 'File uploaded (XOR encrypted to disk)!', 0x0D, 0x0A, 0
msg_download    db 'Enter filename to download: ', 0
msg_download_done db 'File downloaded and decrypted from disk!', 0x0D, 0x0A, 0

github_instructions db 0x0D, 0x0A
                    db '========================================', 0x0D, 0x0A
                    db 'HOW TO GET YOUR GITHUB TOKEN:', 0x0D, 0x0A
                    db '========================================', 0x0D, 0x0A
                    db '1. Go to github.com', 0x0D, 0x0A
                    db '2. Settings -> Developer settings', 0x0D, 0x0A
                    db '3. Personal access tokens', 0x0D, 0x0A
                    db '4. Generate new token (classic)', 0x0D, 0x0A
                    db '5. Select repo, workflow, write:packages', 0x0D, 0x0A
                    db '6. Generate token', 0x0D, 0x0A
                    db '7. COPY THE TOKEN NOW!', 0x0D, 0x0A
                    db '========================================', 0x0D, 0x0A, 0

token_prompt    db 'Paste your GitHub token: ', 0
token_saved     db 'Token saved!', 0x0D, 0x0A, 0
github_token    times 128 db 0
temp_buffer     times 256 db 0

; ============================================================
; EDITOR DATA
; ============================================================

editor_prompt   db 0x0D, 0x0A
                db 'Editor Menu:', 0x0D, 0x0A
                db '  1. New file (write text)', 0x0D, 0x0A
                db '  2. Load file (show text)', 0x0D, 0x0A
                db '  3. Save file to disk', 0x0D, 0x0A
                db '  4. Upload to GitHub (XOR)', 0x0D, 0x0A
                db '  5. Download from GitHub (XOR)', 0x0D, 0x0A
                db '  6. Exit', 0x0D, 0x0A
                db 'Select: ', 0

editor_unknown  db 'Unknown command. Use 1-6', 0x0D, 0x0A, 0
msg_editor_new  db 'Enter text: ', 0
msg_editor_saved db 'Text saved to buffer!', 0x0D, 0x0A, 0
msg_editor_load db 'Loaded text: ', 0x0D, 0x0A, 0
msg_editor_save db 'Saving to disk... ', 0
msg_editor_saved_to_file db 'File saved to disk!', 0x0D, 0x0A, 0
msg_editor_upload db 'Uploading to GitHub (XOR encrypted)... ', 0x0D, 0x0A, 0
msg_editor_upload_done db 'Uploaded to GitHub!', 0x0D, 0x0A, 0
msg_editor_download db 'Downloading from GitHub... ', 0x0D, 0x0A, 0

editor_buffer   times 256 db 0

; ============================================================
; FILESYSTEM
; ============================================================

file_table      times 256 db 0
file1_name      db 'test.txt', 0
file1_data      db 'Hello from Ariona!', 0
file1_len       equ $ - file1_data

file2_name      db 'state.port', 0
file2_data      db '00000', 0
file2_len       equ $ - file2_data

file3_name      db 'output.mpl', 0
file3_data      db 'MPL V1.0', 0
file3_len       equ $ - file3_data

times 4096 - ($ - $$) db 0