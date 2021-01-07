LoadMap: ; c000 (3:4000)
	call DisableLCD
	call EnableSRAM
	bank1call DiscardSavedDuelData
	call DisableSRAM
	ld a, GAME_EVENT_OVERWORLD
	ld [wGameEvent], a
	xor a
	ld [wd10f], a
	ld [wd110], a
	ld [wMatchStartTheme], a
	farcall Func_10a9b
	call WhiteOutDMGPals
	call ZeroObjectPositions
	xor a
	ld [wTileMapFill], a
	call LoadSymbolsFont
	call Set_OBJ_8x8
	xor a
	ld [wLineSeparation], a
	xor a
	ld [wd291], a
.asm_c037
	farcall Func_10ab4
	call WhiteOutDMGPals
	call Func_c241
	call EmptyScreen
	call Func_3ca0
	ld a, PLAYER_TURN
	ldh [hWhoseTurn], a
	farcall Func_1c440
	ld a, [wTempMap]
	ld [wCurMap], a
	ld a, [wTempPlayerXCoord]
	ld [wPlayerXCoord], a
	ld a, [wTempPlayerYCoord]
	ld [wPlayerYCoord], a
	call Func_c36a
	call Func_c184
	call Func_c49c
	farcall Func_80000
	call Func_c4b9
	call Func_c943
	call Func_c158
	farcall Func_80480
	call Func_c199
	xor a
	ld [wd0b4], a
	ld [wd0c1], a
	call Func_39fc
	farcall Func_10af9
	call Func_c141
	call Func_c17a
.asm_c092
	call DoFrameIfLCDEnabled
	call SetScreenScroll
	call HandleOverworldMode
	ld hl, wd0b4
	ld a, [hl]
	and $d0
	jr z, .asm_c092
	call DoFrameIfLCDEnabled
	ld hl, wd0b4
	ld a, [hl]
	bit 4, [hl]
	jr z, .asm_c0b6
	ld a, SFX_0C
	call PlaySFX
	jp .asm_c037
.asm_c0b6
	farcall Func_10ab4
	call Func_c1a0
	ld a, [wMatchStartTheme]
	or a
	jr z, .asm_c0ca
	call Func_c280
	farcall Duel_Init
.asm_c0ca
	call Func_c280
	ret

HandleOverworldMode: ; c0ce (3:40ce)
	ld a, [wOverworldMode]
	res 7, a
	rlca
	add LOW(OverworldModePointers)
	ld l, a
	ld a, HIGH(OverworldModePointers)
	adc $0
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

OverworldModePointers: ; c0e0 (3:40e0)
	dw Func_c0e8         ; on map
	dw CallHandlePlayerMoveMode
	dw SetScriptData
	dw EnterScript

Func_c0e8: ; c0e8 (3:40e8)
	farcall Func_10e55
	ret

CallHandlePlayerMoveMode: ; c0ed (3:40ed)
	call HandlePlayerMoveMode
	ret

SetScriptData: ; c0f1 (3:40f1)
	ld a, [wScriptNPC]
	ld [wLoadedNPCTempIndex], a
	farcall SetNewScriptNPC
	ld a, c
	ld [wNextScript], a
	ld a, b
	ld [wNextScript+1], a
	ld a, $3
	ld [wOverworldMode], a
	jr EnterScript

EnterScript: ; c10a (3:410a)
	ld hl, wNextScript
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

; closes dialogue window. seems to be for other things as well.
CloseAdvancedDialogueBox: ; c111 (3:4111)
	ld a, [wd0c1]
	bit 0, a
	call nz, CloseTextBox
	ld a, [wd0c1]
	bit 1, a
	jr z, .asm_c12a
	ld a, [wScriptNPC]
	ld [wLoadedNPCTempIndex], a
	farcall Func_1c5e9
.asm_c12a
	xor a
	ld [wd0c1], a
	ld a, [wd0c0]
	ld [wOverworldMode], a
	ret

; redraws the background and removes textbox control
CloseTextBox: ; c135 (3:4135)
	push hl
	farcall Func_80028
	ld hl, wd0c1
	res 0, [hl]
	pop hl
	ret

Func_c141: ; c141 (3:4141)
	ld hl, wd0c2
	ld a, [hl]
	or a
	ret z
	push af
	xor a
	ld [hl], a
	pop af
	dec a
	ld hl, PointerTable_c152
	jp JumpToFunctionInTable

PointerTable_c152: ; c152 (3:4152)
	dw Func_c9bc
	dw Func_fc2b
	dw Func_fcad

Func_c158: ; c158 (3:4158)
	ld a, [wd0c2]
	cp $1
	ret nz
	ld a, [wd0c4]
	ld [wTempNPC], a
	call FindLoadedNPC
	jr c, .asm_c179
	ld a, [wLoadedNPCTempIndex]
	ld l, LOADED_NPC_DIRECTION
	call GetItemInLoadedNPCIndex
	ld a, [wd0c5]
	ld [hl], a
	farcall Func_1c58e
.asm_c179
	ret

Func_c17a: ; c17a (3:417a)
	ld a, [wOverworldMode]
	cp $3
	ret z
	call Func_c9b8
	ret

Func_c184: ; c184 (3:4184)
	push bc
	ld c, $1
	ld a, [wCurMap]
	cp OVERWORLD_MAP
	jr nz, .asm_c190
	ld c, $0
.asm_c190
	ld a, c
	ld [wOverworldMode], a
	ld [wd0c0], a
	pop bc
	ret

Func_c199: ; c199 (3:4199)
	ld hl, Func_380e
	call SetDoFrameFunction
	ret

Func_c1a0: ; c1a0 (3:41a0)
	call ResetDoFrameFunction
	ret

WhiteOutDMGPals: ; c1a4 (3:41a4)
	xor a
	call SetBGP
	xor a
	call SetOBP0
	xor a
	call SetOBP1
	ret

Func_c1b1: ; c1b1 (3:41b1)
	ld a, $c
	ld [wd32e], a
	ld a, $0
	ld [wTempMap], a
	ld a, $c
	ld [wTempPlayerXCoord], a
	ld a, $c
	ld [wTempPlayerYCoord], a
	ld a, $2
	ld [wTempPlayerDirection], a
	call Func_c9cb
	call Func_c9dd
	farcall Func_80b7a
	farcall Func_1c82e
	farcall Func_131b3
	xor a
	ld [wPlayTimeCounter + 0], a
	ld [wPlayTimeCounter + 1], a
	ld [wPlayTimeCounter + 2], a
	ld [wPlayTimeCounter + 3], a
	ld [wPlayTimeCounter + 4], a
	ret

Func_c1ed: ; c1ed (3:41ed)
	call Func_c9cb
	farcall Func_11416
	call Func_c9dd
	ret

Func_c1f8: ; c1f8 (3:41f8)
	xor a
	ld [wd0b8], a
	ld [wd0b9], a
	ld [wd0ba], a
	ld [wd11b], a
	ld [wd0c2], a
	ld [wd111], a
	ld [wd112], a
	ld [wd3b8], a
	call EnableSRAM
	ld a, [sAnimationsDisabled]
	ld [wAnimationsDisabled], a
	ld a, [s0a006]
	ld [wTextSpeed], a
	call DisableSRAM
	farcall Func_10756
	ret

Func_c228: ; c228 (3:4228)
	ld a, [wCurMap]
	ld [wTempMap], a
	ld a, [wPlayerXCoord]
	ld [wTempPlayerXCoord], a
	ld a, [wPlayerYCoord]
	ld [wTempPlayerYCoord], a
	ld a, [wPlayerDirection]
	ld [wTempPlayerDirection], a
	ret

Func_c241: ; c241 (3:4241)
	push hl
	push bc
	push de
	lb de, $30, $7f
	call SetupText
	call Func_c258
	pop de
	pop bc
	pop hl
	ret

Func_c251: ; c251 (3:4251)
	ldh a, [hffb0]
	push af
	ld a, $1
	jr asm_c25d

Func_c258: ; c258 (3:4258)
	ldh a, [hffb0]
	push af
	ld a, $2
asm_c25d:
	ldh [hffb0], a
	push hl
	call Func_c268
	pop hl
	pop af
	ldh [hffb0], a
	ret

Func_c268: ; c268 (3:4268)
	ld hl, Unknown_c27c
.asm_c26b
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	or h
	jr z, .asm_c27a
	call ProcessTextFromID
	pop hl
	inc hl
	inc hl
	jr .asm_c26b
.asm_c27a
	pop hl
	ret

Unknown_c27c: ; c27c (3:427c)
	INCROM $c27c, $c280

Func_c280: ; c280 (3:4280)
	call Func_c228
	call Func_3ca0
	call ZeroObjectPositions
	ld hl, wVBlankOAMCopyToggle
	inc [hl]
	call EnableLCD
	call DoFrameIfLCDEnabled
	call DisableLCD
	farcall Func_12871
	ret

Func_c29b: ; c29b (3:429b)
	push hl
	ld hl, wd0c1
	or [hl]
	ld [hl], a
	pop hl
	ret

Func_c2a3: ; c2a3 (3:42a3)
	push hl
	push bc
	push de
	call Func_c335
	farcall Func_10ab4
	ld a, $80
	call Func_c29b
	lb de, $30, $7f
	call SetupText
	farcall Func_12ba7
	call Func_3ca0
	call ZeroObjectPositions
	ld a, $1
	ld [wVBlankOAMCopyToggle], a
	call EnableLCD
	call DoFrameIfLCDEnabled
	call DisableLCD
	pop de
	pop bc
	pop hl
	ret

Func_c2d4: ; c2d4 (3:42d4)
	xor a
	ld [wd10f], a
	ld [wd110], a

Func_c2db: ; c2db (3:42db)
	push hl
	push bc
	push de
	call DisableLCD
	call Set_OBJ_8x8
	call Func_3ca0
	farcall Func_12bcd
	ld a, PLAYER_TURN
	ldh [hWhoseTurn], a
	call Func_c241
	call EmptyScreen
	ld a, [wd111]
	push af
	farcall Func_80000
	pop af
	ld [wd111], a
	ld hl, wd0c1
	res 0, [hl]
	call Func_c34e
	farcall Func_12c5e
	farcall Func_1c6f8
	ld hl, wd0c1
	res 7, [hl]
	ld hl, wd10f
	ld a, [hli]
	or [hl]
	jr z, .asm_c323
	ld a, [hld]
	ld l, [hl]
	ld h, a
	call CallHL2
.asm_c323
	farcall Func_10af9
	pop de
	pop bc
	pop hl
	ret

Func_c32b: ; c32b (3:432b)
	ld a, l
	ld [wd10f], a
	ld a, h
	ld [wd110], a
	jr Func_c2db

Func_c335: ; c335 (3:4335)
	ld a, [wOBP0]
	ld [wd10c], a
	ld a, [wOBP1]
	ld [wd10d], a
	ld hl, wObjectPalettesCGB
	ld de, wd0cc
	ld bc, 8 palettes
	call CopyDataHLtoDE_SaveRegisters
	ret

Func_c34e: ; c34e (3:434e)
	ld a, [wd10c]
	ld [wOBP0], a
	ld a, [wd10d]
	ld [wOBP1], a
	ld hl, wd0cc
	ld de, wObjectPalettesCGB
	ld bc, 8 palettes
	call CopyDataHLtoDE_SaveRegisters
	call FlushAllPalettes
	ret

Func_c36a: ; c36a (3:436a)
	xor a
	ld [wd323], a
	ld a, [wCurMap]
	cp POKEMON_DOME_ENTRANCE
	jr nz, .asm_c379
	xor a
	ld [wd324], a
.asm_c379
	ret
; 0xc37a

	INCROM $c37a, $c38f

Func_c38f: ; c38f (3:438f)
	INCROM $c38f, $c3ca

Func_c3ca: ; c3ca (3:43ca)
	INCROM $c3ca, $c3ee

Func_c3ee: ; c3ee (3:43ee)
	INCROM $c3ee, $c41c

Func_c41c: ; c41c (3:441c)
	ld a, [wd332]
	sub $40
	ld [wSCXBuffer], a
	ld a, [wd333]
	sub $40
	ld [wSCYBuffer], a
	call Func_c430
	ret

Func_c430: ; c430 (3:4430)
	push bc
	ld a, [wd237]
	sla a
	sla a
	sla a
	ld b, a
	ld a, [wSCXBuffer]
	cp $b1
	jr c, .asm_c445
	xor a
	jr .asm_c449
.asm_c445
	cp b
	jr c, .asm_c449
	ld a, b
.asm_c449
	ld [wSCXBuffer], a
	ld a, [wd238]
	sla a
	sla a
	sla a
	ld b, a
	ld a, [wSCYBuffer]
	cp $b9
	jr c, .asm_c460
	xor a
	jr .asm_c464
.asm_c460
	cp b
	jr c, .asm_c464
	ld a, b
.asm_c464
	ld [wSCYBuffer], a
	pop bc
	ret

Func_c469: ; c469 (3:4469)
	ld a, [wSCXBuffer]
	add $4
	and $f8
	rrca
	rrca
	rrca
	ld [wd233], a
	ld a, [wSCYBuffer]
	add $4
	and $f8
	rrca
	rrca
	rrca
	ld [wd234], a
	ret

SetScreenScrollWram: ; c484 (3:4484)
	ld a, [wSCXBuffer]
	ld [wSCX], a
	ld a, [wSCYBuffer]
	ld [wSCY], a
	ret

SetScreenScroll: ; c491 (3:4491)
	ld a, [wSCX]
	ldh [hSCX], a
	ld a, [wSCY]
	ldh [hSCY], a
	ret

Func_c49c: ; c49c (3:449c)
	ld a, [wPlayerXCoord]
	and $1f
	ld [wPlayerXCoord], a
	rlca
	rlca
	rlca
	ld [wd332], a
	ld a, [wPlayerYCoord]
	and $1f
	ld [wPlayerYCoord], a
	rlca
	rlca
	rlca
	ld [wd333], a
	ret

Func_c4b9: ; c4b9 (3:44b9)
	xor a
	ld [wVRAMTileOffset], a
	ld [wd4cb], a
	ld a, $1d
	farcall Func_80418
	ld b, $0
	ld a, [wConsole]
	cp $2
	jr nz, .asm_c4d1
	ld b, $1e
.asm_c4d1
	ld a, b
	ld [wd337], a

	; load Player's sprite for overworld
	ld a, SPRITE_OW_PLAYER
	farcall CreateSpriteAndAnimBufferEntry
	ld a, [wWhichSprite]
	ld [wPlayerSpriteIndex], a

	ld b, $2
	ld a, [wCurMap]
	cp OVERWORLD_MAP
	jr z, .asm_c4ee
	ld a, [wTempPlayerDirection]
	ld b, a
.asm_c4ee
	ld a, b
	ld [wPlayerDirection], a
	call UpdatePlayerSprite
	ld a, [wCurMap]
	cp OVERWORLD_MAP
	call nz, Func_c6f7
	xor a
	ld [wPlayerCurrentlyMoving], a
	ld [wd338], a
	ld a, [wCurMap]
	cp OVERWORLD_MAP
	jr nz, .asm_c50f
	farcall Func_10fde
.asm_c50f
	ret

HandlePlayerMoveMode: ; c510 (3:4510)
	ld a, [wPlayerSpriteIndex]
	ld [wWhichSprite], a
	ld a, [wPlayerCurrentlyMoving]
	bit 4, a
	ret nz
	bit 0, a
	call z, HandlePlayerMoveModeInput
	ld a, [wPlayerCurrentlyMoving]
	or a
	jr z, .notMoving
	bit 0, a
	call nz, Func_c66c
	ld a, [wPlayerCurrentlyMoving]
	bit 1, a
	call nz, Func_c6dc
	ret
.notMoving
	ldh a, [hKeysPressed]
	and START
	call nz, OpenStartMenu
	ret

Func_c53d: ; c53d (3:453d)
	ld a, [wPlayerSpriteIndex]
	ld [wWhichSprite], a
	ld a, [wPlayerCurrentlyMoving]
	bit 0, a
	call nz, Func_c687
	ld a, [wPlayerCurrentlyMoving]
	bit 1, a
	call nz, Func_c6dc
	ret

Func_c554: ; c554 (3:4554)
	ld a, [wPlayerSpriteIndex]
	ld [wWhichSprite], a
	ld a, [wCurMap]
	cp OVERWORLD_MAP
	jr nz, .asm_c566
	farcall Func_10e28
	ret
.asm_c566
	push hl
	push bc
	push de
	call Func_c58b
	ld a, [wSCXBuffer]
	ld d, a
	ld a, [wSCYBuffer]
	ld e, a
	ld c, SPRITE_ANIM_COORD_X
	call GetSpriteAnimBufferProperty
	ld a, [wd332]
	sub d
	add $8
	ld [hli], a
	ld a, [wd333]
	sub e
	add $10
	ld [hli], a
	pop de
	pop bc
	pop hl
	ret

Func_c58b: ; c58b (3:458b)
	push hl
	ld a, [wPlayerXCoord]
	ld b, a
	ld a, [wPlayerYCoord]
	ld c, a
	call GetPermissionOfMapPosition
	and $10
	push af
	ld c, SPRITE_ANIM_FLAGS
	call GetSpriteAnimBufferProperty
	pop af
	ld a, [hl]
	jr z, .asm_c5a7
	or $80
	jr .asm_c5a9
.asm_c5a7
	and $7f
.asm_c5a9
	ld [hl], a
	pop hl
	ret

HandlePlayerMoveModeInput: ; c5ac (3:45ac)
	ldh a, [hKeysHeld]
	and D_PAD
	jr z, .skipMoving
	call UpdatePlayerDirectionFromDPad
	call AttemptPlayerMovementFromDirection
	ld a, [wPlayerCurrentlyMoving]
	and $1
	jr nz, .done
.skipMoving
	ldh a, [hKeysPressed]
	and A_BUTTON
	jr z, .done
	call FindNPCOrObject
	jr .done
.done
	ret

UpdatePlayerDirectionFromDPad: ; c5cb (3:45cb)
	call GetDirectionFromDPad
UpdatePlayerDirection: ; c5ce (3:45ce)
	ld [wPlayerDirection], a
	call UpdatePlayerSprite
	ret

GetDirectionFromDPad: ; c5d5 (3:45d5)
	push hl
	ld hl, KeypadDirectionMap
	or a
	jr z, .loadDirectionMapping
.findDirectionMappingLoop
	rlca
	jr c, .loadDirectionMapping
	inc hl
	jr .findDirectionMappingLoop
.loadDirectionMapping
	ld a, [hl]
	pop hl
	ret

KeypadDirectionMap: ; c5e5 (3:45e5)
	db SOUTH, NORTH, WEST, EAST

; Updates sprite depending on direction
UpdatePlayerSprite: ; c5e9 (3:45e9)
	push bc
	ld a, [wPlayerSpriteIndex]
	ld [wWhichSprite], a
	ld a, [wd337]
	ld b, a
	ld a, [wPlayerDirection]
	add b
	farcall StartNewSpriteAnimation
	pop bc
	ret

AttemptPlayerMovementFromDirection: ; c5fe (3:45fe)
	push bc
	call FindPlayerMovementFromDirection
	call AttemptPlayerMovement
	pop bc
	ret

StartScriptedMovement: ; c607 (3:4607)
	push bc
	ld a, [wPlayerSpriteIndex]
	ld [wWhichSprite], a
	ld a, [wd339]
	call FindPlayerMovementWithOffset
	call AttemptPlayerMovement
	pop bc
	ret

; bc is the location the player is being scripted to move towards.
AttemptPlayerMovement: ; c619 (3:4619)
	push hl
	push bc
	ld a, b
	cp $1f
	jr nc, .quit_movement
	ld a, c
	cp $1f
	jr nc, .quit_movement
	call GetPermissionOfMapPosition
	and $40 | $80 ; the two impassable objects found in the floor map
	jr nz, .quit_movement
	ld a, b
	ld [wPlayerXCoord], a
	ld a, c
	ld [wPlayerYCoord], a
	ld a, [wPlayerCurrentlyMoving] ; I believe everything starting here is animation related.
	or $1
	ld [wPlayerCurrentlyMoving], a
	ld a, $10
	ld [wd338], a
	ld c, SPRITE_ANIM_FLAGS
	call GetSpriteAnimBufferProperty
	set 2, [hl]
	ld c, SPRITE_ANIM_COUNTER
	call GetSpriteAnimBufferProperty
	ld a, $4
	ld [hl], a
.quit_movement
	pop bc
	pop hl
	ret

FindPlayerMovementFromDirection: ; c653 (3:4653)
	ld a, [wPlayerDirection]

FindPlayerMovementWithOffset: ; c656 (3:4656)
	rlca
	ld c, a
	ld b, $0
	push hl
	ld hl, PlayerMovementOffsetTable
	add hl, bc
	ld a, [wPlayerXCoord]
	add [hl]
	ld b, a
	inc hl
	ld a, [wPlayerYCoord]
	add [hl]
	ld c, a
	pop hl
	ret

Func_c66c: ; c66c (3:466c)
	push hl
	push bc
	ld c, $1
	ldh a, [hKeysHeld]
	bit B_BUTTON_F, a
	jr z, .asm_c67e
	ld a, [wd338]
	cp $2
	jr c, .asm_c67e
	inc c
.asm_c67e
	ld a, [wPlayerDirection]
	call Func_c694
	pop bc
	pop hl
	ret

Func_c687: ; c687 (3:4687)
	push bc
	ld a, [wd33a]
	ld c, a
	ld a, [wd339]
	call Func_c694
	pop bc
	ret

Func_c694: ; c694 (3:4694)
	push hl
	push bc
	push bc
	rlca
	ld c, a
	ld b, $0
	ld hl, Unknown_396b
	add hl, bc
	pop bc
.asm_c6a0
	push hl
	ld a, [hli]
	or a
	call nz, Func_c6cc
	ld a, [hli]
	or a
	call nz, Func_c6d4
	pop hl
	ld a, [wd338]
	dec a
	ld [wd338], a
	jr z, .asm_c6b8
	dec c
	jr nz, .asm_c6a0
.asm_c6b8
	ld a, [wd338]
	or a
	jr nz, .asm_c6c3
	ld hl, wPlayerCurrentlyMoving
	set 1, [hl]
.asm_c6c3
	call Func_c41c
	call Func_c469
	pop bc
	pop hl
	ret

Func_c6cc: ; c6cc (3:46cc)
	push hl
	ld hl, wd332
	add [hl]
	ld [hl], a
	pop hl
	ret

Func_c6d4: ; c6d4 (3:46d4)
	push hl
	ld hl, wd333
	add [hl]
	ld [hl], a
	pop hl
	ret

Func_c6dc: ; c6dc (3:46dc)
	push hl
	ld hl, wPlayerCurrentlyMoving
	res 0, [hl]
	res 1, [hl]
	call Func_c6f7
	call Func_3997
	call Func_c70d
	ld a, [wOverworldMode]
	cp $1
	call z, Func_c9c0
	pop hl
	ret

Func_c6f7: ; c6f7 (3:46f7)
	ld a, [wPlayerSpriteIndex]
	ld [wWhichSprite], a
	ld c, SPRITE_ANIM_FLAGS
	call GetSpriteAnimBufferProperty
	res 2, [hl]
	ld c, SPRITE_ANIM_COUNTER
	call GetSpriteAnimBufferProperty
	ld a, $ff
	ld [hl], a
	ret

Func_c70d: ; c70d (3:470d)
	push hl
	ld hl, wTempMap
	ld a, [wCurMap]
	cp [hl]
	jr z, .asm_c71c
	ld hl, wd0b4
	set 4, [hl]
.asm_c71c
	pop hl
	ret

; Arrives here if A button is pressed when not moving + in map move state
FindNPCOrObject: ; c71e (3:471e)
	ld a, $ff
	ld [wScriptNPC], a
	call FindPlayerMovementFromDirection
	call GetPermissionOfMapPosition
	and $40
	jr z, .noNPC
	farcall FindNPCAtLocation
	jr c, .noNPC
	ld a, [wLoadedNPCTempIndex]
	ld [wScriptNPC], a
	ld a, OWMODE_START_SCRIPT
	jr .changeStateExit

.noNPC
	call HandleMoveModeAPress
	jr nc, .exit
	ld a, OWMODE_SCRIPT
	jr .changeStateExit
.exit
	or a
	ret
