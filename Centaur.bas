Public Declare Sub CentaurCmdResp

Static NanoData
Static startMillisSoH
Static endMillisSoH
Static startMillisTmS
Static endMillisTmS
Static Env
Static Envstring
Static SoH
Static Tim
Static TimString
Static Trig
Static TrigString
Static TmS
Static Ch1
Static Ch1String
Static Ch2
Static Ch2String
Static Ch3
Static Ch3String
Dim CentaurSOHData
Dim CentaurTmSData

Public Sub CentaurCmdResp

		F = FreeFile
		F1 = FreeFile
		F2 = FreeFile
		CRLF = Chr(13)&Chr(10)

		Kill "CentaurSOHResp.txt"
		On Error Resume Next
		Kill "CentaurEventResp.txt"
		On Error Resume Next
				
		Open "CentaurSOHResp.txt" As F1 
		Open "CentaurEventResp.txt" As F2
		Open "169.254.33.33:80,TCP" As F

		StatusMsg "Opened TCP socket"

		'Defining parameters for SoH channels

		If SoH = 1 Then

			If Env = 1 Then
				EnvString = "true"
				StatusMsg "Environment"
			Else
				EnvString = "false"
			End If

			If Tim = 1 Then
				TimeString = "true"
				StatusMsg "Timing"
			Else		
				TimString = "false"
			End If

			If Trig = 1 Then
				TrigString = "true"
				StatusMsg "Triggers"
			Else
				TrigString = "false"
			End If

		End If

			'Defining parameters for Time series channels

		If TmS = 1 Then

			If Ch1 = 1 Then
				Ch1String = "true"
			Else
				Ch1String = "false"
			End If			

			If Ch2 = 1 Then
				Ch2String = "true"
			Else
				Ch2String = "false"
			End If

			If Ch3 = 1 Then
				Ch3String = "true"
			Else
				Ch3String = "false"
			End If
		End If

		If SoH = 1 Then
			StatusMsg "GET /retrieval?Group=Soh&Environment="&EnvString&"&Timing="&TimString&"&Triggers="&TrigString&"&startMillis="&startMillisSoH&"&endMillis="&endMillisSoH&" HTTP/1.0"
			Print F, "GET /retrieval?Group=Soh&Environment="&EnvString&"&Timing="&TimString&"&Triggers="&TrigString&"&startMillis="&startMillisSoH&"&endMillis="&endMillisSoH&" HTTP/1.0"&CRLF&"Host: 169.254.33.33"&CRLF&CRLF;

			Sleep 5.0
			i = 1
			Do While Not Eof(F)			
			While i < 12
				Line Input F, CentaurSOHData
				i = i+1
			Wend
			Relevant = 0
			Line Input F, CentaurSOHData
			Length = Len(CentaurSOHData)
			CommaCounter = 0
			i = 1
			While i <= Length
				If Mid(CentaurSOHData, i, 1) = "," Then
					CommaCounter = CommaCounter+1
					If CommaCounter = 3 Then
					    DurationChecker = Mid(CentaurSOHData, i+1, 1)
				    	If DurationChecker <> "," Then
					    	Relevant = 1
				    	End If
					End If
				End If
			i = i+1
			Wend
			
			CommaCounter = 0
			If Relevant = 1 Then
				i = 1
				While i <= Length
					If Mid(CentaurSOHData, i, 1) = "," Then
						CommaCounter = CommaCounter+1
						If CommaCounter = 2 Then
							StartPos1 = i+1
						ElseIf CommaCounter = 4 Then
							EndPos1 = i
						ElseIf CommaCounter = 5 Then
							StartPos2 = i+1
						End If
					End If
				i = i+1
				Wend
				FirstString = Mid(CentaurSOHData, StartPos1, EndPos1-StartPos1)
				SecondString = Mid(CentaurSOHData, StartPos2, Length-StartPos2)
				Print F1, FirstString,",", SecondString
			End If
		End Loop			
		End If

		If TmS = 1 Then
			Print F, "GET /retrieval?Group=TimeSeries&TimeSeries1="&Ch1String&"&TimeSeries2="&Ch2String&"&TimeSeries3="&Ch3String&"&startMillis="&startMillisTmS&"000"&"&endMillis="&endMillisTmS&"000"&" HTTP/1.0"&CRLF&"Host: 169.254.33.33"&CRLF&CRLF;

			StatusMsg "Requested time series data"
			Sleep 5.0

			'i = 1

			'While i < 12
			'	Line Input F, NanoData
			'	i = i+1
			'Wend

			'Do While Not Eof(F)	
				i = ReadB(F, NanoData, 100000)
				'StatusMsg "NanoData: " +NanoData
				Print F2, NanoData
			'End Loop		
			
		End If

		Close F1
		Close F
End Sub	