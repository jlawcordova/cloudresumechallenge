import {
  DynamoDBClient,
  GetItemCommand,
  PutItemCommand,
  UpdateItemCommand,
} from "@aws-sdk/client-dynamodb";
import { hash } from "./hashUtil.mjs";

const Region = "ap-southeast-1";
export const dynamoDBClient = new DynamoDBClient({ region: Region });

const viewCountTable = process.env.VIEW_COUNT_TABLE;
const visitorTable = process.env.VISITOR_TABLE;

export async function hasVisitorViewed(ip) {
  const params = {
    TableName: visitorTable,
    Key: {
      IP: { S: hash(ip) },
    },
  };
  const data = await dynamoDBClient.send(new GetItemCommand(params));
  return data.Item != null;
}

export async function putVisitor(ip) {
  var today = new Date();
  var tomorrow = new Date().setDate(today + 1);

  const params = {
    TableName: visitorTable,
    Item: {
      IP: { S: hash(ip) },
      TTL: { S: tomorrow.getTime() },
    },
  };
  await dynamoDBClient.send(new PutItemCommand(params));
}

export async function getViewCount(resumeId) {
  const params = {
    TableName: viewCountTable,
    Key: {
      Id: { S: resumeId },
    },
  };
  const data = await dynamoDBClient.send(new GetItemCommand(params));
  return data.Item.ViewCount.N;
}

export async function incrementViewCount(resumeId) {
  const params = {
    TableName: viewCountTable,
    Key: {
      Id: { S: resumeId },
    },
    UpdateExpression: "ADD ViewCount :n",
    ExpressionAttributeValues: {
      ":n": { N: "1" },
    },
    ReturnValues: "UPDATED_NEW",
  };
  const data = await dynamoDBClient.send(new UpdateItemCommand(params));
  return data.Attributes.ViewCount.N;
}
