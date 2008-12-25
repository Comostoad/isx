;*************************************************************
;Fury.iss 20081013
;version
;
;20080417a
; * Tweaked cure and MT heal code to be a bit more 'raid' friendly.  The fury should recover from Spike damage to MT better.
;
;20080416a
; * Added a UI option (and code) for "Summon Imp of Ro" for those that follow Solosek Ro and want to maintain that buff.
;
;20080410a
; * Fixed "Buff Spirit of the Bat" to work on the fury him/herself if so set
;
;20080405a
; * Modified heal routine to check for Me.Group[0] (which should be the Fury him/herself)
; * Optimized the heal routine a bit
;
;20080323a
; * Fury will no longer cast any offensive spells if his/her health is under 51%
; * Fury will now cast "Favor of the Phoenix" when "Start EQ2Bot" is first pressed and after
;   full group wipes.
; * Fury will now CheckHeals() before initiating a HO each round
; * Fury will now no longer cast an offensive spell on an NPC that is currently mezzed (using the CheckForMez() function)
; * Added an option to the UI to choose whether or not to cast "Melee Proc Spells" (such as Fae Fire)
;
;20070725a
; Fixed running into combat range un-necesarily
;	Added a toggle for Combat Range AAs to enable or disable thier use.
;
;20070504a
; Tweaked Heal Code
; Updated Group Cures to check target health and group health before casting cures
;	Misc small fixes
;
;20070404a
;	Updated for latest eq2bot
;
;20070226a
; Full support for KoS and EoF AA lines
; Toggle of incombat rez
; Toggle of initiating HO
; Added Missing Spells (Carnal Mask, Maddening Swarm, Barbarous Intimidation)
; Fixed bug in Storms Usage
; Fixed a bug in UI file
;
;20070201a
; Intelligent Casting of Int Buffs
; Crystalized Shard usage added to checkheals
; Fixed Curing of uncurables
; Added toggle for buffing Thorns on MA (raid stacking contention with other furies/wardens)
; Optomized Storms/Ring of fire when selected
; Added AA Lines
; Optomized DPS
;
;20061130a
; Tweaked Rez, fixed some spell list errors.  Hacked buff canceling
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
	;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
	declare ClassFileVersion int script 20081013
	;;;;

	declare OffenseMode bool script
	declare DebuffMode bool script
	declare AoEMode bool script
	declare UseRingOfFire bool script
	declare CureMode bool script
	declare UseStormBolt bool script
	declare InfusionMode bool script
	declare KeepReactiveUp bool script
	declare BuffEel bool script 1
	declare MeleeAAAttacksMode bool script 0
	declare BuffThorns bool script 1
	declare VortexMode bool script 1
	declare CombatRez bool script 1
	declare UseMeleeProcSpells bool script 1
	declare StartHO bool script 1
	declare KeepMTHOTUp bool script 0
	declare KeepGroupHOTUp bool script 0
	declare RaidHealMode bool script 0
	declare ShiftForm int script 1
	declare PactOfNature string script
	declare SpamHealMode bool script 0
	declare FeastAction int script 9
	declare UseFastOffensiveSpellsOnly bool script 0
	declare UseBallLightning bool script 0
	declare UseWrathOfNature bool script 0
	declare UseMythicalOn string script 
	
	declare VimBuffsOn collection:string script
	declare BuffBatGroupMember string script
	declare BuffSavageryGroupMember string script
	declare BuffSpirit bool script FALSE
	declare BuffHunt bool script FALSE
	declare BuffMask bool script FALSE

	declare EquipmentChangeTimer int script

	call EQ2BotLib_Init

	OffenseMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Offensive Spells,FALSE]}]
	DebuffMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Debuff Spells,TRUE]}]
	AoEMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast AoE Spells,FALSE]}]
	UseRingOfFire:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseRingOfFire,FALSE]}]
	CureMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Cast Cure Spells,FALSE]}]
	InfusionMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[InfusionMode,FALSE]}]
	UseStormBolt:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseStormBolt,FALSE]}]
	MeleeAAAttacksMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[MeleeAAAttacksMode,FALSE]}]
	BuffThorns:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Buff Thorns,FALSE]}]
	VortexMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Vortex,FALSE]}]
	KeepReactiveUp:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[KeepReactiveUp,FALSE]}]
	CombatRez:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Combat Rez,FALSE]}]
	StartHO:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Start HOs,FALSE]}]
	UseMeleeProcSpells:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Melee Proc Spells,FALSE]}]
	KeepMTHOTUp:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[KeepMTHOTUp,FALSE]}]
	KeepGroupHOTUp:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[KeepGroupHOTUp,FALSE]}]
	RaidHealMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[Use Raid Heals,FALSE]}]
	UseFastOffensiveSpellsOnly:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseFastOffensiveSpellsOnly,FALSE]}]
	UseBallLightning:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseBallLightning,FALSE]}]
	UseWrathOfNature:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseWrathOfNature,FALSE]}]
	UseMythicalOn:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[UseMythicalOn,"No One"]}]

	BuffBatGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffBatGroupMember,]}]
	BuffSavageryGroupMember:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffSavageryGroupMember,]}]
	BuffSpirit:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffSpirit,TRUE]}]
	BuffHunt:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffHunt,TRUE]}]
	BuffMask:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffMask,TRUE]}]
	BuffEel:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[BuffEel,FALSE]}]
	ShiftForm:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[ShiftForm,]}]
	PactOfNature:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[PactOfNature,]}]
	SpamHealMode:Set[${CharacterSet.FindSet[${Me.SubClass}].FindSetting[SpamHealMode,]}]

	NoEQ2BotStance:Set[TRUE]
	
	Event[EQ2_FinishedZoning]:AttachAtom[Fury_FinishedZoning]
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
		if ${CureMode}
    		call CheckCures
    		
		if ${Me.ToActor.Power}>85
			call CheckHOTs
			
		;; This has to be set WITHIN any 'if' block that uses the timer.
		ClassPulseTimer:Set[${Script.RunningTime}]
	}
}

function Class_Shutdown()
{
	Event[EQ2_FinishedZoning]:DetachAtom[Fury_FinishedZoning]
}

function Buff_Init()
{
	PreAction[1]:Set[DoCheckRezzes]

	PreAction[2]:Set[BuffThorns]
	PreSpellRange[2,1]:Set[40]

	PreAction[3]:Set[Self_Buff]
	PreSpellRange[3,1]:Set[25]

	PreAction[4]:Set[BuffEel]
	PreSpellRange[4,1]:Set[280]

	PreAction[5]:Set[BuffVim]
	PreSpellRange[5,1]:Set[36]

	PreAction[6]:Set[BuffSpirit]
	PreSpellRange[6,1]:Set[21]

	PreAction[7]:Set[BuffHunt]
	PreSpellRange[7,1]:Set[20]

	PreAction[8]:Set[BuffMask]
	PreSpellRange[8,1]:Set[23]

	;PreAction[x]:Set[SOW]
	;PreSpellRange[x,1]:Set[31]

	PreAction[9]:Set[BuffBat]
	PreSpellRange[9,1]:Set[35]

	PreAction[10]:Set[BuffSavagery]
	PreSpellRange[10,1]:Set[38]

	PreAction[11]:Set[AA_Rebirth]
	PreSpellRange[11,1]:Set[390]

	PreAction[12]:Set[AA_Infusion]
	PreSpellRange[12,1]:Set[391]

	PreAction[13]:Set[AA_Shapeshift]
	PreSpellRange[13,1]:Set[396]
	PreSpellRange[13,2]:Set[397]
	PreSpellRange[13,3]:Set[398]

	PreAction[14]:Set[BuffPactOfNature]
	PreSpellRange[14,1]:Set[399]
	
	PreAction[15]:Set[BuffMythical]
}

