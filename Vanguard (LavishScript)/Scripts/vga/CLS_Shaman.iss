;********************************************
function Shaman_DownTime()
{
	if ${Me.EnergyPct}<70 && ${Me.HealthPct}>65 && ${Me.Ability[Ritual of Sacrifice IV].IsReady} && ${Me.ToPawn.CombatState} == 1
   		{
		call executeability "Ritual of Sacrifice IV" "Heal" "Neither"
		}
	if ${Me.EnergyPct}<90 && ${Me.HealthPct}>85 && ${Me.Ability[Ritual of Sacrifice IV].IsReady} && ${Me.ToPawn.CombatState} == 0
   		{
		call executeability "Ritual of Sacrifice IV" "Heal" "Neither"
		}
}
;********************************************
function Shaman_PreCombat()
{

}
;********************************************
function Shaman_Opener()
{

}
;********************************************
function Shaman_Combat()
{
	if ${Me.EnergyPct}<70 && ${Me.HealthPct}>65 && ${Me.Ability[Ritual of Sacrifice IV].IsReady} && ${Me.ToPawn.CombatState} == 1
   		{
		call executeability "Ritual of Sacrifice IV" "Heal" "Neither"
		}
	if ${Me.EnergyPct}<90 && ${Me.HealthPct}>85 && ${Me.Ability[Ritual of Sacrifice IV].IsReady} && ${Me.ToPawn.CombatState} == 0
   		{
		call executeability "Ritual of Sacrifice IV" "Heal" "Neither"
		}
}
;********************************************
function Shaman_Emergency()
{

}
;********************************************
function Shaman_PostCombat()
{

}
;********************************************
function Shaman_PostCasting()
{
	if ${Me.EnergyPct}<70 && ${Me.HealthPct}>65 && ${Me.Ability[Ritual of Sacrifice IV].IsReady} && ${Me.ToPawn.CombatState} == 1
   		{
		call executeability "Ritual of Sacrifice IV" "Heal" "Neither"
		}
	if ${Me.EnergyPct}<90 && ${Me.HealthPct}>85 && ${Me.Ability[Ritual of Sacrifice IV].IsReady} && ${Me.ToPawn.CombatState} == 0
   		{
		call executeability "Ritual of Sacrifice IV" "Heal" "Neither"
		}
}
