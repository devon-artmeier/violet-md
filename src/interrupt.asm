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
; Run V-BLANK event
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Event address
; ------------------------------------------------------------------------------

RunVBlankEvent:
	cmpa.w	#0,a0						; Is the event address set?
	beq.s	.End						; If not, branch
	jmp	(a0)						; Run event

.End:
	rts

; ------------------------------------------------------------------------------
; V-BLANK interrupt
; ------------------------------------------------------------------------------

	xdef VioletMdVBlank
VioletMdVBlank:
	movem.l	d0-a6,-(sp)					; Save registers

	tst.b	vsync_flag					; Are we lagging?
	beq.s	.Lag						; If so, branch
	clr.b	vsync_flag					; Clear VSync flag

	movea.l	vblank_start,a0					; Run V-BLANK interrupt start event
	bsr.s	RunVBlankEvent

	move.w	sr,-(sp)					; Save interrupt settings
	move.w	#$2700,sr					; Disable interrupts
	; TODO: Do updates here
	move.w	(sp)+,sr					; Restore interrupt settings

	movea.l	vblank_end,a0					; Run V-BLANK interrupt end event
	bsr.s	RunVBlankEvent

	movem.l	(sp)+,d0-a6					; Restore registers
	rte

.Lag:
	movea.l	vblank_lag,a0					; Run V-BLANK interrupt lag event
	bsr.s	RunVBlankEvent

	movem.l	(sp)+,d0-a6					; Restore registers
	rte
	
; ------------------------------------------------------------------------------
; VSync
; ------------------------------------------------------------------------------

	xdef VSync
VSync:
	move.w	#$2000,sr					; Enable V-BLANK interrupt
	st.b	vsync_flag					; Set VSync flag

.Wait:
	tst.b	vsync_flag					; Has the V-BLANK interrupt run yet?
	bne.s	.Wait						; If not, wait
	rts

; ------------------------------------------------------------------------------
; Clear V-BLANK interrupt events
; ------------------------------------------------------------------------------

	xdef ClearVBlankEvents
ClearVBlankEvents:
	move.w	sr,-(sp)					; Save interrupt settings
	move.w	#$2700,sr					; Disable interrupts

	clr.l	vblank_start					; Clear events
	clr.l	vblank_end
	clr.l	vblank_lag

	move.w	(sp)+,sr					; Restore interrupt settings
	rts

; ------------------------------------------------------------------------------
; Clear V-BLANK interrupt start event
; ------------------------------------------------------------------------------

	xdef ClearVBlankStartEvent
ClearVBlankStartEvent:
	move.w	sr,-(sp)					; Save interrupt settings
	move.w	#$2700,sr					; Disable interrupts
	
	clr.l	vblank_start					; Clear start event

	move.w	(sp)+,sr					; Restore interrupt settings
	rts

; ------------------------------------------------------------------------------
; Clear V-BLANK interrupt end event
; ------------------------------------------------------------------------------

	xdef ClearVBlankEndEvent
ClearVBlankEndEvent:
	move.w	sr,-(sp)					; Save interrupt settings
	move.w	#$2700,sr					; Disable interrupts
	
	clr.l	vblank_end					; Clear end event

	move.w	(sp)+,sr					; Restore interrupt settings
	rts

; ------------------------------------------------------------------------------
; Clear V-BLANK interrupt lag event
; ------------------------------------------------------------------------------

	xdef ClearVBlankLagEvent
ClearVBlankLagEvent:
	move.w	sr,-(sp)					; Save interrupt settings
	move.w	#$2700,sr					; Disable interrupts
	
	clr.l	vblank_lag					; Clear lag event

	move.w	(sp)+,sr					; Restore interrupt settings
	rts

; ------------------------------------------------------------------------------
; Set V-BLANK interrupt events
; ------------------------------------------------------------------------------
; PARAMETERS:
;	0(sp).l - Lag event address
;	4(sp).l - End event address
;	8(sp).l - Start event address
; ------------------------------------------------------------------------------

	xdef SetVBlankEvents
SetVBlankEvents:
	move.w	sr,-(sp)					; Save interrupt settings
	move.w	#$2700,sr					; Disable interrupts

	move.l	8+6(sp),vblank_start				; Set events
	move.l	4+6(sp),vblank_end
	move.l	0+6(sp),vblank_lag

	move.w	(sp)+,sr					; Restore interrupt settings
	move.l	(sp),$C(sp)					; Deallocate stack frame
	lea	$C(sp),sp
	rts

; ------------------------------------------------------------------------------
; Set V-BLANK interrupt start event
; ------------------------------------------------------------------------------
; PARAMETERS:
;	0(sp).l - Start event address
; ------------------------------------------------------------------------------

	xdef SetVBlankStartEvent
SetVBlankStartEvent:
	move.w	sr,-(sp)					; Save interrupt settings
	move.w	#$2700,sr					; Disable interrupts
	
	move.l	0+6(sp),vblank_start				; Set start event

	move.w	(sp)+,sr					; Restore interrupt settings
	move.l	(sp),4(sp)					; Deallocate stack frame
	addq.w	#4,sp
	rts

; ------------------------------------------------------------------------------
; Set V-BLANK interrupt end event
; ------------------------------------------------------------------------------
; PARAMETERS:
;	0(sp).l - End event address
; ------------------------------------------------------------------------------

	xdef SetVBlankEndEvent
SetVBlankEndEvent:
	move.w	sr,-(sp)					; Save interrupt settings
	move.w	#$2700,sr					; Disable interrupts
	
	move.l	0+6(sp),vblank_end				; Set end event

	move.w	(sp)+,sr					; Restore interrupt settings
	move.l	(sp),4(sp)					; Deallocate stack frame
	addq.w	#4,sp
	rts

; ------------------------------------------------------------------------------
; Set V-BLANK interrupt lag event
; ------------------------------------------------------------------------------
; PARAMETERS:
;	0(sp).l - Lag event address
; ------------------------------------------------------------------------------

	xdef SetVBlankLagEvent
SetVBlankLagEvent:
	move.w	sr,-(sp)					; Save interrupt settings
	move.w	#$2700,sr					; Disable interrupts

	move.l	0+6(sp),vblank_lag				; Set lag event

	move.w	(sp)+,sr					; Restore interrupt settings
	move.l	(sp),4(sp)					; Deallocate stack frame
	addq.w	#4,sp
	rts

; ------------------------------------------------------------------------------