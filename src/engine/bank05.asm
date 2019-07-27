PointerTable_14000: ; 14000 (05:4000)
	dw $47bd ; SAMS_PRACTICE_DECK
	dw PointerTable_14668 ; PRACTICE_PLAYER_DECK
	dw PointerTable_14668 ; SAMS_NORMAL_DECK
	dw PointerTable_14668 ; CHARMANDER_AND_FRIENDS_DECK
	dw PointerTable_14668 ; CHARMANDER_EXTRA_DECK
	dw PointerTable_14668 ; SQUIRTLE_AND_FRIENDS_DECK
	dw PointerTable_14668 ; SQUIRTLE_EXTRA_DECK
	dw PointerTable_14668 ; BULBASAUR_AND_FRIENDS_DECK
	dw PointerTable_14668 ; BULBASAUR_EXTRA_DECK
	dw PointerTable_14668 ; LIGHTNING_AND_FIRE_DECK
	dw PointerTable_14668 ; WATER_AND_FIGHTING_DECK
	dw PointerTable_14668 ; GRASS_AND_PSYCHIC_DECK
	dw $49e8 ; LEGENDARY_MOLTRES_DECK
	dw $4b0f ; LEGENDARY_ZAPDOS_DECK
	dw $4c0b ; LEGENDARY_ARTICUNO_DECK
	dw $4d60 ; LEGENDARY_DRAGONITE_DECK
	dw $4e89 ; FIRST_STRIKE_DECK
	dw $4f0e ; ROCK_CRUSHER_DECK
	dw $4f8f ; GO_GO_RAIN_DANCE_DECK
	dw $5019 ; ZAPPING_SELFDESTRUCT_DECK
	dw $509b ; FLOWER_POWER_DECK
	dw $5122 ; STRANGE_PSYSHOCK_DECK
	dw $51ad ; WONDERS_OF_SCIENCE_DECK
	dw $5232 ; FIRE_CHARGE_DECK
	dw $52bd ; IM_RONALD_DECK
	dw $534b ; POWERFUL_RONALD_DECK
	dw $53e8 ; INVINCIBLE_RONALD_DECK
	dw $546f ; LEGENDARY_RONALD_DECK
	dw $48dc ; MUSCLES_FOR_BRAINS_DECK
	dw PointerTable_14668 ; HEATED_BATTLE_DECK
	dw PointerTable_14668 ; LOVE_TO_BATTLE_DECK
	dw PointerTable_14668 ; EXCAVATION_DECK
	dw PointerTable_14668 ; BLISTERING_POKEMON_DECK
	dw PointerTable_14668 ; HARD_POKEMON_DECK
	dw PointerTable_14668 ; WATERFRONT_POKEMON_DECK
	dw PointerTable_14668 ; LONELY_FRIENDS_DECK
	dw PointerTable_14668 ; SOUND_OF_THE_WAVES_DECK
	dw PointerTable_14668 ; PIKACHU_DECK
	dw PointerTable_14668 ; BOOM_BOOM_SELFDESTRUCT_DECK
	dw PointerTable_14668 ; POWER_GENERATOR_DECK
	dw PointerTable_14668 ; ETCETERA_DECK
	dw PointerTable_14668 ; FLOWER_GARDEN_DECK
	dw PointerTable_14668 ; KALEIDOSCOPE_DECK
	dw PointerTable_14668 ; GHOST_DECK
	dw PointerTable_14668 ; NAP_TIME_DECK
	dw PointerTable_14668 ; STRANGE_POWER_DECK
	dw PointerTable_14668 ; FLYIN_POKEMON_DECK
	dw PointerTable_14668 ; LOVELY_NIDORAN_DECK
	dw PointerTable_14668 ; POISON_DECK
	dw PointerTable_14668 ; ANGER_DECK
	dw PointerTable_14668 ; FLAMETHROWER_DECK
	dw PointerTable_14668 ; RESHUFFLE_DECK
	dw $48dc ; IMAKUNI_DECK
; 1406a

PointerTable_1406a: ; 1406a (5:406a)
	dw $406c
	dw Func_14078
	dw Func_14078
	dw $409e
	dw $40a2
	dw $40a6
	dw $40aa

Func_14078: ; 14078 (5:4078)
	call Func_15eae
	call Func_158b2
	jr nc, .asm_14091
	call Func_15b72
	call Func_15d4f
	call Func_158b2
	jr nc, .asm_14091
	call Func_15b72
	call Func_15d4f
.asm_14091
	call Func_164e8
	call Func_169f8
	ret c
	ld a, $05
	bank1call AIMakeDecision
	ret
; 0x1409e

	INCROM $1409e, $140ae

; returns carry if damage dealt from any of
; a card's moves knocks out defending Pokémon
; input:
; hTempPlayAreaLocation_ff9d = location of attacking card to consider
CheckIfAnyMoveKnocksOutDefendingCard: ; 140ae (5:40ae)
	xor a ; first move
	call CheckIfMoveKnocksOutDefendingCard
	ret c
	ld a, $01 ; second move
; fallthrough

CheckIfMoveKnocksOutDefendingCard: ; 140b5 (5:40b5)
	call CalculateMoveDamage_VersusDefendingCard
	ld a, DUELVARS_ARENA_CARD_HP
	call GetNonTurnDuelistVariable
	ld hl, wDamage
	sub [hl]
	ret c
	ret nz
	scf
	ret
; 0x140c5

	INCROM $140c5, $140fe

; adds wcdbe to a, and stores result in wcdbe
; if there's overflow, it's capped at $ff
; output:
; 	a = a + wcdbe (capped at $ff)
AddToWcdbe: ; 140fe (5:40fe)
	push hl
	ld hl, wcdbe
	add [hl]
	jr nc, .no_cap
	ld a, $ff
.no_cap
	ld [hl], a
	pop hl
	ret
; 0x1410a

; subs a from wcdbe, and stores result in wcdbe
; if there's underflow, it's capped at $00
SubFromWcdbe: ; 1410a (5:410a)
	push hl
	push de
	ld e, a
	ld hl, wcdbe
	ld a, [hl]
	or a
	jr z, .done
	sub e
	ld [hl], a
	jr nc, .done
	ld [hl], $00
.done
	pop de
	pop hl
	ret
; 0x1411d

; stores defending Pokémon's weakness/resistance
; and the number of prize cards in both sides
StoreDefendingPokemonColorWRAndPrizeCards: ; 1411d (5:411d)
	call SwapTurn
	call GetArenaCardColor
	call TranslateColorToWR
	ld [wAIPlayerColor], a
	call GetArenaCardWeakness
	ld [wAIPlayerWeakness], a
	call GetArenaCardResistance
	ld [wAIPlayerResistance], a
	call CountPrizes
	ld [wAIPlayerPrizeCount], a
	call SwapTurn
	call CountPrizes
	ld [wAIOpponentPrizeCount], a
	ret
