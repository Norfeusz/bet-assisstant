package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
	"runtime"
	"syscall"
	"time"
)

const (
	serverURL = "http://localhost:3000"
	maxWaitTime = 30 * time.Second
	checkInterval = 500 * time.Millisecond
	colorReset = "\033[0m"
	colorGreen = "\033[32m"
	colorBlue  = "\033[34m"
	colorRed   = "\033[31m"
	colorYellow = "\033[33m"
)

func main() {
	fmt.Println(colorBlue + "🚀 Bet Assistant Launcher" + colorReset)
	fmt.Println(colorGreen + "================================" + colorReset)
	
	// Start the Node.js server
	fmt.Println("\n📦 Starting server...")
	
	cmd := exec.Command("npm", "run", "leagues:web")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	
	if err := cmd.Start(); err != nil {
		log.Fatal(colorRed + "❌ Failed to start server: " + err.Error() + colorReset)
	}
	
	// Wait for server to be ready with proper health check
	fmt.Println("⏳ Waiting for server to start...")
	if !waitForServer(serverURL, maxWaitTime) {
		fmt.Println(colorRed + "❌ Server failed to start within timeout" + colorReset)
		fmt.Println(colorYellow + "💡 Try running 'npm run leagues:web' manually to see detailed errors" + colorReset)
		cmd.Process.Kill()
		os.Exit(1)
	}
	
	// Open browser
	fmt.Println("🌐 Opening browser...")
	if err := openBrowser(serverURL); err != nil {
		fmt.Println(colorRed + "⚠️  Could not open browser automatically: " + err.Error() + colorReset)
		fmt.Println("👉 Please open manually: " + serverURL)
	} else {
		fmt.Println(colorGreen + "✅ Browser opened!" + colorReset)
	}
	
	fmt.Println("\n" + colorGreen + "✨ Application is running!" + colorReset)
	fmt.Println("📍 URL: " + serverURL)
	fmt.Println("⚠️  Press Ctrl+C to stop\n")
	
	// Handle graceful shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
	
	<-sigChan
	
	fmt.Println("\n\n🛑 Shutting down...")
	if err := cmd.Process.Kill(); err != nil {
		log.Println(colorRed + "Error stopping server: " + err.Error() + colorReset)
	}
	fmt.Println(colorGreen + "👋 Goodbye!" + colorReset)
}

// waitForServer checks if the server is responding
func waitForServer(url string, maxWait time.Duration) bool {
	client := &http.Client{
		Timeout: 2 * time.Second,
	}
	
	start := time.Now()
	dots := 0
	
	for time.Since(start) < maxWait {
		resp, err := client.Get(url)
		if err == nil && resp.StatusCode == 200 {
			resp.Body.Close()
			fmt.Print("\n")
			return true
		}
		if resp != nil {
			resp.Body.Close()
		}
		
		// Show progress
		fmt.Print(".")
		dots++
		if dots%10 == 0 {
			fmt.Printf(" %ds\n", int(time.Since(start).Seconds()))
		}
		
		time.Sleep(checkInterval)
	}
	
	fmt.Print("\n")
	return false
}

// openBrowser opens the default browser to the given URL
func openBrowser(url string) error {
	var cmd *exec.Cmd
	
	switch runtime.GOOS {
	case "windows":
		cmd = exec.Command("cmd", "/c", "start", url)
	case "darwin":
		cmd = exec.Command("open", url)
	case "linux":
		cmd = exec.Command("xdg-open", url)
	default:
		return fmt.Errorf("unsupported platform")
	}
	
	return cmd.Start()
}
