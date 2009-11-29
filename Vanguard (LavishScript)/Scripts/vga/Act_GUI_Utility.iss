function PauseScript()
{
	while (${doPause} || ${Me.ToPawn.IsDead} || ${Me.HealthPct} == 0)
	{
		waitframe
		VG:ExecBinding[straferight,release]
		VG:ExecBinding[strafeleft,release]
		VG:ExecBinding[turnleft,release]
		VG:ExecBinding[turnright,release]
		VG:ExecBinding[moveforward,release]
		VG:ExecBinding[movebackward,release]
	}
}
;********************************************
function groupup()
{
	if ${Me.GroupInvitePending}
	{
	vgexecute /groupacceptinvite
	}

} 
;********************************************
function Trash()
{

    if ${doTrash} && !${Me.InCombat}
     {
	   variable iterator Iterator
	   Trash:GetSettingIterator[Iterator]
	   Iterator:First
	     while ( ${Iterator.Key(exists)} )
	     {
        if ${Me.Inventory[ExactName,${Iterator.Key}](exists)}
              {
             Me.Inventory[ExactName,${Iterator.Key}]:Delete[ExactName,${Iterator.Key}.Quantity]
              }
        Iterator:Next
	     }
      }

}
;********************************************
function RushTank()
{
	if ${DoRushTank}
	{
	if !${Pawn[Poison Cloud](exists)}
		return

	variable int iCount
	iCount:Set[1]
	; Cycle through all the Pawns if there is a poison cloud
		do
		{
		if ${Pawn[${iCount}].Name.Equal[Poison Cloud]} && ${Pawn[${iCount}].Distance} < 10
			{
			if ${Me.IsCasting}
				{
				vgexecute /stopcasting
				}
			if ${Me.Class.Equal[Rogue]}
				{
				Me.Ability[Smoke Trick]:Use
				wait 3
				if ${Pawn[${iCount}].Distance} < 10
					{
					call movetoobject ${Pawn[exactname,${followpawn}].ID} ${followpawndist} 0
					IsFollowing:Set[FALSE]
					}
				return	
				}
			call movetoobject ${Pawn[exactname,${followpawn}].ID} ${followpawndist} 0
			IsFollowing:Set[FALSE]	
			}
		}	
		while ${iCount:Inc} <= ${VG.PawnCount}
	}
	return
	
}

;********************************************
function Harvest()
{
    if ${doHarvest}
	{
	if "(${Me.Target.Type.Equal[Resource]} || ${Me.Target.IsHarvestable}) && ${Me.Target.Distance}<5 && ${Me.ToPawn.CombatState}==0"
		{
		VGExecute /autoattack
		wait 10
		}
	if "(${Me.Target.Type.Equal[Resource]} || ${Me.Target.IsHarvestable}) && ${Me.Target.Distance}<10 && ${Me.Target.Distance}>5 && ${Me.ToPawn.CombatState}==0"
		{
		call movetoobject ${Me.Target.ID} 4 0
		IsFollowing:Set[FALSE]
		VGExecute /autoattack
		wait 10
		}	
	if ${Me.Ability[Auto Attack].Toggled}
		{
		VGExecute /autoattack
		wait 10
		}
	}		
}

