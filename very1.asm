; simple_os_with_login_and_file.asm - 简单操作系统示例，支持echo, help, shutdown命令，显示中文和读取文件

org 100h          ; COM 文件起始位置

; 用户名和密码定义
USERNAME db 'admin', 0
PASSWORD db '1234', 0

; 缓冲区
inputUser db 20 dup(0)
inputPass db 20 dup(0)
inputCmd db 20 dup(0)

; 消息
welcomeFile db 'welcome.txt$', 0
welcomeMsg db '欢迎使用简单操作系统！', 0Dh, 0Ah, '$'
helpMsg db '可用命令: echo, help, shutdown', 0Dh, 0Ah, '$'
unknownCmdMsg db '未知命令！', 0Dh, 0Ah, '$'
shutdownMsg db '系统关机...', 0Dh, 0Ah, '$'
errorMsg db '系统错误！', 0Dh, 0Ah, '$'

; 显示消息的函数
print_msg:
    mov ah, 09h
    int 21h
    ret

; 读取文件的函数
read_file:
    mov ah, 3Dh        ; 打开文件
    mov al, 0          ; 只读模式
    lea dx, [welcomeFile]
    int 21h
    mov bx, ax         ; 保存文件句柄

    mov ah, 3Fh        ; 读文件
    mov cx, 255        ; 读取最大长度
    lea dx, [inputCmd] ; 缓冲区
    int 21h
    mov ah, 3Eh        ; 关闭文件
    int 21h

    ret

; 读入用户输入的函数
read_input:
    mov ah, 0Ah
    int 21h
    ret

; 验证用户名和密码
verify_user_pass:
    lea si, [inputUser + 1]  ; 用户输入的用户名
    lea di, [USERNAME]      ; 预定义的用户名
    call compare_strings
    jne fail_login

    lea si, [inputPass + 1]  ; 用户输入的密码
    lea di, [PASSWORD]      ; 预定义的密码
    call compare_strings
    jne fail_login

    ; 成功
    mov dx, offset welcomeMsg
    call print_msg
    call read_file
    mov dx, offset inputCmd
    call print_msg
    jmp command_prompt

fail_login:
    mov dx, offset errorMsg
    call print_msg
    jmp done

; 字符串比较函数
compare_strings:
    mov cl, 0                ; 初始化比较结果为0（相同）
    repe cmpsb              ; 比较字符串
    jne not_equal           ; 如果不相等，跳转到 not_equal
    ret

not_equal:
    mov cl, 1                ; 设置比较结果为1（不同）
    ret
