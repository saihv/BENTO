''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Created by Andres Mora
' Extreme Environments Robotics and Instrumentation Lab
' SESE, ASU
' April, 2012
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

			So2Raw = Ad420(1, 5)  'Module 1, Input Analog Chan 5
			'mVolts = 5 * adcRaw + (adcRaw ** $1666)   ' x 5.0875 'Calibration equation taken from previous JPL deployment @ Kilahuea
			So2Data = 5*So2Raw + (So2Raw*5.0875)	' To eliminate the decimal point from the SBD message we multiply by 100)
		
			StatusMsg "So2Raw: " +So2Raw + " So2: " +So2Data
		
			PowerAd 1, 0 				' To Power OFF Digital Switched 12V
		Else
			ErrorMsg "MeasureSO2: Something failed"
		End If
		
		StatusMsg "Exiting SO2 Measurement"
	On Error GoTo 0

End Sub