;********************************************
function lootit()
{
	;; if there are no corpses around...then why bother.
	if !${Pawn[Corpse](exists)}
		return
	
	if (${DoLoot} && ${Group.Count} < 7)
	{
		if (!${Me.InCombat} || ${Me.Encounter} == 0)
		{
			variable int iCount
			iCount:Set[1]
			; Cycle through all the Pawns and find some corpses to Loot and Skin
			do
			{
				if ${Pawn[${iCount}].Type.Equal[Corpse]} && ${Pawn[${iCount}].Distance} < 10 && ${Pawn[${iCount}].ContainsLoot}
				{
					;First clear inventory of any trash items
					call Trash

					Pawn[${iCount}]:Target
					wait 5
					if ${Pawn[${iCount}].Distance} > 5
						{
						call movetoobject ${Me.Target.ID} 4 0
						IsFollowing:Set[FALSE]
						}
					if ${DoLootOnly}
						{
						Loot:BeginLooting
						wait 4
						Loot.Item[${LootOnly}]:Loot
						wait 4
						Loot:EndLooting
						}
					if !${DoLootOnly}
						VGExecute /Lootall
					waitframe
					VGExecute "/cleartargets"	
				}
			}	
			while ${iCount:Inc} <= ${VG.PawnCount}
		}
	}
}
;********************************************
function restorespecialpoints()
{
	if ${doRestoreSpecial}
	{
    if ${Me.Stat[Adventuring,Virtue Points](exists)} && ${Me.Stat[Adventuring,Virtue Points]} < ${RestoreSpecialint} && ${Me.Ability[${RestoreSpecial}].IsReady}
          	call executeability "${RestoreSpecial}" "heal" "neither"
    if ${Me.Stat[Adventuring,Phenomena Points](exists)} && ${Me.Stat[Adventuring,Phenomena Points]} < ${RestoreSpecialint} && ${Me.Ability[${RestoreSpecial}].IsReady}
          	call executeability "${RestoreSpecial}" "heal" "neither"
    if ${Me.Stat[Adventuring,Special Points](exists)} && ${Me.Stat[Adventuring,Special Points]} < ${RestoreSpecialint} && ${Me.Ability[${RestoreSpecial}].IsReady}
          	call executeability "${RestoreSpecial}" "heal" "neither"
	}
}
;********************************************
function ShiftingImage()
{
	if ${DoShiftingImage}
	{
		if !${Me.Effect[${ShiftingImage}](exists)} && ${Me.Inventory[Wand of Shifting Images].IsReady}
			Me.Inventory[Wand of Shifting Images]:Use
	}
}
;********************************************
function shouldimount()
{
	if ${doMount} && !${Pawn[${Me}].IsMounted} && ${Pawn[${followpawn}].IsMounted} && !${Me.InCombat}
	{
	Me.Inventory[${Me.Inventory[CurrentEquipSlot,Mount]}]:Use
	call MeCasting Neither
	wait 3
	}
}
;********************************************
function executeability(string x_ability, string x_type, string CP)
{
	variable int64 CurrentTargetID
	variable bool DoIt = FALSE
	variable iterator iAbs
	
	;; Auto Counter...
	if ${DoCountersASAP} && ${CounterReactionReady}
	{
		if (${Time.Timestamp} <= ${CounterReactionTimer})
		{
			CurrentTargetID:Set[${Me.Target.ID}]
			if ${Me.Target.ID} != ${CounterReactionPawnID}
			{
				Pawn[id,${CounterReactionPawnID}]:Target
				wait 2
			}
			
			CounterReactionAbilities:GetIterator[iAbs]
			if ${iAbs:First(exists)}
			do
			{				
				if ${Me.Ability[id,${iAbs.Value}].IsReady}
				{
					echo "executeability()-Debug: Casting Counter '${Me.Ability[id,${iAbs.Value}].Name}'! (Total abilities available for counter: ${CounterReactionAbilities.Used})"
					Me.Ability[id,${iAbs.Value}]:Use
					CounterReactionAbilities:Clear
					wait 3
				}
			}
			while ${iAbs:Next(exists)}
			
			if ${Me.Target.ID} != ${CurrentTargetID}
			{
				Pawn[id,${CurrentTargetID}]:Target
				wait 2
			}
		}
		CounterReactionReady:Set[FALSE]
	}
	
	;; Auto Chains
	if ${DoChainsASAP} && ${ChainReactionReady}
	{
		if (${Time.Timestamp} <= ${ChainReactionTimer})
		{
			CurrentTargetID:Set[${Me.Target.ID}]
			if ${Me.Target.ID} != ${ChainReactionPawnID}
			{
				Pawn[id,${ChainReactionPawnID}]:Target
				wait 2
			}

			ChainReactionAbilities:GetIterator[iAbs]
			if ${iAbs:First(exists)}
			do
			{				
				if ${Me.Ability[id,${iAbs.Value}].IsReady}
				{
					echo "executeability()-Debug: Casting Chain '${Me.Ability[id,${iAbs.Value}].Name}'! (Total abilities available for chain: ${ChainReactionAbilities.Used})"
					Me.Ability[id,${iAbs.Value}]:Use
					ChainReactionAbilities:Clear
					wait 3
				}
			}
			while ${iAbs:Next(exists)}
			
			if ${Me.Target.ID} != ${CurrentTargetID}
			{
				Pawn[id,${CurrentTargetID}]:Target
				wait 2
			}
		}
		ChainReactionReady:Set[FALSE]
	}
	
	
	switch ${x_type}
	{
		case Heal
			;echo "HEAL ${x_ability} ${Me.DTarget} ${Group[1].Name} ${Group[1].Health} , ${Group[2].Name} ${Group[2].Health} , ${Group[3].Name} ${Group[3].Health} , ${Group[4].Name} ${Group[4].Health} , ${Group[5].Name} ${Group[5].Health} , ${Group[6].Name} ${Group[6].Health}"  
			DoIt:Set[TRUE]
			break

		case MeleeHeal
			;echo "HEAL ${x_ability} ${Me.DTarget} ${Group[1].Name} ${Group[1].Health} , ${Group[2].Name} ${Group[2].Health} , ${Group[3].Name} ${Group[3].Health} , ${Group[4].Name} ${Group[4].Health} , ${Group[5].Name} ${Group[5].Health} , ${Group[6].Name} ${Group[6].Health}"  
			call CheckFurious
			if ${Return}
				{
				DoIt:Set[TRUE]
				}
			break	
		
		case attack		
			call mobresist "${x_ability}"
			if ${Return}
				{
				call CheckFurious
				if ${Return}
					{
					DoIt:Set[TRUE]
					}
          			}
      			break

		case counter		
			call mobresist "${x_ability}"
			if ${Return}
			{
				DoIt:Set[TRUE]
	          	}
      			break
      		
		case buff
			DoIt:Set[TRUE]
			break
			
		case evade
			call mobresist "${x_ability}"
			if ${Return}
			{
				DoIt:Set[TRUE]
			}
			break
			
		case utility
			DoIt:Set[TRUE]
			break
			
		case NoCheck
			DoIt:Set[TRUE]
			break
			
		default
			DoIt:Set[TRUE]
			break
	}

	if ${DoIt}
	{
		debuglog "Casting ${x_ability}"
		if ${Me.Ability[${x_ability}].IsReady}
		{
			Me.Ability[${x_ability}]:Use
			;***************edited by maras**************
				usedAbility:Set[TRUE]
			;***************end edited by maras**************
			switch ${x_type}
			{
				case Heal
					actionlog "${x_ability} ${Me.DTarget}"
					call MeCasting ${CP}
					return
				case MeleeHeal
					actionlog "${x_ability} ${Me.DTarget}"
					call MeCasting ${CP}
					return	
				
				case attack		
					actionlog "${x_ability} ${Me.Target}"
					call MeCasting ${CP}
					return
		
				case counter		
					actionlog "${x_ability} ${Me.Target}"
					call MeCasting ${CP}
					return
		
				case buff
					actionlog "${x_ability} ${Me.DTarget} BUFF"
					call MeCasting ${CP}
					return
					
				case evade
					actionlog "${x_ability} ${Me.DTarget} EVADE"
					call MeCasting ${CP}
					return
				
				case utility
					actionlog "${x_ability} ${Me.DTarget} UTILITY"
					call MeCasting ${CP}
					return
					
				case Lifetap
					actionlog "${x_ability} ${Me.DTarget} LIFETAP"
					call MeCasting ${CP}
					return
							
				default
					call MeCasting ${CP}
					return
			}			
		}
		else
			debuglog "${Me.Ability[${x_ability}]} Not Ready ${Me.Ability[${x_ability}].TimeRemaining} Sec."
		return 
	}
	
	return

}

