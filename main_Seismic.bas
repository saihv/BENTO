''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Authors: Andres Mora, Sai Vemprala
' Seismic BENTO
' Extreme Environments Robotics and Instrumentation Laboratory
' SESE, ASU
' July 2013
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'Main Routine

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Declare the Subroutines in the program
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Declare Sub CentaurDataParse
Public Declare Sub CentaurCmdResp

Public Declare Sub ModemInit(Port)
Public Declare Sub ModemInit(Portname)
Public Declare Sub SendReceiveSBD(Port)
Public Declare Sub SendReceiveSBDCentaur(Port)

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global variables containing CO2, SO2, weather data and the sampling Rate
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Static Rate
Static So2Offset
Static EpochCount
Static SoH
Static TmS

Public Sub SCHED_Main

	StatusMsg "Main"

	'Enter one time epoch count value here. WARNING: DO NOT TURN OFF RECORDING AFTER THIS IS DONE. IF RECORDING
	'NEEDS TO BE TURNED OFF, THIS VALUE NEEDS TO BE UPDATED.
	
	If ((Rate = 0) AND ((Hour(Now) Mod 2)= 0) AND (Minute(Now) = 0)) THEN

		If Month(Now) = 7 AND Day(Now) = 18 AND Year(Now) = 2013 AND Hour(Now) = 12 AND Minute(Now) = 00 THEN
			EpochCount = 1368154800
		End If

	Do
		Call CentaurDataParse
		Sleep 1.0

		Call ModemInit("COM3:") 							' Initialize the modem
		Sleep 1.0									 
		
		Call SendReceiveSBD("COM3:")            ' Send/Receive Data through Iridium

		If SoH = 1 OR TmS = 1 Then
			Call CentaurCmdResp
			Sleep 1.0

			Call ModemInit("COM3:") 							' Initialize the modem
			Sleep 1.0									 
		
			Call SendReceiveSBDCentaur("COM3:")            ' Send/Receive Data through Iridium
			Sleep 1.0

		End If
		
		SoH = 0
		TmS = 0

		If Rate = 1 Then
			StatusMsg "Sleeping for 5 minutes"
			Sleep 300
		End If

	Loop Until Rate = 0

	StatusMsg "End of routine"
	
	End If
End Sub





