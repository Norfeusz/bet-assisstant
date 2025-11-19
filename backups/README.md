# Database Backups

Ten folder zawiera automatyczne backupy bazy danych PostgreSQL.

## Pliki

- `database-backup.sql` - Najnowszy backup bazy danych (automatycznie aktualizowany po każdym imporcie)

## Automatyczne backupy

Backup jest tworzony automatycznie:
- Po zakończeniu każdego zadania importu w tle (background import worker)
- Backup jest automatycznie commitowany i pushowany do GitHub

## Ręczne backupy

Możesz również utworzyć backup ręcznie:

```bash
# Backup z automatycznym pushem do GitHub
npm run backup

# Backup z wymuszonym pushem (nawet jeśli nie ma zmian)
npm run backup:force
```

## Przywracanie backupu

Aby przywrócić bazę danych z backupu:

```powershell
$env:PGPASSWORD="Iron4maiden124!"
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -p 1906 -d bet_assistant -f backups/database-backup.sql
```

Lub przez npm script (jeśli zostanie dodany):

```bash
npm run db:restore
```

## Format backupu

Backup zawiera:
- `DROP TABLE IF EXISTS` - czyści istniejące tabele
- `CREATE TABLE` - tworzy strukturę tabel
- `INSERT INTO` - wstawia wszystkie dane
- Bez uprawnień właściciela (--no-owner --no-privileges)

## Rozmiar

Typowy rozmiar backupu:
- Pusta baza: ~5-10 KB
- Z danymi: zależny od liczby zaimportowanych meczów (typowo kilka MB)
