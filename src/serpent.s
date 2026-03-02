  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Copyright (c) 2026 Jahan Addison
  ;; All rights reserved.
  ;;
  ;; Redistribution and use in source and binary forms, with or without
  ;; modification, are permitted provided that the following conditions are met:
  ;;
  ;; 1. Redistributions of source code must retain the above copyright notice, this
  ;;    list of conditions and the following disclaimer.
  ;;
  ;; 2. Redistributions in binary form must reproduce the above copyright notice,
  ;;    this list of conditions and the following disclaimer in the documentation
  ;;    and/or other materials provided with the distribution.
  ;;
  ;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIEDi
  ;; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  ;; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
  ;; ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  ;; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  ;; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ;; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  ;; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  ;; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .include "sfr.i"

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; General Purpose Address Space
  ;;
  ;; @R0 and @R1 will always access the RAM half
  ;; @R2 and @R3 will always access the SFR half.
  ;;
  ;; 256 addresses ($00–$FF) are available for general-purpose data in bank 1:
  ;;
  ;;  $00–$0F: These double as the indirect register pointer cells (@R0–@R3 read
  ;;    their addresses from here depending on IRBK bits in PSW)
  ;;  $10–$FF: Orthogonal general purpose address space, 240 bytes
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;;;;;;;;;;;;;;
  ;; Variables ;;
  ;;;;;;;;;;;;;;;

piece_ptr_x = $00   ; R0: pointer to active piece's x coordinates
piece_ptr_y = $01   ; R1: pointer to active piece's y coordinates

  ;; Serpent state

  ;; Direction values: up = 0, right = 1, down = 2, left = 3
direction = $30   ; serpent direction
serpent_size = $31  ; size of serpent, set to 1 at game start, winning size is 7
serpent_speed = $35   ; speed of serpent, "1" at game start

  ;; The "food" that the serpent eats
food_x = $36   ; horizontal position of food on screen
food_y = $37   ; vertical position of food on screen
seed = $38    ; random seed

  ;; Serpent's tail coordinate addresses
serpent_piece = $48    ; the current serpent piece being updated, set to 1 at start

serpent_x1 = $39
serpent_y1 = $3A
serpent_x2 = $3B
serpent_y2 = $3C
serpent_x3 = $3D
serpent_y3 = $3E
serpent_x4 = $3F
serpent_y4 = $40
serpent_x5 = $41
serpent_y5 = $42
serpent_x6 = $43
serpent_y6 = $44
serpent_x7 = $45
serpent_y7 = $46


  ;; Reset and interrupt vectors

	.org	0

	jmpf	start

	.org	$3

	jmp	nop_irq

	.org	$b

	jmp	nop_irq

	.org	$13

	jmp	nop_irq

	.org	$1b

	jmp	t1int

	.org	$23

	jmp	nop_irq

	.org	$2b

	jmp	nop_irq

	.org	$33

	jmp	nop_irq

	.org	$3b

	jmp	nop_irq

	.org	$43

	jmp	nop_irq

	.org	$4b

	clr1	p3int,0
	clr1	p3int,1
nop_irq:
	reti


	.org	$130

t1int:
	push	ie
	clr1	ie,7
	not1	ext,0
	jmpf	t1int
	pop	ie
	reti


	.org	$1f0

