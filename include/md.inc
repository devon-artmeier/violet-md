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
; Cartridge
; ------------------------------------------------------------------------------

CARTRIDGE		equ 0					; Cartridge start
CARTRIDGE_END		equ $3FFFFF				; Cartridge end
CARTRIDGE_SIZE		equ $400000				; Cartridge size

; ------------------------------------------------------------------------------
; Expansion
; ------------------------------------------------------------------------------

EXPANSION		equ $400000				; Expansion start
EXPANSION_END		equ $7FFFFF				; Expansion end
EXPANSION_SIZE		equ $400000				; Expansion size

; ------------------------------------------------------------------------------
; Work RAM
; ------------------------------------------------------------------------------

WORK_RAM		equ $FFFF0000				; Work RAM start
WORK_RAM_END		equ $FFFFFFFF				; Work RAM end
WORK_RAM_SIZE		equ $10000				; Work RAM size
	
; ------------------------------------------------------------------------------
; VDP
; ------------------------------------------------------------------------------

VDP_PORTS		equ $C00000				; Ports
VDP_DATA		equ $C00000				; Data port
VDP_CTRL		equ $C00004				; Control port
VDP_HV			equ $C00008				; H/V counter

; ------------------------------------------------------------------------------
; YM2612
; ------------------------------------------------------------------------------

YM_PORTS		equ $A00000				; Ports
YM_ADDR_0		equ $A00000				; Register address (bank 0)
YM_DATA_0		equ $A00001				; Register data (bank 0)
YM_ADDR_1		equ $A00002				; Register address (bank 1)
YM_DATA_1		equ $A00003				; Register data (bank 1)

; ------------------------------------------------------------------------------
; PSG
; ------------------------------------------------------------------------------

PSG_CTRL		equ $C00011				; Control port

; ------------------------------------------------------------------------------
; I/O
; ------------------------------------------------------------------------------

IO_REGS			equ $A10001				; I/O registers
IO_VERSION		equ $A10001				; Hardware version
IO_DATA_1		equ $A10003				; Port 1 data
IO_DATA_2		equ $A10005				; Port 2 data
IO_DATA_3		equ $A10007				; Port 3 data
IO_CTRL_1		equ $A10009				; Port 1 control
IO_CTRL_2		equ $A1000B				; Port 2 control
IO_CTRL_3		equ $A1000D				; Port 3 control
IO_SERIAL_TX_1		equ $A1000F				; Port serial Tx data 1
IO_SERIAL_RX_1		equ $A10011				; Port serial Rx data 1
IO_SERIAL_CTRL_1	equ $A10013				; Port serial control 1
IO_SERIAL_TX_2		equ $A10015				; Port serial Tx data 2
IO_SERIAL_RX_2		equ $A10017				; Port serial Rx data 2
IO_SERIAL_CTRL_2	equ $A10019				; Port serial control 2
IO_SERIAL_TX_3		equ $A1001B				; Port serial Tx data 3
IO_SERIAL_RX_3		equ $A1001D				; Port serial Rx data 3
IO_SERIAL_CTRL_3	equ $A1001F				; Port serial control 3
	
; ------------------------------------------------------------------------------
; TMSS
; ------------------------------------------------------------------------------

TMSS_SEGA		equ $A14000				; TMSS "SEGA" register
	
; ------------------------------------------------------------------------------
; Z80
; ------------------------------------------------------------------------------

Z80_RAM			equ $A00000				; Z80 RAM start
Z80_RAM_END		equ $A01FFF				; Z80 RAM end
Z80_RAM_SIZE		equ $2000				; Z80 RAM size

Z80_REGS		equ $A11100				; Z80 registers
Z80_BUS			equ $A11100				; Z80 bus request
Z80_RESET		equ $A11200				; Z80 reset

; ------------------------------------------------------------------------------
; VDP command instruction
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - Instruction
;	\2 - Address in VDP memory
;	\3 - Type of VDP memory
;	\4 - VDP command
;	\5 - Destination (optional)
; ------------------------------------------------------------------------------

