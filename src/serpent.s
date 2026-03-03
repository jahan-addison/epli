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

  ;;;;;;;;;;;;;;;;;;;
  ;; Serpent state ;;
  ;;;;;;;;;;;;;;;;;;;

piece_ptr_x = $00   ; R0: pointer to active piece's x coordinates
piece_ptr_y = $01   ; R1: pointer to active piece's y coordinates

  ;; Direction values: up = 0, right = 1, down = 2, left = 3
direction = $30       ; serpent direction
serpent_size = $31    ; size of serpent, set to 1 at game start, winning size is 7
serpent_speed = $35   ; speed of serpent, "1" at game start

  ;; The "food" that the serpent eats
food_x = $36          ; horizontal position of food on screen
food_y = $37          ; vertical position of food on screen
food_reset = $4F      ; flag to indicate if food needs to be placed, set to 0 at start
seed = $38            ; random seed

  ;; Tail rendering state
trail_pv   = $47    ; pixel value at old head position, saved before each move
trail_r2lo = $49    ; R2 address byte of old head position, saved before each move
trail_bank = $4A    ; xbnk at old head position, saved before each move
tail_x     = $4B    ; byte column of old tail tip, saved before the coord shift
tail_y     = $4C    ; row of old tail tip, saved before the coord shift
shift_i    = $4D    ; descending loop counter used by `shift_trail`

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


  ;;;;;;;;;;;;
  ;; Header ;;
  ;;;;;;;;;;;;

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
  ;;;;;;;;;;;
  ;; setup ;;
  ;;;;;;;;;;;
	clr1 ie, 7
	mov #$a1, ocr
	mov #$09, mcr
	mov #$80, vccr
	clr1 p3int, 0
	clr1 p1, 7
	mov #$ff, p3

  call clrscr
  mov #0, xbnk  ; ensure we draw into bank 0 (upper screen)

  ;; set random seed
	clr1 psw,1  ; get random seed from current minute and
	ld $1c  ; second system variables
	xor $1d
	set1 psw,1
	st seed

  ;; set initial state
  mov #3, serpent_x1
  mov #$f, serpent_y1
  mov #0, food_reset
  mov #$F8,2
  mov #$1,@R2

  ;; direction values: up = 0, right = 1, down = 2, left = 3
  ;; set direction, speed, and size
  mov #1, serpent_size
  mov #1, serpent_speed
  mov #1, serpent_piece

  mov #serpent_x1, piece_ptr_x
  mov #serpent_y1, piece_ptr_y

  mov #0, direction  ; set initial direction (up)

.set_serpent_food:
  clr1 ocr,5
  push 2
  push xbnk

  ;; random byte column 1-4 (pixels 8-40, 8px clear of each edge)
  call random
  and #$3             ; 0-3
  add #1              ; 1-4
  st food_x

  ;; random row 4-27 (4 rows clear of top and bottom edges)
  call random
  and #$17            ; 0-23 (max of 0x17 = 23)
  add #4              ; 4-27
  st food_y

  ;; select bank: bit 4 set = rows 16-31 = bank 1
  ld food_y
  bn acc,4,.fbank0
  mov #1,xbnk
  sub #16             ; normalize to 0-15 for address
  br .faddr
  .fbank0:
  mov #0,xbnk         ; acc = food_y (already 0-15)

  .faddr:
  ;; acc = row (0-15)
  ;; addr_lo = $80 + (row & $E)*8 + (row & 1)*6 + food_x
  push acc            ; save row
  and #$E             ; pair*2 (clear bit 0)
  clr1 psw,7          ; clear carry before shifts
  rol                 ; pair*4
  rol                 ; pair*8
  rol                 ; pair*16
  add #$80            ; add XRAM low-byte base
  st 2                ; store even-row base into R2
  pop acc             ; restore row
  bn acc,0,.feven     ; bit 0 clear = even row, skip
  ld 2
  add #6
  st 2
  .feven:
  ld 2
  add food_x
  st 2                ; R2 = XRAM address of food byte
  mov #$80,@R2        ; draw food pixel (MSB = leftmost pixel of byte)

  pop xbnk
  pop 2
  set1 ocr,5
  mov #1, food_reset

  ;;;;;;;;;;;;;;;;
  ;; Game Start ;;
  ;;;;;;;;;;;;;;;;

