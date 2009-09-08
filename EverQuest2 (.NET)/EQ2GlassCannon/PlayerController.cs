﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Diagnostics;
using System.Drawing;
using EQ2.ISXEQ2;
using InnerSpaceAPI;
using LavishVMAPI;
using System.IO;

namespace EQ2GlassCannon
{
	public partial class PlayerController
	{
		public const string STR_NO_KILL_NPC = "NoKill NPC";

		public uint m_uiLoreAndLegendAbilityID = 0;
		public uint m_uiHOStarterAbiltyID = 0;
		public uint m_uiFeatherfallAbilityID = 0;
		public uint m_uiHalfElfMitigationDebuffAbilityID = 0;
		public uint m_uiFurySalveHealAbilityID = 0;

		public uint m_uiCollectingAbilityID = 0;
		public uint m_uiGatheringAbilityID = 0;
		public uint m_uiMiningAbilityID = 0;
		public uint m_uiForestingAbilityID = 0;
		public uint m_uiTrappingAbilityID = 0;
		public uint m_uiFishingAbilityID = 0;

		/************************************************************************************/
		public enum PositioningStance
		{
			DoNothing = 0,
			NeutralPosition,
			AutoFollow,
			CustomAutoFollow,
			StayInPlace,
			ForwardDash,
			ChatWatch,
			SpawnWatch,
			DespawnWatch,
		}

		/************************************************************************************/
		public enum ChatChannel : int
		{
			Unknown = 0,
			Say,
			Tell,
			Named,
			Auction,
			OutOfCharacter,
			Shout,
			Raid,
			Group,
			Guild,
			Officer,
		}

		/************************************************************************************/
		public class Point3D
		{
			public float X = 0.0f;
			public float Y = 0.0f;
			public float Z = 0.0f;

			public Point3D()
			{
				return;
			}

			public Point3D(Actor SourceActor)
			{
				X = SourceActor.X;
				Y = SourceActor.Y;
				Z = SourceActor.Z;
				return;
			}
		}

		/************************************************************************************/
		public class CustomTellTrigger
		{
			public List<string> m_astrSourcePlayers = new List<string>();
			public string m_strSubstring = string.Empty;
			public List<string> m_astrCommands = new List<string>();
		}

		public bool m_bContinueBot = true;
		public Point3D m_ptMyLastLocation = new Point3D();

		protected bool m_bCheckBuffsNow = true;
		public bool m_bIHaveAggro = false;
		public bool m_bClearGroupMaintained = false;
		public bool m_bLastShadowTargetSamplingWasNearby = false;
		public DateTime m_LastCheckBuffsTime = DateTime.Now;
		public int m_iOffensiveTargetID = -1;
		public Actor m_OffensiveTargetActor = null;
		public int m_iAbilitiesFound = 0;
		protected Point3D m_ptStayLocation = new Point3D();
		public double m_fCurrentMovementTargetCoordinateTolerance = 0.0f;
		protected string m_strPositionalCommandingPlayer = string.Empty;
		protected string m_strCurrentMainTank = string.Empty;
		public string m_strChatWatchTargetText = string.Empty;
		public DateTime m_ChatWatchNextValidAlertTime = DateTime.Now;
		public bool m_bSpawnWatchTargetAnnounced = false;
		public string m_strSpawnWatchTarget = string.Empty;
		public DateTime m_SpawnWatchDespawnStartTime = DateTime.Now;
		protected List<CustomTellTrigger> m_aCustomTellTriggerList = new List<CustomTellTrigger>();

		protected PositioningStance m_ePositioningStance = PositioningStance.AutoFollow;
		public PositioningStance CurrentPositioningStance { get { return m_ePositioningStance; } }

		private Dictionary<string, uint> m_KnowledgeBookNameToIDMap = new Dictionary<string, uint>();
		private Dictionary<uint, string> m_KnowledgeBookIDToNameMap = new Dictionary<uint, string>();
		protected Dictionary<string, GroupMember> m_GroupMemberDictionary = new Dictionary<string, GroupMember>();
		protected Dictionary<string, GroupMember> m_FriendDictionary = new Dictionary<string, GroupMember>();

		/// <summary>
		/// This associates all identical spells of a shared recast timer with the index of the highest level version of them.
		/// </summary>
		protected Dictionary<string, uint> m_KnowledgeBookAbilityLineDictionary = new Dictionary<string, uint>();

		/************************************************************************************/
		public Character Me
		{
			get
			{
				return Program.Me;
			}
		}

		/************************************************************************************/
		public Actor MeActor
		{
			get
			{
				return Program.MeActor;
			}
		}

		/************************************************************************************/
		public virtual void RefreshKnowledgeBook()
		{
			Program.Log("Referencing Knowledge Book...");

			while (Program.s_bContinueBot)
			{
				m_KnowledgeBookNameToIDMap.Clear();
				m_KnowledgeBookIDToNameMap.Clear();

				Frame.Wait(true);
				try
				{
					Program.UpdateGlobals();

					if (Me.NumAbilities == 0)
						Program.Log("NO abilities found!");
					else
					{
						m_iAbilitiesFound = 0;

						foreach (Ability ThisAbility in EnumAbilities())
						{
							/// An ability string of null means it isn't loaded from the server yet.
							if (ThisAbility.IsValid && !string.IsNullOrEmpty(ThisAbility.Name))
							{
								m_iAbilitiesFound++;

								if (m_KnowledgeBookNameToIDMap.ContainsKey(ThisAbility.Name))
								{
									Program.Log(
										"WARNING: Duplicate ability \"{0}\" found (ID {1} & {2}). This could be problematic with maintained spells.",
										ThisAbility.Name,
										ThisAbility.ID,
										m_KnowledgeBookNameToIDMap[ThisAbility.Name]);
								}
								else
									m_KnowledgeBookNameToIDMap.Add(ThisAbility.Name, ThisAbility.ID);

								m_KnowledgeBookIDToNameMap.Add(ThisAbility.ID, ThisAbility.Name);
							}
						}

						if (m_iAbilitiesFound < Me.NumAbilities)
							Program.Log("Found {0} names of {1} abilities so far.", m_iAbilitiesFound, Me.NumAbilities);
						else
						{
							Program.Log("All abilities found.");
#if DEBUG
							/// Now dump it all to a file.
							string strLogFileName = string.Format("{0}.{1} ability table debug dump.csv", Program.ServerName, Me.Name);
							strLogFileName = Path.Combine(Program.s_strINIFolderPath, strLogFileName);
							using (CsvFileWriter OutputFile = new CsvFileWriter(strLogFileName, false))
							{
								for (int iIndex = 1; iIndex <= Me.NumAbilities; iIndex++)
								{
									Ability ThisAbility = Me.Ability(iIndex);
									OutputFile.WriteNextValue(iIndex);
									OutputFile.WriteNextValue(ThisAbility.ID);
									OutputFile.WriteNextValue(ThisAbility.Name);
									OutputFile.WriteLine();
								}
							}
#endif
							break;
						}
					}
				}
				catch
				{
					Program.Log("Exception thrown while looking up ability data.");
				}
				finally
				{
					Frame.Unlock();
				}

				/// This is black magic to force the client to reload the knowledge book.
				Program.RunCommand("/showcombatartbook");
				Program.Log("Waiting for abilities to load from the server...");
				Program.FrameWait(TimeSpan.FromSeconds(3.0f));
				Program.RunCommand("/toggleknowledge");
			}

			/// This must be done before any call to SelectHighestAbilityID().
			m_KnowledgeBookAbilityLineDictionary.Clear();

			/// Racials.
			m_uiFeatherfallAbilityID = SelectHighestAbilityID(
				//"Mind over Matter", /// High Elves. Commented out until the devs reconcile this with the tradeskill ability of the same name.
				"Glide", /// Fae.
				"Falling Grace" /// Erudites.
				);
			m_uiHalfElfMitigationDebuffAbilityID = SelectHighestAbilityID("Piercing Stab");
			m_uiFurySalveHealAbilityID = SelectHighestAbilityID("Salve");

			/// Harvesting.
			m_uiCollectingAbilityID = SelectHighestAbilityID("Collecting");
			m_uiGatheringAbilityID = SelectHighestAbilityID("Gathering");
			m_uiMiningAbilityID = SelectHighestAbilityID("Mining");
			m_uiForestingAbilityID = SelectHighestAbilityID("Foresting");
			m_uiTrappingAbilityID = SelectHighestAbilityID("Trapping");
			m_uiFishingAbilityID = SelectHighestAbilityID("Fishing");

			return;
		}

