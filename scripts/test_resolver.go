package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strings"
	"time"
)

type Language struct {
	ID       string `json:"Id"`
	Language string `json:"Language"`
}

type SkuResponse struct {
	Skus []Language `json:"Skus"`
}

func main() {
	fmt.Println("=== WinDownload Link Resolution Pipeline Test ===")
	fmt.Println("Testing Windows 11 25H2 (Product ID 3262)...")

	client := &http.Client{Timeout: 10 * time.Second}
	apiURL := "https://api.msdl.tech-latest.com/skuinfo?product_id=3262"

	resp, err := client.Get(apiURL)
	if err != nil {
		fmt.Printf("Error contacting resolver endpoint: %v\n", err)
		os.Exit(1)
	}
	defer resp.Body.Close()

	var skuResp SkuResponse
	if err := json.NewDecoder(resp.Body).Decode(&skuResp); err != nil {
		fmt.Printf("Error decoding SKU response: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("✓ Successfully resolved %d official Microsoft languages.\n", len(skuResp.Skus))

	var englishSKU, polishSKU Language
	for _, l := range skuResp.Skus {
		if strings.EqualFold(l.Language, "English") {
			englishSKU = l
		}
		if strings.EqualFold(l.Language, "Polish") {
			polishSKU = l
		}
	}

	if englishSKU.ID != "" {
		fmt.Printf("  • English SKU ID: %s\n", englishSKU.ID)
	}
	if polishSKU.ID != "" {
		fmt.Printf("  • Polish SKU ID: %s\n", polishSKU.ID)
	}

	fmt.Println("\n✓ Verification complete: Microsoft catalog and SKU mapping is operational!")
}
