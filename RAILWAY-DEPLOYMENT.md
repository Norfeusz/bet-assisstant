# 🚂 Railway Deployment Guide - Bet Assistant

Kompletny przewodnik wdrożenia aplikacji Bet Assistant na platformie Railway.

## 📋 Spis treści
1. [Wymagania wstępne](#wymagania-wstępne)
2. [Przygotowanie projektu](#przygotowanie-projektu)
3. [Konfiguracja Railway](#konfiguracja-railway)
4. [Deployment](#deployment)
5. [Weryfikacja i monitorowanie](#weryfikacja-i-monitorowanie)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 Wymagania wstępne

### 1. Konto GitHub
- Projekt musi być w repozytorium GitHub
- Railway będzie automatycznie deployować z GitHub przy każdym push

### 2. Konto Railway
- Zarejestruj się na: https://railway.app
- Połącz z kontem GitHub
- **Darmowy tier: $5 miesięcznie w kredytach** (wystarczy dla tego projektu!)

### 3. API Football Key
- Zarejestruj się na: https://dashboard.api-football.com/register
- Pobierz swój API key (plan FREE: 100 requests/day)
- Zapisz klucz - będzie potrzebny w konfiguracji

---

## 📦 Przygotowanie projektu

### Krok 1: Zacommituj wszystkie zmiany

```powershell
git add .
git commit -m "feat: Add Railway deployment configuration"
git push origin main
```

### Krok 2: Sprawdź utworzone pliki

Upewnij się, że masz wszystkie potrzebne pliki:

✅ `railway.json` - Konfiguracja Railway  
✅ `Procfile` - Definicja procesów (web + worker)  
✅ `.env.railway.example` - Przykład zmiennych środowiskowych  
✅ `package.json` - Zawiera skrypty `railway:server` i `railway:worker`

---

## ⚙️ Konfiguracja Railway

### Krok 1: Utwórz nowy projekt

1. Zaloguj się do Railway: https://railway.app
2. Kliknij **"New Project"**
3. Wybierz **"Deploy from GitHub repo"**
4. Wybierz repozytorium **`bet-assisstant`**
5. Railway automatycznie wykryje projekt Node.js

### Krok 2: Dodaj PostgreSQL Database

1. W projekcie kliknij **"+ New"**
2. Wybierz **"Database"** → **"Add PostgreSQL"**
3. Railway automatycznie:
   - Utworzy bazę danych
   - Ustawi zmienną `DATABASE_URL`
   - Połączy ją z aplikacją

**✅ DATABASE_URL jest już gotowe - nic nie musisz konfigurować!**

### Krok 3: Skonfiguruj zmienne środowiskowe

#### 3.1. Przejdź do ustawień serwisu Web

1. Kliknij na swój serwis (główna aplikacja)
2. Przejdź do zakładki **"Variables"**
3. Kliknij **"+ New Variable"**

#### 3.2. Dodaj wymagane zmienne

Skopiuj wszystkie zmienne z pliku `.env.railway.example`:

```bash
# REQUIRED
API_FOOTBALL_KEY=TWÓJ_KLUCZ_API_TUTAJ
API_FOOTBALL_HOST=v3.football.api-sports.io
API_FOOTBALL_BASE_URL=https://v3.football.api-sports.io

# Rate Limits (dostosuj do swojego planu)
RATE_LIMIT_REQUESTS_PER_DAY=100
RATE_LIMIT_REQUESTS_PER_HOUR=10

# Optional
LOG_LEVEL=INFO
LOG_FILE=logs/bet_assistant.log
TZ=Europe/Warsaw
```

**🔥 WAŻNE:** Zamień `TWÓJ_KLUCZ_API_TUTAJ` na swój prawdziwy klucz API!

#### 3.3. Zapisz zmienne

- Railway automatycznie zrestartuje aplikację po zapisaniu zmiennych

---

## 🚀 Deployment

### Krok 1: Skonfiguruj procesy (Web + Worker)

Railway automatycznie wykryje `Procfile` z dwoma procesami:

**Proces 1: Web (Server)**
```
web: npm run railway:server
```
- Port: Railway automatycznie ustawi `PORT` (zazwyczaj 443/80)
- URL: Railway wygeneruje publiczny URL (np. `bet-assistant.up.railway.app`)

**Proces 2: Worker (Background Import)**
```
worker: npm run railway:worker
```
- Działa w tle bez portu
- Automatycznie importuje mecze co 15 minut

### Krok 2: Dodaj Worker jako osobny serwis

Railway domyślnie uruchamia tylko proces `web`. Aby dodać `worker`:

1. W projekcie kliknij **"+ New"** → **"Empty Service"**
2. Nazwij go: **"Worker"**
3. Połącz z tym samym repozytorium GitHub
4. W ustawieniach Worker:
   - **Start Command**: Zmień na `npm run railway:worker`
   - **Variables**: Skopiuj wszystkie zmienne ze serwisu Web (lub użyj shared variables)

**Alternatywa: Użyj tej samej zmiennej DATABASE_URL**
- W Worker → Variables → **"+ Reference Variable"**
- Wybierz `DATABASE_URL` z serwisu PostgreSQL
- Dodaj pozostałe zmienne (API_FOOTBALL_KEY itp.)

### Krok 3: Deployment automatyczny

Railway automatycznie:
1. ✅ Klonuje repozytorium
2. ✅ Instaluje zależności (`npm install`)
3. ✅ Generuje Prisma Client (`prisma generate`)
4. ✅ Uruchamia migracje (`prisma migrate deploy`)
5. ✅ Startuje aplikację
6. ✅ Wdraża przy każdym `git push`

**📦 Build log będzie pokazany w czasie rzeczywistym**

---

## ✅ Weryfikacja i monitorowanie

### 1. Sprawdź statusy serwisów

Po deployment:
- **Web**: Status powinien być **"Active"** z zielonym wskaźnikiem
- **Worker**: Status powinien być **"Active"** (bez publicznego URL)
- **PostgreSQL**: Status powinien być **"Active"**

### 2. Sprawdź logi

#### Logi Web (Server):
```
Kliknij na serwis Web → Zakładka "Deployments" → Najnowszy deployment
```

Oczekiwane logi:
```
✅ Database connected successfully
✅ Prisma Client generated
✅ Migrations applied: 3 migrations
🚀 Server running on port 3000
```

#### Logi Worker:
```
Kliknij na serwis Worker → Zakładka "Deployments" → Najnowszy deployment
```

Oczekiwane logi:
```
✅ Database connected successfully
🔄 Background import worker started
⏰ Checking for import jobs every 60 seconds...
```

### 3. Testuj aplikację

#### 3.1. Otwórz aplikację
```
Kliknij na serwis Web → "View Deployment" lub skopiuj URL
```

Powinieneś zobaczyć:
- ✅ Interfejs główny aplikacji
- ✅ Sekcję konfiguracji lig
- ✅ Statystyki drużyn

#### 3.2. Sprawdź API
```
https://TWÓJ-URL.up.railway.app/api/rate-limit
```

Oczekiwana odpowiedź JSON:
```json
{
  "date": "2025-11-11",
  "dailyRequests": 0,
  "dailyLimit": 100,
  "dailyRemaining": 100,
  "hourlyRequests": 0,
  "hourlyLimit": 10,
  "hourlyRemaining": 10
}
```

#### 3.3. Utwórz zadanie importu

1. W interfejsie przejdź do **"Zarządzanie importami"**
2. Kliknij **"+ Nowe zadanie importu"**
3. Wybierz ligi (np. Premier League, Bundesliga)
4. Ustaw zakres dat (np. ostatnie 30 dni)
5. Kliknij **"Utwórz zadanie"**

Worker automatycznie rozpocznie import w tle!

### 4. Monitoruj użycie zasobów

Railway Dashboard → Projekt → Zakładka **"Metrics"**

Sprawdź:
- **Memory**: Powinno być ~100-200MB dla każdego serwisu
- **CPU**: Powinno być <5% w spoczynku, ~20-40% podczas importu
- **Network**: Zależne od liczby importowanych meczów

### 5. Sprawdź koszty

Railway Dashboard → Projekt → Zakładka **"Usage"**

Oczekiwane zużycie miesięczne:
```
Web:      ~$1.50 (shared-cpu-1x, ~150MB RAM, 24/7)
Worker:   ~$1.50 (shared-cpu-1x, ~150MB RAM, 24/7)
Database: ~$1.00 (shared-cpu-1x, 1GB storage)
────────────────────────────────────────────
RAZEM:    ~$4.00/miesiąc

💰 Darmowy tier: $5/miesiąc
✅ MIESZCZYSZ SIĘ W DARMOWYM LIMICIE!
```

---

## 🔧 Troubleshooting

### Problem 1: Błąd "DATABASE_URL is not set"

**Rozwiązanie:**
1. Sprawdź czy PostgreSQL jest dodany do projektu
2. W serwisie Web/Worker → Variables → Zweryfikuj `DATABASE_URL`
3. Jeśli brak, dodaj Reference Variable do PostgreSQL

### Problem 2: Błąd "API_FOOTBALL_KEY is not set"

**Rozwiązanie:**
1. Przejdź do Variables w serwisie Web i Worker
2. Dodaj zmienną:
   ```
   API_FOOTBALL_KEY=twój_prawdziwy_klucz
   ```
3. Zapisz i poczekaj na automatyczny restart

### Problem 3: Worker się nie uruchamia

**Rozwiązanie:**
1. Sprawdź logi Worker:
   ```
   Worker → Deployments → Najnowszy deployment → View Logs
   ```
2. Upewnij się, że Start Command to:
   ```
   npm run railway:worker
   ```
3. Zweryfikuj że Worker ma wszystkie wymagane zmienne (DATABASE_URL, API_FOOTBALL_KEY)

### Problem 4: "Rate limit exceeded" od razu po starcie

**Rozwiązanie:**
Lokalny licznik `data/rate-limit.json` nie jest przenoszony do Railway.
Railway rozpoczyna z czystym licznikiem (0/100).

Jeśli problem występuje:
1. Sprawdź logi - błąd może pochodzić z API Football (zewnętrzne limity)
2. Zweryfikuj swój plan na API Football Dashboard
3. Dostosuj zmienne:
   ```
   RATE_LIMIT_REQUESTS_PER_DAY=100  # Dostosuj do planu
   RATE_LIMIT_REQUESTS_PER_HOUR=10
   ```

### Problem 5: Migracje nie działają

**Rozwiązanie:**
1. Sprawdź czy `prisma/migrations/` są w repozytorium Git
2. Upewnij się że `railway:server` zawiera:
   ```json
   "railway:server": "prisma generate && prisma migrate deploy && ts-node server/league-config-server.ts"
   ```
3. W logach powinno być:
   ```
   Applying migration `xxx_migration_name`
   ```

### Problem 6: Out of Memory (OOM)

**Objawy:**
- Serwis restartuje się losowo
- Logi: "Process exited with code 137"

**Rozwiązanie:**
1. W Railway → Serwis → Settings → **Increase Memory Limit**
2. Zmień z 512MB na 1GB (nadal w free tier!)
3. Zoptymalizuj kod (mniej równoczesnych requestów do API)

### Problem 7: Deployment failed - "Could not find dependency"

**Rozwiązanie:**
1. Upewnij się, że `package.json` zawiera wszystkie dependencies
2. Zacommituj i push:
   ```powershell
   git add package.json package-lock.json
   git commit -m "fix: Update dependencies"
   git push
   ```
3. Railway automatycznie redeploy

---

## 🎉 Gratulacje!

Twoja aplikacja jest teraz wdrożona na Railway! 🚀

### Co dalej?

1. **Monitoruj logi** - regularnie sprawdzaj czy worker importuje mecze
2. **Sprawdzaj koszty** - upewnij się że mieszczysz się w $5 free tier
3. **Backupy bazy** - Railway robi automatyczne backupy PostgreSQL
4. **Custom Domain** (opcjonalne) - możesz dodać własną domenę w ustawieniach

### Przydatne linki:

- 📊 Railway Dashboard: https://railway.app/dashboard
- 🐘 PostgreSQL: Railway → Twój projekt → Database → Connect
- 📈 Metryki: Railway → Twój projekt → Metrics
- 💬 Railway Discord: https://discord.gg/railway (support społeczności)

---

## 🆘 Potrzebujesz pomocy?

1. **Sprawdź logi** w Railway Dashboard
2. **Przeczytaj dokumentację** Railway: https://docs.railway.app
3. **Otwórz issue** w repozytorium GitHub
4. **Zapytaj na Railway Discord**: https://discord.gg/railway

---

**Autor:** Bet Assistant Team  
**Ostatnia aktualizacja:** 11 listopada 2025  
**Wersja:** 1.0.0