goodbye:
	not1	ext,0
	jmpf	goodbye


  ;; Header

  .org    $200
  .byte	"Serpent         "
  .byte	"Snake on the VMS - Jahan Addison"

	;; Icon header

	.org	$240

	.word	2,10		; Two frames

	;; Icon palette

	.org	$260

	.word	$0000, $fcfc, $f0a0, $f0f0, $fccf, $f00a, $f00f, $ffff
	.word	$ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff

	;; Icon

	.org	$280

	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$01,$11,$11,$11,$11,$11,$10,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$01,$22,$22,$31,$22,$22,$30,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$01,$22,$22,$31,$22,$22,$30,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$01,$22,$22,$31,$22,$22,$30,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$01,$22,$22,$31,$22,$22,$30,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$01,$33,$33,$31,$33,$33,$30,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$01,$11,$11,$11,$11,$11,$10,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$01,$22,$22,$31,$22,$22,$30,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$01,$22,$22,$31,$22,$22,$30,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$01,$22,$22,$31,$22,$22,$30,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$01,$22,$22,$31,$22,$22,$30,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$01,$33,$33,$31,$33,$33,$30,$00,$00,$00
	.byte	$00,$00,$00,$04,$44,$44,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$04,$55,$55,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$04,$55,$55,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$04,$55,$55,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$04,$55,$55,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$04,$66,$66,$60,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$04,$44,$44,$44,$44,$44,$44,$44,$44,$40,$00,$00,$00
	.byte	$00,$00,$00,$04,$55,$55,$64,$55,$55,$64,$55,$55,$60,$00,$00,$00
	.byte	$00,$00,$00,$04,$55,$55,$64,$55,$55,$64,$55,$55,$60,$00,$00,$00
	.byte	$00,$00,$00,$04,$55,$55,$64,$55,$55,$64,$55,$55,$60,$00,$00,$00
	.byte	$00,$00,$00,$04,$55,$55,$64,$55,$55,$64,$55,$55,$60,$00,$00,$00
	.byte	$00,$00,$00,$04,$66,$66,$64,$66,$66,$64,$66,$66,$60,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$01,$11,$11,$11,$11,$11,$10,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$01,$22,$22,$31,$22,$22,$30,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$01,$22,$22,$31,$22,$22,$30,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$01,$22,$22,$31,$22,$22,$30,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$01,$22,$22,$31,$22,$22,$30,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$01,$33,$33,$31,$33,$33,$30,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$04,$44,$44,$41,$11,$11,$11,$11,$11,$10,$00,$00,$00
	.byte	$00,$00,$00,$04,$55,$55,$61,$22,$22,$31,$22,$22,$30,$00,$00,$00
	.byte	$00,$00,$00,$04,$55,$55,$61,$22,$22,$31,$22,$22,$30,$00,$00,$00
	.byte	$00,$00,$00,$04,$55,$55,$61,$22,$22,$31,$22,$22,$30,$00,$00,$00
	.byte	$00,$00,$00,$04,$55,$55,$61,$22,$22,$31,$22,$22,$30,$00,$00,$00
	.byte	$00,$00,$00,$04,$66,$66,$61,$33,$33,$31,$33,$33,$30,$00,$00,$00
	.byte	$00,$00,$00,$04,$44,$44,$44,$44,$44,$44,$44,$44,$40,$00,$00,$00
	.byte	$00,$00,$00,$04,$55,$55,$64,$55,$55,$64,$55,$55,$60,$00,$00,$00
	.byte	$00,$00,$00,$04,$55,$55,$64,$55,$55,$64,$55,$55,$60,$00,$00,$00
	.byte	$00,$00,$00,$04,$55,$55,$64,$55,$55,$64,$55,$55,$60,$00,$00,$00
	.byte	$00,$00,$00,$04,$55,$55,$64,$55,$55,$64,$55,$55,$60,$00,$00,$00
	.byte	$00,$00,$00,$04,$66,$66,$64,$66,$66,$64,$66,$66,$60,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00


  ;;;;;;;;;;;;;;;;;;;;;;
  ;; Start of program ;;
  ;;;;;;;;;;;;;;;;;;;;;;

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; @TODO
  ;; A second difficult could be allowing the serpent to wrap around the screen
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


start:
  ;; setup
	clr1 ie, 7
	mov #$a1, ocr
	mov #$09, mcr
	mov #$80, vccr
	clr1 p3int, 0
	clr1 p1, 7
	mov #$ff, p3

  call clrscr
  mov #0, xbnk  ; ensure we draw into bank 0 (upper screen)

  ;; set initial position (debug)
  mov #3, serpent_x1
  mov #$f, serpent_y1
  mov #$F8,2
  mov #$1,@R2

  ;; direction values: up = 0, right = 1, down = 2, left = 3
  ;; set direction, speed, and size
  mov #1, serpent_size
  mov #1, serpent_speed
  mov #1, serpent_piece

  mov #serpent_x1, piece_ptr_x
  mov #serpent_y1, piece_ptr_y

  mov #0, direction  ; start moving up

