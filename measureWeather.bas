''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Authors: Nitish Jain, Sai Vemprala
' Extreme Environments Robotics and Instrumentation Laboratory
' SESE, ASU
' April 2013
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Declare the Subroutines in the program
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Declare Sub MeasureWeather

Static weatherData = Array(8)

Public Sub MeasureWeather
	
	StatusMsg "Weather Measurement"
	
	On Error Resume Next
		If Err = 0 Then
			weatherData = SdiCollect("0M!")			
			
			For i = 0 To Ubound(weatherData)		'Dispaying the readings from sensor 
				StatusMsg "Raw WeatherData(" &i& "): " &weatherData(i)
			Next i
		Else
			ErrorMsg "WeatherMeasurement: Something failed"
		End If
		
	On Error GoTo 0
	StatusMsg "Exiting Weather Measurement"
	
End Sub
