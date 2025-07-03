import time
time.sleep(2)

print('''▄▄▄█████▓▓█████  ███▄ ▄███▓ ██▓███   ██▓    ▓█████                
▓  ██▒ ▓▒▓█   ▀ ▓██▒▀█▀ ██▒▓██░  ██▒▓██▒    ▓█   ▀                
▒ ▓██░ ▒░▒███   ▓██    ▓██░▓██░ ██▓▒▒██░    ▒███                  
░ ▓██▓ ░ ▒▓█  ▄ ▒██    ▒██ ▒██▄█▓▒ ▒▒██░    ▒▓█  ▄                
  ▒██▒ ░ ░▒████▒▒██▒   ░██▒▒██▒ ░  ░░██████▒░▒████▒               
  ▒ ░░   ░░ ▒░ ░░ ▒░   ░  ░▒▓▒░ ░  ░░ ▒░▓  ░░░ ▒░ ░               
    ░     ░ ░  ░░  ░      ░░▒ ░     ░ ░ ▒  ░ ░ ░  ░               
  ░         ░   ░      ░   ░░         ░ ░      ░                  
            ░  ░       ░                ░  ░   ░  ░               
                                                                  
  ██████ ▓█████▄▄▄█████▓▄▄▄█████▓ ██▓    ▓█████  ██▀███    ██████ 
▒██    ▒ ▓█   ▀▓  ██▒ ▓▒▓  ██▒ ▓▒▓██▒    ▓█   ▀ ▓██ ▒ ██▒▒██    ▒ 
░ ▓██▄   ▒███  ▒ ▓██░ ▒░▒ ▓██░ ▒░▒██░    ▒███   ▓██ ░▄█ ▒░ ▓██▄   
  ▒   ██▒▒▓█  ▄░ ▓██▓ ░ ░ ▓██▓ ░ ▒██░    ▒▓█  ▄ ▒██▀▀█▄    ▒   ██▒
▒██████▒▒░▒████▒ ▒██▒ ░   ▒██▒ ░ ░██████▒░▒████▒░██▓ ▒██▒▒██████▒▒
▒ ▒▓▒ ▒ ░░░ ▒░ ░ ▒ ░░     ▒ ░░   ░ ▒░▓  ░░░ ▒░ ░░ ▒▓ ░▒▓░▒ ▒▓▒ ▒ ░
░ ░▒  ░ ░ ░ ░  ░   ░        ░    ░ ░ ▒  ░ ░ ░  ░  ░▒ ░ ▒░░ ░▒  ░ ░
░  ░  ░     ░    ░        ░        ░ ░      ░     ░░   ░ ░  ░  ░  
      ░     ░  ░                     ░  ░   ░  ░   ░           ░  
                                                                  ''')
time.sleep (3)
load = 0

#readme
#readme kodu na samym dole
readme = input ("\nCzy pokazać samouczek? [tak/nie]")
readme = readme.lower()
if readme == "tak":
  print ("\nTwoi poddani wydobywają po dwie sztuki wybranego surowca na turę, z wyjątkiem złota. Twórz budynki, by nie opierać się tylko na pracy poddanych i pomnażać bogactwo! Jednak uważaj, bo wroga armia nie śpi, i powinieneś być na nią zawsze przygotowany...")
  time.sleep (5)
  print ("Po zbudowaniu siedmiu budynków, Twoi poddani będą w nich pracować i nie będą mieli jak zyskiwać dla Ciebie surowców. Jednak wówczas zyskasz dostęp do Panelu Królestwa, dzięki czemu będziesz mógł wpłynąć na inne aspekty swojego państwa.")
  readme = input ("\nNaciśnij Enter, gdy będziesz gotowy")
else:
  pass
load_que = input ("\n-------------------ZAPIS GRY------------------- \nGrę zapisujesz poprzez napisanie *save* w dowolnym momencie gry \n----------------------------------------------- \nCzy wczytać grę? [tak/nie]")
load_que = load_que.lower()
if load_que == "tak":
  load = 1
  try:
    loadfile = open("save.py","r")
    loadfile.close()
  except FileNotFoundError:
    print ("\nPrzykro mi, nie ma zapisanych gier")
    load = 0
