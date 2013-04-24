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
Public Declare Sub Nanometrics

Public Declare Sub ModemInit(Port)
Public Declare Sub ModemInit(Portname)
Public Declare Sub SendReceiveSBD(Port)

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global variables containing CO2, SO2, weather data and the sampling Rate
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Static Rate
Static So2Data
Static So2Offset


Public Sub SCHED_Main

	StatusMsg "Main"
	
	If ((Rate = 0) AND ((Hour(Now) Mod 2)= 0) AND (Minute(Now) = 0)) THEN
		Call MeasureWeather									' Measure Weather data
		Sleep 1.0											' Sleep 1 sec.
		
		Call MeasureCO2										' Measure CO2 value
		Sleep 1.0 
		
		So2Data = Tag("So2Tag", 1) + So2Offset		
		'mode: ALARM (1), MOST RECENT (2),  MANUAL MODE (3)
		StatusMsg "SO2: " +So2Data

		'Call Nanometrics
		'Sleep 1.0
		
		Call ModemInit("COM3:") 							' Initialize the modem
		Sleep 1.0									 
		
		Call SendReceiveSBD("COM3:")            ' Send/Receive Data through Iridium

		StatusMsg "End of routine"
		
	ElseIf (Rate = 1) THEN
		While (Rate = 1)
			Call MeasureWeather									' Measure Weather data
			Sleep 1.0											' Sleep 1 sec.
		
			Call MeasureCO2										' Measure CO2 value
			Sleep 1.0 
			
			So2Data = Tag("So2Tag", 1) + So2Offset		
			'mode: ALARM (1), MOST RECENT (2),  MANUAL MODE (3)
			StatusMsg "SO2: " +So2Data

			'Call Nanometrics									' Call seismometer module
			'Sleep 1.0
			
			Call ModemInit("COM3:") 							' Initialize the modem
			Sleep 1.0											 
			
			Call SendReceiveSBD("COM3:")            ' Send/Receive Data through Iridium
			StatusMsg "End of loop"
			
			Sleep 300
		Wend
    End If
	
End Sub





