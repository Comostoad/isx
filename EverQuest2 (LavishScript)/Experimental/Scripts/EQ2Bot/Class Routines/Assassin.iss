;*****************************************************
;Assassin.iss  20070404a
;by Pygar
;
; 20070404a
; Updated for latest eq2bot functionality
; Added Poison Usage - Must edit iss file for names if you want to use other then enfeebling, caustic, and turgur
; Fixed Mastery Usage
; Fixed charging to pulls
; Fixed issue with haveaggro
;
; 20061229a
; Added Toggle for using range attacks
; Moved makeshift to normal CA as it has min range of 0
; Added AA support
; Added Offhand and WeaponSpear support for AA and gear swap
; Needs ammo check for ranged?
;
; 20061229b
; Fixed some bad isready calls
;
; 20061229c
; Added missing weaponchange function
;
; 20061229d
; Removed a few calls that were causing an IS crash bug.  Lax looking into it
;
;*****************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	declare DebuffMode bool script 0
	declare AoEMode bool script 0
	declare UseRangeMode bool script 0
	declare SurroundingAttacksMode bool Script FALSE

	;Custom Equipment
	declare WeaponRapier string script
	declare WeaponSword string script
	declare WeaponDagger string script
	declare PoisonCureItem string script
	declare WeaponMain string script
	declare BuffShadowsGroupMember string script
	declare BuffPoisonGroupMember string script

	declare EquipmentChangeTimer int script

	call EQ2BotLib_Init

	DebuffMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	UseRangeMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Range Arts,FALSE]}]
	BuffShadowsGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffShadowsGroupMember,]}]
	BuffPoisonGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffPoisonGroupMember,]}]
	SurroundingAttacksMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff Surrounding Attacks,FALSE]}]

	WeaponMain:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["MainWeapon",""]}]
	OffHand:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OffHand,]}]
	WeaponRapier:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Rapier",""]}]
	WeaponSword:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Sword",""]}]
	WeaponDagger:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Dagger",""]}]
	WeaponSpear:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["Spear",""]}]

	;POISON DECLERATIONS - Still Experimental, but is working for these 3 for me.
	;EDIT THESE VALUES FOR THE POISONS YOU WISH TO USE
	;The SHORT name is the name of the poison buff icon
	DammagePoisonShort:Set[caustic poison]
	DebuffPoisonShort:Set[enfeebling poison]
	UtilityPoisonShort:Set[ignorant bliss]

}

function Buff_Init()
{
	PreAction[1]:Set[Villany]
	PreSpellRange[1,1]:Set[25]

	PreAction[2]:Set[Focus]
	PreSpellRange[2,1]:Set[27]

	PreAction[3]:Set[Pathfinding]
	PreSpellRange[3,1]:Set[302]

	PreAction[4]:Set[Apply_Poison]
	PreSpellRange[4,1]:Set[387]

	PreAction[5]:Set[Shadows]
	PreSpellRange[5,1]:Set[386]

	PreAction[6]:Set[AA_Neurotoxic_Coating]
	PreSpellRange[6,1]:Set[409]

	PreAction[7]:Set[AA_Surrounding_Attacks]
	PreSpellRange[7,1]:Set[404]

	PreAction[8]:Set[Poisons]

}

function Combat_Init()
{

	Action[1]:Set[Debuff]
	MobHealth[1,1]:Set[20]
	MobHealth[1,2]:Set[100]
	Power[1,1]:Set[20]
	Power[1,2]:Set[100]
	SpellRange[1,1]:Set[50]
	SpellRange[1,2]:Set[51]
	SpellRange[1,3]:Set[52]

	Action[2]:Set[Melee_Attack]
	SpellRange[2,1]:Set[150]

	Action[3]:Set[DoT]
	MobHealth[3,1]:Set[20]
	MobHealth[3,2]:Set[100]
	Power[3,1]:Set[20]
	Power[3,2]:Set[100]
	SpellRange[3,1]:Set[71]
	SpellRange[3,2]:Set[70]

	Action[4]:Set[Concealment]
	MobHealth[4,1]:Set[20]
	MobHealth[4,2]:Set[100]
	SpellRange[4,1]:Set[389]
	SpellRange[4,2]:Set[130]
	SpellRange[4,3]:Set[131]
	SpellRange[4,4]:Set[132]
	SpellRange[4,5]:Set[133]
	SpellRange[4,6]:Set[135]
	SpellRange[4,7]:Set[96]
	SpellRange[4,8]:Set[95]

	Action[5]:Set[Mastery]

	Action[6]:Set[Finishing_Blow]
	SpellRange[6,1]:Set[390]

	Action[7]:Set[Vanish]
	MobHealth[7,1]:Set[20]
	MobHealth[7,2]:Set[100]
	SpellRange[7,1]:Set[389]
	SpellRange[7,2]:Set[130]
	SpellRange[7,3]:Set[131]
	SpellRange[7,4]:Set[132]
	SpellRange[7,5]:Set[133]
	SpellRange[7,6]:Set[135]
	SpellRange[7,7]:Set[96]
	SpellRange[7,8]:Set[95]

	Action[8]:Set[Shrouded_Attack]
	SpellRange[8,1]:Set[186]

	Action[9]:Set[Cripple]
	SpellRange[9,1]:Set[110]

	Action[10]:Set[Combat_Buff]
	MobHealth[10,1]:Set[50]
	MobHealth[10,2]:Set[100]
	SpellRange[10,1]:Set[155]

	Action[11]:Set[Stalk]
	SpellRange[11,1]:Set[185]

	Action[12]:Set[Makeshift]
	SpellRange[12,1]:Set[250]
	SpellRange[12,2]:Set[402]

	Action[13]:Set[Range_Rear]
	SpellRange[13,1]:Set[251]
	SpellRange[13,2]:Set[256]
	SpellRange[13,3]:Set[257]

	Action[14]:Set[Stun]
	SpellRange[14,1]:Set[190]

	Action[15]:Set[Evade]
	SpellRange[15,1]:Set[185]

	Action[16]:Set[AA_Bounty]
	SpellRange[16,1]:Set[400]

	Action[17]:Set[AA_Bladed_Opening]
	SpellRange[17,1]:Set[401]
	MobHealth[17,1]:Set[80]
	MobHealth[17,2]:Set[100]

	Action[18]:Set[AA_Spinning_Spear]
	SpellRange[18,1]:Set[403]

	Action[19]:Set[AA_Frontload]
	SpellRange[19,1]:Set[410]
	MobHealth[19,1]:Set[40]
	MobHealth[19,2]:Set[100]

	Action[20]:Set[AA_Intoxication]
	SpellRange[20,1]:Set[412]
}


