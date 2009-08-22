﻿/* NOTE: The warlock implementation is nowhere near complete.
 */

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace EQ2GlassCannon
{
	public class WarlockController : SorcererController
	{
		public List<string> m_astrShroudTargets = new List<string>();
		public List<string> m_astrGraspTargets = new List<string>();

		public int m_iGroupCastingSkillBuffAbilityID = -1;
		public int m_iGroupNoxiousBuffAbilityID = -1;
		public int m_iGiftAbilityID = -1;
		public int m_iNetherealmAbilityID = -1;
		public int m_iSingleDamageShieldBuffAbilityID = -1;
		public int m_iSingleMeleeProcBuffAbilityID = -1;
		public int m_iNullmailAbilityID = -1;

		public int m_iSingleSTRINTDebuffAbilityID = -1;
		public int m_iSingleBasicNukeAbilityID = -1;
		public int m_iSinglePrimaryPoisonNukeAbilityID = -1;
		public int m_iSingleUnresistableDOTAbilityID = -1;
		public int m_iSingleMediumNukeDOTAbilityID = -1;
		public int m_iSingleColdStunNukeAbilityID = -1;
		public int m_iGreenNoxiousDebuffAbilityID = -1;
		public int m_iGreenPoisonStunNukeAbilityID = -1;
		public int m_iGreenPoisonDOTAbilityID = -1;
		public int m_iGreenDiseaseNukeAbilityID = -1;
		public int m_iGreenDeaggroAbilityID = -1;
		public int m_iBluePoisonAEAbilityID = -1;
		public int m_iBlueMagicKnockbackAEAbilityID = -1;

		/************************************************************************************/
		protected override void TransferINISettings(IniFile ThisFile)
		{
			base.TransferINISettings(ThisFile);

			ThisFile.TransferStringList("Warlock.ShroudTargets", m_astrShroudTargets);
			ThisFile.TransferStringList("Warlock.GraspTargets", m_astrGraspTargets);
			return;
		}

		/************************************************************************************/
		public override void RefreshKnowledgeBook()
		{
			base.RefreshKnowledgeBook();

			/// Buffs.
			m_iGroupCastingSkillBuffAbilityID = SelectHighestTieredAbilityID("Dark Pact");
			m_iGroupNoxiousBuffAbilityID = SelectHighestTieredAbilityID("Aspect of Darkness");
			m_iGiftAbilityID = SelectHighestTieredAbilityID("Gift of Bertoxxulous");
			m_iNetherealmAbilityID = SelectHighestTieredAbilityID("Netherealm");
			m_iSingleDamageShieldBuffAbilityID = SelectHighestTieredAbilityID("Shroud of Bertoxxulous");
			m_iSingleMeleeProcBuffAbilityID = SelectHighestTieredAbilityID("Grasp of Bertoxxulous");
			m_iNullmailAbilityID = SelectHighestAbilityID("Nullmail");
			m_iHateTransferAbilityID = SelectHighestTieredAbilityID("Boon of the Damned");

			m_iSinglePowerFeedAbilityID = SelectHighestTieredAbilityID("Mana Trickle");
			m_iSingleBasicNukeAbilityID = SelectHighestTieredAbilityID("Dissolve");
			m_iSinglePrimaryPoisonNukeAbilityID = SelectHighestTieredAbilityID("Distortion");
			m_iSingleUnresistableDOTAbilityID = SelectHighestTieredAbilityID("Poison");
			m_iSingleMediumNukeDOTAbilityID = SelectHighestTieredAbilityID("Dark Pyre");
			m_iSingleColdStunNukeAbilityID = SelectHighestTieredAbilityID("Encase");
			m_iSingleSTRINTDebuffAbilityID = SelectHighestTieredAbilityID("Curse of Void");
			m_iGreenNoxiousDebuffAbilityID = SelectHighestTieredAbilityID("Vacuum Field");
			m_iGreenPoisonStunNukeAbilityID = SelectHighestTieredAbilityID("Dark Nebula");
			m_iGreenPoisonDOTAbilityID = SelectHighestTieredAbilityID("Apocalypse");
			m_iGreenDiseaseNukeAbilityID = SelectHighestTieredAbilityID("Absolution");
			m_iGreenDeaggroAbilityID = SelectHighestTieredAbilityID("Nullify");
			m_iBluePoisonAEAbilityID = SelectHighestTieredAbilityID("Cataclysm");
			m_iBlueMagicKnockbackAEAbilityID = SelectHighestTieredAbilityID("Rift");

			return;
		}

		/************************************************************************************/
		public override bool DoNextAction()
		{
			if (base.DoNextAction() || MeActor.IsDead)
				return true;

			GetOffensiveTargetActor();
			bool bOffensiveTargetEngaged = EngageOffensiveTarget();

			if (IsCasting)
			{
				if (bOffensiveTargetEngaged && CastAmbidextrousCasting())
					return true;

				return true;
			}

			if (AttemptCureArcane())
				return true;
			if (UseSpellGeneratedHealItem())
				return true;
			if (CastEmergencyPowerFeed())
				return true;

			if (m_bCheckBuffsNow)
			{
				if (CheckToggleBuff(m_iWardOfSagesAbilityID, true))
					return true;

				if (CheckToggleBuff(m_iMagisShieldingAbilityID, true))
					return true;

				if (CheckToggleBuff(m_iNullmailAbilityID, true))
					return true;

				if (CheckToggleBuff(m_iGroupCastingSkillBuffAbilityID, true))
					return true;

				if (CheckToggleBuff(m_iGroupNoxiousBuffAbilityID, true))
					return true;

				if (CheckSingleTargetBuffs(m_iHateTransferAbilityID, m_strHateTransferTarget))
					return true;

				if (CheckSingleTargetBuffs(m_iSingleDamageShieldBuffAbilityID, m_astrShroudTargets))
					return true;

				if (CheckSingleTargetBuffs(m_iSingleMeleeProcBuffAbilityID, m_astrGraspTargets))
					return true;

				if (CheckRacialBuffs())
					return true;

				StopCheckingBuffs();
			}

/* Berrbe says this is his cast order for 1 target:
Netherealm
Gift
Acid storm(when mob is coming)
acid
Vacuum field
Aura
acid
Armageddon(do it 3rd since acid/aura have fast cast and hopefully debuffs will be applied by then!)
Distortion
Acid again
Absolution
Flames
encase
Keep acid running/don't over cas it.
*/

			if (bOffensiveTargetEngaged)
			{
				bool bTempBuffsAdvised = AreTempOffensiveBuffsAdvised();

				if (CastHOStarter())
					return true;

				if (MeActor.IsIdle)
				{
					/// Deaggros.
					if (m_bIHaveAggro)
					{
						if (CastAbility(m_iGreenDeaggroAbilityID))
							return true;

						if (CastAbility(m_iGeneralGreenDeaggroAbilityID))
							return true;
					}

					if (bTempBuffsAdvised)
					{
						if (CastAbilityOnSelf(m_iGiftAbilityID))
							return true;

						if (CastAbilityOnSelf(m_iNetherealmAbilityID))
							return true;
					}

					/// Resistance debuff is ALWAYS first.
					if (m_bUseGreenAEs && !IsAbilityMaintained(m_iGreenNoxiousDebuffAbilityID) && CastGreenOffensiveAbility(m_iGreenNoxiousDebuffAbilityID, 1))
						return true;

					if (!IsAbilityMaintained(m_iSingleSTRINTDebuffAbilityID) && CastAbility(m_iSingleSTRINTDebuffAbilityID))
						return true;

					if (CastBlueOffensiveAbility(m_iBlueMagicKnockbackAEAbilityID, 3))
						return true;
					if (CastBlueOffensiveAbility(m_iBluePoisonAEAbilityID, 7))
						return true;

					if (CastGreenOffensiveAbility(m_iGreenPoisonDOTAbilityID, 4))
						return true;
					if (CastGreenOffensiveAbility(m_iGreenDiseaseNukeAbilityID, 5))
						return true;
					if (CastGreenOffensiveAbility(m_iGreenPoisonStunNukeAbilityID, 6))
						return true;

					if (CastBlueOffensiveAbility(m_iBlueMagicKnockbackAEAbilityID, 2))
						return true;
					if (CastBlueOffensiveAbility(m_iBluePoisonAEAbilityID, 6))
						return true;

					if (CastGreenOffensiveAbility(m_iGreenPoisonDOTAbilityID, 2))
						return true;
					if (CastGreenOffensiveAbility(m_iGreenDiseaseNukeAbilityID, 3))
						return true;
					if (CastGreenOffensiveAbility(m_iGreenPoisonStunNukeAbilityID, 4))
						return true;

					if (CastBlueOffensiveAbility(m_iBluePoisonAEAbilityID, 3))
						return true;

					if (CastAbility(m_iSinglePrimaryPoisonNukeAbilityID))
						return true;

					if (CastAbility(m_iSingleMediumNukeDOTAbilityID))
						return true;

					if (CastAbility(m_iSingleColdStunNukeAbilityID))
						return true;

					if (CastAbility(m_iIceFlameAbilityID))
						return true;

					if (CastAbility(m_iSingleBasicNukeAbilityID))
						return true;

					if (CastAbility(m_iSingleUnresistableDOTAbilityID))
						return true;

					if (CastGreenOffensiveAbility(m_iGreenPoisonDOTAbilityID, 1))
						return true;
					if (CastGreenOffensiveAbility(m_iGreenDiseaseNukeAbilityID, 1))
						return true;
					if (CastGreenOffensiveAbility(m_iGreenPoisonStunNukeAbilityID, 1))
						return true;
					if (CastBlueOffensiveAbility(m_iBluePoisonAEAbilityID, 1))
						return true;
				}
			}

			Program.Log("Nothing left to cast.");
			return false;
		}
	}
}
