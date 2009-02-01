;*************************************************************
;Defiler.iss
;version 20080513a
;by karye
;updated by pygar
;
;20080513a
; * Complete re-write of all heal and curing logic.  Cures will be greatly prioritized durring epic battles.
; * Heal and cure checks should all be much less overhead and provide performance boosts for the bot
;
;20070503a
; Toggle Pet Use
; Toggle Combat Rez
;	Added health check to cure routine
; Added Toggle for Innitiating HO
;
;20070404a
; Updated for latest eq2bot
;
;20061201a
; Fixed Cyrstalize Spirit line
; implemented EoF Mastery attacks
; implemented Turgur's Spirit Sight
; implemented Vampire Theft Of Vitality
; Implemented AA Cannibalize
; Implemented AA Hexation
; Implemented AA Soul Ward
; Fixed a bug with AE healing group members out of zone
; Fixed a bug with curing uncurable afflictions
; The defiler will now use spiritual circle more often
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/${Script.Filename}/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20080513
	;;;;

	declare OffenseMode bool script 0
	declare DebuffMode bool script 0
	declare AoEMode bool script 0
	declare CureMode bool script 0
	declare MaelstromMode bool script 0
	declare KeepWardUp bool script
	declare PetMode bool script 1
	declare CombatRez bool script 1
	declare StartHO bool script 1

	declare BuffNoxious bool script FALSE
	declare BuffMitigation bool script FALSE
	declare BuffStrength bool script FALSE
	declare BuffWaterBreathing bool script FALSE
	declare BuffProcGroupMember string script
	declare BuffHorrorGroupMember string script
	declare BuffAlacrityGroupMember string script

	declare EquipmentChangeTimer int script

	call EQ2BotLib_Init

	PetMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Pets,TRUE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	CureMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Cure Spells,FALSE]}]
	CombatRez:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Combat Rez,FALSE]}]
	DebuffMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Debuff Spells,TRUE]}]
	KeepWardUp:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[KeepWardUp,FALSE]}]
	OffenseMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Offensive Spells,FALSE]}]
	MaelstromMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Maelstrom Mode,FALSE]}]

	BuffNoxious:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffNoxious,TRUE]}]
	BuffStrength:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffStrength,TRUE]}]
	BuffMitigation:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffMitigation,TRUE]}]
	BuffWaterBreathing:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffWaterBreathing,FALSE]}]
	BuffProcGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffProcGroupMember,]}]
	BuffHorrorGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffHorrorGroupMember,]}]
	BuffAlacrityGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffAlacrityGroupMember,]}]
}

function Pulse()
{
	;;;;;;;;;;;;
	;; Note:  This function will be called every pulse, so intensive routines may cause lag.  Therefore, the variable 'ClassPulseTimer' is
	;;        provided to assist with this.  An example is provided.
	;
	;			if (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+2000]})
	;			{
	;				Debug:Echo["Anything within this bracket will be called every two seconds.
	;			}
	;
	;         Also, do not forget that a 'pulse' of EQ2Bot may take as long as 2000 ms.  So, even if you use a lower value, it may not be called
	;         that often (though, if the number is lower than a typical pulse duration, then it would automatically be called on the next pulse.)
	;;;;;;;;;;;;

	;; check this at least every 0.5 seconds
	if (${Script.RunningTime} >= ${Math.Calc64[${ClassPulseTimer}+500]})
	{
		call CheckHeals
		call CheckCures

		if ${Me.ToActor.Power}>85 && ${KeepWardUp}
			call CheckWards

		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}
}

function Class_Shutdown()
{
}

