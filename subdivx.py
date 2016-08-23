import sys
import os
from lxml import html
import requests
import wget
import json

# Check if config file exists
configExists = os.path.isfile('config.json')
if (configExists):
# Load config from json
	with open('config.json') as json_data_file:
		data = json.load(json_data_file)
		logUser = data["LoginData"]["usuario"]
		logPass = data["LoginData"]["clave"]
else:
	# Load config from secret module
	from secrets import subdivx_credentials
	logUser = subdivx_credentials['user']
	logPass = subdivx_credentials['password']

# Check arguments
# Expected input: subdivx.py sName sEpisode keyword
#                    Arg1     Arg2   Arg3    Arg4
# For example: subdivx.py the+flash+2014 s02e04 hdtv
if (len(sys.argv)<2):
	print ('ERROR: No hay argumentos')
	sys.exit(0)
else:
	# Inputs
	# Series Name
	sName = sys.argv[1]
	# Series Episode
	sEpisode = sys.argv[2]
	# Series encoding group
	sGroup = sys.argv[3]
	if (len(sys.argv)>4):
		# Switch for downloading all subs for given episode
		allSubs = sys.argv[4]
	else:
		allSubs = 0
	# Search Term
	searchTerm = sName+'+'+sEpisode
	# Keyword for subtitle matching
	keyword = sGroup

print ('Buscando: ', searchTerm, ' ',keyword)

# Login data
payload = {
	"usuario": logUser, 
	"clave": logPass,
	"enviau": "1"
}

# Log in 
session_requests = requests.session()
login_url = "http://www.subdivx.com/X50"
result = session_requests.get(login_url)
tree = html.fromstring(result.text)

result = session_requests.post(
	login_url, 
	data = payload, 
	headers = dict(referer=login_url)
)

url = 'http://www.subdivx.com/index.php?accion=5&masdesc=&buscar='+searchTerm+'&oxdown=1'
result = session_requests.get(url, headers = dict(referer = url))
tree = html.fromstring(result.content)

subs = tree.xpath('//*[@id="buscador_detalle_sub"]/text()')
dLinks = tree.xpath('//div[@id="buscador_detalle_sub_datos"]//a[last()]/@href')

# Find out if there is more than one page of subs
pags = tree.xpath('//div[@class="pagination"]/a/text()')

if (pags==[]):
	# print ('No hay mas paginas')
	realPags = 1
else:
	realPags = int(len(pags)/2)
	for pages in range(2,realPags+1):
		url = 'http://www.subdivx.com/index.php?accion=5&masdesc=&buscar='+searchTerm+'&oxdown=1&pg='+str(pages)
		result = session_requests.get(url, headers = dict(referer = url))
		tree = html.fromstring(result.content)
		next_subs = tree.xpath('//*[@id="buscador_detalle_sub"]/text()')
		subs = subs + next_subs

print ('Hay ', realPags, 'pag con', len(subs), 'subs')

for x in range(0,len(subs)):
	if (allSubs=="AllSubs"):
		wget.download (dLinks[x],'sub'+str(x+1)+'.zip')
	else:
		if keyword.lower() in subs[x].lower(): 
			print ('El sub apropiado es el ', x)
			print ('Descargalo en: ', dLinks[x])
			wget.download (dLinks[x],'sub.zip')
			break
	pass

# input('Press ENTER to exit')

# This is a HACK - Its intended purpose is to pass
# the number of subs to the AHK script in order to be
# able of unzipping them all.
if (allSubs=="AllSubs"):
	sys.exit(len(subs))
else:
	sys.exit(1)