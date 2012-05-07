/*
 *  CPlusPlusDefination.h
 *  CodeNavaigatorAlg
 *
 *  Created by Guozhen Li on 6/26/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#define COMMENTS_SINGLE @"//"

#define COMMENTS_MULTI @"/*"

#define COMMENTS_MULTI_END @"*/"

#define BRACE_START @"{"

#define BRACE_END @"}"

#define KEYWORD_CPP @"ATOM BOOL BOOLEAN BYTE CHAR COLORREF DWORD DWORD32 DWORD64 DWORDLONG DWORD_PTR FILE FLOAT HACCEL HALF_PTR HANDLE HBITMAP HBRUSH HCOLORSPACE HCONV HCONVLIST HCURSOR HDC HDDEDATA HDESK HDROP HDWP HENHMETAFILE HFILE HFONT HGDIOBJ HGLOBAL HHOOK HICON HINSTANCE HKEY HKL HLOCAL HMENU HMETAFILE HMODULE HMONITOR HPALETTE HPEN HRESULT HRGN HRSRC HSZ HWINSTA HWND INT INT32 INT64 INT_PTR LANGID LCID LCTYPE LGRPID LONG LONG32 LONG64 LONGLONG LONG_PTR LPARAM LPBOOL LPBYTE LPCOLORREF LPCSTR LPCTSTR LPCVOID LPCWSTR LPDWORD LPHANDLE LPINT LPLONG LPSTR LPTSTR LPVOID LPWORD LPWSTR LRESULT PBOOL PBOOLEAN PBYTE PCHAR PCSTR PCTSTR PCWSTR PDWORD32 PDWORD64 PDWORDLONG PDWORD_PTR PFLOAT PHALF_PTR PHANDLE PHKEY PINT PINT32 PINT64 PINT_PTR PLCID PLONG PLONG32 PLONG64 PLONGLONG PLONG_PTR POINTER_32 POINTER_64 PSHORT PSIZE_T PSSIZE_T PSTR PTBYTE PTCHAR PTSTR PUCHAR PUHALF_PTR PUINT PUINT32 PUINT64 PUINT_PTR PULONG PULONG32 PULONG64 PULONGLONG PULONG_PTR PUSHORT PVOID PWCHAR PWORD PWSTR SC_HANDLE SC_LOCK SERVICE_STATUS_HANDLE SHORT SIZE_T SSIZE_T TBYTE TCHAR UCHAR UHALF_PTR UINT UINT32 UINT64 UINT_PTR ULONG ULONG32 ULONG64 ULONGLONG ULONG_PTR USHORT USN VOID WCHAR WORD WPARAM WPARAM WPARAM _EXCEPTION_POINTERS _FPIEEE_RECORD _HEAPINFO _HFILE _PNH __declspec __exception __finally __finddata64_t __int16 __int32 __int64 __int8 __stat64 __time64_t __timeb64 __try __wchar_t __wfinddata64_t _complex _dev_t _diskfree_t _exception _finddata_t _finddatai64_t _off_t _onexit_t _purecall_handler _stat _stati64 _timeb _utimbuf _wfinddata_t _wfinddatai64_t asm auto bool bool break case catch char class clock_t const const_cast continue default delete deprecated div_t dllexport dllimport do double dynamic_cast else enum explicit extern false float for fpos_t friend goto if inline int intptr_t jmp_buf lconv ldiv_t long mbstate_t mutable naked namespace new noinline noreturn nothrow private protected ptrdiff_t public register reinterpret_cast return selectany short sig_atomic_t signed size_t sizeof static static_cast struct switch template terminate_function this thread throw time_t tm true try typedef typeid typename uintptr_t union unsigned using uuid va_list virtual void volatile wchar_t wctrans_t wctype_t whcar_t while wint_t"


#define PREPROCESSOR @"#define",@"#if",@"#ifdef",@"#undef",@"#endif",@"#else",@"#pragma",@"#ifndef", @"#elif", @"#error", nil

#define PREPROCESSOR_HEADER @"#"

#define HEADER_KEYWORD @"include"

#define HEADER_KEYWORD2 @"import"

#define MAGIC_NUMBER @"-&*$|"

typedef enum _PREPROCESSOR_TYPE{
	PREPROCESSOR_DEFINE = 0,
} PREPROCESSOR_TYPE;