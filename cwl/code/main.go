package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/cloudwatchlogs"
	"os"
)

var client *cloudwatchlogs.Client

const defaultRetentionInDays = 7
const maxResults = 50

const failFunction = "Function failed"
const okFunction = "Function successful"

func init() {
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion(os.Getenv("REGION")))
	if err != nil {
		panic("configuration error, " + err.Error())
	}

	client = cloudwatchlogs.NewFromConfig(cfg)
	if err != nil {
		panic("configuration error, " + err.Error())
	}
}

func HandleRequest() ([]string, error) {
	var nextToken *string
	for {
		result, err := client.DescribeLogGroups(context.TODO(), &cloudwatchlogs.DescribeLogGroupsInput{
			LogGroupNamePrefix: aws.String("/aws/lambda/"),
			Limit:              aws.Int32(maxResults),
			NextToken:          nextToken,
		})
		if err != nil {
			return []string{failFunction}, err
		}
		for _, logGroup := range result.LogGroups {
			if logGroup.RetentionInDays == nil {
				fmt.Println(*logGroup.LogGroupName)
				_, err := client.PutRetentionPolicy(context.TODO(), &cloudwatchlogs.PutRetentionPolicyInput{
					LogGroupName:    logGroup.LogGroupName,
					RetentionInDays: aws.Int32(defaultRetentionInDays),
				})
				if err != nil {
					return []string{failFunction}, err
				}
			}
		}
		if result.NextToken == nil {
			break
		}
		nextToken = result.NextToken
	}

	return []string{okFunction}, nil
}

func main() {
	lambda.Start(HandleRequest)
	//_, _ = HandleRequest()
}