.changeStateExit
	ld [wOverworldMode], a
	scf
	ret

OpenStartMenu: ; c74d (3:474d)
	push hl
	push bc
	push de
	call MainMenu_c75a
	call CloseAdvancedDialogueBox
	pop de
	pop bc
	pop hl
	ret

MainMenu_c75a: ; c75a (3:475a)
	call PauseSong
	ld a, MUSIC_PAUSE_MENU
	call PlaySong
	call Func_c797
.asm_c765
	ld a, $1
	call Func_c29b
.asm_c76a
	call DoFrameIfLCDEnabled
	call HandleMenuInput
	jr nc, .asm_c76a
	ld a, e
	ld [wd0b8], a
	ldh a, [hCurMenuItem]
	cp e
	jr nz, .asm_c793
	cp $5
	jr z, .asm_c793
	call Func_c2a3
	ld a, [wd0b8]
	ld hl, PointerTable_c7a2
	call JumpToFunctionInTable
	ld hl, Func_c797
	call Func_c32b
	jr .asm_c765
.asm_c793
	call ResumeSong
	ret

Func_c797: ; c797 (3:4797)
	ld a, [wd0b8]
	ld hl, Unknown_cd98
	farcall Func_111e9
	ret

PointerTable_c7a2: ; c7a2 (3:47a2)
	dw Func_c7ae
	dw Func_c7b3
	dw Func_c7b8
	dw Func_c7cc
	dw Func_c7e0
	dw Func_c7e5

Func_c7ae: ; c7ae (3:47ae)
	farcall Func_10059
	ret

Func_c7b3: ; c7b3 (3:47b3)
	farcall Func_100a2
	ret

Func_c7b8: ; c7b8 (3:47b8)
	xor a
	ldh [hSCX], a
	ldh [hSCY], a
	call Set_OBJ_8x16
	farcall Func_1288c
	farcall Func_8db0
	call Set_OBJ_8x8
	ret

Func_c7cc: ; c7cc (3:47cc)
	xor a
	ldh [hSCX], a
	ldh [hSCY], a
	call Set_OBJ_8x16
	farcall Func_1288c
	farcall Func_a288
	call Set_OBJ_8x8
	ret

Func_c7e0: ; c7e0 (3:47e0)
	farcall Func_10548
	ret

Func_c7e5: ; c7e5 (3:47e5)
	farcall Func_103d2
	ret

PC_c7ea: ; c7ea (3:47ea)
	ld a, MUSIC_PC_MAIN_MENU
	call PlaySong
	call Func_c241
	call Func_c915
	call DoFrameIfLCDEnabled
	ldtx hl, TurnedPCOnText
	call PrintScrollableText_NoTextBoxLabel
	call Func_c84e
.asm_c801
	ld a, $1
	call Func_c29b
.asm_c806
	call DoFrameIfLCDEnabled
	call HandleMenuInput
	jr nc, .asm_c806
	ld a, e
	ld [wd0b9], a
	ldh a, [hCurMenuItem]
	cp e
	jr nz, .asm_c82f
	cp $4
	jr z, .asm_c82f
	call Func_c2a3
	ld a, [wd0b9]
	ld hl, PointerTable_c846
	call JumpToFunctionInTable
	ld hl, Func_c84e
	call Func_c32b
	jr .asm_c801
.asm_c82f
	call CloseTextBox
	call DoFrameIfLCDEnabled
	ldtx hl, TurnedPCOffText
	call Func_c891
	call CloseAdvancedDialogueBox
	xor a
	ld [wd112], a
	call Func_39fc
	ret

PointerTable_c846: ; c846 (3:4846)
	dw Func_c859
	dw Func_c86d
	dw Func_c872
	dw Func_c877

Func_c84e: ; c84e (3:484e)
	INCROM $c84e, $c859

Func_c859: ; c859 (3:4859)
	INCROM $c859, $c86d

Func_c86d: ; c86d (3:486d)
	INCROM $c86d, $c872

Func_c872: ; c872 (3:4872)
	INCROM $c872, $c877

Func_c877: ; c877 (3:4877)
	INCROM $c877, $c891

Func_c891: ; c891 (3:4891)
	push hl
	ld a, [wd0c1]
	bit 0, a
	jr z, .asm_c8a1
	ld hl, wd3b9
	ld a, [hli]
	or [hl]
	call nz, CloseTextBox

.asm_c8a1
	xor a
	ld hl, wd3b9
	ld [hli], a
	ld [hl], a
	pop hl
	ld a, $1
	call Func_c29b
	call Func_c241
	call Func_c915
	call DoFrameIfLCDEnabled
	call PrintScrollableText_NoTextBoxLabel
	ret

Func_c8ba: ; c8ba (3:48ba)
	ld a, e
	or d
	jr z, Func_c891
	push hl
	ld a, [wd0c1]
	bit 0, a
	jr z, .asm_c8d4
	ld hl, wd3b9
	ld a, [hli]
	cp e
	jr nz, .asm_c8d1
	ld a, [hl]
	cp d
	jr z, .asm_c8d4

.asm_c8d1
	call CloseTextBox

.asm_c8d4
	ld hl, wd3b9
	ld [hl], e
	inc hl
	ld [hl], d
	pop hl
	ld a, $1
	call Func_c29b
	call Func_c241
	call Func_c915
	call DoFrameIfLCDEnabled
	call PrintScrollableText_WithTextBoxLabel
	ret

Func_c8ed: ; c8ed (3:48ed)
	push hl
	push bc
	push de
	push hl
	ld a, $1
	call Func_c29b
	call Func_c915
	call DoFrameIfLCDEnabled
	pop hl
	ld a, l
	or h
	jr z, .asm_c90e
	push hl
	xor a
	ld hl, wd3b9
	ld [hli], a
	ld [hl], a
	pop hl
	call YesOrNoMenuWithText
	jr .asm_c911

.asm_c90e
	call YesOrNoMenu

.asm_c911
	pop de
	pop bc
	pop hl
	ret

Func_c915: ; c915 (3:4915)
	push bc
	push de
	ld de, $000c
	ld bc, $1406
	call AdjustCoordinatesForBGScroll
	call Func_c3ca
	pop de
	pop bc
	ret

SetNextNPCAndScript: ; c926 (3:4926)
	push bc
	call FindLoadedNPC
	ld a, [wLoadedNPCTempIndex]
	ld [wScriptNPC], a
	farcall SetNewScriptNPC
	pop bc
;	fallthrough

SetNextScript: ; c935 (3:4935)
	push hl
	ld hl, wNextScript
	ld [hl], c
	inc hl
	ld [hl], b
	ld a, $3
	ld [wOverworldMode], a
	pop hl
	ret

Func_c943: ; c943 (3:4943)
	push hl
	push bc
	push de
	ld l, MAP_SCRIPT_NPCS
	call GetMapScriptPointer
	jr nc, .quit
.loadNPCLoop
	ld a, l
	ld [wTempPointer], a
	ld a, h
	ld [wTempPointer + 1], a
	ld a, BANK(MapScripts)
	ld [wTempPointerBank], a
	ld de, wTempNPC
	ld bc, NPC_MAP_SIZE
	call CopyBankedDataToDE
	ld a, [wTempNPC]
	or a
	jr z, .quit
	push hl
	ld a, [wLoadNPCFunction]
	ld l, a
	ld a, [wLoadNPCFunction+1]
	ld h, a
	or l
	jr z, .noScript
	call CallHL2
	jr nc, .nextNPC
.noScript
	ld a, [wTempNPC]
	farcall LoadNPCSpriteData
	call Func_c998
	farcall Func_1c485
.nextNPC
	pop hl
	ld bc, NPC_MAP_SIZE
	add hl, bc
	jr .loadNPCLoop
.quit
	ld l, MAP_SCRIPT_POST_NPC
	call CallMapScriptPointerIfExists
	pop de
	pop bc
	pop hl
	ret

Func_c998: ; c998 (3:4998)
	ld a, [wTempNPC]
	cp $22
	ret nz
	ld a, [wd3d0]
	or a
	ret z
	ld b, $4
	ld a, [wConsole]
	cp $2
	jr nz, .asm_c9ae
	ld b, $e
.asm_c9ae
	ld a, b
	ld [wd3b1], a
	ld a, $0
	ld [wd3b2], a
	ret

Func_c9b8: ; c9b8 (3:49b8)
	ld l, MAP_SCRIPT_LOAD_MAP
	jr CallMapScriptPointerIfExists

Func_c9bc: ; c9bc (3:49bc)
	ld l, MAP_SCRIPT_AFTER_DUEL
	jr CallMapScriptPointerIfExists

Func_c9c0: ; c9c0 (3:49c0)
	ld l, MAP_SCRIPT_MOVED_PLAYER

CallMapScriptPointerIfExists: ; c9c2 (3:49c2)
	call GetMapScriptPointer
	ret nc
	jp hl

Func_c9c7: ; c9c7 (3:49c7)
	ld l, MAP_SCRIPT_CLOSE_TEXTBOX
	jr CallMapScriptPointerIfExists

Func_c9cb: ; c9cb (3:49cb)
	push hl
	push bc
	ld hl, wEventFlags
	ld bc, $0040
.asm_c9d3
	xor a
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, .asm_c9d3
	pop bc
	pop hl
	ret

; Clears temporary flags before determining Imakuni Room
Func_c9dd: ; c9dd (3:49dd)
	xor a
	ld [wEventFlags + EVENT_FLAG_BYTES - 1], a
	call DetermineImakuniRoom
	call Func_ca0e
	ret

; Determines what room Imakuni is in when you reset
; Skips current room and does not occur if you haven't talked to Imakuni
DetermineImakuniRoom: ; c9e8 (3:49e8)
	ld c, $0
	get_flag_value EVENT_IMAKUNI_STATE
	cp IMAKUNI_TALKED
	jr c, .finish
.tryLoadImakuniLoop
	call UpdateRNGSources
	and $3
	ld c, a
	ld b, $0
	ld hl, ImakuniPossibleRooms
	add hl, bc
	ld a, [wTempMap]
	cp [hl]
	jr z, .tryLoadImakuniLoop
.finish
	ld a, c
	set_flag_value EVENT_IMAKUNI_ROOM
	ret

ImakuniPossibleRooms: ; ca0a (3:4a04)
	db FIGHTING_CLUB_LOBBY
	db SCIENCE_CLUB_LOBBY
	db LIGHTNING_CLUB_LOBBY
	db WATER_CLUB_LOBBY

Func_ca0e: ; ca0e (3:4a0e)
	ld a, [wd32e]
	cp $b
	jr z, .asm_ca68
	get_flag_value EVENT_RECEIVED_LEGENDARY_CARD
	or a
	jr nz, .asm_ca4a
	get_flag_value EVENT_FLAG_40
	cp $7
	jr z, .asm_ca68
	or a
	jr z, .asm_ca33
	cp $2
	jr z, .asm_ca62
	ld c, $1
	set_flag_value EVENT_FLAG_40
	jr .asm_ca62
.asm_ca33
	get_flag_value EVENT_FLAG_3F
	cp $7
	jr z, .asm_ca68
	or a
	jr z, .asm_ca68
	cp $2
	jr z, .asm_ca68
	ld c, $1
	set_flag_value EVENT_FLAG_3F
	jr .asm_ca68
.asm_ca4a
	call UpdateRNGSources
	ld c, $1
	and $3
	or a
	jr z, .asm_ca56
	ld c, $0
.asm_ca56
	set_flag_value EVENT_FLAG_41
	jr .asm_ca5c
.asm_ca5c
	ld c, $7
	set_flag_value EVENT_FLAG_40
.asm_ca62
	ld c, $7
	set_flag_value EVENT_FLAG_3F
.asm_ca68
	ret

GetStackFlagValue: ; ca69 (3:4a69)
	call GetByteAfterCall
;	fallthrough

; returns the event flag's value in a
; also ors it with itself before returning
GetEventFlagValue: ; ca6c (3:4a6c)
	push hl
	push bc
	call GetEventFlag
	ld c, [hl]
	ld a, [wLoadedFlagBits]
.shiftLoop
	bit 0, a
	jr nz, .lsbReached
	srl a
	srl c
	jr .shiftLoop
.lsbReached
	and c
	pop bc
	pop hl
	or a
	ret

ZeroStackFlagValue2: ; ca84 (3:4a84)
	call GetByteAfterCall
	push bc
	ld c, $00
	call SetEventFlagValue
	pop bc
	ret

; Use macro set_flag_value. The byte db'd after this func is called
; is used at the flag argument for SetEventFlagValue
SetStackFlagValue: ; ca8f (3:4a8f)
	call GetByteAfterCall
;	fallthrough

; a - flag
; c - value - truncated to fit only the flag's bounds
SetEventFlagValue: ; ca92 (3:4a92)
	push hl
	push bc
	call GetEventFlag
	ld a, [wLoadedFlagBits]
.asm_ca9a
	bit 0, a
	jr nz, .asm_caa4
	srl a
	sla c
	jr .asm_ca9a
.asm_caa4
	ld a, [wLoadedFlagBits]
	and c
	ld c, a
	ld a, [wLoadedFlagBits]
	cpl
	and [hl]
	or c
	ld [hl], a
	pop bc
	pop hl
	ret

; returns in a the byte db'd after the call to a function that calls this
GetByteAfterCall: ; cab3 (3:4ab3)
	push hl
	ld hl, sp+$4
	push bc
	ld c, [hl]
	inc hl
	ld b, [hl]
	ld a, [bc]
	inc bc
	ld [hl], b
	dec hl
	ld [hl], c
	pop bc
	pop hl
	ret

MaxStackFlagValue: ; cac2 (3:4ac2)
	call GetByteAfterCall
;	fallthrough

MaxOutEventFlag: ; cac5 (3:4ac5)
	push bc
	ld c, $ff
	call SetEventFlagValue
	pop bc
	ret

ZeroStackFlagValue: ; cacd (3:4acd)
	call GetByteAfterCall
;	fallthrough

ZeroOutEventFlag: ; cad0 (3:4ad0)
	push bc
	ld c, $0
	call SetEventFlagValue
	pop bc
	ret

TryGiveMedalPCPacks: ; cad8 (3:4ad8)
	push hl
	push bc
	ld hl, MedalEventFlags
	ld bc, $0008
.countMedalsLoop
	ld a, [hli]
	call GetEventFlagValue
	jr z, .noMedal
	inc b
.noMedal
	dec c
	jr nz, .countMedalsLoop

	ld c, b
	set_flag_value EVENT_MEDAL_COUNT
	ld a, c
	push af
	cp $8
	jr nc, .givePacksForEightMedals
	cp $7
	jr nc, .givePacksForSevenMedals
	cp $3
	jr nc, .givePacksForTwoMedals
	jr .finish

.givePacksForEightMedals
	ld a, $c
	farcall TryGivePCPack

.givePacksForSevenMedals
	ld a, $b
	farcall TryGivePCPack

.givePacksForTwoMedals
	ld a, $a
	farcall TryGivePCPack

.finish
	pop af
	pop bc
	pop hl
	ret

MedalEventFlags: ; cb15 (3:4b15)
	db EVENT_FLAG_08
	db EVENT_FLAG_09
	db EVENT_FLAG_0A
	db EVENT_BEAT_AMY
	db EVENT_FLAG_0C
	db EVENT_FLAG_0D
	db EVENT_FLAG_0E
	db EVENT_FLAG_0F

; returns wEventFlags byte in hl, related bits in wLoadedFlagBits
GetEventFlag: ; cb1d (3:4b1d)
	push bc
	ld c, a
	ld b, $0
	sla c
	rl b
	ld hl, EventFlagMods
	add hl, bc
	ld a, [hli]
	ld c, a
	ld a, [hl]
	ld [wLoadedFlagBits], a
	ld b, $0
	ld hl, wEventFlags
	add hl, bc
	pop bc
	ret

; offset - bytes to set or reset
EventFlagMods: ; cb37 (3:4b37)
	flag_def $3f, %10000000 ; EVENT_FLAG_00 ; 0-7 are reset when game resets
	flag_def $3f, %01000000 ; EVENT_FLAG_01
	flag_def $3f, %00100000 ; EVENT_TEMP_TALKED_TO_IMAKUNI
	flag_def $3f, %00010000 ; EVENT_TEMP_BATTLED_IMAKUNI
	flag_def $3f, %00001000 ; EVENT_FLAG_04
	flag_def $3f, %00000100 ; EVENT_FLAG_05
	flag_def $3f, %00000010 ; EVENT_FLAG_06
	flag_def $3f, %00000001 ; EVENT_FLAG_07
	flag_def $00, %10000000 ; EVENT_FLAG_08
	flag_def $00, %01000000 ; EVENT_FLAG_09
	flag_def $00, %00100000 ; EVENT_FLAG_0A
	flag_def $00, %00010000 ; EVENT_BEAT_AMY
	flag_def $00, %00001000 ; EVENT_FLAG_0C
	flag_def $00, %00000100 ; EVENT_FLAG_0D
	flag_def $00, %00000010 ; EVENT_FLAG_0E
	flag_def $00, %00000001 ; EVENT_FLAG_0F
	flag_def $00, %11111111 ; EVENT_FLAG_10
	flag_def $01, %11110000 ; EVENT_FLAG_11
	flag_def $01, %00001111 ; EVENT_FLAG_12
	flag_def $02, %11000000 ; EVENT_IMAKUNI_STATE
	flag_def $02, %00110000 ; EVENT_FLAG_14
	flag_def $02, %00001000 ; EVENT_BEAT_SARA
	flag_def $02, %00000100 ; EVENT_BEAT_AMANDA
	flag_def $03, %11110000 ; EVENT_FLAG_17
	flag_def $03, %00001111 ; EVENT_FLAG_18
	flag_def $04, %11110000 ; EVENT_FLAG_19
	flag_def $04, %00001111 ; EVENT_FLAG_1A
	flag_def $05, %10000000 ; EVENT_FLAG_1B
	flag_def $05, %01000000 ; EVENT_FLAG_1C
	flag_def $05, %00100000 ; EVENT_FLAG_1D
	flag_def $05, %00010000 ; EVENT_FLAG_1E
	flag_def $05, %00001111 ; EVENT_FLAG_1F
	flag_def $06, %11110000 ; EVENT_FLAG_20
	flag_def $06, %00001100 ; EVENT_FLAG_21
	flag_def $06, %00000010 ; EVENT_RECEIVED_LEGENDARY_CARD
	flag_def $06, %00000001 ; EVENT_FLAG_23
	flag_def $07, %11000000 ; EVENT_FLAG_24
	flag_def $07, %00100000 ; EVENT_FLAG_25
	flag_def $07, %00010000 ; EVENT_FLAG_26
	flag_def $07, %00001000 ; EVENT_FLAG_27
	flag_def $07, %00000100 ; EVENT_FLAG_28
	flag_def $07, %00000010 ; EVENT_FLAG_29
	flag_def $07, %00000001 ; EVENT_FLAG_2A
	flag_def $08, %11111111 ; EVENT_FLAG_2B
	flag_def $09, %11100000 ; EVENT_FLAG_2C
	flag_def $09, %00011111 ; EVENT_FLAG_2D
	flag_def $0a, %11110000 ; EVENT_MEDAL_COUNT
	flag_def $0a, %00001000 ; EVENT_FLAG_2F
	flag_def $0a, %00000100 ; EVENT_FLAG_30
	flag_def $0a, %00000011 ; EVENT_FLAG_31
	flag_def $0b, %10000000 ; EVENT_FLAG_32
	flag_def $0b, %01110000 ; EVENT_JOSHUA_STATE
	flag_def $0b, %00001100 ; EVENT_IMAKUNI_ROOM
	flag_def $0b, %00000011 ; EVENT_FLAG_35
	flag_def $0c, %11100000 ; EVENT_IMAKUNI_WIN_COUNT
	flag_def $0c, %00011100 ; EVENT_FLAG_37
	flag_def $0c, %00000010 ; EVENT_FLAG_38
	flag_def $0c, %00000001 ; EVENT_FLAG_39
	flag_def $0d, %10000000 ; EVENT_FLAG_3A
	flag_def $0d, %01000000 ; EVENT_FLAG_3B
	flag_def $0d, %00100000 ; FLAG_BEAT_BRITTANY
	flag_def $0d, %00010000 ; EVENT_FLAG_3D
	flag_def $0d, %00001110 ; EVENT_FLAG_3E
	flag_def $0e, %11100000 ; EVENT_FLAG_3F
	flag_def $0e, %00011100 ; EVENT_FLAG_40
	flag_def $0f, %11100000 ; EVENT_FLAG_41
	flag_def $10, %10000000 ; EVENT_FLAG_42
	flag_def $10, %01000000 ; EVENT_FLAG_43
	flag_def $10, %00110000 ; EVENT_FLAG_44
	flag_def $10, %00001100 ; EVENT_FLAG_45
	flag_def $10, %00000010 ; EVENT_FLAG_46
	flag_def $10, %00000001 ; EVENT_FLAG_47
	flag_def $11, %11100000 ; EVENT_FLAG_48
	flag_def $11, %00011100 ; EVENT_FLAG_49
	flag_def $12, %11100000 ; EVENT_FLAG_4A
	flag_def $13, %10000000 ; EVENT_FLAG_4B
	flag_def $13, %01100000 ; EVENT_FLAG_4C
	flag_def $13, %00011000 ; EVENT_FLAG_4D
	flag_def $13, %00000100 ; EVENT_FLAG_4E
	flag_def $13, %00000010 ; EVENT_FLAG_4F
	flag_def $14, %10000000 ; EVENT_FLAG_50
	flag_def $14, %01000000 ; EVENT_FLAG_51
	flag_def $14, %00100000 ; EVENT_FLAG_52
	flag_def $14, %00010000 ; EVENT_FLAG_53
	flag_def $14, %00001000 ; EVENT_FLAG_54
	flag_def $14, %00000100 ; EVENT_FLAG_55
	flag_def $14, %00000010 ; EVENT_FLAG_56
	flag_def $14, %00000001 ; EVENT_FLAG_57
	flag_def $15, %11110000 ; EVENT_FLAG_58
	flag_def $15, %00001000 ; EVENT_FLAG_59
	flag_def $16, %10000000 ; EVENT_FLAG_5A
	flag_def $16, %01000000 ; EVENT_FLAG_5B
	flag_def $16, %00100000 ; EVENT_FLAG_5C
	flag_def $16, %00010000 ; EVENT_FLAG_5D
	flag_def $16, %00001000 ; EVENT_FLAG_5E
	flag_def $16, %00000100 ; EVENT_FLAG_5F
	flag_def $16, %00000010 ; EVENT_FLAG_60
	flag_def $16, %00000001 ; EVENT_FLAG_61
	flag_def $16, %11111111 ; EVENT_FLAG_62
	flag_def $17, %10000000 ; EVENT_FLAG_63
	flag_def $17, %01000000 ; EVENT_FLAG_64
	flag_def $17, %00110000 ; EVENT_FLAG_65
	flag_def $17, %00001000 ; EVENT_FLAG_66
	flag_def $17, %00000100 ; EVENT_FLAG_67
	flag_def $18, %11000000 ; EVENT_FLAG_68
	flag_def $18, %00110000 ; EVENT_FLAG_69
	flag_def $18, %00001100 ; EVENT_FLAG_6A
	flag_def $18, %00000011 ; EVENT_FLAG_6B
	flag_def $19, %11000000 ; EVENT_FLAG_6C
	flag_def $19, %00100000 ; EVENT_FLAG_6D
	flag_def $19, %00010000 ; EVENT_FLAG_6E
	flag_def $19, %00001000 ; EVENT_FLAG_6F
	flag_def $19, %00000100 ; EVENT_FLAG_70
	flag_def $19, %00111100 ; EVENT_FLAG_71
	flag_def $1a, %11111100 ; EVENT_FLAG_72
	flag_def $1a, %00000011 ; EVENT_FLAG_73
	flag_def $1b, %11111111 ; EVENT_FLAG_74
	flag_def $1c, %11110000 ; EVENT_FLAG_75
	flag_def $1c, %00001111 ; EVENT_FLAG_76

; Used for basic level objects that just print text and quit
PrintInteractableObjectText: ; cc25 (3:4c25)
	ld hl, wDefaultObjectText
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call Func_cc32
	call CloseAdvancedDialogueBox
	ret

