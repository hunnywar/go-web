package main

import (
	"fmt"
	"html/template"
	"net/http"
)

type PageData struct {
	Title   string
	Message string
}

func main() {
	// Serve static files (e.g., CSS, JS, images)
	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))

	// Define a handler for the home page
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		data := PageData{
			Title:   "Welcome to My Go App",
			Message: "This is a simple web interface using Go.",
		}
		tmpl, err := template.ParseFiles("templates/index.html")
		if err != nil {
			http.Error(w, "Error loading template", http.StatusInternalServerError)
			return
		}
		tmpl.Execute(w, data)
	})

	// Start the server
	port := "8080"
	fmt.Printf("Starting server on port %s...\n", port)
	http.ListenAndServe(":"+port, nil)
}
