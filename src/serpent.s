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
  ;; R0/R1 address the RAM half
  ;; R2/R3 address the SFR half
  ;;
  ;; Bank 1 provides 256 bytes of general-purpose data ($00-$FF)
  ;;    $00-$0F double as the indirect register pointer cells
  ;;
  ;; $10-$FF are orthogonal general-purpose storage
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Variables
  ;;
  ;; Indirect register pointers are in $00-$01
  ;; Directions: 0=up 1=right 2=down 3=left.
  ;;
  ;; All pixel X coordinates are true pixel columns (0-47)
  ;;    Y coordinates are 0-31.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

piece_ptr_x = $00
piece_ptr_y = $01

direction    = $30
serpent_size = $31
serpent_speed = $35

food_x     = $36
food_y     = $37
food_reset = $4F
seed       = $38

pixel_mask_val = $47
pixel_byte_col = $49
pixel_shift    = $4A

tail_x    = $4B
tail_y    = $4C
shift_i   = $4D

serpent_piece = $48

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

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Reset and interrupt vectors ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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


  ;;;;;;;;;;;;;;;;;;;;;
  ;; VMS file header ;;
  ;;;;;;;;;;;;;;;;;;;;;

  .org    $200
  .byte	"Serpent         "
  .byte	"Snake on the VMS - Jahan Addison"

	.org	$240

	.word	2,10

	.org	$260

	.word	$0000, $fcfc, $f0a0, $f0f0, $fccf, $f00a, $f00f, $ffff
	.word	$ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff

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


  ;;;;;;;;;;;;;;;;
  ;; Game Start ;;
  ;;;;;;;;;;;;;;;;

start:
	clr1 ie, 7
	mov #$a1, ocr
	mov #$09, mcr
	mov #$80, vccr
	clr1 p3int, 0
	clr1 p1, 7
	mov #$ff, p3

  call clrscr
  mov #0, xbnk

	clr1 psw,1
	ld $1c
	xor $1d
	set1 psw,1
	st seed

  mov #31, serpent_x1
  mov #$f, serpent_y1
  mov #0, food_reset
  mov #31, B
  mov #15, C
  call pixel_draw

  mov #1, serpent_size
  mov #1, serpent_speed
  mov #1, serpent_piece

  mov #serpent_x1, piece_ptr_x
  mov #serpent_y1, piece_ptr_y

  mov #0, direction

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; set_serpent_food
  ;;
  ;; Place food at a random pixel X (8-39) and Y (4-27), and clear of all edges.
  ;;
  ;; Set food_reset to 1 after drawing.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.set_serpent_food:
  clr1 ocr,5

  call random
  and #$1f
  add #8
  st food_x

  call random
  and #$17
  add #4
  st food_y

  push b
  push c
  push 2
  push xbnk
  ld food_x
  st B
  ld food_y
  st C
  call pixel_draw
  pop xbnk
  pop 2
  pop c
  pop b

  set1 ocr,5
  mov #1, food_reset

  ;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Do we have a winner? ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;
  ld serpent_size
  be #7, .gameover
  br .gameloop
  .gameover:
  call gameover

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; gameloop
  ;;
  ;; Reload head coords into B, C registers; respawn food if needed, then read keys.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.gameloop:
  ld serpent_piece
  dec acc
  add acc
  add #serpent_x1
  st piece_ptr_x
  add #1
  st piece_ptr_y
  ld @R0
  st B
  ld @R1
  st C

  ld serpent_size
  be #7, .gameover

  ld food_reset
  bnz .keypress
  jmpf .set_serpent_food

  ;;;;;;;;;;;;;;
  ;; keypress ;;
  ;;;;;;;;;;;;;;

