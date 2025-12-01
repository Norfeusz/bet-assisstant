# Database Backups

Ten folder zawiera automatyczne backupy bazy danych PostgreSQL.

## System rotacyjny backupów

- Przechowywanych jest **maksymalnie 10 backupów** (database-backup-1.sql do database-backup-10.sql)
- Każdy nowy backup **nadpisuje najstarszy** plik
- Backupy są tworzone automatycznie po każdym zadaniu importu
- Wszystkie backupy są commitowane do repozytorium Git

## Struktura plików

```
backups/
├── database-backup-1.sql   # Backup slot #1
├── database-backup-2.sql   # Backup slot #2
├── ...
└── database-backup-10.sql  # Backup slot #10
```

## Automatyczne backupy

Backup jest tworzony automatycznie:
- Po zakończeniu każdego zadania importu w tle (background import worker)
- Backup jest automatycznie commitowany i pushowany do GitHub
- System wybiera najstarszy slot do nadpisania

## Ręczne tworzenie backupu

```bash
# Utwórz backup (nadpisze najstarszy plik)
npm run backup

# Utwórz backup i wyślij do GitHub
npm run backup -- --push

# Utwórz backup nawet jeśli nie ma zmian
npm run backup -- --push --force
```

## Przywracanie z backupu

```powershell
# Znajdź odpowiedni backup (wyświetl listę z datami)
Get-ChildItem backups\*.sql | Sort-Object LastWriteTime -Descending | Select-Object Name, LastWriteTime, @{N='Size MB';E={[math]::Round($_.Length/1MB,2)}}

# Przywróć wybrany backup
$env:PGPASSWORD="Iron4maiden124!"
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -p 1906 -d bet_assistant -f backups/database-backup-5.sql
```

## Format backupu

Backup zawiera:
- `DROP TABLE IF EXISTS` - czyści istniejące tabele
- `CREATE TABLE` - tworzy strukturę tabel
- `INSERT INTO` - wstawia wszystkie dane
- Bez uprawnień właściciela (--no-owner --no-privileges)

## Monitoring

Przy każdym backupie wyświetlana jest lista istniejących backupów:
```
📋 Existing backups:
  backup-5: 2025-12-01 20:15:03 (5.42 MB)
  backup-3: 2025-11-30 18:30:12 (4.87 MB)
  backup-1: 2025-11-29 22:14:59 (4.23 MB)
  ...
```

## Informacje o backupach

Każdy backup zawiera informacje:
- Numer slotu (1-10)
- Data i czas utworzenia
- Rozmiar pliku w MB
- Liczba tabel
- Liczba instrukcji INSERT
- Timestamp w nazwie commita Git
