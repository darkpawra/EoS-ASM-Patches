; -------------------------------------------------------------------------
; Jawshoeuh 01/08/2023 - Confirmed Working 10/30/2024
; Lunge deals damage and lower target's attack.
; Based on the template provided by https://github.com/SkyTemple
; Uses the naming conventions from https://github.com/UsernameFodder/pmdsky-debug
; -------------------------------------------------------------------------

.relativeinclude on
.nds
.arm

.definelabel MaxSize, 0x2598

.definelabel MoveStartAddress, 0x2330134
.definelabel MoveJumpAddress, 0x023326CC
.definelabel DealDamage, 0x2332B20
.definelabel DungeonRandOutcomeUserTargetInteraction, 0x2324934
.definelabel LowerOffensiveStat, 0x23135fc

; Constants
.definelabel TRUE, 0x1
.definelabel FALSE, 0x0
.definelabel PHYSICAL_STAT, 0x0
.definelabel SPECIAL_STAT, 0x1

; File creation
.create "./code_out.bin", 0x2330134 ; Change to 0x2330B74 for EU.
    .org MoveStartAddress
    .area MaxSize
        sub sp,sp,#0x8
        mov r10,FALSE
        
        ; Damage the target.
        str r7,[sp,#0x0]
        mov r0,r9
        mov r1,r4
        mov r2,r8
        mov r3,#0x100 ; 1.0x, Normal Damage *(See Note 1 Below)
        bl  DealDamage
        
        ; Check for succesful hit.
        cmp r0,#0
        beq return
        mov r10,TRUE
        
        ; Attempt to apply secondary effects (fails if the target has
        ; fainted or has Shield Dust).
        mov r0,r9
        mov r1,r4
        mov r2,#0 ; Always, 100% chance.
        bl  DungeonRandOutcomeUserTargetInteraction
        cmp r0,FALSE
        beq return
        
        ; Lower attack by one!
        mov r3,FALSE
        str r10,[sp,#0x0]
        str r3,[sp,#0x4]
        mov r0,r9
        mov r1,r4
        mov r2,PHYSICAL_STAT
        mov r3,#1 ; 1 stage
        bl  LowerOffensiveStat

    return:
        add sp,sp,#0x8
        b   MoveJumpAddress
        .pool
    .endarea
.close

; Note 1: The game uses the 8 bits at the end as a kind of fraction/decimal
; where the denominator is 256. So in this context, 0x100 means
; (256/256) = 1