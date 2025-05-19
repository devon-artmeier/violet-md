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
; Enter event
; ------------------------------------------------------------------------------

	xdef TestEnter
TestEnter:
	vdpCmd move.l,0,CRAM,WRITE,VDP_CTRL
	move.w	#$E0,VDP_DATA
	rts

; ------------------------------------------------------------------------------
; Exit event
; ------------------------------------------------------------------------------

	xdef TestExit
TestExit:
	rts

; ------------------------------------------------------------------------------
; Update start event
; ------------------------------------------------------------------------------

	xdef TestUpdateStart
TestUpdateStart:
	rts

; ------------------------------------------------------------------------------
; Update end event
; ------------------------------------------------------------------------------

	xdef TestUpdateEnd
TestUpdateEnd:
	rts

; ------------------------------------------------------------------------------
; Draw start event
; ------------------------------------------------------------------------------

	xdef TestDrawStart
TestDrawStart:
	rts

; ------------------------------------------------------------------------------
; Draw end event
; ------------------------------------------------------------------------------

	xdef TestDrawEnd
TestDrawEnd:
	rts

; ------------------------------------------------------------------------------
; V-BLANK interrupt start event
; ------------------------------------------------------------------------------

	xdef TestVBlankStart
TestVBlankStart:
	rts

; ------------------------------------------------------------------------------
; V-BLANK interrupt end event
; ------------------------------------------------------------------------------

	xdef TestVBlankEnd
TestVBlankEnd:
	rts

; ------------------------------------------------------------------------------
; V-BLANK interrupt lag event
; ------------------------------------------------------------------------------

	xdef TestVBlankLag
TestVBlankLag:
	rts

; ------------------------------------------------------------------------------