.gameloop:
  ;; set piece_ptr_x and piece_ptr_y from serpent_piece
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

  ld food_reset
  be #0, .set_serpent_food

  ; get key pressed
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

.gamemove:
  ;; save the head's XRAM byte and address before the move subroutine erases it
  ld 2
  st trail_r2lo
  ld xbnk
  st trail_bank
  ld @R2
  st trail_pv

  ;; set direction: 0=up 1=right 2=down 3=left
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

  .done:
  ;; save new head coordinates into `serpent_x1` / `serpent_y1`
  ld B
  st @R0
  ld C
  st @R1

  ;; food check: xor byte-column then row - both zero means the head
  ;; occupies the same XRAM byte as the food pixel
  ld serpent_x1
  xor food_x
  bnz .check_trail
  ld serpent_y1
  xor food_y
  bnz .check_trail
  ;; food eaten: grows up to `serpent_size` 7, then re-queue placement next frame
  ld serpent_size
  be #7, .check_trail
  inc serpent_size
  mov #0, food_reset
  ;; cascade trail coords so the new piece 2 gets the old head slot;
  ;; skip only the tail-erase, not the shift
  jmpf .trail_shift

  .check_trail:
  ;; erase the old tail-tip pixel before cascading coordinates toward the back
  ld serpent_size
  be #1, .trail_shift       ; size 1 has no trailing pixels to manage
  dec acc                   ; size - 1
  add acc                   ; (size - 1) * 2
  add #serpent_x1
  st piece_ptr_x            ; R0 → x[serpent_size]
  add #1
  st piece_ptr_y            ; R1 → y[serpent_size]
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
  call pixel_addr           ; set R2 and xbnk to old tail tip's XRAM byte
  mov #0, @R2               ; erase old tail tip
  pop xbnk
  pop 2
  pop c
  pop b

  .trail_shift:
  call shift_trail          ; cascade piece[i] = piece[i-1] from size down to 2

  .trail_redraw:
  ;; re-draw piece 2 at the old head position: the move subroutine erased that byte
  ld serpent_size
  be #1, .trail_done
  push 2
  push xbnk
  ld trail_bank
  st xbnk
  ld trail_r2lo
  st 2
  ld trail_pv
  st @R2
  pop xbnk
  pop 2

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
  push acc              ; save row (0-15)
  and #$E               ; row-pair  index: (row & ~1)
  clr1 psw,7
  rol                   ; * 2
  rol                   ; * 4
  rol                   ; * 8 = byte offset within bank
  add #$80              ; XRAM bank base
  st 2
  pop acc               ; restore row
  bn acc,0,.pa_even
  ld 2
  add #6                ; odd row: 6 bytes past the even row base
  st 2
  .pa_even:
  ld 2
  add B                 ; add byte column
  st 2
  pop acc
  ret

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; shift_trail
  ;;
  ;; Cascade each piece coordinate toward the tail: piece[i] = piece[i-1]
  ;; for i descending from `serpent_size` to 2, so piece 2 claims the old head slot.
  ;;
  ;; @params  serpent_size = active trail length (1-7)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