VRAM_WRITE_CMD		equ $40000000				; VRAM write
CRAM_WRITE_CMD		equ $C0000000				; CRAM write
VSRAM_WRITE_CMD		equ $40000010				; VSRAM write
VRAM_READ_CMD		equ $00000000				; VRAM read
CRAM_READ_CMD		equ $00000020				; CRAM read
VSRAM_READ_CMD		equ $00000010				; VSRAM read
VRAM_DMA_CMD		equ $40000080				; VRAM DMA
CRAM_DMA_CMD		equ $C0000080				; CRAM DMA
VSRAM_DMA_CMD		equ $40000090				; VSRAM DMA
VRAM_COPY_CMD		equ $000000C0				; VRAM DMA copy

; ------------------------------------------------------------------------------

vdpCmd macro
	__vdp_cmd: set (\3\_\4\_CMD)|(((\2)&$3FFF)<<16)|((\2)/$4000)
	if \#=5
		\1	#__vdp_cmd,\5
	else
		\1	__vdp_cmd
	endif
	endm

; ------------------------------------------------------------------------------
; VDP command instruction (low word)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - Instruction
;	\2 - Address in VDP memory
;	\3 - Type of VDP memory
;	\4 - VDP command
;	\5 - Destination (optional)
; ------------------------------------------------------------------------------

vdpCmdLo macro
	__vdp_cmd: set ((\3\_\4\_CMD)&$FFFF)|((\2)/$4000)
	if \#=5
		\1	#__vdp_cmd,\5
	else
		\1	__vdp_cmd
	endif
	endm

; ------------------------------------------------------------------------------
; VDP command instruction (high word)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - Instruction
;	\2 - Address in VDP memory
;	\3 - Type of VDP memory
;	\4 - VDP command
;	\5 - Destination (optional)
; ------------------------------------------------------------------------------

vdpCmdHi macro
	__vdp_cmd: set ((\3\_\4\_CMD)>>16)|((\2)&$3FFF)
	if \#=5
		\1	#__vdp_cmd,\5
	else
		\1	__vdp_cmd
	endif
	endm
	
; ------------------------------------------------------------------------------
; Wait for a VDP DMA to finish
; ------------------------------------------------------------------------------
; PARAMETERS:
;	\1 - VDP control port (optional)
; ------------------------------------------------------------------------------

waitDma macro
.Wait\@:
	if \#>0
		move	\1,ccr
	else
		move	VDP_CTRL,ccr
	endif
	bvs.s	.Wait\@
	endm
	
; ------------------------------------------------------------------------------
; VDP DMA from 68000 memory to VDP memory
; ------------------------------------------------------------------------------
; PARAMETERS:
;	src  - Source address in 68000 memory
;	dest - Destination address in VDP memory
;	len  - Length of data in bytes
;	type - Type of VDP memory
;	ctrl - VDP control port (optional)
; ------------------------------------------------------------------------------

dma68k macro src, dest, len, type, ctrl
	if \#>4
		move.l	#$94009300|((((\len)/2)&$FF00)<<8)|(((\len)/2)&$FF),\ctrl
		move.l	#$96009500|((((\src)/2)&$FF00)<<8)|(((\src)/2)&$FF),\ctrl
		move.w	#$9700|(((\src)>>17)&$7F),\ctrl
		vdpCmdHi move.w,\dest,\type,DMA,\ctrl
		vdpCmdLo move.w,\dest,\type,DMA,-(sp)
		move.w	(sp)+,\ctrl
	else
		move.l	#$94009300|((((\len)/2)&$FF00)<<8)|(((\len)/2)&$FF),VDP_CTRL
		move.l	#$96009500|((((\src)/2)&$FF00)<<8)|(((\src)/2)&$FF),VDP_CTRL
		move.w	#$9700|(((\src)>>17)&$7F),VDP_CTRL
		vdpCmdHi move.w,\dest,\type,DMA,VDP_CTRL
		vdpCmdLo move.w,\dest,\type,DMA,-(sp)
		move.w	(sp)+,VDP_CTRL
	endif
	endm

; ------------------------------------------------------------------------------
; Fill VRAM with byte
; (Auto-increment should be set to 1 beforehand)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	addr - Address in VRAM
;	len  - Length of fill in bytes
;	byte - Byte to fill VRAM with
;	ctrl - VDP control port (optional)
;	data - VDP data port (optional)
; ------------------------------------------------------------------------------

