# Google Sheets - Instrukcja konfiguracji

## Kroki konfiguracji:

### 1. Utwórz projekt w Google Cloud Console
1. Wejdź na https://console.cloud.google.com/
2. Utwórz nowy projekt lub wybierz istniejący
3. Zapisz nazwę projektu

### 2. Włącz Google Sheets API
1. W menu wybierz "APIs & Services" > "Library"
2. Wyszukaj "Google Sheets API"
3. Kliknij "Enable"

### 3. Utwórz Service Account
1. W menu wybierz "APIs & Services" > "Credentials"
2. Kliknij "Create Credentials" > "Service Account"
3. Podaj nazwę (np. "bet-assistant-sheets")
4. Kliknij "Create and Continue"
5. Pomiń role (kliknij "Continue")
6. Kliknij "Done"

### 4. Pobierz klucz JSON
1. W liście Service Accounts kliknij na utworzone konto
2. Przejdź do zakładki "Keys"
3. Kliknij "Add Key" > "Create new key"
4. Wybierz typ "JSON"
5. Kliknij "Create" - plik zostanie pobrany
6. Zmień nazwę pliku na `google-sheets-config.json`
7. Skopiuj plik do głównego folderu projektu (obok package.json)

### 5. Utwórz arkusz Google Sheets
1. Wejdź na https://sheets.google.com
2. Utwórz nowy arkusz
3. Zmień nazwę pierwszego arkusza na "Bet Builder"
4. Dodaj nagłówki w pierwszym wierszu:
   - A1: Drużyna gospodarzy
   - B1: Drużyna gości
   - C1: Zakład
   - D1: Typ
   - E1: Założenie
   - F1: Gospodarz %
   - G1: Gość %
   - H1: Pusty
   - I1: Kurs

### 6. Udostępnij arkusz dla Service Account
1. Otwórz plik `google-sheets-config.json`
2. Znajdź pole `client_email` (np. "bet-assistant-sheets@project.iam.gserviceaccount.com")
3. Skopiuj ten adres email
4. W Google Sheets kliknij "Share" (Udostępnij)
5. Wklej skopiowany email
6. Ustaw uprawnienia na "Editor"
7. Kliknij "Share"

### 7. Pobierz ID arkusza
1. Otwórz arkusz Google Sheets
2. Skopiuj ID z URL (część między /d/ a /edit):
   ```
   https://docs.google.com/spreadsheets/d/SKOPIUJ_TO_ID/edit
   ```

### 8. Dodaj ID do pliku .env
1. Otwórz plik `.env` w głównym folderze projektu
2. Dodaj linię:
   ```
   GOOGLE_SHEETS_ID=TWOJE_ID_ARKUSZA
   ```

## Gotowe!
Teraz możesz zrestartować aplikację przez `Bet Assistant.bat` i korzystać z funkcji "Strefa typera".

## Troubleshooting

### Błąd: "google-sheets-config.json not found"
- Upewnij się, że plik `google-sheets-config.json` jest w głównym folderze projektu (obok package.json)

### Błąd: "The caller does not have permission"
- Sprawdź czy arkusz został udostępniony dla service account email
- Sprawdź czy Google Sheets API jest włączone w projekcie

### Błąd: "GOOGLE_SHEETS_ID not configured"
- Dodaj `GOOGLE_SHEETS_ID=...` do pliku .env