; 0x14145

	INCROM $14145, $14226

Func_14226: ; 14226 (5:4226)
	call CreateHandCardList
	ld hl, wDuelTempList
.check_for_next_card
	ld a, [hli]
	ldh [hTempCardIndex_ff98], a
	cp $ff
	ret z

	call LoadCardDataToBuffer1_FromDeckIndex
	ld a, [wLoadedCard1Type]
	cp TYPE_ENERGY
	jr nc, .check_for_next_card
	ld a, [wLoadedCard1Stage]
	or a
	jr nz, .check_for_next_card
	push hl
	ldh a, [hTempCardIndex_ff98]
	call PutHandPokemonCardInPlayArea
	pop hl
	jr .check_for_next_card
; 0x1424b

; returns carry if Pokémon at hTempPlayAreaLocation_ff9d
; can't use a move or if that selected move doesn't have enough energy
; input:
; 	hTempPlayAreaLocation_ff9d = location of Pokémon card
;	wSelectedMoveIndex 		   = selected move to examine
CheckIfCardCanUseSelectedMove: ; 1424b (5:424b)
	ldh a, [hTempPlayAreaLocation_ff9d]
	or a
	jr nz, .bench

	bank1call HandleCantAttackSubstatus
	ret c
	bank1call CheckIfActiveCardParalyzedOrAsleep
	ret c

	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	ld d, a
	ld a, [wSelectedMoveIndex]
	ld e, a
	call CopyMoveDataAndDamage_FromDeckIndex
	call HandleAmnesiaSubstatus
	ret c
	ld a, EFFECTCMDTYPE_INITIAL_EFFECT_1
	call TryExecuteEffectCommandFunction
	ret c
	
.bench
	call CheckEnergyNeededForAttack
	ret c ; can't be used
	ld a, $0d ; $00001101
	call CheckLoadedMoveFlag
	ret
; 0x14279

; load selected move from Pokémon in hTempPlayAreaLocation_ff9d
; and checks if there is enough energy to execute the selected move
; input:
; 	hTempPlayAreaLocation_ff9d = location of Pokémon card
;	wSelectedMoveIndex 		   = selected move to examine
; output:
;	b = colorless energy still needed
;	c = basic energy still needed
;	e = output of ConvertColorToEnergyCardID, or $0 if not a move
;	z set if move has enough energy
;	c set	   if no move 
;	   		OR if it's a Pokémon Power
;	   		OR if not enough energy for move
CheckEnergyNeededForAttack: ; 14279 (5:4279)
	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	ld d, a
	ld a, [wSelectedMoveIndex]
	ld e, a
	call CopyMoveDataAndDamage_FromDeckIndex
	ld hl, wLoadedMoveName
	ld a, [hli]
	or [hl]
	jr z, .no_move
	ld a, [wLoadedMoveCategory]
	cp POKEMON_POWER
	jr nz, .is_move
.no_move
	lb bc, $00, $00
	ld e, c
	scf
	ret
	
.is_move
	ldh a, [hTempPlayAreaLocation_ff9d]
	ld e, a
	call GetPlayAreaCardAttachedEnergies
	bank1call HandleEnergyBurn

	xor a
	ld [wTempLoadedMoveEnergyCost], a
	ld [wTempLoadedMoveEnergyNeededAmount], a
	ld [wTempLoadedMoveEnergyNeededType], a

	ld hl, wAttachedEnergies
	ld de, wLoadedMoveEnergyCost
	ld b, 0
	ld c, (NUM_TYPES / 2) - 1
	
.loop
	; check all basic energy cards except colorless
	ld a, [de]
	swap a
	call CheckIfEnoughParticularAttachedEnergy
	ld a, [de]
	call CheckIfEnoughParticularAttachedEnergy
	inc de
	dec c
	jr nz, .loop

; running CheckIfEnoughParticularAttachedEnergy back to back like this
; overwrites the results of a previous call of this function,
; however, no move in the game has energy requirements for two
; different energy types (excluding colorless), so this routine
; will always just return the result for one type of basic energy,
; while all others will necessarily have an energy cost of 0
; if moves are added to the game with energy requirements of
; two different basic energy types, then this routine only accounts 
; for the type with the highest index

	; colorless
	ld a, [de]
	swap a
	and %00001111
	ld b, a ; colorless energy still needed
	ld a, [wTempLoadedMoveEnergyCost]
	ld hl, wTempLoadedMoveEnergyNeededAmount
	sub [hl]
	ld c, a ; basic energy still needed
	ld a, [wTotalAttachedEnergies]
	sub c
	sub b
	jr c, .not_enough

	ld a, [wTempLoadedMoveEnergyNeededAmount]
	or a
	ret z

; being here means the energy cost isn't satisfied,
; including with colorless energy
	xor a
.not_enough
	cpl
	inc a
	ld c, a ; colorless energy still needed
	ld a, [wTempLoadedMoveEnergyNeededAmount]
	ld b, a ; basic energy still needed
	ld a, [wTempLoadedMoveEnergyNeededType]
	call ConvertColorToEnergyCardID
	ld e, a
	ld d, 0
	scf
	ret
; 0x142f4

; takes as input the energy cost of a move for a 
; particular energy, stored in the lower nibble of a
; if the move costs some amount of this energy, the lower nibble of a != 0,
; and this amount is stored in wTempLoadedMoveEnergyCost
; sets carry flag if not enough energy of this type attached
; input:
; 	a   = this energy cost of move (lower nibble)
; 	hl -> attached energy
; output:
;	z set if enough energy
;	c set if not enough of this energy type attached
CheckIfEnoughParticularAttachedEnergy: ; 142f4 (5:42f4)
	and %00001111
	jr nz, .check
.has_enough
	inc hl
	inc b
	or a
	ret

.check
	ld [wTempLoadedMoveEnergyCost], a
	sub [hl]
	jr z, .has_enough
	jr c, .has_enough

	; not enough energy
	ld [wTempLoadedMoveEnergyNeededAmount], a
	ld a, b
	ld [wTempLoadedMoveEnergyNeededType], a
	inc hl
	inc b
	scf
	ret
; 0x1430f

; input:
;	a = energy type
ConvertColorToEnergyCardID: ; 1430f (5:430f)
	push hl
	push de
	ld e, a
	ld d, 0
	ld hl, .card_id
	add hl, de
	ld a, [hl]
	pop de
	pop hl
	ret

.card_id
	db FIRE_ENERGY
	db GRASS_ENERGY
	db LIGHTNING_ENERGY
	db WATER_ENERGY
	db FIGHTING_ENERGY
	db PSYCHIC_ENERGY
	db DOUBLE_COLORLESS_ENERGY
	
Func_14323: ; 14323 (5:4323)
	INCROM $14323, $1433d

Func_1433d: ; 1433d (5:433d)
	INCROM $1433d, $1438c