Func_cc32: ; cc32 (3:4c32)
	push hl
	ld hl, wCurrentNPCNameTx
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
	call Func_c8ba
	ret

; Used for things that are represented as NPCs but don't have a Script
; EX: Clerks and legendary cards that interact through Level Objects
Script_Clerk10: ; cc3e (3:4c3e)
Script_GiftCenterClerk: ; cc3e (3:4c3e)
Script_Woman2: ; cc3e (3:4c3e)
Script_Torch: ; cc3e (3:4c3e)
Script_LegendaryCardTopLeft: ; cc3e (3:4c3e)
Script_LegendaryCardTopRight: ; cc3e (3:4c3e)
Script_LegendaryCardLeftSpark: ; cc3e (3:4c3e)
Script_LegendaryCardBottomLeft: ; cc3e (3:4c3e)
Script_LegendaryCardBottomRight: ; cc3e (3:4c3e)
Script_LegendaryCardRightSpark: ; cc3e (3:4c3e)
	call CloseAdvancedDialogueBox
	ret

; Enters into the script loop, continuing until wBreakScriptLoop > 0
; When the loop is broken, it resumes normal code execution where script ended
; Note: Some scripts "double return" and skip this.
RST20: ; cc42 (3:4c42)
	pop hl
	ld a, l
	ld [wScriptPointer], a
	ld a, h
	ld [wScriptPointer+1], a
	xor a
	ld [wBreakScriptLoop], a
.continueScriptLoop
	call RunOverworldScript
	ld a, [wBreakScriptLoop] ; if you break out, it jumps
	or a
	jr z, .continueScriptLoop
	ld hl, wScriptPointer
	ld a, [hli]
	ld c, a
	ld b, [hl]
	retbc

IncreaseScriptPointerBy1: ; cc60 (3:4c60)
	ld a, 1
	jr IncreaseScriptPointer
IncreaseScriptPointerBy2: ; cc64 (3:4c64)
	ld a, 2
	jr IncreaseScriptPointer
IncreaseScriptPointerBy4: ; cc68 (3:4c68)
	ld a, 4
	jr IncreaseScriptPointer
IncreaseScriptPointerBy5: ; cc6c (3:4c6c)
	ld a, 5
	jr IncreaseScriptPointer
IncreaseScriptPointerBy6: ; cc70 (3:4c70)
	ld a, 6
	jr IncreaseScriptPointer
IncreaseScriptPointerBy7: ; cc74 (3:4c74)
	ld a, 7
	jr IncreaseScriptPointer
IncreaseScriptPointerBy3: ; cc78 (3:4c78)
	ld a, 3

IncreaseScriptPointer: ; cc7a (3:4c7a)
	ld c, a
	ld a, [wScriptPointer]
	add c
	ld [wScriptPointer], a
	ld a, [wScriptPointer+1]
	adc 0
	ld [wScriptPointer+1], a
	ret

SetScriptPointer: ; cc8b (3:4c8b)
	ld hl, wScriptPointer
	ld [hl], c
	inc hl
	ld [hl], b
	ret

GetScriptArgs5AfterPointer: ; cc92 (3:4c92)
	ld a, $5
	jr GetScriptArgsAfterPointer

GetScriptArgs1AfterPointer: ; cc96 (3:4c96)
	ld a, $1
	jr GetScriptArgsAfterPointer

GetScriptArgs2AfterPointer: ; cc9a (3:4c9a)
	ld a, $2
	jr GetScriptArgsAfterPointer
GetScriptArgs3AfterPointer: ; cc9e (3:4c9e)
	ld a, $3

GetScriptArgsAfterPointer: ; cca0 (3:4ca0)
	push hl
	ld l, a
	ld a, [wScriptPointer]
	add l
	ld l, a
	ld a, [wScriptPointer+1]
	adc $0
	ld h, a
	ld a, [hli]
	ld c, a
	ld b, [hl]
	pop hl
	or b
	ret

SetScriptControlBytePass: ; ccb3 (3:4cb3)
	ld a, $ff
	ld [wScriptControlByte], a
	ret

SetScriptControlByteFail: ; ccb9 (3:4cb9)
	xor a
	ld [wScriptControlByte], a
	ret

; Exits Script mode and runs the next instruction like normal
ScriptCommand_EndScriptLoop1: ; ccbe (3:4cbe)
ScriptCommand_EndScriptLoop2: ; ccbe (3:4cbe)
ScriptCommand_EndScriptLoop3: ; ccbe (3:4cbe)
ScriptCommand_EndScriptLoop4: ; ccbe (3:4cbe)
ScriptCommand_EndScriptLoop5: ; ccbe (3:4cbe)
ScriptCommand_EndScriptLoop6: ; ccbe (3:4cbe)
ScriptCommand_EndScriptLoop7: ; ccbe (3:4cbe)
ScriptCommand_EndScriptLoop8: ; ccbe (3:4cbe)
ScriptCommand_EndScriptLoop9: ; ccbe (3:4cbe)
ScriptCommand_EndScriptLoop10: ; ccbe (3:4cbe)
	ld a, $01
	ld [wBreakScriptLoop], a
	jp IncreaseScriptPointerBy1

ScriptCommand_CloseAdvancedTextBox: ; ccc6 (3:4cc6)
	call CloseAdvancedDialogueBox
	jp IncreaseScriptPointerBy1

ScriptCommand_QuitScriptFully: ; cccc (3:4ccc)
	call ScriptCommand_CloseAdvancedTextBox
	call ScriptCommand_EndScriptLoop1
	pop hl
	ret

; args: 2-Text String Index
ScriptCommand_PrintTextString: ; ccd4 (3:4cd4)
	ld l, c
	ld h, b
	call Func_cc32
	jp IncreaseScriptPointerBy3

Func_ccdc: ; ccdc (3:4cdc)
	ld l, c
	ld h, b
	call Func_c891
	jp IncreaseScriptPointerBy3

ScriptCommand_AskQuestionJumpDefaultYes: ; cce4 (3:4ce4)
	ld a, $1
	ld [wDefaultYesOrNo], a
;	fallthrough

; Asks the player a question then jumps if they answer yes. Seem to be able to
; take a text of 0000 (NULL) to overwrite last with (yes no) prompt at the bottom
ScriptCommand_AskQuestionJump: ; cce9 (3:4ce9)
	ld l, c
	ld h, b
	call Func_c8ed
	ld a, [hCurMenuItem]
	ld [wScriptControlByte], a
	jr c, .asm_ccfe
	call GetScriptArgs3AfterPointer
	jr z, .asm_ccfe
	jp SetScriptPointer

.asm_ccfe
	jp IncreaseScriptPointerBy5

; args - prize cards, deck id, duel theme index
; sets a battle up, doesn't start until we break out of the script system.
ScriptCommand_StartBattle: ; cd01 (3:4d01)
	call Func_cd66
	ld a, [wScriptNPC]
	ld l, LOADED_NPC_ID
	call GetItemInLoadedNPCIndex
	ld a, [hl]
	farcall Func_118d3
	ld a, [wcc19]
	cp $ff
	jr nz, .asm_cd26
	ld a, [wd695]
	ld c, a
	ld b, $0
	ld hl, AaronDeckIDs
	add hl, bc
	ld a, [hl]
	ld [wcc19], a
.asm_cd26
	ld a, [wScriptNPC]
	ld l, LOADED_NPC_ID
	call GetItemInLoadedNPCIndex
	ld a, [hl]
asm_cd2f:
	ld [wd0c4], a
	ld [wcc14], a
	push af
	farcall Func_1c557
	ld [wd0c5], a
	pop af
	farcall Func_118a7
	ld a, GAME_EVENT_DUEL
	ld [wGameEvent], a
	ld hl, wd0b4
	set 6, [hl]
	jp IncreaseScriptPointerBy4

Func_cd4f: ; cd4f (3:4d4f)
	call Func_cd66
	ld a, [wd696]
	farcall Func_118bf
	ld a, $16
	ld [wMatchStartTheme], a
	ld a, [wd696]
	jr asm_cd2f

AaronDeckIDs: ; cd63 (3:4d63)
	db LIGHTNING_AND_FIRE_DECK_ID
	db WATER_AND_FIGHTING_DECK_ID
	db GRASS_AND_PSYCHIC_DECK_ID

Func_cd66: ; cd66 (3:4d66)
	ld a, c
	ld [wcc18], a
	ld a, b
	ld [wcc19], a
	call GetScriptArgs3AfterPointer
	ld a, c
	ld [wDuelTheme], a
	ret

Func_cd76: ; cd76 (3:4d76)
	ld a, GAME_EVENT_BATTLE_CENTER
	ld [wGameEvent], a
	ld hl, wd0b4
	set 6, [hl]
	jp IncreaseScriptPointerBy1

; prints text arg 1 or arg 2 depending on wScriptControlByte.
ScriptCommand_PrintVariableText: ; cd83 (3:4d83)
	ld a, [wScriptControlByte]
	or a
	jr nz, .printText
	call GetScriptArgs3AfterPointer
.printText
	ld l, c
	ld h, b
	call Func_cc32
	jp IncreaseScriptPointerBy5

Func_cd94: ; cd94 (3:4d94)
	get_flag_value EVENT_FLAG_44
Unknown_cd98:
	dec a
	and $3
	add a
	inc a
	call GetScriptArgsAfterPointer
	ld l, c
	ld h, b
	call Func_cc32
	jp IncreaseScriptPointerBy7

Func_cda8: ; cda8 (3:4da8)
	ld a, [wScriptControlByte]
	or a
	jr nz, .asm_cdb1
	call GetScriptArgs3AfterPointer
.asm_cdb1
	ld l, c
	ld h, b
	call Func_c891
	jp IncreaseScriptPointerBy5

; Does not return to RST20 - pops an extra time to skip that.
ScriptCommand_PrintTextQuitFully: ; cdb9 (3:4db9)
	ld l, c
	ld h, b
	call Func_cc32
	call CloseAdvancedDialogueBox
	ld a, $1
	ld [wBreakScriptLoop], a
	call IncreaseScriptPointerBy3
	pop hl
	ret

Func_cdcb: ; cdcb (3:4dcb)
	ld a, [wScriptNPC]
	ld [wLoadedNPCTempIndex], a
Func_cdd1: ; cdd1 (3:4dd1)
	farcall Func_1c50a
	jp IncreaseScriptPointerBy1

Func_cdd8: ; cdd8 (3:4dd8)
	ld a, [wLoadedNPCTempIndex]
	push af
	ld a, [wTempNPC]
	push af
	ld a, [wd696]
	ld [wTempNPC], a
	call FindLoadedNPC
	call Func_cdd1
	pop af
	ld [wTempNPC], a
	pop af
	ld [wLoadedNPCTempIndex], a
	ret

Func_cdf5: ; cdf5 (3:4df5)
	ld a, [wLoadedNPCTempIndex]
	push af
	ld a, [wTempNPC]
	push af
	ld a, [wd696]
	ld [wTempNPC], a
	ld a, c
	ld [wLoadNPCXPos], a
	ld a, b
	ld [wLoadNPCYPos], a
	ld a, $2
	ld [wLoadNPCDirection], a
	ld a, [wTempNPC]
	farcall LoadNPCSpriteData
	farcall Func_1c485
	pop af
	ld [wTempNPC], a
	pop af
	ld [wLoadedNPCTempIndex], a
	jp IncreaseScriptPointerBy3

; Finds and executes an NPCMovement script in the table provided in bc
; based on the active NPC's current direction
ScriptCommand_MoveActiveNPCByDirection: ; ce26 (3:4e26)
	ld a, [wScriptNPC]
	ld [wLoadedNPCTempIndex], a
	farcall GetNPCDirection
	rlca
	add c
	ld l, a
	ld a, b
	adc $0
	ld h, a
	ld c, [hl]
	inc hl
	ld b, [hl]
;	fallthrough

; Moves an NPC given the list of directions pointed to by bc
; set bit 7 to only rotate the NPC
ExecuteNPCMovement: ; ce3a (3:4e3a)
	farcall Func_1c78d
.asm_ce3e
	call DoFrameIfLCDEnabled
	farcall Func_1c7de
	jr nz, .asm_ce3e
	jp IncreaseScriptPointerBy3

; Begin a series of NPC movements on the currently talking NPC
; based on the series of directions pointed to by bc
ScriptCommand_MoveActiveNPC: ; ce4a (3:4e4a)
	ld a, [wScriptNPC]
	ld [wLoadedNPCTempIndex], a
	jr ExecuteNPCMovement

; Begin a series of NPC movements on an arbitrary NPC
; based on the series of directions pointed to by bc
ScriptCommand_MoveWramNPC: ; ce52 (3:4e52)
	ld a, [wLoadedNPCTempIndex]
	push af
	ld a, [wTempNPC]
	push af
	ld a, [wd696]
;	fallthrough

; Executes movement on an arbitrary NPC using values in a and on the stack
; Changes and fixes Temp NPC using stack values
ExecuteArbitraryNPCMovementFromStack: ; ce5d (3:4e5d)
	ld [wTempNPC], a
	call FindLoadedNPC
	call ExecuteNPCMovement
	pop af
	ld [wTempNPC], a
	pop af
	ld [wLoadedNPCTempIndex], a
	ret

ScriptCommand_MoveArbitraryNPC: ; ce6f (3:4e6f)
	ld a, [wLoadedNPCTempIndex]
	push af
	ld a, [wTempNPC]
	push af
	ld a, c
	push af
	call GetScriptArgs2AfterPointer
	push bc
	call IncreaseScriptPointerBy1
	pop bc
	pop af
	jr ExecuteArbitraryNPCMovementFromStack

ScriptCommand_CloseTextBox: ; ce84 (3:4e84)
	call CloseTextBox
	jp IncreaseScriptPointerBy1

; args: booster pack index, booster pack index, booster pack index
ScriptCommand_GiveBoosterPacks: ; ce8a (3:4e8a)
	xor a
	ld [wd117], a
	push bc
	call Func_c2a3
	pop bc
	push bc
	ld a, c
	farcall BoosterPack_1031b
	ld a, 1
	ld [wd117], a
	pop bc
	ld a, b
	cp NO_BOOSTER
	jr z, .asm_ceb4
	farcall BoosterPack_1031b
	call GetScriptArgs3AfterPointer
	ld a, c
	cp NO_BOOSTER
	jr z, .asm_ceb4
	farcall BoosterPack_1031b
.asm_ceb4
	call Func_c2d4
	jp IncreaseScriptPointerBy4

ScriptCommand_GiveOneOfEachTrainerBooster: ; ceba (3:4eba)
	xor a
	ld [wd117], a
	call Func_c2a3
	ld hl, .booster_type_table
.giveBoosterLoop
	ld a, [hl]
	cp NO_BOOSTER
	jr z, .done
	push hl
	farcall BoosterPack_1031b
	ld a, $1
	ld [wd117], a
	pop hl
	inc hl
	jr .giveBoosterLoop
.done
	call Func_c2d4
	jp IncreaseScriptPointerBy1

.booster_type_table
	db BOOSTER_COLOSSEUM_TRAINER
	db BOOSTER_EVOLUTION_TRAINER
	db BOOSTER_MYSTERY_TRAINER_COLORLESS
	db BOOSTER_LABORATORY_TRAINER
	db NO_BOOSTER ; $ff

; Shows the card received screen for a given promotional card
; arg can either be the card, $00 for a wram card, or $ff for the 4 legends
ScriptCommand_ShowCardReceivedScreen: ; cee2 (3:4ee2)
	call Func_c2a3
	ld a, c
	cp $ff
	jr z, .asm_cf09
	or a
	jr nz, .asm_cef0
	ld a, [wd697]

.asm_cef0
	push af
	farcall Func_10000
	farcall Func_10031
	pop af
	bank1call Func_7594
	call WhiteOutDMGPals
	call DoFrameIfLCDEnabled
	call Func_c2d4
	jp IncreaseScriptPointerBy2

.asm_cf09
	xor a
	jr .asm_cef0

ScriptCommand_JumpIfCardOwned: ; cf0c (3:4f0c)
	ld a, c
	call GetCardCountInCollectionAndDecks
	jr asm_cf16

ScriptCommand_JumpIfCardInCollection: ; cf12 (3:4f12)
	ld a, c
	call GetCardCountInCollection

asm_cf16:
	or a
	jr nz, asm_cf1f

asm_cf19:
	call SetScriptControlByteFail
	jp IncreaseScriptPointerBy4

asm_cf1f:
	call SetScriptControlBytePass
	call GetScriptArgs2AfterPointer
	jr z, asm_cf2a
	jp SetScriptPointer

asm_cf2a:
	jp IncreaseScriptPointerBy4

ScriptCommand_JumpIfEnoughCardsOwned: ; cf2d (3:4f2d)
	push bc
	call IncreaseScriptPointerBy1
	pop bc
	call GetAmountOfCardsOwned
	ld a, h
	cp b
	jr nz, .asm_cf3b
	ld a, l
	cp c

.asm_cf3b
	jr nc, asm_cf1f
	jr asm_cf19

; Gives the first arg as a card. If that's 0 pulls from wd697
ScriptCommand_GiveCard: ; cf3f (3:4f3f)
	ld a, c
	or a
	jr nz, .giveCard
	ld a, [wd697]

.giveCard
	call AddCardToCollection
	jp IncreaseScriptPointerBy2

ScriptCommand_TakeCard: ; cf4c (3:4f4c)
	ld a, c
	call RemoveCardFromCollection
	jp IncreaseScriptPointerBy2

Func_cf53: ; cf53 (3:4f53)
	ld c, $1
	ld b, $0
.asm_cf57
	ld a, c
	call GetCardCountInCollection
	add b
	ld b, a
	inc c
	ld a, c
	cp $8
	jr c, .asm_cf57
	ld a, b
	or a
	jr nz, Func_cf6d
Func_cf67: ; cf67 (3:4f67)
	call SetScriptControlByteFail
	jp IncreaseScriptPointerBy3

Func_cf6d: ; cf6d (3:4f6d)
	call SetScriptControlBytePass
	call GetScriptArgs1AfterPointer
	jr z, .asm_cf78
	jp SetScriptPointer

.asm_cf78
	jp IncreaseScriptPointerBy3

Func_cf7b: ; cf7b (3:4f7b)
	ld c, $1
.asm_cf7d
	push bc
	ld a, c
	call GetCardCountInCollection
	jr c, .asm_cf8c
	ld b, a
.asm_cf85
	ld a, c
	call RemoveCardFromCollection
	dec b
	jr nz, .asm_cf85

.asm_cf8c
	pop bc
	inc c
	ld a, c
	cp $8
	jr c, .asm_cf7d
	jp IncreaseScriptPointerBy1

ScriptCommand_JumpBasedOnFightingClubPupilStatus: ; cf96 (3:4f96)
	ld c, $0
	get_flag_value EVENT_FLAG_11
	or a
	jr z, Func_cfc0
	cp a, $08
	jr c, .asm_cfa4
	inc c

.asm_cfa4
	get_flag_value EVENT_FLAG_17
	cp $8
	jr c, .asm_cfad
	inc c

.asm_cfad
	get_flag_value EVENT_FLAG_20
	cp a, $08
	jr c, .asm_cfb6
	inc c
.asm_cfb6
	ld a, c
	rlca
	add $3
	call GetScriptArgsAfterPointer
	jp SetScriptPointer

Func_cfc0: ; cfc0 (3:4fc0)
	call GetScriptArgs1AfterPointer
	jp SetScriptPointer

Func_cfc6: ; cfc6 (3:4fc6)
	ld a, [wScriptNPC]
	ld [wLoadedNPCTempIndex], a
	ld a, c
	farcall Func_1c52e
	jp IncreaseScriptPointerBy2

Func_cfd4: ; cfd4 (3:4fd4)
	get_flag_value EVENT_FLAG_2D
	ld b, a
.asm_cfd9
	ld a, $5
	call Random
	ld e, $1
	ld c, a
	push bc
	or a
	jr z, .asm_cfea
.asm_cfe5
	sla e
	dec c
	jr nz, .asm_cfe5

.asm_cfea
	ld a, e
	and b
	pop bc
	jr nz, .asm_cfd9
	ld a, e
	or b
	push bc
	ld c, a
	set_flag_value EVENT_FLAG_2D
	pop bc
	ld b, $0
	ld hl, Data_d006
	add hl, bc
	ld c, [hl]
	set_flag_value EVENT_FLAG_2B
	jp IncreaseScriptPointerBy1

Data_d006: ; d006 (3:5006)
	INCROM $d006, $d00b

Func_d00b: ; d00b (3:500b)
	sla c
	ld b, $0
	ld hl, wTxRam2
	add hl, bc
	push hl
	get_flag_value EVENT_FLAG_2B
	ld e, a
	ld d, $0
	call GetCardName
	pop hl
	ld [hl], e
	inc hl
	ld [hl], d
	jp IncreaseScriptPointerBy2

Func_d025: ; d025 (3:5025)
	get_flag_value EVENT_FLAG_2B
	call GetCardCountInCollectionAndDecks
	jp c, Func_cf67
	jp Func_cf6d

Func_d032: ; d032 (3:5032)
	get_flag_value EVENT_FLAG_2B
	call GetCardCountInCollection
	jp c, Func_cf67
	jp Func_cf6d

Func_d03f: ; d03f (3:503f)
	get_flag_value EVENT_FLAG_2B
	call RemoveCardFromCollection
	jp IncreaseScriptPointerBy1

ScriptCommand_Jump: ; d049 (3:5049)
	call GetScriptArgs1AfterPointer
	jp SetScriptPointer

ScriptCommand_TryGiveMedalPCPacks: ; d04f (3:504f)
	call TryGiveMedalPCPacks
	jp IncreaseScriptPointerBy1

ScriptCommand_SetPlayerDirection: ; d055 (3:5055)
	ld a, c
	call UpdatePlayerDirection
	jp IncreaseScriptPointerBy2

; arg1 - Direction (index in PlayerMovementOffsetTable)
; arg2 - Tiles Moves (Speed)
ScriptCommand_MovePlayer: ; 505c (3:505c)
	ld a, c
	ld [wd339], a
	ld a, b
	ld [wd33a], a
	call StartScriptedMovement
.asm_d067
	call DoFrameIfLCDEnabled
	call SetScreenScroll
	call Func_c53d
	ld a, [wPlayerCurrentlyMoving]
	and $03
	jr nz, .asm_d067
	call DoFrameIfLCDEnabled
	call SetScreenScroll
	jp IncreaseScriptPointerBy3

ScriptCommand_SetDialogNPC: ; d080 (3:5080)
	ld a, c
	farcall SetNPCDialogName
	jp IncreaseScriptPointerBy2

ScriptCommand_SetNextNPCAndScript: ; d088 (3:5088)
	ld a, c
	ld [wTempNPC], a
	call GetScriptArgs2AfterPointer
	call SetNextNPCAndScript
	jp IncreaseScriptPointerBy4

Func_d095: ; d095 (3:5095)
	ld a, [wScriptNPC]
	ld [wLoadedNPCTempIndex], a
	push bc
	call GetScriptArgs3AfterPointer
	ld a, [wScriptNPC]
	ld l, LOADED_NPC_FIELD_05
	call GetItemInLoadedNPCIndex
	res 4, [hl]
	ld a, [hl]
	or c
	ld [hl], a
	pop bc
	ld e, c
	ld a, [wConsole]
	cp $2
	jr nz, .asm_d0b6
	ld e, b

.asm_d0b6
	ld a, e
	farcall Func_1c57b
	jp IncreaseScriptPointerBy4

Func_d0be: ; d0be (3:50be)
	ld a, [wScriptNPC]
	ld [wLoadedNPCTempIndex], a
	ld a, c
	ld c, b
	ld b, a
	farcall Func_1c461
	jp IncreaseScriptPointerBy3

ScriptCommand_DoFrames: ; d0ce (3:50ce)
	push bc
	call DoFrameIfLCDEnabled
	pop bc
	dec c
	jr nz, ScriptCommand_DoFrames
	jp IncreaseScriptPointerBy2

Func_d0d9: ; d0d9 (3:50d9)
	ld a, [wScriptNPC]
	ld [wLoadedNPCTempIndex], a
	ld d, c
	ld e, b
	farcall Func_1c477
	ld a, e
	cp c
	jp nz, ScriptEventFailedNoJump
	ld a, d
	cp b
	jp nz, ScriptEventFailedNoJump
	jp ScriptEventPassedTryJump