function Combat_Init()
{
	Action[1]:Set[Nuke]
	Power[1,1]:Set[30]
	Power[1,2]:Set[100]
	SpellRange[1,1]:Set[60]

	Action[2]:Set[RingOfFire]
	Power[2,1]:Set[40]
	Power[2,2]:Set[100]
	SpellRange[2,1]:Set[95]

	Action[3]:Set[BallLightning]
	Power[3,1]:Set[40]
	Power[3,2]:Set[100]
	SpellRange[3,1]:Set[97]

	Action[4]:Set[AoE]
	Power[4,1]:Set[30]
	Power[4,2]:Set[100]
	SpellRange[4,1]:Set[90]

	Action[5]:Set[DoT2]
	Power[5,1]:Set[30]
	Power[5,2]:Set[100]
	SpellRange[5,1]:Set[51]
	
	Action[6]:Set[AANuke]
	Power[6,1]:Set[30]
	Power[6,2]:Set[100]
	SpellRange[6,1]:Set[379]

	Action[7]:Set[Proc]
	Power[7,1]:Set[40]
	Power[7,2]:Set[100]
	SpellRange[7,1]:Set[157]

	Action[8]:Set[Mastery]

	Action[9]:Set[DoT]
	Power[9,1]:Set[30]
	Power[9,2]:Set[100]
	SpellRange[9,1]:Set[70]

    Action[10]:Set[Feast]
	Power[10,1]:Set[30]
	Power[10,2]:Set[100]
	SpellRange[10,1]:Set[312]
	FeastAction:Set[10]

	Action[11]:Set[Storms]
	Power[11,1]:Set[40]
	Power[11,2]:Set[100]
	SpellRange[11,1]:Set[96]

	Action[12]:Set[AA_Thunderspike]
	Power[12,1]:Set[40]
	Power[12,2]:Set[100]
	SpellRange[12,1]:Set[383]

	Action[13]:Set[AA_Primordial_Strike]
	Power[13,1]:Set[40]
	Power[13,2]:Set[100]
	SpellRange[13,1]:Set[382]

	Action[14]:Set[AA_Nature_Blade]
	Power[14,1]:Set[40]
	Power[14,2]:Set[100]
	SpellRange[14,1]:Set[381]

}