; loads all the energy cards
; in hand in wDuelTempList
; return carry if no energy cards found
CreateEnergyCardListFromHand: ; 1438c (5:438c)
	push hl
	push de
	push bc
	ld de, wDuelTempList
	ld b, a
	ld a, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	call GetTurnDuelistVariable
	ld c, a
	inc c
	ld l, LOW(wOpponentHand)
	jr .decrease

.loop
	ld a, [hli]
	push de
	call GetCardIDFromDeckIndex
	call GetCardType
	pop de
	and TYPE_ENERGY
	jr z, .decrease
	dec hl
	ld a, [hli]
	ld [de], a
	inc de
.decrease
	dec c
	jr nz, .loop

	ld a, $ff
	ld [de], a
	pop bc
	pop de
	pop hl
	ld a, [wDuelTempList]
	cp $ff
	ccf
	ret
; 0x143bf

Func_143bf: ; 143bf (5:43bf)
	INCROM $143bf, $143e5

; stores in wDamage, wAIMinDamage and wAIMaxDamage the calculated damage
; done to the defending Pokémon by a given card and move
; input:
; a = move index to take into account
; hTempPlayAreaLocation_ff9d = location of attacking card to consider
CalculateMoveDamage_VersusDefendingCard: ; 143e5 (5:43e5)
	ld [wSelectedMoveIndex], a
	ld e, a
	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	ld d, a
	call CopyMoveDataAndDamage_FromDeckIndex
	ld a, [wLoadedMoveCategory]
	cp POKEMON_POWER
	jr nz, .is_move

; is a Pokémon Power
; set wDamage, wAIMinDamage and wAIMaxDamage to zero
	ld hl, wDamage
	xor a
	ld [hli], a
	ld [hl], a
	ld [wAIMinDamage], a
	ld [wAIMaxDamage], a
	ld e, a
	ld d, a
	ret

.is_move
; set wAIMinDamage and wAIMaxDamage to damage of move
	ld a, [wDamage]
	ld [wAIMinDamage], a
	ld [wAIMaxDamage], a
	ld a, EFFECTCMDTYPE_AI
	call TryExecuteEffectCommandFunction
	ld a, [wAIMinDamage]
	ld hl, wAIMaxDamage
	or [hl]
	jr nz, .calculation
	ld a, [wDamage]
	ld [wAIMinDamage], a
	ld [wAIMaxDamage], a
	
.calculation
; if temp. location is active, damage calculation can be done directly...
	ldh a, [hTempPlayAreaLocation_ff9d]
	or a
	jr z, CalculateDamage_VersusDefendingPokemon

; ...otherwise substatuses need to be temporarily reset to account
; for the switching, to obtain the right damage calculation...
	; reset substatus1
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS1
	call GetTurnDuelistVariable
	push af
	push hl
	ld [hl], $00
	; reset substatus2
	ld l, DUELVARS_ARENA_CARD_SUBSTATUS2
	ld a, [hl]
	push af
	push hl
	ld [hl], $00
	; reset changed resistance
	ld l, DUELVARS_ARENA_CARD_CHANGED_RESISTANCE
	ld a, [hl]
	push af
	push hl
	ld [hl], $00
	call CalculateDamage_VersusDefendingPokemon
; ...and subsequently recovered to continue the battle normally
	pop hl
	pop af
	ld [hl], a
	pop hl
	pop af
	ld [hl], a
	pop hl
	pop af
	ld [hl], a
	ret

; calculates the damage that will be dealt to the player's active card
; using the card that is located in hTempPlayAreaLocation_ff9d
; taking into account weakness/resistance/pluspowers/defenders/etc
; and outputs the result capped at a max of $ff
; input:
; 	[wAIMinDamage] = base damage
; 	[wAIMaxDamage] = base damage
; 	[wDamage]      = base damage
; 	hTempPlayAreaLocation_ff9d = turn holder's card location as the attacker
CalculateDamage_VersusDefendingPokemon: ; 14453 (5:4453)
	ld hl, wAIMinDamage
	call _CalculateDamage_VersusDefendingPokemon
	ld hl, wAIMaxDamage
	call _CalculateDamage_VersusDefendingPokemon
	ld hl, wDamage
; fallthrough

_CalculateDamage_VersusDefendingPokemon: ; 14462 (5:4462)
	ld e, [hl]
	ld d, $00
	push hl

	; load this card's data
	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2ID]
	ld [wTempTurnDuelistCardID], a

	; load player's arena card data
	call SwapTurn
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2ID]
	ld [wTempNonTurnDuelistCardID], a
	call SwapTurn

	push de
	call HandleNoDamageOrEffectSubstatus
	pop de
	jr nc, .vulnerable
	; invulnerable to damage
	ld de, $0
	jr .done
.vulnerable
	ldh a, [hTempPlayAreaLocation_ff9d]
	or a
	call z, HandleDoubleDamageSubstatus
	; skips the weak/res checks if bit 7 is set
	; I guess to avoid overflowing?
	; should probably just have skipped weakness test instead?
	bit 7, d
	res 7, d
	jr nz, .not_resistant

; handle weakness
	ldh a, [hTempPlayAreaLocation_ff9d]
	call GetPlayAreaCardColor
	call TranslateColorToWR
	ld b, a
	call SwapTurn
	call GetArenaCardWeakness
	call SwapTurn
	and b
	jr z, .not_weak
	; double de
	sla e
	rl d

.not_weak
; handle resistance
	call SwapTurn
	call GetArenaCardResistance
	call SwapTurn
	and b
	jr z, .not_resistant
	ld hl, -30
	add hl, de
	ld e, l
	ld d, h

.not_resistant
	; apply pluspower and defender boosts
	ldh a, [hTempPlayAreaLocation_ff9d]
	add CARD_LOCATION_ARENA
	ld b, a
	call ApplyAttachedPluspower
	call SwapTurn
	ld b, CARD_LOCATION_ARENA
	call ApplyAttachedDefender
	call HandleDamageReduction
	; test if de underflowed
	bit 7, d
	jr z, .no_underflow
	ld de, $0

.no_underflow
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetTurnDuelistVariable
	and DOUBLE_POISONED
	jr z, .not_poisoned
	ld c, 20
	and DOUBLE_POISONED & (POISONED ^ $ff)
	jr nz, .add_poison
	ld c, 10
.add_poison
	ld a, c
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
.not_poisoned
	call SwapTurn

.done
	pop hl
	ld [hl], e
	ld a, d
	or a
	ret z
	; cap damage
	ld a, $ff
	ld [hl], a
	ret
; 0x1450b