.gameloop:
  ;; piece_ptr_x and piece_ptr_y from serpent_piece
  ld serpent_piece
  dec acc
  add acc             ; acc = (piece - 1) * 2
  add #serpent_x1
  st piece_ptr_x      ; @R0 → xN
  add #1
  st piece_ptr_y      ; @R1 → yN
  ld @R0
  st B                ; B = serpent_xN
  ld @R1
  st C                ; C = serpent_yN

  ; get key pressed
.keypress:
  call getkeys
  bn acc,4,.gameloop
  bn acc,5,.gameloop
  bn acc,3,.setdirection_right
  bn acc,2,.setdirection_left
  bn acc,1,.setdirection_down
  bn acc,0,.setdirection_up

  ; move in set direction if no keypress
  ld direction
  be #0,.moveup
  be #1,.moveright
  be #2,.movedown
  be #3,.moveleft

  .setdirection_right:
  call setdirection_right
  br .moveright
  .setdirection_left:
  call setdirection_left
  br .moveleft
  .setdirection_down:
  call setdirection_down
  br .movedown
  .setdirection_up:
  call setdirection_up
  br .moveup

  .moveright:
  call moveright
  call pausehalf
  br .done
  .moveleft:
  call moveleft
  call pausehalf
  br .done
  .movedown:
  call movedown
  call pausehalf
  br .done
  .moveup:
  call moveup
  call pausehalf
  br .done

  .done:
  ld B
  st @R0 ; write x back via piece_ptr_x
  ld C
  st @R1 ; write y back via piece_ptr_y

  br .gameloop

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Subroutines
  ;; @params
  ;;  1) B register hold the first param
  ;;  2) C register holds the second param
  ;;
  ;;  The stack is used for additional parameters
  ;;
  ;; @returns
  ;;   acc register holds the return value
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

setdirection_up:
  clr1 ocr,5
  mov #0,direction
  set1 ocr,5
  ret

setdirection_down:
  clr1 ocr,5
  mov #2,direction
  set1 ocr,5
  ret

setdirection_left:
  clr1 ocr,5
  mov #3,direction
  set1 ocr,5
  ret

setdirection_right:
  clr1 ocr,5
  mov #1,direction
  set1 ocr,5
  ret

moveup:
  clr1 ocr,5
  ld C
  be #0,.halt ; top of screen → game over
  be #$10,.ubank ; row 16: cross from bank 1 to bottom of bank 0
  bn acc,0,.upeven ; even row (bit 0 clear): gap + row = sub 10
  ;; odd row: subtract 6 bytes straight to the even row above
  dec C
  ld @R2
  push acc ; save pixel data
  mov #0,@R2
  ld 2
  sub #6
  st 2
  pop acc
  st @R2
  br .up
  .ubank:
  ; bank boundary: switch to bank 0, jump to last row
  ld @R2
  push acc
  mov #0,@R2
  mov #0,xbnk
  ld 2
  add #$76 ; +118: from bank 1 row 0 addr to bank 0 row 15 addr
  st 2
  dec C
  pop acc
  st @R2
  br .up
  .upeven:
  ; even row: subtract 4 (gap) + 6 (row) = 10
  dec C
  ld @R2
  push acc
  mov #0,@R2
  ld 2
  sub #$a
  st 2
  pop acc
  st @R2
  br .up
  .halt:
  call gameover
  .up:
  set1 ocr,5
  ret


movedown:
  clr1 ocr,5
  ld C
  be #$1F,.halt  ; check if bottom of buffer, if so, game over
  be #$f,.dbank ; branch to bank 1 coroutine at 15
  bp C,0,.downskip ; check the lowest-order bit (big-endian) for odd to skip
  ; move down
  .downcont:
  inc C
  ld @R2
  push acc
  mov #0,@R2
  .downfinal:
  ld 2
  add #6
  st 2
  pop acc
  st @R2
  br .down
  .dbank:
  ld @R2 ; save our current state for bank 1
  push acc
  mov #0,@R2
  mov #1,xbnk
  ld 2
  sub #$76 ; subtract by 118 to get the first row position on the new bank
  st 2
  inc C
  pop acc
  st @R2
  ; we've moved down, we're done here
  br .down
  .downskip:
  inc C
  ld @R2
  mov #0,@R2
  push acc
  ld 2
  add #4
  st 2
  br .downfinal
  .halt:
  call gameover
  .down:
  set1 ocr,5
  ret