else:
  pass
readme = input ("\nWciśnij Enter, by zacząć grę\n\n")

#wartości
stone = 0
wood = 0
clay = 0
gold = 0
weapons = 0
stonework = 0
woodwork = 0
claywork = 0
goldwork = 0
weaponry = 0
diplomacy = 0
science = 0
labor = 0
trade = 0
trade2 = 0
upgrade1 = 0
upgrade2 = 0
upgrade3 = 0
kingopt = 0
victory = 0
defence = 0
attack = 0
fight = 0
build = 0
nosave = 0
save = 0
turn = 1

#Wczytanie gry
if load == 1:
  loadfile = open("save.py","r")
  line1 = loadfile.readline()
  line2 = loadfile.readline()
  line3 = loadfile.readline()
  line4 = loadfile.readline()
  line5 = loadfile.readline()
  line6 = loadfile.readline()
  line7 = loadfile.readline()
  line8 = loadfile.readline()
  line9 = loadfile.readline()
  line10 = loadfile.readline()
  line11 = loadfile.readline()
  line12 = loadfile.readline()
  line13 = loadfile.readline()
  line14 = loadfile.readline()
  line15 = loadfile.readline()
  line16 = loadfile.readline()
  line17 = loadfile.readline()
  line18 = loadfile.readline()
  line19 = loadfile.readline()
  line20 = loadfile.readline()
  line21 = loadfile.readline()
  line22 = loadfile.readline()
  loadfile.close()
  stone = ''.join(line1)
  wood = ''.join(line2)
  clay = ''.join(line3)
  gold = ''.join(line4)
  weapons = ''.join(line5)
  stonework = ''.join(line6)
  woodwork = ''.join(line7)
  claywork = ''.join(line8)
  goldwork = ''.join(line9)
  weaponry = ''.join(line10)
  diplomacy = ''.join(line11)
  science = ''.join(line12)
  labor = ''.join(line13)
  trade = ''.join(line14)
  trade2 = ''.join(line15)
  upgrade1 = ''.join(line16)
  upgrade2 = ''.join(line17)
  upgrade3 = ''.join(line18)
  kingopt = ''.join(line19)
  victory = ''.join(line20)
  build = ''.join(line21)
  turn = ''.join(line22)
  #str->int
  stone = int(stone)
  wood = int(wood)
  clay = int(clay)
  gold = int(gold)
  weapons = int(weapons)
  stonework = int(stonework)
  woodwork = int(woodwork)
  claywork = int(claywork)
  goldwork = int(goldwork)
  weaponry = int(weaponry)
  diplomacy = int(diplomacy)
  science = int(science)
  labor = int(labor)
  trade = int(trade)
  trade2 = int(trade2)
  upgrade1 = int(upgrade1)
  upgrade2 = int(upgrade2)
  upgrade3 = int(upgrade3)
  kingopt = int(kingopt)
  victory = int(victory)
  build = int(build)
  turn = int(turn)
  print ("---Gra została wczytana---")
else:
  pass
  
  
  