function Buff_Init()
{
	PreAction[1]:Set[BuffPower]
	PreSpellRange[1,1]:Set[35]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]
	PreSpellRange[2,2]:Set[26]

	PreAction[3]:Set[BuffProc]
	PreSpellRange[3,1]:Set[41]

	PreAction[4]:Set[BuffNoxious]
	PreSpellRange[4,1]:Set[23]

	PreAction[5]:Set[Group_Buff]
	PreSpellRange[5,1]:Set[281]
	PreSpellRange[5,2]:Set[283]

	PreAction[6]:Set[SpiritCompanion]
	PreSpellRange[6,1]:Set[385]

	PreAction[7]:Set[SpecialVision]
	PreSpellRange[7,1]:Set[314]

	PreAction[8]:Set[AA_Immunities]
	PreSpellRange[8,1]:Set[383]

	PreAction[9]:Set[AA_RitualisticAggression]
	PreSpellRange[9,1]:Set[396]
	PreSpellRange[9,2]:Set[397]

	PreAction[10]:Set[AA_InfectiveBites]
	PreSpellRange[10,1]:Set[394]

	PreAction[11]:Set[AA_Coagulate]
	PreSpellRange[11,1]:Set[395]

	PreAction[12]:Set[BuffHorror]
	PreSpellRange[12,1]:Set[40]

	PreAction[13]:Set[BuffMitigation]
	PreSpellRange[13,1]:Set[21]

	PreAction[14]:Set[BuffStrength]
	PreSpellRange[14,1]:Set[20]

	PreAction[15]:Set[BuffWaterBreathing]
	PreSpellRange[15,1]:Set[280]

}

function Combat_Init()
{
	Action[1]:Set[AoE1]
	SpellRange[1,1]:Set[90]

	Action[2]:Set[AoE2]
	SpellRange[2,1]:Set[91]

	Action[3]:Set[AARabies]
	SpellRange[3,1]:Set[352]

	Action[4]:Set[Mastery]

	Action[5]:Set[Fuliginous_Sphere]
	MobHealth[5,1]:Set[1]
	MobHealth[5,2]:Set[100]
	Power[5,1]:Set[1]
	Power[5,2]:Set[100]
	SpellRange[5,1]:Set[51]

	Action[6]:Set[Proc_Ward]
	MobHealth[6,1]:Set[1]
	MobHealth[6,2]:Set[100]
	Power[6,1]:Set[1]
	Power[6,2]:Set[100]
	SpellRange[6,1]:Set[322]

	Action[7]:Set[Malaise]
	MobHealth[7,1]:Set[1]
	MobHealth[7,2]:Set[100]
	Power[7,1]:Set[1]
	Power[7,2]:Set[100]
	SpellRange[7,1]:Set[71]

	Action[8]:Set[Curse]
	MobHealth[8,1]:Set[1]
	MobHealth[8,2]:Set[100]
	Power[8,1]:Set[1]
	Power[8,2]:Set[100]
	SpellRange[8,1]:Set[384]

	Action[9]:Set[Imprecation]
	MobHealth[9,1]:Set[1]
	MobHealth[9,2]:Set[100]
	Power[9,1]:Set[60]
	Power[9,2]:Set[100]
	SpellRange[9,1]:Set[80]

	Action[10]:Set[TheftOfVitality]
	MobHealth[10,1]:Set[1]
	MobHealth[10,2]:Set[100]
	Power[10,1]:Set[20]
	Power[10,2]:Set[100]
	SpellRange[10,1]:Set[55]

	Action[11]:Set[ThermalShocker]

	Action[12]:Set[AA_CripplingBash]
	MobHealth[12,1]:Set[1]
	MobHealth[12,2]:Set[100]
	SpellRange[12,1]:Set[393]

}

