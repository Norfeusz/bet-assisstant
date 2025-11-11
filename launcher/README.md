# Bet Assistant Launcher

Proste launchery w Go, które uruchamiają aplikację jednym kliknięciem.

## Kompilacja

### Windows

```bash
cd launcher
# Serwer webowy
go build -o bet-assistant.exe main.go

# Background worker
go build -o bet-assistant-worker.exe worker-main.go
```

### Linux/macOS

```bash
cd launcher
# Serwer webowy
go build -o bet-assistant main.go

# Background worker
go build -o bet-assistant-worker worker-main.go
```

## Użycie

### Serwer Webowy

Po skompilowaniu, po prostu kliknij dwukrotnie na plik:

- Windows: `bet-assistant.exe` lub `Bet Assistant.bat`
- Linux/macOS: `./bet-assistant`

Aplikacja:

1. Uruchomi serwer Node.js
2. Otworzy przeglądarkę na http://localhost:3000
3. Będzie działać do momentu zamknięcia (Ctrl+C)

### Background Worker

Uruchom w osobnym oknie:

- Windows: `bet-assistant-worker.exe` lub `Bet Assistant Worker.bat`
- Linux/macOS: `./bet-assistant-worker`

Worker:

1. Uruchomi proces w tle
2. Będzie sprawdzał zadania co 60 sekund
3. Automatycznie importuje dane z zakolejkowanych zadań
4. Zapisuje logi do `logs/import-YYYY-MM-DD.log`
5. Działa do momentu zamknięcia (Ctrl+C)
