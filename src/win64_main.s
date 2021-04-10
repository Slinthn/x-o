format PE64 NX GUI 6.0
entry MainEntry

include "win64_types.inc"

section '.idata' import readable writable
import_directory_table KERNEL32, USER32
import_functions KERNEL32, ExitProcess, GetLastError, SetLastError, GetModuleHandleA
import_functions USER32, RegisterClassA, CreateWindowExA, DefWindowProcA, PeekMessageA, TranslateMessage, DispatchMessageA, MessageBoxA, SendMessageA

section '.text' code readable writable executable
ButtonsHWND dq 9 dup(0) ; HWND[9]
Window dq 0 ; HWND
Instance dq 0 ; HINSTANCE

ClassName db "X&OWindowClass", 0
WindowName db "X&O", 0
ButtonClass db "BUTTON", 0
ButtonText db ".", 0
TextX db "X", 0
TextO db "O", 0
Congratulations db "Congratulations!", 0
YouWin db "You win!", 0
TryHarder db "Try harder.", 0
YouLose db "You lose.", 0

NO_STATE equ 0
O_STATE equ 1
X_STATE equ 2

Grid db 9 dup(NO_STATE)

include "game.s"

; void MainEntry(void);
;
; 0x20 - 0x60 CreateWindowExA/PeekMessageA
; 0x60 - 0xA0 MSG
MainEntry:
   sub rsp, 0xF8

   mov rcx, 0
   call [SetLastError]

   mov rcx, 0
   call [GetModuleHandleA]
   mov qword [Instance], rax

   call SlinCreateWindow
   call SlinGenerateGrid

.WindowLoop:
   lea rcx, [rsp + 0x60]
   mov rdx, [rsp + 0xA0]
   mov r8, 0
   mov r9, 0
   mov dword [rsp + 0x20], PM_REMOVE
   call [PeekMessageA]

   lea rcx, [rsp + 0x60]
   call [TranslateMessage]
   lea rcx, [rsp + 0x60]
   call [DispatchMessageA]
   jmp .WindowLoop

   add rsp, 0xF8
   ret

; void SlinGenerateGrid(void);
;
; 0x20 - 0x28 loop0 counter
; 0x28 - 0x30 loop1 counter
; 0x30 - 0x38 xpos
; 0x38 - 0x40 ypos
; 0x40 - 0x48 counter
SlinGenerateGrid:
   sub rsp, 0x78

   mov qword [rsp + 0x20], 0 ; reset variables
   mov qword [rsp + 0x28], 0
   mov qword [rsp + 0x30], 0
   mov qword [rsp + 0x38], 0
   mov qword [rsp + 0x40], 0
   mov qword [rsp + 0x48], 0

.loop0: ; for (loop0 < 3) { for (loop1 < 3) {}}
   cmp qword [rsp + 0x20], 3
   je .loop0end

.loop1:
   cmp qword [rsp + 0x28], 3
   je .loop1end

   mov rcx, [rsp + 0x30] ; load X position
   mov rdx, [rsp + 0x38] ; load Y position
   mov r8, [rsp + 0x40] ; load ID (0 - 8)
   call SlinCreateButton

   mov rbx, [rsp + 0x40] ; get current counter
   mov [ButtonsHWND + 8*rbx], rax ; ButtonsHWND[rbx] = rax

   inc qword [rsp + 0x28] ; inc loop1
   inc qword [rsp + 0x40] ; inc general counter
   add qword [rsp + 0x38], 100 ; inc y position
   jmp .loop1
.loop1end:
   inc qword [rsp + 0x20] ; inc loop0
   mov qword [rsp + 0x28], 0 ; reset loop1
   add qword [rsp + 0x30], 100 ; inc x position
   mov qword [rsp + 0x38], 0 ; reset y position
   jmp .loop0

.loop0end:
   add rsp, 0x78
   ret