		/************************************************************************************/
		/// <summary>
		/// Each ordered element in the passed array is the next higher level (or next higher preferred) ability.
		/// </summary>
		/// <param name="astrAbilityNames">List of every spell that shares the behavior and recast timer,
		/// presorted by the caller from lowest level to highest.</param>
		public uint SelectHighestAbilityID(params string[] astrAbilityNames)
		{
			uint uiBestSpellID = 0;

			/// Grab the highest level ability from this group.
			for (int iIndex = astrAbilityNames.Length - 1; iIndex >= 0; iIndex--)
			{
				string strThisAbility = astrAbilityNames[iIndex];
				if (m_KnowledgeBookNameToIDMap.ContainsKey(strThisAbility))
				{
					uiBestSpellID = m_KnowledgeBookNameToIDMap[strThisAbility];
					break;
				}
			}

			/// Now associate every ability in the list (that actually exists) with the ID of the highest-level version of it.
			/// This is important so that older versions of maintained buffs can be efficiently cancelled in favor of the highest versions of them.
			for (int iIndex = 0; iIndex < astrAbilityNames.Length; iIndex++)
			{
				string strThisAbility = astrAbilityNames[iIndex];
				if (m_KnowledgeBookNameToIDMap.ContainsKey(strThisAbility) && !m_KnowledgeBookAbilityLineDictionary.ContainsKey(strThisAbility))
					m_KnowledgeBookAbilityLineDictionary.Add(strThisAbility, uiBestSpellID);
			}

			return uiBestSpellID;
		}

		/************************************************************************************/
		private static readonly string[] s_astrRomanNumeralSuffixes = new string[]
		{
			"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII"
		};

		/************************************************************************************/
		public uint SelectHighestTieredAbilityID(string strBaseAbilityName)
		{
			List<string> astrAbilityNames = new List<string>(s_astrRomanNumeralSuffixes.Length);
			for (int iIndex = 0; iIndex < s_astrRomanNumeralSuffixes.Length; iIndex++)
			{
				string strRomanNumeral = s_astrRomanNumeralSuffixes[iIndex];

				/// There is no roman numeral I for the first spell in the series.
				string strFinalAbilityName = (iIndex > 0) ? string.Format("{0} {1}", strBaseAbilityName, strRomanNumeral) : strBaseAbilityName;
				astrAbilityNames.Add(strFinalAbilityName);
			}

			return SelectHighestAbilityID(astrAbilityNames.ToArray());
		}

		/************************************************************************************/
		public uint SelectAbilityID(uint uiAbilityID)
		{
			if (m_KnowledgeBookIDToNameMap.ContainsKey(uiAbilityID))
				return uiAbilityID;
			else
				return 0;
		}

		/************************************************************************************/
		/// <summary>
		/// The base function caches certain lookup data.
		/// </summary>
		/// <returns>true if an action was taken and no further processing should occur</returns>
		public virtual bool DoNextAction()
		{
			/// We freshly reacquire this for every frame.
			m_OffensiveTargetActor = null;

			if (m_ePositioningStance == PositioningStance.DoNothing)
				return true;

			/// If we have been commanded to redo group buffs, then cancel one per frame.
			if (m_bClearGroupMaintained)
			{
				foreach (Maintained ThisMaintained in EnumMaintained())
				{
					if (ThisMaintained.Type == "Group")
						return ThisMaintained.Cancel();
				}
				m_bClearGroupMaintained = false;
			}

			m_GroupMemberDictionary.Clear();
			foreach (GroupMember ThisMember in EnumGroupMembers())
				m_GroupMemberDictionary.Add(ThisMember.Name, ThisMember);

			m_FriendDictionary.Clear();
			foreach (GroupMember ThisMember in EnumRaidMembers())
				m_FriendDictionary.Add(ThisMember.Name, ThisMember);

			/// If we're not in a raid, or for some weird reason the raid enum turned up blanks,
			/// then just copy from the group list (cheating!).
			if (m_FriendDictionary.Count == 0)
			{
				foreach (KeyValuePair<string, GroupMember> ThisPair in m_GroupMemberDictionary)
					m_FriendDictionary.Add(ThisPair.Key, ThisPair.Value);
			}

			/// Build the maintained spell dictionary.
			m_MaintainedNameToIndexMap.Clear();
			m_MaintainedTargetNameDictionary.Clear();
			for (int iIndex = 1; iIndex <= Me.CountMaintained; iIndex++)
			{
				Maintained ThisMaintained = Me.Maintained(iIndex);

				MaintainedTargetIDKey NewKey = new MaintainedTargetIDKey(ThisMaintained.Name, ThisMaintained.Target().ID);
				if (m_MaintainedTargetNameDictionary.ContainsKey(NewKey))
					Program.Log("Duplicate {0} on target {1}.", ThisMaintained.Name, ThisMaintained.Target().Name);
				m_MaintainedTargetNameDictionary.Add(NewKey, ThisMaintained);

				string strName = ThisMaintained.Name;
				if (strName != null)
				{
					if (!m_MaintainedNameToIndexMap.ContainsKey(strName))
						m_MaintainedNameToIndexMap.Add(strName, iIndex);
				}
			}

			/// Build the beneficial effect dictionary.
			m_BeneficialEffectNameToIndexMap.Clear();
			for (int iIndex = 1; iIndex <= Me.CountEffects; iIndex++)
			{
				string strName = Me.Effect(iIndex).Name;
				if (strName != null)
				{
					if (!m_BeneficialEffectNameToIndexMap.ContainsKey(strName))
						m_BeneficialEffectNameToIndexMap.Add(strName, iIndex);
				}
			}

			m_AbilityCache.Clear();
			m_AbilityCompatibleTargetCountCache.Clear();
			m_VitalStatusCache.Clear();

			m_strCurrentMainTank = GetFirstExistingPartyMember(m_astrMainTanks, false);

			if (CheckPositioningStance())
				return true;

			/// Decide whether now is a good time to check buffs.
			if (!m_bCheckBuffsNow)
			{
				if (DateTime.Now > (m_LastCheckBuffsTime + TimeSpan.FromMilliseconds(m_iCheckBuffsInterval)))
				{
					Program.Log("Checking buffs now.");

					/// Only derived classes set the flag back to false.
					m_bCheckBuffsNow = true;
				}
			}

			if (AutoHarvestNearestNode())
				return true;

			/// Calculate how much time remains on the cast timer.
			DateTime CurrentDateTime = DateTime.Now;
			if (CurrentDateTime > m_LastCastEndTime)
				m_CastTimeRemaining = TimeSpan.FromTicks(0);
			else
				m_CastTimeRemaining = m_LastCastEndTime - CurrentDateTime;

			return false;
		}