function PostCombat_Init()
{
	PostAction[1]:Set[Resurrection]
	PostSpellRange[1,1]:Set[300]
	PostSpellRange[1,2]:Set[301]

}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local

	declare temp int local

	if ${ShardMode}
		call Shard

	call CheckHeals
	call CheckCures

	if ${Me.ToActor.Power}>85 && ${KeepWardUp}
		call CheckWards

	switch ${PreAction[${xAction}]}
	{
		case BuffPower
			Counter:Set[1]
			tempvar:Set[1]

			;loop through all our maintained buffs to first cancel any buffs that shouldnt be buffed
			do
			{
				BuffMember:Set[]
				;check if the maintained buff is of the spell type we are buffing
				if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[${PreSpellRange[${xAction},1]}]}]}
				{
					;iterate through the members to buff
					if ${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{
						tempvar:Set[1]
						do
						{

							BuffTarget:Set[${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								BuffMember:Set[OK]
								break
							}
						}
						while ${tempvar:Inc}<=${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
						;we went through the buff collection and had no match for this maintaned target so cancel it
						if !${BuffMember.Equal[OK]}
						{
							;we went through the buff collection and had no match for this maintaned target so cancel it
							Me.Maintained[${Counter}]:Cancel
						}
					}
					else
					{
						;our buff member collection is empty so this maintained target isnt in it
						Me.Maintained[${Counter}]:Cancel
					}
				}
			}
			while ${Counter:Inc}<=${Me.CountMaintained}

			Counter:Set[1]
			;iterate through the to be buffed Selected Items and buff them
			if ${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{
				do
				{
					BuffTarget:Set[${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID} 0 0 0 0 2 0
				}
				while ${Counter:Inc}<=${UIElement[lbBuffPower@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break
		case SpiritCompanion
			if ${PetMode} && !${Me.InCombat}
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case BuffNoxious
			if ${BuffNoxious}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffMitigation
			if ${BuffMitigation}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffStrength
			if ${BuffStrength}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffWaterBreathing
			if ${BuffWaterBreathing}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffProc
			BuffTarget:Set[${UIElement[cbBuffProcGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}!=${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID} 0 0 0 0 2 0
			break
		case BuffHorror
			BuffTarget:Set[${UIElement[cbBuffHorrorGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}!=${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID} 0 0 0 0 2 0
			break
		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
		case AA_Coagulate
			call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case AA_Immunities
			if !${Me.ToActor.Effect[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)} && ${Me.ToActor.Pet(exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		case AA_RitualisticAggression
		case AA_RitualOfAbsolution
		case AA_InfectiveBites
			if ${Me.ToActor.Pet(exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break
		case SpecialVision
			if ${Me.ToActor.Race.Equal[Euridite]}
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			break
		Default
			return Buff Complete
			break
	}
}

function Combat_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local
	declare spellsused int local

	if ${EpicMode}
		spellsused:Set[0]
	else
		spellsused:Set[1]

	AutoFollowingMA:Set[FALSE]

	if ${Me.ToActor.WhoFollowing(exists)}
		EQ2Execute /stopfollow

	call PetAttack

	if ${CureMode}
		call CheckCures

	;Persist wards if selected.
	call CheckWards

	call CheckHeals
	call RefreshPower

	if ${Me.Equipment[Dream Scorcher](exists)} && ${Me.Equipment[Dream Scorcher].IsReady}
	{
		Target ${KillTarget}
		Me.Equipment[Dream Scorcher]:Use
	}

	call CheckGroupHealth 60
	if ${Return} && ${DebuffMode} && (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].IsHeroic})
	{

		if ${Me.Ability[${SpellType[50]}].IsReady} && !${Me.Maintained[${SpellType[50]}](exists)}
		{
			call CastSpellRange 50 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[382]}].IsReady} && !${Me.Maintained[${SpellType[382]}](exists)} && ${spellsused}<2
		{
			call CastSpellRange 382 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[52]}].IsReady} && !${Me.Maintained[${SpellType[52]}](exists)} && ${spellsused}<2
		{
			call CastSpellRange 52 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[53]}].IsReady} && !${Me.Maintained[${SpellType[53]}](exists)} && ${spellsused}<2
		{
			call CastSpellRange 53 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[54]}].IsReady} && !${Me.Maintained[${SpellType[54]}](exists)} && ${spellsused}<2
		{
			call CastSpellRange 54 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[322]}].IsReady} && !${Me.Maintained[${SpellType[322]}](exists)} && ${spellsused}<2
		{
			call CastSpellRange 322 0 0 0 ${KillTarget}
			spellsused:Inc
		}

		if ${Me.Ability[${SpellType[51]}].IsReady} && !${Me.Maintained[${SpellType[51]}](exists)} && ${spellsused}<2 && ${OffenseMode}
		{
			call CastSpellRange 51 0 0 0 ${KillTarget}
			spellsused:Inc
		}
	}

	;keep Leg Bite up at all times if we have a pet
	if ${Me.Maintained[${SpellType[385]}](exists)}
		call CastSpellRange 388

	if ${ShardMode}
		call Shard

	if ${MaelstromMode}
	{
		call CheckGroupHealth 60
		if ${Return}
			call CastSpellRange 317 0 0 ${KillTarget}
		elseif ${Me.Maintained[${SpellType[317]}](exists)}
			Me.Maintained[${SpellType[317]}]:Cancel
	}
	elseif ${Me.Maintained[${SpellType[317]}](exists)}
		Me.Maintained[${SpellType[317]}]:Cancel

	;Cast Alacrity if available
	if ${Me.Ability[${SpellType[398]}].IsReady}
	{
		BuffTarget:Set[${UIElement[cbBuffAlacrityGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

		if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			call CastSpellRange 398 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID} 0 0 0 0 2 0
	}

	;Before we do our Action, check to make sure our group doesnt need healing
	call CheckGroupHealth 70
	if ${Return}
	{
		switch ${Action[${xAction}]}
		{
			case Repulsion
			case Loathsome_Seal
			case Curse
			case UmbralTrap
			case TheftOfVitality
			case AA_Hexation
				if ${DebuffMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]} && !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break
			case AA_CripplingBash
				;note: will only bash if within 5 meters, this is by design to prevent having to implement a range only mode
				if ${DebuffMode} && ${Me.Maintained[${SpellType[385]}](exists)}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break

			case Proc_Ward
				if (${Actor[${KillTarget}].Difficulty} == 3)  || ${MainTank} || ${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].Type.Equal[NamedNPC]}
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]} && !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				}
				break
			case Forced_Cannibalize
			case Malaise
			case Imprecation
			case Fuliginous_Sphere
				if ${OffenseMode} && !${Me.Maintained[${SpellType[${SpellRange[${xAction},1]}]}](exists)}
					{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
						if ${Return.Equal[OK]}
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break
			case Soul_Essence
				if ${OffenseMode}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CheckHealerMob
						if ${Return}
							call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					}
				}
				break
			case AoE1
			case AoE2
			case AARabies
				if ${AoEMode} && ${Mob.Count}>2 && ${OffenseMode}
						call CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				break
			case Mastery
				;;;; Make sure that we do not spam the mastery spell for creatures invalid for use with our mastery spell
				;;;;;;;;;;
				if (${InvalidMasteryTargets.Element[${Actor[${KillTarget}].ID}](exists)})
						break
				;;;;;;;;;;;
				if ${Me.Ability[Master's Smite].IsReady} && ${Actor[${KillTarget}](exists)} && ${OffenseMode}
				{
					Target ${KillTarget}
					Me.Ability[Master's Smite]:Use
				}
				break
			case ThermalShocker
				if ${Me.Inventory[ExactName,"Brock's Thermal Shocker"](exists)} && ${Me.Inventory[ExactName,"Brock's Thermal Shocker"].IsReady}
					Me.Inventory[ExactName,"Brock's Thermal Shocker"]:Use
			default
				return CombatComplete
				break
		}
	}
	else
		call CheckHeals

	call CheckGroupHealth 60
	if ${DoHOs} && ${Return}
		objHeroicOp:DoHO

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
		call CastSpellRange 303
}

