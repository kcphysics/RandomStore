package main

import (
	"context"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
)

var TableName string
var SiteName string

func calculateBearerToken(storeid string) string {
	astring := fmt.Sprintf("rstore|==%s==|rstore", storeid)
	ahash := sha256.Sum256([]byte(astring))
	return fmt.Sprintf("Bearer %x", ahash)
}

func validateHeaders(headers map[string]string, storeid string) bool {
	bearer := headers["authorization"]
	correct_bearer := calculateBearerToken(storeid)
	log.Printf("Calculated: %s ---- Provided: %s", correct_bearer, bearer)
	return bearer == correct_bearer
}

func Handler(request events.APIGatewayV2HTTPRequest) (events.APIGatewayV2HTTPResponse, error) {
	if os.Getenv("RSTableName") == "" {
		TableName = "RandomStore"
	} else {
		TableName = os.Getenv("RSTableName")
	}
	if os.Getenv("RSSiteName") == "" {
		SiteName = "https://randomstore.scselvy.com"
	} else {
		SiteName = os.Getenv("RSSiteName")
	}
	log.Printf("The target Table to store/get information from is %s", TableName)
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
	if !validateHeaders(request.Headers, storeid) {
		return events.APIGatewayV2HTTPResponse{
			StatusCode: 401,
			Body:       "Unauthorized, go away",
		}, nil
	}
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
	expiration_time, err := UpdateOnRead(client, storeid)
	if err != nil {
		log.Printf("Unable to update expiration time due to error: %v\n", err)
	} else {
		log.Printf("Successfully updated expiration time to %d\n", expiration_time)
	}
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
	if !validateHeaders(request.Headers, shop.StoreID) {
		return events.APIGatewayV2HTTPResponse{
			StatusCode: 401,
			Body:       "Unauthorized, go away",
		}, nil
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
		ShopURL: fmt.Sprintf("%s/index.html?storeid=%s", SiteName, shop_id),
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

func UpdateOnRead(client *dynamodb.Client, storeid string) (int64, error) {
	new_expiration_time := time.Now().AddDate(0, 0, 30)
	net, err := attributevalue.Marshal(new_expiration_time.Unix())
	if err != nil {
		return 0, err
	}
	sid, err := attributevalue.Marshal(storeid)
	if err != nil {
		return 0, err
	}
	update_expression := "SET ExpiresAt = :new_expiration_time"
	expression_attribute_values := map[string]types.AttributeValue{
		":new_expiration_time": net,
	}
	key := map[string]types.AttributeValue{"StoreID": sid}
	update_item_input := dynamodb.UpdateItemInput{
		Key:                       key,
		UpdateExpression:          &update_expression,
		ExpressionAttributeValues: expression_attribute_values,
		TableName:                 aws.String(TableName),
	}
	_, err = client.UpdateItem(context.TODO(), &update_item_input)
	if err != nil {
		return 0, err
	}
	return new_expiration_time.Unix(), nil
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
		TableName: aws.String(TableName),
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
	expiration_date := time.Now().AddDate(0, 0, 30)
	shop_record := ShopRecord{
		StoreID:   shop.StoreID,
		ExpiresAt: expiration_date.Unix(),
		Shop:      shop,
	}
	item, err := attributevalue.MarshalMap(shop_record)
	if err != nil {
		return "", nil
	}
	_, err = client.PutItem(context.TODO(), &dynamodb.PutItemInput{
		Item:      item,
		TableName: aws.String(TableName),
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
// 	cfg, err := config.LoadDefaultConfig(context.TODO())
// 	if err != nil {
// 		panic("Can't get AWS Config")
// 	}
// 	client := dynamodb.NewFromConfig(cfg)
// 	storeid := "e0524f08-7ef8-4327-ae6c-9d2cb8ae506d"
// 	shop, err := GetShop(client, storeid)
// 	if err != nil {
// 		panic(fmt.Sprintf("Unable to get shop from DynamoDB because %v", err))
// 	}
// 	fmt.Println(shop.Name)
// 	expires_at, err := UpdateOnRead(client, storeid)
// 	if err != nil {
// 		panic(err)
// 	}
// 	fmt.Println(time.Unix(expires_at, 0))

// }