		/************************************************************************************/
		public virtual bool OnChoiceWindowAppeared(ChoiceWindow ThisWindow)
		{
			if (m_ePositioningStance == PositioningStance.DoNothing)
			{
				Program.Log("Character is in do-nothing stance; ignoring choice window.");
				return false;
			}

			Program.Log("Choice window appeared: \"{0}\".", ThisWindow.Text);

			/// Group invite window.
			if (ThisWindow.Text.Contains("has invited you to join a group"))
			{
				/// Only accept group invites from a commanding player.
				bool bIssuedByCommandingPlayer = false;
				foreach (string strThisPlayer in m_astrCommandingPlayers)
					if (!string.IsNullOrEmpty(strThisPlayer) && ThisWindow.Text.StartsWith(strThisPlayer))
					{
						bIssuedByCommandingPlayer = true;
						break;
					}

				if (bIssuedByCommandingPlayer)
				{
					Program.Log("Accepting invite from commanding player.");
					//ThisWindow.DoChoice1();
					Program.RunCommand("/acceptinvite");
				}
				else
				{
					Program.Log("Declining invite from unauthorized player.");
					//ThisWindow.DoChoice2();
					Program.RunCommand("/declineinvite");
				}

				return true;
			}

			/// Zone timer reset window.
			else if (ThisWindow.Text.Contains("Are you sure you want to reset your zone timer for "))
			{
				ThisWindow.DoChoice1();
				return true;
			}

			/// Rez window (could be port too, gotta be careful).
			/// "* would like to cast '*' on you. Do you accept?"
			/// TODO: Only accept if person is in group/raid.
			else if (ThisWindow.Text.Contains("would like to cast"))
			{
				/// Always accept; no known reason not to yet.
				ThisWindow.DoChoice1(); /// Accept
				return true;
			}

			return false;
		}

		/************************************************************************************/
		/// <summary>
		/// This function is not yet complete.
		/// </summary>
		public virtual bool OnRewardWindowAppeared(RewardWindow ThisWindow)
		{
			if (m_ePositioningStance == PositioningStance.DoNothing)
			{
				Program.Log("Character is in do-nothing stance; ignoring reward window.");
				return false;
			}

			//Program.Log("Reward window appeared: \"{0}\".", ThisWindow.);

			EQ2UIPage ThisPage = ThisWindow.ToEQ2UIPage;
			Program.Log("Accepting reward...");
			ThisWindow.Receive();
			return false;
		}

