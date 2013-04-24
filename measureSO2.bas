''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Created by Andres Mora
' Modified by Sai Vemprala
' Extreme Environments Robotics and Instrumentation Lab
' SESE, ASU
' February 2013
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Declare the Subroutines in the program
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Declare Sub MeasureSO2


Static So2Data

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Description of the subroutine goes HERE!!!
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub MeasureSO2

	
	StatusMsg "SO2 Measurement"
	
	On Error Resume Next
		If Err = 0 Then
			
			PowerAd 1, 1 				' To Power ON Digital Switched 12V
			Sleep 5.0					' Give some time to the SO2 sensor to wake up

			So2Data = Ad420(1, 10)  'Module 1, Input Analog Chan 5			
			
			StatusMsg "So2 level: " +So2Data

			PowerAd 1, 0 				' To Power OFF Digital Switched 12V
		Else
			ErrorMsg "MeasureSO2: Something failed"
		End If
		
		StatusMsg "Exiting SO2 Measurement"
	On Error GoTo 0

End Sub

