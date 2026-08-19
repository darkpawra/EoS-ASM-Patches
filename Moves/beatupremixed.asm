; -------------------------------------------------------------------------
; Darkpawra 01/08/2026 - Tested 01/08/2026
; Beat Up targets, and has a different effect depending on if it targets a foe or ally.
; Foe: Deals damage and then calls all teammates to your side.
; Ally: Calls all teammates to your side.
; Based on the template provided by https://github.com/SkyTemple
; Uses the naming conventions from https://github.com/UsernameFodder/pmdsky-debug
; -------------------------------------------------------------------------

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x2598

; For US
.definelabel MoveStartAddress, 0x2330134
.definelabel MoveJumpAddress, 0x23326CC
.definelabel DealDamage, 0x2332B20
.definelabel DoMoveBeatUp, 0x232B024

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0

; File creation
.create "./code_out.bin", 0x02330134
    .org MoveStartAddress
    .area MaxSize
		sub r13, r13, #0x4
		
		ldr   r3,[r4,#0xB4]
        ldrb  r0,[r3,#0x6]
        ldrb  r1,[r3,#0x8]
        eor   r2,r0,r1 ; 1 = enemy, 0 = friend
        ldr   r3,[r9,#0xB4]
        ldrb  r0,[r3,#0x6]
        ldrb  r1,[r3,#0x8]
        eor   r3,r0,r1 ; 1 = enemy, 0 = friend
        cmp   r3,r2
        beq   no_damage
        
        ; Damage the target.
        str r7,[r13,#0x0]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; 1.0x, Normal Damage *(See Note 1 Below)
        bl  DealDamage
		
	no_damage:        
		; Performs Beat Up's original effect.
		mov r0,r9
		mov r1,r4
		mov r2,r8
		mov r3,r7
		bl DoMoveBeatUp
		mov r0,#0x1
		mov r10,r0
        
    return:
		add r13, r13, #0x4
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1