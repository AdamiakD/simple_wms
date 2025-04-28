Application.Visible = .F.
_SCREEN.VISIBLE =.F.
_SCREEN.WindowState = 1

Try 
	DO config.prg
Catch to err
	MessageBox('Simple_WMS:' + Chr(10) + err)
EndTry 
DO FORM _main
READ EVENTS