.keypress:
  call getkeys
  bn acc,4,.gameloop
  bn acc,5,.gameloop
  bn acc,3,.setdirection_right
  bn acc,2,.setdirection_left
  bn acc,1,.setdirection_down
  bn acc,0,.setdirection_up

  br .gamemove

  .setdirection_right:
  mov #1, direction
  br .gamemove
  .setdirection_left:
  mov #3, direction
  br .gamemove
  .setdirection_down:
  mov #2, direction
  br .gamemove
  .setdirection_up:
  mov #0, direction
  br .gamemove

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; gamemove
  ;;
  ;; Dispatch to the correct move subroutine, draw the new head pixel, then
  ;; check for food collection before cascading body coordinates.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.gamemove:
  ld direction
  be #0,.moveup
  be #1,.moveright
  be #2,.movedown
  be #3,.moveleft

  .moveright:
  call moveright
  br .done
  .moveleft:
  call moveleft
  br .done
  .movedown:
  call movedown
  br .done
  .moveup:
  call moveup
  br .done

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; done
  ;;
  ;; Draw the new head pixel. The previous head stays "lit" as it becomes piece 2
  ;; after the coordinate cascade below.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .done:
  push b
  push c
  push 2
  push xbnk
  call pixel_draw
  pop xbnk
  pop 2
  pop c
  pop b

  ld food_reset
  be #0, .check_trail

  ld B
  xor food_x
  bnz .check_trail
  ld C
  xor food_y
  bnz .check_trail
  ld serpent_size
  be #7, .check_trail
  inc serpent_size
  ld serpent_size
  st shift_i
  mov #0, food_reset
  mov #$FF, food_x
  mov #$FF, food_y
  jmpf .trail_shift

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; check_trail
  ;;
  ;; Erase the tail-tip pixel and load tail coords for the cascade. At size 1 the
  ;; tail is the head, so the index math yields piece_ptr_x = &x[1] as expected.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .check_trail:
  ld serpent_size
  st shift_i
  dec acc
  add acc
  add #serpent_x1
  st piece_ptr_x
  add #1
  st piece_ptr_y
  ld @R0
  st tail_x
  ld @R1
  st tail_y
  push b
  push c
  push 2
  push xbnk
  ld tail_x
  st B
  ld tail_y
  st C
  call pixel_erase
  pop xbnk
  pop 2
  pop c
  pop b

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; trail_shift
  ;;
  ;; Cascade body coordinates tail-ward, then commit the new head into x1/y1.
  ;; Piece 2 is already lit from the pixel_draw above; no redraw needed.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .trail_shift:
  call shift_trail
  ld B
  st serpent_x1
  ld C
  st serpent_y1

  .trail_done:
  call waitkeys
  jmpf .gameloop


  ;;;;;;;;;;;;;;;;;
  ;; Subroutines ;;
  ;;;;;;;;;;;;;;;;;


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; pixel_addr
  ;;
  ;; Load R2 and xbnk with the XRAM byte address for a given `(B, C)` position,
  ;; using the same pair formula as `.set_serpent_food`.
  ;;
  ;; @params  B = byte column (0-6), C = row (0-31)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pixel_addr:
  push acc
  ld C
  bn acc,4,.pa_bank0
  mov #1,xbnk
  sub #16
  br .pa_row
  .pa_bank0:
  mov #0,xbnk
  .pa_row:
  push acc
  and #$E
  clr1 psw,7
  rol
  rol
  rol
  add #$80
  st 2
  pop acc
  bn acc,0,.pa_even
  ld 2
  add #6
  st 2
  .pa_even:
  ld 2
  add B
  st 2
  pop acc
  ret

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; pixel_draw
  ;;
  ;; Light a single pixel at pixel X (0-47) / row (0-31). Derives byte_col =
  ;; B >> 3 and bit mask = $80 >> (B & 7), then ORs the mask into the XRAM byte
  ;; located by pixel_addr. Clobbers B (set to byte_col on exit).
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pixel_draw:
  push acc
  ld B
  clr1 psw,7
  rorc
  clr1 psw,7
  rorc
  clr1 psw,7
  rorc
  and #$3f
  st pixel_byte_col
  ld B
  and #7
  st pixel_shift
  mov #$80, pixel_mask_val
.pdm:
  ld pixel_shift
  be #0, .pdd
  ld pixel_mask_val
  clr1 psw,7
  rorc
  st pixel_mask_val
  dec pixel_shift
  br .pdm
.pdd:
  ld pixel_byte_col
  st B
  call pixel_addr
  ld @R2
  or pixel_mask_val
  st @R2
  pop acc
  ret

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; pixel_erase
  ;;
  ;; Dark a single pixel at pixel X (0-47) / row (0-31). Identical setup to
  ;; pixel_draw, but XORs the mask with $FF and ANDs rather than ORs.
  ;; Clobbers B (set to byte_col on exit).
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pixel_erase:
  push acc
  ld B
  clr1 psw,7
  rorc
  clr1 psw,7
  rorc
  clr1 psw,7
  rorc
  and #$3f
  st pixel_byte_col
  ld B
  and #7
  st pixel_shift
  mov #$80, pixel_mask_val
.pem:
  ld pixel_shift
  be #0, .ped
  ld pixel_mask_val
  clr1 psw,7
  rorc
  st pixel_mask_val
  dec pixel_shift
  br .pem
.ped:
  ld pixel_mask_val
  xor #$FF
  st pixel_mask_val
  ld pixel_byte_col
  st B
  call pixel_addr
  ld @R2
  and pixel_mask_val
  st @R2
  pop acc
  ret

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; shift_trail
  ;;
  ;; Cascade coordinates tail-ward: piece[i] = piece[i-1] for i descending from
  ;; shift_i to 2, so piece 2 inherits the old head position. Caller must store
  ;; the current serpent_size into shift_i before calling.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
shift_trail:
  push b
  push c
  push acc
  ld shift_i
  be #1, .st_done
  .st_loop:
  ld shift_i
  be #1, .st_done
  dec acc
  add acc
  add #serpent_x1
  st piece_ptr_x
  add #1
  st piece_ptr_y
  dec piece_ptr_x
  dec piece_ptr_x
  ld @R0
  inc piece_ptr_x
  inc piece_ptr_x
  st @R0
  dec piece_ptr_y
  dec piece_ptr_y
  ld @R1
  inc piece_ptr_y
  inc piece_ptr_y
  st @R1
  dec shift_i
  br .st_loop
  .st_done:
  pop acc
  pop c
  pop b
  ret

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; waitkeys
  ;;
  ;; Poll P3 for ~0.5s (30 passes of a 256-cycle busy-wait), latching direction
  ;; on the first arrow press. Returns after the full dwell whether or not a key
  ;; was pressed, giving the serpent its movement cadence.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
