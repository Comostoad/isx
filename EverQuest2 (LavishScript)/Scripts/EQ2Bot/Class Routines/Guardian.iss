;*************************************************************
;Guardian.iss 20071127a
;version
;by Pygar
;
;20071127a
; Major Optimizations
;
;20070725a
; Updated for AA changes
; Added Executioner's Wrath
; Fixed avoidance buff sorta?  Have to manually cancel to change
;
;20070404a
;	Updated for latest eq2bot
;
;
;20061101a
;	initial build
;*************************************************************

#ifndef _Eq2Botlib_
	#include "${LavishScript.HomeDirectory}/Scripts/EQ2Bot/Class Routines/EQ2BotLib.iss"
#endif

function Class_Declaration()
{
  ;;;; When Updating Version, be sure to also set the corresponding version variable at the top of EQ2Bot.iss ;;;;
  declare ClassFileVersion int script 20080408
  ;;;;

	declare PBAoEMode bool script FALSE
	declare OffensiveMode bool script TRUE
	declare DefensiveMode bool script TRUE
	declare TauntMode bool Script TRUE
	declare FullAutoMode bool Script FALSE
	declare DragoonsCycloneMode bool Script FALSE
	declare MezMode bool Script FALSE

	declare BuffAvoidanceGroupMember string script
	declare BuffSentinelGroupMember string script
	declare BuffDeagroGroupMember string script

	declare TowerShield string script
	declare OffHand string script
	declare EquipmentChangeTimer int script
	declare StartHO bool script

	NoEQ2BotStance:Set[1]

	call EQ2BotLib_Init

	FullAutoMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Full Auto Mode,FALSE]}]
	TauntMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Taunt Spells,TRUE]}]
	DefensiveMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Defensive Spells,TRUE]}]
	OffensiveMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast Offensive Spells,FALSE]}]
	DragoonsCycloneMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Buff Dragoons Cyclone,FALSE]}]
	MezMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Use MezMode,FALSE]}]

	PBAoEMode:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Cast PBAoE Spells,FALSE]}]
	StartHO:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[Start HOs,FALSE]}]

	BuffAvoidanceGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffAvoidanceGroupMember,]}]
	BuffSentinelGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffSentinelGroupMember,]}]
	BuffDeagroGroupMember:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[BuffDeagroMember,]}]

	OffHand:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString[OffHand,]}]
	TowerShield:Set[${SettingXML[${charfile}].Set[${Me.SubClass}].GetString["TowerShield",""]}]
}

function Class_Shutdown()
{
}

function Buff_Init()
{
	PreAction[1]:Set[Avoidance_Target]
	PreSpellRange[1,1]:Set[30]

	PreAction[2]:Set[Self_Buff]
	PreSpellRange[2,1]:Set[25]
	PreSpellRange[2,2]:Set[26]

	PreAction[3]:Set[Group_Buff]
	PreSpellRange[3,1]:Set[20]
	PreSpellRange[3,2]:Set[21]
	PreSpellRange[3,3]:Set[22]

	PreAction[4]:Set[AA_DragoonsCyclone]
	PreSpellRange[4,1]:Set[29]

	PreAction[5]:Set[Sentinel_Target]
	PreSpellRange[5,1]:Set[31]

	PreAction[6]:Set[Deagro_Target]
	PreSpellRange[6,1]:Set[32]

	PreAction[7]:Set[AA_Buckler]
	PreSpellRange[7,1]:Set[394]

	PreAction[8]:Set[Offensive_Stance]
	PreSpellRange[8,1]:Set[290]

	PreAction[9]:Set[Deffensive_Stance]
	PreSpellRange[9,1]:Set[295]
}