function PostCombat_Init()
{
	PostAction[1]:Set[AutoFollowTank]
	PostAction[2]:Set[CheckForCures]
	PostAction[3]:Set[Resurrection]
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local
	declare ActorID uint local
	variable int temp

	; Pass out feathers on initial script startup
	if !${InitialBuffsDone}
	{
		if (${Me.GroupCount} > 1)
			call CastSpell "Favor of the Phoenix" ${Me.Ability["Favor of the Phoenix"].ID} 0 1 1
		InitialBuffsDone:Set[TRUE]
	}

	if ${Groupwiped}
	{
		Call HandleGroupWiped
		Groupwiped:Set[False]
	}

	if ${ShardMode}
		call Shard

    if ${xAction}== 1 || ${xAction} == 10
	{
		call CheckHeals
		if ${CureMode}
    		call CheckCures
	}

	if ${Me.ToActor.Power}>85
		call CheckHOTs

    call CheckSKFD

	switch ${PreAction[${xAction}]}
	{
		case DoCheckRezzes
			call CheckRezzes
			break
			
		case BuffThorns
			if ${MainTank} || (${BuffThorns} && ${Actor[exactname,${MainTankPC}](exists)})
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[PC,ExactName,${MainTankPC}].ID}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case AA_Infusion
		    if ${InfusionMode}
		    {
    			if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
    			{
    				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
    					call CastSpellRange ${PreSpellRange[${xAction},1]}
    			}
    		}
    		else
			{
			    if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
			    {
			        if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
				        Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				}
			}
			break
		case Self_Buff
		case AA_Rebirth
			if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break
		case AA_Shapeshift
			if (${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)})
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},${ShiftForm}]}
			}
			break
		case BuffEel
			if ${BuffEel}
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case BuffVim
			Counter:Set[1]
			tempvar:Set[1]
			VimBuffsOn:Clear

			;loop through all our maintained buffs to first cancel any buffs that shouldnt be buffed
			do
			{
				BuffMember:Set[]
				;check if the maintained buff is of the spell type we are buffing
				if ${Me.Maintained[${Counter}].Name.Equal[${SpellType[${PreSpellRange[${xAction},1]}]}]}
				{
					;iterate through the members to buff
					if ${UIElement[lbBuffVim@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
					{
						tempvar:Set[1]
						do
						{
							BuffTarget:Set[${UIElement[lbBuffVim@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${tempvar}].Text}]

							if ${Me.Maintained[${Counter}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
							{
								VimBuffsOn:Set[${Me.Maintained[${Counter}].Target.ID},${Me.Maintained[${Counter}].Target.Name}]
								BuffMember:Set[OK]
								break
							}
						}
						while ${tempvar:Inc}<=${UIElement[lbBuffVim@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}

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
			if ${UIElement[lbBuffVim@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}>0
			{
				do
				{
					BuffTarget:Set[${UIElement[lbBuffVim@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem[${Counter}].Text}]
					if (${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname](exists)})
					{
						ActorID:Set[${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}]
						if ${Actor[${ActorID}].Type.Equal[PC]}
						{
							if (${Me.Group[${BuffTarget.Token[1,:]}](exists)} || ${Me.Name.Equal[${BuffTarget.Token[1,:]}]})
							{
								if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].Range} || !${NoAutoMovement})
								{
									if (!${VimBuffsOn.Element[${ActorID}](exists)})
									{
										call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
									}
									;else
									;	Debug:Echo["${Actor[${ActorID}]}(${Actor[${ActorID}].Type}) already Vim buffed!"]													
								}
							}
						}
						else
						{
							if (${Actor[${ActorID}].Distance} <= ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].Range} || !${NoAutoMovement})
							{
								if (!${VimBuffsOn.Element[${ActorID}](exists)})
								{
									call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${ActorID} 0 0 1 0 0
								}
								;else
								;	Debug:Echo["${Actor[${ActorID}]}(${Actor[${ActorID}].Type}) already Vim buffed!"]				
							}	
						}
					}
				}
				while ${Counter:Inc}<=${UIElement[lbBuffVim@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItems}
			}
			break
		case BuffHunt
			if ${BuffHunt}
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffSpirit
			if ${BuffSpirit}
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			break
		case BuffMask
			if ${BuffMask}
			{
				if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
					call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
				break
				
		case BuffMythical
			BuffTarget:Set[${UIElement[cbUseMythicalOn@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]
			
			if ${BuffTarget.Equal[No One]}
				break

			if ${Me.Maintained["Wrath's Blessing"].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
				break
			else
				Me.Maintained["Wrath's Blessing"]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)}
			{
				if ${Me.CastingSpell}
				{
					do
					{
						waitframe
					}
					while ${Me.CastingSpell}
					wait 2
				}
				
				if !${Me.Equipment[Wrath of Nature].IsReady}
					break
				
				if (${Me.Group[${BuffTarget.Token[1,:]}](exists)} || ${Me.Raid[${BuffTarget.Token[1,:]}](exists)})
				{
					Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}]:DoTarget
					wait 2
					Me.Equipment[Wrath of Nature]:Use
					wait 2
					do
					{
						waitframe
					}
					while ${Me.CastingSpell}
					wait 1	
				}
			}
			break
				
		case BuffBat
			BuffTarget:Set[${UIElement[cbBuffBatGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

			if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
				break
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${BuffTarget.Token[2,:].Equal[Me]}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Me.ID}
			elseif ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)} && ${Me.Group[${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			break
		case BuffSavagery
			BuffTarget:Set[${UIElement[cbBuffSavageryGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

			if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
				break
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)} && ${Me.Group[${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}

			break
		case BuffPactOfNature
			if !${Me.Ability[Pact of Nature](exists)}
				break

			BuffTarget:Set[${UIElement[PactOfNature@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

			if ${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}
				break
			else
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)} && ${Me.Group[${BuffTarget.Token[1,:]}](exists)}
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]},exactname].ID}

			break
		Default
			return Buff Complete
			break
	}
	call ProcessTriggers
}

function _CastSpellRange(int start, int finish, int xvar1, int xvar2, int TargetID, int notall, int refreshtimer, bool castwhilemoving, bool IgnoreMaintained, bool CastSpellNOW, bool IgnoreIsReady)
{
	;; Notes:
	;; - For Fury, this function is utilized throughout the Combat_Routine to make sure that we are making desired checks before any spell cast
	;; - IgnoreMaintained:  If TRUE, then the bot will cast the spell regardless of whether or not it is already being maintained (ie, DoTs)
	;;;;;;;

	call CheckMTNearDeath


	call CastSpellRange ${start} ${finish} ${xvar1} ${xvar2} ${TargetID} ${notall} ${refreshtimer} ${castwhilemoving} ${IgnoreMaintained} ${CastSpellNOW} ${IgnoreIsReady}
	return ${Return}
}

function Combat_Routine(int xAction)
{
	declare DebuffCnt int local
	declare TankToTargetDistance float local

	if ${Me.ToActor.WhoFollowing(exists)}
	{
		EQ2Execute /stopfollow
		AutoFollowingMA:Set[FALSE]
		wait 3
	}
	
	if ${DoCallCheckPosition}
	{
		TankToTargetDistance:Set[${Math.Distance[${Actor[${MainTankID}].Loc},${Actor[${KillTarget}].Loc}]}]
		Debug:Echo["_CastSpellRange()::TankToTargetDistance: ${TankToTargetDistance}"]
		
		if ${AutoMelee} && !${NoAutoMovementInCombat} && !${NoAutoMovement}
		{
			if ${MainTank}
				call CheckPosition 1 0
			else
			{
				if (${TankToTargetDistance} <= 7.5)
					call CheckPosition 1 1
			}
		}
		elseif (${TankToTargetDistance} > 15)
		{	
			if ${Actor[${MainTankID}](exists)}
			{
				Debug:Echo["Out of Range :: Moving to within 15m of tank"]
				call FastMove ${Actor[${MainTankID}].X} ${Actor[${MainTankID}].Z} 15 1 1
			}
		}
		DoCallCheckPosition:Set[FALSE]
	}

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; IF "Cast Offensive Spells" is NOT checked
    ;;;;;
    if !${OffenseMode}
    {
        CurrentAction:Set[OffenseMode: OFF]

        if ${EpicMode} || ${RaidHealMode}
        {
            call CheckCures
        	call CheckHeals
        }
        else
        {
        	call CheckHeals

        	if ${CureMode}
        		call CheckCures
    	}

        call CheckSKFD
        call RefreshPower
        if ${ShardMode}
		    call Shard


    	;maintain debuffs
    	DebuffCnt:Set[0]
    	if (${DebuffMode})
    	{
    		if ${Actor[${KillTarget}].IsEpic} && ${Actor[${KillTarget}].IsNamed} && ${Me.ToActor.Power}>30
    		{
    			if !${Me.Maintained[${SpellType[50]}](exists)} && ${Me.Ability[${SpellType[50]}].IsReady}
    			{
    				call _CastSpellRange 50 0 0 0 ${KillTarget}
    				DebuffCnt:Inc
    			}
    			if !${Me.Maintained[${SpellType[51]}](exists)} && ${Me.Ability[${SpellType[51]}].IsReady} && ${DebuffCnt}<1
    			{
    				call _CastSpellRange 51 0 0 0 ${KillTarget}
    				DebuffCnt:Inc
    			}
    			if !${Me.Maintained[${SpellType[52]}](exists)} && ${Me.Ability[${SpellType[52]}].IsReady} && ${DebuffCnt}<1
    			{
    				call _CastSpellRange 52 0 0 0 ${KillTarget}
    				DebuffCnt:Inc
    			}
    		}
    		elseif ${Actor[${KillTarget}].IsHeroic}
    		{
				;; Fast-casting encounter debuff that should be used always
				if !${Me.Maintained[${SpellType[52]}](exists)} && ${Me.Ability[${SpellType[52]}].IsReady} && ${DebuffCnt}<1
				{
					call _CastSpellRange 52 0 0 0 ${KillTarget}
					DebuffCnt:Inc
				}
			}
    	}

    	;if we cast a debuff, check heals again before continue
    	if (${DebuffCnt} > 0)
    	{
            if ${EpicMode} || ${RaidHealMode}
            {
                call CheckCures
            	call CheckHOTs
            }
            else
            {
            	call CheckHOTs

            	if ${CureMode}
            		call CheckCures
        	}
    	}

    	if (${StartHO})
    	{
    		if (!${EQ2.HOWindowActive} && ${Me.InCombat})
    			call _CastSpellRange 304
    	}

    	;;
    	;;;; FEAST
    	;;
		if !${Target.IsEpic}
		{
			call CheckCondition Power ${Power[${FeastAction},1]} ${Power[${FeastAction},2]}
			if ${Return.Equal[OK]}
			{
				call _CastSpellRange ${SpellRange[${FeastAction},1]} 0 0 0 ${KillTarget}
			}
		}
		CurrentAction:Set[OffenseMode: OFF]
        return CombatComplete
    }
    ;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	if !${Actor[${KillTarget}](exists)} || ${Actor[${KillTarget}].IsDead} || ${Actor[${KillTarget}].Health}<0
	    return CombatComplete

	CurrentAction:Set[Combat :: ${Action[${xAction}]} (${xAction})]


    if ${EpicMode} || ${RaidHealMode}
    {
        call CheckCures
    	call CheckHeals
    }
    else
    {
    	call CheckHeals

    	if ${CureMode}
    		call CheckCures
	}

	call RefreshPower

	if (${StartHO})
	{
		if (!${EQ2.HOWindowActive} && ${Me.InCombat})
			call _CastSpellRange 304
	}

	if ${ShardMode}
		call Shard

	;if named epic, maintain debuffs
	if (${DebuffMode})
	{
		if ${Actor[${KillTarget}].IsEpic} && ${Actor[${KillTarget}].IsNamed} && ${Me.ToActor.Power}>30
		{
			if !${Me.Maintained[${SpellType[50]}](exists)} && ${Me.Ability[${SpellType[50]}].IsReady}
			{
				call _CastSpellRange 50 0 0 0 ${KillTarget}
				DebuffCnt:Inc
			}
			if !${Me.Maintained[${SpellType[51]}](exists)} && ${Me.Ability[${SpellType[51]}].IsReady} && ${DebuffCnt}<1
			{
				call _CastSpellRange 51 0 0 0 ${KillTarget}
				DebuffCnt:Inc
			}
			if !${Me.Maintained[${SpellType[52]}](exists)} && ${Me.Ability[${SpellType[52]}].IsReady} && ${DebuffCnt}<1
			{
				call _CastSpellRange 52 0 0 0 ${KillTarget}
				DebuffCnt:Inc
			}
		}
		elseif ${Actor[${KillTarget}].IsHeroic}
		{
			;; Fast-casting encounter debuff that should be used always
			if !${Me.Maintained[${SpellType[52]}](exists)} && ${Me.Ability[${SpellType[52]}].IsReady} && ${DebuffCnt}<1
			{
				call _CastSpellRange 52 0 0 0 ${KillTarget}
				DebuffCnt:Inc
			}
		}
	}
	elseif ${Actor[${KillTarget}].IsHeroic}
	{
		;; Fast-casting encounter debuff that should be used always
		if !${Me.Maintained[${SpellType[52]}](exists)} && ${Me.Ability[${SpellType[52]}].IsReady} && ${DebuffCnt}<1
		{
			call _CastSpellRange 52 0 0 0 ${KillTarget}
			DebuffCnt:Inc
		}
	}

	;if we cast a debuff, check heals again before continue
	if (${DebuffCnt} > 0)
	{
        if ${EpicMode} || ${RaidHealMode}
        {
            call CheckCures
        	call CheckHOTs
        }
        else
        {
        	call CheckHOTs

        	if ${CureMode}
        		call CheckCures
    	}
	}
	
	
	if ${AutoMelee} && !${NoAutoMovementInCombat} && !${NoAutoMovement}
	{
		if ${Actor[${KillTarget}].Distance} > ${Position.GetMeleeMaxRange[${KillTarget}]}
		{
			TankToTargetDistance:Set[${Math.Distance[${Actor[${MainTankID}].Loc},${Actor[${KillTarget}].Loc}]}]
			Debug:Echo["Combat_Routine():: TankToTargetDistance: ${TankToTargetDistance}"]			
			
			if (${MainTank} || ${TankToTargetDistance} <= 7.5)
			{
				if ${FightingEpicMob}
					call CheckPosition 1 1 ${KillTarget}
				else
				{
					switch ${Actor[${KillTarget}].ConColor}
					{
						case Green
						case Grey
							Debug:Echo["Calling CheckPosition(1 0)"]
							call CheckPosition 1 0 ${KillTarget}
							break
						Default
							Debug:Echo["Calling CheckPosition(1 1)"]
							call CheckPosition 1 1 ${KillTarget}
							break
					}
				}
			}
		}
	}
	

	if (${VortexMode})
	{
		;Debug:Echo["Checking Energy Vortex..."]
		if (!${Actor[${KillTarget}].IsSolo} && ${Actor[${KillTarget}].Health} > 50)
		{
			;Debug:Echo["SpellType[385]: ${SpellType[385]}"]
			;Debug:Echo["Energy Vortex -- Target is not solo...check"]
			if ${Me.Ability[${SpellType[385]}].IsReady}
			{
				;Debug:Echo["Energy Vortex -- Ability (${Me.Ability[${SpellType[385]}]})' is ready...check"]
				switch ${Target.ConColor}
				{
					case Red
					case Orange
					case Yellow
					case White
					case Blue
						if (${Actor[${KillTarget}].EncounterSize} > 2 || ${Actor[${KillTarget}].Difficulty} >= 2)
						{
							Me.Ability[${SpellType[385]}]:Use
							wait 2
							break
						}
					default
						if (${Actor[${KillTarget}].IsEpic} || ${Actor[${KillTarget}].IsNamed})
						{
							Me.Ability[${SpellType[385]}]:Use
							wait 2
						}
						break
				}
			}
		}
	}

	;Debug:Echo["Combat_Routine() -- Action: ${Action[${xAction}]} (xAction: ${xAction})"]
	;Debug:Echo["Combat_Routine() -- MainAssist: ${MainAssist}"]

	if !${OffenseMode}
	{
    	if ${DoHOs}
    	{
			call CheckGroupHealth 60
			if ${Return}
				objHeroicOp:DoHO
    	}
	    return CombatComplete
    }


	switch ${Action[${xAction}]}
	{
		case Nuke
		    if ${UseFastOffensiveSpellsOnly}
		        break
			call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CheckForMez "Fury Nuke"
				if ${Return.Equal[FALSE]}
					call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				else
					call ReacquireTargetFromMA
			}		
			break

		case AANuke
		    if !${UseWrathOfNature}
		        break
			call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CheckForMez "Fury AANuke"
				if ${Return.Equal[FALSE]}
					call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}				
				else
					call ReacquireTargetFromMA
			
			}
			break

		case AA_Thunderspike
			if (${MeleeAAAttacksMode} && ${Actor[${KillTarget}].Distance} <= 5)
			{
			    if ${Me.Ability[Thunderspike](exists)}
			    {
    				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
    				if ${Return.Equal[OK]}
    				{
    					if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
    					{
    						call _CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
    					}
    				}
    			}
			}
			break

		case AoE
			if ${AoEMode} && !${UseFastOffensiveSpellsOnly}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckForMez "Fury AoE"
					if ${Return.Equal[FALSE]}
						call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
					else
						call ReacquireTargetFromMA
				}
			}
			break

		case Proc
			if ${UseMeleeProcSpells} && ${Me.GroupCount} > 1
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
					call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break

		case DoT
			call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CheckForMez "Fury DoT"
				if ${Return.Equal[FALSE]}
					call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				else
					call ReacquireTargetFromMA
			}

			break

		case DoT2
			call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
			if ${Return.Equal[OK]}
			{
				call CheckForMez "Fury DoT2"
				if ${Return.Equal[FALSE]}
					call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
				else
					call ReacquireTargetFromMA
			}
			break

		case AA_Primordial_Strike
			if (${MeleeAAAttacksMode} && ${Actor[${KillTarget}].Distance} <= 5)
			{
			    if ${Me.Ability[Primordial Strike](exists)}
			    {
    				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
    				if ${Return.Equal[OK]}
    					call _CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
    			}
			}
			break

		case AA_Nature_Blade
			if (${MeleeAAAttacksMode} && ${Actor[${KillTarget}].Distance} <= 5)
			{
			    if ${Me.Ability[Nature Blade](exists)}
			    {
    				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
    				if ${Return.Equal[OK]}
    					call _CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
    			}
			}
			break

		case RingOfFire
			if ${UseRingOfFire}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckForMez "Fury Ring of Fire"
					if ${Return.Equal[FALSE]}
						call _CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
					else
						call ReacquireTargetFromMA
				}
			}
			break

		case BallLightning
			if ${UseBallLightning}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckForMez "Fury Ball Lightning"
					if ${Return.Equal[FALSE]}
						call _CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
					else
						call ReacquireTargetFromMA
				}
			}
			break

		case Snare
		case Feast
			if !${Target.IsEpic}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
					call _CastSpellRange ${SpellRange[${xAction},1]} 0 0 0 ${KillTarget}
			}
			break

		case Mastery
		    if ${UseFastOffensiveSpellsOnly}
		        break
			;;;; Make sure that we do not spam the mastery spell for creatures invalid for use with our mastery spell
			;;;;;;;;;;
			if (${InvalidMasteryTargets.Element[${Target.ID}](exists)})
					break
			;;;;;;;;;;;

			call CheckForMez "Fury Mastery"
			if ${Return.Equal[FALSE]}
			{
				if ${Me.Ability[Master's Smite].IsReady}
				{
					Target ${KillTarget}
					Me.Ability[Master's Smite]:Use
					do
					{
						waitframe
					}
					while ${Me.CastingSpell}
					wait 1
				}
			}
			else
				call ReacquireTargetFromMA
			break

		case Storms
			;need to add disable to heal routine to prevent stun lock
			if ${UseStormBolt}
			{
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CheckForMez "Fury Storms"
					if ${Return.Equal[FALSE]}
						call _CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget}
					else
						call ReacquireTargetFromMA
				}
			}
			break

		default
			return CombatComplete
			break
	}


	if ${DoHOs}
	{
		call CheckGroupHealth 60
		if ${Return}
			objHeroicOp:DoHO
	}
}

