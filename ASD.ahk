#NoEnv

; CTRL + SHIFT + S
; Principal - Descarga el mejor sub por episodia
~^+s::ASD(0)

; CTRL + SHIFT + A
; Secundario - Descarga todos los subs del mismo episodio
~^+A::ASD(1)

; Funcion principal
ASD(AllSubs){
	if (AllSubs=1) {
		AllSubs := "AllSubs"
	}
	else{
		AllSubs := ""
	}
	; Guarda el portapapeles
	SavedClip:= Clipboard, Clipboard:= ""
	Send ^c
	ClipWait, 4
	; Obtener archivos, en caso de ser varios
	StringSplit, FileNames, Clipboard, `n, `r 
	
	
	If (FileNames0>1){
		Prog := 100/ FileNames0
		Prog := Round(Prog)
		Progress, b w200, Descargando subtitulos, ASD, ASD
	}
	else {
		Progress, b w200, Descargando subtitulos, ASD, ASD
		Progress, 50
	}	
	Loop, %FileNames0% {
		; Separar los archivos
		SplitPath, FileNames%A_Index%, OutFileName, dir, Ext, OutNameNoExt
		; Chequear la extension del archivo
  	If !Instr(",avi,mkv,mp4,mpg,wmv,divx,mov,mpeg,wmp,flv,vob,", "," Ext ",")
    	Continue
  	If (FileNames0>1){
	    ; Contar el progreso
	  	P := (A_Index * Prog)
			Progress, %P%
		}
		; Ejecutar script de descarga
  	SubDownload(OutFileName, dir, Ext, OutNameNoExt, AllSubs)
	}
	
	Progress, Off
	; Restaura el portapapeles
  Clipboard := SavedClip
	Return
}


SubDownload(OutFileName, dir, Ext, OutNameNoExt, AllSubs)
{
	; Obtener el nombre de la serie
	sName := GetShowName(OutFileName)
	; Se reemplazan los espacios con signos +
	StringReplace, sName, sName, %A_Space%, +, All
	; Obtener la temporada de la serie
	sSeason := GetSeasonNumber(OutFileName)
	; Obtener el episodio de la serie
	sEpisode := GetEpisodeNumber(OutFileName)
	; Obtener una palabra clave, ya sea de la fuente o el grupo del release
	sKeyword := GetKeyword(OutFileName)

	; Hotfix para CASTLE (2009) debido a que la serie
	; no lleva el año en subdivx
	if (sName = "castle+2009")
		sName := "castle"
	; Mismo hotfix para The Odd Couple 2015
	else if(sName = "the+odd+couple+2015")
		sName := "the+odd+couple"
	

	If (AllSubs = "AllSubs"){
		Progress, b w200, Descargando subtitulos, ASD, ASD
		Progress, 50
	}
	; Ejecutar el script de python que descarga el sub desde SubDivX
	; MsgBox, subdivx.py %sName% S%Sseason%E%sEpisode% %sKeyword%
	IfExist, %A_WorkingDir%\subdivx.py
		runwait subdivx.py %sName% S%Sseason%E%sEpisode% %sKeyword% %AllSubs% ,, 
	IfExist, %A_WorkingDir%\subdivx.exe
		runwait subdivx.exe %sName% S%Sseason%E%sEpisode% %sKeyword% %AllSubs% ,, 
	Progress, 90
	numberOfSubs := ErrorLevel
	file = sub.zip
	fileName = sub
	FileMove, %A_WorkingDir%\%file%, %dir%
	Sleep, 500
	Progress, Off
		
  ; Unzip subtitulo - Se necesita 7-Zip
  if (numberOfSubs>1){
  	Loop, %numberOfSubs% {
  		FileMove, %A_WorkingDir%\%fileName%%A_Index%.zip, %dir%
	  	if (A_Is64bitOS = 1) { 
		    runwait "C:\Program Files\7-Zip\7z.exe" e "%dir%\sub"%A_Index%".zip" -o"%dir%\sub\" -y,,hide 
		  } 
		  else { 
		  	runwait "%A_ProgramFiles%\7-Zip\7z.exe" e "%dir%\sub"%A_Index%".zip" -o"%dir%\sub\" -y,,hide
		  }

		  FileMove, %dir%\%fileName%\*.srt, %dir%\%OutNameNoExt%.%A_Index%.srt
		  ;Borra el ZIP del sub y la carpeta
		  FileDelete, %dir%\%fileName%%A_Index%.zip
		  FileRemoveDir, %dir%\%fileName%
		}
	}
  else{
	  if (A_Is64bitOS = 1) { 
	    runwait "C:\Program Files\7-Zip\7z.exe" e "%dir%\sub.zip" -o"%dir%\sub\" -y,,hide 
	  } 
	  else { 
	  	runwait "%A_ProgramFiles%\7-Zip\7z.exe" e "%dir%\sub.zip" -o"%dir%\sub\" -y,,hide
	  }

	  FileMove, %dir%\%fileName%\*.srt, %dir%\%OutNameNoExt%.srt
	  ;Borra el ZIP del sub y la carpeta
	  FileDelete, %dir%\%file%
	  FileRemoveDir, %dir%\%fileName%
  } 

  Return
}


