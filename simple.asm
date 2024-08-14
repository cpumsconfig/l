; 以下是AI的

; simple_os_with_login.asm - 简单操作系统示例，支持echo, help, shutdown命令

org 100h          ; COM 文件起始位置

; 用户名和密码定义
USERNAME db 'admin', 0
PASSWORD db '1234', 0

; 缓冲区
inputUser db 20 dup(0)
inputPass db 20 dup(0)
inputCmd db 20 dup(0)

; 消息
successMsg db '登录成功！', 0Dh, 0Ah, '$'
failMsg db '登录失败！', 0Dh, 0Ah, '$'
helpMsg db '可用命令: echo, help, shutdown', 0Dh, 0Ah, '$'
unknownCmdMsg db '未知命令！', 0Dh, 0Ah, '$'
shutdownMsg db '系统关机...', 0Dh, 0Ah, '$'
errorMsg db '系统错误！', 0Dh, 0Ah, '$'

; 显示消息的函数
print_msg:
    mov ah, 09h
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
    mov dx, offset successMsg
    call print_msg
    jmp command_prompt

fail_login:
    mov dx, offset failMsg
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

; 处理命令
process_command:
    lea si, [inputCmd + 1]  ; 用户输入的命令
    cmp si, 'echo'
    je echo_command
    cmp si, 'help'
    je help_command
    cmp si, 'shutdown'
    je shutdown_command
    jmp unknown_command

echo_command:
    mov dx, offset inputCmd + 1
    call print_msg
    jmp command_prompt

help_command:
    mov dx, offset helpMsg
    call print_msg
    jmp command_prompt

shutdown_command:
    mov dx, offset shutdownMsg
    call print_msg
    ; 关机模拟
    mov ah, 4Ch
    int 21h

unknown_command:
    mov dx, offset unknownCmdMsg
    call print_msg
    jmp command_prompt

command_prompt:
    ; 显示提示符
    mov dx, offset prompt
    call print_msg

    ; 读取用户输入的命令
    call read_input

    ; 处理命令
    call process_command

done:
    ; 退出程序
    mov ah, 4Ch
    int 21h

; 消息和提示符
prompt db '请输入命令: $'

; 程序入口点
start:
    ; 显示提示
    mov dx, offset userPrompt
    call print_msg

    ; 读取用户名
    call read_input

    ; 显示提示
    mov dx, offset passPrompt
    call print_msg

    ; 读取密码
    call read_input

    ; 验证用户名和密码
    call verify_user_pass

    ; 进入命令提示符循环
    jmp command_prompt

userPrompt db '请输入用户名: $'
passPrompt db '请输入密码: $'
