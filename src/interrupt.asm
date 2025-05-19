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
; V-BLANK interrupt
; ------------------------------------------------------------------------------

	xdef VioletMdVBlank
VioletMdVBlank:
	movem.l	d0-a6,-(sp)					; Save registers

	tst.b	vsync_flag					; Are we lagging?
	beq.s	.Lag						; If so, branch
	clr.b	vsync_flag					; Clear VSync flag

	moveq	#$18,d0						; Run scene V-BLANK interrupt start event
	bsr.w	XREF_GetSceneEvent
	beq.s	.NoStartEvent
	jsr	(a0)

.NoStartEvent:
	move	#$2700,sr					; Disable interrupts
	; TODO: Do updates here
	move	#$2000,sr					; Enable interrupts

	moveq	#$1C,d0						; Run scene V-BLANK interrupt end event
	bsr.w	XREF_GetSceneEvent
	beq.s	.NoEndEvent
	jsr	(a0)

.NoEndEvent:
	movem.l	(sp)+,d0-a6					; Restore registers
	rte

.Lag:
	moveq	#$20,d0						; Run scene V-BLANK interrupt lag event
	bsr.w	XREF_GetSceneEvent
	beq.s	.NoLagEvent
	jsr	(a0)

.NoLagEvent:
	movem.l	(sp)+,d0-a6					; Restore registers
	rte
	
; ------------------------------------------------------------------------------
; VSync
; ------------------------------------------------------------------------------

	xdef VioletMdVSync
VioletMdVSync:
	move	#$2000,sr					; Enable V-BLANK interrupt
	st.b	vsync_flag					; Set VSync flag

.Wait:
	tst.b	vsync_flag					; Has the V-BLANK interrupt run yet?
	bne.s	.Wait						; If not, wait
	rts

; ------------------------------------------------------------------------------