SetProcessPriority v1 by CyberTech
 Description:
    Set the app priority for an app just launched by Inner Space
 Instructions:
    1) Place the .cs and .xml in Scripts\AttachWindbg\
    2) Add the following to Pre-Startup for the game you wish to attach:
        <Setting Name="AttachWindbg">execute ${If[${LavishScript.Executable.Find[ExeFile.exe](exists)},run SetProcessPriority ${System.APICall[${System.GetProcAddress["kernel32.dll","GetCurrentProcessId"]}]}]}</Setting>

Example:

				<Set Name="Pre-Startup Sequence" GUID="1863684435">
					<Setting Name="Debugger">execute ${If[${LavishScript.Executable.Find[ExeFile.exe](exists)},run AttachWindbg ${System.APICall[${System.GetProcAddress["kernel32.dll","GetCurrentProcessId"]}]}]}</Setting>
				</Set>