; stores in wDamage, wAIMinDamage and wAIMaxDamage the calculated damage
; done to the Pokémon at hTempPlayAreaLocation_ff9d
; by the defending Pokémon, using the move index at a
; input:
; 	a = move index
;	hTempPlayAreaLocation_ff9d = location of card to calculate
;								 damage as the receiver
CalculateMoveDamage_FromDefendingPokemon: ; 1450b (5:450b)
	call SwapTurn
	ld [wSelectedMoveIndex], a
	ld e, a
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	ld d, a
	call CopyMoveDataAndDamage_FromDeckIndex
	call SwapTurn
	ld a, [wLoadedMoveCategory]
	cp POKEMON_POWER
	jr nz, .is_move

; is a Pokémon Power
; set wDamage, wAIMinDamage and wAIMaxDamage to zero
	ld hl, wDamage
	xor a
	ld [hli], a
	ld [hl], a
	ld [wAIMinDamage], a
	ld [wAIMaxDamage], a
	ld e, a
	ld d, a
	ret

.is_move
; set wAIMinDamage and wAIMaxDamage to damage of move
	ld a, [wDamage]
	ld [wAIMinDamage], a
	ld [wAIMaxDamage], a
	call SwapTurn
	ldh a, [hTempPlayAreaLocation_ff9d]
	push af
	xor a
	ldh [hTempPlayAreaLocation_ff9d], a
	ld a, EFFECTCMDTYPE_AI
	call TryExecuteEffectCommandFunction
	pop af
	ldh [hTempPlayAreaLocation_ff9d], a
	call SwapTurn
	ld a, [wAIMinDamage]
	ld hl, wAIMaxDamage
	or [hl]
	jr nz, .calculation
	ld a, [wDamage]
	ld [wAIMinDamage], a
	ld [wAIMaxDamage], a

.calculation
; if temp. location is active, damage calculation can be done directly...
	ldh a, [hTempPlayAreaLocation_ff9d]
	or a
	jr z, CalculateDamage_FromDefendingPokemon

; ...otherwise substatuses need to be temporarily reset to account
; for the switching, to obtain the right damage calculation...
	ld a, DUELVARS_ARENA_CARD_SUBSTATUS1
	call GetTurnDuelistVariable
	push af
	push hl
	ld [hl], $00
	; reset substatus2
	ld l, DUELVARS_ARENA_CARD_SUBSTATUS2
	ld a, [hl]
	push af
	push hl
	ld [hl], $00
	; reset changed resistance
	ld l, DUELVARS_ARENA_CARD_CHANGED_RESISTANCE
	ld a, [hl]
	push af
	push hl
	ld [hl], $00
	call CalculateDamage_FromDefendingPokemon
; ...and subsequently recovered to continue the battle normally
	pop hl
	pop af
	ld [hl], a
	pop hl
	pop af
	ld [hl], a
	pop hl
	pop af
	ld [hl], a
	ret

; similar to CalculateDamage_VersusDefendingPokemon but reversed,
; calculating damage of the defending Pokémon versus
; the card located in hTempPlayAreaLocation_ff9d
; taking into account weakness/resistance/pluspowers/defenders/etc
; and poison damage for two turns
; and outputs the result capped at a max of $ff
; input:
; 	[wAIMinDamage] = base damage
; 	[wAIMaxDamage] = base damage
; 	[wDamage]      = base damage
;	hTempPlayAreaLocation_ff9d = location of card to calculate
;								 damage as the receiver
CalculateDamage_FromDefendingPokemon: ; 1458c (5:458c)
	ld hl, wAIMinDamage
	call _CalculateDamage_FromDefendingPokemon
	ld hl, wAIMaxDamage
	call _CalculateDamage_FromDefendingPokemon
	ld hl, wDamage
;	fallthrough

_CalculateDamage_FromDefendingPokemon: ; 1459b (5:459b)
	ld e, [hl]
	ld d, $00
	push hl

	; load player active card's data
	call SwapTurn
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2ID]
	ld [wTempTurnDuelistCardID], a
	call SwapTurn

	; load opponent's card data
	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2ID]
	ld [wTempNonTurnDuelistCardID], a

	call SwapTurn
	call HandleDoubleDamageSubstatus
	bit 7, d
	res 7, d
	jr nz, .not_resistant

; handle weakness
	call GetArenaCardColor
	call TranslateColorToWR
	ld b, a
	call SwapTurn
	ldh a, [hTempPlayAreaLocation_ff9d]
	or a
	jr nz, .bench_weak
	ld a, DUELVARS_ARENA_CARD_CHANGED_WEAKNESS
	call GetTurnDuelistVariable
	or a
	jr nz, .unchanged_weak

.bench_weak
	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Weakness]
.unchanged_weak
	and b
	jr z, .not_weak
	; double de
	sla e
	rl d

.not_weak
; handle resistance
	ldh a, [hTempPlayAreaLocation_ff9d]
	or a
	jr nz, .bench_res
	ld a, DUELVARS_ARENA_CARD_CHANGED_RESISTANCE
	call GetTurnDuelistVariable
	or a
	jr nz, .unchanged_res

.bench_res
	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Resistance]
.unchanged_res
	and b
	jr z, .not_resistant
	ld hl, -30
	add hl, de
	ld e, l
	ld d, h

.not_resistant
	; apply pluspower and defender boosts
	call SwapTurn
	ld b, CARD_LOCATION_ARENA
	call ApplyAttachedPluspower
	call SwapTurn
	ldh a, [hTempPlayAreaLocation_ff9d]
	add CARD_LOCATION_ARENA
	ld b, a
	call ApplyAttachedDefender
	ldh a, [hTempPlayAreaLocation_ff9d]
	or a
	call z, HandleDamageReduction
	bit 7, d
	jr z, .no_underflow
	ld de, $0

.no_underflow
	ldh a, [hTempPlayAreaLocation_ff9d]
	or a
	jr nz, .done
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetTurnDuelistVariable
	and DOUBLE_POISONED
	jr z, .done
	ld c, 40
	and DOUBLE_POISONED & (POISONED ^ $ff)
	jr nz, .add_poison
	ld c, 20
.add_poison
	ld a, c
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a

.done
	pop hl
	ld [hl], e
	ld a, d
	or a
	ret z
	ld a, $ff
	ld [hl], a
	ret
; 0x14663

Func_14663: ; 14663 (5:4663)
	farcall Func_200e5
	ret

; GENERAL DECK POINTER LIST - Not sure on all of these.
; This is an example of an AI pointer table, there's one for each AI type.
PointerTable_14668: ; 14668 (05:4668)
	dw Func_14674 ; not used
	dw Func_14674 ; general AI for battles
	dw Func_14678 ; basic pokemon placement / cheater shuffling on better AI
	dw Func_1467f
	dw Func_14683
	dw Func_14687

; when battle AI gets called
Func_14674: ; 14674 (5:4674)
	call Func_1468b
	ret

Func_14678: ; 14678 (5:4678)
	call Func_15636
	call $4226
	ret

Func_1467f: ; 1467f (5:467f)
	call $5b72
	ret