ScriptCommand_JumpIfPlayerCoordsMatch: ; d0f2 (3:50f2)
	ld a, [wPlayerXCoord]
	cp c
	jp nz, ScriptEventFailedNoJump
	ld a, [wPlayerYCoord]
	cp b
	jp nz, ScriptEventFailedNoJump
	jp ScriptEventPassedTryJump

Func_d103: ; d103 (3:5103)
	ld a, [wLoadedNPCTempIndex]
	push af
	ld a, [wTempNPC]
	push af
	ld a, c
	ld [wTempNPC], a
	call FindLoadedNPC
	jr c, .asm_d119
	call ScriptCommand_JumpIfFlagNonzero2.passTryJump
	jr .asm_d11c

.asm_d119
	call ScriptCommand_JumpIfFlagZero2.fail

.asm_d11c
	pop af
	ld [wTempNPC], a
	pop af
	ld [wLoadedNPCTempIndex], a
	ret

Func_d125: ; d125 (3:5125)
	ld a, c
	push af
	call Func_c2a3
	pop af
	farcall Medal_1029e
	call Func_c2d4
	jp IncreaseScriptPointerBy2

Func_d135: ; d135 (3:5135)
	sla c
	ld b, $0
	ld hl, wTxRam2
	add hl, bc
	push hl
	ld a, [wd32e]
	rlca
	ld c, a
	ld b, $0
	ld hl, MapNames - 2
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
	ld [hl], e
	inc hl
	ld [hl], d
	jp IncreaseScriptPointerBy2

MapNames: ; d153 (3:5153)
	tx MasonLaboratoryMapNameText
	tx MrIshiharasHouseMapNameText
	tx FightingClubMapNameText
	tx RockClubMapNameText
	tx WaterClubMapNameText
	tx LightningClubMapNameText
	tx GrassClubMapNameText
	tx PsychicClubMapNameText
	tx ScienceClubMapNameText
	tx FireClubMapNameText
	tx ChallengeHallMapNameText
	tx PokemonDomeMapNameText

Func_d16b: ; d16b (3:516b)
	ld hl, wCurrentNPCNameTx
	ld e, [hl]
	inc hl
	ld d, [hl]
	push de
	sla c
	ld b, $0
	ld hl, wTxRam2
	add hl, bc
	push hl
	ld a, [wd696]
	farcall SetNPCDialogName
	pop hl
	ld a, [wCurrentNPCNameTx]
	ld [hli], a
	ld a, [wCurrentNPCNameTx+1]
	ld [hl], a
	pop de
	ld hl, wCurrentNPCNameTx
	ld [hl], e
	inc hl
	ld [hl], d
	jp IncreaseScriptPointerBy2

Func_d195: ; d195 (3:5195)
	ld a, [wTempNPC]
	push af
	get_flag_value EVENT_FLAG_45
	inc a
	ld c, a
	set_flag_value EVENT_FLAG_45
	call Func_f580
	pop af
	ld [wTempNPC], a
	jp IncreaseScriptPointerBy1

Func_d1ad: ; d1ad (3:51ad)
	call MainMenu_c75a
	jp IncreaseScriptPointerBy1

Func_d1b3: ; d1b3 (3:51b3)
	get_flag_value EVENT_FLAG_44
	dec a
	cp $2
	jr c, .asm_d1c3
	ld a, $d
	call Random
	add $2
;	fallthrough

.asm_d1c3
	ld hl, TradeCardNames
asm_d1c6:
	ld e, a
	add a
	add e
	ld e, a
	ld d, $0
	add hl, de
	ld a, [hli]
	ld [wd697], a
	ld a, [hli]
	ld [wTxRam2], a
	ld a, [hl]
	ld [wTxRam2 + 1], a
	jp IncreaseScriptPointerBy1

TradeCardNames: ; d1dc (3:51dc)
	db MEWTWO2
	tx MewtwoTradeCardName

	db MEW1
	tx MewTradeCardName

	db ARCANINE1
	tx ArcanineTradeCardName

	db PIKACHU3
	tx PikachuTradeCardName

	db PIKACHU4
	tx PikachuTradeCardName

	db SURFING_PIKACHU1
	tx SurfingPikachuTradeCardName

	db SURFING_PIKACHU2
	tx SurfingPikachuTradeCardName

	db ELECTABUZZ1
	tx ElectabuzzTradeCardName

	db SLOWPOKE1
	tx SlowpokeTradeCardName

	db MEWTWO3
	tx MewtwoTradeCardName

	db MEWTWO2
	tx MewtwoTradeCardName

	db MEW1
	tx MewTradeCardName

	db JIGGLYPUFF1
	tx JigglypuffTradeCardName

	db SUPER_ENERGY_RETRIEVAL
	tx SuperEnergyRetrievalTradeCardName

	db FLYING_PIKACHU
	tx FlyingPikachuTradeCardName

Func_d209: ; d209 (3:5209)
	get_flag_value EVENT_FLAG_71
	ld e, a
.asm_d20e
	call UpdateRNGSources
	ld d, $8
	and $3
	ld c, a
	ld b, a
.asm_d217
	jr z, .asm_d21e
	srl d
	dec b
	jr .asm_d217

.asm_d21e
	ld a, d
	and e
	jr nz, .asm_d20e
	push bc
	ld b, $0
	ld hl, Flags_d240
	add hl, bc
	ld a, [hl]
	call MaxOutEventFlag
	pop bc
	ld hl, LegendaryCards
	ld a, c
	jr asm_d1c6

LegendaryCards: ; d234 (3:5234)
	db ZAPDOS3
	tx ZapdosLegendaryCardName

	db MOLTRES2
	tx MoltresLegendaryCardName

	db ARTICUNO2
	tx ArticunoLegendaryCardName

	db DRAGONITE1
	tx DragoniteLegendaryCardName

Flags_d240: ; d240 (3:5240)
	db EVENT_FLAG_6D
	db EVENT_FLAG_6E
	db EVENT_FLAG_6F
	db EVENT_FLAG_70

Func_d244: ; d244 (3:5244)
	ld a, c
	farcall Func_80ba4
	jp IncreaseScriptPointerBy2

ScriptCommand_ChooseDeckToDuelAgainstMultichoice: ; d24c (3:524c)
	ld hl, .multichoice_menu_args
	xor a
	call ShowMultichoiceTextbox
	ld a, [wMultichoiceTextboxResult_ChooseDeckToDuelAgainst]
	ld c, a
	set_flag_value EVENT_FLAG_76
	jp IncreaseScriptPointerBy1

.multichoice_menu_args ; d25e
	dw NULL ; NPC title for textbox under menu
	tx Text03f9 ; text for textbox under menu
	dw MultichoiceTextbox_ConfigTable_ChooseDeckToDuelAgainst ; location of table configuration in bank 4
	db $03 ; the value to return when b is pressed
	dw wMultichoiceTextboxResult_ChooseDeckToDuelAgainst ; ram location to return result into
	dw .text_entries ; location of table containing text entries

.text_entries ; d269
	tx Text03f6
	tx Text03f7
	tx Text03f8

	dw NULL

ScriptCommand_ChooseStarterDeckMultichoice: ; d271 (3:5271)
	ld hl, .multichoice_menu_args
	xor a
	call ShowMultichoiceTextbox
	jp IncreaseScriptPointerBy1

.multichoice_menu_args ; d27b
	dw NULL ; NPC title for textbox under menu
	tx Text03fd ; text for textbox under menu
	dw MultichoiceTextbox_ConfigTable_ChooseDeckStarterDeck ; location of table configuration in bank 4
	db $00 ; the value to return when b is pressed
	dw wd693 ; ram location to return result into
	dw .text_entries ; location of table containing text entries

.text_entries
	tx Text03fa
	tx Text03fb
	tx Text03fc

; displays a textbox with multiple choices and a cursor.
; takes as an argument in h1 a pointer to a table
;	dw text id for NPC title for textbox under menu
;	dw text id for textbox under menu
;	dw location of table configuration in bank 4
;	db the value to return when b is pressed
;	dw ram location to return result into
;	dw location of table containing text entries (optional)

ShowMultichoiceTextbox: ; d28c (3:528c)
	ld [wd416], a
	push hl
	call Func_c241
	call Func_c915
	call DoFrameIfLCDEnabled
	pop hl
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	push hl
	ld h, [hl]
	ld l, a
	or h
	jr z, .asm_d2a8
	call Func_c8ba

.asm_d2a8
	ld a, $1
	call Func_c29b
	pop hl
	inc hl
	ld a, [hli]
	push hl
	ld h, [hl]
	ld l, a
	ld a, [wd416]
	farcall Func_111e9
	pop hl
	inc hl
	ld a, [hli]
	ld [wd417], a
	push hl

.asm_d2c1
	call DoFrameIfLCDEnabled
	call HandleMenuInput
	jr nc, .asm_d2c1
	ld a, [hCurMenuItem]
	cp e
	jr z, .asm_d2d9
	ld a, [wd417]
	or a
	jr z, .asm_d2c1
	ld e, a
	ld [hCurMenuItem], a

.asm_d2d9
	pop hl
	ld a, [hli]
	push hl
	ld h, [hl]
	ld l, a
	ld a, e
	ld [hl], a
	add a
	ld c, a
	ld b, $0
	pop hl
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	or h
	jr z, .asm_d2f5
	add hl, bc
	ld a, [hli]
	ld [wTxRam2], a
	ld a, [hl]
	ld [wTxRam2 + 1], a

.asm_d2f5
	ret

ScriptCommand_ShowSamNormalMultichoice: ; d2f6 (3:52f6)
	ld hl, .multichoice_menu_args
	xor a
	call ShowMultichoiceTextbox
	ld a, [wMultichoiceTextboxResult_Sam]
	ld c, a
	set_flag_value EVENT_FLAG_75
	xor a
	ld [wMultichoiceTextboxResult_Sam], a
	jp IncreaseScriptPointerBy1

.multichoice_menu_args ; d30c
	tx SamNPCName ; NPC title for textbox under menu
	tx HowCanIHelpText ; text for textbox under menu
	dw SamNormalMultichoice_ConfigurationTable ; location of table configuration in bank 4
	db $03 ; the value to return when b is pressed
	dw wMultichoiceTextboxResult_Sam ; ram location to return result into
	dw NULL ; location of table containing text entries

ScriptCommand_ShowSamTutorialMultichoice: ; d317 (3:5317)
	ld hl, .multichoice_menu_args
	ld a, [wMultichoiceTextboxResult_Sam]
	call ShowMultichoiceTextbox
	ld a, [wMultichoiceTextboxResult_Sam]
	ld c, a
	set_flag_value EVENT_FLAG_75
	jp IncreaseScriptPointerBy1

.multichoice_menu_args ; d32b (3:532b)
	dw NULL ; NPC title for textbox under menu
	dw NULL ; text for textbox under menu
	dw SamTutorialMultichoice_ConfigurationTable ; location of table configuration in bank 4
	db $07 ; the value to return when b is pressed
	dw wMultichoiceTextboxResult_Sam ; ram location to return result into
	dw NULL ; location of table containing text entries

ScriptCommand_OpenDeckMachine: ; d336 (3:5336)
	push bc
	call Func_c2a3
	call PauseSong
	ld a, MUSIC_DECK_MACHINE
	call PlaySong
	call EmptyScreen
	xor a
	ldh [hSCX], a
	ldh [hSCY], a
	farcall Func_1288c
	call EnableLCD
	pop bc
	ld a, c
	or a
	jr z, .asm_d360
	dec a
	ld [wd0a9], a
	farcall Func_ba04
	jr .asm_d364
.asm_d360
	farcall Func_b19d
.asm_d364
	call ResumeSong
	call Func_c2d4
	jp IncreaseScriptPointerBy2

; args: unused, room, new player x, new player y, new player direction
ScriptCommand_EnterMap: ; d36d (3:536d)
	ld a, [wScriptPointer]
	ld l, a
	ld a, [wScriptPointer+1]
	ld h, a
	inc hl
	ld a, [hli]
	ld a, [hli]
	ld [wTempMap], a
	ld a, [hli]
	ld [wTempPlayerXCoord], a
	ld a, [hli]
	ld [wTempPlayerYCoord], a
	ld a, [hli]
	ld [wTempPlayerDirection], a
	ld hl, wd0b4
	set 4, [hl]
	jp IncreaseScriptPointerBy6

Func_d38f: ; d38f (3:538f)
	farcall Func_10c96
	jp IncreaseScriptPointerBy2

Func_d396: ; d396 (3:5396)
	farcall Func_1157c
	jp IncreaseScriptPointerBy2

Func_d39d: ; d39d (3:539d)
	ld a, c
	or a
	jr nz, .asm_d3ac
	farcall Func_10dba
	ld c, a
	set_flag_value EVENT_FLAG_72
	jr .asm_d3b6

.asm_d3ac
	ld a, GAME_EVENT_GIFT_CENTER
	ld [wGameEvent], a
	ld hl, wd0b4
	set 6, [hl]

.asm_d3b6
	jp IncreaseScriptPointerBy2

Func_d3b9: ; d3b9 (3:53b9)
	call Func_3917
	ld a, GAME_EVENT_CREDITS
	ld [wGameEvent], a
	ld hl, wd0b4
	set 6, [hl]
	jp IncreaseScriptPointerBy1

ScriptCommand_TryGivePCPack: ; d3c9 (3:53c9)
	ld a, c
	farcall TryGivePCPack
	jp IncreaseScriptPointerBy2

ScriptCommand_nop: ; d3d1 (3:53d1)
	jp IncreaseScriptPointerBy1

Func_d3d4: ; d3d4 (3:53d4)
	ld a, [wd693]
	bank1call Func_7576
	jp IncreaseScriptPointerBy1

	INCROM $d3dd, $d3e0

Func_d3e0: ; d3e0 (3:53e0)
	ld a, $1
	ld [wd32e], a
	farcall Func_11024
.asm_d3e9
	call DoFrameIfLCDEnabled
	farcall Func_11060
	ld a, [wd33e]
	cp $2
	jr nz, .asm_d3e9
	farcall Func_10f2e
	jp IncreaseScriptPointerBy1

Func_d3fe: ; d3fe (3:53fe)
	ld a, c
	ld [wd112], a
	call PlaySong
	jp IncreaseScriptPointerBy2

Func_d408: ; d408 (3:5408)
	ld a, c
	ld [wd111], a
	jp IncreaseScriptPointerBy2

Func_d40f: ; d40f (3:540f)
	ld a, c
	call CallPlaySong
	jp IncreaseScriptPointerBy2

ScriptCommand_PlaySFX: ; d416 (3:5416)
	ld a, c
	call PlaySFX
	jp IncreaseScriptPointerBy2

Func_d41d: ; d41d (3:541d)
	call Func_39fc
	jp IncreaseScriptPointerBy1

ScriptCommand_PauseSong: ; d423 (3:5423)
	call PauseSong
	jp IncreaseScriptPointerBy1

ScriptCommand_ResumeSong: ; d429 (3:5429)
	call ResumeSong
	jp IncreaseScriptPointerBy1

ScriptCommand_WaitForSongToFinish: ; d42f (3:542f)
	call WaitForSongToFinish
	jp IncreaseScriptPointerBy1

Func_d435: ; d435 (3:5435)
	ld a, c
	farcall Func_1c83d
	jp IncreaseScriptPointerBy2

Func_d43d: ; d43d (3:543d)
	ld a, GAME_EVENT_CHALLENGE_MACHINE
	ld [wGameEvent], a
	ld hl, wd0b4
	set 6, [hl]
	jp IncreaseScriptPointerBy1

; sets the event flag in arg 1 to the value in arg 2
ScriptCommand_SetFlagValue: ; d44a (3:544a)
	ld a, c
	ld c, b
	call SetEventFlagValue
	jp IncreaseScriptPointerBy3

ScriptCommand_IncrementFlagValue: ; d452 (3:5452)
	ld a, c
	push af
	call GetEventFlagValue
	inc a
	ld c, a
	pop af
	call SetEventFlagValue
	jp IncreaseScriptPointerBy2

ScriptCommand_JumpIfFlagZero1: ; d460 (3:5460)
	ld a, c
	call GetEventFlagValue
	or a
	jr z, .passTryJump

.fail
	call SetScriptControlByteFail
	jp IncreaseScriptPointerBy4

.passTryJump
	call SetScriptControlBytePass
	call GetScriptArgs2AfterPointer
	jr z, .noJumpTarget
	jp SetScriptPointer

.noJumpTarget
	jp IncreaseScriptPointerBy4

ScriptCommand_JumpIfFlagNonzero1: ; d47b (3:547b)
	ld a, c
	call GetEventFlagValue
	or a
	jr nz, ScriptCommand_JumpIfFlagZero1.passTryJump
	jr ScriptCommand_JumpIfFlagZero1.fail

; args - event flag, value, jump address
ScriptCommand_JumpIfFlagEqual: ; d484 (3:5484)
	call GetEventFlagValueBC
	cp c
	jr z, ScriptEventPassedTryJump

ScriptEventFailedNoJump: ; d48a (3:548a)
	call SetScriptControlByteFail
	jp IncreaseScriptPointerBy5

ScriptEventPassedTryJump: ; d490 (3:5490)
	call SetScriptControlBytePass
	call GetScriptArgs3AfterPointer
	jr z, .noJumpAddress
	jp SetScriptPointer

.noJumpAddress
	jp IncreaseScriptPointerBy5

ScriptCommand_JumpIfFlagNotEqual: ; d49e (3:549e)
	call GetEventFlagValueBC
	cp c
	jr nz, ScriptEventPassedTryJump
	jr ScriptEventFailedNoJump

ScriptCommand_JumpIfFlagNotLessThan: ; d4a6 (3:54a6)
	call GetEventFlagValueBC
	cp c
	jr nc, ScriptEventPassedTryJump
	jr ScriptEventFailedNoJump

ScriptCommand_JumpIfFlagLessThan: ; d4ae (3:54ae)
	call GetEventFlagValueBC
	cp c
	jr c, ScriptEventPassedTryJump
	jr ScriptEventFailedNoJump

; Gets event flag at c (Script defaults)
; c takes on the value of b as a side effect
GetEventFlagValueBC: ; d4b6 (3:54b6)
	ld a, c
	ld c, b
	call GetEventFlagValue
	ret

ScriptCommand_MaxOutFlagValue: ; d4bc (3:54bc)
	ld a, c
	call MaxOutEventFlag
	jp IncreaseScriptPointerBy2

ScriptCommand_ZeroOutFlagValue: ; d4c3 (3:54c3)
	ld a, c
	call ZeroOutEventFlag
	jp IncreaseScriptPointerBy2

ScriptCommand_JumpIfFlagNonzero2: ; d4ca (3:54ca)
	ld a, c
	call GetEventFlagValue
	or a
	jr z, ScriptCommand_JumpIfFlagZero2.fail

.passTryJump
	call SetScriptControlBytePass
	call GetScriptArgs2AfterPointer
	jr z, .noJumpArgs
	jp SetScriptPointer
.noJumpArgs
	jp IncreaseScriptPointerBy4

ScriptCommand_JumpIfFlagZero2: ; d4df (3:54df)
	ld a, c
	call GetEventFlagValue
	or a
	jr z, ScriptCommand_JumpIfFlagNonzero2.passTryJump

.fail
	call SetScriptControlByteFail
	jp IncreaseScriptPointerBy4

LoadOverworld: ; d4ec (3:54ec)
	call Func_d4fb
	get_flag_value EVENT_FLAG_3E
	or a
	ret nz
	ld bc, Script_BeginGame
	jp SetNextScript

Func_d4fb: ; d4fb (3:54fb)
	zero_flag_value EVENT_FLAG_59
	call Func_f602
	get_flag_value EVENT_FLAG_3F
	cp $02
	jr z, .asm_d527
	get_flag_value EVENT_FLAG_40
	cp $02
	jr z, .asm_d521
	get_flag_value EVENT_FLAG_41
	cp $02
	jr z, .asm_d51b
	ret
.asm_d51b
	ld c, $07
	set_flag_value EVENT_FLAG_41
.asm_d521
	ld c, $07
	set_flag_value EVENT_FLAG_40
.asm_d527
	ld c, $07
	set_flag_value EVENT_FLAG_3F
	ret

Script_BeginGame: ; d52e (3:552e)
	start_script
	do_frames 60
	run_command Func_d3e0
	do_frames 120
	enter_map $02, MASON_LABORATORY, 14, 26, NORTH
	quit_script_fully

MasonLaboratoryAfterDuel: ; d53b (3:553b)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_SAM
	db NPC_SAM
	dw Script_BeatSam
	dw Script_LostToSam
	db $00

MasonLabLoadMap: ; d549 (3:5549)
	get_flag_value EVENT_FLAG_3E
	cp $03
	ret nc
	ld a, NPC_DRMASON
	ld [wTempNPC], a
	call FindLoadedNPC
	ld bc, Script_EnterLabFirstTime
	jp SetNextNPCAndScript

MasonLabCloseTextBox: ; d55e (3:555e)
	ld a, $0a
	farcall Func_80b89
	ret

; Lets you access the Challenge Machine if available
MasonLabPressedA: ; d565 (3:5565)
	get_flag_value EVENT_RECEIVED_LEGENDARY_CARD
	or a
	ret z
	ld hl, ChallengeMachineObjectTable
	call FindExtraInteractableObjects
	ret

ChallengeMachineObjectTable: ; d572 (3:5572)
	db 10, 4, NORTH
	dw Script_ChallengeMachine
	db 12, 4, NORTH
	dw Script_ChallengeMachine
	db $00

Script_ChallengeMachine: ; d57d (3:557d)
	start_script
	run_command Func_ccdc
	tx Text05bd
	run_command Func_d43d
	quit_script_fully

Script_Tech1: ; d583 (3:5583)
	INCROM $d583, $d5ca

Script_Tech2: ; d5ca (3:55ca)
	INCROM $d5ca, $d5d5

Script_Tech3: ; d5d5 (3:55d5)
	INCROM $d5d5, $d5e0

Script_Tech4: ; d5e0 (3:55e0)
	INCROM $d5e0, $d5eb

Preload_Tech5: ; d5eb (3:55eb)
	INCROM $d5eb, $d5f9

Script_Tech5: ; d5f9 (3:55f9)
	INCROM $d5f9, $d604

Preload_Sam: ; d604 (3:5604)
	INCROM $d604, $d61d

Script_Sam: ; d61d (3:561d)
	INCROM $d61d, $d68a

Script_BeatSam: ; d68a (3:568a)
	INCROM $d68a, $d69f

Script_LostToSam: ; d69f (3:569f)
	INCROM $d69f, $d710

Preload_DrMason: ; d710 (3:5710)
	INCROM $d710, $d727

Script_DrMason: ; d727 (3:5727)
	INCROM $d727, $d753

Script_EnterLabFirstTime: ; d753 (3:5753)
	start_script
	move_player NORTH, 2
	move_player NORTH, 2
	move_player NORTH, 2
	move_player NORTH, 2
	move_player NORTH, 2
	move_player NORTH, 2
	move_player NORTH, 2
	move_player NORTH, 2
	move_player NORTH, 2
	print_text_string Text05e3
	close_advanced_text_box
	set_next_npc_and_script NPC_SAM, Script_d779
	end_script_loop
	ret

Script_d779: ; d779 (03:5779)
	start_script
	move_active_npc NPCMovement_d880
	print_text_string Text05e4
	set_dialog_npc NPC_DRMASON
	print_text_string Text05e5
	close_text_box
	move_active_npc NPCMovement_d882
	run_command Func_cfc6
	db $01
	set_player_direction WEST
	close_advanced_text_box
	set_next_npc_and_script NPC_DRMASON, Script_d794
	end_script_loop
	ret

Script_d794: ; d794 (3:5794)
	start_script
	move_active_npc NPCMovement_d88b
	do_frames 40
	print_text_string Text05e6
	close_text_box
	move_player WEST, 1
	move_player WEST, 1
	set_player_direction SOUTH
	move_player SOUTH, 1
	move_player SOUTH, 1
	move_player SOUTH, 1
	set_player_direction WEST
	move_active_npc NPCMovement_d894
	print_text_string Text05e7
	set_dialog_npc $07
	print_text_string Text05e8