waitkeys:
  push b
  push c
  mov #30,b
.wkouter:
  mov #0,c
.wkinner:
  dbnz c,.wkinner
  ld p3
  bn acc,3,.wkright
  bn acc,2,.wkleft
  bn acc,1,.wkdown
  bn acc,0,.wkup
  dbnz b,.wkouter
  pop c
  pop b
  ret
.wkright:
  mov #1,direction
  dbnz b,.wkouter
  pop c
  pop b
  ret
.wkleft:
  mov #3,direction
  dbnz b,.wkouter
  pop c
  pop b
  ret
.wkdown:
  mov #2,direction
  dbnz b,.wkouter
  pop c
  pop b
  ret
.wkup:
  mov #0,direction
  dbnz b,.wkouter
  pop c
  pop b
  ret

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; move routines
  ;;
  ;; Increment or decrement C (pixel Y) or B (pixel X) by one.
  ;;
  ;; Calls gameover if the move would "collide" with LCD screen boundary.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveup:
  ld C
  be #0,.halt
  dec C
  ret
  .halt:
  call gameover

movedown:
  ld C
  be #$1f,.halt
  inc C
  ret
  .halt:
  call gameover

moveright:
  ld B
  be #47,.halt
  inc B
  ret
  .halt:
  call gameover

moveleft:
  ld B
  be #0,.halt
  dec B
  ret
  .halt:
  call gameover

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; pause routines
  ;;
  ;; Software busy loops of ~1s, ~0.5s, and ~0.25s respectively.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pause:
  push b
  push c
  mov #64,b
.pouter:
  mov #0,c
.pinner:
  dbnz c,.pinner
  dbnz b,.pouter
  pop c
  pop b
  ret

pausehalf:
  push b
  push c
  mov #32,b
.phouter:
  mov #0,c
.phinner:
  dbnz c,.phinner
  dbnz b,.phouter
  pop c
  pop b
  ret

pausequarter:
  push b
  push c
  mov #16,b
.pqouter:
  mov #0,c
.pqinner:
  dbnz c,.pqinner
  dbnz b,.pqouter
  pop c
  pop b
  ret

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; random
  ;;
  ;; Pseudo-random byte in acc and updates seed in-place.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
random:
	push b
	push c
	ld seed
	st b
	mov #$4e,acc
	mov #$6d,c
	mul
	st b
	ld c
	add #$39
	st seed
	ld b
	addc #$30
	pop c
	pop b
	ret

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; clrscr
  ;;
  ;; Zero every addressable byte in both XRAM banks, clearing the LCD frame buffer.
  ;; Skips the 4-byte inter-row gaps maintained by the row-pair formula.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; setscr
  ;;
  ;; Copy $C0 bytes from ROM (addressed by trl/trh) into both XRAM banks, using
  ;; the same formula as clrscr. Caller sets trl and trh before the call.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; getkeys
  ;;
  ;; Read P3 and return the raw active-low byte. Branches to goodbye if docked or
  ;; MODE is held; on SLEEP it blanks the LCD, halts, then resumes on wake.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getkeys:
  bp p7,0,quit
  ld p3
  bn acc,6,quit
  bn acc,7,sleep
  ret
quit:
  jmp goodbye

sleep:
  bn p3,7,sleep
  mov #0,vccr
sleepmore:
  set1 pcon,0
  bp p7,0,quit
  bp p3,7,sleepmore
  mov #$80,vccr
waitsleepup:
  bn p3,7,waitsleepup
  br getkeys


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; gameover
  ;;
  ;; Blit the gameover bitmap and spin forever. Only a power-cycle escapes.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gameover:
  mov #<gameover_screen,trl
  mov #>gameover_screen,trh
  call setscr
.forever:
  br .forever

gameover_screen:
  .byte $00,$00,$00,$00,$00,$00
  .byte $00,$1C,$10,$89,$F0,$00
  .byte $00,$20,$28,$D9,$00,$00
  .byte $00,$2C,$44,$A9,$00,$00
  .byte $00,$26,$7C,$89,$E0,$00
  .byte $00,$22,$44,$89,$00,$00
  .byte $00,$22,$44,$89,$00,$00
  .byte $00,$1C,$44,$89,$F0,$00
  .byte $00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00
  .byte $00,$1C,$44,$F9,$E0,$00
  .byte $00,$22,$44,$81,$08,$00
  .byte $00,$22,$44,$81,$08,$00
  .byte $00,$22,$44,$F1,$E0,$00
  .byte $00,$22,$28,$81,$40,$00
  .byte $00,$22,$28,$81,$20,$00
  .byte $00,$1C,$10,$F9,$08,$00


  .cnop   0,$200