;********************************************
function:bool checkabilitytocast(string aName)
{
	debuglog "Checking ${aName}"
	if ${Me.Ability[${abilString}].EnergyCost(exists)} && ${Me.Ability[${abilString}].EnergyCost} == 0 && ${Me.Ability[${abilString}].EnduranceCost(exists)} && ${Me.Ability[${abilString}].EnduranceCost} == 0
	{
		debuglog "Has No Ability Cost DO IT "
		return TRUE
	}
	if ${Me.Ability[${aName}].EnergyCost} > ${Me.Energy}
	{
		debuglog "Not Enough Energy for ${aName}"
		return FALSE
	}
	if ${Me.Ability[${aName}].EnduranceCost} > ${Me.Endurance} 
	{
		debuglog "Not Enough Endurance for ${aName}"
		return FALSE
	}	
	if ${Me.Ability[${aName}].JinCost} > ${Me.Stat[Adventuring,Jin]} 
	{
		debuglog "Not Enough Jin for ${aName}"
		return FALSE
	}
	if ${Me.Ability[${aName}].VirtuePointsCost} > ${Me.Stat[Adventuring,Virtue Points]} 
	{
		debuglog "Not Enough Virtue for ${aName}"
		return FALSE
	}
	if ${Me.Ability[${aName}].PhenomenaPointsCost} > ${Me.Stat[Adventuring,Phenomena Points]} 
	{
		debuglog "Not Enough Phenomena for ${aName}"
		return FALSE
	}
	if ${Me.Ability[${aName}].SpecialPointsCost} > ${Me.Stat[Adventuring,Special Points]} 
	{
		debuglog "Not Enough Special for ${aName}"
		return FALSE
	}
	if ${Me.Ability[${aName}].TimeRemaining} > 0
	{
		debuglog "TimeRemaining Must wait ${Me.Ability[${aName}].TimeRemaining}"
		return FALSE
	}
	if !${Me.Ability[${aName}].IsReady}
	{
		debuglog "'${aName}' is not ready!"
		return FALSE
	}

	debuglog "Whatever Do IT"
	return TRUE

}
;********************************************
atom(script) NeedBuffs() 
{
	GroupNeedsBuffs:Set[TRUE]
} 
;********************************************
function CheckPosition()
{
	call RushTank
	call assistpawn
	call DoFollowInCombat
	call facemob
	call MoveToTarget
	call targettank
}
;********************************************
function targettank()
{
	if (${Pawn[exactname,${tankpawn}](exists)} && !${Me.FName.Equal[${tankpawn}]} && ${Pawn[exactname,${tankpawn}].Distance} < 50)
	{
		VGExecute /targetauto ${tankpawn}
	}
	return
}
;********************************************
function assistpawn()
{
	if ${doassistpawn} 
	{
		if (${Pawn[exactname,${assistpawn}](exists)} && ${Pawn[exactname,${assistpawn}].CombatState} != 0 && ${Pawn[exactname,${assistpawn}].Distance} < 50)
		{
			call LooseTarget
			VGExecute /assist ${assistpawn}
		}
	}
	return
}
;********************************************
function LooseTarget()
{
	if ${DoLooseTarget} 
	{
		if ${Me.Target(exists)} && ${Me.TargetHealth} < 2 && !${Me.Target.IsDead}
		{
			AssistEncounter:Set[${Me.Target.ID}]
			VGExecute /cleartarget
			while ${Me.Encounter.ID[${AssistEncounter}](exists)} && !${Me.Target(exists)}
				wait 1
		}
	}
	return
}
;********************************************
function DoFollowInCombat()
{
	if ${DoFollowInCombat}
	{
		call assistpawn
		if ${Me.Target.ID(exists)} && ${Me.Target.Distance} > 5 && ${Me.Target.Distance} < 7 && ${Pawn[exactname,${followpawn}].Distance} < 5
		{
			face ${Me.Target.X} ${Me.Target.Y}
			call movetoobject ${Me.Target.ID} ${followpawndist} 0
		}
		if ${Me.Target.ID(exists)} && ${Me.Target.Distance} < 5 && ${Pawn[exactname,${followpawn}].Distance} < 5
		{
			face ${Me.Target.X} ${Me.Target.Y}
		}
		if ${Pawn[exactname,${followpawn}].Distance} > 5 && ${Pawn[exactname,${followpawn}].Distance} < 25
		{
			face ${Pawn[exactname,${assistpawn}].X} ${Pawn[exactname,${assistpawn}].Y}
			call movetoobject ${Pawn[exactname,${followpawn}].ID} ${followpawndist} 0
		}
	}
	return

}
;********************************************
function facemob()
{
	if ${doFaceTarget}
	{
		call assistpawn
		if ${Me.Target.ID(exists)}
		{
			face ${Me.Target.X} ${Me.Target.Y}
		}
	}
	return

}
;********************************************     
function TooClose()
{
	call facemob
	if ${Me.Target(exists)} && ${Me.Target.Distance} < 1
	{
		VG:ExecBinding[movebackward]
		wait 2
		VG:ExecBinding[movebackward,release]
		return
	}
	return
}
;********************************************     
function followpawn()
{
	if ${dofollowpawn}
	{
		if (${Pawn[exactname,${followpawn}](exists)} && ${Pawn[exactname,${followpawn}].Distance} > ${followpawndist} && ${Pawn[exactname,${followpawn}].Distance} < 50)
		{
			call movetoobject ${Pawn[exactname,${followpawn}].ID} ${followpawndist} 0
		}
	}
	return
}