moveright:
  clr1 ocr,5
  ld B
  ; check if buffer cannot move right any further
  be #6,.right
  ; when we're on the last, we ensure we move until the most-significant bit
  be #5,.rightfinal
  .rightcontinue:
  ; move right
  ld @R2
  clr1 psw,7
  rorc
  ; check the carry flag for overflow of our bit, which
  ; means it's time to move to the next byte
  bp psw,7,.rightnext
  st @R2
  br .right
  .rightnext:
  ; move right the next byte to prepare to store the most-significant bit of current
  inc 2
  ror
  ld @R2
  set1 acc,7
  st @R2
  ; clear the current most-significant bit. if the byte is
  ; now clear, we can proceed with the next byte
  dec 2
  ld @R2
  clr1 acc,0
  st @R2
  clr1 psw,7
  bnz .right
  inc B
  ld B
  inc 2
  br .right
  .rightfinal:
  ld @R2
  bp acc,0,.rightdone
  br .rightcontinue
  .rightdone:
  inc B
  .right:
  set1 ocr,5
  ret


moveleft:
  clr1 ocr,5
  ld B
  ; check if buffer cannot move left any further
  be #0,.left
  ; when we're on the last, we ensure we move until the most-significant bit
  be #1,.leftfinal
  .leftcontinue:
  ; move left
  ld @R2
  clr1 psw,7  ; clear carry before rotate (matches moveright pattern)
  rolc
  ; check the carry flag for overflow of our bit, which
  ; means it's time to move to the preceding byte
  bp psw,7,.leftnext
  st @R2
  br .left
  .leftnext:
  ; move left the previous byte to prepare to store the most-significant bit of current
  dec 2
  rol
  ld @R2
  set1 acc,0
  st @R2
  ; clear the current most-significant bit. if the byte is
  ; now clear, we can proceed with the preceding byte
  inc 2
  ld @R2
  clr1 acc,7
  st @R2
  clr1 psw,7
  bnz .left
  dec B
  ld B
  dec 2
  br .left
  .leftfinal:
  ld @R2
  bp acc,7,.leftdone
  br .leftcontinue
  .halt:
  call gameover
  .leftdone:
  dec B
  .left:
  set1 ocr,5
  ret

pause:
  push b
  push c
  mov #64,b ; 64 outer x 256 inner x 2-cycle dbnz = 32768 cycles = 1s
.pouter:
  mov #0,c ; c=0 → dbnz wraps to 255, giving 256 iterations
.pinner:
  dbnz c,.pinner
  dbnz b,.pouter
  pop c
  pop b
  ret

pausehalf:
  push b
  push c
  mov #32,b  ; 32 outer x 256 inner x 2-cycle dbnz = 16384 cycles = 0.5 s
.phouter:
  mov #0,c
.phinner:
  dbnz c,.phinner
  dbnz b,.phouter
  pop c
  pop b
  ret

clrscr:
  clr1 ocr,5
  push acc
  push xbnk
  push 2
  mov #0,xbnk
  .cbank:
  mov #$80,2
  .cloop:
  mov #0,@R2
  inc 2
  ld 2
  and #$f
  bne #$c,.cskip
  ld 2
  add #4
  st 2
  .cskip:
  ld 2
  bnz .cloop
  bp xbnk,0,.cexit
  mov #1,xbnk
  br .cbank
  .cexit:
  pop 2
  pop xbnk
  pop acc
  set1 ocr,5
  ret

setscr:
  clr1 ocr,5
  push acc
  push xbnk
  push c
  push 2
  mov #$80,2
  xor acc
  st xbnk
  st c
.sloop:
  ldc
  st @R2
  inc 2
  ld 2
  and #$f
  bne #$c,.sskip
  ld 2
  add #4
  st 2
  bnz .sskip
  inc xbnk
  mov #$80,2