function Combat_Init()
{

	Action[1]:Set[AoE_Taunt1]
	SpellRange[1,1]:Set[170]

	Action[2]:Set[AoE2]
	Power[2,1]:Set[20]
	Power[2,2]:Set[100]
	SpellRange[2,1]:Set[96]

	Action[3]:Set[AoE1]
	Power[3,1]:Set[20]
	Power[3,2]:Set[100]
	SpellRange[3,1]:Set[95]

	Action[4]:Set[Taunt1]
	SpellRange[4,1]:Set[160]

	Action[5]:Set[AA_AccelerationStrike]
	MobHealth[5,1]:Set[10]
	MobHealth[5,2]:Set[100]
	SpellRange[5,1]:Set[399]

	Action[6]:Set[AA_ExecutionersWrath]
	MobHealth[6,1]:Set[10]
	MobHealth[6,2]:Set[100]
	SpellRange[6,1]:Set[397]

	Action[7]:Set[Obliterate]
	MobHealth[7,1]:Set[10]
	MobHealth[7,2]:Set[100]
	SpellRange[7,1]:Set[82]

	Action[8]:Set[Melee_Attack2]
	MobHealth[8,1]:Set[5]
	MobHealth[8,2]:Set[100]
	SpellRange[8,1]:Set[153]

	Action[9]:Set[LayWaste]
	MobHealth[9,1]:Set[10]
	MobHealth[9,2]:Set[100]
	SpellRange[9,1]:Set[393]

	Action[10]:Set[Melee_Attack1]
	MobHealth[10,1]:Set[5]
	MobHealth[10,2]:Set[100]
	SpellRange[10,1]:Set[157]

	Action[11]:Set[Melee_Attack3]
	MobHealth[11,1]:Set[5]
	MobHealth[11,2]:Set[100]
	SpellRange[11,1]:Set[154]

	Action[12]:Set[Charge]
	SpellRange[12,1]:Set[80]

	Action[13]:Set[Taunt2]
	SpellRange[13,1]:Set[161]

	Action[14]:Set[AoE_Taunt2]
	SpellRange[14,1]:Set[171]

	Action[15]:Set[Melee_Attack4]
	SpellRange[15,1]:Set[152]

	Action[16]:Set[Melee_Attack5]
	SpellRange[16,1]:Set[81]

	Action[17]:Set[Melee_Attack5]
	SpellRange[17,1]:Set[150]

	Action[18]:Set[Melee_Attack6]
	SpellRange[18,1]:Set[151]

	Action[19]:Set[Shield_Attack]
	Power[19,1]:Set[5]
	Power[19,2]:Set[100]
	SpellRange[19,1]:Set[240]
	SpellRange[19,2]:Set[400]

	Action[20]:Set[ThermalShocker]

}

function PostCombat_Init()
{
	PostAction[1]:Set[Cancel_Root]
	PostSpellRange[1,1]:Set[172]

	PostAction[2]:Set[AA_BindWound]
	PostSpellRange[2,1]:Set[398]
}

