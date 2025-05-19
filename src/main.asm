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
; Get scene events
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Scene event type
;	       $00 - Enter
;	       $04 - Exit
;	       $08 - Update start
;	       $0C - Update end
;	       $10 - Draw start
;	       $14 - Draw end
;	       $18 - V-BLANK interrupt start
;	       $1C - V-BLANK interrupt end
;	       $20 - V-BLANK interrupt lag
; ------------------------------------------------------------------------------
; RETURNS:
;	eq/ne - Not defined/Defined
;	a0.l  - Scene event address
; ------------------------------------------------------------------------------

	xdef XREF_GetSceneEvent
XREF_GetSceneEvent:
	lea	XREF_Scenes(pc),a0				; Get event address
	adda.w	scene,a0
	movea.l	(a0,d0.w),a0
	cmpa.w	#0,a0						; Check if it's defined
	rts
	
; ------------------------------------------------------------------------------
; Set scene
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Scene ID
; ------------------------------------------------------------------------------

	xdef SetScene
SetScene:
	movem.w	d0-d1,-(sp)					; Save registers
	
	add.w	d0,d0						; Multiply ID by index size
	add.w	d0,d0
	move.w	d0,d1
	lsl.w	#3,d0
	add.w	d1,d0
	
	move.w	d0,next_scene					; Set next scene
	
	movem.w	(sp)+,d0-d1					; Restore registers
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
	bsr.s	XREF_GetSceneEvent
	beq.s	.NoExitEvent
	jsr	(a0)

.NoExitEvent:
	move.w	next_scene,scene				; Update scene ID

XREF_MainStart:
	moveq	#0,d0						; Run scene enter event
	bsr.s	XREF_GetSceneEvent
	beq.s	UpdateScene
	jsr	(a0)

UpdateScene:
	bsr.w	VioletMdVSync					; VSync

	moveq	#8,d0						; Run scene update start event
	bsr.s	XREF_GetSceneEvent
	beq.s	.NoUpdateStartEvent
	jsr	(a0)

.NoUpdateStartEvent:
	; TODO: Do updates here

	moveq	#$C,d0						; Run scene update end event
	bsr.s	XREF_GetSceneEvent
	beq.s	.NoUpdateEndEvent
	jsr	(a0)

.NoUpdateEndEvent:
	; TODO: Initialize drawing here

	moveq	#$10,d0						; Run scene draw start event
	bsr.s	XREF_GetSceneEvent
	beq.s	.NoDrawStartEvent
	jsr	(a0)
	
.NoDrawStartEvent:
	; TODO: Do drawing here

	moveq	#$14,d0						; Run scene draw end event
	bsr.s	XREF_GetSceneEvent
	beq.s	.NoDrawEndEvent
	jsr	(a0)
	
.NoDrawEndEvent:
	; TODO: Finish drawing here
	
	bra.s	Main						; Loop

; ------------------------------------------------------------------------------