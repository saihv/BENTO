Public Declare Sub CentaurDataParse

Static CentaurSOHData
Static CentaurHealthData
Static EpochCount
Dim TimeMil
Dim UTC
Dim Start
Dim Duration
Dim STA
Dim LTA
Dim Votes
Dim Channel
Dim startEpochCount
Dim endEpochCount

Public Sub CentaurDataParse

		StatusMsg "Initiating Centaur data retrieval"
		'Sleep 5.0
		F = FreeFile
		F1 = FreeFile
		CRLF = Chr(13)&Chr(10)

		startEpochCount = EpochCount		
		EpochCount = EpochCount + 7200
		endEpochCount = EpochCount

		StatusMsg startEpochCount
		StatusMsg endEpochCount

		Kill "CentaurTriggers.txt"
		On Error Resume Next
		Kill "CentaurHealth.txt"
		On Error Resume Next
					
		Open "169.254.33.33:80,TCP" As F

		Open "CentaurTriggers.txt" As F1
		Open "CentaurHealth.txt" As F2

		Print F, "GET /retrieval?Group=Soh&Environment=false&Timing=false&Triggers=true&startMillis="&startEpochCount&"000"&"&endMillis="&endEpochCount&"000"&" HTTP/1.0"&CRLF&"Host: 169.254.33.33"&CRLF&CRLF;

		Sleep 5.0
		i = 1	
		While i < 13
			Line Input F, CentaurSOHData
			i = i+1
		Wend
		Do While Not Eof(F)				
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
			
			StatusMsg "Relevant:" +Relevant

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
				FirstString = Mid(CentaurSOHData, StartPos1, EndPos1-StartPos1)+","
				StatusMsg "FirstString:" +FirstString 
				SecondString = Mid(CentaurSOHData, StartPos2, Length-StartPos2)
				StatusMsg "SecndString:" +SecondString  
				Print F1, FirstString, SecondString
			End If
		End Loop		

		Close F

		If Hour(Now) = 0 Then

			Open "169.254.30.30:80,TCP" As F

			Print F, "GET /retrieval?Group=Soh&Environment=true&Timing=true&Triggers=false&startMillis="&startEpochCount&"000"&"&endMillis="&endEpochCount&"000"&" HTTP/1.0"&CRLF&"Host: 169.254.33.33"&CRLF&CRLF;

			Sleep 5.0

			Do While Not Eof(F)
			i = 1
			While i < 13
				Line Input F, CentaurHealthData
				i = i+1
			Wend
			Line Input F, CentaurHealthData
			Print F2, CentaurHealthData
			Close F
			End Loop			
		End If

		Close F1
		
End Sub	