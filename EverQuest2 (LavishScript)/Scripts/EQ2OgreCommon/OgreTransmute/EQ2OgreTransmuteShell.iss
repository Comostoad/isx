
function main()
{
	echo This script reads your inventory which is keep on the server, so some times you will need to run the script twice to transmute everything.
	echo ***WARNING*** While there are checkboxes for which boxes to Transmute, and all testing has them working properly
	echo I am not responsible for any lost items or your children being unfit.
	echo Use at your own risk... and enjoy :)
	ui -reload "${LavishScript.HomeDirectory}/Interface/skins/eq2/eq2.xml"
	ui -reload -skin eq2 "${LavishScript.HomeDirectory}/Scripts/eq2ogrecommon/OgreTransmute/eq2OgreTransmuteXML.xml"
}