''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Created by Andres Mora
' Extreme Environments Robotics and Instrumentation Lab
' SESE, ASU
' April, 2012
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''' 
' This program supports measuring Vaisala CO2 sensor. 
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Public Declare Sub MeasureCO2
Public Declare Sub ReadSerialPort(Port, Data, MAXBYTES) 

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Constants
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Const NOPARITY = 0
Const ODDPARITY = 1
Const EVENPARITY = 2
Const MARKPARITY = 3
Const SPACEPARITY = 4

Const ONESTOPBIT = 0
Const ONE5STOPBITS = 1
Const TWOSTOPBITS = 2

Const NOHANDSHAKE = 0
Const HANDSHAKE = 1

Const CHAR_LF = Chr(10)          ' Line feed character
Const CHAR_CR = Chr(13)          ' Carriage return character

Const MAXBYTES = 200             ' Max num bytes in sensor response. See manual.


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Configuration Parameters
'
Const SENSORNAME = "CO2"      ' Name used on block output and sensors page

Const PORTNAME = "COM4:"
Const BAUDRATE = 19200
Const PARITY = NOPARITY
Const DATABITS = 8
Const STOPBITS = ONESTOPBIT
Const FLOWCONTROL = NOHANDSHAKE
Const PORT_TIMEOUT = 2 '1
Const WAKE_UP_TIME = 10

Const ENTER = CHAR_CR + CHAR_LF
Const POLL_CMD = "SEND" + ENTER
Const SET_SENDMODE_STOP_CMD = "SMODE STOP"
Const RESET_CMD = "RESET"
Const ECHO_OFF_CMD = "ECHO OFF"

Static CO2Data


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Measure Sensor
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
   
Public Sub MeasureCO2

	StatusMsg "CO2 Measurement"

	' Initialize local data.
    Data = ""
    NumBytes = 0
    Ch = ""
	GoodDataFlag = 0
	  
    ' Measure by polling sensor for its current measurement. 
    ' Note that a failure to open the port is not reported as an error because 
    ' it's expected on occasion (when sensor has been opened for maintenance). 
      
	On Error Resume Next
    Port = FreeFile
    Open PORTNAME As Port NoWait
    If Err = 0 Then 
		SetPort Port, BAUDRATE, PARITY, DATABITS, STOPBITS, FLOWCONTROL
        SetTimeout Port, PORT_TIMEOUT
        FlushInput Port
		 
		StatusMsg "Port Initialized"
		Sleep PORT_TIMEOUT
		 
		StatusMsg "Reading Port 1st time" 'Initialization from Vaisala sensor GMP343...
		Call ReadSerialPort(Port, Data, MAXBYTES)
		 
		Sleep WAKE_UP_TIME
		 
		While GoodDataFlag = 0 
			StatusMsg "Requesting data"
			
			NumBytes = WriteB(Port, POLL_CMD, Len(POLL_CMD))	' Command sensor to return current measurement.
					 
			StatusMsg "Reading Port 2nd time" 					'Echoed and RXed data, Format: SEND[_][_]DataABC.DE[_]>
			Call ReadSerialPort(Port, Data, MAXBYTES)
         
			Sleep PORT_TIMEOUT
		 
			If StrComp(Data, "0.0") = 0 Then 
				'StatusMsg "Equal to 0.0" 'Do nothing
			Else
				GoodDataFlag = 1
				'StatusMsg "Flag: " &GoodDataFlag
			End If
		Wend
		 
        Close Port
    End If

	CO2Data = Data
    StatusMsg "DataFinal: " &CO2Data
	StatusMsg "Exiting CO2 Measurement!"
   
    On Error GoTo 0
      
End Sub

''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub ReadSerialPort(Port, Data, MAXBYTES)

	tempData = ""
	NumBytes = ReadB(Port, Data, MAXBYTES)
    If Err = 0 Then
        If NumBytes > 0 Then
			         
            'Replace unprintable characters in response string with spaces.
            For i = 1 to NumBytes
				Ch = Mid(Data, i, 1)
				If (Asc(Ch) < 46  Or Asc(Ch) = 47 Or Asc(Ch) > 57) Then  'Avoid anything different than a number in the final value we want
					'Do nothing, skip value
				Else 
					tempData = tempData + Ch							'Store in temporary variable and concatenate with previous
				End If
				
            Next i
			StatusMsg "tempData: <" & tempData & ">"
			Data = tempData
						
			'StatusMsg "Data: " &Data
			
        Else
			ErrorMsg "Vaisala CO2 Sensor: No response from sensor."
        End If
    Else
        ErrorMsg "Vaisala CO2 Sensor: Port write or read error."
    End If	

End Sub