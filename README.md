# ⚽ Bet Assistant# Bet Assistant

System do importowania i analizy danych meczów piłkarskich z API-Football.Aplikacja do importowania i analizy statystyk meczów piłkarskich z API Football.

---## 🚀 Technologie

## 📋 Spis treści- **Node.js** + TypeScript

- **Prisma** ORM

- [Wymagania](#-wymagania)- **PostgreSQL** baza danych

- [Instalacja](#-instalacja)- **Express** serwer HTTP

- [Konfiguracja](#-konfiguracja)- **API Football** źródło danych

- [Uruchamianie](#-uruchamianie)

- [Funkcje](#-funkcje)## 📦 Instalacja

- [Limity API](#-limity-api)

- [FAQ](#-faq)1. **Zainstaluj Node.js** (wersja 16+): https://nodejs.org/

- [Specyfikacja techniczna](#-specyfikacja-techniczna)

2. **Zainstaluj zależności**:

---

```bash

## 🔧 Wymaganianpm install

```

- **Node.js** 18+ (zalecane: 20 LTS)

- **PostgreSQL** 14+3. **Skonfiguruj zmienne środowiskowe** w pliku `.env`:

- **Konto API-Football** (https://www.api-football.com/)

- System operacyjny: Windows, macOS lub Linux```env

DATABASE_URL="postgresql://postgres:postgres@localhost:1906/bet_assistant"

---API_FOOTBALL_KEY="twoj-klucz-api"

````

## 📦 Instalacja

4. **Wygeneruj Prisma Client**:

### 1. Sklonuj/pobierz projekt

```bash

```bashnpx prisma generate

git clone <repository-url>```

cd "Bet Asistant"

```## 🎯 Uruchomienie



### 2. Zainstaluj zależności### Metoda 1: One-click launcher (zalecane)



```bash```bash

npm installcd launcher

```.\bet-assistant.exe

````

### 3. Skonfiguruj bazę danych

Launcher automatycznie:

Utwórz bazę PostgreSQL:

- Uruchamia serwer

````sql- Otwiera przeglądarkę na http://localhost:3000

CREATE DATABASE bet_assistant;

```### Metoda 2: Ręcznie



### 4. Wykonaj migracje```bash

npm run server

```bash```

npx prisma migrate dev

```Następnie otwórz: http://localhost:3000



---## 🌐 Funkcje



## ⚙️ Konfiguracja### Interfejs webowy



### Plik `.env`- ✅ Wybór 56 krajów i ich lig

- ✅ Import danych z zakresu dat

Skopiuj `.env.example` do `.env` i uzupełnij:- ✅ Auto-retry po osiągnięciu limitu (300 req/godz)

- ✅ Wznowienie przerwanego importu

```env- ✅ Zatrzymywanie/kończenie importu

# Połączenie z bazą danych- ✅ Podgląd postępu w czasie rzeczywistym

DATABASE_URL="postgresql://user:password@localhost:1906/bet_assistant"

### Importowane statystyki

# Klucz API Football

API_FOOTBALL_KEY="twoj-klucz-api"- Wynik meczu i bramki

```- Strzały (ogółem i celne)

- Rzuty rożne i spalone

**Gdzie znaleźć klucz API?**- Żółte i czerwone kartki

1. Zarejestruj się na https://www.api-football.com/- Posiadanie piłki

2. Przejdź do Dashboard- Faule

3. Skopiuj "API Key"- **xG** (expected goals)

- **Wyniki do przerwy**

---- Kursy bukmacherskie (1X2)



## 🚀 Uruchamianie## 📊 Baza danych



### Opcja 1: Graficzny launcher (Windows)Schemat dostępny w `prisma/schema.prisma`



```bashGłówna tabela: `matches` z 33 kolumnami statystyk.

npm run launcher

```## 🔧 Skrypty migracji



Uruchomi się okno z przyciskami:Jeśli potrzebujesz zaktualizować schemat bazy:

- **Start Server** - uruchamia interfejs webowy

- **Import Data** - konsola importu danych```bash

- **View Data** - podgląd bazy danychnpx ts-node scripts/migrate-db.ts

````

### Opcja 2: Linia komend

## 📝 Licencja

#### Interfejs webowy (zalecane)

Projekt prywatny.

```bash

npm run leagues:web## Struktura projektu

```

````

Otwórz przeglądarkę: http://localhost:3000Bet Asistant/

├── src/

#### Import z konsoli│   ├── db/

│   │   └── index.ts            # Połączenie z bazą danych

```bash│   ├── models/

npm run import│   │   └── match.ts            # Typy i funkcje pomocnicze

```│   └── index.ts                # Główny plik aplikacji

├── tests/

---│   └── test-db.ts              # Testy połączenia i CRUD

├── prisma/

## 🎯 Funkcje│   ├── schema.prisma           # Schemat bazy danych

│   └── prisma.config.ts        # Konfiguracja Prisma

### 1. Zarządzanie ligami├── database/

│   └── create_matches_table.sql # Oryginalny skrypt SQL

**Interfejs webowy:**├── package.json                # Zależności Node.js

- Przeglądaj dostępne ligi według krajów├── tsconfig.json              # Konfiguracja TypeScript

- Włączaj/wyłączaj ligi do importu└── .env                       # Konfiguracja środowiska

- Zapisuj zestawy lig jako presety```

- Wczytuj zapisane presety

## Status

**Dostępne regiony:**

- 🇪🇺 **Europa:** Niemcy, Polska, Anglia, Hiszpania, Włochy, Francja, Holandia, Belgia, Portugalia, Turcja, Grecja, Norwegia, Szwecja, Dania, Austria, Chorwacja, Cypr, Czechy, Słowacja, Serbia, Szwajcaria, Szkocja, Węgry, Ukraina, Rumunia, Słowenia, Finlandia, Bułgaria, Macedonia✅ **Zrobione:**

- 🌎 **Ameryka Południowa:** Brazylia, Argentyna, Urugwaj, Kolumbia, Ekwador, Peru, Boliwia, Paragwaj

- 🌎 **Ameryka Północna:** USA, Meksyk, Jamajka, Dominikana- Migracja z Python na Node.js + TypeScript

- 🌏 **Azja:** Korea Południowa, Katar, Kazachstan, Azerbejdżan, Indonezja, Tajlandia, Wietnam, Singapur- Konfiguracja Prisma ORM z introspekcją istniejącej tabeli

- 🌍 **Afryka:** Egipt, Maroko, Nigeria, Mozambik, Burkina Faso, Tunezja- Testy połączenia z bazą danych i operacji CRUD

- Modele TypeScript z type safety

**🏆 UEFA Competitions:**

- Liga Mistrzów🔄 **Następne kroki:**

- Liga Europy

- Liga Konferencji- Implementacja scrapera dla flashscore.pl

- System filtrowania danych

### 2. Import danych- Interfejs użytkownika


**Co importujemy:**
- ✅ Wyniki meczów (bramki, półczas)
- ✅ Statystyki (strzały, rzuty rożne, posiadanie piłki, faule, kartki)
- ✅ xG (Expected Goals) - dla topowych lig
- ✅ Kursy bukmacherskie (1X2)
- ✅ Status zakończenia meczu

**Inteligentny import (optymalizacja tokenów):**
- ✅ Sprawdza, czy mecz już istnieje w bazie
- ✅ Pomija zakończone mecze (0 tokenów API)
- ✅ Aktualizuje tylko kursy dla niezakończonych meczów (1 token)
- ✅ Pobiera pełne dane dla nowych meczów (2 tokeny)

**Oszczędność: 75-100% tokenów przy ponownym imporcie!**

**Zakres dat:**
- Wybierz zakres dat do importu (Od - Do)
- 💡 Wskazówka: Import meczów przed ich rozpoczęciem daje dostęp do kursów

### 3. Presety lig

Oszczędzaj czas - zapisuj ulubione zestawy lig:

**Przykładowe presety:**
- **TOP5** - Premier League, La Liga, Bundesliga, Serie A, Ligue 1
- **Polska** - Ekstraklasa, I Liga
- **Niemcy** - Bundesliga, 2. Bundesliga, DFB Pokal
- **UEFA** - Liga Mistrzów, Liga Europy, Liga Konferencji

**Jak używać:**
1. Wybierz ligi, które Cię interesują
2. Kliknij "Save Preset"
3. Nadaj nazwę (np. "Moje Ligi")
4. W przyszłości: kliknij przycisk z nazwą presetu - ligi załadują się automatycznie

### 4. Monitorowanie limitów API

**Interfejs pokazuje na żywo:**
- **Dzienne limity:** X/7500 requestów
- **Godzinowe limity:** X/300 requestów
- **Czas do resetu:** countdown z minutami/godzinami

**Kolory ostrzeżeń:**
- 🟢 **Biały:** >100 requestów pozostało
- 🟡 **Żółty:** <100 requestów pozostało (uwaga!)
- 🔴 **Czerwony:** <50 requestów pozostało (ostrożnie!)

Odświeżanie automatyczne co 30 sekund.

### 5. Auto-retry przy limicie

Gdy osiągniesz limit godzinowy:
- ⏸️ System automatycznie zatrzymuje import
- ⏰ Czeka 1 godzinę
- ▶️ Wznawia import automatycznie
- 📝 Logi pokazują postęp oczekiwania

Możesz ręcznie przerwać import przyciskiem **"Stop Import"**.

---

## 📊 Limity API

### API-Football (plan darmowy)

| Limit | Wartość |
|-------|---------|
| Requesty na minutę | 30 |
| Requesty na godzinę | 300 |
| Requesty dziennie (TOTAL) | 7500 |

### Koszty tokenów w naszym systemie

| Akcja | Koszt |
|-------|-------|
| Pobranie listy lig dla kraju | 1 token |
| Pobranie listy meczów dla ligi+daty | 1 token |
| Pobranie statystyk meczu | 1 token |
| Pobranie kursów meczu | 1 token |
| **Import nowego meczu (full)** | **2 tokeny** |
| **Aktualizacja kursów (tylko odds)** | **1 token** |
| **Pominięcie zakończonego** | **0 tokenów** ✨ |

### Optymalizacja kosztów - przykład

**Scenariusz: Import 100 meczów**

❌ **Bez optymalizacji (tradycyjne podejście):**
- Pierwsze uruchomienie: 100 meczów × 2 tokeny = **200 tokenów**
- Drugie uruchomienie: 100 meczów × 2 tokeny = **200 tokenów**
- Trzecie uruchomienie: 100 meczów × 2 tokeny = **200 tokenów**
- **SUMA: 600 tokenów**

✅ **Z naszą optymalizacją:**
- Pierwsze uruchomienie: 100 × 2 = **200 tokenów**
- Drugie uruchomienie (po zakończeniu meczów): **0 tokenów!** 🎉
- Trzecie uruchomienie (aktualizacja kursów, 50 niezakończonych): 50 × 1 = **50 tokenów**
- **SUMA: 250 tokenów**

**Oszczędność: 58%** (350 tokenów zaoszczędzonych)

---

## ❓ FAQ

### Dlaczego brak xG dla niektórych lig?

xG (Expected Goals) jest dostępne tylko dla topowych lig europejskich:
- 🏴󠁧󠁢󠁥󠁮󠁧󠁿 Premier League
- 🇪🇸 La Liga
- 🇩🇪 Bundesliga
- 🇮🇹 Serie A
- 🇫🇷 Ligue 1

Dla innych lig API-Football nie dostarcza xG. To **ograniczenie dostawcy danych**, nie błąd systemu.

### Dlaczego nie ma kursów dla starych meczów?

Kursy bukmacherskie są dostępne tylko:
- **Przed meczem** (pre-match odds)
- **W trakcie meczu** (live odds)

Po zakończeniu meczu kursy **znikają z API** - to polityka API-Football.

💡 **Rozwiązanie:** Importuj mecze **przed ich rozpoczęciem**, aby zachować kursy w bazie.

### Jak często powinienem importować dane?

**Zalecane harmonogramy:**

📅 **Codziennie rano:**
- Import przyszłych meczów (zbieranie kursów pre-match)
- Aktualizacja wyników zakończonych meczów

📅 **Po weekendzie:**
- Pełna aktualizacja wyników
- Sprawdzenie, czy wszystkie statystyki się pobrały

📅 **Przed analizą:**
- Szybka aktualizacja najnowszych danych

### Co się stanie, gdy przekroczę limit API?

System automatycznie:
1. ✅ Wykryje błąd `Rate limit exceeded`
2. ⏸️ Zatrzyma import gracefully
3. ⏰ Poczeka **1 godzinę** (dla limitu godzinowego) lub do **północy** (dla limitu dziennego)
4. ▶️ Wznowi import od miejsca przerwania

Możesz też **ręcznie przerwać** import przyciskiem "Stop Import" w interfejsie.

### Jak sprawdzić, ile tokenów zostało?

Otwórz interfejs webowy: **http://localhost:3000**

Na górze strony widoczne są 3 liczniki:
- 🟢 **Daily Limit:** X/7500 (pozostało na dziś)
- 🟢 **Hourly Limit:** X/300 (pozostało w tej godzinie)
- ⏱️ **Reset in:** czas do odświeżenia limitu

Odświeżanie automatyczne co 30 sekund.

### Czy mogę importować równolegle (wiele instancji)?

**❌ NIE.** System jest zaprojektowany do **sekwencyjnego** importu, aby:
- Uniknąć przekroczenia limitów API
- Poprawnie śledzić zużycie tokenów
- Zachować spójność danych w bazie

Uruchamiaj tylko **jedną instancję** importu naraz.

### Jak usunąć stare dane?

**Opcja 1: SQL (DBeaver, pgAdmin)**

```sql
-- Usuń mecze starsze niż 30 dni
DELETE FROM matches WHERE match_date < CURRENT_DATE - INTERVAL '30 days';

-- Usuń mecze z konkretnej ligi
DELETE FROM matches WHERE league = 'Liga nazwa';

-- Usuń wszystkie dane (UWAGA!)
TRUNCATE TABLE matches;
````

**Opcja 2: Prisma Studio**

```bash
npx prisma studio
```

Otwiera graficzny interfejs do zarządzania danymi.

### Gdzie są zapisane dane?

📁 **Struktura plików:**

```
Bet Asistant/
├── data/
│   ├── leagues.json          # Konfiguracja lig (enabled/disabled)
│   ├── rate-limit.json       # Tracking limitów API
│   └── presets/              # Zapisane presety lig
│       ├── TOP5.json
│       ├── Polska.json
│       └── ...
├── prisma/
│   └── migrations/           # Historia zmian w schemacie DB
└── .env                      # Konfiguracja (DATABASE_URL, API_KEY)
```

**Baza danych:** PostgreSQL (adres w `DATABASE_URL`)

---

## 🐛 Rozwiązywanie problemów

### Błąd połączenia z bazą danych

```
Error: connect ECONNREFUSED localhost:5432
```

**Rozwiązanie:**

1. ✅ Sprawdź, czy PostgreSQL **działa** (uruchom usługę)
2. ✅ Zweryfikuj `DATABASE_URL` w `.env` (user, password, port, database)
3. ✅ Upewnij się, że port jest poprawny (domyślnie **5432** lub **1906**)
4. ✅ Testuj połączenie: `npx prisma db pull`

### Błąd "API key invalid"

```
Error: Invalid API key
```

**Rozwiązanie:**

1. ✅ Sprawdź `API_FOOTBALL_KEY` w `.env`
2. ✅ Zweryfikuj klucz na https://www.api-football.com/ → Dashboard → API Key
3. ✅ Upewnij się, że **nie ma spacji** przed/po kluczu
4. ✅ Sprawdź, czy klucz nie wygasł (plany mają limity czasowe)

### Błąd "Rate limit exceeded"

```
Error: Rate limit exceeded. Daily: 900/7500, Hourly: 300/300
```

**Rozwiązanie:**

- ⏰ Poczekaj **1 godzinę** (limit godzinowy)
- ⏰ Lub do **północy** (limit dzienny - reset o 00:00 UTC)
- ✅ System **automatycznie wznowi** import po resecie

### Import się zawiesza

**Symptomy:** Import nie reaguje, brak postępu

**Rozwiązanie:**

1. 📋 Sprawdź **logi w terminalu** (czy są błędy?)
2. ⏸️ Użyj przycisku **"Stop Import"** w interfejsie
3. 🔄 Zrestartuj serwer:
   - Naciśnij **Ctrl+C** w terminalu
   - Uruchom ponownie: `npm run leagues:web`
4. 🗄️ Sprawdź połączenie z bazą danych

### Liczniki tokenów nie działają (404)

```
GET http://localhost:3000/api/rate-limit 404 (Not Found)
```

**Rozwiązanie:**

- ✅ **Zrestartuj serwer** - w nowej wersji naprawiono kolejność middleware
- ✅ Upewnij się, że używasz **najnowszej wersji** kodu
- ✅ Sprawdź, czy endpoint `/api/rate-limit` istnieje w `server/league-config-server.ts`

---

## 📜 Specyfikacja techniczna

### Architektura systemu

```
┌─────────────────────────────────────────────┐
│           Frontend (public/index.html)       │
│  - Interfejs webowy (HTML/CSS/JS)           │
│  - Zarządzanie ligami i presetami           │
│  - Monitorowanie limitów API (realtime)     │
└─────────────────┬───────────────────────────┘
                  │ HTTP/REST
┌─────────────────▼───────────────────────────┐
│     Backend (server/league-config-server)    │
│  - Express.js API server                     │
│  - Endpoints: /api/leagues, /api/import, etc │
│  - Middleware: JSON, static files            │
└─────────────────┬───────────────────────────┘
                  │
    ┌─────────────┼─────────────┐
    │             │             │
┌───▼────┐  ┌─────▼────┐  ┌────▼─────┐
│ Import │  │   API    │  │ Presets  │
│ Logic  │  │ Football │  │ Manager  │
│        │  │  Client  │  │          │
└───┬────┘  └─────┬────┘  └────┬─────┘
    │             │             │
    └─────────────┼─────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│         PostgreSQL Database                  │
│  - Table: matches (wyniki, statystyki, xG)  │
│  - Indexes: fixture_id (unique)             │
└─────────────────────────────────────────────┘
```

### Technologie

| Warstwa        | Technologia  | Wersja |
| -------------- | ------------ | ------ |
| **Runtime**    | Node.js      | 18+    |
| **Language**   | TypeScript   | 5.x    |
| **Database**   | PostgreSQL   | 14+    |
| **ORM**        | Prisma       | 5.x    |
| **Backend**    | Express.js   | 4.x    |
| **Frontend**   | Vanilla JS   | ES6+   |
| **API Source** | API-Football | v3     |

### Struktura projektu

```
Bet Asistant/
├── src/                           # Kod źródłowy TypeScript
│   ├── services/
│   │   ├── api-football-client.ts # Klient API-Football (HTTP, rate limit)
│   │   ├── data-importer.ts       # Logika importu z optymalizacją
│   │   └── league-selector.ts     # Zarządzanie włączonymi ligami
│   ├── types/
│   │   └── api-football.ts        # Typy odpowiedzi API
│   └── utils/
│       ├── import-control.ts      # Stop/resume importu
│       ├── import-state.ts        # Stan importu (progress)
│       └── league-presets.ts      # Zarządzanie presetami
│
├── server/                        # Backend (Express)
│   └── league-config-server.ts    # Główny serwer HTTP
│
├── public/                        # Frontend (static files)
│   ├── index.html                 # SPA - interfejs webowy
│   └── styles.css                 # Stylowanie
│
├── prisma/
│   ├── schema.prisma              # Definicja modelu DB
│   └── migrations/                # Historia migracji
│
├── launcher/                      # GUI launcher (Windows)
│   ├── bet-assistant.exe          # Kompilowany launcher
│   └── index.html                 # Frontend launchera
│
├── archive/                       # Archiwalne skrypty
│   ├── add-fixture-id.ts          # Template: dodawanie kolumny
│   ├── add-is-finished.ts         # Template: migracja z defaultem
│   └── add-uefa-competitions.ts   # Template: wstawianie rekordów
│
├── data/                          # Dane runtime
│   ├── leagues.json               # Stan lig (enabled/disabled)
│   ├── rate-limit.json            # Tracking limitów
│   └── presets/                   # Zapisane presety użytkownika
│
├── .env                           # Konfiguracja (DATABASE_URL, API_KEY)
├── package.json                   # Zależności NPM
├── tsconfig.json                  # Konfiguracja TypeScript
└── README.md                      # Dokumentacja (ten plik)
```

### Schemat bazy danych

**Tabela: `matches`**

```prisma
model matches {
  id                       Int                  @id @default(autoincrement())
  fixture_id               Int?                 @unique // API Football fixture ID (deduplikacja)
  match_date               DateTime             @db.Timestamp(6)
  country                  String               @db.VarChar(100)
  league                   String               @db.VarChar(200)
  home_team                String               @db.VarChar(200)
  away_team                String               @db.VarChar(200)
  result                   match_result_enum?   // home_win, away_win, draw
  home_goals               Int?
  away_goals               Int?
  home_goals_ht            Int?
  away_goals_ht            Int?
  result_ht                match_result_enum?
  home_xg                  Decimal?             @db.Decimal(4, 2)  // Expected Goals
  away_xg                  Decimal?             @db.Decimal(4, 2)
  home_shots               Int?
  home_shots_on_target     Int?
  away_shots               Int?
  away_shots_on_target     Int?
  home_corners             Int?
  away_corners             Int?
  home_offsides            Int?
  away_offsides            Int?
  home_y_cards             Int?                 @default(0)
  away_y_cards             Int?                 @default(0)
  home_r_cards             Int?                 @default(0)
  away_r_cards             Int?                 @default(0)
  home_possession          Int?
  away_possession          Int?
  home_fouls               Int?
  away_fouls               Int?
  home_odds                Decimal?             @db.Decimal(6, 2)  // Kursy bukmacherskie
  draw_odds                Decimal?             @db.Decimal(6, 2)
  away_odds                Decimal?             @db.Decimal(6, 2)
  is_finished              String?              @default("yes") @db.VarChar(3)  // yes/no
  created_at               DateTime?            @default(now()) @db.Timestamp(6)

  @@index([fixture_id])
  @@index([match_date])
  @@index([league])
}
```

**Enum: `match_result_enum`**

```sql
CREATE TYPE match_result_enum AS ENUM ('home_win', 'away_win', 'draw');
```

### Przepływ danych - import meczu

```typescript
// Pseudokod logiki importu z optymalizacją

async function importSingleMatch(fixture, league) {
	// 1. Sprawdź, czy mecz już istnieje w bazie (0 tokenów)
	const existing = await db.query(
		`
    SELECT is_finished, home_odds, draw_odds, away_odds
    FROM matches
    WHERE fixture_id = $1
  `,
		[fixture.id]
	)

	if (existing) {
		// CASE 1: Mecz zakończony → SKIP (0 tokenów) ✨
		if (existing.is_finished === 'yes') {
			console.log('⏭️ Skipping finished match')
			return { tokens: 0 }
		}

		// CASE 2: Mecz niezakończony → aktualizuj tylko kursy (1 token)
		const odds = await apiClient.getFixtureOdds(fixture.id) // 1 token
		await db.update({ home_odds, draw_odds, away_odds })
		console.log('🔄 Updated odds only')
		return { tokens: 1 }
	}

	// CASE 3 & 4: Nowy mecz → pobierz pełne dane (2 tokeny)
	const [statistics, odds] = await Promise.all([
		apiClient.getFixtureStatistics(fixture.id), // 1 token
		apiClient.getFixtureOdds(fixture.id), // 1 token
	])

	await db.insert({ ...fixture, ...statistics, ...odds })
	console.log('✅ Imported new match')
	return { tokens: 2 }
}
```

### API Endpoints

**Backend:** `server/league-config-server.ts`

| Method | Endpoint                          | Opis                                            |
| ------ | --------------------------------- | ----------------------------------------------- |
| GET    | `/api/countries`                  | Lista wszystkich krajów z ligami                |
| GET    | `/api/countries/:country/leagues` | Ligi dla danego kraju (season=2025)             |
| GET    | `/api/leagues/summary`            | Podsumowanie (liczba lig, enabled)              |
| GET    | `/api/rate-limit`                 | Aktualne limity API (dzienne, godzinowe, reset) |
| POST   | `/api/leagues/toggle`             | Włącz/wyłącz ligę (body: {id, enabled})         |
| POST   | `/api/import`                     | Rozpocznij import (body: {fromDate, toDate})    |
| POST   | `/api/import/stop`                | Zatrzymaj trwający import                       |
| GET    | `/api/presets`                    | Lista wszystkich presetów                       |
| POST   | `/api/presets/:name/save`         | Zapisz preset (body: leagues[])                 |
| POST   | `/api/presets/:name/load`         | Załaduj preset (ustawia enabled)                |
| DELETE | `/api/presets/:name`              | Usuń preset                                     |

### Optymalizacja API Tokens

**Kluczowe mechanizmy:**

1. **Database-First Approach**

   ```typescript
   // Zawsze sprawdź bazę PRZED wywołaniem API
   const existing = await checkDatabase(fixture_id)
   if (existing && existing.is_finished === 'yes') {
   	return // 0 tokenów zaoszczędzonych!
   }
   ```

2. **Conditional Fetching**

   ```typescript
   // Pobieraj tylko to, czego potrzebujesz
   if (existing && existing.is_finished === 'no') {
     // Tylko kursy (1 token zamiast 2)
     const odds = await apiClient.getFixtureOdds(fixture_id)
   } else {
     // Pełne dane (2 tokeny)
     const [stats, odds] = await Promise.all([...])
   }
   ```

3. **Rate Limit Tracking**

   ```typescript
   // Tracking w data/rate-limit.json
   {
     "hourly": { "count": 150, "resetAt": "2025-11-10T15:00:00Z" },
     "daily": { "count": 1200, "resetAt": "2025-11-11T00:00:00Z" }
   }
   ```

4. **Auto-Retry przy limicie**
   ```typescript
   try {
   	await apiClient.makeRequest(url)
   } catch (error) {
   	if (error.message.includes('Rate limit')) {
   		console.log('⏸️ Rate limit reached, waiting 1 hour...')
   		await sleep(3600000) // 1 godzina
   		console.log('▶️ Resuming import...')
   		retry()
   	}
   }
   ```

### Rate Limiting

**Implementacja:** `src/services/api-football-client.ts`

```typescript
class ApiFootballClient {
	private rateLimitFile = 'data/rate-limit.json'

	private async checkRateLimit() {
		const stats = this.loadRateLimitStats()

		// Reset godzinowy (każda pełna godzina)
		if (new Date() >= new Date(stats.hourly.resetAt)) {
			stats.hourly.count = 0
			stats.hourly.resetAt = nextHour()
		}

		// Reset dzienny (o północy UTC)
		if (new Date() >= new Date(stats.daily.resetAt)) {
			stats.daily.count = 0
			stats.daily.resetAt = nextMidnight()
		}

		// Sprawdź limity
		if (stats.hourly.count >= 300) {
			throw new Error('Rate limit exceeded: hourly')
		}
		if (stats.daily.count >= 7500) {
			throw new Error('Rate limit exceeded: daily')
		}

		// Inkrementuj liczniki
		stats.hourly.count++
		stats.daily.count++
		this.saveRateLimitStats(stats)
	}

	async makeRequest(url: string) {
		await this.checkRateLimit()
		const response = await fetch(url, {
			headers: { 'x-apisports-key': this.apiKey },
		})
		return response.json()
	}
}
```

### Deduplikacja meczów

**Problem:** Ten sam mecz może być importowany wielokrotnie (różne wywołania, różne daty).

**Rozwiązanie:** Unikalna kolumna `fixture_id`

```sql
-- Definicja
fixture_id INTEGER UNIQUE

-- Index dla szybkiego wyszukiwania
CREATE INDEX idx_fixture_id ON matches(fixture_id);

-- Przy insercie - automatyczne wykrywanie duplikatów
INSERT INTO matches (..., fixture_id, ...)
VALUES (..., 12345, ...)
ON CONFLICT (fixture_id) DO NOTHING;  -- lub UPDATE
```

**W kodzie:**

```typescript
// Przed importem - sprawdź po fixture_id
const existing = await prisma.matches.findUnique({
	where: { fixture_id: fixture.id },
})

if (existing) {
	// Decyzja: update czy skip
}
```

### Null vs 0 - semantyka danych

**Konwencja:**

- **`null`** = dane niedostępne z API

  - xG dla niższych lig
  - Kursy dla zakończonych meczów
  - Statystyki, których API nie zwrócił

- **`0`** = rzeczywista wartość zero
  - 0 żółtych kartek (mecz bez kartek)
  - 0 czerwonych kartek

**Implementacja:**

```typescript
function getStatValue(stats: any, key: string, defaultValue = null) {
  const value = stats[key]
  return value !== undefined && value !== null ? value : defaultValue
}

// Użycie
home_shots: getStatValue(homeStats, 'Total Shots'),        // null jeśli brak
home_y_cards: getStatValue(homeStats, 'Yellow Cards', 0),  // 0 jeśli brak
```

### Enum Casting w PostgreSQL

**Problem:** Prisma generuje queries z parametrami, PostgreSQL wymaga explicit cast dla enumów.

**Rozwiązanie:** `::match_result_enum`

```typescript
// ❌ BEZ CASTING (błąd)
await prisma.$executeRaw`
  INSERT INTO matches (..., result, ...)
  VALUES (..., $7, ...)  -- PostgreSQL nie wie, że to enum
`

// ✅ Z CASTING (działa)
await prisma.$executeRaw`
  INSERT INTO matches (..., result, ...)
  VALUES (..., $7::match_result_enum, ...)  -- Explicit cast
`
```

### Middleware Order w Express

**WAŻNE:** Kolejność ma znaczenie!

```typescript
// ❌ ŹLE - static files przechwytują API routes
app.use(express.static('public'))  // Catch-all dla wszystkich ścieżek
app.get('/api/rate-limit', ...)    // Nigdy nie osiągnięty (404)

// ✅ DOBRZE - API routes PRZED static files
app.get('/api/rate-limit', ...)    // Obsłuży żądanie
app.use(express.static('public'))  // Fallback dla HTML/CSS/JS
```

### Presety - format JSON

**Plik:** `data/presets/{name}.json`

```json
{
	"name": "TOP5",
	"leagues": [
		{ "id": 39, "name": "Premier League", "country": "England" },
		{ "id": 140, "name": "La Liga", "country": "Spain" },
		{ "id": 78, "name": "Bundesliga", "country": "Germany" },
		{ "id": 135, "name": "Serie A", "country": "Italy" },
		{ "id": 61, "name": "Ligue 1", "country": "France" }
	],
	"createdAt": "2025-11-10T12:00:00Z"
}
```

**Operacje:**

- **Save:** `POST /api/presets/:name/save` + body z leagues[]
- **Load:** `POST /api/presets/:name/load` → ustawia `enabled: true` dla lig z presetu
- **List:** `GET /api/presets` → zwraca listę nazw
- **Delete:** `DELETE /api/presets/:name`

---

## 📝 Changelog

### v1.0.0 (2025-11-10)

**🎉 Funkcje:**

- ✅ Interfejs webowy do zarządzania ligami
- ✅ Inteligentny import z optymalizacją tokenów (75-100% oszczędności)
- ✅ System presetów dla szybkiego wyboru lig
- ✅ Monitorowanie limitów API w czasie rzeczywistym (auto-refresh 30s)
- ✅ Auto-retry przy przekroczeniu limitu (czeka 1h, wznawia)
- ✅ Obsługa UEFA Competitions (Champions, Europa, Conference)
- ✅ Deduplikacja meczów po `fixture_id`
- ✅ Status zakończenia meczu (`is_finished: yes/no`)
- ✅ Graficzny launcher dla Windows

**⚡ Optymalizacje:**

- ✅ Database-first: sprawdzanie przed API call
- ✅ Pomijanie zakończonych meczów (0 tokenów)
- ✅ Aktualizacja tylko kursów dla niezakończonych (1 token)
- ✅ Parallel fetch dla statistics + odds

**🐛 Naprawy:**

- ✅ Enum casting w PostgreSQL (`::match_result_enum`)
- ✅ Preset save/load (global leagues array scope fix)
- ✅ Middleware order (API routes przed static files)
- ✅ Rate limit error handling (bez crash)
- ✅ Null vs 0 semantyka dla statystyk

**📦 Architektura:**

- TypeScript 5.x + Node.js 18+
- Express.js backend
- Vanilla JS frontend (no framework)
- PostgreSQL + Prisma ORM
- API-Football v3

---

## 🤝 Wsparcie

W razie problemów:

1. 📖 Sprawdź [FAQ](#-faq)
2. 🐛 Zobacz [Rozwiązywanie problemów](#-rozwiązywanie-problemów)
3. 📜 Przeczytaj [Specyfikację techniczną](#-specyfikacja-techniczna)
4. 📝 Sprawdź logi w terminalu

---

**Wersja:** 1.0.0  
**Data ostatniej aktualizacji:** 10 listopada 2025  
**Licencja:** MIT  
**Autor:** Bet Assistant Team