.ows_d7bc
	close_text_box
	show_sam_tutorial_multichoice
	close_text_box
	jump_if_flag_equal EVENT_FLAG_75, $07, .ows_d80c
	jump_if_flag_equal EVENT_FLAG_75, $01, .ows_d7e8
	jump_if_flag_equal EVENT_FLAG_75, $02, .ows_d7ee
	jump_if_flag_equal EVENT_FLAG_75, $03, .ows_d7f4
	jump_if_flag_equal EVENT_FLAG_75, $04, .ows_d7fa
	jump_if_flag_equal EVENT_FLAG_75, $05, .ows_d800
	jump_if_flag_equal EVENT_FLAG_75, $06, .ows_d806
	print_text_string Text05d6
	script_jump .ows_d7bc

.ows_d7e8
	print_text_string Text05d7
	script_jump .ows_d7bc

.ows_d7ee
	print_text_string Text05d8
	script_jump .ows_d7bc

.ows_d7f4
	print_text_string Text05d9
	script_jump .ows_d7bc

.ows_d7fa
	print_text_string Text05da
	script_jump .ows_d7bc

.ows_d800
	print_text_string Text05db
	script_jump .ows_d7bc

.ows_d806
	print_text_string Text05dc
	script_jump .ows_d7bc

.ows_d80c
	print_text_string Text05e9
	ask_question_jump_default_yes NULL, .ows_d817
	script_jump .ows_d7bc

.ows_d817
	set_dialog_npc $01
	print_text_string Text05ea
	script_nop
	script_set_flag_value EVENT_FLAG_3E, $01
	close_advanced_text_box
	set_next_npc_and_script NPC_SAM, Script_d827
	end_script_loop
	ret

Script_d827: ; d827 (3:5827)
	start_script
	start_battle PRIZES_2, SAMS_PRACTICE_DECK_ID, MUSIC_DUEL_THEME_1
	quit_script_fully
; 0xd82d

	INCROM $d82d, $d834

AfterTutorialBattleScript: ; d834 (3:5834)
	start_script
	print_text_string Text05eb
	print_text_string Text05ef
	close_text_box
	move_active_npc NPCMovement_d896
	set_player_direction NORTH
	move_player NORTH, 1
	move_player NORTH, 1
	move_player NORTH, 1
	set_player_direction EAST
	move_player EAST, 1
	move_player EAST, 1
	set_player_direction NORTH
	print_text_string Text05f0
	close_text_box
	run_command Func_ccdc
	tx Text05f1
	close_text_box
	print_text_string Text05f2
.ows_d85f
	choose_starter_deck_multichoice
	close_text_box
	ask_question_jump Text05f3, .ows_d869
	script_jump .ows_d85f
.ows_d869
	print_text_string Text05f4
	close_text_box
	pause_song
	run_command Func_d40f
	try_give_medal_pc_packs
	run_command Func_ccdc
	tx Text05f5
	wait_for_song_to_finish
	resume_song
	close_text_box
	script_set_flag_value EVENT_FLAG_3E, $03
	run_command Func_d3d4
	print_text_string Text05f6
	run_command Func_d396
	db $00
	quit_script_fully

NPCMovement_d880: ; d880 (3:5880)
	db EAST
	db $ff

NPCMovement_d882: ; d882 (3:5882)
	db SOUTH
	db SOUTH
	db WEST
	db WEST
	db WEST
	db WEST
	db SOUTH
	db EAST | NO_MOVE
	db $ff

NPCMovement_d88b: ; d88b (3:588b)
	db WEST
	db SOUTH
	db SOUTH
	db SOUTH
	db WEST
	db WEST
	db WEST
	db EAST | NO_MOVE
	db $ff

NPCMovement_d894: ; d894 (4:5894)
	db SOUTH | NO_MOVE
	db $ff

NPCMovement_d896: ; d896 (3:5896)
	db NORTH
	db NORTH
	db NORTH
	db EAST
	db EAST
	db EAST
	db EAST
	db SOUTH | NO_MOVE
	db $ff

DeckMachineRoomAfterDuel: ; d89f (3:589f)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_AARON
	db NPC_AARON
	dw Script_BeatAaron
	dw Script_LostToAaron
	db $00

DeckMachineRoomCloseTextBox: ; d8ad (3:58ad)
	INCROM $d8ad, $d8bb

Script_Tech6: ; d8bb (3:58bb)
	INCROM $d8bb, $d8c6

Script_Tech7: ; d8c6 (3:58c6)
	INCROM $d8c6, $d8d1

Script_Tech8: ; d8d1 (3:58d1)
	INCROM $d8d1, $d8dd

Script_Aaron: ; d8dd (3:58dd)
	INCROM $d8dd, $d903

Script_BeatAaron: ; d903 (3:5903)
	INCROM $d903, $d92e

Script_LostToAaron: ; d92e (3:592e)
	INCROM $d92e, $d932

Script_d932: ; d932 (3:5932)
	start_script
	run_command Func_ccdc
	tx Text0605
	ask_question_jump_default_yes Text0606, .ows_d93c
	quit_script_fully

.ows_d93c
	open_deck_machine $09
	quit_script_fully

Script_d93f: ; d93f (3:593f)
	INCROM $d93f, $d995

Script_d995: ; d995 (3:5995)
	INCROM $d995, $d9c2

Script_d9c2: ; d9c2 (3:59c2)
	INCROM $d9c2, $d9ef

Script_d9ef: ; d9ef (3:59ef)
	INCROM $d9ef, $da1c

Script_da1c: ; da1c (3:5a1c)
	INCROM $da1c, $da49

Script_da49: ; da49 (3:5a49)
	INCROM $da49, $da76

Script_da76: ; da76 (3:5a76)
	INCROM $da76, $daa3

Script_daa3: ; daa3 (3:5aa3)
	INCROM $daa3, $dad0

Script_dad0: ; dad0 (3:5ad0)
	INCROM $dad0, $dadd

Preload_NikkiInIshiharasHouse: ; dadd (3:5add)
	get_flag_value EVENT_FLAG_35
	cp $01
	jr nz, .dontLoadNikki
	scf
	ret
.dontLoadNikki
	or a
	ret
; 0xdae9

	INCROM $dae9, $db3d

Preload_IshiharaInIshiharasHouse: ; db3d (3:5b3d)
	get_flag_value EVENT_FLAG_1C
	or a
	ret z
	get_flag_value EVENT_FLAG_1F
	cp $08
	ret

Script_Ishihara: ; db4a (3:5b4a)
	start_script
	max_out_flag_value EVENT_FLAG_1D
	jump_if_flag_equal EVENT_FLAG_1F, $00, .ows_db80
	jump_if_flag_nonzero_2 EVENT_FLAG_39, .ows_db5a
	jump_if_flag_nonzero_2 EVENT_RECEIVED_LEGENDARY_CARD, .ows_dc3e
.ows_db5a
	jump_if_flag_nonzero_2 EVENT_FLAG_00, .ows_db90
	jump_if_flag_zero_2 EVENT_FLAG_38, .ows_db90
	jump_if_flag_equal EVENT_FLAG_1F, $01, .ows_db93
	jump_if_flag_equal EVENT_FLAG_1F, $02, .ows_db93
	jump_if_flag_equal EVENT_FLAG_1F, $03, .ows_dbcc
	jump_if_flag_equal EVENT_FLAG_1F, $04, .ows_dbcc
	jump_if_flag_equal EVENT_FLAG_1F, $05, .ows_dc05
	jump_if_flag_equal EVENT_FLAG_1F, $06, .ows_dc05
.ows_db80
	max_out_flag_value EVENT_FLAG_00
	script_set_flag_value EVENT_FLAG_1F, $01
	zero_out_flag_value EVENT_FLAG_38
	jump_if_flag_zero_2 EVENT_RECEIVED_LEGENDARY_CARD, .ows_db8d
	max_out_flag_value EVENT_FLAG_39
.ows_db8d
	print_text_quit_fully Text0727

.ows_db90
	print_text_quit_fully Text0728

.ows_db93
	jump_if_flag_equal EVENT_FLAG_1F, $01, NULL
	print_variable_text Text0729, Text072a
	script_set_flag_value EVENT_FLAG_1F, $02
	ask_question_jump Text072b, .check_ifhave_clefable_incollectionordecks
	print_text_quit_fully Text072c

.check_ifhave_clefable_incollectionordecks
	jump_if_card_owned CLEFABLE, .check_ifhave_clefable_incollectiononly
	print_text_quit_fully Text072d

.check_ifhave_clefable_incollectiononly
	jump_if_card_in_collection CLEFABLE, .do_clefable_trade
	print_text_quit_fully Text072e

.do_clefable_trade
	max_out_flag_value EVENT_FLAG_00
	script_set_flag_value EVENT_FLAG_1F, $03
	zero_out_flag_value EVENT_FLAG_38
	print_text_string Text072f
	run_command Func_ccdc
	tx Text0730
	take_card CLEFABLE
	give_card SURFING_PIKACHU1
	show_card_received_screen SURFING_PIKACHU1
	print_text_quit_fully Text0731

.ows_dbcc
	jump_if_flag_equal EVENT_FLAG_1F, $03, NULL
	print_variable_text Text0732, Text0733
	script_set_flag_value EVENT_FLAG_1F, $04
	ask_question_jump Text072b, .check_ifhave_ditto_incollectionordecks
	print_text_quit_fully Text072c

.check_ifhave_ditto_incollectionordecks
	jump_if_card_owned DITTO, .check_ifhave_ditto_incollectiononly
	print_text_quit_fully Text0734

.check_ifhave_ditto_incollectiononly
	jump_if_card_in_collection DITTO, .do_ditto_trade
	print_text_quit_fully Text0735

.do_ditto_trade
	max_out_flag_value EVENT_FLAG_00
	script_set_flag_value EVENT_FLAG_1F, $05
	zero_out_flag_value EVENT_FLAG_38
	print_text_string Text072f
	run_command Func_ccdc
	tx Text0736
	take_card DITTO
	give_card FLYING_PIKACHU
	show_card_received_screen FLYING_PIKACHU
	print_text_quit_fully Text0737

.ows_dc05
	jump_if_flag_equal EVENT_FLAG_1F, $05, NULL
	print_variable_text Text0738, Text0739
	script_set_flag_value EVENT_FLAG_1F, $06
	ask_question_jump Text072b, .check_ifhave_chansey_incollectionordecks
	print_text_quit_fully Text072c

.check_ifhave_chansey_incollectionordecks
	jump_if_card_owned CHANSEY, .check_ifhave_chansey_incollectiononly
	print_text_quit_fully Text073a

.check_ifhave_chansey_incollectiononly
	jump_if_card_in_collection CHANSEY, .do_chansey_trade
	print_text_quit_fully Text073b

.do_chansey_trade
	max_out_flag_value EVENT_FLAG_00
	script_set_flag_value EVENT_FLAG_1F, $07
	zero_out_flag_value EVENT_FLAG_38
	print_text_string Text072f
	run_command Func_ccdc
	tx Text073c
	take_card CHANSEY
	give_card SURFING_PIKACHU2
	show_card_received_screen SURFING_PIKACHU2
	print_text_quit_fully Text073d

.ows_dc3e
	max_out_flag_value EVENT_FLAG_39
	print_text_quit_fully Text073e

Preload_Ronald1InIshiharasHouse: ; dc43 (3:5c43)
	get_flag_value EVENT_RECEIVED_LEGENDARY_CARD
	cp $01
	ccf
	ret

Script_Ronald: ; dc4b (3:5c4b)
	start_script
	jump_if_flag_nonzero_2 EVENT_FLAG_4E, .ows_dc55
	max_out_flag_value EVENT_FLAG_4E
	print_text_quit_fully Text073f

.ows_dc55
	print_text_string Text0740
	ask_question_jump Text0741, .ows_dc60
	print_text_quit_fully Text0742

.ows_dc60
	print_text_quit_fully Text0743

	; could be a commented function, or could be placed by mistake from
	; someone thinking that the Ronald script ended with more code execution
	ret

Script_Clerk1: ; dc64 (3:5c64)
	start_script
	print_text_quit_fully Text045a

FightingClubLobbyAfterDuel: ; dc68 (3:5c68)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_IMAKUNI
	db NPC_IMAKUNI
	dw Script_BeatImakuni
	dw Script_LostToImakuni
	db $00

Script_Man1: ; dc76 (3:5c76)
	INCROM $dc76, $dceb

Preload_ImakuniInFightingClubLobby: ; dceb (3:5ceb)
	INCROM $dceb, $dd0d

Script_Imakuni: ; dd0d (3:5d0d)
	start_script
	script_set_flag_value EVENT_IMAKUNI_STATE, IMAKUNI_TALKED
	jump_if_flag_zero_2 EVENT_TEMP_TALKED_TO_IMAKUNI, NULL
	print_variable_text Text0467, Text0468
	max_out_flag_value EVENT_TEMP_TALKED_TO_IMAKUNI
	ask_question_jump Text0469, .acceptDuel
	print_text_string Text046a
	quit_script_fully

.acceptDuel
	print_text_string Text046b
	start_battle PRIZES_6, IMAKUNI_DECK_ID, MUSIC_IMAKUNI
	quit_script_fully

Script_BeatImakuni: ; dd2d (3:5d2d)
	start_script
	jump_if_flag_equal EVENT_IMAKUNI_WIN_COUNT, $07, .giveBoosters
	script_increment_flag_value EVENT_IMAKUNI_WIN_COUNT
	jump_if_flag_equal EVENT_IMAKUNI_WIN_COUNT, $03, .threeWins
	jump_if_flag_equal EVENT_IMAKUNI_WIN_COUNT, $06, .sixWins
.giveBoosters
	print_text_string Text046c
	give_one_of_each_trainer_booster
	script_jump .done

.threeWins
	print_text_string Text046d
	script_jump .giveImakuniCard

.sixWins
	print_text_string Text046e
.giveImakuniCard
	print_text_string Text046f
	give_card IMAKUNI_CARD
	show_card_received_screen IMAKUNI_CARD
.done
	print_text_string Text0470
	script_jump ScriptJump_ImakuniCommon

Script_LostToImakuni: ; dd5c (3:5d5c)
	start_script
	print_text_string Text0471

ScriptJump_ImakuniCommon: ; dd60 (3:5d60)
	close_text_box
	jump_if_player_coords_match 18, 4, .ows_dd69
	script_jump .ows_dd6e

.ows_dd69
	set_player_direction EAST
	move_player WEST, 1

.ows_dd6e
	move_active_npc NPCMovement_dd78
	run_command Func_cdcb
	max_out_flag_value EVENT_TEMP_BATTLED_IMAKUNI
	run_command Func_d408
	db $09
	run_command Func_d41d
	quit_script_fully

NPCMovement_dd78: ; dd78 (3:5d78)
	db SOUTH
	db SOUTH
	db SOUTH
	db SOUTH
	db EAST
	db EAST
	db EAST
	db EAST
	db EAST
	db $ff

Script_Specs1: ; dd82 (3:5d82)
	INCROM $dd82, $dd8d

Script_Butch: ; dd8d (3:5d8d)
	INCROM $dd8d, $dd98

Preload_Granny1: ; dd98 (3:5d98)
	INCROM $dd98, $dd9f

Script_Granny1: ; dd9f (3:5d9f)
	INCROM $dd9f, $dda3

FightingClubAfterDuel: ; dda3 (3:5da3)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_CHRIS
	db NPC_CHRIS
	dw Script_BeatChrisInFightingClub
	dw Script_LostToChrisInFightingClub

	db NPC_MICHAEL
	db NPC_MICHAEL
	dw Script_BeatMichaelInFightingClub
	dw Script_LostToMichaelInFightingClub

	db NPC_JESSICA
	db NPC_JESSICA
	dw Script_BeatJessicaInFightingClub
	dw Script_LostToJessicaInFightingClub

	db NPC_MITCH
	db NPC_MITCH
	dw Script_BeatMitch
	dw Script_LostToMitch
	db $00

Script_Mitch: ; ddc3 (3:5dc3)
	start_script
	try_give_pc_pack $02
	jump_if_flag_nonzero_2 EVENT_FLAG_0F, Script_Mitch_AlreadyHaveMedal
	fight_club_pupil_jump .first_interaction, .three_pupils_remaining, \
		.two_pupils_remaining, .one_pupil_remaining, .all_pupils_defeated
.first_interaction
	print_text_string Text0477
	script_set_flag_value EVENT_FLAG_11, $01
	script_set_flag_value EVENT_FLAG_17, $01
	script_set_flag_value EVENT_FLAG_20, $01
	quit_script_fully
.three_pupils_remaining
	print_text_quit_fully Text0478
.two_pupils_remaining
	print_text_quit_fully Text0479
.one_pupil_remaining
	print_text_quit_fully Text047a
.all_pupils_defeated
	print_text_string Text047b
	ask_question_jump Text047c, .do_battle
	print_text_string Text047d
	quit_script_fully
.do_battle
	print_text_string Text047e
	start_battle PRIZES_6, FIRST_STRIKE_DECK_ID, MUSIC_DUEL_THEME_2
	quit_script_fully

Script_BeatMitch: ; ddff (3:5dff)
	start_script
	jump_if_flag_nonzero_2 EVENT_FLAG_0F, Script_Mitch_GiveBoosters
	print_text_string Text047f
	max_out_flag_value EVENT_FLAG_0F
	try_give_medal_pc_packs
	run_command Func_d125
	db $0f
	run_command Func_d435
	db $01
	print_text_string Text0480
	give_booster_packs BOOSTER_LABORATORY_NEUTRAL, BOOSTER_LABORATORY_NEUTRAL, NO_BOOSTER
	print_text_string Text0481
	quit_script_fully

Script_LostToMitch: ; de19 (3:5e19)
	start_script
	jump_if_flag_nonzero_2 EVENT_FLAG_0F, Script_Mitch_PrintTrainHarderText
	print_text_quit_fully Text0482

Script_Mitch_AlreadyHaveMedal: ; de21 (3:5e21)
	print_text_string Text0483
	ask_question_jump Text047c, .do_battle
	print_text_string Text0484
	quit_script_fully
.do_battle
	print_text_string Text0485
	start_battle PRIZES_6, FIRST_STRIKE_DECK_ID, MUSIC_DUEL_THEME_2
	quit_script_fully

Script_Mitch_GiveBoosters:
	print_text_string Text0486
	give_booster_packs BOOSTER_LABORATORY_NEUTRAL, BOOSTER_LABORATORY_NEUTRAL, NO_BOOSTER
	print_text_string Text0487
	quit_script_fully

Script_Mitch_PrintTrainHarderText:
	print_text_quit_fully Text0488

Preload_ChrisInFightingClub: ; de43 (3:5e43)
	INCROM $de43, $de69

Script_BeatChrisInFightingClub: ; de69 (3:5e69)
	INCROM $de69, $de75

Script_LostToChrisInFightingClub: ; de75 (3:5e75)
	INCROM $de75, $de79

Preload_MichaelInFightingClub: ; de79 (3:5e79)
	INCROM $de79, $de95

Script_BeatMichaelInFightingClub: ; de95 (3:5e95)
	INCROM $de95, $dea1

Script_LostToMichaelInFightingClub: ; dea1 (3:5ea1)
	INCROM $dea1, $dea5

Preload_JessicaInFightingClub: ; dea5 (3:5ea5)
	INCROM $dea5, $dec1

Script_BeatJessicaInFightingClub: ; dec1 (3:5ec1)
	INCROM $dec1, $decd

Script_LostToJessicaInFightingClub: ; decd (3:5ecd)
	INCROM $decd, $ded1

Script_Clerk2: ; ded1 (3:5ed1)
	INCROM $ded1, $ded5

RockClubLobbyAfterDuel: ; ded5 (3:5ed5)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_CHRIS
	db NPC_CHRIS
	dw Script_BeatChrisInRockClubLobby
	dw Script_LostToChrisInRockClubLobby

	db NPC_MATTHEW
	db NPC_MATTHEW
	dw Script_BeatMatthew
	dw Script_LostToMatthew
	db $00

Preload_ChrisInRockClubLobby: ; dee9 (3:5ee9)
	INCROM $dee9, $def2

Script_Chris: ; def2 (3:5ef2)
	INCROM $def2, $df0c

Script_BeatChrisInRockClubLobby: ; df0c (3:5f0c)
	INCROM $df0c, $df20

Script_LostToChrisInRockClubLobby: ; df20 (3:5f20)
	INCROM $df20, $df39

Script_Matthew: ; df39 (3:5f39)
	INCROM $df39, $df63

Script_BeatMatthew: ; df63 (3:5f63)
	INCROM $df63, $df78

Script_LostToMatthew: ; df78 (3:5f78)
	INCROM $df78, $df83

Script_Woman1: ; df83 (3:5f83)
	INCROM $df83, $dfc0

Script_Chap1: ; dfc0 (3:5fc0)
	INCROM $dfc0, $dfcb

Preload_Lass3: ; dfcb (3:5fcb)
	INCROM $dfcb, $dfd2

Script_Lass3: ; dfd2 (3:5fd2)
	INCROM $dfd2, $dfd6

RockClubAfterDuel: ; dfd6 (3:5fd6)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_RYAN
	db NPC_RYAN
	dw Script_BeatRyan
	dw Script_LostToRyan

	db NPC_ANDREW
	db NPC_ANDREW
	dw Script_BeatAndrew
	dw Script_LostToAndrew

	db NPC_GENE
	db NPC_GENE
	dw Script_BeatGene
	dw Script_LostToGene
	db $00

Script_Ryan: ; dff0 (3:5ff0)
	INCROM $dff0, $e007

Script_BeatRyan: ; e007 (3:6007)
	INCROM $e007, $e013

Script_LostToRyan: ; e013 (3:6013)
	INCROM $e013, $e017

Script_Andrew: ; e017 (3:6017)
	INCROM $e017, $e02e

Script_BeatAndrew: ; e02e (3:602e)
	INCROM $e02e, $e03a

Script_LostToAndrew: ; e03a (3:603a)
	INCROM $e03a, $e03e

Script_Gene: ; e03e (3:603e)
	INCROM $e03e, $e059

Script_BeatGene: ; e059 (3:6059)
	INCROM $e059, $e073

Script_LostToGene: ; e073 (3:6073)
	INCROM $e073, $e09e

Script_Clerk3: ; e09e (3:609e)
	INCROM $e09e, $e0a2

WaterClubLobbyAfterDuel: ; e0a2 (3:60a2)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_IMAKUNI
	db NPC_IMAKUNI
	dw Script_BeatImakuni
	dw Script_LostToImakuni
	db $00

Preload_ImakuniInWaterClubLobby: ; e0b0 (3:60b0)
	get_flag_value EVENT_IMAKUNI_STATE
	cp IMAKUNI_TALKED
	jr c, .asm_e0c6
	get_flag_value EVENT_TEMP_BATTLED_IMAKUNI
	jr nz, .asm_e0c6
	get_flag_value EVENT_IMAKUNI_ROOM
	cp IMAKUNI_WATER_CLUB
	jr z, .asm_e0c8
.asm_e0c6
	or a
	ret
.asm_e0c8
	ld a, $10
	ld [wd111], a
	scf
	ret

Script_Gal1: ; e0cf (3:60cf)
	start_script
	jump_if_flag_equal EVENT_FLAG_12, $02, .ows_e10e
	jump_if_flag_equal EVENT_FLAG_12, $00, NULL
	print_variable_text Gal1WantToTrade1Text, Gal1WantToTrade2Text
	script_set_flag_value EVENT_FLAG_12, $01
	ask_question_jump Gal1WouldYouLikeToTradeText, .ows_e0eb
	print_text_string Gal1DeclinedTradeText
	quit_script_fully

.ows_e0eb
	jump_if_card_owned LAPRAS, .ows_e0f3
	print_text_string Gal1DontOwnCardText
	quit_script_fully

.ows_e0f3
	jump_if_card_in_collection LAPRAS, .ows_e0fb
	print_text_string Gal1CardInDeckText
	quit_script_fully

.ows_e0fb
	script_set_flag_value EVENT_FLAG_12, $02
	print_text_string Gal1LetsTradeText
	run_command Func_ccdc
	tx Gal1TradeCompleteText
	take_card LAPRAS
	give_card ARCANINE1
	show_card_received_screen ARCANINE1
	print_text_string Gal1ThanksText
	quit_script_fully

.ows_e10e
	print_text_quit_fully Gal1AfterTradeText

