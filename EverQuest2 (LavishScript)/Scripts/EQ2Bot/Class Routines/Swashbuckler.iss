;*****************************************************
;Swashbuckler.iss 20070822a
;by Pygar
;
;20070822a
; Removed Weapon Swaps
;20070725a
; Updated for new AA changes
;
;20070514a
;DPS Tuning
;
; 20070427a
; Fixed Hurricane Buffing
; Fixed some misplaced CastCaRange calls
;	Fixed spelling on Hurricane
; Cleanup on UI
;	Can no longer attempt to hate transfer to self.
;*****************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
  ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
  declare ClassFileVersion int script 20080408
  ;;;;

	declare OffenseMode bool script 1
	declare AoEMode bool script 0
	declare SnareMode bool script 0
  declare TankMode bool script 0
  declare AnnounceMode bool script 0
  declare BuffLunge bool script 0
	declare MaintainPoison bool script 1
	declare DebuffPoisonShort string script
	declare DammagePoisonShort string script
	declare UtilityPoisonShort string script
	declare StartHO bool script 1
	declare HurricaneMode bool script 1

	;POISON DECLERATIONS
	;EDIT THESE VALUES FOR THE POISONS YOU WISH TO USE
	;The SHORT name is the name of the poison buff icon
	if !${Me.InRaid}
	{
		DammagePoisonShort:Set[caustic poison]
		UtilityPoisonShort:Set[turgor]
	}
	else
	{
		DammagePoisonShort:Set[hemotoxin]
		UtilityPoisonShort:Set[ignorant bliss]
	}
	DebuffPoisonShort:Set[enfeebling poison]

	NoEQ2BotStance:Set[1]

	call EQ2BotLib_Init

	OffenseMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Offensive Spells,TRUE]}]
	AoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast AoE Spells,FALSE]}]
	SnareMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Snares,FALSE]}]
	TankMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Try to Tank,FALSE]}]
	BuffHateGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffHateGroupMember,]}]
	HurricaneMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use Hurricane,TRUE]}]
	BuffLunge:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff Lunge Reversal,FALSE]}]
	MaintainPoison:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[MaintainPoison,FALSE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]
}

function Class_Shutdown()
{
}

function Buff_Init()
{

	PreAction[1]:Set[Foot_Work]
	PreSpellRange[1,1]:Set[25]

	PreAction[2]:Set[Bravado]
	PreSpellRange[2,1]:Set[26]

	PreAction[3]:Set[Offensive_Stance]
	PreSpellRange[3,1]:Set[291]

	PreAction[4]:Set[Avoid]
	PreSpellRange[4,1]:Set[27]

	PreAction[5]:Set[Deffensive_Stance]
	PreSpellRange[5,1]:Set[292]

	PreAction[6]:Set[Poisons]

	PreAction[7]:Set[AA_Lunge_Reversal]
	PreSpellRange[7,1]:Set[395]

	PreAction[8]:Set[AA_Evasiveness]
	PreSpellRange[8,1]:Set[397]

	PreAction[9]:Set[Hurricane]
	PreSpellRange[9,1]:Set[28]

	PreAction[10]:Set[BuffHate]
	PreSpellRange[10,1]:Set[40]
}

