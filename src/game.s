; void SlinGridCheck(int gridNumber, HWND button);
SlinGridClick:
   sub rsp, 0x28
   mov al, byte [rcx + Grid]
   cmp al, NO_STATE
   jz .Allow
   jmp .Deny

.Allow:
   mov byte [rcx + Grid], O_STATE

   mov rcx, rdx
   mov rdx, WM_SETTEXT
   mov r8, 0
   mov r9, TextO
   call [SendMessageA]

   mov rcx, O_STATE
   call SlinCheckWin
   cmp rax, 1
   je .PlayerWins

   call SlinComputerPlay
   mov rcx, X_STATE
   call SlinCheckWin
   cmp rax, 1
   je .ComputerWins

   jmp .Return

.PlayerWins:
   mov rcx, 0
   mov rdx, YouWin
   mov r8, Congratulations
   mov r9, 0
   call [MessageBoxA]

   mov rcx, 0
   call [ExitProcess]
   jmp .Return

.ComputerWins:
   mov rcx, 0
   mov rdx, YouLose
   mov r8, TryHarder
   mov r9, 0
   call [MessageBoxA]

   mov rcx, 0
   call [ExitProcess]
   jmp .Return

.Deny:
   jmp .Return

.Return:
   add rsp, 0x28
   ret

; void SlinComputerPlay(void);
;
; 0x20 - 0x28 loop0 counter
SlinComputerPlay:
   sub rsp, 0x38
   mov qword [rsp + 0x20], 9
.loop0:
   cmp qword [rsp + 0x20], 0
   jz .loop0end
   dec qword [rsp + 0x20]

   mov rcx, qword [rsp + 0x20]
   mov al, byte [rcx + Grid]
   cmp al, NO_STATE
   jnz .loop0

   mov byte [rcx + Grid], X_STATE

   shl rcx, 3
   mov rcx, qword [rcx + ButtonsHWND]
   mov rdx, WM_SETTEXT
   mov r8, 0
   mov r9, TextX
   call [SendMessageA]

.loop0end:
   add rsp, 0x38
   ret

; int SlinCheckWin(void);
SlinCheckWin:
   sub rsp, 0x28

   mov rdx, rcx
   mov rcx, -1
.loop0: ; column checks
   inc rcx
   cmp rcx, 3
   je .loop0end

   mov al, [rcx*3 + 0 + Grid]
   cmp al, dl
   jne .loop0

   mov al, [rcx*3 + 1 + Grid]
   cmp al, dl
   jne .loop0

   mov al, [rcx*3 + 2 + Grid]
   cmp al, dl
   jne .loop0

   je .winner

.loop0end:
   mov rcx, -1
.loop1: ; row checks
   inc rcx
   cmp rcx, 3
   je .loop1end

   mov al, [rcx + 0*3 + Grid]
   cmp al, dl
   jne .loop1

   mov al, [rcx + 1*3 + Grid]
   cmp al, dl
   jne .loop1

   mov al, [rcx + 2*3 + Grid]
   cmp al, dl
   jne .loop1

   je .winner
.loop1end:
.diagonal0: ; top left - bottom right diagonal
   mov al, [0 + Grid]
   cmp al, dl
   jne .diagonal1

   mov al, [4 + Grid]
   cmp al, dl
   jne .diagonal1

   mov al, [8 + Grid]
   cmp al, dl
   jne .diagonal1

   je .winner

.diagonal1: ; bottom left - top right diagonal
   mov al, [2 + Grid]
   cmp al, dl
   jne .endchecks

   mov al, [4 + Grid]
   cmp al, dl
   jne .endchecks

   mov al, [6 + Grid]
   cmp al, dl
   jne .endchecks

   je .winner

.endchecks:
   jmp .nowinner

.winner:
   mov rax, 1
   jmp .return

.nowinner:
   mov rax, 0
   jmp .return

.return:
   add rsp, 0x28
   ret