Script_Lass1: ; e111 (3:6111)
	start_script
	jump_if_flag_equal EVENT_FLAG_14, $01, .ows_e121
	print_text_string Text0427
	script_set_flag_value EVENT_FLAG_14, $01
	script_set_flag_value EVENT_IMAKUNI_STATE, IMAKUNI_MENTIONED
	quit_script_fully

.ows_e121
	jump_if_flag_not_equal EVENT_IMAKUNI_ROOM, IMAKUNI_WATER_CLUB, .ows_e12d
	jump_if_flag_nonzero_2 EVENT_TEMP_BATTLED_IMAKUNI, .ows_e12d
	print_text_quit_fully Text0428

.ows_e12d
	print_text_quit_fully Text0429

Preload_Man2: ; e130 (3:6130)
	get_flag_value EVENT_JOSHUA_STATE
	cp JOSHUA_BEATEN
	ret

Script_Man2: ; e137 (3:6137)
	start_script
	print_text_quit_fully Text042a

Script_Pappy2: ; e13b (3:613b)
	start_script
	print_text_quit_fully Text042b

WaterClubMovePlayer: ; e13f (3:613f)
	ld a, [wPlayerYCoord]
	cp $8
	ret nz
	get_flag_value EVENT_JOSHUA_STATE
	cp $2
	ret nc
	ld a, NPC_JOSHUA
	ld [wTempNPC], a
	ld bc, Script_NotReadyToSeeAmy
	jp SetNextNPCAndScript

WaterClubAfterDuel: ; e157 (3:6157)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_SARA
	db NPC_SARA
	dw Script_BeatSara
	dw Script_LostToSara

	db NPC_AMANDA
	db NPC_AMANDA
	dw Script_BeatAmanda
	dw Script_LostToAmanda

	db NPC_JOSHUA
	db NPC_JOSHUA
	dw Script_BeatJoshua
	dw Script_LostToJoshua

	db NPC_AMY
	db NPC_AMY
	dw Script_BeatAmy
	dw Script_LostToAmy
	db $00

Script_Sara: ; e177 (3:6177)
	start_script
	print_text_string Text042c
	ask_question_jump Text042d, .yes_duel
	print_text_string Text042e
	quit_script_fully
.yes_duel
	print_text_string Text042f
	start_battle PRIZES_2, WATERFRONT_POKEMON_DECK_ID, MUSIC_DUEL_THEME_1
	quit_script_fully

Script_BeatSara: ; e18c (3:618c)
	start_script
	max_out_flag_value EVENT_BEAT_SARA
	print_text_string Text0430
	give_booster_packs BOOSTER_COLOSSEUM_WATER, BOOSTER_COLOSSEUM_WATER, NO_BOOSTER
	print_text_string Text0431
	quit_script_fully

Script_LostToSara: ; e19a (03:619a)
	start_script
	print_text_quit_fully Text0432

Script_Amanda: ; e19e (03:619e)
	start_script
	print_text_string Text0433
	ask_question_jump Text0434, .yes_duel
	print_text_string Text0435
	quit_script_fully
.yes_duel
	print_text_string Text0436
	start_battle PRIZES_3, LONELY_FRIENDS_DECK_ID, MUSIC_DUEL_THEME_1
	quit_script_fully

Script_BeatAmanda: ; e1b3 (03:61b3)
	start_script
	max_out_flag_value EVENT_BEAT_AMANDA
	print_text_string Text0437
	give_booster_packs BOOSTER_MYSTERY_LIGHTNING_COLORLESS, BOOSTER_MYSTERY_LIGHTNING_COLORLESS, NO_BOOSTER
	print_text_string Text0438
	quit_script_fully

Script_LostToAmanda: ; e1c1 (03:61c1)
	start_script
	print_text_quit_fully Text0439

Script_NotReadyToSeeAmy: ; e1c5 (03:61c5)
	start_script
	jump_if_player_coords_match $12, $08, .ows_e1ec
	jump_if_player_coords_match $14, $08, .ows_e1f2
	jump_if_player_coords_match $18, $08, .ows_e1f8
.ows_e1d5
	move_player SOUTH, 4
	move_active_npc NPCMovement_e213
	print_text_string Text043a
	jump_if_player_coords_match $12, $0a, .ows_e1fe
	jump_if_player_coords_match $14, $0a, .ows_e202
	move_active_npc NPCMovement_e215
	quit_script_fully

.ows_e1ec
	move_active_npc NPCMovement_e206
	script_jump .ows_e1d5
.ows_e1f2
	move_active_npc NPCMovement_e20b
	script_jump .ows_e1d5
.ows_e1f8
	move_active_npc NPCMovement_e20f
	script_jump .ows_e1d5
.ows_e1fe
	move_active_npc NPCMovement_e218
	quit_script_fully

.ows_e202
	move_active_npc NPCMovement_e219
	quit_script_fully

NPCMovement_e206: ; e206 (3:6206)
	db NORTH
	db WEST
	db WEST
	db SOUTH | NO_MOVE
	db $ff

NPCMovement_e20b: ; e20b (3:620b)
	db NORTH
	db WEST
	db SOUTH | NO_MOVE
	db $ff

NPCMovement_e20f: ; e20f (3:620f)
	db NORTH
	db EAST
	db SOUTH | NO_MOVE
	db $ff

NPCMovement_e213: ; e213 (3:6213)
	db SOUTH
	db $ff

NPCMovement_e215: ; e215 (3:6215)
	db WEST
	db SOUTH | NO_MOVE
	db $ff

NPCMovement_e218: ; e218 (3:6218)
	db EAST
;	fallthrough

NPCMovement_e219: ; e219 (3:6219)
	db EAST
	db SOUTH | NO_MOVE
	db $ff

Script_Joshua: ; e21c (3:621c)
	start_script
	jump_if_flag_zero_2 EVENT_BEAT_AMANDA, .sara_and_amanda_not_beaten
	jump_if_flag_zero_2 EVENT_BEAT_SARA, .sara_and_amanda_not_beaten
	script_jump .beat_sara_and_amanda
.sara_and_amanda_not_beaten
	script_set_flag_value EVENT_JOSHUA_STATE, JOSHUA_TALKED
	print_text_string Text043b
	quit_script_fully

.beat_sara_and_amanda
	jump_if_flag_nonzero_1 EVENT_JOSHUA_STATE, .already_talked
	script_set_flag_value EVENT_JOSHUA_STATE, JOSHUA_TALKED
	print_text_string Text043b
	print_text_string Text043c
.already_talked
	jump_if_flag_equal EVENT_JOSHUA_STATE, JOSHUA_TALKED, NULL
	print_variable_text Text043d, Text043e
	ask_question_jump Text043f, .startDuel
	jump_if_flag_equal EVENT_JOSHUA_STATE, JOSHUA_TALKED, NULL
	print_variable_text Text0440, Text0441
	quit_script_fully

.startDuel
	print_text_string Text0442
	try_give_pc_pack $04
	start_battle PRIZES_4, SOUND_OF_THE_WAVES_DECK_ID, MUSIC_DUEL_THEME_1
	quit_script_fully

Script_LostToJoshua: ; e260 (3:6260)
	start_script
	jump_if_flag_equal EVENT_JOSHUA_STATE, JOSHUA_TALKED, NULL
	print_variable_text Text0443, Text0444
	quit_script_fully

Script_BeatJoshua: ; e26c (3:626c)
	start_script
	jump_if_flag_equal EVENT_JOSHUA_STATE, JOSHUA_TALKED, NULL
	print_variable_text Text0445, Text0446
	give_booster_packs BOOSTER_MYSTERY_WATER_COLORLESS, BOOSTER_MYSTERY_WATER_COLORLESS, NO_BOOSTER
	jump_if_flag_equal EVENT_JOSHUA_STATE, JOSHUA_TALKED, NULL
	print_variable_text Text0447, Text0448
	jump_if_flag_not_equal EVENT_JOSHUA_STATE, JOSHUA_BEATEN, .firstJoshuaWin
	quit_script_fully

.firstJoshuaWin
	script_set_flag_value EVENT_JOSHUA_STATE, JOSHUA_BEATEN
	print_text_string Text0449
	close_text_box
	move_active_npc_by_direction NPCMovementTable_e2a1
	print_text_string Text044a
	run_command Func_cfc6
	db $00
	close_advanced_text_box
	set_next_npc_and_script NPC_AMY, Script_MeetAmy
	end_script_loop
	ret

NPCMovementTable_e2a1: ; e2a1 (3:62a1)
	dw NPCMovement_e2a9
	dw NPCMovement_e2a9
	dw NPCMovement_e2a9
	dw NPCMovement_e2a9

NPCMovement_e2a9: ; e2a9 (3:62a9)
	db NORTH
	db $ff

NPCMovement_e2ab: ; e2ab (3:62ab)
	db SOUTH
	db $ff

Preload_Amy: ; e2ad (3:62ad)
	xor a
	ld [wd3d0], a
	ld a, [wd0c2]
	or a
	jr z, .asm_e2cf
	ld a, [wPlayerXCoord]
	cp $14
	jr nz, .asm_e2cf
	ld a, [wPlayerYCoord]
	cp $06
	jr nz, .asm_e2cf
	ld a, $14
	ld [wLoadNPCXPos], a
	ld a, $01
	ld [wd3d0], a
.asm_e2cf
	scf
	ret

Script_MeetAmy: ; e2d1 (3:62d1)
	start_script
	print_text_string Text044b
	set_dialog_npc NPC_JOSHUA
	print_text_string Text044c
	set_dialog_npc NPC_AMY
	print_text_string Text044d
	close_text_box
	run_command Func_d095
	db $09
	db $2f
	db $10
	do_frames $20
	run_command Func_d095
	db $04
	db $0e
	db $00
	run_command Func_d0be
	db $14
	db $04
	set_player_direction WEST
	move_player WEST, 1
	set_player_direction NORTH
	move_player NORTH, 1
	move_player NORTH, 1
	move_arbitrary_npc NPC_JOSHUA, NPCMovement_e2ab
	print_text_string Text044e
	script_jump Script_Amy.askConfirmDuel

Script_Amy: ; e304 (3:6304)
	start_script
	jump_if_flag_nonzero_2 EVENT_BEAT_AMY, ScriptJump_TalkToAmyAgain
	print_text_string Text044f
.askConfirmDuel
	ask_question_jump Text0450, .startDuel

.denyDuel
	print_text_string Text0451
	run_command Func_d0d9
	db $14
	db $04
	dw Script_LostToAmy.ows_e34e
	quit_script_fully

.startDuel
	print_text_string Text0452
	start_battle PRIZES_6, GO_GO_RAIN_DANCE_DECK_ID, MUSIC_DUEL_THEME_2
	quit_script_fully

Script_BeatAmy: ; e322 (3:6322)
	start_script
	print_text_string Text0453
	jump_if_flag_nonzero_2 EVENT_BEAT_AMY, .beatAmyCommon
	print_text_string Text0454
	max_out_flag_value EVENT_BEAT_AMY
	try_give_medal_pc_packs
	run_command Func_d125
	db EVENT_BEAT_AMY
	run_command Func_d435
	db $03
	print_text_string Text0455
.beatAmyCommon
	give_booster_packs BOOSTER_LABORATORY_WATER, BOOSTER_LABORATORY_WATER, NO_BOOSTER
	print_text_string Text0456
	run_command Func_d0d9
	db $14
	db $04
	dw Script_LostToAmy.ows_e34e
	quit_script_fully

Script_LostToAmy: ; e344 (3:6344)
	start_script
	print_text_string Text0457
	run_command Func_d0d9
	db $14
	db $04
	dw .ows_e34e
	quit_script_fully

.ows_e34e
	run_command Func_d095
	db $08
	db $2e
	db $10
	run_command Func_d0be
	db $16
	db $04
	quit_script_fully

ScriptJump_TalkToAmyAgain: ; e356 (3:6356)
	print_text_string Text0458
	ask_question_jump Text0450, .startDuel
	script_jump Script_Amy.denyDuel

.startDuel
	print_text_string Text0459
	start_battle PRIZES_6, GO_GO_RAIN_DANCE_DECK_ID, MUSIC_DUEL_THEME_2
	quit_script_fully

Script_Clerk4: ; e369 (3:6369)
	INCROM $e369, $e36d

LightningClubLobbyAfterDuel: ; e36d (3:636d)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_IMAKUNI
	db NPC_IMAKUNI
	dw Script_BeatImakuni
	dw Script_LostToImakuni
	db $00

Preload_ImakuniInLightningClubLobby: ; e37b (3:637b)
	INCROM $e37b, $e39a

Script_Chap2: ; e39a (3:639a)
	INCROM $e39a, $e3d9

Script_Lass4: ; e3d9 (3:63d9)
	INCROM $e3d9, $e3dd

Script_Hood1: ; e3dd (3:63dd)
	INCROM $e3dd, $e3e8

LightningClubAfterDuel: ; e3e8 (3:63e8)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_JENNIFER
	db NPC_JENNIFER
	dw Script_BeatJennifer
	dw Script_LostToJennifer

	db NPC_NICHOLAS
	db NPC_NICHOLAS
	dw Script_BeatNicholas
	dw Script_LostToNicholas

	db NPC_BRANDON
	db NPC_BRANDON
	dw Script_BeatBrandon
	dw Script_LostToBrandon

	db NPC_ISAAC
	db NPC_ISAAC
	dw Script_BeatIsaac
	dw Script_LostToIsaac
	db $00

Script_Jennifer: ; e408 (3:6408)
	INCROM $e408, $e41d

Script_BeatJennifer: ; e41d (3:641d)
	INCROM $e41d, $e42b

Script_LostToJennifer: ; e42b (3:642b)
	INCROM $e42b, $e42f

Script_Nicholas: ; e42f (3:642f)
	INCROM $e42f, $e444

Script_BeatNicholas: ; e444 (3:6444)
	INCROM $e444, $e452

Script_LostToNicholas: ; e452 (3:6452)
	INCROM $e452, $e456

Script_Brandon: ; e456 (3:6456)
	INCROM $e456, $e480

Script_BeatBrandon: ; e480 (3:6480)
	INCROM $e480, $e490

Script_LostToBrandon: ; e490 (3:6490)
	INCROM $e490, $e494

Preload_Isaac: ; e494 (3:6494)
	INCROM $e494, $e4ad

Script_Isaac: ; e4ad (3:64ad)
	INCROM $e4ad, $e4e1

Script_BeatIsaac: ; e4e1 (3:64e1)
	INCROM $e4e1, $e4fb

Script_LostToIsaac: ; e4fb (3:64fb)
	INCROM $e4fb, $e525

GrassClubEntranceAfterDuel: ; e525 (3:6525)
	ld hl, GrassClubEntranceAfterDuelTable
	call FindEndOfBattleScript
	ret

FindEndOfBattleScript: ; e52c (3:652c)
	ld c, $0
	ld a, [wDuelResult]
	or a ; cp DUEL_WIN
	jr z, .player_won
	ld c, $2

.player_won
	ld a, [wd0c4]
	ld b, a
	ld de, $0005
.check_enemy_byte_loop
	ld a, [hli]
	or a
	ret z
	cp b
	jr z, .found_enemy
	add hl, de
	jr .check_enemy_byte_loop

.found_enemy
	ld a, [hli]
	ld [wTempNPC], a
	ld b, $0
	add hl, bc
	ld c, [hl]
	inc hl
	ld b, [hl]
	jp SetNextNPCAndScript

GrassClubEntranceAfterDuelTable: ; e553 (3:6553)
	db NPC_MICHAEL
	db NPC_MICHAEL
	dw Script_BeatMichaelInGrassClubEntrance
	dw Script_LostToMichaelInGrassClubEntrance

	db NPC_RONALD2
	db NPC_RONALD2
	dw Script_BeatFirstRonaldFight
	dw Script_LostToFirstRonaldFight

	db NPC_RONALD3
	db NPC_RONALD3
	dw Script_BeatSecondRonaldFight
	dw Script_LostToSecondRonaldFight
	db $00

Script_Clerk5: ; e566 (3:6566)
	INCROM $e566, $e56a

Preload_MichaelInGrassClubEntrance: ; e56a (3:656a)
	INCROM $e56a, $e573

Script_Michael: ; e573 (3:6573)
	INCROM $e573, $e597

Script_BeatMichaelInGrassClubEntrance: ; e597 (3:6597)
	INCROM $e597, $e5ab

Script_LostToMichaelInGrassClubEntrance: ; e5ab (3:65ab)
	INCROM $e5ab, $e5c4

GrassClubLobbyAfterDuel: ; e5c4 (3:65c4)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_BRITTANY
	db NPC_BRITTANY
	dw Script_BeatBrittany
	dw Script_LostToBrittany
	db $00

Script_Brittany: ; e5d2 (3:65d2)
	start_script
	jump_if_flag_less_than EVENT_FLAG_35, $01, NULL
	print_variable_text Text06e0, Text06e1
	ask_question_jump Text06e2, .wantToDuel
	print_text_string Text06e3
	quit_script_fully

.wantToDuel
	print_text_string Text06e4
	start_battle PRIZES_4, ETCETERA_DECK_ID, MUSIC_DUEL_THEME_1
	quit_script_fully

Script_BeatBrittany: ; e5ee (3:65ee)
	start_script
	print_text_string Text06e5
	give_booster_packs BOOSTER_MYSTERY_GRASS_COLORLESS, BOOSTER_MYSTERY_GRASS_COLORLESS, NO_BOOSTER
	jump_if_flag_less_than EVENT_FLAG_35, $02, NULL
	print_variable_text Text06e6, Text06e7
	max_out_flag_value FLAG_BEAT_BRITTANY
	jump_if_flag_not_less_than EVENT_FLAG_35, $02, .finishScript
	jump_if_flag_zero_2 EVENT_FLAG_3A, .finishScript
	jump_if_flag_zero_2 EVENT_FLAG_3B, .finishScript
	script_set_flag_value EVENT_FLAG_35, $01
	max_out_flag_value EVENT_FLAG_1E
	print_text_string Text06e8
.finishScript
	quit_script_fully

Script_LostToBrittany: ; e618 (3:6618)
	start_script
	print_text_quit_fully Text06e9

Script_e61c: ; e61c (3:661c)
	print_text_quit_fully Text06ea

Script_Lass2: ; e61f (3:661f)
	start_script
	jump_if_flag_nonzero_2 EVENT_FLAG_04, Script_e61c
	jump_if_flag_not_less_than EVENT_FLAG_37, $06, Script_e61c
	jump_if_flag_not_less_than EVENT_FLAG_37, $04, .ows_e6a1
	jump_if_flag_not_less_than EVENT_FLAG_37, $02, .ows_e66a
	jump_if_flag_equal EVENT_FLAG_37, $00, NULL
	print_variable_text Text06eb, Text06ec
	script_set_flag_value EVENT_FLAG_37, $01
	ask_question_jump Text06ed, .ows_e648
	print_text_quit_fully Text06ee

.ows_e648
	jump_if_card_owned $1c, .ows_e64f
	print_text_quit_fully Text06ef

.ows_e64f
	jump_if_card_in_collection $1c, .ows_e656
	print_text_quit_fully Text06f0

.ows_e656
	max_out_flag_value EVENT_FLAG_04
	script_set_flag_value EVENT_FLAG_37, $02
	print_text_string Text06f1
	run_command Func_ccdc
	tx Text06f2
	take_card ODDISH
	give_card VILEPLUME
	show_card_received_screen VILEPLUME
	print_text_quit_fully Text06f3

.ows_e66a
	jump_if_flag_equal EVENT_FLAG_37, $02, NULL
	print_variable_text Text06f4, Text06f5
	script_set_flag_value EVENT_FLAG_37, $03
	ask_question_jump Text06ed, .ows_e67f
	print_text_quit_fully Text06f6

.ows_e67f
	jump_if_card_owned $ab, .ows_e686
	print_text_quit_fully Text06f7

.ows_e686
	jump_if_card_in_collection $ab, .ows_e68d
	print_text_quit_fully Text06f8

.ows_e68d
	max_out_flag_value EVENT_FLAG_04
	script_set_flag_value EVENT_FLAG_37, $04
	print_text_string Text06f9
	run_command Func_ccdc
	tx Text06fa
	take_card CLEFAIRY
	give_card PIKACHU3
	show_card_received_screen PIKACHU3
	print_text_quit_fully Text06f3

.ows_e6a1
	jump_if_flag_equal EVENT_FLAG_37, $04, NULL
	print_variable_text Text06fb, Text06fc
	script_set_flag_value EVENT_FLAG_37, $05
	ask_question_jump Text06ed, .ows_e6b6
	print_text_quit_fully Text06fd

.ows_e6b6
	jump_if_card_owned CHARIZARD, .ows_e6bd
	print_text_quit_fully Text06fe

.ows_e6bd
	jump_if_card_in_collection CHARIZARD, .ows_e6c4
	print_text_quit_fully Text06ff

.ows_e6c4
	max_out_flag_value EVENT_FLAG_04
	script_set_flag_value EVENT_FLAG_37, $06
	print_text_string Text0700
	run_command Func_ccdc
	tx Text0701
	take_card CHARIZARD
	give_card BLASTOISE
	show_card_received_screen BLASTOISE
	print_text_quit_fully Text06f3

Script_Granny2: ; e6d8 (3:66d8)
	INCROM $e6d8, $e6dc

Preload_Gal2: ; e6dc (3:66dc)
	INCROM $e6dc, $e6e3

Script_Gal2: ; e6e3 (3:66e3)
	INCROM $e6e3, $e6e7

GrassClubAfterDuel: ; e6e7 (3:66e7)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_KRISTIN
	db NPC_KRISTIN
	dw Script_BeatKristin
	dw Script_LostToKristin

	db NPC_HEATHER
	db NPC_HEATHER
	dw Script_BeatHeather
	dw Script_LostToHeather

	db NPC_NIKKI
	db NPC_NIKKI
	dw Script_BeatNikki
	dw Script_LostToNikki
	db $00

Script_Kristin: ; e701 (3:6701)
	INCROM $e701, $e71c

Script_BeatKristin: ; e71c (3:671c)
	INCROM $e71c, $e741

Script_LostToKristin: ; e741 (3:6741)
	INCROM $e741, $e745

Script_Heather: ; e745 (3:6745)
	INCROM $e745, $e760

Script_BeatHeather: ; e760 (3:6760)
	INCROM $e760, $e78a

Script_LostToHeather: ; e78a (3:678a)
	INCROM $e78a, $e796

Preload_NikkiInGrassClub: ; e796 (3:6796)
	INCROM $e796, $e79e

Script_Nikki: ; e79e (3:679e)
	INCROM $e79e, $e7d3

Script_BeatNikki: ; e7d3 (3:67d3)
	INCROM $e7d3, $e7f2

Script_LostToNikki: ; e7f2 (3:67f2)
	INCROM $e7f2, $e7f6

ClubEntranceAfterDuel: ; e7f6 (3:67f6)
	ld hl, .after_duel_table
	jp FindEndOfBattleScript

.after_duel_table
	db NPC_RONALD2
	db NPC_RONALD2
	dw Script_BeatFirstRonaldFight
	dw Script_LostToFirstRonaldFight

	db NPC_RONALD3
	db NPC_RONALD3
	dw Script_BeatSecondRonaldFight
	dw Script_LostToSecondRonaldFight
	db $00

; A Ronald is already loaded or not loaded depending on Pre-Load scripts
; in data/npc_map_data.asm. This just starts a script if possible.
LoadClubEntrance: ; e809 (3:6809)
	call TryFirstRonaldFight
	call TrySecondRonaldFight
	call TryFirstRonaldEncounter
	ret

TryFirstRonaldEncounter: ; e813 (3:6813)
	ld a, NPC_RONALD1
	ld [wTempNPC], a
	call FindLoadedNPC
	ret c
	ld bc, Script_FirstRonaldEncounter
	jp SetNextNPCAndScript

TryFirstRonaldFight: ; e822 (3:6822)
	ld a, NPC_RONALD2
	ld [wTempNPC], a
	call FindLoadedNPC
	ret c
	get_flag_value EVENT_FLAG_4C
	or a
	ret nz
	ld bc, Script_FirstRonaldFight
	jp SetNextNPCAndScript

TrySecondRonaldFight: ; e837 (3:6837)
	ld a, NPC_RONALD3
	ld [wTempNPC], a
	call FindLoadedNPC
	ret c
	get_flag_value EVENT_FLAG_4D
	or a
	ret nz
	ld bc, ScriptSecondRonaldFight
	jp SetNextNPCAndScript

