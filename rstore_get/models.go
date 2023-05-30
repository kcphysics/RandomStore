package main

type Item struct {
	Name             string   `json:"name"`
	BasePrice        float64  `json:"base_price"`
	Weight           float64  `json:"weight"`
	Description      string   `json:"description"`
	Tags             []string `json:"tags"`
	BaseAvailability float64  `json:"base_availability"`
	Price            float64  `json:"price"`
	Stock            int      `json:"stock"`
	BaseStock        int      `json:"base_stock"`
	StockedQuantity  int      `json:"stocked_quantity"`
}

type RSConfig struct {
	SettlementType       string `json:"settlementType"`
	NumberScarcityEvents int    `json:"numberScarcityEvents"`
	NumberSurplusEvents  int    `json:"numberSurplusEvents"`
	ScarceTags           []string
	SurplusTags          []string
}

type RandomStore struct {
	StoreID string   `json:"storeid"`
	Name    string   `json:"name"`
	Config  RSConfig `json:"config"`
	Items   []Item   `json:"items"`
}

type ShopRecord struct {
	StoreID       string      `json:"storeID"`
	LastTouchedAt string      `json:"last_touched_at"`
	Shop          RandomStore `json:"shop"`
}