; ### Funcion que obtiene el nombre de la serie dado un nombre de archivo ###
; Soporta los siguientes tipos de nombre (igual para obtener temporada y episodio):
; Castle 2009 - S03E01 - A Deadly Affair - [HDTV].mp4
; Greys.Anatomy.S10E01E02.HDTV.x264-LOL.mp4
; the.odd.couple.2015.201.hdtv-lol.mp4
; The.Flash.2014.S02E22.HDTV.x264.REPACK-LOL[rarbg].mp4
; Suits.6x01.HDTV.x264-KILLERS.mkv
GetShowName(FileName)
{
	IfInString, FileName, .
		StringReplace, NormalName, FileName, ., %A_Space%, All
	IfInString, NormalName, _
		StringReplace, NormalName, NormalName, _, %A_Space%, All
	If RegExMatch(NormalName, "i)s[0-9][0-9]? ?e[0-9][0-9]?", SeasonAndEpisode)
	{
		StringGetPos, SeasonAndEpisodePos, NormalName, %SeasonAndEpisode%
		StringLeft, ShowName, NormalName, (SeasonAndEpisodePos - 1)
	}
	Else If RegExMatch(NormalName, "i)[0-9][0-9]?x[0-9][0-9]?", SeasonAndEpisode)
	{          
		StringGetPos, SeasonAndEpisodePos, NormalName, %SeasonAndEpisode%
		StringLeft, ShowName, NormalName, (SeasonAndEpisodePos - 1)
	}
	Else If RegExMatch(NormalName, "[0-9][0-9][0-9][0-9]?", SeasonAndEpisode)
	{                      
		pos = 1
		While pos := RegExMatch(NormalName,"[0-9][0-9][0-9][0-9]?", match, pos+StrLen(match))
		{
			Conf%A_Index% := match
			ConfPos%A_Index% := pos
		}

		if (SeasonAndEpisode>1900)
		{               
			StringLeft, ShowName, NormalName, (ConfPos2 - 1)
		}
		else
		{
			StringGetPos, SeasonAndEpisodePos, NormalName, %SeasonAndEpisode%
			StringLeft, ShowName, NormalName, (SeasonAndEpisodePos - 1)
		}
	}
	Loop
	{
		StringRight, LastChar, ShowName, 1
		If (LastChar = "-" or LastChar = " ")
			StringTrimRight, ShowName, ShowName, 1
		Else
			Break
	}
	
	Return ShowName
}

;Obtiene el numero de la temporadaa
GetSeasonNumber(FileName)
{
	If RegExMatch(FileName, "i)s\K[0-9][0-9]?.?e[0-9][0-9]?", SeasonAndEpisode)
	{
		StringSplit, OutputArray, SeasonAndEpisode, e E, .
		SeasonNumber = %OutputArray1%
		IfInString, SeasonNumber, 0
		{
			StringGetPos, ZeroLoc, SeasonNumber, 0
			If ZeroLoc = 0
			StringTrimLeft, SeasonNumber, SeasonNumber, 1
		}
 	}
	Else If RegExMatch(FileName, "i)[0-9][0-9]?x[0-9][0-9]?", SeasonAndEpisode)
	{
		StringSplit, OutputArray, SeasonAndEpisode, x X
		SeasonNumber = %OutputArray1%
		IfInString, SeasonNumber, 0
		{
			StringGetPos, ZeroLoc, SeasonNumber, 0
			If ZeroLoc = 0
				StringTrimLeft, SeasonNumber, SeasonNumber, 1
		}
	}
	Else If RegExMatch(FileName, "[0-9][0-9][0-9][0-9]?", SeasonAndEpisode)
	{
		pos = 1
		While pos := RegExMatch(FileName,"[0-9][0-9][0-9][0-9]?", match, pos+StrLen(match))
		{
			Conf%A_Index% := match
			ConfPos%A_Index% := pos
		}
		if (SeasonAndEpisode>1900)
		{               
			SeasonAndEpisode = %Conf2%
		}

		StringTrimRight, SeasonNumber, SeasonAndEpisode, 2
		IfInString, SeasonNumber, 0
		{
		 StringGetPos, ZeroLoc, SeasonNumber, 0
		 If ZeroLoc = 0
				StringTrimLeft, SeasonNumber, SeasonNumber, 1
		}
	}

	Return PadZero(SeasonNumber)
}