function Post_Combat_Routine(int xAction)
{
    declare tempgrp int local 1

	TellTank:Set[FALSE]

	; turn off auto attack if we were casting while the last mob died
	if ${Me.AutoAttackOn}
		EQ2Execute /toggleautoattack

	switch ${PostAction[${xAction}]}
	{
		case Resurrection
		    if !${Me.ToActor.InCombatMode} || ${CombatRez}
		    {
    			tempgrp:Set[1]
    			do
    			{
    				if (${Me.Group[${tempgrp}](exists)} && ${Me.Group[${tempgrp}].ToActor.IsDead})
    				{
    					if (${Me.InRaid} && ${Me.Ability[${SpellType[380]}].IsReady})
    					{
    						call CastSpellRange 380 0 1 0 ${Me.Group[${tempgrp}].ID} 1
    						wait 5
    						do
    						{
    							waitframe
    						}
    						while ${Me.CastingSpell}
    					}
    					elseif ${Me.Ability[${SpellType[300]}].IsReady}
    					{
    						call CastSpellRange 300 0 1 0 ${Me.Group[${tempgrp}].ID} 1
    						wait 5
    						do
    						{
    							waitframe
    						}
    						while ${Me.CastingSpell}
    					}
    					elseif ${Me.Ability[${SpellType[301]}].IsReady}
    					{
    						call CastSpellRange 301 0 1 0 ${Me.Group[${tempgrp}].ID} 1
    						wait 5
    						do
    						{
    							waitframe
    						}
    						while ${Me.CastingSpell}
    					}
    					elseif ${Me.Ability[${SpellType[302]}].IsReady}
    					{
    						call CastSpellRange 302 0 1 0 ${Me.Group[${tempgrp}].ID} 1
    						wait 5
    						do
    						{
    							waitframe
    						}
    						while ${Me.CastingSpell}
    					}
    					else
    					{
    						call CastSpellRange 303 0 1 0 ${Me.Group[${tempgrp}].ID} 1
    						wait 5
    						do
    						{
    							waitframe
    						}
    						while ${Me.CastingSpell}
    					}
    				}
    			}
    			while ${tempgrp:Inc}<=${Me.GroupCount}
    		}
			break
		case CheckForCures
			;Debug:Echo["Checking if Cures are needed post combat..."]
			if ${Me.ToActor.InCombatMode}
    			call CheckCures 1
    		else
    		    call CheckCures 0
			break
		case AutoFollowTank
			if ${AutoFollowMode}
				ExecuteAtom AutoFollowTank
			break
		default
			return PostCombatRoutineComplete
			break
	}
}

