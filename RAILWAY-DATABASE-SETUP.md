# 🗄️ Jak zastosować migracje Prisma w Railway

## 📋 Problem

Railway utworzył pustą bazę PostgreSQL. Musisz zaaplikować migracje Prisma aby utworzyć tabele.

---

## ✅ ROZWIĄZANIE 1: Automatyczne (przez Railway deployment)

Railway **automatycznie** uruchomi migracje przy pierwszym deployment, ponieważ skrypt `railway:server` zawiera:

```json
"railway:server": "prisma generate && prisma migrate deploy && ts-node server/league-config-server.ts"
```

### Kroki:

1. ✅ **Push kod do GitHub** (już zrobione)
2. ✅ **Railway automatycznie wykryje zmiany**
3. ✅ **Railway uruchomi:**

   - `npm install`
   - `prisma generate` (wygeneruje Prisma Client)
   - `prisma migrate deploy` ← **To zastosuje migracje!**
   - `ts-node server/league-config-server.ts` (start serwera)

4. **Sprawdź logi Railway:**
   - Railway → Web Service → Deployments → Najnowszy → View Logs
   - Szukaj linii:
     ```
     Applying migration `20251111000000_initial_schema`
     Database schema updated!
     ```

### ✅ Jeśli widzisz "Database schema updated!" - **GOTOWE!** 🎉

---

## ✅ ROZWIĄZANIE 2: Manualnie (z lokalnego komputera)

Jeśli automatyczne nie zadziałało lub chcesz ręcznie:

### Krok 1: Pobierz DATABASE_URL z Railway

1. Railway → PostgreSQL Service → Variables
2. Skopiuj wartość `DATABASE_URL`
   ```
   postgresql://postgres:PASSWORD@HOST:PORT/railway
   ```

### Krok 2: Zastosuj migracje lokalnie

W PowerShell:

```powershell
# Ustaw DATABASE_URL na Railway PostgreSQL
$env:DATABASE_URL="postgresql://postgres:PASSWORD@HOST:PORT/railway"

# Wygeneruj Prisma Client
npm run db:generate

# Zastosuj wszystkie migracje
npx prisma migrate deploy

# Zweryfikuj że tabele zostały utworzone
npx prisma db pull
```

**Oczekiwany output:**

```
Applying migration `20251111000000_initial_schema`
The following migration(s) have been applied:

migrations/
  └─ 20251111000000_initial_schema/
    └─ migration.sql

Your database is now in sync with your schema.
```

### Krok 3: Zweryfikuj w Railway

1. Railway → PostgreSQL → Database → Data
2. Powinieneś zobaczyć tabele:
   - ✅ `matches`
   - ✅ `import_jobs`
   - ✅ `_prisma_migrations` (Prisma tracking table)

---

## ✅ ROZWIĄZANIE 3: Przez Railway CLI (dla zaawansowanych)

### Krok 1: Zainstaluj Railway CLI

```powershell
# Windows (Scoop)
scoop install railway

# Lub pobierz z: https://github.com/railwayapp/cli/releases
```

### Krok 2: Zaloguj się

```powershell
railway login
```

### Krok 3: Połącz z projektem

```powershell
railway link
# Wybierz swój projekt: bet-assisstant
```

### Krok 4: Uruchom migracje

```powershell
railway run npx prisma migrate deploy
```

---

## 🔍 Weryfikacja po zastosowaniu migracji

### Sprawdź logi Web Service:

```
Railway → Web Service → Deployments → View Logs
```

Szukaj:

```
✅ Applying migration `20251111000000_initial_schema`
✅ Database schema updated!
🌐 League Configuration Web Interface
   Server running on port: XXXX
```

### Test w przeglądarce:

1. Otwórz URL aplikacji
2. Przejdź do **"Zarządzanie importami"**
3. Kliknij **"+ Nowe zadanie importu"**
4. Jeśli formularz się wyświetla bez błędów → **Tabele działają!** ✅

### Sprawdź bazę danych bezpośrednio:

**Opcja A: Railway Dashboard**

