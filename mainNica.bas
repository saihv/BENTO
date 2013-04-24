''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Created by Andres Mora
' Extreme Environments Robotics and Instrumentation Lab
' SESE, ASU
' April, 2012
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'Main Routine

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Declare the Subroutines in the program
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Declare Sub MeasureWeather
Public Declare Sub MeasureSO2
Public Declare Sub MeasureCO2

Public Declare Sub ModemInit(Port)
Public Declare Sub ModemInit(Portname)
Public Declare Sub SendReceiveSBD(Port)

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global variables containing CO2, SO2, weather data and the sampling Rate
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Static Rate
Static So2Data


Public Sub SCHED_Main

	StatusMsg "Main"
	
	If ((Rate = 0) AND ((Hour(Now) Mod 2)= 0) AND (Minute(Now) = 0)) OR ((Rate = 1) AND ((Minute(Now) Mod 5)= 0)) THEN   ' Records every two hours (every 5 mins, high rate)
	'If ((Rate = 0) AND (Minute(Now) = 30) OR (Minute(Now) = 0)) OR ((Rate = 1) AND ((Minute(Now) Mod 5)= 0)) THEN   ' Records every half-an-hour (every 5 mins, high rate)
		Call MeasureWeather									' Measure Weather data
		Sleep 1.0											' Sleep 1 sec.
		
		Call MeasureCO2										' Measure CO2 value
		Sleep 1.0 
		
	'	Call MeasureSO2										' Measure SO2 value
	'	Sleep 1.0											 
	
		So2Data = Tag("So2Tag", 1)
		StatusMsg "S: " +So2Data
		a 
		Call ModemInit("COM3:") 							' Initialize the modem
		Sleep 1.0											 
		
		Call SendReceiveSBD("COM3:")            ' Send/Receive Data through Iridium
		
	
				
    Else   
		StatusMsg "Sleeping"
		
    End If
	
End Sub





