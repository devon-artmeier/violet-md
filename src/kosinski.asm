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
; PARAMETERS:
;	0(sp).l - Destination buffer address
;	4(sp).l - Source data address
; ------------------------------------------------------------------------------

	xdef DecompKosinski
DecompKosinski:
	movem.l	a0-a1,-(sp)					; Save registers

	movea.l	4+$C(sp),a0					; Decompress data
	movea.l	0+$C(sp),a1
	bsr.s	DecompKosinskiData

	movem.l	(sp)+,a0-a1					; Restore registers
	move.l	(sp),8(sp)					; Deallocate stack frame
	addq.w	#8,sp
	rts

; ------------------------------------------------------------------------------
; Decompress Kosinski compressed data (extended parameters)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	0(sp).l - End addresses buffer address
;	4(sp).l - Destination buffer address
;	8(sp).l - Source data address
; ------------------------------------------------------------------------------

	xdef DecompKosinskiEx
DecompKosinskiEx:
	movem.l	a0-a2,-(sp)					; Save registers

	movea.l	8+$10(sp),a0					; Decompress data
	movea.l	4+$10(sp),a1
	bsr.s	DecompKosinskiData

	movea.l	0+$10(sp),a2					; Get end addresses buffer
	cmpa.w	#0,a2						; Is it set?
	beq.s	.NoEndBuffer					; If not, branch

	move.l	a0,(a2)+					; Store end addresses
	move.l	a1,(a2)+

.NoEndBuffer:
	movem.l	(sp)+,a0-a2					; Restore registers
	move.l	(sp),$C(sp)					; Deallocate stack frame
	lea	$C(sp),sp
	rts

; ------------------------------------------------------------------------------
; Decompress Kosinski compressed data
; ------------------------------------------------------------------------------
; Format details: https://segaretro.org/Kosinski_compression
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Source data address
;	a1.l - Destination buffer address
; ------------------------------------------------------------------------------
; RETURNS:
;	a0.l - Source data end address
;	a1.l - Destination buffer end address
; ------------------------------------------------------------------------------

DecompKosinskiData:
	movem.l	d0-d3/a2,-(sp)					; Save registers
	
	move.b	(a0)+,-(sp)					; Read from data stream
	move.b	(a0)+,-(sp)
	move.w	(sp)+,d1
	move.b	(sp)+,d1
	moveq	#16-1,d0					; 16 bits to process

; ------------------------------------------------------------------------------

.GetCode:
	lsr.w	#1,d1						; Get code
	bcc.s	.Code0x						; If it's 0, branch

; ------------------------------------------------------------------------------

.Code1:
	dbf	d0,.CopyByte					; Decrement bits left to process

	move.b	(a0)+,-(sp)					; Read from data stream
	move.b	(a0)+,-(sp)
	move.w	(sp)+,d1
	move.b	(sp)+,d1
	moveq	#16-1,d0					; 16 bits to process

.CopyByte:
	move.b	(a0)+,(a1)+					; Copy uncompressed byte
	bra.s	.GetCode					; Process next code

; ------------------------------------------------------------------------------

.Code0x:
	dbf	d0,.GetCopyOffset0x				; Decrement bits left to process

	move.b	(a0)+,-(sp)					; Read from data stream
	move.b	(a0)+,-(sp)
	move.w	(sp)+,d1
	move.b	(sp)+,d1
	moveq	#16-1,d0					; 16 bits to process

.GetCopyOffset0x:
	moveq	#$FFFFFFFF,d2					; Copy offsets are always negative
	moveq	#0,d3						; Reset copy counter

	lsr.w	#1,d1						; Get 2nd code bit
	bcs.s	.Code01					; If the full code is 01, branch

; ------------------------------------------------------------------------------

.Code00:
	dbf	d0,.GetCopyLength00H				; Decrement bits left to process

	move.b	(a0)+,-(sp)					; Read from data stream
	move.b	(a0)+,-(sp)
	move.w	(sp)+,d1
	move.b	(sp)+,d1
	moveq	#16-1,d0					; 16 bits to process

.GetCopyLength00H:
	lsr.w	#1,d1						; Get number of bytes to copy (top bit)
	addx.w	d3,d3
	dbf	d0,.GetCopyLength00L				; Decrement bits left to process

	move.b	(a0)+,-(sp)					; Read from data stream
	move.b	(a0)+,-(sp)
	move.w	(sp)+,d1
	move.b	(sp)+,d1
	moveq	#16-1,d0					; 16 bits to process

.GetCopyLength00L:
	lsr.w	#1,d1						; Get number of bytes to copy (bottom bit)
	addx.w	d3,d3
	dbf	d0,.GetCopyOffset00				; Decrement bits left to process

	move.b	(a0)+,-(sp)					; Read from data stream
	move.b	(a0)+,-(sp)
	move.w	(sp)+,d1
	move.b	(sp)+,d1
	moveq	#16-1,d0					; 16 bits to process

.GetCopyOffset00:
	move.b	(a0)+,d2					; Get copy offset

; ------------------------------------------------------------------------------

.StartCopy:
	lea	(a1,d2.w),a2					; Get copy address
	move.b	(a2)+,(a1)+					; Copy a byte

.CopyLoop:
	move.b	(a2)+,(a1)+					; Copy a byte
	dbf	d3,.CopyLoop					; Loop until bytes are copied

	bra.w	.GetCode					; Process next code

; ------------------------------------------------------------------------------

.Code01:
	dbf	d0,.GetCopyOffset01				; Decrement bits left to process

	move.b	(a0)+,-(sp)					; Read from data stream
	move.b	(a0)+,-(sp)
	move.w	(sp)+,d1
	move.b	(sp)+,d1
	moveq	#16-1,d0					; 16 bits to process

.GetCopyOffset01:
	move.b	(a0)+,-(sp)					; Get copy offset
	move.b	(a0)+,d2
	move.b	d2,d3
	lsl.w	#5,d2
	move.b	(sp)+,d2

	andi.w	#7,d3						; Get 3-bit copy count
	bne.s	.StartCopy					; If this is a 3-bit copy count, branch

	move.b	(a0)+,d3					; Get 8-bit copy count
	beq.s	.End						; If it's 0, we are done decompressing
	subq.b	#1,d3						; Is it 1?
	bne.s	.StartCopy					; If not, start copying
	
	bra.w	.GetCode					; Process next code

.End:
	movem.l	(sp)+,d0-d3/a2					; Restore registers
	rts

; ------------------------------------------------------------------------------