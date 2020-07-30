* The .click() method of a button
LOCAL x

* See https://github.com/StevenBlack/envLib for the SetDefault class
* Save, and automatically restore, the current SET DEFAULT
x = CREATEOBJECT( "SetDefault", "c:\projects\myproject" )

MODIFY PROJECT myproject NOWAIT
DO sccgen.prg
RELEASE WINDOW "Project Manager"