function RefreshPower()
{
    if ${Me.Level} < 75
    {
    	if ${Me.InCombat} && ${Me.ToActor.Power}<65  && ${Me.ToActor.Health}>25
    		call UseItem "Helm of the Scaleborn"

    	if ${Me.InCombat} && ${Me.ToActor.Power}<45
    		call UseItem "Spiritise Censer"

    	if ${Me.InCombat} && ${Me.ToActor.Power}<15
    		call UseItem "Stein of the Everling Lord"
	}


}

function Have_Aggro()
{

	if !${TellTank} && ${WarnTankWhenAggro}
	{
		eq2execute /tell ${MainTankPC}  ${Actor[${aggroid}].Name} On Me!
		TellTank:Set[TRUE]
	}

	if (!${MainTank} && ${Me.Group} > 1)
	{
		if ${Me.Inventory[Behavioral Modificatinator Stereopticon](exists)}
		{
			if (${Me.Inventory[Behavioral Modificatinator Stereopticon].IsReady})
			{
				Me.Inventory[Behavioral Modificatinator Stereopticon]:Use
				return
			}
		}
	}

	if ${Actor[${aggroid}].Distance}<${Me.Ability[${SpellType[180]}].MaxRange}
		call CastSpellRange 180 0 0 0 ${aggroid}

}

