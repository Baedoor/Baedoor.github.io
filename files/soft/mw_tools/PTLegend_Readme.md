# Project Tamriel Gridmap Legend
Small tool developed by me in Nim language that allows for building legend for gridmaps
used by [Project Tamriel](project-tamriel.com/).  

## How to use
Download the package from GitHub - you can use [this link]() for convenience.  
After you download the .zip file, unpack it somewhere and open the folder.

You should see two folders (`pois` and `fonts`) and those files:
```
factions.txt
pois.txt
pt_legend.exe
```
Clicking on .exe file, you will run the process of generating two files - one for
factions, and second for PoIs (points of interests).  
By default, they should generate the last setup my program was designed with. However,
you may want to edit or customise that. For that, you should edit .txt files mentioned
above.

### Factions
Faction legend is managed by `factions.txt` file. After opening, you will see it
structured somewhat like that:
```
--- Section Title
colour1 : name1
colour2 : name2
colour3 : name3
--- Another Section
colour4 : name4
```
The code block above kinda explains it already. Sections are separated by using
three hyphens, `---`, which can be followed by section title.  
Under the separator, you put entries by writing them each in new line. Each entry
should contain hexcode colour value (without "#"!) and name of the faction - both
separated by ` : ` (colon with spaces surrounding).

### PoIs (Points of Interest)
PoIs are managed very similarly - you use `pois.txt` file instead, but the structure
of the file will feel quite familiar:
```
--- Section Title
icon1 : name1
icon2 : name2
icon3 : name3
--- Another Section
icon4 : name4
```
The difference visible here is that instead of hexcode, the first part of entry
should be icon - to be exact, it should be name of the file located in `pois` folder.  
The name of the file should not contain spaces, however - use `_` instead.