package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"os/signal"
	"syscall"
)

const (
	colorReset  = "\033[0m"
	colorGreen  = "\033[32m"
	colorBlue   = "\033[34m"
	colorYellow = "\033[33m"
	colorRed    = "\033[31m"
)

func main() {
	fmt.Println(colorBlue + "🤖 Bet Assistant Background Worker" + colorReset)
	fmt.Println(colorGreen + "====================================" + colorReset)
	
	// Start the worker
	fmt.Println("\n📦 Starting background worker...")
	
	cmd := exec.Command("npm", "run", "import:worker")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	
	if err := cmd.Start(); err != nil {
		log.Fatal(colorRed + "❌ Failed to start worker: " + err.Error() + colorReset)
	}
	
	fmt.Println("\n" + colorGreen + "✅ Worker is running!" + colorReset)
	fmt.Println(colorYellow + "📋 The worker checks for pending jobs every 60 seconds" + colorReset)
	fmt.Println(colorYellow + "📊 Create jobs through the web interface (http://localhost:3000)" + colorReset)
	fmt.Println(colorYellow + "📁 Logs are saved to: logs/import-YYYY-MM-DD.log" + colorReset)
	fmt.Println("\n⚠️  Press Ctrl+C to stop\n")
	
	// Handle graceful shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
	
	// Wait for signal or process to finish
	go func() {
		<-sigChan
		fmt.Println("\n\n🛑 Shutting down worker...")
		if err := cmd.Process.Kill(); err != nil {
			log.Println(colorRed + "Error stopping worker: " + err.Error() + colorReset)
		}
	}()
	
	// Wait for the worker process to finish
	if err := cmd.Wait(); err != nil {
		log.Println(colorRed + "Worker exited with error: " + err.Error() + colorReset)
	}
	
	fmt.Println(colorGreen + "👋 Worker stopped!" + colorReset)
}
