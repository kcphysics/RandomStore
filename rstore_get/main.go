package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
)

func Handler(request events.APIGatewayV2HTTPRequest) (events.APIGatewayV2HTTPResponse, error) {
	var Response events.APIGatewayV2HTTPResponse
	var err error
	log.Printf("Starting Handler, got the method %s\n", request.RequestContext.HTTP.Method)
	log.Println(request)
	switch request.RequestContext.HTTP.Method {
	case "GET":
		log.Println("Starting the GET handler")
		Response, err = GetHandler(request)
		if err != nil {
			return events.APIGatewayV2HTTPResponse{
				StatusCode: 500,
				Body:       fmt.Sprintf("Error received: %v", err),
			}, err
		}
	case "POST":
		Response, err = PostHandler(request)
		if err != nil {
			return events.APIGatewayV2HTTPResponse{
				StatusCode: 500,
				Body:       fmt.Sprintf("Error received: %v", err),
			}, err
		}
	}
	return Response, nil
}

func GetHandler(request events.APIGatewayV2HTTPRequest) (events.APIGatewayV2HTTPResponse, error) {
	log.Println("Got a GET request, starting to fetch the requested store")
	storeid := request.QueryStringParameters["storeid"]
	log.Printf("Received a request to fetch store saved at with Store ID of: %s\n", storeid)
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		log.Printf("Failed to create client: %v\n", err)
		return events.APIGatewayV2HTTPResponse{}, err
	}
	client := dynamodb.NewFromConfig(cfg)
	shop, err := GetShop(client, storeid)
	if err != nil {
		log.Printf("Unable to get store with StoreID: %s due to error: %v\n", storeid, err)
		return events.APIGatewayV2HTTPResponse{}, err
	}
	log.Println("Retrieved the shop successfully from DynamoDB")
	shop_str, err := json.Marshal(shop)
	if err != nil {
		log.Printf("Unable to serialize saved object: %v\n", err)
		return events.APIGatewayV2HTTPResponse{}, err
	}
	log.Println("Successfully serialized the shop for transmission")
	res := events.APIGatewayV2HTTPResponse{
		Body:       string(shop_str),
		StatusCode: 200,
		Headers:    map[string]string{"Content-Type": "application/json"},
	}
	return res, nil
}

func PostHandler(request events.APIGatewayV2HTTPRequest) (events.APIGatewayV2HTTPResponse, error) {
	var shop RandomStore
	err := json.Unmarshal([]byte(request.Body), &shop)
	if err != nil {
		return events.APIGatewayV2HTTPResponse{}, fmt.Errorf("invalid JSON recieved, %v", err)
	}
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		return events.APIGatewayV2HTTPResponse{}, err
	}
	client := dynamodb.NewFromConfig(cfg)
	shop_id, err := PutShop(client, shop)
	if err != nil {
		return events.APIGatewayV2HTTPResponse{}, err
	}
	stored := struct {
		ShopID  string
		ShopURL string
	}{
		ShopID:  shop_id,
		ShopURL: fmt.Sprintf("https://randomstore.scselvy.com/index.html?storeid=%s", shop_id),
	}
	stored_str, err := json.Marshal(stored)
	if err != nil {
		return events.APIGatewayV2HTTPResponse{}, nil
	}
	res := events.APIGatewayV2HTTPResponse{
		Body:       string(stored_str),
		StatusCode: 200,
		Headers:    map[string]string{"Content-Type": "application/json"},
	}
	return res, nil
}

func GetShop(client *dynamodb.Client, storeid string) (RandomStore, error) {
	var Shop RandomStore
	sid, err := attributevalue.Marshal(storeid)
	if err != nil {
		return RandomStore{}, err
	}
	key := map[string]types.AttributeValue{"StoreID": sid}
	response, err := client.GetItem(context.TODO(), &dynamodb.GetItemInput{
		Key:       key,
		TableName: aws.String("RandomStore"),
	})
	log.Println(response)
	if err != nil {
		return RandomStore{}, nil
	} else {
		err = attributevalue.Unmarshal(response.Item["Shop"], &Shop)
		if err != nil {
			return RandomStore{}, err
		}
	}
	return Shop, nil
}

func PutShop(client *dynamodb.Client, shop RandomStore) (string, error) {
	shop_record := ShopRecord{
		StoreID:       shop.StoreID,
		LastTouchedAt: time.Now().String(),
		Shop:          shop,
	}
	item, err := attributevalue.MarshalMap(shop_record)
	if err != nil {
		return "", nil
	}
	_, err = client.PutItem(context.TODO(), &dynamodb.PutItemInput{
		Item:      item,
		TableName: aws.String("RandomStore"),
	})
	if err != nil {
		return "", nil
	}
	return shop_record.StoreID, nil

}

func main() {
	lambda.Start(Handler)
}

// func main() {
// 	var Shop RandomStore
// 	raw_data, err := os.ReadFile("dummy_store.json")
// 	if err != nil {
// 		panic(err)
// 	}
// 	err = json.Unmarshal(raw_data, &Shop)
// 	if err != nil {
// 		panic(err)
// 	}
// 	log.Println("Successfully read in the Shop")
// 	cfg, err := config.LoadDefaultConfig(context.TODO())
// 	if err != nil {
// 		panic(err)
// 	}
// 	client := dynamodb.NewFromConfig(cfg)
// 	// sid, err := PutShop(client, Shop)
// 	// if err != nil {
// 	// 	panic(err)
// 	// }
// 	// log.Printf("Created an entry I guess... sid is ==> %s", sid)
// 	new_shop, err := GetShop(client, "1234567")
// 	if err != nil {
// 		log.Panicln(err)
// 	}
// 	log.Println(new_shop)
// 	log.Printf("We got ourselves a shop recalled!  Name ==> %s", new_shop.Name)
// }