Func_14683: ; 14683 (5:4683)
	call $5b72
	ret

Func_14687: ; 14687 (5:4687)
	call $41e5
	ret

; AI for general decks i think
Func_1468b: ; 1468b (5:468b)
	call Func_15649
	ld a, $1
	call Func_14663
	farcall $8, $67d3
	jp nc, $4776
	farcall $8, $6790
	farcall $8, $66a3
	farcall $8, $637f
	ret c
	farcall $8, $662d
	ld a, $2
	call Func_14663
	ld a, $3
	call Func_14663
	ld a, $4
	call Func_14663
	call $5eae
	ret c
	ld a, $5
	call Func_14663
	ld a, $6
	call Func_14663
	ld a, $7
	call Func_14663
	ld a, $8
	call Func_14663
	call $4786
	ld a, $a
	call Func_14663
	ld a, $b
	call Func_14663
	ld a, $c
	call Func_14663
	ld a, [wAlreadyPlayedEnergy]
	or a
	jr nz, .asm_146ed
	call $64e8

.asm_146ed
	call $5eae
	farcall $8, $66a3
	farcall $8, $637f
	ret c
	farcall $8, $6790
	ld a, $d
	farcall $8, $619b
	ld a, $d
	call Func_14663
	ld a, $f
	call Func_14663
	ld a, [wce20]
	and $4
	jr z, .asm_14776
	ld a, $1
	call Func_14663
	ld a, $2
	call Func_14663
	ld a, $3
	call Func_14663
	ld a, $4
	call Func_14663
	call $5eae
	ret c
	ld a, $5
	call Func_14663
	ld a, $6
	call Func_14663
	ld a, $7
	call Func_14663
	ld a, $8
	call Func_14663
	call $4786
	ld a, $a
	call Func_14663
	ld a, $b
	call Func_14663
	ld a, $c
	call Func_14663
	ld a, [wAlreadyPlayedEnergy]
	or a
	jr nz, .asm_1475b
	call $64e8

.asm_1475b
	call $5eae
	farcall $8, $66a3
	farcall $8, $637f
	ret c
	farcall $8, $6790
	ld a, $d
	farcall $8, $619b
	ld a, $d
	call Func_14663

.asm_14776
	ld a, $e
	farcall $8, $619b
	call $69f8
	ret c
	ld a, $5
	bank1call AIMakeDecision
	ret
; 0x14786

	INCROM $14786, $1514f

; these seem to be lists of card IDs
; for the AI to look up in their hand
Data_1514f: ; 1514f (5:514f)
	db KANGASKHAN
	db CHANSEY
	db SNORLAX
	db MR_MIME
	db ABRA
	db $00

	db ABRA
	db MR_MIME
	db KANGASKHAN
	db SNORLAX
	db CHANSEY
	db $00

	INCROM $1515b, $155d2

; return carry if card ID loaded in a is found in hand
; and outputs in a the deck index of that card
; input:
;	a = card ID
; output:
; 	a = card deck index, if found
;	c set if found
LookForCardInHand: ; 155d2 (5:55d2)
	ld [wTempCardIDToLook], a
	call CreateHandCardList
	ld hl, wDuelTempList

.loop
	ld a, [hli]
	cp $ff
	ret z
	ldh [hTempCardIndex_ff98], a
	call LoadCardDataToBuffer1_FromDeckIndex
	ld b, a
	ld a, [wTempCardIDToLook]
	cp b
	jr nz, .loop

	ldh a, [hTempCardIndex_ff98]
	scf
	ret
; 0x155ef

Func_155ef: ; 155ef (5:55d2)
	INCROM $155ef, $15636

Func_15636: ; 15636 (5:5636)
	ld a, $10
	ld hl, wcda5
	call ZeroData
	ld a, $5
	ld [wcda6], a
	ld a, $ff
	ld [wcda5], a
	ret

Func_15649: ; 15649 (5:5649)
	ld a, [wcda6]
	inc a
	ld [wcda6], a
	xor a
	ld [wce20], a
	ld [wcddb], a
	ld [wcddc], a
	ld [wce03], a
	ld a, [wPlayerAttackingMoveIndex]
	cp $ff
	jr z, .asm_156b1
	or a
	jr z, .asm_156b1
	ld a, [wPlayerAttackingCardIndex]
	cp $ff
	jr z, .asm_156b1
	call SwapTurn
	call GetCardIDFromDeckIndex
	call SwapTurn
	ld a, e
	cp MEWTWO1 ; I believe this is a check for Mewtwo1's Barrier move
	jr nz, .asm_156b1
	ld a, [wcda7]
	bit 7, a
	jr nz, .asm_156aa
	inc a
	ld [wcda7], a
	cp $3
	jr c, .asm_156c2
	ld a, DUELVARS_ARENA_CARD
	call GetNonTurnDuelistVariable
	call SwapTurn
	call GetCardIDFromDeckIndex
	call SwapTurn
	ld a, e
	cp MEWTWO1
	jr nz, .asm_156a4
	farcall $8, $67a9
	jr nc, .asm_156aa

.asm_156a4
	xor a
	ld [wcda7], a
	jr .asm_156c2

.asm_156aa
	ld a, $80
	ld [wcda7], a
	jr .asm_156c2

.asm_156b1
	ld a, [wcda7]
	bit 7, a
	jr z, .asm_156be
	inc a
	ld [wcda7], a
	jr .asm_156c2

.asm_156be
	xor a
	ld [wcda7], a

.asm_156c2
	ret
; 0x156c3

	INCROM $156c3, $1575e

; zeroes a bytes starting at hl
ZeroData: ; 1575e (5:575e)
	push af
	push bc
	push hl
	ld b, a
	xor a
.clear_loop
	ld [hli], a
	dec b
	jr nz, .clear_loop
	pop hl
	pop bc
	pop af
	ret
; 0x1576b

	INCROM $1576b, $158b2

Func_158b2: ; 158b2 (5:58b2)
	ld a, [wGotHeadsFromConfusionCheckDuringRetreat]
	or a
	jp nz, .asm_15b2f
	xor a
	ld [$cdd7], a
	call StoreDefendingPokemonColorWRAndPrizeCards
	ld a, $80
	ld [wcdbe], a
	ld a, [$cdb4]
	or a
	jr z, .check_status
	srl a
	srl a
	sla a
	call AddToWcdbe

.check_status
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetTurnDuelistVariable
	or a
	jr z, .asm_158f1 ; no status
	and DOUBLE_POISONED
	jr z, .asm_158e5 ; no poison
	ld a, $02
	call AddToWcdbe

.asm_158e5
	ld a, [hl]
	and $0f
	cp $01
	jr nz, .asm_158f1
	ld a, $01
	call AddToWcdbe