```
Railway → PostgreSQL → Database → Data
```

Powinieneś zobaczyć:

- `matches` (0 rows)
- `import_jobs` (0 rows)
- `_prisma_migrations` (1 row)

**Opcja B: Prisma Studio (lokalnie)**

```powershell
$env:DATABASE_URL="postgresql://postgres:PASSWORD@HOST:PORT/railway"
npm run db:studio
```

Otwiera GUI w przeglądarce na `http://localhost:5555`

---

## 🐛 Troubleshooting

### Problem: "No pending migrations to apply"

**Przyczyna:** Migracje już zostały zastosowane  
**Rozwiązanie:** Sprawdź czy tabele istnieją w bazie (Railway → PostgreSQL → Data)

### Problem: "Can't reach database server"

**Przyczyna:** Błędny DATABASE_URL  
**Rozwiązanie:**

1. Zweryfikuj DATABASE_URL w Railway Variables
2. Upewnij się że PostgreSQL Service jest uruchomiony (🟢 Active)
3. Sprawdź firewall/VPN

### Problem: "Environment variable not found: DATABASE_URL"

**Przyczyna:** Zmienna nie jest ustawiona  
**Rozwiązanie:**

- Railway: Sprawdź Variables w PostgreSQL Service
- Lokalnie: Ustaw `$env:DATABASE_URL="..."`

### Problem: "P3009: migrate found failed migration"

**Przyczyna:** Poprzednia migracja się nie powiodła  
**Rozwiązanie:**

```powershell
# Oznacz migrację jako wykonaną (jeśli tabele już istnieją)
npx prisma migrate resolve --applied 20251111000000_initial_schema

# LUB zresetuj całą bazę (USUWA WSZYSTKIE DANE!)
npx prisma migrate reset
```

### Problem: Tabele istnieją ale mają inną strukturę

**Przyczyna:** Ręcznie utworzone tabele nie pasują do schema  
**Rozwiązanie:**

```powershell
# Opcja 1: Aktualizuj schema.prisma na podstawie istniejącej bazy
npx prisma db pull

# Opcja 2: Usuń wszystko i zastosuj migracje od nowa
# UWAGA: Usuwa wszystkie dane!
npx prisma migrate reset
```

---

## 📊 Po zastosowaniu migracji

### Struktura bazy danych:

```sql
-- Tabele
matches (39 kolumn)
  ├─ id (PRIMARY KEY)
  ├─ fixture_id (UNIQUE)
  ├─ match_date, country, league
  ├─ home_team, away_team
  ├─ goals, shots, corners, offsides
  ├─ xG, possession, odds
  └─ timestamps

import_jobs (17 kolumn)
  ├─ id (PRIMARY KEY)
  ├─ leagues (JSONB)
  ├─ date_from, date_to
  ├─ status (ENUM)
  ├─ progress (JSONB)
  ├─ counters (imported, failed, etc.)
  ├─ rate_limit info
  ├─ hidden (BOOLEAN)
  └─ timestamps

-- Enums
match_result_enum: h-win | draw | a-win
job_status_enum: pending | running | paused | completed | failed | rate_limited

-- Indeksy (dla wydajności)
matches:
  - fixture_id (UNIQUE)
  - country + league
  - match_date
  - home_team + away_team
  - created_at

import_jobs:
  - status
  - created_at (DESC)
  - hidden
```

---

## ✅ Podsumowanie

**Najbardziej prawdopodobne:**
Railway **automatycznie zastosuje migracje** przy pierwszym deployment dzięki skryptowi `railway:server`.

**Sprawdź logi Railway:**

```
Web Service → Deployments → View Logs → Szukaj "Applying migration"
```

**Jeśli nie działa:**
Użyj Rozwiązania 2 (manualnie z lokalnego komputera) lub 3 (Railway CLI).

**Po zastosowaniu:**
Aplikacja będzie mogła zapisywać mecze i zadania importu! 🚀

---

**Pytania?** Sprawdź logi Railway lub otwórz issue na GitHub.
