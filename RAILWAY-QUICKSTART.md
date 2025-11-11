# 🚂 Railway - Szybki Start (5 minut)

## ✅ KROK 1: Przygotuj projekt (1 min)

```powershell
# Push do GitHub (jeśli jeszcze nie zrobione)
git push origin main
```

Potrzebujesz:
- ✅ Konto GitHub z projektem
- ✅ Klucz API Football: https://dashboard.api-football.com/register

---

## ✅ KROK 2: Utwórz projekt Railway (2 min)

1. Wejdź na: **https://railway.app**
2. Kliknij **"New Project"**
3. Wybierz **"Deploy from GitHub repo"**
4. Wybierz repozytorium: **bet-assisstant**

✅ Railway automatycznie zbuduje i wdroży aplikację!

---

## ✅ KROK 3: Dodaj PostgreSQL (30 sek)

1. W projekcie kliknij **"+ New"**
2. Wybierz **"Database"** → **"PostgreSQL"**
3. ✅ Gotowe! DATABASE_URL jest automatycznie ustawione

---

## ✅ KROK 4: Ustaw zmienne środowiskowe (1 min)

1. Kliknij na serwis **Web**
2. Przejdź do zakładki **"Variables"**
3. Dodaj zmienne:

```bash
API_FOOTBALL_KEY=TWÓJ_KLUCZ_API
API_FOOTBALL_HOST=v3.football.api-sports.io
API_FOOTBALL_BASE_URL=https://v3.football.api-sports.io
RATE_LIMIT_REQUESTS_PER_DAY=100
RATE_LIMIT_REQUESTS_PER_HOUR=10
LOG_LEVEL=INFO
TZ=Europe/Warsaw
```

🔴 **WAŻNE:** Zamień `TWÓJ_KLUCZ_API` na prawdziwy klucz!

---

## ✅ KROK 5: Dodaj Worker (1 min)

1. Kliknij **"+ New"** → **"Empty Service"**
2. Nazwij: **"Worker"**
3. Połącz z tym samym repozytorium
4. W **Settings** → **Start Command** wpisz:
   ```
   npm run railway:worker
   ```
5. W **Variables**:
   - Skopiuj wszystkie zmienne z serwisu Web
   - LUB użyj "Reference Variable" dla DATABASE_URL

---

## 🎉 GOTOWE!

Twoja aplikacja działa na Railway!

### Sprawdź:

**Web URL:**
```
https://bet-assistant-production.up.railway.app
(Railway wygeneruje unikalny URL)
```

**Statusy serwisów:**
- 🟢 Web: Active
- 🟢 Worker: Active  
- 🟢 PostgreSQL: Active

**Logi:**
```
Web → Deployments → View Logs
Worker → Deployments → View Logs
```

---

## 💰 Koszty

```
Web:      $1.50/miesiąc
Worker:   $1.50/miesiąc
Database: $1.00/miesiąc
─────────────────────────
RAZEM:    ~$4.00/miesiąc

💰 Darmowy limit: $5/miesiąc
✅ MASZ $1 ZAPASU!
```

---

## 📚 Pełna dokumentacja

Szczegółowy przewodnik: **[RAILWAY-DEPLOYMENT.md](./RAILWAY-DEPLOYMENT.md)**

Zawiera:
- ✅ Troubleshooting
- ✅ Monitoring
- ✅ Rozwiązywanie problemów
- ✅ Optymalizacja kosztów

---

## 🆘 Szybka pomoc

**Problem:** Błąd "DATABASE_URL not set"
→ Dodaj PostgreSQL do projektu (Krok 3)

**Problem:** Błąd "API_FOOTBALL_KEY not set"  
→ Ustaw zmienną w Variables (Krok 4)

**Problem:** Worker się nie uruchamia
→ Sprawdź Start Command: `npm run railway:worker`

**Problem:** "Rate limit exceeded"
→ Sprawdź swój plan na API Football Dashboard

---

**Pytania?** Otwórz issue na GitHub lub sprawdź [RAILWAY-DEPLOYMENT.md](./RAILWAY-DEPLOYMENT.md)
