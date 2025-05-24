; ------------------------------------------------------------------------------
; Copyright (c) 2025 Devon Artmeier
;
; Permission to use, copy, modify, and/or distribute this software
; for any purpose with or without fee is hereby granted.
;
; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
; WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIE
; WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
; AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
; DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
; PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER 
; TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
; PERFORMANCE OF THIS SOFTWARE.
; ------------------------------------------------------------------------------

	include	"shared.inc"
	
	section code

; ------------------------------------------------------------------------------
; Decompress Kosinski compressed data
; ------------------------------------------------------------------------------
; Format details: https://segaretro.org/Kosinski_compression
; ------------------------------------------------------------------------------
; PARAMETERS:
;	0(sp).l - Destination buffer address
;	4(sp).l - Source data address
; ------------------------------------------------------------------------------

	xdef KosDec
KosDec:
	movem.l	a0-a1,-(sp)					; Save registers

	movea.l	4+12(sp),a0					; Decompress data
	movea.l	0+12(sp),a1
	include	"kosinski_internal.inc"

	movem.l	(sp)+,a0-a1					; Restore registers
	move.l	(sp),8(sp)					; Deallocate stack frame and exit
	addq.w	#8,sp
	rts

; ------------------------------------------------------------------------------