function Post_Combat_Routine(int xAction)
{
	declare tempgrp int 1
	;Turn off Maelstrom so we can move
	if ${Me.Maintained[${SpellType[317]}](exists)}
		Me.Maintained[${SpellType[317]}]:Cancel

	call CheckCures

	TellTank:Set[FALSE]

	if ${Me.AutoAttackOn}
		EQ2Execute /toggleautoattack

	switch ${PostAction[${xAction}]}
	{
		case Resurrection
			tempgrp:Set[1]
			do
			{
				if ${Me.Group[${tempgrp}].ToActor.IsDead}
					call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]} 1 0 ${Me.Group[${tempgrp}].ID} 1 0 0 0 2 0
			}
			while ${tempgrp:Inc} <= ${Me.GroupCount}
			break
		default
			return PostCombatRoutineComplete
			break
	}
	call CheckHeals
}

function Have_Aggro()
{

}

function RefreshPower()
{
	;AA Cannibalize
	if ${Me.ToActor.Power}<45  && ${Me.ToActor.Health}>50
	{
		call CastSpellRange 387
		call CastSpellRange 381
	}

	;Forced Canabalize
	if ${Me.ToActor.Power}<85 && ${Me.InCombat}  && !${Actor[${KillTarget}].Name.Upper.Find[DRUSELLA]} && !${Actor[${KillTarget}].Name.Upper.Find[VENRIL SATHIR]}
		call CastSpellRange 72 0 0 0 ${KillTarget}
}

function CheckHealerMob()
{
	declare tcount int local 2

	EQ2:CreateCustomActorArray[byDist,15]
	do
	{
		if ${Mob.ValidActor[${CustomActor[${tcount}].ID}]}
		{
			switch ${CustomActor[${tcount}].Class}
			{
				case templar
				case inquisitor
				case fury
				case warden
				case defiler
				case mystic
					return TRUE
			}
		}
	}
	while ${tcount:Inc}<=${EQ2.CustomActorArraySize}

	return FALSE
}

