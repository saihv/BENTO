'**************************************************************************
' Created by Andres Mora
' Modified by Sai Vemprala
' Extreme Environments Robotics and Instrumentation Lab
' SESE, ASU
' May, 2012
'**************************************************************************

'************************************************************************
' Functions and Subroutines Declarations
'************************************************************************
'Public Declare Sub ModemInit(Portname)
Public Declare Sub FormatCentaurData(DataSetToTX)
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
Static PRT
Static CO2Data
Static weatherData
Static So2Data
Static SoH
Static TmS
Static Ch1
Static Ch2
Static Ch3
Static startMillisTmS
Static endMillisTmS
Static Env
Static Tim
Static Trig
Static startMillisSoH
Static endMillisSoH
Static CentaurData

Dim TimeMil
Dim UTC
Dim Start
Dim Duration
Dim STA
Dim LTA
Dim Votes
Dim Channel
'SO2_positive_offset = 0
CRLF = Chr(13)&Chr(10)

'**************************************************************************
' Initialize Iridium Modem
'**************************************************************************



'**************************************************************************
' Send data through the modem
'**************************************************************************
Public Sub SendReceiveSBDCentaur(PORTNAME)

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

		Call FormatCentaurData(DataSetToTX)
		Datacounter = 1
		DataLength = Len(DataSetToTX)
		StatusMsg "Length is" &DataLength
		Do
  
		''''--Clear SBD Message Buffer--''''
		'StatusMsg "AT+SBDD0"							'DEBUG
		CmdOneResp = HayesCommand(PORT, "AT+SBDD0", 2)
	
		If CmdOneResp = "" OR Right(CmdOneResp,3) = "1OK" Then
			ErrorMsg "Command AT+SBDD failed: " &CmdOneResp
			goto ErrorHandler
		Else 
			'Call FormatCentaurData(DataSetToTX)
			BinString = Mid(DataSetToTX, Datacounter, 300)
			StatusMsg "<"+BinString+">"
			LenData = Format("%2d", Len(BinString))
			StatusMsg LenData
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
			StatusMsg "Sending AT+SBDI for Centaur data"
			CmdFourResp = HayesCommand(PORT, "AT+SBDI", 15)
			StatusMsg "CmdFourResp SBDI=" &CmdFourResp
		
			If Left(CmdFourResp, 8) = "+SBDI: 1" then
				DataSent = TrueOne
				StatusMsg "Centaur Data Sent Sucessfully"
				
					
				'StatusMsg "I finished Centaur!"							' For Debugging Only

				
					
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

		Datacounter = Datacounter+300
		StatusMsg "Position is " &Datacounter
		Loop Until Datacounter > DataLength
	
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
Public Sub FormatCentaurData(DataSetToTX)

	
	If SoH = 1 Then
		F2 = FreeFile
		Open "CentaurSoHResp.txt" As F2
		Do While Not Eof(F2)
			Line Input F2, CentaurData
			DataSetToTX = "SOH DATA"+DataSetToTX+CentaurData
		End Loop

		Close F2
	End If

	If TmS = 1 Then
		F2 = FreeFile
		Open "CentaurEventResp.txt" As F2
		DataSetToTX = "Time series data"
		Do While Not Eof(F2)
			Line Input F2, CentaurData
			DataSetToTX = DataSetToTX+CRLF+CentaurData
		End Loop

		Close F2
	End If

	StatusMsg "<" + DataSetToTX + ">"

	Open "\SD Card\EventData.Txt" As F3
	Print F3, DataSetToTX
	Close F3
	
End Sub

