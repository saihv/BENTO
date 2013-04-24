Public Declare Sub Nanometrics

Static NanoData
Static startMillisSoH
Static endMillisSoH
Static Env
Static Envstring
Static Tim
Static TimString
Static Trig
Static TrigString
Static Ch1
Static Ch1String
Static Ch2
Static Ch2String
Static Ch3
Static Ch3String

Public Sub Nanometrics
		StatusMsg "Starting"
		'Sleep 5.0
		F = FreeFile
		F1 = FreeFile
		CRLF = Chr(13)&Chr(10)
		
		Open "Nano.txt" As F1
		Open "169.254.30.30:80,TCP" As F

		'Defining parameters for SoH channels

		If SoH = 1 Then

			If Env = 1 Then
				EnvString = "true"
			Else
				EnvString = "false"
			End If

			If Tim = 1 Then
				TimeSeries3tring = "true"
			Else		
				TimString = "false"
			End If

			If Trig = 1 Then
				TrigString = "true"
			Else
				TrigString = "false"
			End If

		End If

			'Defining parameters for Time series channels

		If TmS = 1

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
			Print F, "GET http://169.254.30.30/retrieval?Group=SOH&Environment="&EnvString&"&Timing="&TimString&"&Triggers="&TrigString&"&startMillis="&startMillisSoH&"&endMillis="&endMillisSoH&" HTTP/1.0"&CRLF&"Host: 169.254.30.30"&CRLF&CRLF;
			i = 1
			While i < 12
				Line Input F, NanoData
				'Print F1, NanoData
				i = i+1
			Wend
			C = MsgBox(NanoData)
		End If

		If TmS = 1 Then
			Print F, "GET http://169.254.30.30/retrieval?Group=TimeSeries&TimeSeries1="&Ch1String&"&TimeSeries2="&Ch2String&"&TimeSeries3="&Ch3String&"&startMillis="&startMillisTmS&"&endMillis="&endMillisTmS&" HTTP/1.0"&CRLF&"Host: 169.254.30.30"&CRLF&CRLF;
			Close F1
			Close F
		E
End Sub	