function PostCombat_Init()
{
	PreAction[1]:Set[Slip]
	PreSpellRange[1,1]:Set[202]
}

function Buff_Routine(int xAction)
{
	declare BuffTarget string local
	call ActionChecks


	ExecuteAtom CheckStuck

	if ${AutoFollowMode}
	{
		ExecuteAtom AutoFollowTank
	}

	call WeaponChange

	switch ${PreAction[${xAction}]}
	{
		case AA_Neurotoxic_Coating
		case Pathfinding
		case Focus
		case Villany
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break

		case Apply_Poison
			BuffTarget:Set[${UIElement[cbBuffPoisonGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		case Shadows
			BuffTarget:Set[${UIElement[cbBuffShadowsGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break

		case AA_Surrounding_Attacks
			if ${SurroundingAttacksMode}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break

		case Poisons
			if ${MaintainPoison}
			{
				Me:CreateCustomInventoryArray[nonbankonly]
				if !${Me.Maintained[${DammagePoisonShort}](exists)} && ${Me.CustomInventory[${DammagePoisonShort}](exists)}
				{
					Me.CustomInventory[${DammagePoisonShort}]:Use
				}

				if !${Me.Maintained[${DebuffPoisonShort}](exists)} && ${Me.CustomInventory[${DebuffPoisonShort}](exists)}
				{
					Me.CustomInventory[${DebuffPoisonShort}]:Use
				}

				if !${Me.Maintained[${UtilityPoisonShort}](exists)} && ${Me.CustomInventory[${UtilityPoisonShort}](exists)}
				{
					Me.CustomInventory[${UtilityPoisonShort}]:Use
				}
			}
			break
		Default
			xAction:Set[20]
			break
	}

}

function Combat_Routine(int xAction)
{
;echo combat routine

	AutoFollowingMA:Set[FALSE]
	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
	}

	if ${Me.ToActor.IsStealthed}
	{
		call CastStealthAttack
	}

	;smokebomb check
	if ${Me.Ability[${SpellType[407]}].IsReady} && !${Me.ToActor.IsStealthed}
	{
		call CastSpellRange 407
		call CastStealthAttack
	}

	;Getaway check
	if ${Me.Ability[${SpellType[411]}].IsReady} && !${Me.ToActor.IsStealthed}
	{
		call CastSpellRange 411
		call CastStealthAttack
	}

	;Poison Combination Check disabled for now cause I can't seem to check if mob IsAfflicted by Noxious
	;if 1=0 && ${Me.Ability[${SpellType[408]}].IsReady}
	;{
	;	call CastSpellRange 408
	;}

	if !${EQ2.HOWindowActive} && ${Me.InCombat}
	{
		call CastSpellRange 303
	}

	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}

	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal[${WeaponMain}]}
	{
		Me.Inventory[${WeaponMain}]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}

	Call ActionChecks

	if ${Target.Target.ID}!=${Me.ID} && ${Target.Distance}<10
	{
		call GetBehind
	}


	switch ${Action[${xAction}]}
	{

		case Debuff
			if ${DebuffMode}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},3]} 0 0 ${KillTarget} 0 0 1
					}
				}
			}
			break

		case Makeshift
			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
			call CastSpellRange ${SpellRange[${xAction},2]} 0 0 0 ${KillTarget} 0 0 1
			break
		case AA_Intoxication
		case Evade
		case Stun
		case Cripple
		case Melee_Attack
			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
			break

		case DoT
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},2]} 0 0 ${KillTarget} 0 0 1
				}
			}
			break

		case Vanish
		case Concealment
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				if ${AoEMode} && ${Mob.Count}>=2
				{
					call CastSpellRange ${SpellRange[${xAction},7]} ${SpellRange[${xAction},8]} 0 0 ${KillTarget} 0 0 1
				}
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},6]} 0 0 ${KillTarget} 0 0 1
			}
			break

		case Stalk
		case Shrouded_Attack
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
			call CastStealthAttack
			break

		case Combat_Buff
			call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
			}
			break

		case Range_Rear
			call CastSpellRange ${SpellRange[151]} 0 0 0 ${KillTarget} 0 0 1
			if ${UseRangeMode}
			{
				if ${Actor[${KillTarget}].Distance}<5
					{
						press -hold ${backward}
						wait 2
						press -release ${backward}
					}
				if !${Actor[${KillTarget}].Distance}<5
				call CastSpellRange ${SpellRange[${xAction},1]} ${SpellRange[${xAction},3]} 0 0 ${KillTarget}
			}
			break

			case Mastery
				if !${MainTank} && ${Target.Target.ID}!=${Me.ID}
				{
					if ${Me.Ability[Sinister Strike].IsReady} && ${Actor[${KillTarget}](exists)}
					{
						Target ${KillTarget}
						call CheckPosition 1 1
						Me.Ability[Sinister Strike]:Use
					}
				}
			break

		case Bounty
			if ${Actor[${KillTarget}].ConColor} != 'Grey' && ${Actor[${KillTarget}].ConColor} != 'Green' && ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
			}
			break
		case AA_Bladed_Opening
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					if ${Me.Equipment[1].Name.Equal[${WeaponSword}]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
					}
					elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
					{
						Me.Inventory[${WeaponSword}]:Equip
						EquipmentChangeTimer:Set[${Time.Timestamp}]
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
					}
				}
			}
			break

		case AA_Spinning_Spear
			if ${AoEMode} && ${Mob.Count}>=2 && {Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				if ${Me.Equipment[1].Name.Equal[${WeaponSpear}]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}
				elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
				{
					Me.Inventory[${WeaponSpear}]:Equip
					EquipmentChangeTimer:Set[${Time.Timestamp}]
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}
			}
			break
		case AA_Frontload
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
				}
			}
			break
		default
			xAction:Set[20]
			break
	}
}