function CheckHeals()
{
	declare tempgrp int local 1
	declare temphl int local 0
	declare temph2 int local 1
	declare grpheal int local 0
	declare lowest int local 0
	declare raidlowest int local 1
	declare PetToHeal int local 0
	;declare MainTankID int local 0
	declare MainTankInGroup bool local 0
	declare MainTankExists bool local 1
	declare lowestset bool local FALSE
	declare cGroupMemberID int local 0
	declare cGroupMemberHealth int local 0
	declare lGroupMemberHealth int local 0
	declare cGroupMemberDistance float local 0
	declare cGroupMemberClass string local 0
	declare cGroupMemberIsDead bool local FALSE

	;if ${Me.Name.Equal[${MainTankPC}]} || ${MainTank}
	;	MainTankID:Set[${Me.ID}]
	;else
	;	MainTankID:Set[${Actor[pc,ExactName,${MainTankPC}].ID}]


	if ${DoCallCheckPosition}
	{
		TankToTargetDistance:Set[${Math.Distance[${Actor[${MainTankID}].Loc},${Actor[${KillTarget}].Loc}]}]
		Debug:Echo["_CastSpellRange()::TankToTargetDistance: ${TankToTargetDistance}"]
		
		if ${AutoMelee} && !${NoAutoMovementInCombat} && !${NoAutoMovement}
		{
			if ${MainTank}
				call CheckPosition 1 0
			else
			{
				if (${TankToTargetDistance} <= 7.5)
					call CheckPosition 1 1
			}
		}
		elseif (${TankToTargetDistance} > 15)
		{	
			if ${Actor[${MainTankID}](exists)}
			{
				Debug:Echo["Out of Range :: Moving to within 15m of tank"]
				call FastMove ${Actor[${MainTankID}].X} ${Actor[${MainTankID}].Z} 15 1 1
			}
		}
		DoCallCheckPosition:Set[FALSE]
	}


    if !${Actor[${MainTankID}](exists)}
    {
		echo "EQ2Bot-CheckHeals() -- MainTank does not exist! (MainTankID/MainTankPC: ${MainTankID}/${MainTankPC}"
        MainTankExists:Set[FALSE]
    }
    else
        MainTankExists:Set[TRUE]

	;curses cause heals to do damage and must be cleared off healer
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	;Res the MT if they are dead
	if ${MainTankExists} && ${Actor[${MainTankID}].IsDead}
	{
		if (!${Me.ToActor.InCombatMode} || ${CombatRez})
			call CastSpellRange 300 0 1 1 ${MainTankID}
	}
	call CheckHOTs

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
    else
    {
        if ${Me.ToActor.Health}<85
	        call HealMe
    }

    if ${Me.GroupCount} > 1
    {
    	do
    	{
    		if ${Me.Group[${temphl}].ToActor(exists)}
    		{
    		    ;; Set some variables now:
    		    cGroupMemberID:Set[${Me.Group[${temphl}].ID}]

    		    ; FIRST -- If group member has health below a certain threshold, heal them immediately
    		    if ${Me.Group[${temphl}].ToActor.Health} < 60 && !${Me.Group[${temphl}].ToActor.IsDead}
    		    {
    		    	if ${Me.Ability[${SpellType[2]}].IsReady}
						call CastSpellRange 2 0 0 0 ${cGroupMemberID}
				}

    		    ;;;;;;;;
    		    ;; Set variables now:
    		    cGroupMemberHealth:Set[${Me.Group[${temphl}].ToActor.Health}]
    		    lGroupMemberHealth:Set[${Me.Group[${lowest}].ToActor.Health}]
    		    cGroupMemberDistance:Set[${Me.Group[${temphl}].ToActor.Distance}]
    		    cGroupMemberClass:Set[${Me.Group[${temphl}].Class}]
    		    cGroupMemberIsDead:Set[${Me.Group[${temphl}].ToActor.IsDead}]
    		    ;;
    		    ;;;;;;;;

    			if (${cGroupMemberHealth}<100 && !${cGroupMemberIsDead})
    			{
    				if (${cGroupMemberHealth}<${lGroupMemberHealth} || !${lowestset}) && ${cGroupMemberDistance}<=${Me.Ability[${SpellType[1]}].Range}
    				{
    			        lowestset:Set[TRUE]
    					lowest:Set[${temphl}]
    					;Debug:Echo["CheckHeals():  lowest: ${lowest} (lowestset: ${lowestset})"]
    				}
    			}

    			if ${Me.Group[${temphl}].ID}==${MainTankID}
    				MainTankInGroup:Set[1]

    			if !${cGroupMemberIsDead} && ${cGroupMemberHealth}<80 && ${cGroupMemberDistance}<=${Me.Ability[${SpellType[15]}].Range}
    				grpheal:Inc

    			if (${cGroupMemberClass.Equal[conjuror]}  || ${cGroupMemberClass.Equal[necromancer]} || ${cGroupMemberClass.Equal[coercer]})
    			{
        			if (${Me.Group[${temphl}].ToActor.Pet.Health}<60 && !${Me.Group[${temphl}].ToActor.Pet.IsDead})
        				PetToHeal:Set[${Me.Group[${temphl}].ToActor.Pet.ID}
    			}
    			elseif (${cGroupMemberClass.Equal[illusionist]} && !${Me.InCombat})
    			{
        			if (${Me.Group[${temphl}].ToActor.Pet.Health}<60 && !${Me.Group[${temphl}].ToActor.Pet.IsDead})
        				PetToHeal:Set[${Me.Group[${temphl}].ToActor.Pet.ID}
    			}
    		}
    	}
    	while ${temphl:Inc} <= ${Me.GroupCount}
    }

	;if ${Me.ToActor.Health}<80 && !${Me.ToActor.IsDead}
	;	grpheal:Inc


	if ${grpheal}>1
		call GroupHeal

	;now lets heal individual groupmembers if needed
	if ${lowestset}
	{
	    ;Debug:Echo["${Me.Group[${lowest}]}'s health is lowest at ${Me.Group[${lowest}].ToActor.Health}"]
		call UseCrystallizedSpirit 60

		if ${Me.Group[${lowest}].ToActor.Health}<60 && !${Me.Group[${lowest}].ToActor.IsDead} && ${Me.Group[${lowest}].ToActor(exists)} && ${Me.Group[${lowest}].ToActor.Distance}<=${Me.Ability[${SpellType[2]}].Range}
		{
		    ;Debug:Echo["${Me.Group[${lowest}]}'s health is lowest (<60) at ${Me.Group[${lowest}].ToActor.Health} -- HEALING"]
		    if ${Me.Ability[${SpellType[2]}].IsReady}
				call CastSpellRange 2 0 0 0 ${Me.Group[${lowest}].ID}
		}

		if ${Me.Group[${lowest}].ToActor.Health}<75 && !${Me.Group[${lowest}].ToActor.IsDead} && ${Me.Group[${lowest}].ToActor(exists)} && ${Me.Group[${lowest}].ToActor.Distance}<=${Me.Ability[${SpellType[7]}].Range}
		{
			if ${Me.Ability[${SpellType[7]}].IsReady}
			{
			    ;Debug:Echo["${Me.Group[${lowest}]}'s health is lowest (<75) at ${Me.Group[${lowest}].ToActor.Health} -- HEALING"]
				call CastSpellRange 7 0 0 0 ${Me.Group[${lowest}].ID}
			}
			elseif ${Me.Ability[${SpellType[1]}].IsReady}
			{
			    ;Debug:Echo["${Me.Group[${lowest}]}'s health is lowest (<75) at ${Me.Group[${lowest}].ToActor.Health} -- HEALING"]
				call CastSpellRange 1 0 0 0 ${Me.Group[${lowest}].ID}
			}
			elseif ${Me.Ability[${SpellType[4]}].IsReady}
			{
			    ;Debug:Echo["${Me.Group[${lowest}]}'s health is lowest (<75) at ${Me.Group[${lowest}].ToActor.Health} -- HEALING"]
				call CastSpellRange 4 0 0 0 ${Me.Group[${lowest}].ID}
			}
		}
	}

	;RAID HEALS - Only check if in raid, raid heal mode on, maintank is green, I'm above 50, and a direct heal is available.  Otherwise don't waste time.
	if (${MainTankExists})
	{
    	if ${RaidHealMode} && ${Me.InRaid} && ${Me.ToActor.Health}>50 && ${Actor[${MainTankID}].Health}>70 && (${Me.Ability[${SpellType[4]}].IsReady} || ${Me.Ability[${SpellType[1]}].IsReady})
    	{
    		do
    		{
    			if ${Me.Raid[${temph2}](exists)} && ${Me.Raid[${temph2}].ToActor(exists)}
    			{
    			    if ${Me.Raid[${temph2}].Name.NotEqual[${Me.Name}]}
    				{
      				    if ${Me.Raid[${temph2}].ToActor.Health} < 100 && !${Me.Raid[${temph2}].ToActor.IsDead} && ${Me.Raid[${temph2}].ToActor.Distance}<=${Me.Ability[${SpellType[1]}].Range}
          				{
          					if ${Me.Raid[${temph2}].ToActor.Health} < ${Me.Raid[${raidlowest}].ToActor.Health} || ${raidlowest}==0
          						raidlowest:Set[${temph2}]
          				}
    				}
    			}
    		}
    		while ${temph2:Inc}<= ${Me.Raid}

	      if (${Me.Raid[${raidlowest}].ToActor(exists)})
	      {
      		if ${Me.InCombat} && ${Me.Raid[${raidlowest}].ToActor.Health} < 60 && !${Me.Raid[${raidlowest}].ToActor.IsDead} && ${Me.Raid[${raidlowest}].ToActor.Distance}<=${Me.Ability[${SpellType[1]}].Range}
      		{
      			;Debug:Echo["Raid Lowest: ${Me.Raid[${raidlowest}].Name} -> ${Me.Raid[${raidlowest}].ToActor.Health} health"]
      			if ${Me.Ability[${SpellType[4]}].IsReady}
      				call CastSpellRange 4 0 0 0 ${Me.Raid[${raidlowest}].ID}
      			elseif ${Me.Ability[${SpellType[1]}].IsReady}
      				call CastSpellRange 1 0 0 0 ${Me.Raid[${raidlowest}].ID}
      		}
      	}
    	}
    }

	;PET HEALS
	if ${PetToHeal} && ${Actor[${PetToHeal}](exists)} && ${Actor[${PetToHeal}].InCombatMode} && !${EpicMode} && !${Me.InRaid}
		call CastSpellRange 4 0 0 0 ${PetToHeal}

	if ${EpicMode}
		call CheckCures

	;Check Rezes
	if ${CombatRez} || !${Me.InCombat}
	{
		temphl:Set[1]
		do
		{
			if ${Me.Group[${temphl}].ToActor(exists)}
			{
                if ${Me.Group[${temphl}].ToActor.IsDead} && ${Me.Group[${temphl}].ToActor.Distance}<=20
    			    call CastSpellRange 300 303 1 0 ${Me.Group[${temphl}].ID} 1
			}
		}
		while ${temphl:Inc} <= ${Me.GroupCount}
	}
}

function HealMe()
{
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	if ${Me.Inventory[Crystallized Spirit](exists)} && ${Me.ToActor.Health}<70 && ${Me.ToActor.InCombatMode}
		Me.Inventory[Crystallized Spirit]:Use

	if ${Me.ToActor.Health}<25
	{
		if ${haveaggro}
			call EmergencyHeal ${Me.ID}
		else
		{
			if ${Me.Ability[${SpellType[4]}].IsReady}
				call CastSpellRange 4 0 0 0 ${Me.ID}
			elseif ${Me.Ability[${SpellType[1]}].IsReady}
				call CastSpellRange 1 0 0 0 ${Me.ID}
		}
	}

	if ${Me.ToActor.Health}<40
	{
		if ${Me.Ability[${SpellType[1]}].IsReady}
			call CastSpellRange 1 0 0 0 ${Me.ID}
	}

	if ${Me.ToActor.Health}<65
	{
		if !${EpicMode} || (${haveaggro} && ${Me.ToActor.InCombatMode})
		{
			if ${Me.Ability[${SpellType[7]}].IsReady}
				call CastSpellRange 7 0 0 0 ${Me.ID}
		}
		else
		{
			if ${Me.Ability[${SpellType[1]}].IsReady}
				call CastSpellRange 1 0 0 0 ${Me.ID}
		}
	}
}

function HealMT(int MainTankID, int MTInMyGroup)
{
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}


	;MAINTANK EMERGENCY HEAL
	if ${Actor[${MainTankID}].Health}<30 && !${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)}
		call EmergencyHeal ${MainTankID} ${MTInMyGroup}

	;Frey Check
	if ${Actor[${MainTankID}].Health}<50 && !${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)} && ${Actor[${MainTankID}].Distance}<=${Me.Ability[${SpellType[2]}].Range}
	{
		if ${Me.Ability[${SpellType[2]}].IsReady}
			call CastSpellRange 2 0 0 0 ${MainTankID}
	}

	if ${Actor[${MainTankID}].Health}<60 && !${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)} && ${Actor[${MainTankID}].Distance}<=${Me.Ability[${SpellType[1]}].Range}
	{
		if ${Me.Ability[${SpellType[1]}].IsReady}
			call CastSpellRange 1 0 0 0 ${MainTankID}
	}
	if ${Actor[${MainTankID}].Health}<70 && !${Actor[${MainTankID}].IsDead} && ${Actor[${MainTankID}](exists)} && ${Actor[${MainTankID}].Distance}<=${Me.Ability[${SpellType[4]}].Range}
	{
		if ${Me.Ability[${SpellType[4]}].IsReady}
			call CastSpellRange 4 0 0 0 ${MainTankID}
	}

	;MAINTANK HEALS
	; Use regens first, then Patch Heals
	if ${Actor[${MainTankID}].Health}<90 && ${Actor[${MainTankID}](exists)} && !${Actor[${MainTankID}].IsDead}
	{
		if ${Me.Ability[${SpellType[7]}].IsReady} && ${Me.Maintained[${SpellType[7]}].Target.ID} != ${MainTankID} && ${Actor[${MainTankID}].Distance}<=${Me.Ability[${SpellType[7]}].Range}
			call CastSpellRange 7 0 0 0 ${MainTankID}
		elseif ${Me.Ability[${SpellType[15]}].IsReady} && !${Me.Maintained[${SpellType[15]}](exists)} && ${MTInMyGroup}
		{
			call CastSpellRange 15
		}
	}
}