Script_Clerk6: ; e84c (3:684c)
	INCROM $e84c, $e850

Script_Lad3: ; e850 (3:6850)
	INCROM $e850, $e85b

Preload_Ronald1InClubEntrance: ; e85b (3:685b)
	INCROM $e85b, $e862

Script_FirstRonaldEncounter: ; e862 (3:6862)
	start_script
	max_out_flag_value EVENT_FLAG_4B
	move_active_npc NPCMovement_e894
	run_command Func_d135
	db $00
	print_text_string Text0645
	close_text_box
	move_player NORTH, 1
	move_player NORTH, 1
	print_text_string Text0646
	ask_question_jump_default_yes NULL, .ows_e882
	print_text_string Text0647
	script_jump .ows_e885

.ows_e882
	print_text_string Text0648
.ows_e885
	print_text_string Text0649
	close_text_box
	set_player_direction WEST
	move_player EAST, 4
	move_active_npc NPCMovement_e894
	run_command Func_cdcb
	run_command Func_d41d
	quit_script_fully

NPCMovement_e894: ; e894 (3:6894)
	db SOUTH
	db SOUTH
	db SOUTH
	db SOUTH
	db SOUTH
	db $ff

Preload_Ronald2InClubEntrance: ; e89a (3:689a)
	INCROM $e89a, $e8c0

Script_FirstRonaldFight: ; e8c0 (3:68c0)
	start_script
	move_active_npc NPCMovement_e905
	do_frames $3c
	move_active_npc NPCMovement_e90d
	print_text_string Text064a
	jump_if_player_coords_match $08, $02, .ows_e8d6
	set_player_direction WEST
	move_player WEST, 1
.ows_e8d6
	set_player_direction SOUTH
	move_player SOUTH, 1
	move_player SOUTH, 1
	print_text_string Text064b
	script_set_flag_value $4c, $01
	start_battle PRIZES_6, IM_RONALD_DECK_ID, MUSIC_RONALD
	quit_script_fully

Script_BeatFirstRonaldFight: ; e8e9 (3:68e9)
	start_script
	print_text_string Text064c
	give_card JIGGLYPUFF1
	show_card_received_screen JIGGLYPUFF1
	print_text_string Text064d
	script_jump ScriptJump_FinishedFirstRonaldFight

Script_LostToFirstRonaldFight: ; e8f7 (3:68f7)
	start_script
	print_text_string Text064e

ScriptJump_FinishedFirstRonaldFight:
	script_set_flag_value EVENT_FLAG_4C, $02
	close_text_box
	move_active_npc NPCMovement_e90f
	run_command Func_cdcb
	run_command Func_d41d
	quit_script_fully

NPCMovement_e905: ; e905 (3:6905)
	db EAST
	db EAST
	db EAST
	db EAST
	db EAST
	db SOUTH
	db NORTH | NO_MOVE
	db $ff

NPCMovement_e90d: ; e90d (3:690d)
	db NORTH
	db $ff

NPCMovement_e90f: ; e90f (3:690f)
	db SOUTH
	db SOUTH
	db SOUTH
	db SOUTH
	db SOUTH
	db $ff

Preload_Ronald3InClubEntrance: ; e915 (3:6915)
	INCROM $e915, $e91e

ScriptSecondRonaldFight: ; e91e (3:691e)
	start_script
	move_active_npc NPCMovement_e905
	do_frames 60
	move_active_npc NPCMovement_e90d
	print_text_string Text064f
	jump_if_player_coords_match $08, $02, .ows_6934
	set_player_direction WEST
	move_player WEST, 1
.ows_6934
	set_player_direction SOUTH
	move_player SOUTH, 1
	move_player SOUTH, 1
	print_text_string Text0650
	script_set_flag_value EVENT_FLAG_4D, $01
	start_battle PRIZES_6, POWERFUL_RONALD_DECK_ID, MUSIC_RONALD
	quit_script_fully

Script_BeatSecondRonaldFight: ; e947 (3:6947)
	start_script
	print_text_string Text0651
	give_card SUPER_ENERGY_RETRIEVAL
	show_card_received_screen SUPER_ENERGY_RETRIEVAL
	print_text_string Text0652
	script_jump ScriptJump_FinishedSecondRonaldFight

Script_LostToSecondRonaldFight: ; e955 (3:6955)
	start_script
	print_text_string Text0653

ScriptJump_FinishedSecondRonaldFight: ; e959 (3:6959)
	script_set_flag_value EVENT_FLAG_4D, $02
	close_text_box
	move_active_npc NPCMovement_e90f
	run_command Func_cdcb
	run_command Func_d41d
	quit_script_fully

PsychicClubLobbyAfterDuel: ; e963 (3:6963)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_ROBERT
	db NPC_ROBERT
	dw Script_BeatRobert
	dw Script_LostToRobert
	db $00

PsychicClubLobbyLoadMap: ; e971 (3:6971)
	INCROM $e971, $e980

Script_Robert: ; e980 (3:6980)
	INCROM $e980, $e995

Script_BeatRobert: ; e995 (3:6995)
	INCROM $e995, $e9a1

Script_LostToRobert: ; e9a1 (3:69a1)
	INCROM $e9a1, $e9a5

Script_Pappy1: ; e9a5 (3:69a5)
	INCROM $e9a5, $e9f7

Preload_Ronald1InPsychicClubLobby: ; e9f7 (3:69f7)
	INCROM $e9f7, $ea30

Script_Gal3: ; ea30 (3:6a30)
	INCROM $ea30, $ea3b

Script_Chap4: ; ea3b (3:6a3b)
	INCROM $ea3b, $ea46

PsychicClubAfterDuel: ; ea46 (3:6a46)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_DANIEL
	db NPC_DANIEL
	dw Script_BeatDaniel
	dw Script_LostToDaniel

	db NPC_STEPHANIE
	db NPC_STEPHANIE
	dw Script_BeatStephanie
	dw Script_LostToStephanie

	db NPC_MURRAY1
	db NPC_MURRAY1
	dw Script_BeatMurray
	dw Script_LostToMurray
	db $00

Script_Daniel: ; ea60 (3:6a60)
	INCROM $ea60, $ea92

Script_BeatDaniel: ; ea92 (3:6a92)
	INCROM $ea92, $ea9e

Script_LostToDaniel: ; ea9e (3:6a9e)
	INCROM $ea9e, $eaa2

Script_Stephanie: ; eaa2 (3:6aa2)
	INCROM $eaa2, $eac0

Script_BeatStephanie: ; eac0 (3:6ac0)
	INCROM $eac0, $eacc

Script_LostToStephanie: ; eacc (3:6acc)
	INCROM $eacc, $ead0

Preload_Murray2: ; ead0 (3:6ad0)
	INCROM $ead0, $eada

Preload_Murray1: ; eada (3:6ada)
	INCROM $eada, $eadf

Script_Murray: ; eadf (3:6adf)
	INCROM $eadf, $eb0f

Script_BeatMurray: ; eb0f (3:6b0f)
	INCROM $eb0f, $eb29

Script_LostToMurray: ; eb29 (3:6b29)
	INCROM $eb29, $eb53

Script_Clerk7: ; eb53 (3:6b53)
	INCROM $eb53, $eb57

ScienceClubLobbyAfterDuel:; eb57 (3:6b57)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_IMAKUNI
	db NPC_IMAKUNI
	dw Script_BeatImakuni
	dw Script_LostToImakuni
	db $00

Preload_ImakuniInScienceClubLobby: ; eb65 (3:6b65)
	INCROM $eb65, $eb84

Script_Lad1: ; eb84 (3:6b84)
	INCROM $eb84, $ebc1

Script_Man3: ; ebc1 (3:6bc1)
	INCROM $ebc1, $ebc5

Script_Specs2: ; ebc5 (3:6bc5)
	INCROM $ebc5, $ebed

Script_Specs3: ; ebed (3:6bed)
	INCROM $ebed, $ebf1

ScienceClubAfterDuel: ; ebf1 (3:6bf1)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_JOSEPH
	db NPC_JOSEPH
	dw Script_BeatJoseph
	dw Script_LostToJoseph

	db NPC_DAVID
	db NPC_DAVID
	dw Script_BeatDavid
	dw Script_LostToDavid

	db NPC_ERIK
	db NPC_ERIK
	dw Script_BeatErik
	dw Script_LostToErik

	db NPC_RICK
	db NPC_RICK
	dw Script_BeatRick
	dw Script_LostToRick
	db $00

Script_David: ; ec11 (3:6c11)
	INCROM $ec11, $ec2f

Script_BeatDavid: ; ec2f (3:6c2f)
	INCROM $ec2f, $ec3e

Script_LostToDavid: ; ec3e (3:6c3e)
	INCROM $ec3e, $ec42

Script_Erik: ; ec42 (3:6c42)
	INCROM $ec42, $ec57

Script_BeatErik: ; ec57 (3:6c57)
	INCROM $ec57, $ec63

Script_LostToErik: ; ec63 (3:6c63)
	INCROM $ec63, $ec67

Script_Rick: ; ec67 (3:6c67)
	INCROM $ec67, $ec80

Script_BeatRick: ; ec80 (3:6c80)
	INCROM $ec80, $ec9a

Script_LostToRick: ; ec9a (3:6c9a)
	INCROM $ec9a, $ecc4

Preload_Joseph: ; ecc4 (3:6cc4)
	INCROM $ecc4, $ecdb

Script_Joseph: ; ecdb (3:6cdb)
	INCROM $ecdb, $ecf6

Script_BeatJoseph: ; ecf6 (3:6cf6)
	INCROM $ecf6, $ed1c

Script_LostToJoseph: ; ed1c (3:6d1c)
	INCROM $ed1c, $ed45

Script_Clerk8: ; ed45 (3:6d45)
	INCROM $ed45, $ed49

FireClubLobbyAfterDuel: ; ed49 (3:6d49)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_JESSICA
	db NPC_JESSICA
	dw Script_BeatJessicaInFireClubLobby
	dw Script_LostToJessicaInFireClubLobby
	db $00

FireClubPressedA: ; ed57 (3:6d57)
	ld hl, SlowpokePaintingObjectTable
	call FindExtraInteractableObjects
	ret

SlowpokePaintingObjectTable: ; ed5e (3:6d5e)
	db 16, 2, NORTH
	dw Script_ee76
	db $00

; Given a table with data of the form:
;	X, Y, Dir, Script
; Searches to try to find a match, and starts a Script if possible
FindExtraInteractableObjects: ; ed64 (3:6d64)
	ld de, $5
.findObjectMatchLoop
	ld a, [hl]
	or a
	ret z
	push hl
	ld a, [wPlayerXCoord]
	cp [hl]
	jr nz, .didNotMatch
	inc hl
	ld a, [wPlayerYCoord]
	cp [hl]
	jr nz, .didNotMatch
	inc hl
	ld a, [wPlayerDirection]
	cp [hl]
	jr z, .foundObject
.didNotMatch
	pop hl
	add hl, de
	jr .findObjectMatchLoop
.foundObject
	inc hl
	ld c, [hl]
	inc hl
	ld b, [hl]
	pop hl
	call SetNextScript
	scf
	ret

Preload_JessicaInFireClubLobby: ; ed8d (3:6d8d)
	INCROM $ed8d, $ed96

Script_Jessica: ; ed96 (3:6d96)
	INCROM $ed96, $edba

Script_BeatJessicaInFireClubLobby: ; edba (3:6dba)
	INCROM $edba, $edce

Script_LostToJessicaInFireClubLobby: ; edce (3:6dce)
	INCROM $edce, $ede8

Script_Chap3: ; ede8 (3:6de8)
	INCROM $ede8, $ee25

Preload_Lad2: ; ee25 (3:6e25)
	INCROM $ee25, $ee2c

Script_Lad2: ; ee2c (3:6e2c)
	INCROM $ee2c, $ee76

Script_ee76: ; ee76 (3:6e76)
	start_script
	jump_if_flag_equal EVENT_FLAG_21, $01, .ows_ee7d
	quit_script_fully

.ows_ee7d
	script_set_flag_value EVENT_FLAG_21, $02
	run_command Func_ccdc
	tx FoundLv9SlowpokeText
	give_card SLOWPOKE1
	show_card_received_screen SLOWPOKE1
	quit_script_fully

Script_Mania: ; ee88 (3:6e88)
	INCROM $ee88, $ee93

FireClubAfterDuel: ; ee93  (3:6e93)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_JOHN
	db NPC_JOHN
	dw Script_BeatJohn
	dw Script_LostToJohn

	db NPC_ADAM
	db NPC_ADAM
	dw Script_BeatAdam
	dw Script_LostToAdam

	db NPC_JONATHAN
	db NPC_JONATHAN
	dw Script_BeatJonathan
	dw Script_LostToJonathan

	db NPC_KEN
	db NPC_KEN
	dw Script_BeatKen
	dw Script_LostToKen
	db $00

Script_John: ; eeb3 (3:6eb3)
	INCROM $eeb3, $eec8

Script_BeatJohn: ; eec8 (3:6ec8)
	INCROM $eec8, $eed4

Script_LostToJohn: ; eed4 (3:6ed4)
	INCROM $eed4, $eed8

Script_Adam: ; eed8 (3:6ed8)
	INCROM $eed8, $eeed

Script_BeatAdam: ; eeed (3:6eed)
	INCROM $eeed, $eef9

Script_LostToAdam: ; eef9 (3:6ef9)
	INCROM $eef9, $eefd

Script_Jonathan: ; eefd (3:6efd)
	INCROM $eefd, $ef12

Script_BeatJonathan: ; ef12 (3:6f12)
	INCROM $ef12, $ef1e

Script_LostToJonathan: ; ef1e (3:6f1e)
	INCROM $ef1e, $ef22

Script_Ken: ; ef22 (3:6f22)
	start_script
	try_give_pc_pack $09
	jump_if_flag_nonzero_2 EVENT_FLAG_23, .have_300_cards
	jump_if_enough_cards_owned 300, .have_300_cards
	jump_if_flag_zero_1 EVENT_FLAG_24, NULL
	print_variable_text Text06ba, Text06bb
	script_set_flag_value EVENT_FLAG_24, $01
	quit_script_fully
.have_300_cards
	max_out_flag_value EVENT_FLAG_23
	jump_if_flag_nonzero_2 EVENT_FLAG_0A, Script_KenBattle_AlreadyHaveMedal
	jump_if_flag_zero_1 EVENT_FLAG_24, NULL
	print_variable_text Text06bc, Text06bd
	script_set_flag_value EVENT_FLAG_24, $01
	ask_question_jump Text06be, .do_battle
	print_text_string Text06bf
	quit_script_fully
.do_battle
	print_text_string Text06c0
	start_battle PRIZES_6, FIRE_CHARGE_DECK_ID, MUSIC_DUEL_THEME_2
	quit_script_fully

Script_BeatKen: ; ef5e (3:6f5e)
	start_script
	print_text_string Text06c1
	jump_if_flag_nonzero_2 EVENT_FLAG_0A, .give_booster_packs
	max_out_flag_value EVENT_FLAG_0A
	try_give_medal_pc_packs
	run_command Func_d125
	db $0a
	run_command Func_d435
	db $08
	print_text_string Text06c2
.give_booster_packs
	give_booster_packs BOOSTER_MYSTERY_NEUTRAL, BOOSTER_MYSTERY_NEUTRAL, NO_BOOSTER
	print_text_string Text06c3
	quit_script_fully

Script_LostToKen: ; ef78 (3:6f78)
	start_script
	jump_if_flag_zero_2 EVENT_FLAG_0A, NULL
	print_variable_text Text06c4, Text06c5
	quit_script_fully

Script_KenBattle_AlreadyHaveMedal: ; ef83 (3:6f83)
	print_text_string Text06c6
	ask_question_jump Text06be, .do_battle
	print_text_quit_fully Text06bf
.do_battle
	print_text_string Text06c7
	start_battle PRIZES_6, FIRE_CHARGE_DECK_ID, MUSIC_DUEL_THEME_2
	quit_script_fully

Preload_Clerk9: ; ef96 (3:6f96)
	call TryGiveMedalPCPacks
	get_flag_value EVENT_MEDAL_COUNT
	ld hl, .jumpTable
	cp $09
	jp c, JumpToFunctionInTable
	debug_ret
	jr .asm_efe4

.jumpTable
	dw .asm_efe4
	dw .asm_efe4
	dw .asm_efe4
	dw .asm_efba
	dw .asm_efde
	dw .asm_efc9
	dw .asm_efd8
	dw .asm_efd8
	dw .asm_efd8

.asm_efba
	get_flag_value EVENT_FLAG_3F
	or a
	jr nz, .asm_efe4
	ld c, $01
	set_flag_value EVENT_FLAG_3F
	jr .asm_efe4

.asm_efc9
	get_flag_value EVENT_FLAG_40
	or a
	jr nz, .asm_efde
	ld c, $01
	set_flag_value EVENT_FLAG_40
	jr .asm_efde

.asm_efd8
	ld c, $07
	set_flag_value EVENT_FLAG_40
.asm_efde
	ld c, $07
	set_flag_value EVENT_FLAG_3F
.asm_efe4
	zero_flag_value EVENT_FLAG_42
	get_flag_value EVENT_FLAG_3F
	cp $00
	jr z, .asm_eff8
	cp $07
	jr z, .asm_eff8
	ld c, $01
	jr .asm_f016

.asm_eff8
	get_flag_value EVENT_FLAG_40
	cp $00
	jr z, .asm_f008
	cp $07
	jr z, .asm_f008
	ld c, $02
	jr .asm_f016

.asm_f008
	get_flag_value EVENT_FLAG_41
	cp $00
	jr z, .asm_f023
	cp $07
	jr z, .asm_f023
	ld c, $03
.asm_f016
	set_flag_value EVENT_FLAG_44
	max_flag_value EVENT_FLAG_42
	ld a, $0b
	ld [wd111], a
.asm_f023
	scf
	ret

Script_Clerk9: ; f025 (3:7025)
	start_script
	jump_if_flag_zero_1 EVENT_FLAG_3F, .ows_f066
	jump_if_flag_equal EVENT_FLAG_41, $07, .ows_f069
	jump_if_flag_equal EVENT_FLAG_41, $03, .ows_f06f
	jump_if_flag_equal EVENT_FLAG_41, $02, .ows_f072
	jump_if_flag_equal EVENT_FLAG_41, $01, .ows_f06c
	jump_if_flag_equal EVENT_FLAG_40, $07, .ows_f069
	jump_if_flag_equal EVENT_FLAG_40, $03, .ows_f06f
	jump_if_flag_equal EVENT_FLAG_40, $02, .ows_f072
	jump_if_flag_equal EVENT_FLAG_40, $01, .ows_f06c
	jump_if_flag_equal EVENT_FLAG_3F, $07, .ows_f069
	jump_if_flag_equal EVENT_FLAG_3F, $03, .ows_f06f
	jump_if_flag_equal EVENT_FLAG_3F, $02, .ows_f072
	jump_if_flag_equal EVENT_FLAG_3F, $01, .ows_f06c
.ows_f066
	print_text_quit_fully Text050a

.ows_f069
	print_text_quit_fully Text050b

.ows_f06c
	print_text_quit_fully Text050c

.ows_f06f
	print_text_quit_fully Text050d

.ows_f072
	print_text_quit_fully Text050e

Preload_ChallengeHallNPCs2: ; f075 (3:7075)
	call Preload_ChallengeHallNPCs1
	ccf
	ret

Preload_ChallengeHallNPCs1: ; f07a (3:707a)
	get_flag_value EVENT_FLAG_42
	or a
	jr z, .quit
	ld a, $0b
	ld [wd111], a
	scf
.quit
	ret

ChallengeHallLobbyLoadMap: ; f088 (3:7088)
	get_flag_value EVENT_FLAG_58
	or a
	ret z
	ld a, $02
	ld [wTempNPC], a
	call FindLoadedNPC
	ld bc, Script_f166
	jp SetNextNPCAndScript

Script_Pappy3: ; f09c (3:709c)
	start_script
	print_text_quit_fully Text050f

Script_Gal4: ; f0a0 (3:70a0)
	start_script
	print_text_quit_fully Text0510

Script_Champ: ; f0a4 (3:70a4)
	start_script
	print_text_quit_fully Text0511

Script_Hood2: ; f0a8 (3:70a8)
	start_script
	print_text_quit_fully Text0512

Script_Lass5: ; f0ac (3:70ac)
	start_script
	print_text_quit_fully Text0513

Script_Chap5: ; f0b0 (3:70b0)
	start_script
	print_text_quit_fully Text0514

Preload_ChallengeHallLobbyRonald1: ; f0b4 (3:70b4)
	zero_flag_value2 EVENT_FLAG_58
	get_flag_value EVENT_RECEIVED_LEGENDARY_CARD
	or a
	jr nz, .asm_f0ff
	get_flag_value EVENT_FLAG_59
	or a
	jr nz, .asm_f11f
	get_flag_value EVENT_FLAG_40
	cp $00
	jr z, .asm_f0e5
	call .asm_710f
	get_flag_value EVENT_FLAG_40
	ld e, a
	get_flag_value EVENT_FLAG_49
	ld d, a
	ld hl, Unknown_f156
	call Func_f121
	jr nc, .asm_f11f
	jr .asm_f0f7
.asm_f0e5
	get_flag_value EVENT_FLAG_3F
	ld e, a
	get_flag_value EVENT_FLAG_48
	ld d, a
	ld hl, Unknown_f146
	call Func_f121
	jr nc, .asm_f11f
.asm_f0f7
	ld a, [wPlayerYCoord]
	ld [wLoadNPCYPos], a
	scf
	ret
.asm_f0ff
	max_flag_value EVENT_FLAG_54
	max_flag_value EVENT_FLAG_55
	max_flag_value EVENT_FLAG_56
	max_flag_value EVENT_FLAG_57
.asm_710f
	max_flag_value EVENT_FLAG_50
	max_flag_value EVENT_FLAG_51
	max_flag_value EVENT_FLAG_52
	max_flag_value EVENT_FLAG_53
.asm_f11f
	or a
	ret

Func_f121: ; f121 (3:7121)
	ld c, $04
.asm_f123
	ld a, [hli]
	cp e
	jr nz, .asm_f13e
	ld a, [hli]
	cp d
	jr nz, .asm_f13f
	ld a, [hl]
	call GetEventFlagValue
	or a
	jr nz, .asm_f13f
	ld a, [hl]
	call MaxOutEventFlag
	inc hl
	ld c, [hl]
	set_flag_value EVENT_FLAG_58
	scf
	ret
.asm_f13e
	inc hl
.asm_f13f
	inc hl
	inc hl
	dec c
	jr nz, .asm_f123
	or a
	ret

Unknown_f146: ; f146 (3:7146)
	db $01, $00, EVENT_FLAG_50, $01
	db $03, $03, EVENT_FLAG_51, $02
	db $07, $03, EVENT_FLAG_52, $03
	db $07, $00, EVENT_FLAG_53, $04

Unknown_f156: ; f156 (3:7156)
	db $01, $00, EVENT_FLAG_54, $05
	db $03, $03, EVENT_FLAG_55, $06
	db $07, $03, EVENT_FLAG_56, $07
	db $07, $00, EVENT_FLAG_57, $08

Script_f166: ; f166 (3:7166)
	INCROM $f166, $f239

ChallengeHallAfterDuel: ; f239 (3:7239)
	ld c, $00
	ld a, [wDuelResult]
	or a
	jr z, .won
	ld c, $02
.won
	ld b, $00
	ld hl, ChallengeHallAfterDuelTable
	add hl, bc
	ld c, [hl]
	inc hl
	ld b, [hl]
	ld a, NPC_HOST
	ld [wTempNPC], a
	jp SetNextNPCAndScript

ChallengeHallAfterDuelTable:
	dw WonAtChallengeHall
	dw LostAtChallengeHall

ChallengeHallLoadMap: ; f258 (3:7258)
	get_flag_value EVENT_FLAG_47
	or a
	ret z
	ld a, NPC_HOST
	ld [wTempNPC], a
	call FindLoadedNPC
	ld bc, Script_f433
	jp SetNextNPCAndScript

Script_Clerk13: ; f26c (3:726c)
	start_script
	print_text_quit_fully Text0525

