# ✅ Railway Deployment - Checklist Weryfikacyjny

Użyj tej checklisty po wdrożeniu, aby upewnić się, że wszystko działa poprawnie.

---

## 📦 PRZED DEPLOYMENT

- [ ] Projekt jest w repozytorium GitHub
- [ ] Masz klucz API Football (https://dashboard.api-football.com/register)
- [ ] Wszystkie zmiany są zacommitowane i pushowane do `main`
- [ ] Pliki są gotowe:
  - [ ] `railway.json`
  - [ ] `Procfile`
  - [ ] `package.json` (ze skryptami railway:server i railway:worker)
  - [ ] `.env.railway.example`

---

## 🚀 KONFIGURACJA RAILWAY

### 1. Utworzenie projektu
- [ ] Zalogowano do Railway.app
- [ ] Utworzono nowy projekt
- [ ] Połączono z repozytorium GitHub `bet-assisstant`
- [ ] Railway wykrył projekt jako Node.js

### 2. PostgreSQL
- [ ] Dodano PostgreSQL database do projektu
- [ ] Railway automatycznie ustawił `DATABASE_URL`
- [ ] Status PostgreSQL: 🟢 Active

### 3. Serwis Web (Server)
- [ ] Serwis Web został automatycznie utworzony
- [ ] Dodano zmienne środowiskowe:
  - [ ] `API_FOOTBALL_KEY` (z prawdziwym kluczem!)
  - [ ] `API_FOOTBALL_HOST=v3.football.api-sports.io`
  - [ ] `API_FOOTBALL_BASE_URL=https://v3.football.api-sports.io`
  - [ ] `RATE_LIMIT_REQUESTS_PER_DAY=100`
  - [ ] `RATE_LIMIT_REQUESTS_PER_HOUR=10`
  - [ ] `LOG_LEVEL=INFO`
  - [ ] `TZ=Europe/Warsaw`
- [ ] `DATABASE_URL` jest dostępne (automatycznie)
- [ ] Status Web: 🟢 Active
- [ ] Railway wygenerował publiczny URL

### 4. Serwis Worker
- [ ] Utworzono nowy Empty Service nazwany "Worker"
- [ ] Połączono z tym samym repozytorium GitHub
- [ ] W Settings → Start Command ustawiono: `npm run railway:worker`
- [ ] Skopiowano wszystkie zmienne środowiskowe z Web lub:
  - [ ] Użyto Reference Variable dla `DATABASE_URL`
  - [ ] Dodano pozostałe zmienne (API_FOOTBALL_KEY, etc.)
- [ ] Status Worker: 🟢 Active

---

## 🔍 WERYFIKACJA PO DEPLOYMENT

### 1. Sprawdzenie logów Web
- [ ] Przejdź do: Web → Deployments → Najnowszy deployment
- [ ] Sprawdź logi pod kątem błędów
- [ ] Powinny pojawić się komunikaty:
  - [ ] `✅ Prisma Client generated`
  - [ ] `✅ Migrations applied`
  - [ ] `🌐 League Configuration Web Interface`
  - [ ] `Server running on port: XXXX`
  - [ ] `Railway Environment: production`

### 2. Sprawdzenie logów Worker
- [ ] Przejdź do: Worker → Deployments → Najnowszy deployment
- [ ] Sprawdź logi pod kątem błędów
- [ ] Powinny pojawić się komunikaty:
  - [ ] `✅ Prisma Client generated`
  - [ ] `🔄 Background import worker started`
  - [ ] `⏰ Checking for import jobs every 60 seconds...`

### 3. Sprawdzenie logów PostgreSQL
- [ ] Przejdź do: PostgreSQL → View Logs
- [ ] Brak błędów połączenia
- [ ] Baza danych jest online

### 4. Test aplikacji webowej
- [ ] Otwórz URL aplikacji (Web → Settings → Skopiuj URL)
- [ ] Strona główna się ładuje
- [ ] Interfejs jest widoczny i responsywny
- [ ] Brak błędów w konsoli przeglądarki (F12)

### 5. Test API Endpoints

**Endpoint: Rate Limit**
- [ ] Otwórz: `https://TWÓJ-URL.up.railway.app/api/rate-limit`
- [ ] Otrzymano odpowiedź JSON:
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

**Endpoint: Import Jobs**
- [ ] Otwórz: `https://TWÓJ-URL.up.railway.app/api/import-jobs`
- [ ] Otrzymano odpowiedź JSON z pustą lub pełną listą zadań

### 6. Utworzenie zadania importu
- [ ] W interfejsie przejdź do "Zarządzanie importami"
- [ ] Kliknij "+ Nowe zadanie importu"
- [ ] Wybierz kilka lig (np. Premier League, Bundesliga)
- [ ] Ustaw zakres dat (ostatnie 7-14 dni dla testu)
- [ ] Kliknij "Utwórz zadanie"
- [ ] Zadanie pojawiło się na liście ze statusem "pending"

### 7. Weryfikacja działania Worker
**Czekaj 1-2 minuty, a następnie:**
- [ ] Sprawdź logi Worker
- [ ] Powinny pojawić się komunikaty:
  - [ ] `✅ Found job #X to process`
  - [ ] `Starting job: X leagues from ... to ...`
  - [ ] `Processing league: ...`
  - [ ] `Progress: X imported, Y failed`
- [ ] Odśwież listę zadań w interfejsie
- [ ] Status zadania zmienił się na `in_progress` lub `completed`
- [ ] Licznik `imported_matches` rośnie

### 8. Weryfikacja bazy danych
- [ ] W Railway → PostgreSQL → Connect → skopiuj connection string
- [ ] (Opcjonalnie) Połącz się przez pgAdmin lub Prisma Studio lokalnie:
  ```powershell
  # Ustaw DATABASE_URL na Railway PostgreSQL
  $env:DATABASE_URL="postgresql://..."
  npm run db:studio
  ```
- [ ] Sprawdź tabelę `matches` - powinny być nowe rekordy
- [ ] Sprawdź tabelę `import_jobs` - powinno być utworzone zadanie

---

## 💰 SPRAWDZENIE KOSZTÓW

- [ ] Railway Dashboard → Projekt → Zakładka "Usage"
- [ ] Sprawdź użycie zasobów:
  - Web: ~$1-2/miesiąc
  - Worker: ~$1-2/miesiąc
  - PostgreSQL: ~$1/miesiąc
- [ ] **RAZEM: ~$3-5/miesiąc** (w limicie darmowych $5!)

### Metryki w czasie rzeczywistym
- [ ] Zakładka "Metrics" dostępna
- [ ] Memory Usage: ~100-300MB na serwis
- [ ] CPU Usage: <10% w spoczynku
- [ ] Network: Zależy od importów

---

## 🐛 TROUBLESHOOTING

### Jeśli Web nie startuje:
- [ ] Sprawdź logi: Web → Deployments → View Logs
- [ ] Szukaj błędów: "DATABASE_URL", "API_FOOTBALL_KEY"
- [ ] Zweryfikuj wszystkie zmienne środowiskowe
- [ ] Upewnij się, że PostgreSQL jest dodany do projektu

### Jeśli Worker nie startuje:
- [ ] Sprawdź Start Command: `npm run railway:worker`
- [ ] Sprawdź logi: Worker → Deployments → View Logs
- [ ] Zweryfikuj zmienne (szczególnie DATABASE_URL)
- [ ] Sprawdź czy Worker ma dostęp do tego samego repozytorium

### Jeśli migracje Prisma nie działają:
- [ ] Sprawdź czy folder `prisma/migrations/` jest w repozytorium
- [ ] Sprawdź logi pod kątem: "Applying migration"
- [ ] Manualnie uruchom w Railway CLI (jeśli zainstalowane):
  ```bash
  railway run prisma migrate deploy
  ```

### Jeśli Rate Limit exceeded od razu:
- [ ] To NORMALNE przy pierwszym uruchomieniu z wieloma ligami
- [ ] Worker automatycznie wznowi po 15 minutach
- [ ] Sprawdź swój plan API Football na dashboard
- [ ] Rozważ zmniejszenie liczby lig w pierwszym zadaniu

---

## 🎉 SUKCES!

Jeśli wszystkie powyższe punkty są zaznaczone, Twoja aplikacja działa poprawnie na Railway! 🚀

### Co dalej?
- [ ] Monitoruj logi regularnie (codziennie przez pierwszy tydzień)
- [ ] Sprawdzaj koszty co tydzień (upewnij się że <$5)
- [ ] Dodaj więcej lig po pomyślnych testach
- [ ] (Opcjonalnie) Skonfiguruj custom domain w Railway Settings

---

## 📞 Pomoc

**Problem nadal występuje?**
1. Przeczytaj szczegółowy przewodnik: [RAILWAY-DEPLOYMENT.md](./RAILWAY-DEPLOYMENT.md)
2. Sprawdź sekcję Troubleshooting
3. Otwórz issue na GitHub z:
   - Opisem problemu
   - Logami z Railway
   - Krokami do reprodukcji

**Railway Support:**
- Discord: https://discord.gg/railway
- Dokumentacja: https://docs.railway.app

---

**Data ostatniej weryfikacji:** _______________  
**Wszystko działa?** ✅ TAK / ❌ NIE  
**Notatki:** _______________________________________________