function Buff_Routine(int xAction)
{
	declare tempvar int local
	declare Counter int local
	declare BuffMember string local
	declare BuffTarget string local
	variable int temp

	if ${ShardMode}
	{
		call Shard
	}

	if (${AutoFollowMode} && !${Me.ToActor.WhoFollowing.Equal[${AutoFollowee}]})
	{
	  ExecuteAtom AutoFollowTank
		wait 5
	}

	switch ${PreAction[${xAction}]}
	{
		case Avoidance_Target
			BuffTarget:Set[${UIElement[cbBuffAvoidanceGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

			if ${BuffTarget.Equal["None"]}
				break

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)} && !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[1,:]}].ID}
				wait 5
			}
			break

		case Offensive_Stance
			if ${OffensiveMode} && ${PreSpellRange[${xAction},1](exists)} && ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady} && !${Me.Maintained[${PreSpellRange[${xAction},1]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break

		case Deffensive_Stance
			if ${DefensiveMode} && ${PreSpellRange[${xAction},1](exists)} && ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady} && !${Me.Maintained[${PreSpellRange[${xAction},1]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break

		case AA_Buckler
			if ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady} && !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}](exists)}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			break

		case Self_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},2]}
			break

		case Group_Buff
			call CastSpellRange ${PreSpellRange[${xAction},1]} ${PreSpellRange[${xAction},3]}
			break
		case AA_DragoonsCyclone
			if ${DragoonsCycloneMode}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]}
			}
			else
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}
			break
		case Sentinel_Target
			BuffTarget:Set[${UIElement[cbBuffSentinelGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

			if ${BuffTarget.Equal["None"]}
				break

			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)} && ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		case Deagro_Target
			BuffTarget:Set[${UIElement[cbBuffDeagroGroupMember@Class@EQ2Bot Tabs@EQ2 Bot].SelectedItem.Text}]

			if ${BuffTarget.Equal["None"]}
				break

			if !${Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}].Target.ID}==${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			{
				Me.Maintained[${SpellType[${PreSpellRange[${xAction},1]}]}]:Cancel
			}

			if ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}](exists)} && ${Me.Ability[${SpellType[${PreSpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${PreSpellRange[${xAction},1]} 0 0 0 ${Actor[${BuffTarget.Token[2,:]},${BuffTarget.Token[1,:]}].ID}
			}
			break
		Default
			return Buff Complete
			break
	}

}

function Combat_Routine(int xAction)
{

	if ${DoHOs}
	{
		objHeroicOp:DoHO
	}

	if !${EQ2.HOWindowActive} && ${Me.InCombat} && ${StartHO}
	{
		call CastSpellRange 303
	}

	;The following till FullAuto could be nested in FullAuto, but I think bot control of these abilities is better
	call CheckHeals

	if ${Me.Ability[${SpellType[156]}].IsReady} && ${Me.ToActor.Health}<60
	{
		call CastSpellRange 156
	}

	if ${Me.Ability[${SpellType[172]}].IsReady} && ${Me.ToActor.Health}<50
	{
		call CastSpellRange 172
	}

	if ${Me.Ability[${SpellType[155]}].IsReady} && ${Me.ToActor.Health}<40
	{
		call CastSpellRange 155
	}

	if ${Me.ToActor.Health}<20
	{
		if ${Me.Equipment[2].Name.Equal[${TowerShield}]}
		{
			call CastSpellRange 322 0 1 0 ${KillTarget}
		}
		elseif ${Math.Calc[${Time.Timestamp}-${EquipmentChangeTimer}]}>2
		{
			Me.Inventory[${TowerShield}]:Equip
			EquipmentChangeTimer:Set[${Time.Timestamp}]
			call CastSpellRange 322 0 1 0 ${KillTarget}
		}
	}

	;echo in combat
	if ${FullAutoMode}
	{
		;echo ${xAction} - ${SpellType[${SpellRange[${xAction},1]}]} - ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].Name} - ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
		switch ${Action[${xAction}]}
		{
			case LayWaste
			case Obliterate
			case AA_ExecutionersWrath
			case AA_AccelerationStrike
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady}
				{
					call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]}
					}
				}
				break

			case Taunt2
			case Taunt1
				if ${TauntMode}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
					}
				break

			case AoE_Taunt1
			case AoE_Taunt2
				if ${TauntMode} && ${Mob.Count}>1
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
				break

			case AoE1
			case AoE2
				if ${Me.Ability[${SpellType[${SpellRange[${xAction},1]}]}].IsReady} && ${Mob.Count}>1 && ${PBAoEMode}
				{
					call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
					if ${Return.Equal[OK]}
					{
						call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
					}
				}
				break
			case Melee_Attack1
			case Melee_Attack2
			case Melee_Attack3
				call CheckCondition MobHealth ${MobHealth[${xAction},1]} ${MobHealth[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				}
				break

			case Charge
			case Melee_Attack4
			case Melee_Attack5
			case Melee_Attack6
				call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
				break

			case Shield_Attack
				call CheckCondition Power ${Power[${xAction},1]} ${Power[${xAction},2]}
				if ${Return.Equal[OK]}
				{
					call CastSpellRange ${SpellRange[${xAction},1]} 0 1 0 ${KillTarget} 0 0 1
					if ${Me.Ability[${SpellType[${SpellRange[${xAction},2]}]}].IsReady}
					{
						call CastSpellRange ${SpellRange[${xAction},2]} 0 1 0 ${KillTarget} 0 0 1
					}
				}
				break


			case ThermalShocker
				if ${Me.Inventory[ExactName,"Brock's Thermal Shocker"](exists)} && ${Me.Inventory[ExactName,"Brock's Thermal Shocker"].IsReady}
				{
					Me.Inventory[ExactName,"Brock's Thermal Shocker"]:Use
				}
				break
			case default
				return Combat Complete
				break
		}
	}
}