function Lost_Aggro()
{

}

function MA_Lost_Aggro()
{

}

function MA_Dead()
{
	if ${Actor[ExactName,PC,${MainTankPC}].IsDead} && ${Actor[ExactName,PC,${MainTankPC}](exists)} && ${CombatRez}
		call 300 301 1 0 ${Actor[ExactName,PC,${MainTankPC}].ID} 1 0 0 0 2 0
}

function CheckCures()
{
	declare temphl int local 1
	declare grpcure int local 0
	declare Affcnt int local 0

	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID} 0 0 0 0 1 0

	;check for group cures, if it is ready and we are in a large enough group
	if ${Me.Ability[${SpellType[220]}].IsReady} && ${Me.GroupCount}>2
	{
		;check ourselves
		if ${Me.IsAfflicted}
		{
			;add ticks for group cures based upon our afflicions
			if ${Me.Noxious}>0 || ${Me.Trauma}>0
				grpcure:Inc
		}

		;loop group members, and check for group curable afflictions
		do
		{
			;make sure they in zone and in range
			if ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].IsAfflicted} && ${Me.Group[${temphl}].ToActor.Distance}<=${Me.Ability[${SpellType[220]}].Range}
			{
				if ${Me.Group[${temphl}].Noxious}>0 || ${Me.Group[${temphl}].Trauma}>0
					grpcure:Inc
			}
		}
		while ${temphl:Inc} <= ${Me.GroupCount}

		;Use group cure if more than 3 afflictions will be removed
		if ${grpcure}>3
			call CastSpellRange 220 0 0 0 ${KillTarget} 0 0 0 0 1 0
	}

	;Cure Ourselves first
  if ${Me.IsAfflicted} && (${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Trauma}>0 || ${Me.Elemental}>0 || ${Me.Cursed})
		call CureMe


	;Cure Group Members - This will cure a single person unless epicmode is checkd on extras tab, in which case it will cure
	;	all afflictions unless group health or mt health gets low
	while ${Affcnt:Inc}<7 && ${Me.ToActor.Health}>30 && (${Me.Arcane}<1 && ${Me.Noxious}<1 && ${Me.Elemental}<1 && ${Me.Trauma}<1)
	{
		call FindAfflicted
		if ${Return}>0
			call CureGroupMember ${Return}
		else
			break

		;epicmode is set in eq2botextras, we will cure only one person per call unless in epic mode.
		if !${EpicMode}
			break

		;break if we need heals
		call CheckGroupHealth 30
		if !${Return}
			break

		;Check MT health and heal him if needed
		if ${Actor[pc,ExactName,${MainTankPC}].Health}<50
		{
			if ${Actor[pc,ExactName,${MainTankPC}].ID}==${Me.ID}
				call HealMe
			else
				call HealMT
		}
	}

}

function FindAfflicted()
{
	declare temphl int local 1
	declare tmpafflictions int local 0
	declare mostafflictions int local 0
	declare mostafflicted int local 0

	;check for single target cures
	do
	{
		if ${Me.Group[${temphl}].IsAfflicted} && ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].ToActor.Distance}<=${Me.Ability[${SpellType[210]}].Range}
		{
			if ${Me.Group[${temphl}].Arcane}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Arcane}]}]

			if ${Me.Group[${temphl}].Noxious}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Noxious}]}]

			if ${Me.Group[${temphl}].Elemental}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Elemental}]}]

			if ${Me.Group[${temphl}].Trauma}>0
				tmpafflictions:Set[${Math.Calc[${tmpafflictions}+${Me.Group[${temphl}].Trauma}]}]

			if ${tmpafflictions}>${mostafflictions}
			{
				mostafflictions:Set[${tmpafflictions}]
				mostafflicted:Set[${temphl}]
			}
		}
	}
	while ${temphl:Inc} <= ${Me.GroupCount}

	if ${mostafflicted}>0
		return ${mostafflicted}
	else
		return 0
}