; *********************
; **  Pause Routines **
; *********************
function Pause(float delay)
{
	declare DelayTimer int local ${Math.Calc[${LavishScript.RunningTime}+(1000*${delay})]}

   	while ${LavishScript.RunningTime}<${DelayTimer}
 	{
		waitframe 
	}
}
; ***********************************************
function MeCasting(string CP)
{
	wait 3
	debuglog "Waiting After Cast"
	;Sub to wait till casting is complete before running the next command
	while ${Me.IsCasting}
	{
		if ${CP.Equal[While]} || ${CP.Equal[Both]}
		{
			call EmergencyActions
		}
		elseif ${CP.Equal[Neither]} || ${CP.Equal[Post]}
		{
		}
		
		waitframe
	}

	while (${VG.InGlobalRecovery} || ${Me.ToPawn.IsStunned} || !${Me.Ability[Torch].IsReady})
	{
		waitframe
	}


	if ${Me.Target.IsDead} || ${Me.TargetHealth} == 0
	{
		lastattack:Set[None]
		newattack:Set[TRUE]
	}
	if ${x_type.Equal[Heal]}
		HealTimer:Set[${SlowHeals}]
	if ${doSlowAttacks}
		wait ${SlowAttacks}
	debuglog "Done Waiting, Continue Fighting"
	if ${CP.Equal[Both]} || ${CP.Equal[Post]}
	{
		call PostCastingActions
	}
	return
}