.asm_158f1
	xor a
	ldh [hTempPlayAreaLocation_ff9d], a
	call CheckIfAnyMoveKnocksOutDefendingCard
	jr nc, .active_cant_knock_out
	call CheckIfCardCanUseSelectedMove
	jp nc, .active_cant_use_move
	call LookForEnergyNeededInHand
	jr nc, .active_cant_knock_out

.active_cant_use_move
	ld a, $05
	call SubFromWcdbe
	ld a, [wAIOpponentPrizeCount]
	cp 2
	jr nc, .active_cant_knock_out
	ld a, $23
	call SubFromWcdbe
	
.active_cant_knock_out
	call Func_173b1
	jr nc, .asm_15930
	ld a, $02
	call AddToWcdbe
	call Func_17426
	jr c, .asm_1594d
	ld a, [wAIPlayerPrizeCount]
	cp 2
	jr nc, .asm_15941
	ld a, $01
	ld [$cdd7], a
.asm_15930
	call Func_17426
	jr c, .asm_1594d
	ld a, [wAIPlayerPrizeCount]
	cp 2
	jr nc, .asm_15941
	ld a, $02
	call AddToWcdbe
.asm_15941
	ld a, [wAIOpponentPrizeCount]
	cp 2
	jr nc, .asm_1594d
	ld a, $02
	call SubFromWcdbe
.asm_1594d
	call GetArenaCardColor
	call TranslateColorToWR
	ld b, a
	ld a, [wAIPlayerResistance]
	and b
	jr z, .asm_15980
	ld a, $01
	call AddToWcdbe
	ld a, [wAIPlayerResistance]
	ld b, a
	ld a, DUELVARS_BENCH
	call GetTurnDuelistVariable
.asm_15968
	ld a, [hli]
	cp $ff
	jr z, .asm_1597b
	call LoadCardDataToBuffer1_FromDeckIndex
	ld a, [wLoadedCard1Type]
	call TranslateColorToWR
	and b
	jr nz, .asm_15968
	jr .asm_15980
.asm_1597b
	ld a, $02
	call SubFromWcdbe
.asm_15980
	ld a, [wAIPlayerColor]
	ld b, a
	call GetArenaCardWeakness
	and b
	jr z, .asm_159ad
	ld a, $02
	call AddToWcdbe
	ld a, [wAIPlayerColor]
	ld b, a
	ld a, DUELVARS_BENCH
	call GetTurnDuelistVariable
.asm_15998
	ld a, [hli]
	cp $ff
	jr z, .asm_159a8
	call LoadCardDataToBuffer1_FromDeckIndex
	ld a, [wLoadedCard1Weakness]
	and b
	jr nz, .asm_15998
	jr .asm_159ad
.asm_159a8
	ld a, $03
	call SubFromWcdbe
.asm_159ad
	ld a, [wAIPlayerColor]
	ld b, a
	call GetArenaCardResistance
	and b
	jr z, .asm_159bc
	ld a, $03
	call SubFromWcdbe
.asm_159bc
	ld a, [wAIPlayerWeakness]
	ld b, a
	ld a, DUELVARS_BENCH
	call GetTurnDuelistVariable
	ld e, $00
.asm_159c7
	inc e
	ld a, [hli]
	cp $ff
	jr z, .asm_15a0e
	push de
	call LoadCardDataToBuffer1_FromDeckIndex
	ld a, [wLoadedCard1Type]
	call TranslateColorToWR
	pop de
	and b
	jr z, .asm_159c7
	ld a, $02
	call AddToWcdbe
	push de
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call GetCardIDFromDeckIndex
	ld a, e
	pop de
	cp PORYGON
	jr nz, .asm_159fc
	ld a, e
	call Func_17383
	jr nc, .asm_159fc
	ld a, $0a
	call AddToWcdbe
	jr .asm_15a0e
.asm_159fc
	call GetArenaCardColor
	call TranslateColorToWR
	ld b, a
	ld a, [wAIPlayerWeakness]
	and b
	jr z, .asm_15a0e
	ld a, $03
	call SubFromWcdbe

.asm_15a0e
	ld a, [wAIPlayerColor]
	ld b, a
	ld a, DUELVARS_BENCH
	call GetTurnDuelistVariable
.asm_15a17
	ld a, [hli]
	cp $ff
	jr z, .asm_15a2a
	call LoadCardDataToBuffer1_FromDeckIndex
	ld a, [wLoadedCard1Resistance]
	and b
	jr z, .asm_15a17
	ld a, $01
	call AddToWcdbe

.asm_15a2a
	ld a, DUELVARS_BENCH
	call GetTurnDuelistVariable
	ld c, $00
.asm_15a31
	inc c
	ld a, [hli]
	cp $ff
	jr z, .asm_15a7a
	ld a, c
	ldh [hTempPlayAreaLocation_ff9d], a
	push hl
	push bc
	call CheckIfAnyMoveKnocksOutDefendingCard
	jr nc, .asm_15a4b
	call CheckIfCardCanUseSelectedMove
	jr nc, .asm_15a4f
	call LookForEnergyNeededInHand
	jr c, .asm_15a4f
.asm_15a4b
	pop bc
	pop hl
	jr .asm_15a31
.asm_15a4f
	pop bc
	pop hl
	ld a, $02
	call AddToWcdbe
	ld a, [wAIOpponentPrizeCount]
	cp 2
	jr nc, .asm_15a7a
	call Func_17426
	jr c, .asm_15a7a
	xor a
	ldh [hTempPlayAreaLocation_ff9d], a
	call CheckIfAnyMoveKnocksOutDefendingCard
	jr nc, .asm_15a70
	call CheckIfCardCanUseSelectedMove
	jp nc, .asm_15a7a
.asm_15a70
	ld a, $28
	call AddToWcdbe
	ld a, $01
	ld [$cdd7], a
.asm_15a7a
	ld a, DUELVARS_ARENA_CARD
	call GetNonTurnDuelistVariable
	call SwapTurn
	call GetCardIDFromDeckIndex
	call SwapTurn
	ld a, e
	cp MR_MIME
	jr z, .asm_15a91
	cp HITMONLEE
	jr nz, .asm_15abc
.asm_15a91
	xor a
	call Func_17383
	jr c, .asm_15abc
	ld a, DUELVARS_BENCH
	call GetTurnDuelistVariable
	ld c, $00
.asm_15a9e
	inc c
	ld a, [hli]
	cp $ff
	jr z, .asm_15abc
	ld a, c
	push hl
	push bc
	call Func_17383
	jr c, .asm_15ab0
	pop bc
	pop hl
	jr .asm_15a9e
.asm_15ab0
	pop bc
	pop hl
	ld a, $05
	call AddToWcdbe
	ld a, $01
	ld [$cdd7], a
.asm_15abc
	xor a
	ldh [hTempPlayAreaLocation_ff9d], a
	call GetPlayAreaCardRetreatCost
	cp 2
	jr c, .asm_15ad6
	cp 3
	jr nc, .asm_15ad1
	ld a, $01
	call SubFromWcdbe
	jr .asm_15ad6
