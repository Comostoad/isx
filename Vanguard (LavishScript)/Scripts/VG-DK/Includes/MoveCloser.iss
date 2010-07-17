/*
MoveCloser v1.0
by:  Zandros, 27 Jan 2009

Description:
Simple routine to Move closer to location X and Y that returns TRUE or FALSE
Currently it does not avoid obstacles or handle being stuck

parameters:
X = Coordinate X
Y = Coordinate Y
Distance = Distance from target to stop moving (default is 3m)

Example Code:
call MoveCloser ${Me.Target.X} ${Me.Target.Y} 15	"Move within 15m of location"

External Routines that must be in your program:  faceloc
*/

/* Toggle this on or off in your scripts */
;variable bool DoMove = TRUE

;===================================================
;===       Move Closer if target exists         ====
;===================================================
function:bool MoveCloser(float X, float Y, int Distance=300)
{
	;-------------------------------------------
	; Return if we don't want to move
	;-------------------------------------------
	if !${doMove}
		return TRUE

	;-------------------------------------------
	; Convert our distance not less than 3m
	;-------------------------------------------
	Distance:Set[${Math.Calc[${Distance}*100].Int}]
	if ${Distance}<300
		Distance:Set[300]

	;-------------------------------------------
	; Set our bailout timer to 10 sec "yah, kinda short timer"
	;-------------------------------------------
	variable int bailOut
	bailOut:Set[${Math.Calc[${LavishScript.RunningTime}+(10000)]}]


	;-------------------------------------------
	; Move if we are over our distance "looks natural if we move and turn at the same time"
	;-------------------------------------------
	if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}<100 || ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Distance}
	{
		;-------------------------------------------
		; Our Target matches our X so move to target
		;-------------------------------------------
		if ${X}==${Me.Target.X}
		{
			if ${Math.Distance[${Me.X},${Me.Y},${Me.Target.X},${Me.Target.Y}]}>${Distance} && ${LavishScript.RunningTime}<=${bailOut} && !${Me.ToPawn.IsStunned} && !${isPaused} && ${doMove}
			{
				while ${Me.Target(exists)} && ${Math.Distance[${Me.X},${Me.Y},${Me.Target.X},${Me.Target.Y}]}>${Distance} && ${LavishScript.RunningTime}<=${bailOut} && !${Me.ToPawn.IsStunned} && !${isPaused} && ${doMove}
				{
					VG:ExecBinding[movebackward,release]
					VG:ExecBinding[moveforward]
					face ${Me.Target.X} ${Me.Target.Y}
				}
				VG:ExecBinding[moveforward,release]
			}
			if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}<100 && ${LavishScript.RunningTime}<=${bailOut} && !${Me.ToPawn.IsStunned} && !${isPaused} && ${doMove}
			{
				while ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}<100 && ${LavishScript.RunningTime}<=${bailOut} && !${Me.ToPawn.IsStunned} && !${isPaused} && ${doMove}
				{
					VG:ExecBinding[moveforward,release]
					VG:ExecBinding[movebackward]
					face ${X} ${Y}
				}
				VG:ExecBinding[movebackward,release]
			}
			if ${LavishScript.RunningTime}>${bailOut}
			{
				;echo "VG: Moving - BailOut timer exceeded"
				return FALSE
			}
			return TRUE
		}

	

		;-------------------------------------------
		; Keep moving forward while facing the target
		;-------------------------------------------
		if !${Me.Target(exists)} && ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Distance} && ${LavishScript.RunningTime}<=${bailOut} && !${Me.ToPawn.IsStunned} && !${isPaused} && ${doMove}
		{
			while !${Me.Target(exists)} && ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}>${Distance} && ${LavishScript.RunningTime}<=${bailOut} && !${Me.ToPawn.IsStunned} && !${isPaused} && ${doMove}
			{
				VG:ExecBinding[movebackward,release]
				VG:ExecBinding[moveforward]
				face ${X} ${Y}
			}
			VG:ExecBinding[moveforward,release]
		}

		;-------------------------------------------
		; Keep moving backward while facing the target
		;-------------------------------------------
		if ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}<100 && ${LavishScript.RunningTime}<=${bailOut} && !${Me.ToPawn.IsStunned} && !${isPaused} && ${doMove}
		{
			while ${Math.Distance[${Me.X},${Me.Y},${X},${Y}]}<100 && ${LavishScript.RunningTime}<=${bailOut} && !${Me.ToPawn.IsStunned} && !${isPaused} && ${doMove}
			{
				VG:ExecBinding[moveforward,release]
				VG:ExecBinding[movebackward]
				face ${X} ${Y}
			}
			VG:ExecBinding[movebackward,release]
		}

		;-------------------------------------------
		; Display our message if our timer ran out
		;-------------------------------------------
		if ${LavishScript.RunningTime}>${bailOut}
		{
			;echo "VG: Moving - BailOut timer exceeded"
			return FALSE
		}
	}
	return TRUE
}