function Combat_Init()
{

	Action[1]:Set[Melee_Attack1]
	SpellRange[1,1]:Set[150]

	Action[2]:Set[Debuff1]
	Power[2,1]:Set[20]
	Power[2,2]:Set[100]
	SpellRange[2,1]:Set[191]

	Action[3]:Set[AoE1]
	SpellRange[3,1]:Set[95]

	Action[4]:Set[AoE2]
	SpellRange[4,1]:Set[96]

	Action[5]:Set[AA_WalkthePlank]
	SpellRange[5,1]:Set[385]

	Action[6]:Set[Rear_Attack1]
	SpellRange[6,1]:Set[101]

	Action[7]:Set[Rear_Attack2]
	SpellRange[7,1]:Set[100]

	Action[8]:Set[Debuff2]
	Power[8,1]:Set[20]
	Power[8,2]:Set[100]
	SpellRange[8,1]:Set[190]

	Action[9]:Set[Mastery]

	Action[10]:Set[Flank_Attack1]
	SpellRange[10,1]:Set[110]

	Action[11]:Set[Flank_Attack2]
	SpellRange[11,1]:Set[111]

	Action[12]:Set[Taunt]
	Power[12,1]:Set[20]
	Power[12,2]:Set[100]
	MobHealth[12,1]:Set[10]
	MobHealth[12,2]:Set[100]
	SpellRange[12,1]:Set[160]

	Action[13]:Set[Front_Attack]
	SpellRange[13,1]:Set[120]

	Action[14]:Set[Melee_Attack2]
	SpellRange[14,1]:Set[151]

	Action[15]:Set[Melee_Attack3]
	SpellRange[15,1]:Set[152]

	Action[16]:Set[Melee_Attack4]
	SpellRange[16,1]:Set[153]

	Action[17]:Set[Melee_Attack5]
	SpellRange[17,1]:Set[154]

	Action[18]:Set[Melee_Attack6]
	SpellRange[18,1]:Set[149]

	Action[19]:Set[Snare]
	Power[19,1]:Set[60]
	Power[19,2]:Set[100]
	SpellRange[19,1]:Set[235]

	Action[20]:Set[AA_Torporous]
	SpellRange[20,1]:Set[381]

	Action[21]:Set[AA_Traumatic]
	SpellRange[21,1]:Set[382]

	Action[22]:Set[AA_BootDagger]
	SpellRange[22,1]:Set[386]
}


function PostCombat_Init()
{

}

function Buff_Routine(int xAction)
{
	declare BuffTarget string local
	Call ActionChecks

	ExecuteAtom CheckStuck

	if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
	{
	    ExecuteAtom AutoFollowTank
		wait 5
	}

	switch ${PreAction[${xAction}]}
	{
		case Foot_Work
		case Bravado
		case AA_Evasiveness
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case Offensive_Stance
			if (${OffenseMode} || !${TankMode}) && !${Me.Maintained[${PreSpellRange[${xAction},1]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break

		case Avoid
			if ${OffenseMode} && !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
				wait 30
			}
			if !${OffenseMode}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Deffensive_Stance
			if (${TankMode} && !${OffenseMode}) && !${Me.Maintained[${PreSpellRange[${xAction},1]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
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
		case AA_Lunge_Reversal
			if ${BuffLunge}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Hurricane
			if ${HurricaneMode} && !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
				wait 30
			}
			elseif !${HurricaneMode}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case BuffHate
			BuffTarget:Set[${UIElement[cbBuffHateGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		Default
			xAction:Set[40]
			break
	}

}

function Combat_Routine(int xAction)
{
	AutoFollowingMA:Set[FALSE]
	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
	}

	if !${Me.AutoAttackOn}
	{
		EQ2Execute /toggleautoattack
	}


	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
	{
		call CastSpellRange 303
	}

	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}

	Call ActionChecks


	;if stealthed, use ambush
	if !${MainTank} && ${Me.ToActor.IsStealthed} && ${Me.Ability[${SpellType[130]}].IsReady}
	{
		call CastSpellRange 130 0 1 1 ${KillTarget} 0 0 1
	}

	;use best debuffs on target if epic
	if ${Actor[${KillTarget}].IsEpic}
	{
		if ${Me.Ability[${SpellType[150]}].IsReady}
		{
			call CastSpellRange 150 0 0 1 ${KillTarget} 0 0 1
		}

		if ${Me.Ability[${SpellType[191]}].IsReady}
		{
			call CastSpellRange 191 0 1 1 ${KillTarget} 0 0 1
		}

		if ${Me.Ability[${SpellType[381]}].IsReady} && ${Target.Target.ID}!=${Me.ID}
		{
			call CastSpellRange 381 0 1 1 ${KillTarget} 0 0 1
		}

		if ${Me.Ability[${SpellType[382]}].IsReady} && ${Target.Target.ID}!=${Me.ID}
		{
			call CastSpellRange 382 0 1 1 ${KillTarget} 0 0 1
		}

		if ${Me.Ability[${SpellType[386]}].IsReady} && ${Target.Target.ID}!=${Me.ID}
		{
			call CastSpellRange 386 0 1 1 ${KillTarget} 0 0 1
		}

		if ${Me.Ability[${SpellType[101]}].IsReady} && ${Target.Target.ID}!=${Me.ID}
		{
			call CastSpellRange 101 0 1 1 ${KillTarget} 0 0 1
		}
	}

	;if Named or Epic and over 60% health, use dps buffs
	if ${Actor[${KillTarget}].IsEpic} || (${Actor[${KillTarget}].IsHeroic} && ${Actor[${KillTarget}].IsNamed})
	{
		call CheckCondition MobHealth 60 100
		if ${Return.Equal[OK]} || ${Actor[${KillTarget}].IsEpic}
		{
			call CheckPosition 1 1
			if ${Me.Ability[${SpellType[155]}].IsReady} || ${Me.Ability[${SpellType[157]}].IsReady}
			{
				call CastSpellRange 155 158 1 0 ${KillTarget} 0 0 1
				call CastSpellRange 151 0 1 0 ${KillTarget} 0 0 1
				call CastSpellRange 153 0 1 0 ${KillTarget} 0 0 1
			}
		}
	}

	switch ${Action[${xAction}]}
	{
		case Melee_Attack1
		case Melee_Attack2
		case Melee_Attack3
		case Melee_Attack4
		case Melee_Attack5
		case Melee_Attack6
			call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			break
		case AoE1
		case AoE2
			if ${AoEMode} && ${Mob.Count}>=2
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			}
			break
		case Snare
			if ${SnareMode}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
				}
			}
			break
		case Rear_Attack1
		case Rear_Attack2
			if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-25 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<25) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>335 || ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-335
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			}
			elseif ${Target.Target.ID}!=${Me.ID}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 1 ${KillTarget}
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
		case AA_WalkthePlank
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			}
			break
		case AA_Torporous
		case AA_Traumatic
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			}
			break
		case AA_BootDagger
			if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
			}
			break

		case Flank_Attack1
		case Flank_Attack2
			;check valid rear position
			if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-25 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<25) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>335 || ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-335
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			}
			;check right flank
			elseif (${Math.Calc[${Target.Heading}-${Me.Heading}]}>65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-295)
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			}
			;check left flank
			elseif (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<295)
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			}
			elseif ${Target.Target.ID}!=${Me.ID}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 3 ${KillTarget}
			}
		case Debuff1
		case Debuff2
		case Taunt
			if ${TankMode}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget} 0 0 1
			}
			break
		case Front_Attack
			;check right flank
			if (${Math.Calc[${Target.Heading}-${Me.Heading}]}>65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-295)
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			}
			;check left flank
			elseif (${Math.Calc[${Target.Heading}-${Me.Heading}]}<-65 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}>-145) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>215 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<295)
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			}
			;check front
			elseif (${Math.Calc[${Target.Heading}-${Me.Heading}]}>125 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<235) || (${Math.Calc[${Target.Heading}-${Me.Heading}]}>-235 && ${Math.Calc[${Target.Heading}-${Me.Heading}]}<-125)
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			}
			elseif ${Target.Target.ID}!=${Me.ID}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 3 ${KillTarget}
			}
			else
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 2 ${KillTarget}
			}
			break

		case Stun
			if !${Target.IsEpic}
			{
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
			}
			break
		default
			return CombatComplete
			break
	}
}

