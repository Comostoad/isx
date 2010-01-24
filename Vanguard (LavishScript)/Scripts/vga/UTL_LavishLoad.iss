;===================================================
;===               Load XML Data                ====
;===================================================
function loadxmls()
{
	LavishSettings[VGA]:Clear
	LavishSettings[VGA_Mobs]:Clear
	LavishSettings[VGA_General]:Clear
	LavishSettings[VGA_Quests]:Clear
	LavishSettings:AddSet[VGA]
	LavishSettings:AddSet[VGA_Mobs]
	LavishSettings:AddSet[VGA_General]
	LavishSettings:AddSet[VGA_Quests]

	LavishSettings[VGA]:AddSet[Healers]
	LavishSettings[VGA]:AddSet[Utility]
	LavishSettings[VGA]:AddSet[OpeningSpellSequence]
	LavishSettings[VGA]:AddSet[CombatSpellSequence]
	LavishSettings[VGA]:AddSet[AOESpell]
	LavishSettings[VGA]:AddSet[DotSpell]
	LavishSettings[VGA]:AddSet[DebuffSpell]
	LavishSettings[VGA]:AddSet[Spell]
	LavishSettings[VGA]:AddSet[OpeningMeleeSequence]
	LavishSettings[VGA]:AddSet[CombatMeleeSequence]
	LavishSettings[VGA]:AddSet[AOEMelee]
	LavishSettings[VGA]:AddSet[DotMelee]
	LavishSettings[VGA]:AddSet[DebuffMelee]
	LavishSettings[VGA]:AddSet[Melee]
	LavishSettings[VGA]:AddSet[AOECrits]
	LavishSettings[VGA]:AddSet[DotCrits]
	LavishSettings[VGA]:AddSet[BuffCrits]
	LavishSettings[VGA]:AddSet[CombatCrits]
	LavishSettings[VGA]:AddSet[Clickies]
	LavishSettings[VGA]:AddSet[Counter]
	LavishSettings[VGA]:AddSet[Dispell]
	LavishSettings[VGA]:AddSet[StancePush]
	LavishSettings[VGA]:AddSet[TurnOffAttack]
	LavishSettings[VGA]:AddSet[TurnOffDuringBuff]
	LavishSettings[VGA]:AddSet[Crits]
	LavishSettings[VGA]:AddSet[CounterAttack]
	LavishSettings[VGA]:AddSet[Evade]
	LavishSettings[VGA]:AddSet[Evade1]
	LavishSettings[VGA]:AddSet[Evade2]
	LavishSettings[VGA]:AddSet[Buff]
	LavishSettings[VGA]:AddSet[IceA]
	LavishSettings[VGA]:AddSet[FireA]
	LavishSettings[VGA]:AddSet[SpiritualA]
	LavishSettings[VGA]:AddSet[PhysicalA]
	LavishSettings[VGA]:AddSet[ArcaneA]
	LavishSettings[VGA]:AddSet[Triggers]
	LavishSettings[VGA]:AddSet[UseAbilT1]
	LavishSettings[VGA]:AddSet[UseItemsT1]
	LavishSettings[VGA]:AddSet[MobDeBuffT1]
	LavishSettings[VGA]:AddSet[BuffT1]
	LavishSettings[VGA]:AddSet[AbilReadyT1]
	LavishSettings[VGA]:AddSet[Class]
	LavishSettings[VGA]:AddSet[Rescue]
	LavishSettings[VGA]:AddSet[ForceRescue]
	LavishSettings[VGA]:AddSet[HealSequence]
	LavishSettings[VGA]:AddSet[EmergencyHealSequence]

	LavishSettings[VGA_Mobs]:AddSet[Ice]
	LavishSettings[VGA_Mobs]:AddSet[Fire]
	LavishSettings[VGA_Mobs]:AddSet[Spiritual]
	LavishSettings[VGA_Mobs]:AddSet[Physical]
	LavishSettings[VGA_Mobs]:AddSet[Arcane]

	LavishSettings[VGA_General]:AddSet[BW]
	LavishSettings[VGA_General]:AddSet[DBW]
	LavishSettings[VGA_General]:AddSet[TBW]
	LavishSettings[VGA_General]:AddSet[Sell]	
	LavishSettings[VGA_General]:AddSet[Trash]
	LavishSettings[VGA_General]:AddSet[Interactions]	
	LavishSettings[VGA_General]:AddSet[Friends]

	LavishSettings[VGA_Quests]:AddSet[QuestNPCs]
	LavishSettings[VGA_Quests]:AddSet[Quests]

	LavishSettings[VGA]:Import[${LavishScript.CurrentDirectory}/scripts/VGA/Save/${Me.FName}.xml]
	LavishSettings[VGA_Mobs]:Import[${LavishScript.CurrentDirectory}/scripts/VGA/Save/VGA_Mobs.xml]
	LavishSettings[VGA_General]:Import[${LavishScript.CurrentDirectory}/scripts/VGA/Save/VGA_General.xml]
	LavishSettings[VGA_Quests]:Import[${LavishScript.CurrentDirectory}/scripts/VGA/Save/VGA_Quests.xml]

	call LavishLoad
}
;===================================================
;===               Healer Lavish Load           ====
;===================================================
function LavishLoad()
{
	HealerSR:Set[${LavishSettings[VGA].FindSet[Healers]}]
	Buff:Set[${LavishSettings[VGA].FindSet[Buff]}]
	LazyBuff:Set[${HealerSR.FindSetting[LazyBuff]}]
	ResStone:Set[${HealerSR.FindSetting[ResStone]}]
	CombatRes:Set[${HealerSR.FindSetting[CombatRes]}]
	NonCombatRes:Set[${HealerSR.FindSetting[NonCombatRes]}]
	HotHeal:Set[${HealerSR.FindSetting[HotHeal]}]
	InstantHeal:Set[${HealerSR.FindSetting[InstantHeal]}]
	InstantHeal2:Set[${HealerSR.FindSetting[InstantHeal2]}]
	SmallHeal:Set[${HealerSR.FindSetting[SmallHeal]}]
	BigHeal:Set[${HealerSR.FindSetting[BigHeal]}]
	InstantGroupHeal:Set[${HealerSR.FindSetting[InstantGroupHeal]}]
	GroupHeal:Set[${HealerSR.FindSetting[GroupHeal]}]
	hgrp[1]:Set[${HealerSR.FindSetting[hgrp1]}]
	hgrp[2]:Set[${HealerSR.FindSetting[hgrp2]}]
	hgrp[3]:Set[${HealerSR.FindSetting[hgrp3]}]
	hgrp[4]:Set[${HealerSR.FindSetting[hgrp4]}]
	hgrp[5]:Set[${HealerSR.FindSetting[hgrp5]}]
	hgrp[6]:Set[${HealerSR.FindSetting[hgrp6]}]
	hgrp[7]:Set[${HealerSR.FindSetting[hgrp7]}]
	hgrp[8]:Set[${HealerSR.FindSetting[hgrp8]}]
	hgrp[9]:Set[${HealerSR.FindSetting[hgrp9]}]
	hgrp[10]:Set[${HealerSR.FindSetting[hgrp10]}]
	hgrp[11]:Set[${HealerSR.FindSetting[hgrp11]}]
	hgrp[12]:Set[${HealerSR.FindSetting[hgrp12]}]
	hgrp[13]:Set[${HealerSR.FindSetting[hgrp13]}]
	hgrp[14]:Set[${HealerSR.FindSetting[hgrp14]}]
	hgrp[15]:Set[${HealerSR.FindSetting[hgrp15]}]
	hgrp[16]:Set[${HealerSR.FindSetting[hgrp16]}]
	hgrp[17]:Set[${HealerSR.FindSetting[hgrp17]}]
	hgrp[18]:Set[${HealerSR.FindSetting[hgrp18]}]
	hgrp[19]:Set[${HealerSR.FindSetting[hgrp19]}]
	hgrp[20]:Set[${HealerSR.FindSetting[hgrp20]}]
	hgrp[21]:Set[${HealerSR.FindSetting[hgrp21]}]
	hgrp[22]:Set[${HealerSR.FindSetting[hgrp22]}]
	hgrp[23]:Set[${HealerSR.FindSetting[hgrp23]}]
	hgrp[24]:Set[${HealerSR.FindSetting[hgrp24]}]
	ghpctgrp[1]:Set[${HealerSR.FindSetting[ghpctgrp1]}]
	ghpctgrp[2]:Set[${HealerSR.FindSetting[ghpctgrp2]}]
	ghpctgrp[3]:Set[${HealerSR.FindSetting[ghpctgrp3]}]
	ghpctgrp[4]:Set[${HealerSR.FindSetting[ghpctgrp4]}]
	ghpctgrp[5]:Set[${HealerSR.FindSetting[ghpctgrp5]}]
	ghpctgrp[6]:Set[${HealerSR.FindSetting[ghpctgrp6]}]
	ghpctgrp[7]:Set[${HealerSR.FindSetting[ghpctgrp7]}]
	ghpctgrp[8]:Set[${HealerSR.FindSetting[ghpctgrp8]}]
	ghpctgrp[9]:Set[${HealerSR.FindSetting[ghpctgrp9]}]
	ghpctgrp[10]:Set[${HealerSR.FindSetting[ghpctgrp10]}]
	ghpctgrp[11]:Set[${HealerSR.FindSetting[ghpctgrp11]}]
	ghpctgrp[12]:Set[${HealerSR.FindSetting[ghpctgrp12]}]
	ghpctgrp[13]:Set[${HealerSR.FindSetting[ghpctgrp13]}]
	ghpctgrp[14]:Set[${HealerSR.FindSetting[ghpctgrp14]}]
	ghpctgrp[15]:Set[${HealerSR.FindSetting[ghpctgrp15]}]
	ghpctgrp[16]:Set[${HealerSR.FindSetting[ghpctgrp16]}]
	ghpctgrp[17]:Set[${HealerSR.FindSetting[ghpctgrp17]}]
	ghpctgrp[18]:Set[${HealerSR.FindSetting[ghpctgrp18]}]
	ghpctgrp[19]:Set[${HealerSR.FindSetting[ghpctgrp19]}]
	ghpctgrp[20]:Set[${HealerSR.FindSetting[ghpctgrp20]}]
	ghpctgrp[21]:Set[${HealerSR.FindSetting[ghpctgrp21]}]
	ghpctgrp[22]:Set[${HealerSR.FindSetting[ghpctgrp22]}]
	ghpctgrp[23]:Set[${HealerSR.FindSetting[ghpctgrp23]}]
	ghpctgrp[24]:Set[${HealerSR.FindSetting[ghpctgrp24]}]
	ighpctgrp[1]:Set[${HealerSR.FindSetting[ighpctgrp1]}]
	ighpctgrp[2]:Set[${HealerSR.FindSetting[ighpctgrp2]}]
	ighpctgrp[3]:Set[${HealerSR.FindSetting[ighpctgrp3]}]
	ighpctgrp[4]:Set[${HealerSR.FindSetting[ighpctgrp4]}]
	ighpctgrp[5]:Set[${HealerSR.FindSetting[ighpctgrp5]}]
	ighpctgrp[6]:Set[${HealerSR.FindSetting[ighpctgrp6]}]
	ighpctgrp[7]:Set[${HealerSR.FindSetting[ighpctgrp7]}]
	ighpctgrp[8]:Set[${HealerSR.FindSetting[ighpctgrp8]}]
	ighpctgrp[9]:Set[${HealerSR.FindSetting[ighpctgrp9]}]
	ighpctgrp[10]:Set[${HealerSR.FindSetting[ighpctgrp10]}]
	ighpctgrp[11]:Set[${HealerSR.FindSetting[ighpctgrp11]}]
	ighpctgrp[12]:Set[${HealerSR.FindSetting[ighpctgrp12]}]
	ighpctgrp[13]:Set[${HealerSR.FindSetting[ighpctgrp13]}]
	ighpctgrp[14]:Set[${HealerSR.FindSetting[ighpctgrp14]}]
	ighpctgrp[15]:Set[${HealerSR.FindSetting[ighpctgrp15]}]
	ighpctgrp[16]:Set[${HealerSR.FindSetting[ighpctgrp16]}]
	ighpctgrp[17]:Set[${HealerSR.FindSetting[ighpctgrp17]}]
	ighpctgrp[18]:Set[${HealerSR.FindSetting[ighpctgrp18]}]
	ighpctgrp[19]:Set[${HealerSR.FindSetting[ighpctgrp19]}]
	ighpctgrp[20]:Set[${HealerSR.FindSetting[ighpctgrp20]}]
	ighpctgrp[21]:Set[${HealerSR.FindSetting[ighpctgrp21]}]
	ighpctgrp[22]:Set[${HealerSR.FindSetting[ighpctgrp22]}]
	ighpctgrp[23]:Set[${HealerSR.FindSetting[ighpctgrp23]}]
	ighpctgrp[24]:Set[${HealerSR.FindSetting[ighpctgrp24]}]
	hhpctgrp[1]:Set[${HealerSR.FindSetting[hhpctgrp1]}]
	hhpctgrp[2]:Set[${HealerSR.FindSetting[hhpctgrp2]}]
	hhpctgrp[3]:Set[${HealerSR.FindSetting[hhpctgrp3]}]
	hhpctgrp[4]:Set[${HealerSR.FindSetting[hhpctgrp4]}]
	hhpctgrp[5]:Set[${HealerSR.FindSetting[hhpctgrp5]}]
	hhpctgrp[6]:Set[${HealerSR.FindSetting[hhpctgrp6]}]
	hhpctgrp[7]:Set[${HealerSR.FindSetting[hhpctgrp7]}]
	hhpctgrp[8]:Set[${HealerSR.FindSetting[hhpctgrp8]}]
	hhpctgrp[9]:Set[${HealerSR.FindSetting[hhpctgrp9]}]
	hhpctgrp[10]:Set[${HealerSR.FindSetting[hhpctgrp10]}]
	hhpctgrp[11]:Set[${HealerSR.FindSetting[hhpctgrp11]}]
	hhpctgrp[12]:Set[${HealerSR.FindSetting[hhpctgrp12]}]
	hhpctgrp[13]:Set[${HealerSR.FindSetting[hhpctgrp13]}]
	hhpctgrp[14]:Set[${HealerSR.FindSetting[hhpctgrp14]}]
	hhpctgrp[15]:Set[${HealerSR.FindSetting[hhpctgrp15]}]
	hhpctgrp[16]:Set[${HealerSR.FindSetting[hhpctgrp16]}]
	hhpctgrp[17]:Set[${HealerSR.FindSetting[hhpctgrp17]}]
	hhpctgrp[18]:Set[${HealerSR.FindSetting[hhpctgrp18]}]
	hhpctgrp[19]:Set[${HealerSR.FindSetting[hhpctgrp19]}]
	hhpctgrp[20]:Set[${HealerSR.FindSetting[hhpctgrp20]}]
	hhpctgrp[21]:Set[${HealerSR.FindSetting[hhpctgrp21]}]
	hhpctgrp[22]:Set[${HealerSR.FindSetting[hhpctgrp22]}]
	hhpctgrp[23]:Set[${HealerSR.FindSetting[hhpctgrp23]}]
	hhpctgrp[24]:Set[${HealerSR.FindSetting[hhpctgrp24]}]
	fhpctgrp[1]:Set[${HealerSR.FindSetting[fhpctgrp1]}]
	fhpctgrp[2]:Set[${HealerSR.FindSetting[fhpctgrp2]}]
	fhpctgrp[3]:Set[${HealerSR.FindSetting[fhpctgrp3]}]
	fhpctgrp[4]:Set[${HealerSR.FindSetting[fhpctgrp4]}]
	fhpctgrp[5]:Set[${HealerSR.FindSetting[fhpctgrp5]}]
	fhpctgrp[6]:Set[${HealerSR.FindSetting[fhpctgrp6]}]
	fhpctgrp[7]:Set[${HealerSR.FindSetting[fhpctgrp7]}]
	fhpctgrp[8]:Set[${HealerSR.FindSetting[fhpctgrp8]}]
	fhpctgrp[9]:Set[${HealerSR.FindSetting[fhpctgrp9]}]
	fhpctgrp[10]:Set[${HealerSR.FindSetting[fhpctgrp10]}]
	fhpctgrp[11]:Set[${HealerSR.FindSetting[fhpctgrp11]}]
	fhpctgrp[12]:Set[${HealerSR.FindSetting[fhpctgrp12]}]
	fhpctgrp[13]:Set[${HealerSR.FindSetting[fhpctgrp13]}]
	fhpctgrp[14]:Set[${HealerSR.FindSetting[fhpctgrp14]}]
	fhpctgrp[15]:Set[${HealerSR.FindSetting[fhpctgrp15]}]
	fhpctgrp[16]:Set[${HealerSR.FindSetting[fhpctgrp16]}]
	fhpctgrp[17]:Set[${HealerSR.FindSetting[fhpctgrp17]}]
	fhpctgrp[18]:Set[${HealerSR.FindSetting[fhpctgrp18]}]
	fhpctgrp[19]:Set[${HealerSR.FindSetting[fhpctgrp19]}]
	fhpctgrp[20]:Set[${HealerSR.FindSetting[fhpctgrp20]}]
	fhpctgrp[21]:Set[${HealerSR.FindSetting[fhpctgrp21]}]
	fhpctgrp[22]:Set[${HealerSR.FindSetting[fhpctgrp22]}]
	fhpctgrp[23]:Set[${HealerSR.FindSetting[fhpctgrp23]}]
	fhpctgrp[24]:Set[${HealerSR.FindSetting[fhpctgrp24]}]
	hpctgrp[1]:Set[${HealerSR.FindSetting[hpctgrp1]}]
	hpctgrp[2]:Set[${HealerSR.FindSetting[hpctgrp2]}]
	hpctgrp[3]:Set[${HealerSR.FindSetting[hpctgrp3]}]
	hpctgrp[4]:Set[${HealerSR.FindSetting[hpctgrp4]}]
	hpctgrp[5]:Set[${HealerSR.FindSetting[hpctgrp5]}]
	hpctgrp[6]:Set[${HealerSR.FindSetting[hpctgrp6]}]
	hpctgrp[7]:Set[${HealerSR.FindSetting[hpctgrp7]}]
	hpctgrp[8]:Set[${HealerSR.FindSetting[hpctgrp8]}]
	hpctgrp[9]:Set[${HealerSR.FindSetting[hpctgrp9]}]
	hpctgrp[10]:Set[${HealerSR.FindSetting[hpctgrp10]}]
	hpctgrp[11]:Set[${HealerSR.FindSetting[hpctgrp11]}]
	hpctgrp[12]:Set[${HealerSR.FindSetting[hpctgrp12]}]
	hpctgrp[13]:Set[${HealerSR.FindSetting[hpctgrp13]}]
	hpctgrp[14]:Set[${HealerSR.FindSetting[hpctgrp14]}]
	hpctgrp[15]:Set[${HealerSR.FindSetting[hpctgrp15]}]
	hpctgrp[16]:Set[${HealerSR.FindSetting[hpctgrp16]}]
	hpctgrp[17]:Set[${HealerSR.FindSetting[hpctgrp17]}]
	hpctgrp[18]:Set[${HealerSR.FindSetting[hpctgrp18]}]
	hpctgrp[19]:Set[${HealerSR.FindSetting[hpctgrp19]}]
	hpctgrp[20]:Set[${HealerSR.FindSetting[hpctgrp20]}]
	hpctgrp[21]:Set[${HealerSR.FindSetting[hpctgrp21]}]
	hpctgrp[22]:Set[${HealerSR.FindSetting[hpctgrp22]}]
	hpctgrp[23]:Set[${HealerSR.FindSetting[hpctgrp23]}]
	hpctgrp[24]:Set[${HealerSR.FindSetting[hpctgrp24]}]
	bhpctgrp[1]:Set[${HealerSR.FindSetting[bhpctgrp1]}]
	bhpctgrp[2]:Set[${HealerSR.FindSetting[bhpctgrp2]}]
	bhpctgrp[3]:Set[${HealerSR.FindSetting[bhpctgrp3]}]
	bhpctgrp[4]:Set[${HealerSR.FindSetting[bhpctgrp4]}]
	bhpctgrp[5]:Set[${HealerSR.FindSetting[bhpctgrp5]}]
	bhpctgrp[6]:Set[${HealerSR.FindSetting[bhpctgrp6]}]
	bhpctgrp[7]:Set[${HealerSR.FindSetting[bhpctgrp7]}]
	bhpctgrp[8]:Set[${HealerSR.FindSetting[bhpctgrp8]}]
	bhpctgrp[9]:Set[${HealerSR.FindSetting[bhpctgrp9]}]
	bhpctgrp[10]:Set[${HealerSR.FindSetting[bhpctgrp10]}]
	bhpctgrp[11]:Set[${HealerSR.FindSetting[bhpctgrp11]}]
	bhpctgrp[12]:Set[${HealerSR.FindSetting[bhpctgrp12]}]
	bhpctgrp[13]:Set[${HealerSR.FindSetting[bhpctgrp13]}]
	bhpctgrp[14]:Set[${HealerSR.FindSetting[bhpctgrp14]}]
	bhpctgrp[15]:Set[${HealerSR.FindSetting[bhpctgrp15]}]
	bhpctgrp[16]:Set[${HealerSR.FindSetting[bhpctgrp16]}]
	bhpctgrp[17]:Set[${HealerSR.FindSetting[bhpctgrp17]}]
	bhpctgrp[18]:Set[${HealerSR.FindSetting[bhpctgrp18]}]
	bhpctgrp[19]:Set[${HealerSR.FindSetting[bhpctgrp19]}]
	bhpctgrp[20]:Set[${HealerSR.FindSetting[bhpctgrp20]}]
	bhpctgrp[21]:Set[${HealerSR.FindSetting[bhpctgrp21]}]
	bhpctgrp[22]:Set[${HealerSR.FindSetting[bhpctgrp22]}]
	bhpctgrp[23]:Set[${HealerSR.FindSetting[bhpctgrp23]}]
	bhpctgrp[24]:Set[${HealerSR.FindSetting[bhpctgrp24]}]
	doCombatStance:Set[${HealerSR.FindSetting[doCombatStance]}]
	doNonCombatStance:Set[${HealerSR.FindSetting[doNonCombatStance]}]
	CombatStance:Set[${HealerSR.FindSetting[CombatStance]}]
	NonCombatStance:Set[${HealerSR.FindSetting[NonCombatStance]}]
	ClickieForce:Set[${HealerSR.FindSetting[ClickieForce]}]	
  doClickieForce:Set[${HealerSR.FindSetting[doClickieForce]}]	
  doRestoreSpecial:Set[${HealerSR.FindSetting[doRestoreSpecial]}]	
  RestoreSpecialint:Set[${HealerSR.FindSetting[RestoreSpecialint]}]	
  RestoreSpecial:Set[${HealerSR.FindSetting[RestoreSpecial]}]	
DoByPassVGAHeals:Set[${HealerSR.FindSetting[DoByPassVGAHeals]}]	
TankHealPct:Set[${HealerSR.FindSetting[TankHealPct,${TankHealPct}]}]
TankEmerHealPct:Set[${HealerSR.FindSetting[TankEmerHealPct,${TankEmerHealPct}]}]
MedHealPct:Set[${HealerSR.FindSetting[MedHealPct,${MedHealPct}]}]
MedEmerHealPct:Set[${HealerSR.FindSetting[MedEmerHealPct,${MedEmerHealPct}]}]
SquishyHealPct:Set[${HealerSR.FindSetting[SquishyHealPct,${SquishyHealPct}]}]
SquishyEmerHealPct:Set[${HealerSR.FindSetting[SquishyEmerHealPct,${SquishyEmerHealPct}]}]
kiss:Set[${HealerSR.FindSetting[kiss,${kiss}]}]
HealCrit1:Set[${HealerSR.FindSetting[HealCrit1,${HealCrit1}]}]
HealCrit2:Set[${HealerSR.FindSetting[HealCrit2,${HealCrit2}]}]
InstantHotHeal1:Set[${HealerSR.FindSetting[InstantHotHeal1,${InstantHotHeal1}]}]
InstantHotHeal2:Set[${HealerSR.FindSetting[InstantHotHeal2,${InstantHotHeal2}]}]
TapSoloHeal:Set[${HealerSR.FindSetting[TapSoloHeal,${TapSoloHeal}]}]

DoResInCombat:Set[${HealerSR.FindSetting[DoResInCombat,${DoResInCombat}]}]
DoResNotInCombat:Set[${HealerSR.FindSetting[DoResNotInCombat,${DoResNotInCombat}]}]
DoResRaid:Set[${HealerSR.FindSetting[DoResRaid,${DoResRaid}]}]



	;===================================================
	;===                  Utility Load              ====
	;===================================================
	UtilitySR:Set[${LavishSettings[VGA].FindSet[Utility]}]
	doassistpawn:Set[${UtilitySR.FindSetting[doassistpawn]}]
	dofollowpawn:Set[${UtilitySR.FindSetting[dofollowpawn]}]
	followpawndist:Set[${UtilitySR.FindSetting[followpawndist]}]
	MoveToTargetPct:Set[${UtilitySR.FindSetting[MoveToTargetPct]}]
	doMoveToTarget:Set[${UtilitySR.FindSetting[doMoveToTarget]}]
	doFaceTarget:Set[${UtilitySR.FindSetting[doFaceTarget]}]
	DoLoot:Set[${UtilitySR.FindSetting[DoLoot]}]
	AssistBattlePct:Set[${UtilitySR.FindSetting[AssistBattlePct]}]
	SlowHeals:Set[${UtilitySR.FindSetting[SlowHeals]}]
	doParser:Set[${UtilitySR.FindSetting[doParser]}]
	doDebug:Set[${UtilitySR.FindSetting[doDebug]}]
	doActionLog:Set[${UtilitySR.FindSetting[doActionLog]}]
	doSell:Set[${UtilitySR.FindSetting[doSell]}]
	doTrash:Set[${UtilitySR.FindSetting[doTrash]}]
	Sell:Set[${LavishSettings[VGA_General].FindSet[Sell]}]
	Trash:Set[${LavishSettings[VGA_General].FindSet[Trash]}]
	DoChainsASAP:Set[${UtilitySR.FindSetting[FALSE,FALSE]}]
	DoCountersASAP:Set[${UtilitySR.FindSetting[FALSE,FALSE]}]
	DoMount:Set[${UtilitySR.FindSetting[DoMount,FALSE]}]
	DoShiftingImage:Set[${UtilitySR.FindSetting[DoShiftingImage,FALSE]}]
	ShiftingImage:Set[${UtilitySR.FindSetting[ShiftingImage,TRUE]}]
	DoAutoAcceptGroupInvite:Set[${UtilitySR.FindSetting[DoAutoAcceptGroupInvite,TRUE]}]
	DoLooseTarget:Set[${UtilitySR.FindSetting[DoLooseTarget,${DoLooseTarget}]}]
	AssistEncounter:Set[${UtilitySR.FindSetting[AssistEncounter,${AssistEncounter}]}]
	DoFollowInCombat:Set[${UtilitySR.FindSetting[DoFollowInCombat,${DoFollowInCombat}]}]
	doAutoSell:Set[${UtilitySR.FindSetting[doAutoSell,${doAutoSell}]}]
	doHarvest:Set[${UtilitySR.FindSetting[doHarvest,${doHarvest}]}]
	DoLootOnly:Set[${UtilitySR.FindSetting[DoLootOnly,${DoLootOnly}]}]
	LootOnly:Set[${UtilitySR.FindSetting[LootOnly,${LootOnly}]}]
	LootDelay:Set[${UtilitySR.FindSetting[LootDelay,${LootDelay}]}]	

	DoClassDownTime:Set[${UtilitySR.FindSetting[DoClassDownTime,${DoClassDownTime}]}]
	DoClassPreCombat:Set[${UtilitySR.FindSetting[DoClassPreCombat,${DoClassPreCombat}]}]	
	DoClassOpener:Set[${UtilitySR.FindSetting[DoClassOpener,${DoClassOpener}]}]
	DoClassCombat:Set[${UtilitySR.FindSetting[DoClassCombat,${DoClassCombat}]}]	
	DoClassPostCombat:Set[${UtilitySR.FindSetting[DoClassPostCombat,${DoClassPostCombat}]}]
	DoClassEmergency:Set[${UtilitySR.FindSetting[DoClassEmergency,${DoClassEmergency}]}]	
	DoClassPostCasting:Set[${UtilitySR.FindSetting[DoClassPostCasting,${DoClassPostCasting}]}]

	DoAttackPositionFront:Set[${UtilitySR.FindSetting[DoAttackPositionFront,${DoAttackPositionFront}]}]
	DoAttackPositionLeft:Set[${UtilitySR.FindSetting[DoAttackPositionLeft,${DoAttackPositionLeft}]}]
	DoAttackPositionRight:Set[${UtilitySR.FindSetting[DoAttackPositionRight,${DoAttackPositionRight}]}]
	DoAttackPositionBack:Set[${UtilitySR.FindSetting[DoAttackPositionBack,${DoAttackPositionBack}]}]
	DoAttackPosition:Set[${UtilitySR.FindSetting[DoAttackPosition,${DoAttackPosition}]}]
	DoPopCrates:Set[${UtilitySR.FindSetting[DoPopCrates,${DoPopCrates}]}]

	Friends:Set[${LavishSettings[VGA_General].FindSet[Friends]}]

	DoAcceptRes:Set[${UtilitySR.FindSetting[DoAcceptRes,${DoAcceptRes}]}]
	Speed:Set[${UtilitySR.FindSetting[Speed,${Speed}]}]
	DoAutoResCombat:Set[${UtilitySR.FindSetting[DoAutoResCombat,${DoAutoResCombat}]}]
	DoAutoResNoCombat:Set[${UtilitySR.FindSetting[DoAutoResNoCombat,${DoAutoResNoCombat}]}]

	DoChargeFollow:Set[${UtilitySR.FindSetting[DoChargeFollow,${DoChargeFollow}]}]
	;===================================================
	;===                  Spells Load               ====
	;===================================================
	OpeningSpellSequence:Set[${LavishSettings[VGA].FindSet[OpeningSpellSequence]}]
	CombatSpellSequence:Set[${LavishSettings[VGA].FindSet[CombatSpellSequence]}]
	AOESpell:Set[${LavishSettings[VGA].FindSet[AOESpell]}]
	DotSpell:Set[${LavishSettings[VGA].FindSet[DotSpell]}]
	DebuffSpell:Set[${LavishSettings[VGA].FindSet[DebuffSpell]}]
	SpellSR:Set[${LavishSettings[VGA].FindSet[Spell]}]
	
	doOpeningSeqSpell:Set[${SpellSR.FindSetting[doOpeningSeqSpell]}]
	doCritsDuringOpeningSeqSpell:Set[${SpellSR.FindSetting[doCritsDuringOpeningSeqSpell]}]
	doCombatSeqSpell:Set[${SpellSR.FindSetting[doCombatSeqSpell]}]
	doAOESpell:Set[${SpellSR.FindSetting[doAOESpell]}]
	doDotSpell:Set[${SpellSR.FindSetting[doDotSpell]}]
	doDebuffSpell:Set[${SpellSR.FindSetting[doDebuffSpell]}]
	DispellSpell:Set[${SpellSR.FindSetting[DispellSpell]}]
	PushStanceSpell:Set[${SpellSR.FindSetting[PushStanceSpell]}]
	CounterSpell1:Set[${SpellSR.FindSetting[CounterSpell1]}]
	CounterSpell2:Set[${SpellSR.FindSetting[CounterSpell2]}]
	doSlowAttacks:Set[${SpellSR.FindSetting[doSlowAttacks]}]
	SlowAttacks:Set[${SpellSR.FindSetting[SlowAttacks]}]
	
	;===================================================
	;===                  Mobs Load                 ====
	;===================================================
	Ice:Set[${LavishSettings[VGA_Mobs].FindSet[Ice]}]
	Fire:Set[${LavishSettings[VGA_Mobs].FindSet[Fire]}]
	Spiritual:Set[${LavishSettings[VGA_Mobs].FindSet[Spiritual]}]
	Physical:Set[${LavishSettings[VGA_Mobs].FindSet[Physical]}]
	Arcane:Set[${LavishSettings[VGA_Mobs].FindSet[Arcane]}]
	
	;===================================================
	;===                  Melee Load                ====
	;===================================================
	OpeningMeleeSequence:Set[${LavishSettings[VGA].FindSet[OpeningMeleeSequence]}]
	CombatMeleeSequence:Set[${LavishSettings[VGA].FindSet[CombatMeleeSequence]}]
	AOEMelee:Set[${LavishSettings[VGA].FindSet[AOEMelee]}]
	DotMelee:Set[${LavishSettings[VGA].FindSet[DotMelee]}]
	DebuffMelee:Set[${LavishSettings[VGA].FindSet[DebuffMelee]}]
	Melee:Set[${LavishSettings[VGA].FindSet[Melee]}]
	
	doOpeningSeqMelee:Set[${Melee.FindSetting[doOpeningSeqMelee]}]
	doCritsDuringOpeningSeqMelee:Set[${Melee.FindSetting[doCritsDuringOpeningSeqMelee]}]
	doCombatSeqMelee:Set[${Melee.FindSetting[doCombatSeqMelee]}]
	doAOEMelee:Set[${Melee.FindSetting[doAOEMelee]}]
	doDotMelee:Set[${Melee.FindSetting[doDotMelee]}]
	doDebuffMelee:Set[${Melee.FindSetting[doDebuffMelee]}]
	doKillingBlow:Set[${Melee.FindSetting[doKillingBlow]}]
	KillingBlow:Set[${Melee.FindSetting[KillingBlow]}]	
	;===================================================
	;===                  Evade Load                ====
	;===================================================
	Evade1:Set[${LavishSettings[VGA].FindSet[Evade1]}]
	Evade2:Set[${LavishSettings[VGA].FindSet[Evade2]}]
	Evade:Set[${LavishSettings[VGA].FindSet[Evade]}]
	Rescue:Set[${LavishSettings[VGA].FindSet[Rescue]}]
	ForceRescue:Set[${LavishSettings[VGA].FindSet[ForceRescue]}]
	
	agropush:Set[${Evade.FindSetting[agropush]}]
	doPushAgro:Set[${Evade.FindSetting[doPushAgro]}]
	doRescue:Set[${Evade.FindSetting[doRescue]}]
	doInvoln1:Set[${Evade.FindSetting[doInvoln1]}]
	doInvoln2:Set[${Evade.FindSetting[doInvoln2]}]
	doEvade1:Set[${Evade.FindSetting[doEvade1]}]
	doEvade2:Set[${Evade.FindSetting[doEvade2]}]
	doFD:Set[${Evade.FindSetting[doFD]}]
	FDPct:Set[${Evade.FindSetting[FDPct]}]
	Involn1Pct:Set[${Evade.FindSetting[Involn1Pct]}]
	Involn2Pct:Set[${Evade.FindSetting[Involn2Pct]}]
	FD:Set[${Evade.FindSetting[FD]}]
	Involn1:Set[${Evade.FindSetting[Involn1]}]
	Involn2:Set[${Evade.FindSetting[Involn2]}]
	HealerSR:Set[${LavishSettings[VGA].FindSet[Healers]}]
	
	;===================================================
	;===                  Crits Load                ====
	;===================================================
	AOECrits:Set[${LavishSettings[VGA].FindSet[AOECrits]}]
	BuffCrits:Set[${LavishSettings[VGA].FindSet[BuffCrits]}]
	DotCrits:Set[${LavishSettings[VGA].FindSet[DotCrits]}]
	CombatCrits:Set[${LavishSettings[VGA].FindSet[CombatCrits]}]
	CounterAttack:Set[${LavishSettings[VGA].FindSet[CounterAttack]}]
	Crits:Set[${LavishSettings[VGA].FindSet[Crits]}]
	
	doCombatCrits:Set[${Crits.FindSetting[doCombatCrits]}]
	doBuffCrits:Set[${Crits.FindSetting[doBuffCrits]}]
	doDotCrits:Set[${Crits.FindSetting[doDotCrits]}]
	doAOECrits:Set[${Crits.FindSetting[doAOECrits]}]
	doCounterAttack:Set[${Crits.FindSetting[doCounterAttack]}]
	
	;===================================================
	;===            Combat Main Load                ====
	;===================================================
	Clickies:Set[${LavishSettings[VGA].FindSet[Clickies]}]
	Dispell:Set[${LavishSettings[VGA].FindSet[Dispell]}]
	StancePush:Set[${LavishSettings[VGA].FindSet[StancePush]}]
	TurnOffAttack:Set[${LavishSettings[VGA].FindSet[TurnOffAttack]}]
	TurnOffDuringBuff:Set[${LavishSettings[VGA].FindSet[TurnOffDuringBuff]}]
	Counter:Set[${LavishSettings[VGA].FindSet[Counter]}]
	
	doClickies:Set[${SpellSR.FindSetting[doClickies]}]
	doDispell:Set[${SpellSR.FindSetting[doDispell]}]
	doStancePush:Set[${SpellSR.FindSetting[doStancePush]}]
	doTurnOffAttack:Set[${SpellSR.FindSetting[doTurnOffAttack]}]
	doCounter:Set[${SpellSR.FindSetting[doCounter]}]
	doFurious:Set[${SpellSR.FindSetting[doFurious]}]
	
	;===================================================
	;===              Abilities Load                ====
	;===================================================
	IceA:Set[${LavishSettings[VGA].FindSet[IceA]}]
	FireA:Set[${LavishSettings[VGA].FindSet[FireA]}]
	SpiritualA:Set[${LavishSettings[VGA].FindSet[SpiritualA]}]
	PhysicalA:Set[${LavishSettings[VGA].FindSet[PhysicalA]}]
	ArcaneA:Set[${LavishSettings[VGA].FindSet[ArcaneA]}]
	
	
	;===================================================
	;===              BuffWatch Load                ====
	;===================================================
	TBW:Set[${LavishSettings[VGA_General].FindSet[TBW]}]
	DBW:Set[${LavishSettings[VGA_General].FindSet[DBW]}]
	BW:Set[${LavishSettings[VGA_General].FindSet[BW]}]
	
	;===================================================
	;===             Triggers   Load                ====
	;===================================================
	UseAbilT1:Set[${LavishSettings[VGA].FindSet[UseAbilT1]}]
	UseItemsT1:Set[${LavishSettings[VGA].FindSet[UseItemsT1]}]
	MobDeBuffT1:Set[${LavishSettings[VGA].FindSet[MobDeBuffT1]}]
	BuffT1:Set[${LavishSettings[VGA].FindSet[BuffT1]}]
	AbilReadyT1:Set[${LavishSettings[VGA].FindSet[AbilReadyT1]}]
	
	Triggers:Set[${LavishSettings[VGA].FindSet[Triggers]}]
	doTrigger1:Set[${Triggers.FindSetting[doTrigger1,${doTrigger1}]}]
	doWeaknessT1:Set[${Triggers.FindSetting[doWeaknessT1,${doWeaknessT1}]}]
	WeaknessT1:Set[${Triggers.FindSetting[WeaknessT1,${WeaknessT1}]}]
	doCritsT1:Set[${Triggers.FindSetting[doCritsT1,${doCritsT1}]}]
	CritsT1:Set[${Triggers.FindSetting[CritsT1,${CritsT1}]}]
	doHealthT1:Set[${Triggers.FindSetting[doHealthT1,${doHealthT1}]}]
	MinHealthT1:Set[${Triggers.FindSetting[MinHealthT1,${MinHealthT1}]}]
	MaxHealthT1:Set[${Triggers.FindSetting[MaxHealthT1,${MaxHealthT1}]}]
	doAbilReadyT1:Set[${Triggers.FindSetting[doAbilReadyT1,${doAbilReadyT1}]}]
	doIncTextT1:Set[${Triggers.FindSetting[doIncTextT1,${doIncTextT1}]}]
	IncTextT1:Set[${Triggers.FindSetting[IncTextT1,${IncTextT1}]}]
	doBuffT1:Set[${Triggers.FindSetting[doBuffT1,${doBuffT1}]}]
	doMobDeBuffT1:Set[${Triggers.FindSetting[doMobDeBuffT1,${doMobDeBuffT1}]}]
	doMobBuffT1:Set[${Triggers.FindSetting[doMobBuffT1,${doMobBuffT1}]}]
	MobBuffT1:Set[${Triggers.FindSetting[MobBuffT1,${MobBuffT1}]}]
	doSpecialT1:Set[${Triggers.FindSetting[doSpecialT1,${doSpecialT1}]}]
	SpecialT1:Set[${Triggers.FindSetting[SpecialT1,${SpecialT1}]}]
	doLoseAgroT1:Set[${Triggers.FindSetting[doLoseAgroT1,${doLoseAgroT1}]}]
	doGainAgroT1:Set[${Triggers.FindSetting[doGainAgroT1,${doGainAgroT1}]}]
	doOtherAgroT1:Set[${Triggers.FindSetting[doOtherAgroT1,${doOtherAgroT1}]}]
	doSwapStanceT1:Set[${Triggers.FindSetting[doSwapStanceT1,${doSwapStanceT1}]}]
	SwapStanceT1:Set[${Triggers.FindSetting[SwapStanceT1,${SwapStanceT1}]}]
	doSwitchSongsT1:Set[${Triggers.FindSetting[doSwitchSongsT1,${doSwitchSongsT1}]}]
	SwitchSongsT1:Set[${Triggers.FindSetting[SwitchSongsT1,${SwitchSongsT1}]}]
	doSwapWeaponsT1:Set[${Triggers.FindSetting[doSwapWeaponsT1,${doSwapWeaponsT1}]}]
	SWPrimaryT1:Set[${Triggers.FindSetting[SWPrimaryT1,${SWPrimaryT1}]}]
	SWSecondaryT1:Set[${Triggers.FindSetting[SWSecondaryT1,${SWSecondaryT1}]}]
	doUseItemsT1:Set[${Triggers.FindSetting[doUseItemsT1,${doUseItemsT1}]}]
	doUseAbilT1:Set[${Triggers.FindSetting[doUseAbilT1,${doUseAbilT1}]}]
	LastSongT1:Set[${Triggers.FindSetting[LastSongT1,${LastSongT1}]}]
	LastPrimaryT1:Set[${Triggers.FindSetting[LastPrimaryT1,${LastPrimaryT1}]}]
	LastSecondaryT1:Set[${Triggers.FindSetting[LastSecondaryT1,${LastSecondaryT1}]}]
	LastStanceT1:Set[${Triggers.FindSetting[LastStanceT1,${LastStanceT1}]}]

	;===================================================
	;===            Interactions   Load             ====
	;===================================================
	Interactions:Set[${LavishSettings[VGA_General].FindSet[Interactions]}]
	doRequestBuffs[1]:Set[${Interactions.FindSetting[doRequestBuff1]}]
	RequestBuff[1]:Set[${Interactions.FindSetting[RequestBuff1]}]
	RequestBuffPlayer[1]:Set[${Interactions.FindSetting[RequestBuffPlayer1]}]
	TellRequestBuffPlayer[1]:Set[${Interactions.FindSetting[TellRequestBuffPlayer1]}]
	doRequestBuffs[2]:Set[${Interactions.FindSetting[doRequestBuffs2]}]
	RequestBuff[2]:Set[${Interactions.FindSetting[RequestBuff2]}]
	RequestBuffPlayer[2]:Set[${Interactions.FindSetting[RequestBuffPlayer2]}]
	TellRequestBuffPlayer[2]:Set[${Interactions.FindSetting[TellRequestBuffPlayer2]}]
	doRequestBuffs[3]:Set[${Interactions.FindSetting[doRequestBuffs3]}]
	RequestBuff[3]:Set[${Interactions.FindSetting[RequestBuff3]}]
	RequestBuffPlayer[3]:Set[${Interactions.FindSetting[RequestBuffPlayer3]}]
	TellRequestBuffPlayer[3]:Set[${Interactions.FindSetting[TellRequestBuffPlayer3]}]
	doRequestBuffs[4]:Set[${Interactions.FindSetting[doRequestBuffs4]}]
	RequestBuff[4]:Set[${Interactions.FindSetting[RequestBuff4]}]
	RequestBuffPlayer[4]:Set[${Interactions.FindSetting[RequestBuffPlayer4]}]
	TellRequestBuffPlayer[4]:Set[${Interactions.FindSetting[TellRequestBuffPlayer4]}]
	doRequestItems[1]:Set[${Interactions.FindSetting[doRequestItems1]}]
	RequestItems[1]:Set[${Interactions.FindSetting[RequestItems1]}]
	RequestItemsPlayer[1]:Set[${Interactions.FindSetting[RequestItemsPlayer1]}]
	TellRequestItemsPlayer[1]:Set[${Interactions.FindSetting[TellRequestItemsPlayer1]}]
	doRequestItems[2]:Set[${Interactions.FindSetting[doRequestItems2]}]
	RequestItems[2]:Set[${Interactions.FindSetting[RequestItems2]}]
	RequestItemsPlayer[2]:Set[${Interactions.FindSetting[RequestItemsPlayer2]}]
	TellRequestItemsPlayer[2]:Set[${Interactions.FindSetting[TellRequestItemsPlayer2]}]
	DoStopFollow:Set[${Interactions.FindSetting[DoStopFollow,${DoStopFollow}]}]
	StopFollowtxt:Set[${Interactions.FindSetting[StopFollowtxt,${StopFollowtxt}]}]
	DoStartFollow:Set[${Interactions.FindSetting[DoStartFollow,${DoStartFollow}]}]
	StartFollowtxt:Set[${Interactions.FindSetting[StartFollowtxt,${StartFollowtxt}]}]
	DoKillLevitate:Set[${Interactions.FindSetting[DoKillLevitate,${DoKillLevitate}]}]
	KillingLevitate:Set[${Interactions.FindSetting[KillingLevitate,${KillingLevitate}]}]
	DoReassistTank:Set[${Interactions.FindSetting[DoReassistTank,${DoReassistTank}]}]
	ReassistingTank:Set[${Interactions.FindSetting[ReassistingTank,${ReassistingTank}]}]
	DoPause:Set[${Interactions.FindSetting[DoPause,${DoPause}]}]
	Pausetxt:Set[${Interactions.FindSetting[Pausetxt,${Pausetxt}]}]
	DoBuffage:Set[${Interactions.FindSetting[DoBuffage,${DoBuffage}]}]
	Buffagetxt:Set[${Interactions.FindSetting[Buffagetxt,${Buffagetxt}]}]
	DoResume:Set[${Interactions.FindSetting[DoResume,${DoResume}]}]
	Resumetxt:Set[${Interactions.FindSetting[Resumetxt,${Resumetxt}]}]
	
	Class:Set[${LavishSettings[VGA].FindSet[Class]}]
	switch ${Me.Class}
	{
		case Bard
			PrimaryWeapon:Set[${Class.FindSetting[PrimaryWeapon,${PrimaryWeapon}]}]
			SecondaryWeapon:Set[${Class.FindSetting[SecondaryWeapon,${SecondaryWeapon}]}]
			FightSong:Set[${Class.FindSetting[FightSong,${FightSong}]}]
			RunSong:Set[${Class.FindSetting[RunSong,${RunSong}]}]
			Drum:Set[${Class.FindSetting[Drum,${Drum}]}]
			break
			
		case Blood Mage
			BMHealthToEnergySpell:Set[${Class.FindSetting[BMHealthToEnergySpell,${BMHealthToEnergySpell}]}]
			BMBloodUnionDumpDPSSpell:Set[${Class.FindSetting[BMBloodUnionDumpDPSSpell,${BMBloodUnionDumpDPSSpell}]}]
			BMSingleTargetLifeTap1:Set[${Class.FindSetting[BMSingleTargetLifeTap1,${BMSingleTargetLifeTap1}]}]
			BMSingleTargetLifeTap2:Set[${Class.FindSetting[BMSingleTargetLifeTap2,${BMSingleTargetLifeTap2}]}]
			BMBloodUnionSingleTargetHOT:Set[${Class.FindSetting[BMBloodUnionSingleTargetHOT,${BMBloodUnionSingleTargetHOT}]}]
			break
	}
	;===================================================
	;===                 Quests   Load              ====
	;===================================================
	
	QuestNPCs:Set[${LavishSettings[VGA_Quests].FindSet[QuestNPCs]}]
	Quests:Set[${LavishSettings[VGA_Quests].FindSet[Quests]}]
}
