# Accidentabilitat de bicicletes i VMPs a la ciutat de Barcelona en funció de la llum diürna

## Context del projecte
Pràctica final de l’assignatura de Visualització de Dades del Màster en Ciència de Dades de la UOC, en la que es demana als alumnes la creació d’una visualització narrativa de temàtica lliure.

Tot observant la quantitat de patinets que circulen sense il·luminació una tarda d’hivern, ja caiguda la nit, he tingut la idea de plantejar si la manca de llum diürna influeix en el nombre d’accidents que pateixen els VMP i també en la seva gravetat. He fet servir les dades de la ciutat de Barcelona, entre els anys 2017 i 2021, publicades al portal de dades obertes de l’Ajuntament. Addicionalment he volgut comprovar com afecten les condicions meteorològiques, en especial la pluja, en l’accidentabilitat de VMPs.

El treball presentat en aquest projecte inclou, bàsicament, el procés de neteja i adequació de les dades amb llenguatge R per tal de crear les visualitzacions que es presentaran com a resultat de la pràctica amb l’eina Flourish en format d'història: [Estranys a la nit. Accidentabilitat de bicicletes i VMPs a la ciutat de Barcelona en funció de la llum diürna](https://public.flourish.studio/story/1807828/).

### Reptes
Complexitat del projecte: combinació de dades sobre les hores de llum per a establir les condicions de luminositat (diürna/nocturna) en el moment de l’accident. Juntar informació meteorològica de fitxers proporcionats amb format diferent a partir de 2020. Assignació d’una estació meteorològica a cada districte.

### Fonts de dades
Les dades d'accidentabilitat a la ciutat de Barcelona s'han obtingut al portal d'Open Data de l'Ajuntament de Barcelona, a l'[enllaç](https://opendata-ajuntament.barcelona.cat/data/ca/dataset/accidents-gu-bcn)

Les dades meteorològiques de les estacions del Servei Meteorològic de Catalunya a la ciutat de Barcelona s'han obtingut al portal d'Open Data de l'Ajuntament de Barcelona, a l'[enllaç](https://opendata-ajuntament.barcelona.cat/data/ca/dataset/mesures-estacions-meteorologiques)

Les dades de les hores de sortida i posta de sol a la ciutat de Barcelona s'han obtingut de la web [sunrise-sunset.org](https://sunrise-sunset.org/)

## Visualitzacions presentades al projecte
* Nombre de vehicles implicats en accidents per tipus de vehicle. *Recompte mensual al període 2017-2021*
* Recompte de vehicles per tipus en accidents amb vianants implicats (animació amb l’evolució). *Total acumulat des de gener de 2017*
* Mapa d'accidents amb bicicletes i VMPs implicats. *Període 2017-2021 (distinció entre diürns i nocturs amb el símbol corresponent)*
* Proporció d'accidents amb bicicletes i VMPs implicats amb llum diürna. *Recompte mensual al període 2017-2021*
* Proporció d'accidents amb bicicletes i VMPs implicats entre les 17h i les 21h. *Recompte mensual al període 2017-2021*
* Nombre d'accidents amb bicicletes i VMPs implicats segons la importància de les lesions produïdes a la víctima més greu. *Recompte al període 2017-2021 en funció de les condicions de llum (diürna o nocturna) en el moment de l'accident i la quantitat de pluja acumulada el dia de l'accident*
* Recompte del nombre de dies segons la quantitat de pluja acumulada. *Període 2017-2021*

## Conclusions a partir de les visualitzacions
* Es produeixen més accidents en presència de llum diürna, això es podria deure al fet que hi ha més desplaçaments de dia que de nit.
* La proporció d'accidents amb gravetat de lesions més greu és major amb condicions de llum nocturna.
* Caldria informació de la intensitat de pluja per a poder visualitzar la seva influència en el nombre d'accidents i la gravetat de les lesions de les persones que el pateixen.
* Al mapa d'accidents s'observa alguna zona puntual on només hi ha accidents amb llum nocturna. Convindria verificar la il·luminació d'aquests punts per a comprovar si és menys intensa que a la resta de la ciutat.

## Descripció dels fitxers R desenvolupats

**01_AccVehicles.R**

Obtenció de la informació d’interès de l’accidentabilitat de vehicles a la ciutat de Barcelona els anys 2017 a 2021. Inclou ajuntar la informació dels cinc fitxers amb la informació de cadascun dels anys a un únic dataframe, tot mantenint les columnes d’interès (feature selection), la simplificació de les categories de vehicles per a facilitar la visualització de la informació i l’escriptura de la informació resultant a un fitxer CSV.

**02_AccBicisVmps.R**

Obtenció de la informació de l’accidentabilitat de VMPs i bicicletes a la ciutat de Barcelona al període comprès entre els anys 2017 i 2021, ajuntant la informació dels cinc anys així com el nombre de persones lesionades en aquests accidents.
Addicionalment s’incorpora la informació meteorològica del dia de l’accident, en concret la quantitat de pluja recollida al llarg de la jornada categoritzada segons els criteris del Servei Meteorològic de Catalunya. Finalment s’ajunten les condicions de llum diürna a l’hora de l’accident, obtinguda a l’algoritme desenvolupat al script cleanDaylight.R
La informació resultant del tractament en aquest script s’escriu a un fitxer CSV.

**03_FormatViz.R**

En aquest script s’adapten les dades a visualitzar als requisits de l’eina flourish, per tal de generar de manera adient les visualitzacions desitjades. Es genera un CSV per a cadascuna de les visualitzacions.

**cleanDaylight.R**

Script per a la neteja i adequació de les hores de llum diürna a la ciutat de Barcelona per a obtenir, com a resultat, la informació de la primera i la darrera hora que es consideraran amb llum diürna per a cada dia al període entre els anys 2017 i 2021. Queda fora de l’abast d’aquesta descripció l’explicació de l’algoritme que s’ha fet servir per a determinar la informació d’interès.

**cleanMeteo.R**

Script per a ajuntar les dades proporcionades pel Servei Meteorològic de Catalunya (SMC) de temperatura mitjana i pluja acumulada en 24 hores per a cada dia des del 1 de gener de 2017 fins el 31 de desembre de 2021. S’agafa la informació de dues de les estacions meteorològiques del SMC a la ciutat de Barcelona: Zona Universitària (codi X8) i Raval (codi X4).
