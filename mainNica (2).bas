''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Authors: Andres Mora, Sai Vemprala
' Extreme Environments Robotics and Instrumentation Laboratory
' SESE, ASU
' April 2013
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'Main Routine

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Declare the Subroutines in the program
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Declare Sub MeasureWeather
Public Declare Sub MeasureSO2
Public Declare Sub MeasureCO2
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
Static So2Data
Static So2Offset

Public Sub SCHED_Main

	StatusMsg "Main"
	
	If ((Rate = 0) AND ((Hour(Now) Mod 2)= 0) AND (Minute(Now) = 0)) THEN

	Do
		Call MeasureWeather									' Measure Weather data
		Sleep 1.0											' Sleep 1 sec.
		
		Call MeasureCO2										' Measure CO2 value
		Sleep 1.0 
		
		Call MeasureSO2
		Sleep 1.0

		'So2Data = Tag("So2Tag_2", 1) + So2Offset	 	
		'mode: ALARM (1), MOST RECENT (2),  MANUAL MODE (3)
		'StatusMsg "SO2: " +So2Data

		Call ModemInit("COM3:") 							' Initialize the modem
		Sleep 1.0									 
		
		Call SendReceiveSBD("COM3:")            ' Send/Receive Data through Iridium

		If Rate = 1 Then
			StatusMsg "Sleeping for 5 minutes"
			Sleep 300
		End If

	Loop Until Rate = 0

	StatusMsg "End of routine"
	
	End If
End Sub