function CureMe()
{
	declare AffCnt int 0
	declare CureCnt int 0

	;check if we are not in control, and use control cure if needed
	if !${Me.ToActor.CanTurn} || ${Me.ToActor.IsRooted}
		call CastSpellRange 326

	if !${Me.IsAfflicted}
		return

	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID} 0 0 0 0 1 0

	while ${CureCnt:Inc}<4 && (${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0)
	{
		if ${Me.Arcane}>0
		{
			AffCnt:Set[${Me.Arcane}]
			call CastSpellRange 210 0 0 0 ${Me.ID} 0 0 0 0 1 0
			wait 2

			;if we tried to cure and it failed to work, we might be charmed, use control cure
			if ${Me.Arcane}==${AffCnt}
				call CastSpellRange 326 0 0 0 ${KillTarget} 0 0 0 0 1 0
		}

		if  ${Me.Noxious}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0
		{
			call CastSpellRange 210 0 0 0 ${Me.ID} 0 0 0 0 1 0
			wait 2
		}

		if ${Me.ToActor.Health}<30 && ${EpicMode}
			call HealMe
	}
}

function HealMe()
{
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID} 0 0 0 0 1 0

	;ME HEALS
	; if i have summoned a defiler crystal use that to heal first
	if ${Me.Inventory[Crystallized Spirit](exists)} && ${Me.ToActor.Health}<70 && ${Me.ToActor.InCombatMode}
		Me.Inventory[Crystallized Spirit]:Use

	if ${Me.ToActor.Health}<25
	{
		if ${haveaggro}
			call EmergencyHeal ${Me.ID}
		else
		{
			if ${Me.Ability[${SpellType[1]}].IsReady}
			{
				call CastSpellRange 387
				call CastSpellRange 1 0 0 0 ${Me.ID} 0 0 0 0 2 0
			}
			else
			{
				call CastSpellRange 387
				call CastSpellRange 4 0 0 0 ${Me.ID} 0 0 0 0 2 0
			}
		}
	}

	if ${Me.ToActor.Health}<85
	{
		if ${haveaggro} && ${Me.ToActor.InCombatMode}
			call CastSpellRange 7 0 0 0 ${Me.ID} 0 0 0 0 2 0
		else
		{
			call CastSpellRange 387
			call CastSpellRange 4 0 0 0 ${Me.ID} 0 0 0 0 2 0
		}
	}
}