.asm_15ad1
	ld a, $02
	call SubFromWcdbe
.asm_15ad6
	call Func_170c9
	jr c, .asm_15ae5
	call Func_17101
	cp $02
	jr c, .asm_15ae5
	call AddToWcdbe
.asm_15ae5
	ld a, DUELVARS_BENCH
	call GetTurnDuelistVariable
	ld e, $00
.asm_15aec
	inc e
	ld a, [hli]
	cp $ff
	jr z, .asm_15b12
	push de
	push hl
	call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2ID]
	pop hl
	pop de
	cp MYSTERIOUS_FOSSIL
	jr z, .asm_15aec
	cp CLEFAIRY_DOLL
	jr z, .asm_15aec
	ld a, e
	ldh [hTempPlayAreaLocation_ff9d], a
	push de
	push hl
	call Func_173b1
	pop hl
	pop de
	jr c, .asm_15aec
	jr .asm_15b17
.asm_15b12
	ld a, $14
	call SubFromWcdbe
.asm_15b17
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call GetCardIDFromDeckIndex
	ld a, e
	cp MYSTERIOUS_FOSSIL
	jr z, .asm_15b33
	cp CLEFAIRY_DOLL
	jr z, .asm_15b33
	ld a, [wcdbe]
	cp $83
	jr nc, .asm_15b31
.asm_15b2f
	or a
	ret
.asm_15b31
	scf
	ret
.asm_15b33
	ld e, $00
.asm_15b35
	inc e
	ld a, e
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	cp $ff
	jr z, .asm_15b2f
	ld a, e
	ldh [hTempPlayAreaLocation_ff9d], a
	push de
	call Func_173b1
	pop de
	jr c, .asm_15b35
	ld a, e
	push de
	call Func_17383
	pop de
	jr nc, .asm_15b35
	jr .asm_15b31
; 0x15b54

	INCROM $15b54, $15b72

Func_15b72 ; 15b72 (5:5b72)
	INCROM $15b72, $15d4f

Func_15d4f ; 15d4f (5:5d4f)
	INCROM $15d4f, $15ea6

; Copy cards from wDuelTempList to wHandTempList
CopyHandCardList: ; 15ea6 (5:5ea6)
	ld a, [hli]
	ld [de], a
	cp $ff
	ret z
	inc de
	jr CopyHandCardList

Func_15eae: ; 15eae (5:5eae)
	call CreateHandCardList
	call SortTempHandByIDList
	ld hl, wDuelTempList
	ld de, wHandTempList
	call CopyHandCardList
	ld hl, wHandTempList

.next_card
	ld a, [hli]
	cp $ff
	jp z, Func_15f4c

	ld [wcdf3], a
	push hl
	call LoadCardDataToBuffer1_FromDeckIndex
	ld a, [wLoadedCard1Type]
	cp TYPE_ENERGY
	jr nc, .skip
	; skip non-pokemon cards

	ld a, [wLoadedCard1Stage]
	or a
	jr nz, .skip
	; skip non-basic pokemon

	ld a, $82
	ld [wcdbe], a
	call Func_161d5
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	cp $04
	jr c, .asm_15ef2
	ld a, $14
	call SubFromWcdbe
	jr .asm_15ef7
.asm_15ef2
	ld a, $32
	call AddToWcdbe
.asm_15ef7
	xor a
	ldh [hTempPlayAreaLocation_ff9d], a
	call Func_173b1
	jr nc, .asm_15f04
	ld a, $14
	call AddToWcdbe
.asm_15f04
	ld a, [wcdf3]
	call Func_163c9
	call Func_1637b
	jr nc, .asm_15f14
	ld a, $14
	call AddToWcdbe
.asm_15f14
	ld a, [wcdf3]
	call Func_16422
	jr nc, .asm_15f21
	ld a, $14
	call AddToWcdbe
.asm_15f21
	ld a, [wcdf3]
	call Func_16451
	jr nc, .asm_15f2e
	ld a, $0a
	call AddToWcdbe
.asm_15f2e
	ld a, [wcdbe]
	cp $b4
	jr c, .skip
	ld a, [wcdf3]
	ldh [hTemp_ffa0], a
	call Func_1433d
	jr c, .skip
	ld a, $01
	bank1call AIMakeDecision
	jr c, .done
.skip
	pop hl
	jp .next_card
.done
	pop hl
	ret

Func_15f4c ; 15f4c (5:5f4c)
	INCROM $15f4c, $161d5

Func_161d5: ; 161d5 (5:61d5)
; check if deck applies
	ld a, [wOpponentDeckID]
	cp LEGENDARY_ZAPDOS_DECK_ID
	jr z, .begin
	cp LEGENDARY_ARTICUNO_DECK_ID
	jr z, .begin
	cp LEGENDARY_RONALD_DECK_ID
	jr z, .begin
	ret

; check if card applies
.begin
	ld a, [wLoadedCard1ID]
	cp ARTICUNO2
	jr z, .articuno
	cp MOLTRES2
	jr z, .moltres
	cp ZAPDOS3
	jr z, .zapdos
	ret

.articuno
	; exit if not enough Pokemon in Play Area
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	cp 2
	ret c

	call CheckIfCardCanKnockOutAndUseSelectedMove
	jr c, .asm_16258
	call CheckIfActivePokemonCanUseAnyNonResidualMove
	jr nc, .asm_16258
	call Func_158b2
	jr c, .asm_16258
	
	; checks for player's active card status
	ld a, DUELVARS_ARENA_CARD_STATUS
	call GetNonTurnDuelistVariable
	and CNF_SLP_PRZ
	or a
	jr nz, .asm_16258

	; checks for player's Pokemon Power
	call SwapTurn
	ld a, DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	ld d, a
	ld e, $00
	call CopyMoveDataAndDamage_FromDeckIndex
	call SwapTurn
	ld a, [wLoadedMoveCategory]
	cp POKEMON_POWER
	jr z, .check_muk_and_snorlax

	; return if no space on the bench
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	call GetTurnDuelistVariable
	cp MAX_BENCH_POKEMON
	jr c, .check_muk_and_snorlax
	ret

.check_muk_and_snorlax
	; checks for Muk in both Play Areas
	ld a, MUK
	call CountPokemonIDInBothPlayAreas
	jr c, .asm_16258
	; checks if player's active card is Snorlax
	ld a, DUELVARS_ARENA_CARD
	call GetNonTurnDuelistVariable
	call SwapTurn
	call GetCardIDFromDeckIndex
	call SwapTurn
	ld a, e
	cp SNORLAX
	jr z, .asm_16258

	ld a, $46
	call AddToWcdbe
	ret
.asm_16258
	ld a, $64
	call SubFromWcdbe
	ret