vramFill macro addr, len, byte, ctrl, data
	if \#>3
		move.l	#$94009300|((((\len)-1)&$FF00)<<8)|(((\len)-1)&$FF),\ctrl
		move.w	#$9780,\ctrl
		vdpCmd move.l,\addr,VRAM,DMA,\ctrl
		move.w	#((\byte)<<8)|(\byte),\data
		waitDma \ctrl
	else
		move.l	#$94009300|((((\len)-1)&$FF00)<<8)|(((\len)-1)&$FF),VDP_CTRL
		move.w	#$9780,VDP_CTRL
		vdpCmd move.l,\addr,VRAM,DMA,VDP_CTRL
		move.w	#((\byte)<<8)|(\byte),VDP_DATA
		waitDma
	endif
	endm

; ------------------------------------------------------------------------------
; Copy a region of VRAM to a location in VRAM
; (Auto-increment should be set to 1 beforehand)
; ------------------------------------------------------------------------------
; PARAMETERS:
;	src  - Source address in VRAM
;	dest - Destination address in VRAM
;	len  - Length of copy in bytes
;	ctrl - VDP control port (optional)
; ------------------------------------------------------------------------------

vramCopy macro src, dest, len, ctrl
	if \#>3
		move.l	#$94009300|((((\len)-1)&$FF00)<<8)|(((\len)-1)&$FF),\ctrl
		move.l	#$96009500|(((\src)&$FF00)<<8)|((\src)&$FF),\ctrl
		move.w	#$97C0,\ctrl
		vdpCmd move.l,\dest,VRAM,COPY,\ctrl
		waitDma \ctrl
	else
		move.l	#$94009300|((((\len)-1)&$FF00)<<8)|(((\len)-1)&$FF),VDP_CTRL
		move.l	#$96009500|(((\src)&$FF00)<<8)|((\src)&$FF),VDP_CTRL
		move.w	#$97C0,VDP_CTRL
		vdpCmd move.l,\dest,VRAM,COPY,VDP_CTRL
		waitDma
	endif
	endm

; ------------------------------------------------------------------------------
; Reqeust Z80 bus access
; ------------------------------------------------------------------------------
; PARAMETERS:
;	reg - Z80 control port (optional)
; ------------------------------------------------------------------------------

requestZ80 macro reg
	if \#>0
		move.w	#$100,\reg
	else
		move.w	#$100,Z80_BUS
	endif
	endm

; ------------------------------------------------------------------------------
; Wait for Z80 bus acknowledgement
; ------------------------------------------------------------------------------
; PARAMETERS:
;	reg - Z80 control port (optional)
; ------------------------------------------------------------------------------

waitZ80 macro reg
.Wait\@:
	if \#>0
		btst	#0,\reg
	else
		btst	#0,Z80_BUS
	endif
	bne.s	.Wait\@
	endm

; ------------------------------------------------------------------------------
; Stop the Z80 and get bus access
; ------------------------------------------------------------------------------
; PARAMETERS:
;	reg - Z80 control port (optional)
; ------------------------------------------------------------------------------

stopZ80 macro reg
	if \#>0
		requestZ80 \reg
		waitZ80 \reg
	else
		requestZ80
		waitZ80
	endif
	endm

; ------------------------------------------------------------------------------
; Start the Z80 and release bus access
; ------------------------------------------------------------------------------
; PARAMETERS:
;	reg - Z80 bus port (optional)
; ------------------------------------------------------------------------------

startZ80 macro reg
	if \#>0
		move.w	#0,\reg
	else
		move.w	#0,Z80_BUS
	endif
	endm

; ------------------------------------------------------------------------------
; Start Z80 reset
; ------------------------------------------------------------------------------
; PARAMETERS:
;	reg - Z80 reset port (optional)
; ------------------------------------------------------------------------------

resetZ80On macro reg
	if \#>0
		move.w	#0,\reg
	else
		move.w	#0,Z80_RESET
	endif
	ror.b	#8,d0
	endm

; ------------------------------------------------------------------------------
; Stop Z80 reset
; ------------------------------------------------------------------------------
; PARAMETERS:
;	reg - Z80 reset port (optional)
; ------------------------------------------------------------------------------

resetZ80Off macro reg
	if \#>0
		move.w	#$100,\reg
	else
		move.w	#$100,Z80_RESET
	endif
	endm

; ------------------------------------------------------------------------------