function CheckHeals()
{
	declare tempgrp int local 1
	declare temphl int local 1
	declare grpheal int local 0
	declare lowest int local 0
	declare PetToHeal int local 0
	declare MainTankID int local 0
	declare MainTankInGroup bool local 0
  declare MainTankExists bool local 1

	if ${Me.Name.Equal[${MainTankPC}]}
		MainTankID:Set[${Me.ID}]
	else
		MainTankID:Set[${Actor[PC,ExactName,${MainTankPC}].ID}]

  if !${Actor[${MainTankID}](exists)}
  {
    echo "EQ2Bot-CheckHeals() -- MainTank does not exist! (MainTankID/MainTankPC: ${MainTankID}/${MainTankPC}"
    MainTankExists:Set[FALSE]
  }
  else
    MainTankExists:Set[TRUE]

	;curses cause heals to do damage and must be cleared off healer
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID} 0 0 0 0 1 0

	;Res the MT if they are dead
	if (${MainTankExists})
	{
  	if (!${Me.ToActor.InCombatMode} || ${CombatRez}) && ${Actor[${MainTankID}].IsDead}
    	call CastSpellRange 300 0 1 1 ${MainTankID} 0 0 0 0 1 0
	}

	;Persist wards if selected.
	call CheckWards


  if ${Me.GroupCount} > 1
  {
		do
		{
			if ${Me.Group[${temphl}].ToActor(exists)}
			{
				if ${Me.Group[${temphl}].ToActor.Health}<100 && !${Me.Group[${temphl}].ToActor.IsDead}
				{
					if (${Me.Group[${temphl}].ToActor.Health}<${Me.Group[${lowest}].ToActor.Health} || ${lowest}==0) && ${Me.Group[${temphl}].ToActor.Distance}<=${Me.Ability[${SpellType[1]}].Range}
						lowest:Set[${temphl}]
				}

				if ${Me.Group[${temphl}].ID}==${MainTankID}
					MainTankInGroup:Set[1]

				if !${Me.Group[${temphl}].ToActor.IsDead} && ${Me.Group[${temphl}].ToActor.Health}<80 && ${Me.Group[${temphl}].ToActor.Distance}<=${Me.Ability[${SpellType[15]}].Range}
					grpheal:Inc

				if ${Me.Group[${temphl}].ToActor.Pet.Health}<60 && ${Me.Group[${temphl}].ToActor.Pet.Health}>0 && !${EpicMode}
					PetToHeal:Set[${Me.Group[${temphl}].ToActor.Pet.ID}

				if ${Me.ToActor.Pet.Health}<60 && !${EpicMode}
					PetToHeal:Set[${Me.ToActor.Pet.ID}]
			}
		}
		while ${temphl:Inc} <= ${Me.GroupCount}

		if ${Me.ToActor.Health}<80 && !${Me.ToActor.IsDead}
			grpheal:Inc
	}

  if (${MainTankExists})
  {
  	if ${Actor[${MainTankID}].Health}<90
  	{
  		if ${Me.ID}==${MainTankID}
  			call HealMe
  		else
  			call HealMT ${MainTankID} ${MainTankInGroup}
  	}

  	;Check My health after MT
    if ${Me.ID}!=${MainTankID} && ${Me.ToActor.Health}<50
	    call HealMe
  }


	if ${PetMode} && ${grpheal}>1 && ${Me.Ability[${SpellType[16]}].IsReady} || (${EpicMode} && ${Me.InCombat})
		call CastSpellRange 16

	if ${grpheal}>2
		call GroupHeal

	;now lets heal individual groupmembers if needed
	if ${lowest}
	{
		call UseCrystallizedSpirit 60

		if ${Me.Group[${lowest}].ToActor.Health}<50 && !${Me.Group[${lowest}].ToActor.IsDead} && ${Me.Group[${lowest}].ToActor(exists)} && ${Me.Group[${lowest}].ToActor.Distance}<=${Me.Ability[${SpellType[1]}].Range}
			call CastSpellRange 387

		if ${Me.Group[${lowest}].ToActor.Health}<70 && !${Me.Group[${lowest}].ToActor.IsDead} && ${Me.Group[${lowest}].ToActor(exists)} && ${Me.Group[${lowest}].ToActor.Distance}<=${Me.Ability[${SpellType[1]}].Range}
		{
			if ${Me.Ability[${SpellType[1]}].IsReady}
				call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ID} 0 0 0 0 2 0
			else
				call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ID} 0 0 0 0 2 0
		}
	}

	;PET HEALS
	if ${PetToHeal} && ${Actor[${PetToHeal}](exists)} && ${Actor[${PetToHeal}].InCombatMode} && ${Actor[${PetToHeal}].Distance}<=${Me.Ability[${SpellType[4]}].Range}
		call CastSpellRange 4 0 0 0 ${PetToHeal} 0 0 0 0 2 0

	if ${EpicMode}
		call CheckCures

	;Check Rezes
	if ${CombatRez} || !${Me.InCombat}
	{
		temphl:Set[1]
		do
		{
			if ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].ToActor.IsDead} && ${Me.Group[${temphl}].ToActor.Distance}<=20
				call CastSpellRange 300 303 1 0 ${Me.Group[${temphl}].ID} 1 0 0 0 2 0
		}
		while ${temphl:Inc} <= ${Me.GroupCount}
	}
}

function HealMT(int MTID, int MTInMyGroup)
{
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID} 0 0 0 0 1 0

	;DeathWard Check
	if ${Actor[${MTID}].Health}<50 && !${Actor[${MTID}].IsDead} && ${Actor[${MTID}](exists)} && ${Actor[${MTID}].Distance}<=${Me.Ability[${SpellType[8]}].Range}
	{
		call CastSpellRange 387
		call CastSpellRange 8 0 0 0 ${MTID} 0 0 0 0 1 0
	}

	;MAINTANK EMERGENCY HEAL
	if ${Actor[${MTID}].Health}<30 && !${Actor[${MTID}].IsDead} && ${Actor[${MTID}](exists)}
		call EmergencyHeal ${MTID}

	;MAINTANK HEALS
	; Use Wards first, then Patch Heals
	if ${Actor[${MTID}].Health}<90 && ${Actor[${MTID}](exists)} && !${Actor[${MTID}].IsDead}
	{
		if ${Me.Ability[${SpellType[15]}].IsReady} && !${Me.Maintained[${SpellType[15]}](exists)} && ${MTInMyGroup} && ${Actor[${MTID}](exists)} && ${Actor[${MTID}].Distance}<=${Me.Ability[${SpellType[15]}].Range}
		{
			call CastSpellRange 387
			call CastSpellRange 15 0 0 0 ${KillTarget} 0 0 0 0 2 0
		}
		else
			call CastSpellRange 7 0 0 0 ${MTID} 0 0 0 0 2 0

		if ${Me.Ability[${SpellType[7]}].IsReady} && ${EpicMode} && ${Actor[${MTID}](exists)} && ${Actor[${MTID}].Distance}<=${Me.Ability[${SpellType[7]}].Range}
			call CastSpellRange 7 0 0 0 ${MTID} 0 0 0 0 2 0
	}

	if ${Actor[${MTID}].Health}<70 && !${Actor[${MTID}].IsDead} && ${Actor[${MTID}](exists)} && ${Actor[${MTID}].Distance}<=${Me.Ability[${SpellType[1]}].Range}
	{
		call CastSpellRange 387
		if ${Me.Ability[${SpellType[1]}].IsReady}
			call CastSpellRange 1 0 0 0 ${MTID} 0 0 0 0 2 0
		else
			call CastSpellRange 4 0 0 0 ${MTID} 0 0 0 0 2 0
	}
}