function Post_Combat_Routine()
{
	switch ${Action[${xAction}]}
	{
		case Slip
			if !${Me.ToActor.IsStealthed}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break
		default
			xAction:Set[20]
			break
	}
}

function Have_Aggro()
{

	echo I have agro from ${aggroid}

	;agro dump
	call CastSpellRange 180 0 1 0 ${aggroid}
	call CastSpellRange 185 0 1 0 ${aggroid}
}

function Lost_Aggro()
{

}

function MA_Lost_Aggro()
{
	wait 20
}

function MA_Dead()
{

}

function Cancel_Root()
{

}
function CheckHeals()
{

}

function CastStealthAttack()
{
	if ${Me.Ability[${SpellType[96]}].IsReady} && ${AoEMode} && ${Mob.Count}>=2
	{
		call CastSpellRange 96 0 0 0 ${KillTarget}
	}
	elseif ${Me.Ability[${SpellType[95]}].IsReady} && ${AoEMode} && ${Mob.Count}>=2
	{
		call CastSpellRange 95 0 0 0 ${KillTarget}
	}
	elseif ${Me.Ability[${SpellType[131]}].IsReady}
	{
		call CastSpellRange 131 0 0 0 ${KillTarget}
	}
	elseif ${Me.Ability[${SpellType[132]}].IsReady}
	{
		call CastSpellRange 132 0 0 0 ${KillTarget}
	}
	elseif ${Me.Ability[${SpellType[130]}].IsReady}
	{
		call CastSpellRange 130 0 0 0 ${KillTarget}
	}
	elseif ${Me.Ability[${SpellType[133]}].IsReady}
	{
		call CastSpellRange 133 0 0 0 ${KillTarget}
	}
	elseif ${Me.Ability[${SpellType[135]}].IsReady}
	{
		call CastSpellRange 135 0 0 0 ${KillTarget}
	}

}

function ActionChecks()
{

	if ${ShardMode}
	{
		call Shard
	}

}

function WeaponChange()
{

	;equip main hand
	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[1].Name.Equal[${WeaponMain}]}
	{
		Me.Inventory[${WeaponMain}]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}

	;equip off hand
	if ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2  && !${Me.Equipment[2].Name.Equal[${OffHand}]} && !${Me.Equipment[1].WieldStyle.Find[Two-Handed]}
	{
		Me.Inventory[${OffHand}]:Equip
		EquipmentChangeTimer:Set[${Time.Timestamp}]
	}

}

