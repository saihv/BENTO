'**************************************************************************
' Created by Andres Mora
' Extreme Environments Robotics and Instrumentation Lab
' SESE, ASU
' May, 2012
'**************************************************************************

'************************************************************************
' Functions and Subroutines Declarations
'************************************************************************
Public Declare Sub ModemInit(Portname)
Public Declare Sub FormatData(DataSetToTX)
Public Declare Function HayesCommand(Handle, Command, TimeoutSec)


'**************************************************************************
' Constants
'**************************************************************************
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

Const TrueOne = -1
Const FalseOne = 0


'**************************************************************************
' Configuration Parameters
'**************************************************************************
Const SENSORNAME = "IridiumModem"      ' Name used on block output and sensors page

'Const PORTNAME = "COM3:"
Const BAUDRATE = 19200
Const PARITY = NOPARITY
Const DATABITS = 8
Const STOPBITS = 1 'ONESTOPBIT
Const FLOWCONTROL = HANDSHAKE
Const PORT_TIMEOUT = 2 '1
Const WAKE_UP_TIME = 10

Const ENTER = CHAR_CR + CHAR_LF
Const POLL_CMD = "SEND" + ENTER
Const SET_SENDMODE_STOP_CMD = "SMODE STOP"
Const RESET_CMD = "RESET"
Const ECHO_OFF_CMD = "ECHO OFF"


'**************************************************************************
' Global variables containing CO2, SO2, weather data and the sampling Rate
'**************************************************************************
Static Rate
Static CO2Data
Static weatherData
Static So2Data

'**************************************************************************
' Initialize Iridium Modem
'**************************************************************************
Public Sub ModemInit(PORTNAME)

  On Error Resume Next
	PORT = FreeFile
	Open PORTNAME As PORT NoWait
	
	If Err Then
		WarningMsg "Could not open Iridium modem on PORT " & PORTNAME
		Exit Sub
	End If
  
	SetPort PORT, BAUDRATE, NOPARITY, DATABITS, STOPBITS, FLOWCONTROL
	SetTimeout PORT, PORT_TIMEOUT
	Turn Left(PORTNAME,Len(PORTNAME)-1), "ON"
	SetDtr PORT, 1
	Connected = True
  
	Sleep 0.2
	
	If Cts(PORT) = 0 Then
		ErrorMsg "Iridium modem is not connected. No CTS."
		Turn Left(PORTNAME,Len(PORTNAME)-1), "OFF"
		Close PORT
		PORT = FreeFile
		Connected = False
		Exit Sub
	End If
  
	' Check Modem is OK
	Result = HayesCommand(PORT, "AT", 2)
		
	If Right(Result,2) <> "OK" Then
		ErrorMsg "Iridium modem does not appear to be working: " & Result
		Exit Sub
	Else 
		StatusMsg "Hayes Cmd AT Success: " + Result
	End If
	
	Close PORT
  
End Sub


'**************************************************************************
' Send data through the modem
'**************************************************************************
Public Sub SendReceiveSBD(PORTNAME)

	StatusMsg "SendReceiveSBD @ " & PORTNAME

	Const RegTimeout = 60 '10 seconds
	Const SendTimeout = 120 '10 seconds
	DataSetToTX =""	
	RemoteCmd = ""

	On Error Resume Next
		PORT = FreeFile
		Open PORTNAME As PORT NoWait
	
		If Err Then
			WarningMsg "Could not open Iridium modem on PORT " & PORTNAME
			Exit Sub
		End If
  
		SetPort PORT, BAUDRATE, NOPARITY, DATABITS, STOPBITS, FLOWCONTROL
		SetTimeout PORT, PORT_TIMEOUT
		Turn Left(PORTNAME,Len(PORTNAME)-1), "ON"
		SetDtr PORT, 1
		Connected = True
  
		Sleep 0.2
	
		If Cts(PORT) = 0 Then
			ErrorMsg "Iridium modem is not connected. No CTS."
			Turn Left(PORTNAME,Len(PORTNAME)-1), "OFF"
			Close PORT
			PORT = FreeFile
			Connected = False
			Exit Sub
		End If
  
		''''--Clear SBD Message Buffer--''''
		'StatusMsg "AT+SBDD0"							'DEBUG
		CmdOneResp = HayesCommand(PORT, "AT+SBDD0", 2)
	
		If CmdOneResp = "" OR Right(CmdOneResp,3) = "1OK" Then
			ErrorMsg "Command AT+SBDD failed: " &CmdOneResp
			goto ErrorHandler
		Else 
			Call FormatData(DataSetToTX)
			BinString = DataSetToTX
			LenData = Format("%2d", Len(BinString))
			Result = ComputeCRC(0,0,BinString) Mod 65536'
			BinString = BinString & Chr(Result>>8) & Chr(Result Mod 256)
			
			SBDWBCmd = "AT+SBDWB=" &LenData
			'StatusMsg "SBDWBCmd Back<" &SBDWBCmd & ">"						' For Debugging Only
			
			CmdTwoResp = HayesCommand(PORT, SBDWBCmd, 2)
		
			StatusMsg "CmdTwoResp Back<" &CmdTwoResp & ">"
		
			If Right(CmdTwoResp, 5)="READY" then
				CmdThreeResp = HayesCommand(PORT, BinString, 2)
				StatusMsg "CmdThreeResp: " &CmdThreeResp
					
				If Left(CmdThreeResp,1) <> "0" then
					ErrorMsg "CmdThreeResp SBDWB failed: " &CmdThreeResp
					goto ErrorHandler
				End If
			End If
		End If
	
		'Initiate SBD Session to send the data
		StartTime = Time
		DataSent = FalseOne
	
		Do
			StatusMsg "Sending AT+SBDI"
			CmdFourResp = HayesCommand(PORT, "AT+SBDI", 15)
			StatusMsg "CmdFourResp SBDI=" &CmdFourResp
		
			If Left(CmdFourResp, 8) = "+SBDI: 1" then
				DataSent = TrueOne
				StatusMsg "Data Sent Sucessfully"
				
				StatusMsg "Checking for Msgs" 
				RemoteCmd = HayesCommand(PORT, "AT+SBDRT", 10)
				StatusMsg "RemoteCmd: " & RemoteCmd
	
				If Right(RemoteCmd,2) = "OK" then
					If Right(RemoteCmd,8) = "Rate=1OK" then        	'<--Burst Mode
						Rate = 1
						StatusMsg "NewRate= " &Rate
					ElseIf Right(RemoteCmd,8) = "Rate=0OK" then    	'<--Regular Mode
						Rate = 0
						StatusMsg "NewRate= " &Rate
					Else											'<--Maintain 	Current Mode
						ErrorMsg "No Msg RXed, keeping actual Rate= " &Rate
						goto ErrorHandler
					End If
				End If
	
				'StatusMsg "I finished!"							' For Debugging Only
					
			End If
			
			'If CDPort(PORTNAME) <> 0 then
			'	StatusMsg "CD active on modem ... abort"
			'	goto errorhandler
			'End If
	
		Loop Until (DataSent OR ((Time - StartTime)> SendTimeout))
		
		If ((Time - StartTime) > SendTimeout) then
			ErrorMsg "SBDI timeout: " &CmdFourResp			
			goto ErrorHandler
		End If
	
		ErrorHandler:
		'Call ClrDTRPort(PORT)
		'Call ClosePort(PORT)
		Close PORT
		
	Close PORT
	
