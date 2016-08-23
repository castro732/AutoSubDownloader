![logo](http://i.imgur.com/hwviI2A.png)
#AutoSubDownloader 

AutoSubDownloader es un pequeño script, hecho con AutoHotkey y Python, que sirve para descargar automáticamente los subtítulos de series (por ahora solo series) desde [SubDivx](http://www.subdivx.com) y [TuSubtitulo.com](http://www.tusubtitulo.com)

<div align="center">
        <img width="100%" src="http://i.imgur.com/ObG2dv8.gif" alt="About screen" title="About screen"</img>
        <img height="0" width="8px">
</div>

##Características
- Descarga el subtitulo apropiado (basándose en resolución, codec, release group) desde subdivx y lo renombra igual que el archivo de video al presionar *Ctrl + Shift + S*.
		Ejemplo:
```
Serie.S04E05.HDTV-LOL.mp4
Serie.S04E05.HDTV-LOL.srt
```

- Descarga todos los subtítulos disponibles (desde subdivx) al presionar *Ctrl + Shift + A* y los renombra al estilo:
```
Serie.S04E05.HDTV-LOL.mp4
Serie.S04E05.HDTV-LOL.1.srt
Serie.S04E05.HDTV-LOL.2.srt
Serie.S04E05.HDTV-LOL.3.srt
...
```

##Instalación

 - 	**Opción 1:**
Accede a la sección [releases](/releases) y descarga los binarios, tienes 2 versiones:
    * **Versión instalable**, que añade la sección al menú inicio y un autorun automático.
    * **Versión portable**, solo necesitas ejecutar el archivo *ASD.exe* y el programa se comenzara a ejecutar.

- **Opción 2:**
Descarga el código fuente y ejecutar el archivo *ASD.ahk*


##Requisitos

**Generales:**
- 7-Zip ([descargar](http://www.7-zip.org/download.html))

**Si usas los binarios:**
- Microsoft Visual C++ 2010 SP1

**Si usas el código fuente:**
- AutoHotKey ([descargar](https://autohotkey.com/download/ahk-install.exe))
- Python 3.5.2


##Uso

- Ejecutar el script de AutoHotKey (*ASD.ahk*) o el archivo ejecutable (*ASD.EXE*), que se encuentra dentro de la carpeta AutoSubDownloader. Si el script esta corriendo, veras este icono ![ASK icon](http://i.imgur.com/3iwdG2h.png?1) o este icono ![ASD icon](http://i.imgur.com/hYlM3Tr.png) en tu barra de tareas.
- ¡Listo! Ahora solo ve y selecciona un archivo de video y presiona *Ctrl + Shift + S*
