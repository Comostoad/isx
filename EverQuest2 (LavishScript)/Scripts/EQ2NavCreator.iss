;-----------------------------------------------------------------------------------------------
; EQ2NavCreator.iss Version 1  Updated: 04/28/2008
;
; Written by: Amadeus  (Based upon EQ2PatherLegacy.iss by Blazer)
;
; v1.0 - * Initial Release
;-----------------------------------------------------------------------------------------------

#include ${LavishScript.HomeDirectory}/Scripts/EQ2Navigation/EQ2Nav_Lib.iss

#define ADDPOINT f1
#define ADDPOINTNOCOLLISION ALT+F1
#define ADDNAMEPOINT f2
#define ADDNAMEDPOINTNOCOLLISION ALT+F2
#define SAVEPOINTS f3
#define QUIT f11

function main(... Args)
{
    if !${ISXEQ2(exists)}
    {
        echo "EQ2NavCreator:: ISXEQ2 must be loaded to use this script."
        return
    }
    do
    {
        waitframe
    }
    while !${ISXEQ2.IsReady}

    declarevariable Mapper EQ2Mapper global
	declarevariable CurrentTask int global
    declarevariable HudX int script
    declarevariable HudY int script
    declarevariable AutoPlot bool script
    declarevariable NoCollision bool script
        
    ;; Variables that should be user definable (EQ2Mapper also has variables that should be assigned per user);;;
    declarevariable MapFileRegionsType string script
    ; EQ2Mapper only supports "box" region types so far...
    MapFileRegionsType:Set["Box"]
    
	Script:Squelch
	
	
	if ${Args.Size} > 0
	{
	    variable int Iterator = 1
		do
		{
			if (${Args[${Iterator}].Equal[-autoplot]} || ${Args[${Iterator}].Find[-auto]} > 0)
				AutoPlot:Set[TRUE]
		    if (${Args[${Iterator}].Equal[-nocollision]} || ${Args[${Iterator}].Find[-nocollision]} > 0)
		        NoCollision:Set[TRUE]
			else
				echo "EQ2NavCreator:: '${Args[${Iterator}]}' is not a valid command line argument:  Ignoring..."
		}
		while ${Iterator:Inc} <= ${Args.Size}
	}	
	
	

	; Set the default location of the HUD
	HudX:Set[230]
	HudY:Set[200]

	echo "---------------------------"
	echo "EQ2NavCreator:: Initializing."
    Mapper:Initialize
    Mapper:LoadMapper	
    if (${NoCollision})
        Mapper.NoCollisionDetection:Set[TRUE]
	echo "EQ2NavCreator:: Initialization complete."
    echo "---------------------------"

    bind addpoint "ADDPOINT" "CurrentTask:Set[1]"
    bind addpointnocollision "ADDPOINTNOCOLLISION" "CurrentTask:Set[2]"
	bind addnamepoint "ADDNAMEPOINT" "CurrentTask:Set[3]"
	bind addnamepointnocollision "ADDNAMEDPOINTNOCOLLISION" "CurrentTask:Set[4]"
	bind savepoints "SAVEPOINTS" "CurrentTask:Set[5]"
	bind quit "QUIT" "CurrentTask:Set[6]"

    HUD -add FunctionKey1  ${HudX},${HudY:Inc[15]} "F1     - Add a Navigational Point at your current location"
    HUD -add FunctionKey1b ${HudX},${HudY:Inc[15]} "ALT+F1 - Add a Navigational Point at your current location (and connect with no collision tests)"
	HUD -add FunctionKey2  ${HudX},${HudY:Inc[15]} "F2     - Add a Navigational Point with a region name (FQN) you specify."
	HUD -add FunctionKey2b ${HudX},${HudY:Inc[15]} "ALT+F2 - Add a Navigational Point with a region name (FQN) you specify (and connect with no collision tests)"
	
	HUD -add FunctionKey3  ${HudX},${HudY:Inc[25]} "F3     - Save ALL Navigational Points."
	HUD -add FunctionKey11 ${HudX},${HudY:Inc[15]} "F11    - Exit EQ2NavCreator (and save all navigation points)"
	
	HUD -add NavPointStatus ${HudX},${HudY:Inc[30]} "Last Nav Point Added: \${Mapper.LastRegionAdded_Name} [\${Mapper.LastRegionAdded_X.Precision[2]}(x) \${Mapper.LastRegionAdded_Y.Precision[2]}(y) \${Mapper.LastRegionAdded_Z.Precision[2]}(z)]"
	HUD -add NavCountStatus ${HudX},${HudY:Inc[15]} "Total Number of Points Used: \${Mapper.CurrentZone.ChildCount}"
	
	HUDSet NavPointStatus -c FFFF00
	HUDSet NavCountStatus -c FFFF00	
	
	
	if (${Mapper.CurrentZone.ChildCount} == 0 && ${AutoPlot})
		CurrentTask:Set[1]

	Do
	{
		switch ${CurrentTask}
		{
		    case 1
		        CurrentTask:Set[0]
		        Mapper:MapLocationBox[${Me.ToActor.Loc},"Auto"]
		        break
		        
		    case 2
		        CurrentTask:Set[0]
		        Mapper.NoCollisionDetection:Set[TRUE]
		        Mapper:MapLocationBox[${Me.ToActor.Loc},"Auto"]
		        Mapper.NoCollisionDetection:Set[FALSE]
		        break
		    
			case 3
				CurrentTask:Set[0]
				InputBox "What name do you want to give this NavPoint?"
				if ${UserInput.Length}
				{
				    echo "MapFileRegionsType: ${MapFileRegionsType}"
				    if (${MapFileRegionsType.Equal[Box]})
				    {
				        Mapper:MapLocationBox[${Me.X},${Me.Y},${Me.Z},${UserInput}]
        		        announce "\\#FF6E6ENavigational Point Added" 1 2
        		    }
				    elseif (${MapFileRegionsType.Equal[Box]})
				    {
				        ;Mapper:MapLocationPoint[${Me.X},${Me.Y},${Me.Z},${UserInput}]
        		        announce "\\#FF6E6ENavigational Point Added" 1 2
        		    }
				}
				break
				
			case 4
				CurrentTask:Set[0]
				InputBox "What name do you want to give this NavPoint?"
				if ${UserInput.Length}
				{
				    Mapper.NoCollisionDetection:Set[TRUE]
				    echo "MapFileRegionsType: ${MapFileRegionsType}"
				    if (${MapFileRegionsType.Equal[Box]})
				    {
				        Mapper:MapLocationBox[${Me.X},${Me.Y},${Me.Z},${UserInput}]
        		        announce "\\#FF6E6ENavigational Point Added" 1 2
        		    }
				    elseif (${MapFileRegionsType.Equal[Box]})
				    {
				        ;Mapper:MapLocationPoint[${Me.X},${Me.Y},${Me.Z},${UserInput}]
        		        announce "\\#FF6E6ENavigational Point Added" 1 2
        		    }
        		    Mapper.NoCollisionDetection:Set[FALSE]
				}
				break
			    
			case 5
				CurrentTask:Set[0]
				Mapper:Save
				announce "Navigational Points have been Saved" 1 3
				break
				
			case 6
				CurrentTask:Set[99]
				break
		}
		
		if (${AutoPlot})
    		Mapper:Pulse
		waitframe
	}
	while ${CurrentTask}<6

	Script:End
}

function atexit()
{
    Mapper:Save
    
    bind -delete addpoint
    bind -delete addpointnocollision
	bind -delete addnamepoint
	bind -delete addnamepointnocollision
	bind -delete savepoints
	bind -delete quit

    HUD -remove FunctionKey1
    HUD -remove FunctionKey1b
	HUD -remove FunctionKey2
	HUD -remove FunctionKey2b
	HUD -remove FunctionKey3
	HUD -remove FunctionKey11
	HUD -remove NavPointStatus
	HUD -remove NavCountStatus
}