; Obtiene el numero del episodio
GetEpisodeNumber(FileName)
{
	If RegExMatch(FileName, "i)s\K[0-9][0-9]?.?e[0-9][0-9]?", SeasonAndEpisode)
	{
		StringSplit, OutputArray, SeasonAndEpisode, e E, .
		EpisodeNumber = %OutputArray2%
		IfInString, EpisodeNumber, 0
		{
			StringGetPos, ZeroLoc, EpisodeNumber, 0
			If ZeroLoc = 0
				StringTrimLeft, EpisodeNumber, EpisodeNumber, 1
		}
	}
	Else If RegExMatch(FileName, "i)[0-9][0-9]?.?x[0-9][0-9]?", SeasonAndEpisode)
	{
		StringSplit, OutputArray, SeasonAndEpisode, x X
		EpisodeNumber = %OutputArray2%
		IfInString, EpisodeNumber, 0
		{
			StringGetPos, ZeroLoc, EpisodeNumber, 0
			If ZeroLoc = 0
				StringTrimLeft, EpisodeNumber, EpisodeNumber, 1
		}
	}
	Else If RegExMatch(FileName, "[0-9][0-9][0-9][0-9]?", SeasonAndEpisode)
	{
		pos = 1
		While pos := RegExMatch(FileName,"[0-9][0-9][0-9][0-9]?", match, pos+StrLen(match))
		{
			Conf%A_Index% := match
			ConfPos%A_Index% := pos
		}
		if (SeasonAndEpisode>1900)
		{               
			SeasonAndEpisode = %Conf2%
		}

		StringRight, EpisodeNumber, SeasonAndEpisode, 2
		IfInString, EpisodeNumber, 0
		{
			StringGetPos, ZeroLoc, EpisodeNumber, 0
			If ZeroLoc = 0
				StringTrimLeft, EpisodeNumber, EpisodeNumber, 1
		}
	}

	Return PadZero(EpisodeNumber)
}

; Obtiene el formato del release, resolucion
GetRelease(FileName)
{   
	Source_720p := RegExMatch( Filename, "i)720p")
	If (RegExMatch( Filename, "i)720p") >= 7)
		RELEASE = %RELEASE%720p
	Else If (RegExMatch( Filename, "i)1080p") >= 7)
		RELEASE = %RELEASE%1080p
	Else If (RegExMatch( Filename, "i)1080i") >= 7)
		RELEASE = %RELEASE%1080i
	Else If (RegExMatch( Filename, "i)hdtv") >= 7)
		RELEASE = %RELEASE%HDTV
	Else If (RegExMatch( Filename, "i)hr") >= 7)
		RELEASE = %RELEASE%HR
	Else If (RegExMatch( Filename, "i)pdtv") >= 7)
		RELEASE = %RELEASE%PDTV
	Else If (RegExMatch( Filename, "i)dvdrip") >= 7)
		RELEASE = %RELEASE%DVDRip
	Else If (RegExMatch( Filename, "i)webrip") >= 7)
		RELEASE = %RELEASE%WEBRip
	Else If (RegExMatch( Filename, "i)web.*dl") >= 7)
		RELEASE = %RELEASE%WEB DL
	
	Return RELEASE
}

; Obtiene la etiquera especial del release (Proper, repack...)
GetSpecialTag(Filename)
{
	; Check Special tags

	If (RegExMatch( Filename, "i)proper") >= 1)
		SpecialTag = PROPER
	Else If (RegExMatch( Filename, "i)repack") >= 1)
		SpecialTag = REPACK
	Else If (RegExMatch( Filename, "i)ws") >= 1)
		SpecialTag = WS
	Else If (RegExMatch( Filename, "i)extended") >= 1)
		SpecialTag = EXTENDED
	Else If (RegExMatch( Filename, "i)internal") >= 1)
		SpecialTag = iNTERNAL
	Else If (RegExMatch( Filename, "i)preair") >= 1)
		SpecialTag = PREAIR
	Else If (RegExMatch( Filename, "i)final") >= 1)
		SpecialTag = FINAL

	Return SpecialTag
}

; Obtiene el grupo del release del capitulo
GetGroup(Filename) 
{
	
	IfExist, %A_WorkingDir%\groups.txt 
	{
		FileRead, fileGroups, groups.txt
		StringSplit, groups, fileGroups, `n, `r 
		
		numberOfLines := groups0

		Loop, %numberOfLines%
		{
			IfInString, Filename, % groups%A_Index%
				Return groups%A_Index%
		}		
	}
	else {
		groups := ["lol","killers","dimension","fleet","ambit","batv","fum","afg","c4tv","msd","asap","2hd","evolve","excellence","fqm","fov","tla"]

		for k, v in groups {
			IfInString, Filename, %v%	
				Return v
		}	
	}	

	
}

; Obtiene la palabra clave para conseguir el subtitulo adecuado
GetKeyword(FileName) 
{ 
	T := GetSpecialTag(FileName)
	G := GetGroup(FileName)
	R := GetRelease(FileName)

	if (T)
	{
		Return T
	}
	else if (G)
	{
		Return G
	}
	else
	{
		Return R
	}
}

; Añade 0 a las temporadas o capitulos de un digito
; por ejemplo 1 se convierte en 01
PadZero(VarToPad) {
   VarToPadLen := StrLen(VarToPad)
   If VarToPadLen = 1
      VarToPad = 0%VarToPad%
   VarToPadLen =
   Return VarToPad
}