Preload_Guide: ; f270 (3:7270)
	get_flag_value EVENT_FLAG_42
	or a
	jr z, .asm_f281
	ld a, $1c
	ld [wLoadNPCXPos], a
	ld a, $02
	ld [wLoadNPCYPos], a
.asm_f281
	scf
	ret

Script_Guide: ; f283 (3:7283)
	start_script
	jump_if_flag_zero_2 EVENT_FLAG_42, .ows_f28b
	print_text_quit_fully Text0526

.ows_f28b
	jump_if_flag_zero_1 EVENT_FLAG_3F, .ows_f292
	print_text_quit_fully Text0527

.ows_f292
	print_text_quit_fully Text0528

Script_Clerk12: ; f295 (3:7295)
	start_script
	jump_if_flag_equal EVENT_FLAG_41, $03, .ows_f2c4
	jump_if_flag_equal EVENT_FLAG_41, $02, .ows_f2c1
	jump_if_flag_equal EVENT_FLAG_40, $03, .ows_f2c4
	jump_if_flag_equal EVENT_FLAG_40, $02, .ows_f2c1
	jump_if_flag_equal EVENT_FLAG_3F, $03, .ows_f2c4
	jump_if_flag_equal EVENT_FLAG_3F, $02, .ows_f2c1
	jump_if_flag_equal EVENT_FLAG_44, $02, .ows_f2cd
	jump_if_flag_equal EVENT_FLAG_44, $03, .ows_f2d3
	script_jump .ows_f2c7

.ows_f2c1
	print_text_quit_fully Text0529

.ows_f2c4
	print_text_quit_fully Text052a

.ows_f2c7
	print_text_string Text052b
	script_jump .ows_f2d6

.ows_f2cd
	print_text_string Text052c
	script_jump .ows_f2d6

.ows_f2d3
	print_text_string Text052d
.ows_f2d6
	print_text_string Text052e
	ask_question_jump Text052f, .ows_f2e1
	print_text_quit_fully Text0530

.ows_f2e1
	max_out_flag_value EVENT_FLAG_59
	print_text_string Text0531
	close_text_box
	move_active_npc NPCMovement_f349
	jump_if_player_coords_match 8, 18, .ows_f2fa
	jump_if_player_coords_match 12, 18, .ows_f302
	move_player NORTH, 2
	script_jump .ows_f307

.ows_f2fa
	set_player_direction EAST
	move_player EAST, 2
	script_jump .ows_f307

.ows_f302
	set_player_direction WEST
	move_player WEST, 2
.ows_f307
	set_player_direction NORTH
	move_player NORTH, 1
	move_player NORTH, 1
	move_player NORTH, 1
	move_player NORTH, 1
	move_player NORTH, 1
	jump_if_flag_nonzero_2 EVENT_FLAG_43, .ows_f33a
	max_out_flag_value EVENT_FLAG_43
	move_player NORTH, 1
	move_player NORTH, 1
	set_player_direction EAST
	do_frames 30
	set_player_direction SOUTH
	do_frames 20
	set_player_direction EAST
	do_frames 20
	set_player_direction SOUTH
	do_frames 30
	move_player SOUTH, 1
	move_player SOUTH, 1
.ows_f33a
	set_player_direction EAST
	move_player EAST, 1
	move_active_npc NPCMovement_f34e
	close_advanced_text_box
	set_next_npc_and_script $4a, Script_f353
	end_script_loop
	ret

NPCMovement_f349: ; f349 (3:7349)
	db NORTH
	db NORTH
	db EAST
;	fallthrough

NPCMovement_f34c: ; f34c (3:734c)
	db WEST | NO_MOVE
	db $ff

NPCMovement_f34e: ; f34e (3:734e)
	db WEST
	db SOUTH
	db SOUTH
	db $ff

Script_Host: ; f352 (3:7352)
	ret

Script_f353: ; f353 (3:7353)
	start_script
	do_frames 20
	move_active_npc NPCMovement_f37d
	do_frames 20
	move_active_npc NPCMovement_f390
	run_command Func_d16b
	db $00
	print_text_string Text0532
	close_text_box
	move_active_npc NPCMovement_f37f
	print_text_string Text0533
	close_text_box
	move_active_npc NPCMovement_f388
	print_text_string Text0534
	close_text_box
	move_active_npc NPCMovement_f38e
	print_text_string Text0535
	run_command Func_cd4f
	db $04
	db $00
	db $00
	quit_script_fully

NPCMovement_f37d: ; f37d (3:737d)
	db EAST | NO_MOVE
	db $ff

NPCMovement_f37f: ; f37f (3:737f)
	db EAST
	db EAST
	db SOUTH
	db $ff

NPCMovement_f383: ; f383 (3:7383)
	db NORTH
	db WEST
	db WEST
	db SOUTH | NO_MOVE
	db $ff

NPCMovement_f388: ; f388 (3:7388)
	db NORTH
	db WEST
	db WEST
;	fallthrough

NPCMovement_f38b: ; f38b (3:738b)
	db WEST
	db SOUTH
	db $ff

NPCMovement_f38e: ; f38e (3:738e)
	db NORTH
	db EAST
;	fallthrough

NPCMovement_f390: ; f390 (3:7390)
	db SOUTH | NO_MOVE
	db $ff

LostAtChallengeHall: ; f392 (3:7392)
	start_script
	do_frames 20
	move_active_npc NPCMovement_f37d
	do_frames 20
	move_active_npc NPCMovement_f390
	jump_if_flag_equal EVENT_FLAG_45, $02, ScriptJump_f410
	jump_if_flag_equal EVENT_FLAG_45, $03, ScriptJump_f410.ows_f41a
	run_command Func_d16b
	db $00
	run_command Func_d16b
	db $01
	print_text_string Text0536
.ows_f3ae
	close_text_box
	move_active_npc NPCMovement_f38b
	print_text_string Text0537
	close_text_box
	move_active_npc NPCMovement_f38e
	jump_if_flag_equal EVENT_FLAG_44, $02, .ows_f3ce
	jump_if_flag_equal EVENT_FLAG_44, $03, .ows_f3d9
	script_set_flag_value EVENT_FLAG_3F, $03
	script_set_flag_value EVENT_FLAG_48, $03
	zero_out_flag_value EVENT_FLAG_51
	script_jump .ows_f3e2
.ows_f3ce
	script_set_flag_value EVENT_FLAG_40, $03
	script_set_flag_value EVENT_FLAG_49, $03
	zero_out_flag_value EVENT_FLAG_55
	script_jump .ows_f3e2
.ows_f3d9
	script_set_flag_value EVENT_FLAG_41, $03
	script_set_flag_value EVENT_FLAG_4A, $03
	script_jump .ows_f3e2
.ows_f3e2
	close_advanced_text_box
	set_next_npc_and_script NPC_CLERK12, Script_f3e9
	end_script_loop
	ret

Script_f3e9: ; f3e9 (3:73e9)
	start_script
	move_active_npc NPCMovement_f40a
	set_player_direction WEST
	move_player WEST, 1
	set_player_direction SOUTH
	move_player SOUTH, 1
	move_player SOUTH, 1
	move_player SOUTH, 1
	move_player SOUTH, 1
	move_player SOUTH, 1
	move_player SOUTH, 1
	move_active_npc NPCMovement_f40d
	quit_script_fully

NPCMovement_f40a: ; f40a (3:740a)
	db WEST
	db EAST | NO_MOVE
	db $ff

NPCMovement_f40d: ; f40d (3:740d)
	db EAST
	db SOUTH | NO_MOVE
	db $ff

ScriptJump_f410: ; f410 (4:7410)
	run_command Func_d16b
	db $00
	run_command Func_d16b
	db $01
	print_text_string Text0538
	script_jump LostAtChallengeHall.ows_f3ae

.ows_f41a
	print_text_string Text0539
	set_dialog_npc NPC_RONALD1
	jump_if_flag_equal EVENT_FLAG_44, $03, .ows_f42e
	jump_if_flag_equal EVENT_FLAG_44, $01, NULL
	print_variable_text Text053a, Text053b
.ows_f42e
	set_dialog_npc NPC_HOST
	script_jump LostAtChallengeHall.ows_f3ae

Script_f433: ; f433 (3:7433)
	start_script
	do_frames 20
	move_active_npc NPCMovement_f37d
	do_frames 20
	move_active_npc NPCMovement_f390
	script_jump WonAtChallengeHall.ows_f4a4

WonAtChallengeHall: ; f441 (3:7441)
	start_script
	do_frames 20
	move_active_npc NPCMovement_f37d
	do_frames 20
	move_active_npc NPCMovement_f390
	jump_if_flag_equal EVENT_FLAG_45, $03, ScriptJump_f4db
	jump_if_flag_equal EVENT_FLAG_45, $02, .ows_f456
.ows_f456
	jump_if_flag_equal EVENT_FLAG_45, $01, NULL
	print_variable_text Text053c, Text053d
	move_active_npc NPCMovement_f37f
	run_command Func_d16b
	db $00
	print_text_string Text053e
	close_text_box
	move_wram_npc NPCMovement_f4c8
	run_command Func_cdd8
	print_text_string Text053f
	close_text_box
	run_command Func_d195
	run_command Func_cdf5
	db $14
	db $14
	move_wram_npc NPCMovement_f4d0
	run_command Func_d16b
	db $00
	jump_if_flag_equal EVENT_FLAG_45, $02, NULL
	print_variable_text Text0540, Text0541
	move_active_npc NPCMovement_f383
	jump_if_flag_equal EVENT_FLAG_45, $02, .ows_f4a4
	jump_if_flag_equal EVENT_FLAG_44, $03, .ows_f4a1
	close_text_box
	set_dialog_npc $02
	jump_if_flag_equal EVENT_FLAG_44, $01, NULL
	print_variable_text Text0542, Text0543
	set_dialog_npc NPC_HOST
	close_text_box
.ows_f4a1
	print_text_string Text0544
.ows_f4a4
	zero_out_flag_value EVENT_FLAG_47
	print_text_string Text0545
	ask_question_jump_default_yes Text0546, .ows_f4bd
	jump_if_flag_equal EVENT_FLAG_45, $02, NULL
	print_variable_text Text0547, Text0548
	run_command Func_cd4f
	db $04
	db $00
	db $00
	quit_script_fully
.ows_f4bd
	print_text_string Text0549
	close_text_box
	max_out_flag_value EVENT_FLAG_47
	run_command Func_d1ad
	close_text_box
	script_jump .ows_f4a4

NPCMovement_f4c8: ; f4c8 (3:74c8)
	db EAST
NPCMovement_f4c9: ; f4c9 (3:74c9)
	db SOUTH
	db SOUTH
	db SOUTH
	db SOUTH
	db SOUTH
	db SOUTH
	db $ff

NPCMovement_f4d0: ; f4d0 (3:74d0)
	db NORTH
	db NORTH
	db NORTH
	db NORTH
	db NORTH
	db NORTH
	db WEST
	db $ff

NPCMovement_f4d8: ; f4d8 (3:74d8)
	db EAST
	db SOUTH | NO_MOVE
	db $ff

ScriptJump_f4db: ; f4db (3:74db)
	print_text_string Text054a
	move_active_npc NPCMovement_f37f
	run_command Func_d16b
	db $00
	print_text_string Text054b
	close_text_box
	jump_if_flag_equal EVENT_FLAG_44, $03, .ows_f513
	set_dialog_npc $02
	jump_if_flag_equal EVENT_FLAG_44, $01, NULL
	print_variable_text Text054c, Text054d
	move_wram_npc NPCMovement_f4d8
	do_frames 40
	move_wram_npc NPCMovement_f34c
	jump_if_flag_equal EVENT_FLAG_44, $01, NULL
	print_variable_text Text054e, Text054f
	set_dialog_npc NPC_HOST
	close_text_box
	move_wram_npc NPCMovement_f4c9
	script_jump .ows_f516
.ows_f513
	move_wram_npc NPCMovement_f4c8
.ows_f516
	run_command Func_cdd8
	move_active_npc NPCMovement_f383
	print_text_string Text0550
	close_text_box
	move_active_npc NPCMovement_f38b
	run_command Func_d1b3
	print_text_string Text0551
	give_card VARIABLE_CARD
	show_card_received_screen $00
	print_text_string Text0552
	close_text_box
	jump_if_flag_equal EVENT_FLAG_44, $02, .ows_f540
	jump_if_flag_equal EVENT_FLAG_44, $03, .ows_f549
	script_set_flag_value EVENT_FLAG_3F, $02
	script_set_flag_value EVENT_FLAG_48, $02
	script_jump .ows_f552
.ows_f540
	script_set_flag_value EVENT_FLAG_40, $02
	script_set_flag_value EVENT_FLAG_49, $02
	script_jump .ows_f552
.ows_f549
	script_set_flag_value EVENT_FLAG_41, $02
	script_set_flag_value EVENT_FLAG_4A, $02
	script_jump .ows_f552
.ows_f552
	close_advanced_text_box
	set_next_npc_and_script NPC_CLERK12, Script_f3e9
	end_script_loop
	ret

; Loads the NPC to fight at the challenge hall
Preload_ChallengeHallOpponent: ; f559 (3:7559)
	get_flag_value EVENT_FLAG_42
	or a
	ret z
	get_flag_value EVENT_FLAG_46
	or a
	jr z, .asm_f56e
	ld a, [wd696]
	ld [wTempNPC], a
	scf
	ret
.asm_f56e
	call Func_f5db
	ld c, $01
	set_flag_value EVENT_FLAG_45
	call Func_f580
	max_flag_value EVENT_FLAG_46
	scf
	ret

Func_f580: ; f580 (3:7580)
	get_flag_value EVENT_FLAG_44
	cp $3
	jr z, .pick_challenger_include_ronald
	get_flag_value EVENT_FLAG_45
	cp $3
	ld d, ChallengeHallNPCsEnd - ChallengeHallNPCs - 1 ; discount Ronald
	jr nz, .pick_challenger
	ld a, NPC_RONALD1
	jr .force_ronald

.pick_challenger_include_ronald
	ld d, ChallengeHallNPCsEnd - ChallengeHallNPCs

.pick_challenger
	ld a, d
	call Random
	ld c, a
	call Func_f5cc
	jr c, .pick_challenger
	call Func_f5d4
	ld b, $0
	ld hl, ChallengeHallNPCs
	add hl, bc
	ld a, [hl]

.force_ronald
	ld [wTempNPC], a
	ld [wd696], a
	ret

ChallengeHallNPCs: ; f5b3 (3:75b3)
	db NPC_CHRIS
	db NPC_MICHAEL
	db NPC_JESSICA
	db NPC_MATTHEW
	db NPC_RYAN
	db NPC_ANDREW
	db NPC_SARA
	db NPC_AMANDA
	db NPC_JOSHUA
	db NPC_JENNIFER
	db NPC_NICHOLAS
	db NPC_BRANDON
	db NPC_BRITTANY
	db NPC_KRISTIN
	db NPC_HEATHER
	db NPC_ROBERT
	db NPC_DANIEL
	db NPC_STEPHANIE
	db NPC_JOSEPH
	db NPC_DAVID
	db NPC_ERIK
	db NPC_JOHN
	db NPC_ADAM
	db NPC_JONATHAN
	db NPC_RONALD1
ChallengeHallNPCsEnd:

Func_f5cc: ; f5cc (3:75cc)
	INCROM $f5cc, $f5d4

Func_f5d4: ; f5d4 (3:75d4)
	INCROM $f5d4, $f5db

Func_f5db: ; f5db (3:75db)
	xor a
	ld [wd698], a
	ld [wd699], a
	ld [wd69a], a
	ld [wd69b], a
	ret
; 0xf5e9

	INCROM $f5e9, $f602

Func_f602: ; f602 (3:7602)
	INCROM $f602, $f607

PokemonDomeEntranceLoadMap: ; f607 (3:7607)
	INCROM $f607, $f62a

PokemonDomeEntranceCloseTextBox: ; f62a (3:762a)
	INCROM $f62a, $f631

Script_f631: ; f631 (3:7631)
	start_script
	print_text_string Text0508
	close_advanced_text_box
	set_next_npc_and_script NPC_RONALD1, .ows_f63c
	end_script_loop

	ret

.ows_f63c
	INCROM $f63c, $f6af

Script_f6af: ; f6af (3:76af)
	INCROM $f6af, $f6c6

PokemonDomeMovePlayer: ; f6c6 (3:76c6)
	INCROM $f6c6, $f6e0

PokemonDomeAfterDuel: ; f6e0 (3:76e0)
	ld hl, .after_duel_table
	call FindEndOfBattleScript
	ret

.after_duel_table
	db NPC_COURTNEY
	db NPC_COURTNEY
	dw Script_BeatCourtney
	dw Script_LostToCourtney

	db NPC_STEVE
	db NPC_STEVE
	dw Script_BeatSteve
	dw Script_LostToSteve

	db NPC_JACK
	db NPC_JACK
	dw Script_BeatJack
	dw Script_LostToJack

	db NPC_ROD
	db NPC_ROD
	dw Script_BeatRod
	dw Script_LostToRod

	db NPC_RONALD1
	db NPC_RONALD1
	dw Script_BeatRonald1InPokemonDome
	dw Script_LostToRonald1InPokemonDome
	db $00

PokemonDomeLoadMap: ; f706 (3:7706)
	INCROM $f706, $f718

PokemonDomeCloseTextBox: ; f718 (3:7718)
	INCROM $f718, $f71f

Script_Courtney: ; f71f (3:771f)
	INCROM $f71f, $f72a

Script_Steve: ; f72a (3:772a)
	INCROM $f72a, $f735

Script_Jack: ; f735 (3:7735)
	INCROM $f735, $f740

Script_Rod: ; f740 (3:7740)
	INCROM $f740, $f74b

Preload_Courtney: ; f74b (3:774b)
	INCROM $f74b, $f78c

Preload_Steve: ; f78c (3:778c)
	INCROM $f78c, $f7a3

Preload_Jack: ; f7a3 (3:77a3)
	INCROM $f7a3, $f7ba

Preload_Rod: ; f7ba (3:77ba)
	INCROM $f7ba, $f7d6

Preload_Ronald1InPokemonDome: ; f7d6 (3:77d6)
	INCROM $f7d6, $f93f

Script_LostToCourtney: ; f93f (3:793f)
	INCROM $f93f, $f95a

Script_BeatCourtney: ; f95a (3:795a)
	INCROM $f95a, $f9b7

Script_LostToSteve: ; f9b7 (3:79b7)
	INCROM $f9b7, $f9c8

Script_BeatSteve: ; f9c8 (3:79c8)
	INCROM $f9c8, $fa23

Script_LostToJack: ; fa23 (3:7a23)
	INCROM $fa23, $fa34

Script_BeatJack: ; fa34 (3:7a34)
	INCROM $fa34, $fa98

Script_LostToRod: ; fa98 (3:7a98)
	INCROM $fa98, $faae

Script_BeatRod: ; faae (3:7aae)
	INCROM $faae, $fb48

Script_LostToRonald1InPokemonDome: ; fb48 (3:7b48)
	INCROM $fb48, $fb53

Script_BeatRonald1InPokemonDome: ; fb53 (3:7b53)
	INCROM $fb53, $fbdb

HallOfHonorLoadMap: ; fbdb (3:7bdb)
	ld a, SFX_10
	call PlaySFX
	ret

Script_fbe1: ; fbe1 (3:7be1)
	INCROM $fbe1, $fbf1

Script_fbf1: ; fbf1 (3:7bf1)
	start_script
	jump_if_flag_nonzero_2 EVENT_RECEIVED_LEGENDARY_CARD, .ows_fc10
	max_out_flag_value EVENT_RECEIVED_LEGENDARY_CARD
	run_command Func_ccdc
	tx Text05b8
	give_card ZAPDOS3
	give_card MOLTRES2
	give_card ARTICUNO2
	give_card DRAGONITE1
	show_card_received_screen $ff
.ows_fc05
	run_command Func_d38f
	db $00
	run_command Func_ccdc
	tx Text05b9
.ows_fc0a
	run_command Func_d38f
	db $01
	run_command Func_d396
	db $01
	run_command Func_d3b9
	quit_script_fully

.ows_fc10
	jump_if_flag_equal EVENT_FLAG_71, $0f, .ows_fc20
	run_command Func_d209
	run_command Func_ccdc
	tx Text05ba
	give_card VARIABLE_CARD
	show_card_received_screen VARIABLE_CARD
	script_jump .ows_fc05

.ows_fc20
	run_command Func_ccdc
	tx Text05bb
	run_command Func_d38f
	db $00
	run_command Func_ccdc
	tx Text05bc
	script_jump .ows_fc0a

Func_fc2b: ; fc2b (3:7c2b)
	ld a, [wDuelResult]
	cp 2
	jr c, .asm_fc34
	ld a, $2
.asm_fc34
	rlca
	ld c, a
	ld b, $0
	ld hl, PointerTable_fc4c
	add hl, bc
	ld c, [hl]
	inc hl
	ld b, [hl]
	ld a, LOW(ClerkNPCName_)
	ld [wCurrentNPCNameTx], a
	ld a, HIGH(ClerkNPCName_)
	ld [wCurrentNPCNameTx+1], a
	jp SetNextScript

PointerTable_fc4c: ; fc4c (3:7c4c)
	dw Script_fc64
	dw Script_fc68
	dw Script_fc60

Script_fc52: ; fc52 (3:7c52)
	start_script
	print_text_string Text06c8
	ask_question_jump_default_yes NULL, .ows_fc5e
	print_text_quit_fully Text06c9

.ows_fc5e
	run_command Func_cd76
	quit_script_fully

Script_fc60: ; fc60 (3:7c60)
	start_script
	print_text_quit_fully Text06ca

Script_fc64: ; fc64 (3:7c64)
	start_script
	print_text_quit_fully Text06cb

Script_fc68: ; fc68 (3:7c68)
	start_script
	print_text_quit_fully Text06cc

; Clerk looks away from you if you can't use infrared
; This is one of the preloads that does not change whether or not they appear
Preload_GiftCenterClerk: ; fc6c (3:7c6c)
	ld a, [wConsole]
	cp CONSOLE_CGB
	jr z, .notCGB
	ld a, NORTH
	ld [wLoadNPCDirection], a
.notCGB
	scf
	ret

Func_fc7a: ; fc7a (3:7c7a)
	ld a, [wConsole]
	ld c, a
	set_flag_value EVENT_FLAG_74

	start_script
	jump_if_flag_not_equal EVENT_FLAG_74, $02, Func_fcad.ows_fcd5
	print_text_string Text06cd
	run_command Func_d39d
	db $00
	jump_if_flag_not_less_than EVENT_FLAG_72, $04, Func_fc7a.ows_fcaa
	print_text_string Text06ce
	ask_question_jump_default_yes Text06cf, .ows_fca0
	print_text_string Text06d0
	script_jump Func_fc7a.ows_fcaa

.ows_fca0
	run_command Func_d396
	db $00
	play_sfx SFX_56
	run_command Func_ccdc
	tx Text06d1
	run_command Func_d39d
	db $01
	quit_script_fully

.ows_fcaa
	print_text_quit_fully Text06d2

Func_fcad: ; fcad (3:7cad)
	ld a, [wd10e]
	ld c, a
	set_flag_value EVENT_FLAG_72

	start_script
	play_sfx SFX_56
	run_command Func_d396
	db $00
	jump_if_flag_equal EVENT_FLAG_72, $00, .ows_fccc
	jump_if_flag_equal EVENT_FLAG_72, $02, .ows_fccf
	jump_if_flag_equal EVENT_FLAG_72, $03, .ows_fcd2
	script_jump Func_fc7a.ows_fcaa

.ows_fccc
	print_text_quit_fully Text06d3

.ows_fccf
	print_text_quit_fully Text06d4

.ows_fcd2
	print_text_quit_fully Text06d5

.ows_fcd5
	move_arbitrary_npc NPC_GIFT_CENTER_CLERK, NPCMovement_fce1
	print_text_string Text06d6
	move_arbitrary_npc NPC_GIFT_CENTER_CLERK, NPCMovement_fce3
	quit_script_fully

NPCMovement_fce1: ; fce1 (3:7ce1)
	db SOUTH | NO_MOVE
	db $ff

NPCMovement_fce3: ; fce3 (3:7ce3)
	db NORTH | NO_MOVE
	db $ff
; 0xfce5

rept $31b
	db $ff
endr