function GroupHeal()
{
	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	if ${Me.Ability[${SpellType[11]}].IsReady}
		call CastSpellRange 11

	if ${Me.Ability[${SpellType[10]}].IsReady}
		call CastSpellRange 10
	elseif ${Me.Ability[${SpellType[15]}].IsReady}
		call CastSpellRange 15
}

function EmergencyHeal(int healtarget)
{
	;death prevention
	if ${Me.Ability[${SpellType[316]}].IsReady} && (${Me.ID}==${healtarget} || ${Me.Group[${Actor[${healtarget}].Name}](exists)})
		call CastSpellRange 316 0 0 0 ${healtarget}

	;emergency heals
	if ${Me.Ability[${SpellType[8]}].IsReady}
		call CastSpellRange 8 0 0 0 ${healtarget}
	elseif ${Me.Ability[${SpellType[16]}].IsReady}
		call CastSpellRange 16 0 0 0 ${healtarget}

}

function CureGroupMember(int gMember)
{
	declare tmpcure int local 0

	;Debug:Echo["CureGroupMember(${gMember})"]

	if !${Me.Group[${gMember}].ToActor(exists)} || ${Me.Group[${gMember}].ToActor.IsDead} || !${Me.Group[${gMember}].IsAfflicted} || ${Me.Group[${gMember}].ToActor.Health} < 0 || ${Me.Group[${gMember}].ToActor.Distance}>=${Me.Ability[${SpellType[210]}].Range}
		return

	while ${Me.Group[${gMember}].IsAfflicted} && ${tmpcure:Inc}<4 && ${Me.Group[${gMember}].ToActor(exists)} && !${Me.Group[${gMember}].ToActor.IsDead}
	{
		if (${Me.Group[${gMember}].Arcane}>0 || ${Me.Group[${gMember}].Noxious}>0 || ${Me.Group[${gMember}].Elemental}>0 || ${Me.Group[${gMember}].Trauma}>0)
		{
		    ;Debug:Echo["Curing ${Me.Group[${gMember}]}"]
			call CastSpellRange 210 0 0 0 ${Me.Group[${gMember}].ID}
			wait 2
		}
	}
}

function CureMe()
{
	declare CureCnt int local 0

	if !${Me.IsAfflicted}
		return

	;check if we are not in control, and use control cure if needed
	if !${Me.ToActor.CanTurn} || !${Me.ToActor.IsRooted}
		call CastSpellRange 289

	if ${Me.Cursed}
		call CastSpellRange 211 0 0 0 ${Me.ID}

	while (${Me.Arcane}>0 || ${Me.Noxious}>0 || ${Me.Elemental}>0 || ${Me.Trauma}>0) && ${CureCnt:Inc}<4
	{
		call CastSpellRange 210 0 0 0 ${Me.ID}

		if ${Me.ToActor.Health}<30 && ${EpicMode}
			call HealMe
	}

}

function CheckCures(int InCombat=1)
{
    if ${InCombat}
    {
        if !${EpicMode}
        {
            if !${CureMode} && ${Me.ToActor.InCombatMode}
                return
        }
    }

	if ${DoCallCheckPosition}
	{
		TankToTargetDistance:Set[${Math.Distance[${Actor[${MainTankID}].Loc},${Actor[${KillTarget}].Loc}]}]
		Debug:Echo["_CastSpellRange()::TankToTargetDistance: ${TankToTargetDistance}"]
		
		if ${AutoMelee} && !${NoAutoMovementInCombat} && !${NoAutoMovement}
		{
			if ${MainTank}
				call CheckPosition 1 0
			else
			{
				if (${TankToTargetDistance} <= 7.5)
					call CheckPosition 1 1
			}
		}
		elseif (${TankToTargetDistance} > 15)
		{	
			if ${Actor[${MainTankID}](exists)}
			{
				Debug:Echo["Out of Range :: Moving to within 15m of tank"]
				call FastMove ${Actor[${MainTankID}].X} ${Actor[${MainTankID}].Z} 15 1 1
			}
		}
		DoCallCheckPosition:Set[FALSE]
	}

	declare temphl int local 1
	declare grpcure int local 0
	declare Affcnt int local 0

	;check for group cures, if it is ready and we are in a large enough group
	if ${Me.Ability[${SpellType[220]}].IsReady} && ${Me.GroupCount} > 1
	{
		;check ourselves
		if ${Me.IsAfflicted}
		{
			;add ticks for group cures based upon our afflicions
			if ${Me.Noxious}>0 || ${Me.Elemental}>0
				grpcure:Inc
		}
		;Debug:Echo["CheckCures() -- Checked 'Me' -- grpcure: ${grpcure} (Noxious and Elemental Only)"]

		;loop group members, and check for group curable afflictions
		do
		{
			;make sure they in zone and in range
			if ${Me.Group[${temphl}].ToActor(exists)} && ${Me.Group[${temphl}].IsAfflicted} && ${Me.Group[${temphl}].ToActor.Distance}<=${Me.Ability[${SpellType[220]}].Range}
			{
				if ${Me.Group[${temphl}].Noxious}>0 || ${Me.Group[${temphl}].Elemental}>0
					grpcure:Inc
			}
		}
		while ${temphl:Inc} <= ${Me.GroupCount}

		;Debug:Echo["CheckCures() -- Checked Group -- grpcure: ${grpcure} (Noxious and Elemental Only)"]

        if ${EpicMode}
        {
    		if ${grpcure} > 2
    		{
    			call CastSpellRange 220
    			; need a slight wait here for the client to catch up with the server and know that the cure counters were updated
    			wait 5
    			call FindAfflicted
    			if ${Return} <= 0
    			    return
    		}
        }
        else
        {
    		if ${grpcure} > 1
    		{
    			call CastSpellRange 220
    			; need a slight wait here for the client to catch up with the server and know that the cure counters were updated
    			wait 5
    			call FindAfflicted
    			if ${Return} <= 0
    			    return
    		}
    	}
	}

	;Cure Ourselves first
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

		;epicmode is not set in eq2botextras, we will cure only one person per call unless in epic mode.
		if !${EpicMode}
			break

		;Check MT health and heal him if needed
		if ${Actor[pc,ExactName,${MainTankPC}].Health}<50
		{
			if ${Actor[pc,ExactName,${MainTankPC}].ID}==${Me.ID}
				call HealMe
			else
				call HealMT
		}

		;check if we need heals
		call CheckGroupHealth 50
		if !${Return}
			break

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

    ;Debug:Echo["FindAfflicted() returning ${mostafflicted}"]

	if ${mostafflicted}>0
		return ${mostafflicted}
	else
		return 0
}

