macro import_directory_table [lib] {
forward
   dd rva IAT__#lib
   dd 0
   dd 0
   dd rva NAME__#lib
   dd rva IAT__#lib

common
   dd 5 dup(0)

forward
NAME__#lib db `lib, ".DLL", 0
}

macro import_functions lib, [func] {
forward
   if $ & 1
      db 0
   end if
IMPORTNAME__#func dw 0
   db `func, 0

common
IAT__#lib:

forward
func dq rva IMPORTNAME__#func

common
   dq 0
}

BS_DEFPUSHBUTTON equ 0x1

WS_CHILD equ 0x40000000
WS_TABSTOP equ 0x10000
WS_OVERLAPPED equ 0x0
WS_CAPTION equ 0xC00000
WS_SYSMENU equ 0x80000
WS_THICKFRAME equ 0x40000
WS_MINIMIZEBOX equ 0x20000
WS_MAXIMIZEBOX equ 0x10000
WS_OVERLAPPEDWINDOW equ WS_OVERLAPPED + WS_CAPTION + WS_SYSMENU + WS_THICKFRAME + WS_MINIMIZEBOX + WS_MAXIMIZEBOX
WS_VISIBLE equ 0x10000000

CW_USEDEFAULT equ 0x80000000

PM_REMOVE equ 0x1

WM_DESTROY equ 0x2
WM_CLOSE equ 0x10
WM_COMMAND equ 0x111
WM_PAINT equ 0xF
WM_SETTEXT equ 0xC

TRANSPARENT equ 1
OPAQUE equ 2

CS_VREDRAW equ 0x1
CS_HREDRAW equ 0x2