function GroupHeal()
{
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID} 0 0 0 0 2 0

	call CastSpellRange 387

	if ${Me.Ability[${SpellType[10]}].IsReady}
		call CastSpellRange 10 0 0 0 ${KillTarget} 0 0 0 0 2 0
	else
		call CastSpellRange 15 0 0 0 ${KillTarget} 0 0 0 0 2 0
}

function EmergencyHeal(int healtarget)
{
	;Soul Ward
	if ${Me.ID}!=${healtarget}
	call CastSpellRange 380 0 0 0 ${healtarget} 0 0 0 0 1 0

	;if we cast soulward exit emergency heal
	if ${Me.Maintained[${SpellType[380]}](exists)}
		return

	;Avenger Death Save
	call CastSpellRange 338 0 0 0 ${healtarget} 0 0 0 0 1 0

	if ${Me.Ability[${SpellType[335]}].IsReady}
		call CastSpellRange 335 0 0 0 ${healtarget} 0 0 0 0 1 0
	else
		call CastSpellRange 334 0 0 0 ${healtarget} 0 0 0 0 1 0
}

function CureGroupMember(int gMember)
{
	declare tmpcure int local 0

	if !${Me.Group[${gMember}].ToActor(exists)} || ${Me.Group[${gMember}].ToActor.IsDead} || !${Me.Group[${gMember}].IsAfflicted} || ${Me.Group[${gMember}].ToActor.Distance}>${Me.Ability[${SpellType[210]}].Range}
		return

	while ${Me.Group[${gMember}].IsAfflicted} && ${CureMode} && ${tmpcure:Inc}<4 && ${Me.Group[${gMember}].ToActor(exists)} && !${Me.Group[${gMember}].ToActor.IsDead}
	{
		if ${Me.Group[${gMember}].Arcane}>0 || ${Me.Group[${gMember}].Noxious}>0 || ${Me.Group[${gMember}].Elemental}>0 || ${Me.Group[${gMember}].Trauma}>0
		{
			call CastSpellRange 210 0 0 0 ${Me.Group[${gMember}].ID} 0 0 0 0 ${EpicMode}
			wait 2
		}
	}
}

function CheckWards()
{

	declare tempvar int local 1
	declare hot1 int local 0
	declare grphot int local 0
	hot1:Set[0]
	grphot:Set[0]

	if ${KeepWardUp}
	{
		do
		{
			if ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[7]}]} && ${Me.Maintained[${tempvar}].Target.ID}==${Actor[PC,ExactName,${MainTankPC}].ID}
			{
				;echo Single ward is Present on MT
				hot1:Set[1]
				break
			}
			elseif ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[15]}]}
			{
				;echo Group ward is Present
				grphot:Set[1]
			}
		}
		while ${tempvar:Inc}<=${Me.CountMaintained}

		if ${hot1}==0 && ${Me.Power}>${Me.Ability[${SpellType[7]}].PowerCost}
		{
			call CastSpellRange 7 0 0 0 ${Actor[PC,ExactName,${MainTankPC}].ID} 0 0 0 0 2 0
			hot1:Set[1]
		}

		if ${grphot}==0 && ${Me.Power}>${Me.Ability[${SpellType[15]}].PowerCost}
			call CastSpellRange 15
	}
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}