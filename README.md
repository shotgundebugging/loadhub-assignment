Backend (loadhub-be)
loadhub-be conține o versiune simplificată a unor subsisteme din LoadHub.
Scopul exercițiului este să rezolvați cerințele prin scrierea codului, fără a fi necesară rularea aplicației.
Soluțiile propuse vor fi analizate și discutate în cadrul interviului tehnic.

1.
Construirea unui sistem intern de audit (de la zero, fără utilizarea unor librării externe).
Un manager de cont va avea acces la toate log-urile relevante companiei sale.
Sistemul trebuie să înregistreze log-uri pentru următoarele acțiuni:
  - accesarea informațiilor despre un anumit transport
  - crearea unui nou transport
  - actualizarea unei adrese din nomenclator
  - ștergerea unei adrese din nomenclator
Fiecare înregistrare trebuie să specifice:
  - statusul acțiunii (dacă a avut loc cu succes sau nu)
  - erorile (în cazul în care acțiunea nu a avut succes)
  - alte informații pe care le considerați relevante
Țineți cont că sistemul trebuie să fie scalabil pentru zeci/sute de acțiuni și entități.

2.
Fiecare transport primește coordonate de la aplicația mobilă a șoferului care efectuează acel transport.
Aplicația mobilă trimite coordonatele printr-un endpoint API la fiecare 2 minute.
În cazul în care nu se poate stabili o conexiune cu API-ul (ex: lipsă conexiune internet), aplicația salvează coordonatele intern și le trimite pe toate sub formă de array în momentul în care conexiunea cu API-ul este restabilită.
Să se construiască un serviciu care primește ca parametru un transport și generează statusuri automate pe baza coordonatelor înregistrate.
Logica de generare a statusurilor automate este descrisă mai jos.

START AUTOMAT: READY → MOVING
Detectează momentul în care un șofer părăsește punctul de încărcare și schimbă automat statusul transportului din READY în MOVING.

  Descriere flux:
  Detecție proximitate – pentru fiecare transport cu status READY, sistemul verifică dacă șoferul se află la mai puțin de 100 de metri de locația de start a transportului. Daca da, transportul este marcat temporar ca "nearby".
  Detecție ieșire – dacă un transport marcat anterior ca "nearby" se află în afara razei de 100 de metri și are încă statusul READY, este considerat că șoferul a părăsit punctul de încărcare. Transportul este schimbat automat în status MOVING.
  De asemenea, o data plecat, nu mai ramane marcat ca "nearby".

PAUZĂ AUTOMATĂ: MOVING → PAUSED
Detectează când un șofer rămâne staționar o perioadă mai lungă în timpul cursei și schimbă automat statusul transportului din MOVING în PAUSED.

  Descriere flux:
  Verificare status MOVING – sistemul verifică dacă transportul se afla în statusul MOVING.
  Calcul viteză – sistemul calculează viteza șoferului folosind coordonatele GPS curente și anterioare (km/h).
  Monitorizare viteză mică – dacă viteza șoferului este ≤ 2 km/h, sistemul incrementează un contorul "pauseIterations" (folosit pentru a urmări cât timp șoferul stă pe loc). Dacă viteza depășește 2 km/h, contorul se resetează la 0.
  Declanșare pauză – când contorul "pauseIterations" ajunge la 2 (adică șoferul a stat aproape pe loc timp de aproximativ 4 minute), sistemul schimbă statusul transportului din MOVING în PAUSED.
  Dacă transportul nu se afla in statusul MOVING sau viteza crește înainte de atingerea pragului, contorul "pauseIterations" se resetează și statusul nu se schimbă.

RESTART AUTOMAT: PAUSED → MOVING
Detectează momentul în care șoferul își reia deplasarea după o pauză și schimbă automat statusul transportului din PAUSED în MOVING.

  Descriere flux:
  Verificare status PAUSED – sistemul verifică dacă transportul se afla în statusul PAUSED.
  Calcul viteză – sistemul calculează viteza șoferului folosind coordonatele GPS curente și anterioare (km/h).
  Verificare viteză – dacă viteza depășește 5 km/h, sistemul consideră că șoferul se deplasează din nou.

FINALIZARE AUTOMATĂ: (MOVING sau PAUSED) → FINALIZED
Detectează momentul în care șoferul ajunge la destinație și finalizează automat transportul prin schimbarea statusului în FINALIZED.

  Descriere flux:
  Verificare status MOVING sau PAUSED – sistemul verifică dacă transportul se afla în statusul MOVING sau PAUSED.
  Verificare proximitate – sistemul verifică dacă șoferul se află la mai puțin de 100 de metri de destinația finală. Daca da, transportul este marcat ca FINALIZED.


Note:
Nu se pot genera statusuri automate pentru un transport cu statusul draft.
Pentru calculul distantei dintre 2 puncte se poate folosi RGeo (returneaza distanta in metrii):
  first_point = RGeo::Geographic.spherical_factory.point(first_point.longitude, first_point.latitude)
  second_point = RGeo::Geographic.spherical_factory.point(second_point.longitude, second_point.latitude)
  first_point.distance(second_point)

Frontend (loadhub-fe)
3.
Creați un proiect de frontend folosind Nuxt 3 și implementați o pagină care reproduce designul din fisierele jpeg.
Pagina trebuie să respecte structura, stilurile și elementele vizuale din design și să fie complet responsive, adaptându-se corect la diferite dimensiuni de ecran.
Implementarea trebuie realizată folosind componente și bune practici specifice ecosistemului Nuxt 3.
Iconițele și culorile necesare se găsesc în folderul assets/ și trebuie utilizate conform designului.
Datele necesare pentru afișarea informațiilor în interfață se află în fișierul gpsProviders.json, care simulează răspunsul unui API.