function Post_Combat_Routine(int xAction)
{
	if ${Me.Maintained[Stealth](exists)}
	{
		Me.Maintained[Stealth]:Cancel
	}

	switch ${PostAction[${xAction}]}
	{
		default
			return PostCombatRoutineComplete
			break
	}
}

function Have_Aggro()
{

	echo I have agro from ${agroid}
	if ${OffenseMode} && ${Me.Ability[${SpellType[388]}].IsReady} && ${agroid}>0
	{
		;Feign
		call CastSpellRange 388 0 1 0 ${agroid} 0 0 1
	}
	elseif ${agroid}>0
	{
		if ${Me.Ability[${SpellType[185]}].IsReady}
		{
			;agro dump
			call CastSpellRange 185 0 1 0 ${agroid} 0 0 1
		}
		else
		{
			call CastSpellRange 181 0 1 0 ${agroid} 0 0 1
		}

	}
}

function Lost_Aggro()
{
	if ${Target.Target.ID}!=${Me.ID}
	{
		if ${TankMode}
		{
			call CastSpellRange 100 101 1 1 ${KillTarget} 0 0 1
			call CastSpellRange 160 0 1 0 ${KillTarget} 0 0 1
		}
	}

}

function MA_Lost_Aggro()
{

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

function ActionChecks()
{
	call UseCrystallizedSpirit 60

	if ${ShardMode}
	{
		call Shard
	}
}

