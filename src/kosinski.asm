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
;	a0.l - Pointer to source data
;	a1.l - Pointer to destination buffer
; ------------------------------------------------------------------------------
; RETURNS:
;	a0.l - Pointer to end of source data
;	a1.l - Pointer to end of destination buffer
; ------------------------------------------------------------------------------

	xdef KosDec
KosDec:
	include	"kosinski_internal.inc"
	rts

; ------------------------------------------------------------------------------