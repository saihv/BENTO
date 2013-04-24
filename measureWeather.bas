''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Created by Nitish Jain
' Extreme Environments Robotics and Instrumentation Lab
' SESE, ASU
' April, 2012
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Declare the Subroutines in the program
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Declare Sub MeasureWeather


Static weatherData = Array(8)


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' 
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub MeasureWeather
	
	StatusMsg "Weather Measurement"
	
	On Error Resume Next
		If Err = 0 Then
			weatherData = SdiCollect("0M!")
			'weatherData = Sdi("0XWU!") ',I=5,A=10!")				'Checks what wind measurements will be sent
			'weatherData = Sdi("0XTU!")				'Checks what temp measurements will be sent
			'weatherData = Sdi("0XRU!")				'Checks what rain measurements will be sent
			'weatherData = Sdi("0XZRU!")				'Reset rain counter command will be sent
			'weatherData = Sdi("0XRU,I=10!")	'Measure for 10secs rain values
			'weatherData = Sdi("0XSU!")
			'weatherData = Sdi("0XSU,R=11110000&00000000!")				'Checks what super measurements will be sent
			'StatusMsg Ubound(weatherData)
			
			'StatusMsg weatherData
			'Sleep 0.50
			'weatherData = Sdi("0XRU!")
			'StatusMsg weatherData

			'weatherData = SdiCollect("0M5!")
			
			For i = 0 To Ubound(weatherData)		'Dispaying the readings from sensor 
				StatusMsg "Raw WeatherData(" &i& "): " &weatherData(i)
				'result = Int(weatherData(i)*10)
				'StatusMsg "WeatherData(" &i& "): " &result '&weatherData(i)
				'result = Bin6(result, 3)
				'StatusMsg "Encoded: " &result
			Next i
		Else
			ErrorMsg "WeatherMeasurement: Something failed"
		End If
		
	On Error GoTo 0
	StatusMsg "Exiting Weather Measurement"
	
End Sub