function CheckHOTs()
{
	declare tempvar int local 1
	declare hot1 int local 0
	declare grphot int local 0
	declare MainTankID int local 0
	hot1:Set[0]
	grphot:Set[0]
	MainTankID:Set[${Actor[exactname,${MainTankPC}].ID}]


	if (${Me.InCombat} || ${Actor[${MainTankID}].InCombatMode})
	{
		if ${KeepMTHOTUp}
		{
			if !${Me.InRaid} || !${Me.Group[${MainTankPC}](exists)}
			{
				tempvar:Set[1]
				do
				{
					if ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[7]}]} && ${Me.Maintained[${tempvar}].Target.ID} == ${MainTankID}
					{
						;echo Single HoT is Present on MT
						hot1:Set[1]
						break
					}
				}
				while ${tempvar:Inc}<=${Me.CountMaintained}

				if ${hot1}==0 && ${Me.Power}>${Me.Ability[${SpellType[7]}].PowerCost} && ${Actor[${MainTankID}](exists)}
				{
					; Single Target HoT
					call CastSpellRange 7 0 0 0 ${MainTankID}
					hot1:Set[1]
				}
			}
		}
		if ${KeepGroupHOTUp}
		{
			if !${Me.InRaid} || ${Me.Group[${MainTankPC}](exists)}
			{
				tempvar:Set[1]
				do
				{
					if ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[15]}]}
					{
						;echo Group HoT is Present
						grphot:Set[1]
						break
					}
				}
				while ${tempvar:Inc}<=${Me.CountMaintained}

				if ${grphot}==0 && ${Me.Power}>${Me.Ability[${SpellType[15]}].PowerCost}
				{
					; group HoT
					call CastSpellRange 15
				}
			}
		}

		; Hibernate
		if ${Actor[${KillTarget}].IsEpic}
		{
			if ${Me.ToActor.Power} > 55 && !${Me.Maintained[${SpellType[11]}](exists)}
				call CastSpellRange 11
		}
	}
	elseif (${KeepReactiveUp} && ${Me.ToActor.Power} >= 85)
	{
		;; Pre HoT
		tempvar:Set[1]
		do
		{
			if ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[7]}]} && ${Me.Maintained[${tempvar}].Target.ID} == ${MainTankID}
			{
				;echo Single HoT is Present on MT
				hot1:Set[1]
				if ${grphot} > 0
					break
				continue
			}
			elseif ${Me.Maintained[${tempvar}].Name.Equal[${SpellType[15]}]}
			{
				;echo Group HoT is Present
				grphot:Set[1]
				if ${hot1} > 0
					break
			}
		}
		while ${tempvar:Inc}<=${Me.CountMaintained}

		if !${Me.InRaid} || !${Me.Group[${MainTankPC}](exists)}
		{
			if ${hot1}==0 && ${Me.Power}>${Me.Ability[${SpellType[7]}].PowerCost} && ${Actor[${MainTankID}](exists)}
			{
				; Single Target HoT
				call CastSpellRange 7 0 0 0 ${MainTankID}
				hot1:Set[1]
			}
		}
		if !${Me.InRaid} || ${Me.Group[${MainTankPC}](exists)}
		{
			if ${grphot}==0 && ${Me.Power}>${Me.Ability[${SpellType[15]}].PowerCost}
			{
				; group HoT
				call CastSpellRange 15
			}
		}


		; Hibernate
		if !${Me.Maintained[${SpellType[11]}](exists)}
			call CastSpellRange 11
	}
}

function CheckMTNearDeath()
{
	declare MainTankID int local 0
	MainTankID:Set[${Actor[exactname,${MainTankPC}].ID}]

	if (${Actor[${MainTankID}].Health} <= 25)
	{
		if (${Me.Ability[${SpellType[316]}].IsReady} && ${Me.ID}==${MainTankID})
			call CastSpellRange 316 0 0 0 ${MainTankID}
	}
}

function Lost_Aggro()
{
}

function MA_Lost_Aggro()
{
}

function MA_Dead()
{
	variable int MainTankID
	MainTankID:Set[${Actor[exactname,${MainTankPC}].ID}]

  	if (${Actor[${MainTankID}](exists)} && ${CombatRez})
  	{
    	if (${Actor[${MainTankID}].IsDead})
			call CastSpellRange 300 303 1 0 ${MainTankID} 1
	}
}

function Cancel_Root()
{
}


function HandleGroupWiped()
{
	;;; There was a full group wipe and now we are rebuffing

	;assume that someone used a feather
	if (${Me.GroupCount} > 1)
		call CastSpell "Favor of the Phoenix" ${Me.Ability["Favor of the Phoenix"].ID} 1 1
	return OK
}

function CheckSKFD()
{
    if !${Me.ToActor.IsFD}
        return

	variable int MainTankID
	MainTankID:Set[${Actor[exactname,${MainTankPC}].ID}]

    if !${Actor[${MainTankID}](exists)}
        return

    if ${Actor[${MainTankID}].IsDead}
        return

    if ${Me.ToActor.Health} < 20
        return

    call RemoveSKFD "Fury::CheckSKFD"
    return
}

function PostDeathRoutine()
{
	;; This function is called after a character has either revived or been rezzed

	return
}

atom(script) Fury_FinishedZoning(string TimeInSeconds)
{
	if ${KillTarget} && ${Actor[${KillTarget}](exists)}
	{
		if !${Actor[${KillTarget}].InCombatMode}
			KillTarget:Set[0]
	}
}

function CheckRezzes()
{
	variable int tempgrp
	
	if ${Me.ToActor.InCombatMode} && !${CombatRez}
		return
		
	if ${Me.GroupCount}	<= 1
		return
	

	tempgrp:Set[1]
	do
	{
		if (${Me.Group[${tempgrp}](exists)} && ${Me.Group[${tempgrp}].ToActor.IsDead})
		{
			if (${Me.InRaid} && ${Me.Ability[${SpellType[380]}].IsReady})
			{
				call CastSpellRange 380 0 1 0 ${Me.Group[${tempgrp}].ID} 1
				wait 5
				do
				{
					waitframe
				}
				while ${Me.CastingSpell}
			}
			elseif ${Me.Ability[${SpellType[300]}].IsReady}
			{
				call CastSpellRange 300 0 1 0 ${Me.Group[${tempgrp}].ID} 1
				wait 5
				do
				{
					waitframe
				}
				while ${Me.CastingSpell}
			}
			elseif ${Me.Ability[${SpellType[301]}].IsReady}
			{
				call CastSpellRange 301 0 1 0 ${Me.Group[${tempgrp}].ID} 1
				wait 5
				do
				{
					waitframe
				}
				while ${Me.CastingSpell}
			}
			elseif ${Me.Ability[${SpellType[302]}].IsReady}
			{
				call CastSpellRange 302 0 1 0 ${Me.Group[${tempgrp}].ID} 1
				wait 5
				do
				{
					waitframe
				}
				while ${Me.CastingSpell}
			}
			else
			{
				call CastSpellRange 303 0 1 0 ${Me.Group[${tempgrp}].ID} 1
				wait 5
				do
				{
					waitframe
				}
				while ${Me.CastingSpell}
			}
		}
	}
	while ${tempgrp:Inc}<=${Me.GroupCount}	
	
}