shift_trail:
  push b
  push c
  push acc
  ld serpent_size
  be #1, .st_done           ; size 1 has no pieces to cascade
  st shift_i
  .st_loop:
  ld shift_i
  be #1, .st_done
  ;; point R0/R1 at piece[i]: addr = serpent_x1 + (i - 1) * 2
  dec acc                   ; i - 1
  add acc                   ; (i - 1) * 2
  add #serpent_x1
  st piece_ptr_x            ; R0 = &x[i]
  add #1
  st piece_ptr_y            ; R1 = &y[i]
  ;; read x[i-1] by stepping R0 back one coord pair (2 bytes)
  dec piece_ptr_x
  dec piece_ptr_x           ; R0 = &x[i-1]
  ld @R0
  inc piece_ptr_x
  inc piece_ptr_x           ; R0 = &x[i]
  st @R0                    ; x[i] = x[i-1]
  ;; read y[i-1] by stepping R1 back one coord pair
  dec piece_ptr_y
  dec piece_ptr_y           ; R1 = &y[i-1]
  ld @R1
  inc piece_ptr_y
  inc piece_ptr_y           ; R1 = &y[i]
  st @R1                    ; y[i] = y[i-1]
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
  ;; Loop for ~0.5s polling P3 arrow keys every ~16ms, writing direction to RAM
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
waitkeys:
  push b
  push c
  mov #30,b           ; 30 polls x ~512 cycles each ~= 0.47 s
.wkouter:
  mov #0,c            ; 256-cycle inner busy-wait
.wkinner:
  dbnz c,.wkinner
  ld p3               ; sample keys directly -- active low (0 = pressed)
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
  ;; moveup
  ;;
  ;; Move the current serpent pixel one row up in the XRAM frame buffer, crossing
  ;; the bank boundary from bank 1 to bank 0 when necessary
  ;;
  ;; @params  B = byte column, C = current row (0-31)
  ;; @returns B = byte column, C = new row
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; movedown
  ;;
  ;; Move the active serpent pixel one row down in the XRAM frame buffer, crossing
  ;; the bank boundary from bank 0 to bank 1 when necessary
  ;;
  ;; @params  B = byte column, C = current row (0-31)
  ;; @returns B = byte column, C = new row
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; moveright
  ;;
  ;; Move the active serpent pixel one position right within the current XRAM row,
  ;; carrying the bit across byte boundaries
  ;;
  ;; @params  B = byte column (0-6), C = current row
  ;; @returns B = new byte column, C = row (unchanged)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveright:
  clr1 ocr,5
  ld B
  ; check if buffer cannot move right any further
  be #6,.halt
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
  .halt:
  call gameover
  .rightdone:
  inc B
  .right:
  set1 ocr,5
  ret


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; moveleft
  ;;
  ;; Move the active serpent pixel one position left within the current XRAM row,
  ;; carrying the bit across byte boundaries
  ;;
  ;; @params  B = byte column (0-6), C = current row
  ;; @returns B = new byte column, C = row (unchanged)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveleft:
  clr1 ocr,5
  ld B
  ; check if buffer cannot move left any further
  be #0,.halt
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

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; pause
  ;;
  ;; Pause for approximately one second using a software busy-wait loop
  ;;
  ;; b x 256 inner x 2-cycle dbnz = 1s
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; pausehalf
  ;;
  ;; Pause for approximately half a second using a software busy-wait loop
  ;;
  ;; b x 256 inner x 2-cycle dbnz = 0.5s
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; pausequarter
  ;;
  ;; Pause for approximately a quarter second using a software busy-wait loop
  ;;
  ;; b x 256 inner x 2-cycle dbnz = 0.25s
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
  ;; Generate a pseudo-random value in the range 0-255
  ;;
  ;; @returns acc = random, seed is updated for next call
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
  ;; Zero all bytes in both XRAM banks, clearing the LCD frame buffer
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
  ;; Copy a predefined full-screen image to the screen
  ;;
  ;; @params trl = low byte of predefined screen ROM address
  ;;         trh = high byte of predefined screen ROM address
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
  ;; Read P3, check dock detection and the SLEEP key before returning.
  ;;
  ;; Branch to goodbye if docked or MODE is held; enters halt loop on SLEEP
  ;;
  ;; @returns acc = raw P3 byte (active-low; caller masks individual bits)
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
  ;; Display "GAME" on the top row and "OVER" on the bottom row
  ;; of the LCD, then halt forever (only a power-cycle escapes)
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
