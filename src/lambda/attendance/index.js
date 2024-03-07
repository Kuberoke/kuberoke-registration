const AWS = require('aws-sdk')

const dynamodb = new AWS.DynamoDB()

const TableName = process.env.TABLENAME


const handler = async (event) => {
  let message = ''
  let statusCode = 200

  const body = JSON.parse(event.body)

  const params = {
    ExpressionAttributeNames: {
     "#a": "attended"
    }, 
    ExpressionAttributeValues: {
      ":a": {
        B: true
      },
    }, 
    Key: {
     "email": {
       S: body.email
      }
    },
    ConditionExpression: "attribute_exists(email)",
    ReturnValues: "NONE",
    TableName,
    UpdateExpression: "SET #a = :a"
  };

  try {
    if (statusCode == 200) await dynamodb.updateItem(params).promise()
  } catch (e) {
    statusCode = 400
    console.error(body, e)
    message = "Something went wrong. Please try again later."
    if (e.code === 'ConditionalCheckFailedException') {
      message = "This email is not registered."
    }
  }

  let response = {
      statusCode,
      headers: {
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({message})
  };

  console.debug("response: " + JSON.stringify(response))

  return response
};

module.exports = { handler }