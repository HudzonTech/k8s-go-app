package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestRootHandler(t *testing.T) {
	req := httptest.NewRequest("GET", "/", nil)
	rr := httptest.NewRecorder()
	http.HandlerFunc(rootHandler).ServeHTTP(rr, req)
	if rr.Code != http.StatusOK {
		t.Fatalf("status=%d", rr.Code)
	}
	var resp HelloResponse
	if err := json.Unmarshal(rr.Body.Bytes(), &resp); err != nil {
		t.Fatalf("json: %v", err)
	}
	if resp.Message == "" {
		t.Fatal("empty message")
	}
}

func TestHealthHandler(t *testing.T) {
	req := httptest.NewRequest("GET", "/health", nil)
	rr := httptest.NewRecorder()
	http.HandlerFunc(healthHandler).ServeHTTP(rr, req)
	if rr.Code != http.StatusOK {
		t.Fatalf("status=%d", rr.Code)
	}
	var resp HealthResponse
	if err := json.Unmarshal(rr.Body.Bytes(), &resp); err != nil {
		t.Fatalf("json: %v", err)
	}
	if resp.Status != "ok" {
		t.Fatalf("status=%q", resp.Status)
	}
	if resp.Version == "" {
		t.Fatal("empty version")
	}
	if resp.Timestamp == "" {
		t.Fatal("empty timestamp")
	}
}

func TestVersionHandler(t *testing.T) {
	req := httptest.NewRequest("GET", "/version", nil)
	rr := httptest.NewRecorder()
	http.HandlerFunc(versionHandler).ServeHTTP(rr, req)
	if rr.Code != http.StatusOK {
		t.Fatalf("status=%d", rr.Code)
	}
	var body map[string]string
	if err := json.Unmarshal(rr.Body.Bytes(), &body); err != nil {
		t.Fatalf("json: %v", err)
	}
	if body["version"] == "" {
		t.Fatal("empty version")
	}
}

func TestMethodNotAllowed(t *testing.T) {
	req := httptest.NewRequest("POST", "/", nil)
	rr := httptest.NewRecorder()
	http.HandlerFunc(rootHandler).ServeHTTP(rr, req)
	if rr.Code != http.StatusMethodNotAllowed {
		t.Fatalf("status=%d", rr.Code)
	}
}