End Sub

'************************************************************************
' Format data to be sent through the modem
' Sensors to TX:
' 5 min/1hr interval-
' make String look like this: mmddyyyyhhmnBat_VoltRate,Weather1,Weather2,...,WeatherN,CO2,SO2
'************************************************************************
Public Sub FormatData(DataSetToTX)

	'INITIALIZE local variables
	StatusMsg "Format routine"	
	TimeNow = now 								'What time are we starting
	DataToTx = ""
	
	'StatusMsg "TimeNow: " & TimeNow							' Debugging only
	
	MonthDate = Month(TimeNow)
	If MonthDate < 10 then
		MonthDate = "0" + MonthDate
	End If 
	
	DateStr = Day(TimeNow) & MonthDate & (Year(TimeNow) - 2000)
	TimeStr = Format("%02d", Hour(TimeNow)) & Format("%02d", Minute(TimeNow))
	DateTimeStr = DateStr & TimeStr
		
	'First, add the weather values (8) to the string to TX
	For i = 1 To Ubound(weatherData)-1
		If i = 1 then
			DataToTx = weatherData(i) 'Bin6(Int(weatherData(i)*100), 3)
		Else
			DataToTx = DataToTx & "," & weatherData(i)
			'StatusMsg "<" + DataToTx + " >"		'Debugging
		End If
	Next i
	
	'Second, add the CO2 value to the string to TX
	DataToTx = DataToTx + "," + CO2Data
	
	'Finally, add the SO2 value to the string to TX
	DataToTx = DataToTx + "," + So2Data
	
	'Grab First Set of data and add battery voltage and Rate values too
	battery = Format("%2.1f", Systat(5))		' Systat provides info about Sutron's internal state according to input number. 5 = Battery status/value
	DateTimeStr = DateTimeStr + "B" + battery + "R" + Rate
	DataSetToTX = DateTimeStr + "," +DataToTX

	StatusMsg "<" + DataSetToTX + ">"
End Sub


'************************************************************************
' HayesCommand code.
'************************************************************************

Public Function HayesCommand(Handle, Command, TimeoutSec)
  Result = ""
  If Command <> "" Then
     Sleep 0.2
     FlushInput Handle
     ' Tack on a CR and send the command to the modem
     Print Handle, Command; Chr(13);
     'DEBUG:
     StatusMsg "Sending to Modem: " & Command
  End If
  ' Wait up to the timeout for 1 character to come in
  SetTimeout Handle, TimeoutSec
  Result = ""
  StartTime = GetTickCount
  Do
     Line Input Handle, Result
  Loop Until (Result <> "") And (Result <> Command) Or
((GetTickCount-StartTime)/1000 >= TimeoutSec)
  If Left(Result, 1) = "#" Then ' Handle special results that have an OK at the end
     Trim = ""
     Do
        SetTimeout Handle, 0.1
        Line Input Handle, Trim
     Loop Until Trim <> "" or Timeout(Handle)
  End If
  SetTimeout Handle, 0.1
  ' Now read off a dangling LF that's left behind by Line Input
  LF = ""
  Count = ReadB(Handle, LF, 1)
  SetTimeout Handle, PORT_TIMEOUT
  'DEBUG:
  StatusMsg "Received from Modem: " & Result
  HayesCommand = Result
End Function