.sskip:
  inc c
  ld c
  bne #$c0,.sloop
  pop 2
  pop c
  pop xbnk
  pop acc
  set1 ocr,5
  ret

getkeys:
  bp p7,0,quit
  ld p3
  bn acc,6,quit
  bn acc,7,sleep
  ret
quit:
  jmp goodbye

sleep:
  bn p3,7,sleep ; wait for SLEEP to be depressed (released)
  mov #0,vccr ; blank LCD before halting
sleepmore:
  set1 pcon,0 ; enter HALT mode
  bp p7,0,quit ; docked?
  bp p3,7,sleepmore ; no SLEEP press yet
  mov #$80,vccr ; re-enable LCD
waitsleepup:
  bn p3,7,waitsleepup
  br getkeys


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Gameover
  ;;
  ;; Displays "GAME" on the top row and "OVER" on the bottom row
  ;; of the LCD, then halts forever (only a power-cycle escapes).
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gameover:
  mov #<gameover_screen,trl
  mov #>gameover_screen,trh
  call setscr
.forever:
  br .forever


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Gameover Bitmap
  ;;
  ;; Bank 0 (display lines 0-15):
  ;;   Lines 1-7 = "GAME" (5-wide chars at px 10, 17, 24, 31)
  ;; Bank 1 (display lines 16-31):
  ;;   Lines 25-31 = "OVER" (same horizontal positions)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gameover_screen:
  ;; bank 0
  .byte $00,$00,$00,$00,$00,$00  ; line  0  (blank)
  .byte $00,$1C,$10,$89,$F0,$00  ; line  1  GAME row 0
  .byte $00,$20,$28,$D9,$00,$00  ; line  2  GAME row 1
  .byte $00,$2C,$44,$A9,$00,$00  ; line  3  GAME row 2
  .byte $00,$26,$7C,$89,$E0,$00  ; line  4  GAME row 3
  .byte $00,$22,$44,$89,$00,$00  ; line  5  GAME row 4
  .byte $00,$22,$44,$89,$00,$00  ; line  6  GAME row 5
  .byte $00,$1C,$44,$89,$F0,$00  ; line  7  GAME row 6
  .byte $00,$00,$00,$00,$00,$00  ; line  8  (blank)
  .byte $00,$00,$00,$00,$00,$00  ; line  9
  .byte $00,$00,$00,$00,$00,$00  ; line 10
  .byte $00,$00,$00,$00,$00,$00  ; line 11
  .byte $00,$00,$00,$00,$00,$00  ; line 12
  .byte $00,$00,$00,$00,$00,$00  ; line 13
  .byte $00,$00,$00,$00,$00,$00  ; line 14
  .byte $00,$00,$00,$00,$00,$00  ; line 15
  ;; bank 1
  .byte $00,$00,$00,$00,$00,$00  ; line 16  (blank)
  .byte $00,$00,$00,$00,$00,$00  ; line 17
  .byte $00,$00,$00,$00,$00,$00  ; line 18
  .byte $00,$00,$00,$00,$00,$00  ; line 19
  .byte $00,$00,$00,$00,$00,$00  ; line 20
  .byte $00,$00,$00,$00,$00,$00  ; line 21
  .byte $00,$00,$00,$00,$00,$00  ; line 22
  .byte $00,$00,$00,$00,$00,$00  ; line 23
  .byte $00,$00,$00,$00,$00,$00  ; line 24
  .byte $00,$1C,$44,$F9,$E0,$00  ; line 25  OVER row 0
  .byte $00,$22,$44,$81,$08,$00  ; line 26  OVER row 1
  .byte $00,$22,$44,$81,$08,$00  ; line 27  OVER row 2
  .byte $00,$22,$44,$F1,$E0,$00  ; line 28  OVER row 3
  .byte $00,$22,$28,$81,$40,$00  ; line 29  OVER row 4
  .byte $00,$22,$28,$81,$20,$00  ; line 30  OVER row 5
  .byte $00,$1C,$10,$F9,$08,$00  ; line 31  OVER row 6


  .cnop   0,$200          ; pad to an even number of blocks