while turn != False:
  time.sleep (2)
  print("\n-----------------------------------------------")
  print("Tura", turn)
  turn = turn+1
  
  #nowe surowce+interfejs
  turn_stone = stonework * 2
  turn_wood = woodwork * 2
  turn_clay = claywork * 2
  turn_gold = goldwork * 2
  turn_weapons = weaponry
  turn_science = labor
  if upgrade1 == 1:
    turn_stone = stonework * 3
    turn_wood = woodwork * 3
    turn_clay = claywork * 3
  else:
    pass
  if upgrade2 == 1:
    turn_weapons = weaponry * 2
  else:
    pass
  stone = stone + turn_stone
  wood = wood + turn_wood
  clay = clay + turn_clay
  gold = gold + turn_gold
  weapons = weapons + turn_weapons
  science = science + turn_science
  print("KAMIEŃ", stone, "DREWNO", wood, "GLINA", clay, "ZŁOTO",gold)
  print("ZYSKI: [",stonework,"|",woodwork,"|",claywork,"|",goldwork,"]")
  if trade == 1:
	  print ("TARG WYBUDOWANY")
  else:
	  pass
  if labor > 0:
	  print ("LABORATORIA",labor)
  else:
	  pass
  if weapons > 0:
	  print("ARMIA",weapons)
  else:
	  pass
  time.sleep (1)
	
	#panel początkowy
  if build < 7:
	  kingopt = 0
	  time.sleep (1)
	  ask = input('''\nCo chcesz, by wydobywali Twoi poddani? [kamien/drewno/glina/zloto]''')
	  ask = ask.lower()
	  if ask == ("kamien"):
		  stone = stone + 2
		  print("Wydobyto dwie sztuki kamienia")
	  elif ask == ("drewno"):
		  wood = wood + 2
		  print("Ścięto dwa drzewa")
	  elif ask == ("glina"):
		  clay = clay + 2
		  print("Wydobyto dwie sztuki gliny")
	  elif ask == ("zloto"):
		  gold = gold + 1
		  print("Wydobyto złoto")
	  elif ask == ("cheat"):
	    wood = wood+50
	    stone = stone+50
	    clay = clay+50
	    gold = gold+50
	    weapons = weapons+50
	    turn = turn+10
	  elif ask == ("save"):
	    save = 1
	  else:
		  print("Napisałeś coś źle... za karę nie otrzymujesz żadnych surowców z pracy poddanych")
	  print("\nKAMIEŃ", stone, "DREWNO", wood, "GLINA", clay, "ZŁOTO", gold)
	
	#panel królestwa 
  elif build >= 7:
	  kingopt = 1
	  time.sleep (1)
	  print ("\n[PANEL KRÓLESTWA]")
	  #punkty badań, dyplomacja
	  print ("NAUKA",science,"DYPLOMACJA",diplomacy)
	  print ("\n[BADANIA] Pozwalają na wybór pewnych ulepszeń, jeżeli zdobyłeś odpowiednio wiele punktów nauki \n[DYPLOMACJA] Pokazuje dostępne opcje polityczne")
	  if trade == 1:
	    print ("[HANDEL] Pozwala na wymianę towarów z przyjaznymi krajami")
	  else:
	      pass
	  kingdom = input ("Którą opcję wybierasz?")
	  kingdom = kingdom.upper()
	  
	  #królestwo - badania
	  if kingdom == "BADANIA":
	    print ("\n------------------")
	    if upgrade1 == 0:
	      print ("[ULEPSZENIE PRODUKCJI] Zwiększa produkcję surowców \n[8 pkt badań, 10 złota]")
	    else:
	      pass
	    if upgrade2 == 0:
	      print ("[ULEPSZENIE KOSZAR] Armia szkoli więcej żołnierzy \n[4 pkt badań, 5 złota]")
	    else:
	      pass
	    if upgrade3 == 0:
	      print ("[ULEPSZENIE BRONI] Armia dostaje lepszą broń \n[3 pkt badań, 5 złota]")
	    else:
	      pass
	    if upgrade1 == 1 and upgrade2 == 1 and upgrade3 == 1:
	      shame_its_no_upgrades = input ("Niestety nie masz już czego ulepszyć")
	    else:
	      pass
	    sci_choose = input ("Wybierasz któreś badanie?")
	    sci_choose = sci_choose.upper()
	    if sci_choose == "ULEPSZENIE PRODUKCJI":
	      if science >= 8 and gold >= 10:
	        science = science - 8
	        gold = gold - 10
	        upgrade1 = 1
	        print ("\nUlepszono produkcję!")
	        time.sleep (1)
	      else:
	        print ("Nie masz wystarczająco dużo środków")
	        time.sleep (1)
	    elif sci_choose == "ULEPSZENIE KOSZAR":
	      if science >= 4 and gold >= 5:
	        science = science - 4
	        gold = gold - 5
	        upgrade2 = 1
	        print ("\nUlepszono koszary!")
	        time.sleep (1)
	      else:
	        print ("Nie masz wystarczająco dużo środków")
	        time.sleep (1)
	    elif sci_choose == "ULEPSZENIE BRONI":
	      if science >= 3 and gold >= 5:
	        science = science - 3
	        gold = gold - 5
	        upgrade3 = 1
	        print ("\nUlepszono broń!")
	        time.sleep (1)
	      else:
	        print ("Nie masz wystarczająco dużo środków")
	        time.sleep (1)
	        
	  #królestwo - dyplomacja
	  elif kingdom == "DYPLOMACJA":
	    print ("------------------")
	    print ("[PODAREK] Podarek kosztuje Cię pięć sztuk złota, jednak polepsza Twoje stosunki z sąsiadami \n[EMISARIUSZ] Emisariusz ma szansę polepszyć Twoje stosunki z sąsiadami, kosztuje Cię dwie sztuki złota")
	    if trade2 != 1:
	      print ("[PROSBA O HANDEL] Otwiera możliwość handlu - potrzebujesz jednak mieć co najmniej przyjazny stosunek z sąsiadami (3 pkt dyplomacji) i wybudowany targ")
	    else:
	      pass
	    diplomacy_ask = input ("Co wybierasz?")
	    diplomacy_ask = diplomacy_ask.upper()
	    if diplomacy_ask == "PODAREK":
	      if gold >= 5:
	        gold = gold - 5
	        diplomacy = diplomacy + 1
	        print ("Podarek ucieszył Twoich sąsiadów")
	        time.sleep (1)
	      else:
	        print ("Nie masz dość złota, by ofiarować podarek!")
	        time.sleep (1)
	    elif diplomacy_ask == "EMISARIUSZ":
	      if gold >= 2:
	        gold = gold - 2
	        import random
	        emisario = random.randint(1,3)
	        if emisario == 1:
	          diplomacy = diplomacy + 1
	          print ("Emisariusz zakończył swoją misję pomyślnie")
	          time.sleep (1)
	        elif emisario > 1:
	          print ("Emisariusz wrócił z pustymi rękoma")
	          time.sleep (1)
	      else:
	        print ("Nie masz dość złota, by zatrudnić emisariusza")
	        time.sleep (1)
	    elif diplomacy_ask == "PROSBA O HANDEL":
	      if diplomacy >= 3 and trade == 1:
	        trade_chance = random.randint (1,2)
	        if trade_chance == 1:
	          trade2 = 1
	          print ("Udzielono Ci pozwolenia!")
	          time.sleep (1)
	        else:
	          print ("Wniosek został odrzucony")
	          time.sleep (1)
	      elif diplomacy >= 3:
	        print ("Nie wybudowałeś targu..")
	        time.sleep (1)
	      elif trade == 1:
	        print ("Nie masz dość dobrych stosunków z sąsiadami")
	        time.sleep (1)
	      else:
	        print ("Nie posiadasz odpowiednich środków!")
	        time.sleep (1)
	        
	  #królestwo - handel
	  elif kingdom == "HANDEL":
	    if trade2 == 1:
	      print ("[1] Sprzedaj 10 sztuk drewna za 3 sztuki złota \n[2] Sprzedaj 10 sztuk gliny za 3 sztuki złota \n[3] Sprzedaj 10 sztuk kamienia za 4 sztuki złota \n[4] Zakup 3 żołnierzy za 6 sztuk złota")
	      tradeque = input ("Którą ofertę wybierasz?")
	      if tradeque == "1":
	        if wood >= 10:
	          wood = wood - 10
	          gold = gold + 3
	          print ("Wymiana przebiegła pomyślnie")
	          time.sleep (1)
	        else:
	          print ("Nie masz odpowiednio dużo drewna")
	      elif tradeque == "2":
	        if clay >= 10:
	          clay = clay - 10
	          gold = gold + 3
	          print ("Wymiana przebiegła pomyślnie")
	          time.sleep (1)
	        else:
	          print ("Nie masz odpowiednio dużo gliny")
	      elif tradeque == "3":
	        if stone >= 10:
	          stone = stone - 10
	          gold = gold + 4
	          print ("Wymiana przebiegła pomyślnie")
	          time.sleep (1)
	        else:
	          print ("Nie masz odpowiednio dużo kamienia")
	      elif tradeque == "4":
	        if gold >= 6:
	          gold = gold - 6
	          weapons = weapons + 3
	          print ("Zakup żołnierzy powiódł się")
	          time.sleep (1)
	        else:
	          print ("Nie masz odpowiednio dużo złota")
	    else:
	      print ("Nie otrzymałeś pozwolenia na handel")
	      time.sleep (2)
	  elif kingdom == "SAVE":
	    save = 1
	  else:
	    pass
	  
	#panel budowy
  time.sleep (2)
  print("------------------")
  ask2 = input('''\nCzy chcesz wybudować jakiś budynek? [tak/nie]''')
  if ask2 == ("nie"):
	  pass
  elif ask2 == ("save"):
	  save = 1
  elif ask2 == ("tak"):
	  
		#budowa
	  print("\n------------------")
	  print('''Możesz wybudować: \nKOPALNIA [+2 kamienia, kosztuje: 2 gliny, 2 drewna] \nTARTAK [+2 drewna, kosztuje: 4 gliny] \nWYDOBYCIE GLINY [+2 gliny, kosztuje: 4 drewna] \nMENNICA [+2 złota, kosztuje: 4 drewna, 2 gliny, 2 kamienia] \nKOSZARY [+1 żołnierz, kosztuje: 4 kamienia, 3 drewna, 5 złota]''')
	  if kingopt == 1:
		  print ("\nPanel królestwa daje Ci ponadto: \nLABORATORIUM [+1 punkt nauki, kosztuje: 5 kamienia, 3 drewna, 2 gliny, 3 złota] \nTARG [pozwala na wymianę handlową, kosztuje: 4 kamienia, 5 drewna, 4 gliny, 3 złota]")
	  ask3 = input("\nCo wybierasz? [wpisz nazwę zapisaną dużymi literami]")
	  ask3 = ask3.upper()
	  if ask3 == ("KOPALNIA"):
		  if wood >= 2 and clay >= 2:
			  wood = wood - 2
			  clay = clay - 2
			  stonework = stonework + 1
			  build = build + 1
			  print("Wybudowano kopalnię")
		  else:
			  print("Nie masz wystarczająco dużo surowców")
	  elif ask3 == ("TARTAK"):
		  if clay >= 4:
			  clay = clay - 4
			  woodwork = woodwork + 1
			  build = build + 1
			  print("Wybudowano tartak")
		  else:
			  print("Nie masz wystarczająco dużo surowców")
	  elif ask3 == ("WYDOBYCIE GLINY"):
		  if wood >= 4:
			  wood = wood - 4
			  claywork = claywork + 1
			  build = build + 1
			  print("Wybudowano kopalnię gliny")
		  else:
			  print("Nie masz wystarczająco dużo surowców")
	  elif ask3 == ("MENNICA"):
		  if wood >= 4 and clay >= 2 and stone >= 2:
			  wood = wood - 4
			  clay = clay - 2
			  stone = stone - 2
			  goldwork = goldwork + 1
			  build = build + 1
			  print("Wybudowano mennicę")
		  else:
			  print("Nie masz wystarczająco dużo surowców")
	  elif ask3 == ("KOSZARY"):
		  if stone >= 4 and wood >= 3 and gold >= 5:
			  stone = stone - 4
			  wood = wood - 3
			  gold = gold - 5
			  weaponry = weaponry + 1
			  build = build + 1
			  print ("Wybudowano koszary")
		  else:
			  print("Nie masz wystarczająco dużo surowców")
	  elif ask3 == ("LABORATORIUM"):
		  if kingopt == 1:
		    if stone >=5 and wood >= 3 and clay >= 2 and gold >= 3:
		      stone = stone - 5
		      wood = wood - 3
		      clay = clay - 2
		      gold = gold - 3
		      labor = labor + 1
		      print ("Wybudowano laboratorium!")
		    else:
		      print ("Nie masz wystarczająco dużo surowców")
		  else:
		    print ("Nie masz dostępu do tej budowli")
	  elif ask3 == ("TARG"):
		  if kingopt == 1:
		    if stone >= 4 and wood >= 5 and clay >= 4 and gold >= 3:
		      stone = stone - 4
		      wood = wood - 5
		      clay = clay - 4
		      gold = gold - 3
		      trade = 1
		      print ("Wybudowano targ!")
		    else:
		      print ("Nie masz wystarczająco dużo surowców")
		  else:
		    print ("Nie masz dostępu do tej budowli")
	  else:
		  pass
  else:
	  pass
			
			
  #walka_z_mocarstwem (event)
  if turn == 12:
	  fight = 1
	  nosave = 1
  elif turn == 16:
	  fight = 1
	  nosave = 1
  elif turn == 21:
	  fight = 1
	  nosave = 1
  elif turn == 30:
	  fight = 1
	  nosave = 1
	  victory = 1
  else:
	  pass
  if fight == 1:
	  print("\n---------------------------------------------")
	  time.sleep (1)
	  print('''Nagle, Twoi poddani zauważyli, że Twoje królestwo jest atakowane... Twoja armia wychodzi im na powitanie''')
	  print("Twoja armia liczy", weapons, "żołnierzy")
	  import random
	  if victory != 1:
	    enemy = random.randint(1, 10)
	  else:
	    enemy = random.randint(10, 25)
	  if enemy > 5:
		  print("Wroga jest sporo!")
	  elif enemy <= 5:
		  print("Wróg nie wydaje się być silny")
	  time.sleep (1)
	  defence = weapons * 1
	  attack = enemy * 1
	  strategy = input('''Jak zaatakować wroga? \nZ ZASKOCZENIA [przydatne przy małych armiach] \nZOLW [przydatne z duzym przeciwnikiem]''')
	  strategy = strategy.upper()
	  if strategy == ("Z ZASKOCZENIA"):
		  if enemy > 5:
			  attack = attack * 2
		  if enemy <= 5:
			  defence = defence * 2
	  elif strategy == ("ZOLW"):
		  if enemy > 5:
			  defence = defence * 2
		  if enemy <= 5:
			  attack = attack * 2
	  else:
		  defence = float(defence)
		  attack = float(attack)
		  attack = attack * 1.5
	  time.sleep (1)
	  if upgrade3 == 1:
	    defence = defence * 1.5
	  else:
		  pass
		
		
		
    #Walka
	  print ("Siła Twojej armii:", defence)
	  print ("Siła armii przeciwnika:", attack)
	  time.sleep (2)
	  if attack > defence:
		  print("\n----------------------------------")
		  print("PRZEGRAŁEŚ GRĘ, PRZYKRO NAM")
		  break
	  elif defence == attack:
		  print("OBRONILIŚMY SIĘ, ale to pyrrusowe zwycięstwo..")
		  time.sleep (1)
		  print("Straciliśmy wszystkie jednostki!")
		  weapons = 0
		  if woodwork > 2:
		    build = build - woodwork
		    woodwork = 0
		    print("Zniszczono nam wszystkie tartaki!")
		  else:
		    pass
		  if stonework > 1:
		    build = build - stonework
		    stonework = 0
		    print ("Zniszczono nam wszystkie kopalnie!")
		  else:
		    pass
		  if goldwork > 0:
		    build = build - goldwork
		    goldwork = 0
		    print("Zniszczono nam wszystkie mennice!")
		  else:
		    pass
		  if stone and clay > 2:
		    stone = 0
		    clay = 0
		    print("Atak spustoszył część naszych surowców")
		  else:
		    pass
		  fight = 0
		  time.sleep (2)
	  elif defence > attack:
		  print("\n----------------------------------")
		  print("SZCZĘŚLIWIE SIĘ OBRONIŁEŚ")
		  print("Ponadto zebrałeś od wrogów łupy")
		  lost_army = weapons - enemy
		  lost_army = weapons - lost_army
		  lost_army = int(lost_army)
		  if lost_army < 0:
			  lost_army = 0
		  else:
			  pass
		  weapons = weapons - lost_army
		  if weapons < 0:
			  weapons = 0
		  else:
			  pass
		  print("W walce straciłeś", lost_army, "żołnierzy")
		  found_gold = random.randint(1, 15)
		  gold = gold + found_gold
		  print("I zdobyłeś ponadto", found_gold, "złota")
		  fight = 0
		  time.sleep (2)
  else:
	  pass
			
			
  #Wygrana			
  if fight == 0 and victory == 1:
	  print ("Wygrałeś!")
	  time.sleep (1)
	  sandbox = input ("\nCzy chcesz grać w trybie sandboxowym? [pozwala on na dowolną ilość tur, bez obawy, że ktoś Cię zaatakuje][tak/nie]")
	  sandbox = sandbox.lower()
	  if sandbox == "tak":
	    pass
	  else:
	    break
  else:
	  pass
	
	
	#Zapis gry
  if save == 1:
	  if nosave == 0:
	    turn = turn-1
	  else:
	    pass
	  savefile = open("save.py","w")
	  stone = str(stone)
	  wood = str(wood)
	  clay = str(clay)
	  gold = str(gold)
	  weapons = str(weapons)
	  stonework = str(stonework)
	  woodwork = str(woodwork)
	  claywork = str(claywork)
	  goldwork = str(goldwork)
	  weaponry = str(weaponry)
	  diplomacy = str(diplomacy)
	  science = str(science)
	  labor = str(labor)
	  trade = str(trade)
	  trade2 = str(trade2)
	  upgrade1 = str(upgrade1)
	  upgrade2 = str(upgrade2)
	  upgrade3 = str(upgrade3)
	  kingopt = str(kingopt)
	  victory = str(victory)
	  build = str(build)
	  turn = str(turn)
	  save_files = (stone + "\n" + wood + "\n" + clay + "\n" + gold + "\n" + weapons + "\n" + stonework + "\n" + woodwork + "\n" + claywork + "\n" + goldwork + "\n" + weaponry + "\n" + diplomacy + "\n" + science + "\n" + labor + "\n" + trade + "\n" + trade2 + "\n" + upgrade1 + "\n" + upgrade2 + "\n" + upgrade3 + "\n" + kingopt + "\n" + victory + "\n" + build + "\n" + turn)
	  savefile.write(save_files)
	  savefile.close()
	  end_que = input ("Gra została zapisana! \nCzy zakończyć grę? [tak/nie]")
	  end_que = end_que.lower()
	  if end_que == "tak":
	    break
	  else:
	    stone = int(stone)
	    wood = int(wood)
	    clay = int(clay)
	    gold = int(gold)
	    weapons = int(weapons)
	    stonework = int(stonework)
	    woodwork = int(woodwork)
	    claywork = int(claywork)
	    goldwork = int(goldwork)
	    weaponry = int(weaponry)
	    diplomacy = int(diplomacy)
	    science = int(science)
	    labor = int(labor)
	    trade = int(trade)
	    trade2 = int(trade2)
	    upgrade1 = int(upgrade1)
	    upgrade2 = int(upgrade2)
	    upgrade3 = int(upgrade3)
	    kingopt = int(kingopt)
	    victory = int(victory)
	    build = int(build)
	    turn = int(turn)
	    save = 0
	    continue
  else:
	  pass
	
	

#------------------------------------------------------------	
#objaśnienie zmiennych:
  #ask - panel początkowy (zbiór surowca)
  #ask2 - panel budowy
  #ask3 - panel wyboru budowy
  #kingdom - panel królestwa (wybór opcji)
  #kingopt - opcje dostępne przy królestwie
  #trade - jest zbudowaniem targu
  #trade2 - jest dostępnymi opcjami w handlu
	
#cheaty:
  #wpisując "cheat" w oknie wydobycia poddanych, przeskakujesz o 10 tur do przodu, jak i zyskujesz 50 sztuk każdego surowca
#--------------------------------------------------------------
#(strategia)
#v.0.3
#Autor: Tomasz Stępień