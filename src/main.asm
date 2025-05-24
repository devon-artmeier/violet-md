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
; Set scene
; ------------------------------------------------------------------------------
; PARAMETERS:
;	0(sp).w - Scene ID
; ------------------------------------------------------------------------------

	xdef SetScene
SetScene:
	movem.w	d0-d1,-(sp)					; Save registers

	move.w	0+8(sp),d0					; Set scene
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	lsl.w	#3,d0
	move.w	d0,next_scene
	
	movem.w	(sp)+,d0-d1					; Restore registers
	move.l	(sp),2(sp)					; Deallocate stack frame and exit
	addq.w	#2,sp
	rts

; ------------------------------------------------------------------------------
; Run scene event
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Scene event type
;	       $00 - Enter
;	       $04 - Exit
;	       $08 - Update start
;	       $0C - Update end
;	       $10 - Draw start
;	       $14 - Draw end
; ------------------------------------------------------------------------------

RunSceneEvent:
	lea	XREF_Scenes(pc),a0				; Get event address
	adda.w	scene,a0
	move.l	(a0,d0.w),d0
	beq.s	.End						; If it's not defined, branch
	
	movea.l	d0,a0						; Run event
	jmp	(a0)
	
.End:
	rts

; ------------------------------------------------------------------------------
; Main
; ------------------------------------------------------------------------------

	xdef XREF_MainStart
Main:
	move.w	scene,d0					; Has the scene changed?
	cmp.w	next_scene,d0
	beq.s	UpdateScene					; If not, branch
	
	moveq	#4,d0						; Run scene exit event
	bsr.s	RunSceneEvent
	
	move.w	next_scene,scene				; Update scene ID

XREF_MainStart:
	moveq	#0,d0						; Run scene enter event
	bsr.s	RunSceneEvent

UpdateScene:
	bsr.w	VSync						; VSync

	moveq	#8,d0						; Run scene update start event
	bsr.s	RunSceneEvent
	
	; TODO: Do updates here

	moveq	#$C,d0						; Run scene update end event
	bsr.s	RunSceneEvent
	
	; TODO: Initialize drawing here

	moveq	#$10,d0						; Run scene draw start event
	bsr.s	RunSceneEvent
	
	; TODO: Do drawing here

	moveq	#$14,d0						; Run scene draw end event
	bsr.s	RunSceneEvent
	
	; TODO: Finish drawing here
	
	bra.s	Main						; Loop

; ------------------------------------------------------------------------------