.moltres
	; checks if there's enough cards in deck
	ld a, DUELVARS_NUMBER_OF_CARDS_NOT_IN_DECK
	call GetTurnDuelistVariable
	cp $38 ; max number of cards not in deck to activate
	jr nc, .asm_16258
	ret

.zapdos
	; checks for Muk in both Play Areas
	ld a, MUK
	call CountPokemonIDInBothPlayAreas
	jr c, .asm_16258
	ret
; 0x16270

	INCROM $16270, $1628f

; returns carry if card at hTempPlayAreaLocation_ff9d
; can knock out defending Pokémon
; input:
; 	hTempPlayAreaLocation_ff9d = location of Pokémon card
;	wSelectedMoveIndex 		   = selected move to examine
CheckIfCardCanKnockOutAndUseSelectedMove: ; 1628f (5:628f)
	xor a
	ldh [hTempPlayAreaLocation_ff9d], a
	call CheckIfAnyMoveKnocksOutDefendingCard
	jr nc, .fail
	call CheckIfCardCanUseSelectedMove
	jp c, .fail
	scf
	ret
	
.fail
	or a
	ret
; 0x162a1

; outputs carry if any of the active Pokémon attacks
; can be used and are not residual
CheckIfActivePokemonCanUseAnyNonResidualMove: ; 162a1 (5:62a1)
; active card
	xor a
	ldh [hTempPlayAreaLocation_ff9d], a
; first move
	ld [wSelectedMoveIndex], a
	call CheckIfCardCanUseSelectedMove
	jr c, .next_move
	ld a, [wLoadedMoveCategory]
	and RESIDUAL
	jr z, .ok

.next_move
; second move
	ld a, $01
	ld [wSelectedMoveIndex], a
	call CheckIfCardCanUseSelectedMove
	jr c, .fail
	ld a, [wLoadedMoveCategory]
	and RESIDUAL
	jr z, .ok
.fail
	or a
	ret

.ok
	scf
	ret
; 0x162c8

	INCROM $162c8, $16311

; looks for energy card(s) in hand depending on what is needed
; 	- if one basic energy is required, look for that energy;
;	- if one colorless is required, create a list at wDuelTempList
;	  of all energy cards;
;	- if two colorless are required, look for double colorless;
; return carry if successful in finding card
LookForEnergyNeededInHand: ; 16311 (5:6311)
	call CheckEnergyNeededForAttack
	ld a, b
	add c
	cp 1
	jr z, .one_energy
	cp 2
	jr nz, .done
	ld a, c
	cp 2
	jr z, .two_colorless
.done
	or a
	ret

.one_energy
	ld a, b
	or a
	jr z, .one_colorless
	ld a, e
	call LookForCardInHand
	ret c
	jr .done

.one_colorless
	call CreateEnergyCardListFromHand
	jr c, .done
	scf
	ret

.two_colorless
	ld a, DOUBLE_COLORLESS_ENERGY
	call LookForCardInHand
	ret c
	jr .done
; 0x1633f

; goes through $00 terminated list pointed 
; by wcdae and compares it to each card in hand.
; Sorts the hand in wDuelTempList so that the found card IDs
; are in the same order as the list pointed by de.
SortTempHandByIDList: ; 1633f (5:633f)
	ld a, [wcdae+1]
	or a
	ret z

; start going down the ID list
	ld d, a
	ld a, [wcdae]
	ld e, a
	ld c, 0
.next_list_id
; get this item's ID
; if $00, list has ended
	ld a, [de]
	or a
	ret z
	inc de
	ld hl, wDuelTempList
	ld b, 0
	add hl, bc
	ld b, a

; search in the hand card list
.next_hand_card
	ld a, [hl]
	ldh [hTempCardIndex_ff98], a
	cp -1
	jr z, .next_list_id
	push bc
	push de
	call GetCardIDFromDeckIndex
	ld a, e
	pop de
	pop bc
	cp b
	jr nz, .not_same

; found
; swap this hand card with the spot
; in hand corresponding to c
	push bc
	push hl
	ld b, 0
	ld hl, wDuelTempList
	add hl, bc
	ld b, [hl]
	ldh a, [hTempCardIndex_ff98]
	ld [hl], a
	pop hl
	ld [hl], b
	pop bc
	inc c
.not_same
	inc hl
	jr .next_hand_card
; 0x1637b

Func_1637b ; 1637b (5:637b)
	INCROM $1637b, $163c9

Func_163c9 ; 163c9 (5:63c9)
	INCROM $163c9, $16422

Func_16422 ; 16422 (5:6422)
	INCROM $16422, $16451

Func_16451 ; 16451 (5:6451)
	INCROM $16451, $164e8

Func_164e8 ; 164e8 (5:64e8)
	INCROM $164e8, $169f8

Func_169f8 ; 169f8 (5:69f8)
	INCROM $169f8, $170c9

Func_170c9 ; 170c9 (5:70c9)
	INCROM $170c9, $17101

Func_17101 ; 17101 (5:7101)
	INCROM $17101, $17383

Func_17383 ; 17383 (5:7383)
	INCROM $17383, $173b1

Func_173b1: ; 173b1 (5:73b1)
	xor a
	ld [$ce00], a
	ld [$ce01], a
	call Func_173e4
	jr nc, .asm_173c3
	ld a, [wDamage]
	ld [$ce00], a
.asm_173c3
	ld a, $01
	call Func_173e4
	jr nc, .asm_173d2
	ld a, [wDamage]
	ld [$ce01], a
	jr .asm_173d7
.asm_173d2
	ld a, [$ce00]
	or a
	ret z
.asm_173d7
	ld a, [$ce00]
	ld b, a
	ld a, [$ce01]
	cp b
	jr nc, .asm_173e2
	ld a, b
.asm_173e2
	scf
	ret
; 0x173e4

; input:
;	a = move index
Func_173e4: ; 173e4 (5:73e4)
	ld [wSelectedMoveIndex], a
	ldh a, [hTempPlayAreaLocation_ff9d]
	push af
	xor a
	ldh [hTempPlayAreaLocation_ff9d], a
	call SwapTurn
	call CheckIfCardCanUseSelectedMove
	call SwapTurn
	pop bc
	ld a, b
	ldh [hTempPlayAreaLocation_ff9d], a
	jr c, .done

; player's active Pokémon can use move
	ld a, [wSelectedMoveIndex]
	call CalculateMoveDamage_FromDefendingPokemon
	ldh a, [hTempPlayAreaLocation_ff9d]
	add DUELVARS_ARENA_CARD_HP
	call GetTurnDuelistVariable
	ld hl, wDamage
	sub [hl]
	jr z, .set_carry
	ret

.set_carry
	scf
	ret

.done
	or a
	ret
; 0x17414

Func_17414 ; 17414 (5:7414)
	INCROM $17414, $17426

Func_17426 ; 17426 (5:7426)
	INCROM $17426, $18000