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

; ------------------------------------------------------------------------------
; Memory map and variables
; ------------------------------------------------------------------------------

	rsset WORK_RAM+$E000
scene			rs.w 1					; Current scene
next_scene		rs.w 1					; Next scene

bg_tasks_bookmark	rs.l 1					; Background task bookmark
bg_tasks_sr		rs.w 1					; Background task status register
bg_tasks_regs		rs.l 8+7				; Background task registers

vblank_start		rs.l 1					; V-BLANK interrupt start event
vblank_end		rs.l 1					; V-BLANK interrupt end event
vblank_lag		rs.l 1					; V-BLANK interrupt lag event

vsync_flag		rs.b 1					; VSync flag

			rs.b (WORK_RAM_END-$1FF)-__RS		; Stack space
stack			rs.b 0					; Stack base

; ------------------------------------------------------------------------------