		/************************************************************************************/
		/// <summary>
		/// Everything will gravitate to this function eventually, after I learn how to use regular expressions.
		/// </summary>
		/// <returns>true if the implementation took ownership of the text and further processing should cease.</returns>
		public virtual bool OnIncomingText(ChatChannel eChannel, string strChannelName, string strFrom, string strMessage)
		{
			string strTrimmedMessage = strMessage.Trim();
			string strLowerCaseMessage = strTrimmedMessage.ToLower();

			/// Chat Watch text is top priority.
			if (m_ePositioningStance == PositioningStance.ChatWatch &&
				strLowerCaseMessage.Contains(m_strChatWatchTargetText) &&
				m_ChatWatchNextValidAlertTime < DateTime.Now)
			{
				Program.Log("Chat Watch text \"{0}\" found!", m_strChatWatchTargetText);
				Program.s_EmailQueueThread.PostEmailMessage(m_astrChatWatchToAddressList, "Chat text spotted!", strMessage);
				m_ChatWatchNextValidAlertTime = DateTime.Now + TimeSpan.FromMinutes(m_fChatWatchAlertCooldownMinutes);
				/// Don't return a value; allow processing to continue because there's no need to cockblock in this case.
			}

			/// NOTE: Place all exact-match checks in this table. C# will hash sort it for quickness.
			switch (strMessage)
			{
				/// Look for cast abort strings.
				case "Already casting...":
				case "Can't see target":
				case "Interrupted!":
				case "No eligible target":
				case "No targets in range":
				case "Not an enemy":
				case "Target is not alive":
				case "Target too weak":
				case "Too far away":
				{
					m_LastCastEndTime = DateTime.Now;
					return true;
				}
			}

			if (m_bAutoHarvestInProgress)
			{
				if (strMessage.StartsWith("You gather") ||
					strMessage.StartsWith("You failed to gather anything from") ||
					strMessage.StartsWith("You forest") ||
					strMessage.StartsWith("You failed to forest anything from") ||
					strMessage.StartsWith("You acquire") ||
					strMessage.StartsWith("You failed to trap anything from") ||
					strMessage.StartsWith("You fish") ||
					strMessage.StartsWith("You failed to fish anything from") ||
					strMessage.StartsWith("You mine") ||
					strMessage.StartsWith("You failed to mine anything from") ||
					strMessage.StartsWith("You do not have enough skill"))
				{
					Program.Log("Harvesting attempt complete.");
					m_bAutoHarvestInProgress = false;
					return true;
				}
			}

			return false;
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		/// <param name="iChannel"></param>
		/// <param name="strFrom"></param>
		/// <param name="strMessage"></param>
		/// <returns>true if handled by a base implementation, and if no further processing should be permitted.</returns>
		public virtual bool OnIncomingChatText(int iChannel, string strFrom, string strMessage)
		{
			string strTrimmedMessage = strMessage.Trim();
			string strLowerCaseMessage = strTrimmedMessage.ToLower();

			/// First check for a match against custom tell triggers.
			/// These can be authorized from any source.
			foreach (CustomTellTrigger ThisTrigger in m_aCustomTellTriggerList)
			{
				if (
					(ThisTrigger.m_astrSourcePlayers.Count == 0 || ThisTrigger.m_astrSourcePlayers.Contains(strFrom.ToLower()))
					&&
					strLowerCaseMessage.Contains(ThisTrigger.m_strSubstring)
					)
				{
					Program.Log("Custom trigger command received (\"{0}\").", ThisTrigger.m_strSubstring);
					foreach (string strThisCommand in ThisTrigger.m_astrCommands)
					{
						Program.RunCommand(strThisCommand, m_astrCommandingPlayers);
					}
					return true;
				}
			}

			/// This override only deals with commands after this point.
			string strThisCommandingPlayer = string.Empty;
			if (string.IsNullOrEmpty(strFrom) || !m_astrCommandingPlayers.Contains(strFrom))
				return false;

			Actor CommandingPlayerActor = Program.GetNonPetActor(strFrom);

			/// This is the assist call; direct the bot to begin combat.
			if (strLowerCaseMessage.Contains(m_strAssistSubphrase))
			{
				if (CommandingPlayerActor == null)
					Program.Log("Commanding player not a valid combat assist!");
				else
				{
					Actor OffensiveTargetActor = CommandingPlayerActor.Target();

					/// Successful target acquisition.
					if (OffensiveTargetActor != null && OffensiveTargetActor.IsValid && (OffensiveTargetActor.Type == "NPC" || OffensiveTargetActor.Type == "NamedNPC"))
					{
						m_iOffensiveTargetID = OffensiveTargetActor.ID;
						Program.Log("New offensive target: {0}", OffensiveTargetActor.Name);
					}
					else
					{
						if (OffensiveTargetActor != null)
							Program.Log("{0} provided an invalid offensive target ({1}, {2}, {3}).", CommandingPlayerActor.Name, OffensiveTargetActor.Name, OffensiveTargetActor.ID, OffensiveTargetActor.Type);

						/// Combat is now cancelled.
						/// Maybe the commanding player misclicked or clicked off intentionally, but it doesn't matter.
						WithdrawFromCombat();
					}
				}

				/// An assist command promotes to neutral positioning.
				if (m_ePositioningStance == PositioningStance.DoNothing)
					ChangePositioningStance(PositioningStance.NeutralPosition);

				return true;
			}

			/// Reload the INI file and knowledge book; the rest of the code will adjust on its own.
			else if (strLowerCaseMessage.Contains(m_strReloadINISubphrase))
			{
				Program.Log("Reload INI command (\"{0}\") received.", m_strReloadINISubphrase);
				ReadINISettings();
				Program.ReleaseAllKeys(); /// If there's a bug, this will cure it. If not, no loss.
				Program.s_bRefreshKnowledgeBook = true;
			}

			else if (strLowerCaseMessage.Contains(m_strDoNothingSubphrase))
			{
				Program.Log("Do Nothing command (\"{0}\") received.", m_strDoNothingSubphrase);
				ChangePositioningStance(PositioningStance.DoNothing);
			}

			else if (strLowerCaseMessage.Contains(m_strNeutralPositionSubphrase))
			{
				Program.Log("Neutral Position command (\"{0}\") received.", m_strNeutralPositionSubphrase);
				ChangePositioningStance(PositioningStance.NeutralPosition);
			}

			else if (strLowerCaseMessage.Contains(m_strStayInPlaceSubphrase))
			{
				Program.Log("Stay In Place command (\"{0}\") received.", m_strStayInPlaceSubphrase);
				m_strPositionalCommandingPlayer = strFrom;
				ChangePositioningStance(PositioningStance.StayInPlace);
			}

			else if (strLowerCaseMessage.Contains(m_strForwardDashSubphrase))
			{
				Program.Log("Forward Dash command (\"{0}\") received.", m_strForwardDashSubphrase);
				ChangePositioningStance(PositioningStance.ForwardDash);
			}

			else if (strLowerCaseMessage.Contains(m_strAutoFollowSubphrase))
			{
				Program.Log("Autofollow command (\"{0}\") received.", m_strAutoFollowSubphrase);
				ChangePositioningStance(PositioningStance.AutoFollow);
			}

			else if (strLowerCaseMessage.Contains(m_strCustomAutoFollowSubphrase))
			{
				Program.Log("Custom Autofollow command (\"{0}\") received.", m_strCustomAutoFollowSubphrase);
				m_fCurrentMovementTargetCoordinateTolerance = m_fCustomAutoFollowMinimumRange;
				m_strPositionalCommandingPlayer = strFrom;
				ChangePositioningStance(PositioningStance.CustomAutoFollow);
			}

			else if (strLowerCaseMessage.Contains(m_strShadowMeSubphrase))
			{
				Program.Log("Shadow Me command (\"{0}\") received.", m_strShadowMeSubphrase);
				m_fCurrentMovementTargetCoordinateTolerance = m_fStayInPlaceTolerance;
				m_strPositionalCommandingPlayer = strFrom;
				ChangePositioningStance(PositioningStance.CustomAutoFollow);
			}

			/// Bot killswitch.
			else if (strLowerCaseMessage.Contains(m_strBotKillswitchSubphrase))
			{
				Program.Log("Bot killswitch command (\"{0}\") received.", m_strBotKillswitchSubphrase);
				Program.s_bContinueBot = false;
				return true;
			}

			/// Process killswitch.
			else if (strLowerCaseMessage.Contains(m_strProcessKillswitchSubphrase))
			{
				Program.Log("Process killswitch command (\"{0}\") received.", m_strProcessKillswitchSubphrase);
				Process.GetCurrentProcess().Kill();
			}

			/// Begin dropping all group buffs.
			else if (strLowerCaseMessage.Contains(m_strClearGroupMaintainedSubphrase))
			{
				m_bClearGroupMaintained = true;
			}

			/// Mentor the specified group member.
			else if (strLowerCaseMessage.Contains(m_strMentorSubphrase))
			{
				foreach (GroupMember ThisMember in EnumGroupMembers())
				{
					if (strLowerCaseMessage.Contains(ThisMember.Name.ToLower()) && ThisMember.ToActor().IsValid)
					{
						Program.ApplyVerb(ThisMember.ToActor(), "mentor");
						return true;
					}
				}
			}

			else if (strLowerCaseMessage.Contains(m_strRepairSubphrase))
			{
				if (CommandingPlayerActor != null)
				{
					Actor MenderTargetActor = CommandingPlayerActor.Target();
					if (MenderTargetActor.IsValid && (MenderTargetActor.Type == "NoKill NPC" || MenderTargetActor.Type == "NPC")) /// Some menders can be killed.
					{
						Program.ApplyVerb(MenderTargetActor, "repair");
						Program.RunCommand("/mender_repair_all");
						return true;
					}
				}
			}

			/// This is a very shady command to use; it's only for the daring individual.
			/// It allows you to specify a verb upon an actor by name, choosing the actor closest to the commanding player.
			/// It is most useful when you want all of your bots to perform a verb at the exact same time.
			/// The command is formatted in five concatenated chunks:
			/// Prefix ActorName Separator Verb Suffix
			/// The INI file allows you to customize the Prefix, Separator, and Suffix to differentiate somewhat.
			/// Using default INI settings a command string will look something like this next line:
			/// try this: "Treasure Chest", "disarm"
			else if (strTrimmedMessage.StartsWith(m_strArbitraryVerbCommandPrefix) && strTrimmedMessage.EndsWith(m_strArbitraryVerbCommandSuffix))
			{
				string strMiddleChunk = strTrimmedMessage.Substring(
					m_strArbitraryVerbCommandPrefix.Length,
					strTrimmedMessage.Length - m_strArbitraryVerbCommandPrefix.Length - m_strArbitraryVerbCommandSuffix.Length);

				string[] astrParameters = strMiddleChunk.Split(new string[] { m_strArbitraryVerbCommandSeparator }, StringSplitOptions.None);
				if (astrParameters.Length != 2)
					return false;

				string strActorName = astrParameters[0];
				string strVerb = astrParameters[1];
				Program.Log("Attempting to apply verb \"{0}\" on actor \"{1}\".", strVerb, strActorName);

				/// Grab the so-named actor nearest to the commander.
				double fNearestDistance = 50.0;
				Actor NearestActor = null;
				foreach (Actor ThisActor in Program.EnumActors(strActorName))
				{
					if (ThisActor.Name != strActorName)
						continue;

					double fThisDistance = GetActorDistance2D(CommandingPlayerActor, ThisActor);
					if (fThisDistance < fNearestDistance)
					{
						fNearestDistance = fThisDistance;
						NearestActor = ThisActor;
					}
				}

				/// No such actor found.
				if (NearestActor == null)
				{
					Program.Log("No actor found for the specified arbitrary verb.");
					return false;
				}

				Program.ApplyVerb(NearestActor, strVerb);
				return true;
			}

			else if (strLowerCaseMessage.StartsWith(m_strChatWatchSubphrase))
			{
				Program.Log("Chat Watch command (\"{0}\") received.", m_strChatWatchSubphrase);
				m_strChatWatchTargetText = strLowerCaseMessage.Substring(m_strChatWatchSubphrase.Length).ToLower().Trim();
				Program.Log("Bot will now scan for text \"{0}\".", m_strChatWatchTargetText);

				ChangePositioningStance(PositioningStance.ChatWatch);
			}

			else if (strLowerCaseMessage.StartsWith(m_strSpawnWatchSubphrase))
			{
				Program.Log("Spawn Watch command (\"{0}\") received.", m_strSpawnWatchSubphrase);
				m_bSpawnWatchTargetAnnounced = false;
				m_strSpawnWatchTarget = strTrimmedMessage.Substring(m_strSpawnWatchSubphrase.Length).ToLower().Trim();
				Program.Log("Bot will now scan for actor \"{0}\".", m_strSpawnWatchTarget);
				ChangePositioningStance(PositioningStance.SpawnWatch);
			}

			else if (strLowerCaseMessage.StartsWith(m_strSpawnWatchDespawnSubphrase))
			{
				Program.Log("De-spawn Watch command (\"{0}\") received.", m_strSpawnWatchDespawnSubphrase);
				m_bSpawnWatchTargetAnnounced = false;

				m_strSpawnWatchTarget = strTrimmedMessage.Substring(m_strSpawnWatchDespawnSubphrase.Length).ToLower().Trim();
				Program.Log("Bot will now wait for the absence of actor \"{0}\" for {0:0.0} consecutive minute(s).", m_strSpawnWatchTarget, m_fSpawnWatchDespawnTimeoutMinutes);

				ChangePositioningStance(PositioningStance.DespawnWatch);
			}

			else
				Program.Log("No command detected in commanding player chat.");

			return false;
		}

		/************************************************************************************/
		public virtual void OnZoning()
		{
			return;
		}

		/************************************************************************************/
		public virtual void OnZoningComplete()
		{
			if (m_ePositioningStance == PositioningStance.ForwardDash)
				ChangePositioningStance(PositioningStance.AutoFollow);

			return;
		}

		/************************************************************************************/
		public virtual bool OnCustomSlashCommand(string strCommand, string[] astrParameters)
		{
			string strCondensedParameters = string.Join(" ", astrParameters).Trim();

			switch (strCommand)
			{
				/// Directly acquire an offensive target.
				case "gc_attack":
				{
					Actor MyTargetActor = MeActor.Target();
					if (MyTargetActor.IsValid)
					{
						/// Don't bother filtering. Just grab the ID, let the other code determine if it's a legit target.
						m_iOffensiveTargetID = MyTargetActor.ID;
						Program.Log("Offensive target set to \"{0}\" ({1}).", MyTargetActor.Name, m_iOffensiveTargetID);
					}
					else
					{
						Program.Log("Invalid target selected.");
					}
					break;
				}

				/// Arbitrarily change an INI setting on the fly.
				case "gc_changesetting":
				{
					string strKey = string.Empty;
					string strValue = string.Empty;

					int iEqualsPosition = strCondensedParameters.IndexOf(" ");
					if (iEqualsPosition == -1)
						strKey = strCondensedParameters;
					else
					{
						strKey = strCondensedParameters.Substring(0, iEqualsPosition).TrimEnd();
						strValue = strCondensedParameters.Substring(iEqualsPosition + 1).TrimStart();
					}

					if (!string.IsNullOrEmpty(strKey))
					{
						Program.Log("Changing setting \"{0}\" to new value \"{1}\"...", strKey, strValue);

						IniFile FakeIniFile = new IniFile();
						FakeIniFile.WriteString(strKey, strValue);
						FakeIniFile.Mode = IniFile.TransferMode.Read;
						TransferINISettings(FakeIniFile);
						ApplySettings();
					}
					return true;
				}

				case "gc_exit":
				{
					Program.Log("Exit command received!");
					Program.s_bContinueBot = false;
					return true;
				}

				case "gc_findactor":
				{
					if (string.IsNullOrEmpty(strCondensedParameters))
					{
						Program.Log("gc_findactor failed: No actor name specified!");
						return true;
					}

					string strSearchString = strCondensedParameters.ToLower();
					bool bNamedSearch = (strSearchString == "named");

					List<Actor> ActorList = new List<Actor>();
					int iValidActorCount = 0;
					int iInvalidActorCount = 0;

					foreach (Actor ThisActor in Program.EnumActors())
					{
						bool bAddThisActor = false;

						if (ThisActor.IsValid)
						{
							if (bNamedSearch)
							{
								if (ThisActor.IsNamed && !ThisActor.IsAPet)
									bAddThisActor = true;
							}
							else if (ThisActor.Name.ToLower().Contains(strSearchString))
								bAddThisActor = true;
						}

						if (bAddThisActor)
						{
							ActorList.Add(ThisActor);
							iValidActorCount++;
						}
						else
							iInvalidActorCount++;
					}

					if (ActorList.Count == 0)
					{
						Program.Log("gc_findactor: Unable to find actor \"{0}\".", strCondensedParameters);
						return true;
					}

					ActorList.Sort(new ActorDistanceComparer());

					/// Run the waypoint on the nearest actor.
					Program.RunCommand("/waypoint {0}, {1}, {2}", ActorList[0].X, ActorList[0].Y, ActorList[0].Z);

					FlexStringBuilder SummaryBuilder = new FlexStringBuilder();
					SummaryBuilder.AppendLine("gc_findactor: {0} actor(s) found ({1} invalid) using \"{2}\".", iValidActorCount, iInvalidActorCount, strCondensedParameters);

					/// Now display the individual results.
					for (int iIndex = 0; iIndex < ActorList.Count && iIndex < 5; iIndex++)
					{
						Actor ThisActor = ActorList[iIndex];

						SummaryBuilder.LinePrefix = "   ";
						SummaryBuilder.AppendLine("{0}. \"{1}\" ({2}) found {3:0.00} meters away at ({4:0.00}, {5:0.00}, {6:0.00})",
							iIndex + 1,
							ThisActor.Name,
							ThisActor.ID,
							ThisActor.Distance,
							ThisActor.X,
							ThisActor.Y,
							ThisActor.Z);
						SummaryBuilder.LinePrefix = "      ";

						string strFullName = ThisActor.Name;
						if (!string.IsNullOrEmpty(ThisActor.LastName))
							strFullName += " " + ThisActor.LastName;
						if (!string.IsNullOrEmpty(ThisActor.SuffixTitle))
							strFullName += " " + ThisActor.SuffixTitle;
						if (!string.IsNullOrEmpty(ThisActor.Guild))
							strFullName += " <" + ThisActor.Guild + ">";

						SummaryBuilder.AppendLine("Full Name: {0}", strFullName);

						SummaryBuilder.AppendLine("Type: {0}", ThisActor.Type);
						SummaryBuilder.AppendLine("Class: {0}", ThisActor.Class);
						SummaryBuilder.AppendLine("Race: {0}", ThisActor.Race);
						SummaryBuilder.AppendLine("Level(Effective): {0}({1})", ThisActor.Level, ThisActor.EffectiveLevel);
						SummaryBuilder.AppendLine("Encounter Size: {0}", ThisActor.EncounterSize);
						SummaryBuilder.AppendLine("IsLocked: {0}", ThisActor.IsLocked);
						SummaryBuilder.AppendLine("IsNamed: {0}", ThisActor.IsNamed);
						SummaryBuilder.AppendLine("Speed: {0}", ThisActor.Speed);
					}

					Program.Log(SummaryBuilder.ToString());
					return true;
				}

				case "gc_openini":
				{
					Program.SafeShellExecute(Program.s_strCurrentINIFilePath);
					return true;
				}

				case "gc_openoverridesini":
				{
					Program.SafeShellExecute(Program.s_strSharedOverridesINIFilePath);
					return true;
				}

				case "gc_reloadsettings":
				{
					ReadINISettings();
					Program.ReleaseAllKeys(); /// If there's a bug, this will cure it. If not, no loss.
					Program.s_bRefreshKnowledgeBook = true;
					return true;
				}

				case "gc_stance":
				{
					if (astrParameters.Length < 1)
					{
						Program.Log("gc_stance failed: Missing stance parameter.");
						return true;
					}

					string strStance = astrParameters[0].ToLower();
					switch (strStance)
					{
						case "afk":
							ChangePositioningStance(PositioningStance.DoNothing);
							break;
						case "neutral":
							ChangePositioningStance(PositioningStance.NeutralPosition);
							break;
						case "dash":
							ChangePositioningStance(PositioningStance.ForwardDash);
							break;
						case "stay":
							m_strPositionalCommandingPlayer = Me.Name;
							ChangePositioningStance(PositioningStance.StayInPlace);
							break;
					}

					return true;
				}

				case "gc_spawnwatch":
				{
					m_bSpawnWatchTargetAnnounced = false;
					m_strSpawnWatchTarget = strCondensedParameters.ToLower().Trim();
					Program.Log("Bot will now scan for actor \"{0}\".", m_strSpawnWatchTarget);
					ChangePositioningStance(PositioningStance.SpawnWatch);
					return true;
				}

				/// Test the text-to-speech synthesizer using the current settings.
				case "gc_tts":
				{
					Program.SayText(strCondensedParameters);
					return true;
				}

				case "gc_version":
				{
					Program.DisplayVersion();
					return true;
				}

				/// Clear the offensive target.
				case "gc_withdraw":
				{
					Program.Log("Offensive target withdrawn.");
					WithdrawFromCombat();
					return true;
				}
			}

			return false;
		}

		/************************************************************************************/
		public void StopCheckingBuffs()
		{
			m_bCheckBuffsNow = false;
			m_LastCheckBuffsTime = DateTime.Now;
			Program.Log("Finished checking buffs.");
			return;
		}

		/************************************************************************************/
		public void ChangePositioningStance(PositioningStance eNewStance)
		{
			/// Deactivate the existing stance.
			if (m_ePositioningStance == PositioningStance.CustomAutoFollow ||
				m_ePositioningStance == PositioningStance.StayInPlace ||
				m_ePositioningStance == PositioningStance.ForwardDash)
			{
				Program.ReleaseKey("W");
			}

			if (eNewStance == PositioningStance.DoNothing)
			{
				m_ePositioningStance = PositioningStance.DoNothing;
			}
			else if (eNewStance == PositioningStance.NeutralPosition)
			{
				m_ePositioningStance = PositioningStance.NeutralPosition;
			}
			else if (eNewStance == PositioningStance.StayInPlace)
			{
				Actor CommandingPlayerActor = Program.GetNonPetActor(m_strPositionalCommandingPlayer);
				if (CommandingPlayerActor != null)
				{
					m_ePositioningStance = PositioningStance.StayInPlace;
					m_ptStayLocation = new Point3D(CommandingPlayerActor);
					m_fCurrentMovementTargetCoordinateTolerance = m_fStayInPlaceTolerance;
					CheckPositioningStance();
				}
			}
			else if (eNewStance == PositioningStance.CustomAutoFollow)
			{
				m_ePositioningStance = PositioningStance.CustomAutoFollow;
				m_bLastShadowTargetSamplingWasNearby = false;
				CheckPositioningStance();
			}
			else if (eNewStance == PositioningStance.ForwardDash)
			{
				m_ePositioningStance = PositioningStance.ForwardDash;
				CheckPositioningStance();
			}
			else if (eNewStance == PositioningStance.AutoFollow)
			{
				m_ePositioningStance = PositioningStance.AutoFollow;
				CheckPositioningStance();
			}

			else if (eNewStance == PositioningStance.ChatWatch)
			{
				m_ePositioningStance = PositioningStance.ChatWatch;
				m_ChatWatchNextValidAlertTime = DateTime.Now;
			}

			else if (eNewStance == PositioningStance.SpawnWatch)
			{
				m_ePositioningStance = PositioningStance.SpawnWatch;
				m_bSpawnWatchTargetAnnounced = false;
			}

			else if (eNewStance == PositioningStance.DespawnWatch)
			{
				m_ePositioningStance = PositioningStance.DespawnWatch;
				m_bSpawnWatchTargetAnnounced = false;
				m_SpawnWatchDespawnStartTime = DateTime.Now;
			}

			return;
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		/// <returns>true if an autofollow command was sent.</returns>
		public bool CheckPositioningStance()
		{
			/// Traditional client autofollow.
			if (m_ePositioningStance == PositioningStance.AutoFollow)
			{
				if (MeActor.IsDead)
					return false;

				/// Make sure an autofollow target exists in our group.
				string strAutoFollowTarget = GetFirstExistingPartyMember(m_astrAutoFollowTargets, true);
				if (string.IsNullOrEmpty(strAutoFollowTarget))
				{
					Program.Log("Can't autofollow (no configured targets found in group).");
					return false;
				}

				/// If the player isn't in zone or is dead, we don't really need to see that in the log.
				Actor AutoFollowActor = m_GroupMemberDictionary[strAutoFollowTarget].ToActor();
				if (!AutoFollowActor.IsValid)
				{
					//Program.Log("Can't autofollow on {0} (player actor is invalid).", m_strAutoFollowTarget);
					return false;
				}
				else if (AutoFollowActor.IsDead)
				{
					//Program.Log("Can't autofollow on {0} (player is dead).", m_strAutoFollowTarget);
					return false;
				}

				/// Reapply autofollow.
				/// We won't make it an absolute requirement for Check Buffs completion.
				if (MeActor.WhoFollowing != strAutoFollowTarget)
				{
					/// If we're too far away, the client will put up an error message.
					/// Therefore we have to filter out this failure condition.
					if (GetActorDistance3D(MeActor, AutoFollowActor) < 30)
					{
						if (AutoFollowActor.DoFace())
						{
							Program.RunCommand(1, "/follow {0}", strAutoFollowTarget);
							return true;
						}
					}
				}

				/// The most annoying shit about autofollow is when we're in combat but not on a target.
				/// They run their own fucking directions.
				else if ((MeActor.InCombatMode || Me.IsHated) && m_iOffensiveTargetID == -1)
				{
					if (AutoFollowActor.DoFace())
					{
						Program.Log("In combat without an offensive target; forcing direction toward autofollow target.");
						return false;
					}
				}
			}

			/// These stances are grouped together because both of them involve direct autofollow.
			else if (m_ePositioningStance == PositioningStance.StayInPlace || m_ePositioningStance == PositioningStance.CustomAutoFollow)
			{
				if (MeActor.IsDead)
					return false;

				/// Firstly, no matter where we are, stop autofollowing.
				if (!string.IsNullOrEmpty(MeActor.WhoFollowing))
				{
					Program.RunCommand(1, "/stopfollow");
					return true;
				}

				/// For shadowing, the coordinate is updated at every iteration.
				if (m_ePositioningStance == PositioningStance.CustomAutoFollow)
				{
					/// Make sure an autofollow target exists in our party.
					string strAutoFollowTarget = GetFirstExistingPartyMember(m_astrAutoFollowTargets, false);
					if (string.IsNullOrEmpty(strAutoFollowTarget))
					{
						Program.ReleaseKey("W");
						return false;
					}

					Actor FollowActor = m_FriendDictionary[strAutoFollowTarget].ToActor();
					if (!FollowActor.IsValid)
					{
						Program.ReleaseKey("W");
						return false;
					}

					m_ptStayLocation = new Point3D(FollowActor);
				}

				if (/*!MeActor.IsClimbing &&*/ MeActor.CanTurn)
				{
					double fRange = GetActorDistance2D(MeActor, m_ptStayLocation);

					/// If target suddenly ported from near to ridiculously far away, almost errantly, then call it off.
					/// But if the target began the stance far away and is approaching near, then allow it to continue,
					/// because in that case the commander is using shadowing to draw the character closer.
					if (m_ePositioningStance == PositioningStance.CustomAutoFollow)
					{
						bool bThisSamplingIsNearby = (fRange < 200.0f);
						if (m_bLastShadowTargetSamplingWasNearby && !bThisSamplingIsNearby)
						{
							//Program.RunCommand("/t {0} you ported too far away", m_astrCommandingPlayers); /// TODO: Make this configurable.
							ChangePositioningStance(PositioningStance.NeutralPosition);
							return true;
						}
						m_bLastShadowTargetSamplingWasNearby = bThisSamplingIsNearby;
					}

					if (fRange > m_fCurrentMovementTargetCoordinateTolerance)
					{
						float fBearing = Me.HeadingTo(m_ptStayLocation.X, m_ptStayLocation.Y, m_ptStayLocation.Z);
						if (Me.Face(fBearing))
						{
							Program.Log("Moving to stay position ({0:0.00}, {1:0.00}, {2:0.00}), {3:0.00} meters away...", m_ptStayLocation.X, m_ptStayLocation.Y, m_ptStayLocation.Z, fRange);
							Program.PressAndHoldKey("W");
						}
					}
					else
					{
						Program.ReleaseKey("W");
					}
				}
			}

			else if (m_ePositioningStance == PositioningStance.ForwardDash)
			{
				if (MeActor.IsDead)
					return false;

				if (GetActorDistance3D(MeActor, m_ptMyLastLocation) > 200.0f)
				{
					/// We probably ran through a port.
					Program.Log("Large motion gap detected while dashing; it is assumed we got ported.");
					ChangePositioningStance(PositioningStance.NeutralPosition);
				}
				else
				{
					Program.PressAndHoldKey("W");
				}

				return false;
			}

			else if (m_ePositioningStance == PositioningStance.ChatWatch)
			{
				return true;
			}

			else if (m_ePositioningStance == PositioningStance.SpawnWatch)
			{
				Actor ActualFoundActor = null;
				foreach (Actor ThisActor in Program.EnumActors())
				{
					string strThisActorName = ThisActor.Name.Trim().ToLower();
					if (strThisActorName == m_strSpawnWatchTarget)
					{
						ActualFoundActor = ThisActor;
						break;
					}
				}

				if (ActualFoundActor != null)
				{
					/// This is awesomesauce right here.
					string strCoordinates = string.Format("{0:0.00}, {1:0.00}, {2:0.00}", ActualFoundActor.X, ActualFoundActor.Y, ActualFoundActor.Z);
					Program.RunCommand("/waypoint {0}", strCoordinates);
					Program.Log("Spawn Watch target \"{0}\" found at ({1})! See map: a waypoint command was executed.", ActualFoundActor.Name, strCoordinates);
					Program.SayText(m_strSpawnWatchAlertSpeech, ActualFoundActor.Name);

					if (m_astrSpawnWatchToAddressList.Count > 0)
					{
						Program.s_EmailQueueThread.PostEmailMessage(
							m_astrSpawnWatchToAddressList,
							"From " + Me.Name,
							ActualFoundActor.Name + " just spawned!");
					}

					try
					{
						Program.RunCommand(m_strSpawnWatchAlertCommand, m_astrCommandingPlayers, m_strSpawnWatchTarget);
					}
					catch
					{
						Program.Log("Error in Spawn Watch alert command format.");
					}

					Program.Log("Now entering De-spawn Watch mode.");
					ChangePositioningStance(PositioningStance.DespawnWatch);
				}
				return true;
			}

			else if (m_ePositioningStance == PositioningStance.DespawnWatch)
			{
				foreach (Actor ThisActor in Program.EnumActors())
				{
					string strThisActorName = ThisActor.Name.Trim().ToLower();
					if ((strThisActorName == m_strSpawnWatchTarget) && !ThisActor.IsDead)
					{
#if DEBUG
						double fDistance = GetActorDistance2D(MeActor, ThisActor);
						Program.Log("Distance to {0}: {1:0.00}", ThisActor.Name, fDistance);
#endif
						/// Reset the clock every time we see a single living actor with the search name.
						m_SpawnWatchDespawnStartTime = DateTime.Now;
						return true;
					}
				}

				/// Actor despawned!
				if ((m_SpawnWatchDespawnStartTime + TimeSpan.FromMinutes(m_fSpawnWatchDespawnTimeoutMinutes)) < DateTime.Now)
				{
					Program.Log("De-spawn Watch target \"{0}\" dead or no longer found after timeout!", m_strSpawnWatchTarget);

					if (m_astrSpawnWatchToAddressList.Count > 0)
					{
						Program.s_EmailQueueThread.PostEmailMessage(
							m_astrSpawnWatchToAddressList,
							"From " + Me.Name,
							m_strSpawnWatchTarget + " just despawned!");
					}

					ChangePositioningStance(PositioningStance.DoNothing);
				}

				return true;
			}

			return false;
		}

		/************************************************************************************/
		/// <summary>
		/// 
		/// </summary>
		/// <returns>true if the player was able to fully target and engage the designated opponent</returns>
		public bool EngageOffensiveTarget()
		{
			if (m_OffensiveTargetActor == null)
				return false;

			/// Make sure the mob is targetted before we return success.
			Actor MyTargetActor = MeActor.Target();
			if (!MyTargetActor.IsValid || MyTargetActor.ID != m_OffensiveTargetActor.ID)
			{
				/// If we can't even target it, we either got a crazy mob (which we're not prepared for in this script) or we're SOL.
				if (!m_OffensiveTargetActor.DoTarget())
					Program.Log("Unable to target mob: ({0}, {1})", m_OffensiveTargetActor.Name, m_OffensiveTargetActor.ID);

				return false;
			}

			/// If we're stealthed, then we can bail because targetting is all we need.
			/// Otherwise the /auto commands will break stealth which we might need for some CA's.
			if (MeActor.IsStealthed)
			{
				Program.Log("Player is stealthed; no action will be taken.");
				return true;
			}

			/// Turn on auto-attack if required.
			/// End-of-combat will turn it back off automatically.
			/// I picked a larger minimum range for ranged autoattack because any closer
			/// and then it's likely the commander is just trying to position for melee.
			/// Remember too that there is an update delay with readback stats.
			double fDistance = GetActorDistance3D(MeActor, m_OffensiveTargetActor);
			if (m_bUseRanged && (fDistance > 10.0) && !Me.RangedAutoAttackOn)
			{
				/// Turn on ranged auto-attack instead if there is too much distance to the target.
				Program.RunCommand("/auto 2");
				m_OffensiveTargetActor.DoFace();
				return false;
			}
			else if (m_bAutoAttack && !Me.AutoAttackOn)
			{
				Program.RunCommand("/auto 1");
				m_OffensiveTargetActor.DoFace();
				return false;
			}

			/// Make sure the pet is on the right target before we return success.
			Actor PetActor = Me.Pet();
			if (Me.IsHated && PetActor.IsValid && PetActor.CanTurn)
			{
				Actor PetTargetActor = PetActor.Target();
				if (!PetTargetActor.IsValid || (PetTargetActor.ID != m_OffensiveTargetActor.ID) || !PetActor.InCombatMode)
				{
					Program.Log("Sending in pet for attack!");
					Program.RunCommand("/pet attack");
					///return false; // Don't return failure; often there is lag time with the fucking pet and it kills our dps to wait for it.
				}
			}

			return true;
		}

		/************************************************************************************/
		/// <summary>
		/// Ceases any offensive activity against the given target actor without completely
		/// disengaging from the current encounter altogether, and in a way to prevent accidental
		/// engagement of a different target. This is vital for mezzing, and returns true
		/// if any server contact was made (implying that we'll need to call this again on the
		/// same actor later).
		/// </summary>
		/// <returns></returns>
		public bool WithdrawCombatFromTarget(Actor TargetActor)
		{
			bool bActionTaken = false;

			Actor MyTargetActor = MeActor.Target();
			if (MyTargetActor.IsValid && MyTargetActor.ID == TargetActor.ID)
			{
				/// Turn it off just in case.
				if (Me.AutoAttackOn || Me.RangedAutoAttackOn)
				{
					Program.RunCommand("/auto 0");
					bActionTaken = true;
				}

				/// If an enemy is targetted, target nothing instead.
				//Program.RunCommand("/target_none");
				//return true;
			}

			Actor PetActor = Me.Pet();
			if (PetActor.IsValid)
			{
				Actor PetTargetActor = PetActor.Target();
				if (PetTargetActor.IsValid && PetTargetActor.InCombatMode && PetTargetActor.ID == TargetActor.ID)
				{
					Program.RunCommand("/pet backoff");
					bActionTaken = true;
				}
			}

			return bActionTaken;
		}

		/************************************************************************************/
		public bool WithdrawFromCombat()
		{
			bool bActionTaken = false;
			m_iOffensiveTargetID = -1;

			if (!MeActor.IsDead)
			{
				/// Turn it off just in case.
				if (Me.AutoAttackOn || Me.RangedAutoAttackOn)
				{
					Program.RunCommand("/auto 0");
					bActionTaken = true;
				}

				/// Pull the pet back just in case.
				Actor PetActor = Me.Pet();
				if (PetActor.IsValid && PetActor.InCombatMode)
				{
					Program.RunCommand("/pet backoff");
					bActionTaken = true;
				}

				/// If an enemy is targetted, target nothing instead.
				Actor TargetActor = MeActor.Target();
				if (TargetActor.IsValid && TargetActor.Type == "NPC")
				{
					Program.RunCommand("/target_none");
					bActionTaken = true;
				}
			}

			return bActionTaken;
		}

		/************************************************************************************/
		public bool GetOffensiveTargetActor()
		{
			if (m_iOffensiveTargetID == -1)
				return false;

			/// See if everyone is dead...
			bool bEveryoneDead = true;
			foreach (GroupMember ThisMember in m_FriendDictionary.Values)
			{
				Actor ThisActor = ThisMember.ToActor();
				if (ThisActor.IsValid && !ThisActor.IsDead) /// TODO: But are dead players also invalid by design?
				{
					bEveryoneDead = false;
					break;
				}
			}

			/// If everyone in the party is dead, the fight is completely over.
			if (bEveryoneDead)
			{
				if (m_iOffensiveTargetID != -1)
				{
					Program.Log("Everyone is dead and the encounter is over; the bot will not re-engage on rez/revive.");
					m_iOffensiveTargetID = -1;
				}
				return false;
			}

			Actor OffensiveTargetActor = Program.GetActor(m_iOffensiveTargetID);

			if (OffensiveTargetActor == null ||
				!OffensiveTargetActor.IsValid ||
				OffensiveTargetActor.IsDead ||
				OffensiveTargetActor.IsLocked ||
				OffensiveTargetActor.Type == "NoKill NPC")
			{
				if (OffensiveTargetActor == null)
					Program.Log("Offensive target is null.");
				else
					Program.Log("Offensive target ({0}, {1}) is dead, locked, or invalid.", OffensiveTargetActor.Name, OffensiveTargetActor.ID);

				WithdrawFromCombat();
				return false;
			}

			m_OffensiveTargetActor = OffensiveTargetActor;

			/// Decide if I have aggro. In the future, use the ratio.
			Actor AggroWhoreActor = m_OffensiveTargetActor.Target();
			m_bIHaveAggro = AggroWhoreActor.IsValid && (AggroWhoreActor.ID == MeActor.ID);

			return true;
		}
	}
}
