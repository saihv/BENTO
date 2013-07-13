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
Static PRT
Static SO2Offset

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Description of the subroutine goes HERE!!!
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub MeasureSO2

	
	StatusMsg "SO2 Measurement"
	
	On Error Resume Next
		If Err = 0 Then
			
			PowerAd 1, 1

			StatusMsg "Pump run time is "&PRT

			If PRT = 0 Then
				Sleep 5.0					' Give some time to the SO2 sensor to wake up
			Else
				Sleep PRT
			End If

			So2Data = Ad420(1, 10) + SO2Offset  'Module 1, Input Analog Chan 8			
			
			StatusMsg "So2 level: " +So2Data

			PowerAd 1, 0 				' To Power OFF Digital Switched 12V
		Else
			ErrorMsg "MeasureSO2: Something failed"
		End If
		
		StatusMsg "Exiting SO2 Measurement"
	On Error GoTo 0

End Sub