; ******************
; ** Timer Object **
; ******************
objectdef Timer
{
	variable uint EndTime
	
	method Set(uint Milliseconds)
	{
	 	EndTime:Set[${Milliseconds}+${Script.RunningTime}]
	}
	member:uint TimeLeft()
	{
	 	if ${Script.RunningTime}>=${EndTime}
	    	return 0
	 	return ${Math.Calc[${EndTime}-${Script.RunningTime}]}
	}
} 

variable Timer Timer

function MH_Clock()
{
   ;MH_Timer:Set[1234]
   ;Note: Above time is in ms - so the above is 1.234 seconds
   echo ${MH_Timer.TimeLeft}ms remaining
   Wait 99999 !${MH_Timer.TimeLeft}
   echo Time's up!
}
atom ParseLog(string aText) 
{
	if ${doParser}
	{
		UIElement[DebugList@LogsCFrm@Logs@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${aText}]
	}
}
atom actionlog(string aText) 
{
	if ${doActionLog}
	{
		UIElement[DebugList@LogsCFrm@Logs@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${aText}]
	}
}
atom Grplog(string aText) 
{
	UIElement[GroupMemberList@HealPctCFrm@HealPct@HealerSubTab@HealerFrm@Healer@ABot@vga_gui]:AddItem[${aText}]

}
atom debuglog(string aText) 
{
	if ${doDeBug}
	{
		UIElement[DebugList@LogsCFrm@Logs@MainSubTab@MainFrm@Main@ABot@vga_gui]:AddItem[${aText}]
	}
}


objectdef HealTimer
{
	variable uint EndTime
	
	method Set(uint Milliseconds)
	{
	 	EndTime:Set[${Milliseconds}+${Script.RunningTime}]
	}
	member:uint TimeLeft()
	{
	 	if ${Script.RunningTime}>=${EndTime}
	    	return 0
	 	return ${Math.Calc[${EndTime}-${Script.RunningTime}]}
	}
} 
variable HealTimer HealTimer

objectdef BuffTimer
{
	variable uint EndTime
	
	method Set(uint Milliseconds)
	{
	 	EndTime:Set[${Milliseconds}+${Script.RunningTime}]
	}
	member:uint TimeLeft()
	{
	 	if ${Script.RunningTime}>=${EndTime}
	    	return 0
	 	return ${Math.Calc[${EndTime}-${Script.RunningTime}]}
	}
} 
variable BuffTimer BuffTimer
;*********************************
atom cleardebug()
{
	UIElement[DebugList@LogsCFrm@Logs@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
	if ${ParseCount}<7
	{
		ParseCount:Inc
	}
	if ${ParseCount}>6
	{
		UIElement[ParseList@LogsCFrm@Logs@MainSubTab@MainFrm@Main@ABot@vga_gui]:ClearItems
		ParseCount:Set[0]
	}
}