; void SlinCreateWindow(void);
;
; 0x20 - 0x60 CreateWindowA
; 0x60 - 0xA8 WNDCLASSA
SlinCreateWindow:
   sub rsp, 0xB8

   mov dword [rsp + 0x60], CS_VREDRAW + CS_HREDRAW ; WNDCLASSA.style
   mov qword [rsp + 0x68], SlinWindowProc ; WNDCLASSA.lpfnWndProc
   mov dword [rsp + 0x70], 0 ; WNDCLASSA.cbClsExtra
   mov dword [rsp + 0x74], 0 ; WNDCLASSA.cbWndExtra
   mov rax, [Instance]
   mov qword [rsp + 0x78], rax ; WNDCLASSA.hInstance
   mov qword [rsp + 0x80], 0 ; WNDCLASSA.hIcon
   mov qword [rsp + 0x88], 0 ; WNDCLASSA.hCursor
   mov qword [rsp + 0x90], 17 ; WNDCLASSA.hbrBackground
   mov qword [rsp + 0x98], 0 ; WNDCLASSA.lpszMenuName
   mov qword [rsp + 0xA0], ClassName ; WNDCLASSA.lpszClassName

   lea rcx, [rsp + 0x60]
   call [RegisterClassA]

   mov rcx, 0 ; dwExStyle
   mov rdx, ClassName ; lpClassName
   mov r8, WindowName ; lpWindowName
   mov r9, WS_OVERLAPPED + WS_CAPTION + WS_SYSMENU + WS_VISIBLE ; dwStyle
   mov dword [rsp + 0x20], CW_USEDEFAULT ; X
   mov dword [rsp + 0x28], CW_USEDEFAULT ; Y
   mov dword [rsp + 0x30], 316 ; nWidth
   mov dword [rsp + 0x38], 339 ; nHeight
   mov qword [rsp + 0x40], 0 ; hWndParent
   mov qword [rsp + 0x48], 0 ; hMenu
   mov rax, [Instance]
   mov qword [rsp + 0x50], rax ; hInstance
   mov qword [rsp + 0x58], 0 ; lpParam
   call [CreateWindowExA]

   mov qword [Window], rax

   add rsp, 0xB8
   ret

; LRESULT SlinWindowProc(HWND, UINT, WPARAM, LPARAM);
SlinWindowProc:
   sub rsp, 0x28

   cmp rdx, WM_DESTROY
   je .ExitProgram
   cmp rdx, WM_CLOSE
   je .ExitProgram
   cmp rdx, WM_COMMAND
   je .Command
   jmp .Default

.Command:
   mov rcx, r8
   mov rdx, r9
   call SlinGridClick
   mov rax, 0
   jmp .Return

.ExitProgram:
   mov rcx, 0
   call [ExitProcess]
   mov rax, 0
   jmp .Return

.Default:
   call [DefWindowProcA]
   jmp .Return

.Return:
   add rsp, 0x28
   ret

; HWND SlinCreateButton(int x, int y, int menu);
;
; 0x20 - 0x60 CreateWindowExA
SlinCreateButton:
   sub rsp, 0x68

   mov dword [rsp + 0x20], ecx ; X
   mov dword [rsp + 0x28], edx ; Y
   mov dword [rsp + 0x30], 100 ; nWidth
   mov dword [rsp + 0x38], 100 ; nHeight
   mov rax, [Window]
   mov qword [rsp + 0x40], rax ; hWndParent
   mov qword [rsp + 0x48], r8 ; hMenu
   mov rax, [Instance]
   mov qword [rsp + 0x50], rax ; hInstance
   mov qword [rsp + 0x58], 0 ; lpParam
   mov rcx, 0 ; dwExStyle
   mov rdx, ButtonClass ; lpClassName
   mov r8, ButtonText ; lpWindowName
   mov r9, WS_TABSTOP + WS_VISIBLE + WS_CHILD + BS_DEFPUSHBUTTON ; dwStyle
   call [CreateWindowExA]

   add rsp, 0x68
   ret