function Post_Combat_Routine(int xAction)
{
	if ${Me.Equipment[2].Name.Equal[${TowerShield}]} && !${Offhand}
		Me.Inventory[${Offhand}]:Equip

	switch ${PostAction[${xAction}]}
	{

		case Cancel_Root
			 if ${Me.Maintained[${SpellType[${PostSpellRange[${xAction},1]}]}](exists)}
			 {
			    Me.Maintained[${SpellType[${PostSpellRange[${xAction},1]}]}]:Cancel
			 }
			break
		case AA_AccelterationStrike
			if ${Me.Ability[${SpellType[${PostSpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${SpellRange[${xAction},1]}
			}
			break
		case AA_BindWound
			if ${Me.Ability[${SpellType[${PostSpellRange[${xAction},1]}]}].IsReady}
			{
				call CastSpellRange ${PostSpellRange[${xAction},1]}
			}
			break
		default
			return PostCombatRoutineComplete
			break
	}
}

function Have_Aggro()
{

}

function Lost_Aggro(int mobid)
{
	if ${FullAutoMode} && ${Me.ToActor.Power}>5
	{
		if ${TauntMode}
		{
			if !${MezMode} && ${Actor${mobid}].Target.ID}!=${Me.ID}
			{
				KillTarget:Set[${mobid}]
				target ${mobid}
			}

			if ${Actor[${KillTarget}].Target.ID}!=${Me.ID} && ${Me.Ability[${SpellType[270]}].IsReady}
			{
				call CastSpellRange 270 0 1 0 ${Actor[${KillTarget}].ID}
			}

			;Use Reinforcement to get back to top of agro tree else use taunts
			if ${Actor[${KillTarget}].Target.ID}!=${Me.ID}
			{
				if ${Me.Ability[${SpellType[321]}].IsReady}
				{
					call CastSpellRange 321 0 1 0 ${Actor[${KillTarget}].ID}
				}
				else
				{
					call CastSpellRange 160 161 1 0 ${Actor[${KillTarget}].ID}
				}

				;use rescue if new agro target is under 65 health
				if ${Me.ToActor.Target.Target.Health}<65 && ${Actor[${KillTarget}].Target.ID}!=${Me.ID}
				{
					call CastSpellRange 320 0 1 0 ${mobid}
				}
			}
		}
	}
}

function MA_Lost_Aggro()
{


}

function MA_Dead()
{
	MainTank:Set[TRUE]
	MainTankPC:Set[${Me.Name}]
	KillTarget:Set[]
}

function Cancel_Root()
{

}

function CheckHeals()
{
	declare temphl int local
	declare grpheal int local 0
	declare lowest int local 0
	declare MTinMyGroup bool local FALSE

	grpcnt:Set[${Me.GroupCount}]
	hurt:Set[FALSE]

	temphl:Set[1]
	grpcure:Set[0]
	lowest:Set[1]

	if ${Me.Ability[${SpellType[316]}].IsReady} || ${Me.Ability[${SpellType[271]}].IsReady}
	{
		do
		{
			if ${Me.Group[${temphl}].ZoneName.Equal["${Zone.Name}"]}
			{

				if ${Me.Group[${temphl}].ToActor.Health} < 100 && !${Me.Group[${temphl}].ToActor.IsDead} && ${Me.Group[${temphl}].ToActor(exists)}
				{
					if ${Me.Group[${temphl}].ToActor.Health} < ${Me.Group[${lowest}].ToActor.Health}
					{
						lowest:Set[${temphl}]
					}
				}

				if !${Me.Group[${temphl}].ToActor.IsDead} && ${Me.Group[${temphl}].ToActor.Health}<60
				{
					grpheal:Inc
				}

				if ${Me.Group[${temphl}].Name.Equal[${MainTankPC}]}
				{
					MTinMyGroup:Set[TRUE]
				}
			}

		}
		while ${temphl:Inc}<${grpcnt}
	}
	;MAINTANK EMERGENCY Mitigation
	if ${Me.Group[${lowest}].ToActor.Health}<30 && !${Me.Group[${lowest}].ToActor.IsDead} && ${Me.Group[${lowest}].Name.Equal[${MainTankPC}]} && ${Me.Group[${lowest}].ToActor(exists)}
	{
		call CastSpellRange 317
		call CastSpellRange 155 156
	}

	;GROUP HEALS
	if ${grpheal}>1
	{
		if ${Me.Ability[${SpellType[316]}].IsReady}
		{
			call CastSpellRange 316
		}
		if ${Me.Ability[${SpellType[271]}].IsReady}
		{
			call CastSpellRange 271
		}
	}

}


