package main

import (
	"net/http"
	"os"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func main() {
	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)

	message := os.Getenv("TARGET")

	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(message))
	})

	http.ListenAndServe(":3333", r)
}
