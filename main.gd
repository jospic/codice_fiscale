extends Control

var vocali
var mesi
var controllo
var dispari
var pari

var dati = {}

func _ready():
	
	var province = {}
	
	openDB()
	
	province = getProvinciaList()
	
	# popola la lista delle province
	for i in range (0, province.size()):
		$provinciaNascita.add_item(province[i], i)
		
	vocali = "aeiouAEIOU"
	
	mesi = { '01':'A','02':'B','03':'C','04':'D',
			 '05':'E','06':'H','07':'L','08':'M',
			 '09':'P','10':'R','11':'S','12':'T'}
	
	controllo = { 0:'A',1:'B',2:'C',3:'D',4:'E',5:'F',
				  6:'G',7:'H',8:'I',9:'J',10:'K',11:'L',
				  12:'M',13:'N',14:'O',15:'P',16:'Q',17:'R',
				  18:'S',19:'T',20:'U',21:'V',22:'W',23:'X',
				  24:'Y',25:'Z'}
	
	dispari = { '0':1, '1':0, '2':5, '3':7, '4':9, '5':13,
			   '6':15, '7':17, '8':19, '9':21, 'A':1, 'B':0,
			   'C':5, 'D':7, 'E':9, 'F':13, 'G':15, 'H':17,
			   'I':19, 'J':21, 'K':2, 'L':4, 'M':18, 'N':20,
			   'O':11, 'P':3, 'Q':6, 'R':8, 'S':12, 'T':14,
			   'U':16, 'V':10, 'W':22, 'X':25, 'Y':24, 'Z':23}
	
	pari = { '0':0, '1':1, '2':2, '3':3, '4':4, '5':5,
			   '6':6, '7':7, '8':8, '9':9, 'A':0, 'B':1,
			   'C':2, 'D':3, 'E':4, 'F':5, 'G':6, 'H':7,
			   'I':8, 'J':9, 'K':10, 'L':11, 'M':12, 'N':13,
			   'O':14, 'P':15, 'Q':16, 'R':17, 'S':18, 'T':19,
			   'U':20, 'V':21, 'W':22, 'X':23, 'Y':24, 'Z':25}
	
func CalcolaCF(cognome, nome, data, comune, sesso):
	var codFisc = CalcCognome(cognome)+CalcNome(nome)+Data(data, sesso)+comune
	codFisc = codFisc+CodiceControllo(codFisc)
	return codFisc

func CalcCognome(lastname):
	var cons = ""
	var voc = ""
	for x in lastname:
		if x in vocali:
			voc += x
		else:
			cons += x
	var codCognome = (cons + voc).substr(0, 3)
	return codCognome.to_upper()

func CalcNome(name):
	var cons = ""
	var voc = ""
	for x in name:
		if x in vocali:
			voc += x
		else:
			cons += x
	if len(cons) > 3:
		cons = cons.substr(0,1) + cons.substr(2,1) + cons.substr(3,1)
	var codNome = (cons + voc).substr(0, 3)
	return codNome.to_upper()

func Data(date, gender):
	var anno = date.substr(8, 2)
	var mese = mesi[date.substr(3, 2)]
	var giorno
	if gender != "M":
		giorno = str(int(date.substr(0, 2)) + 40)
	else:
		giorno = date.substr(0, 2)
	return anno + mese + giorno
		
func CodiceControllo(codFisc):
	var indice = 0
	var a = 0
	var b = 0
	var p = []
	var d = []
	while indice < len(codFisc):
		if indice%2!=0:
			p.append(codFisc[indice])
		else:
			d.append(codFisc[indice])
		indice +=1
	
	for x in p:
		a +=  pari[x]
	for y in d:
		b += dispari[y]

	return controllo[((a+b)%26)].to_upper()

func _on_CalendarButton_date_selected(date_obj):
	$dataNascita.set_text(date_obj.date())
	generaCF()

func _on_chkM_toggled(button_pressed):
	if (button_pressed):
		generaCF()

func _on_chkF_toggled(button_pressed):
	if (button_pressed):
		generaCF()

func _on_provinciaNascita_item_selected(_id):
	var prov = $provinciaNascita.get_text()
	getComuneList(prov)
	generaCF()

func getProvinciaList():
	var prov = {}
	# ordina i dati per provincia
	dati.sort_custom(CustomSorter, "sortByProvince")
	var k = 0
	var exist = ""
	for i in range (0, dati.size()):
		# elimina i doppioni
		if (dati[i].provincia != exist):
			prov[k] = dati[i].provincia
			exist = prov[k]
			k += 1
			#print (prov[k-1])
	return prov

func getComuneList(prov):
	var com = {}
	# ordina i dati per provincia
	dati.sort_custom(CustomSorter, "sortByComune")
	var k = 0
	for i in range (0, dati.size()):
		# cerca i comuni per la provincia data
		if (dati[i].provincia == prov):
			com[k] = dati[i].comune
			k += 1
	# popola la lista dei comuni
	$comuneNascita.clear()
	for i in range (0, com.size()):
		$comuneNascita.add_item(com[i], i)

class CustomSorter:
	static func sortByProvince(a, b):
		if a["provincia"] < b["provincia"]:
			return true
		return false
		
	static func sortByComune(a, b):
		if a["comune"] < b["comune"]:
			return true
		return false
		
func openDB():
	var file = File.new()
	file.open("res://comuni.json", file.READ)
	var text = file.get_as_text()
	dati = parse_json(text)
	file.close()

func _on_comuneNascita_item_selected(_id):
	generaCF()

func _on_nome_text_changed(new_text):
	var curpos = $nome.get_cursor_position() # posizione cursore
	$nome.set_text(new_text.to_upper())	  # tutto maiuscolo
	$nome.set_cursor_position(curpos)		  # ripristina cursore all'ultima posizione
	generaCF()

func _on_cognome_text_changed(new_text):
	var curpos = $cognome.get_cursor_position() # posizione cursore
	$cognome.set_text(new_text.to_upper())	  # tutto maiuscolo
	$cognome.set_cursor_position(curpos)		  # ripristina cursore all'ultima posizione
	generaCF()
		
func _on_dataNascita_text_changed(_new_text):
	var dataNascita = $dataNascita.get_text()
	var regex = RegEx.new()
	regex.compile("^(0?[1-9]|[12][0-9]|3[01])[\\/\\-](0?[1-9]|1[012])[\\/\\-]\\d{4}$")
	var valid = regex.search(dataNascita) # valida la data
	if (valid):
		generaCF()

func generaCF():
	var cognome = $cognome.get_text().replace( " ", "")
	var nome = $nome.get_text().replace( " ", "")
	var data = $dataNascita.get_text()
	var genere = "M"
	var comune
	var com = $comuneNascita.get_text()
	if (com):
		for i in range (0, dati.size()):
			if (dati[i].comune == com):
				comune = dati[i].codice
		if ($chkF.pressed):
			genere = "F"
	if (cognome and nome and data and comune and genere):
		var cf = CalcolaCF(cognome, nome, data, comune, genere)
		if (cf):
			OS.clipboard = cf
			$CF.set_text(cf)

