import json
import os
import boto3

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TABLE_NAME', 'WebAppTable')
table = dynamodb.Table(table_name)

def handler(event, context):
    print(f"Received event: {json.dumps(event)}")

    http_method = event.get('httpMethod')
    path = event.get('path')

    if http_method == 'POST' and path == '/items':
        return create_item(event)
    elif http_method == 'GET' and path == '/items':
        return get_all_items()
    elif http_method == 'GET' and path.startswith('/items/'):
        return get_item_by_id(event)
    elif http_method == 'PUT' and path.startswith('/items/'):
        return update_item(event)
    elif http_method == 'DELETE' and path.startswith('/items/'):
        return delete_item(event)
    else:
        return {
            'statusCode': 404,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'message': 'Not Found'})
        }

def create_item(event):
    try:
        body = json.loads(event['body'])
        item_id = body.get('id')
        item_data = body.get('data')

        if not item_id or not item_data:
            return {
                'statusCode': 400,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps({'message': 'Missing id or data in request body'})
            }

        table.put_item(Item={'id': item_id, 'data': item_data})
        return {
            'statusCode': 201,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'message': 'Item created successfully', 'item_id': item_id})
        }
    except Exception as e:
        print(f"Error creating item: {e}")
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'message': 'Could not create item', 'error': str(e)})
        }

def get_all_items():
    try:
        response = table.scan()
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps(response['Items'])
        }
    except Exception as e:
        print(f"Error getting all items: {e}")
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'message': 'Could not retrieve items', 'error': str(e)})
        }

def get_item_by_id(event):
    try:
        item_id = event['pathParameters']['proxy']
        response = table.get_item(Key={'id': item_id})
        item = response.get('Item')
        if item:
            return {
                'statusCode': 200,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps(item)
            }
        else:
            return {
                'statusCode': 404,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps({'message': 'Item not found'})
            }
    except Exception as e:
        print(f"Error getting item by ID: {e}")
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'message': 'Could not retrieve item', 'error': str(e)})
        }

def update_item(event):
    try:
        item_id = event['pathParameters']['proxy']
        body = json.loads(event['body'])
        item_data = body.get('data')

        if not item_data:
            return {
                'statusCode': 400,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps({'message': 'Missing data in request body'})
            }

        response = table.update_item(
            Key={'id': item_id},
            UpdateExpression='SET #d = :data',
            ExpressionAttributeNames={'#d': 'data'},
            ExpressionAttributeValues={':data': item_data},
            ReturnValues='UPDATED_NEW'
        )
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'message': 'Item updated successfully', 'updated_attributes': response.get('Attributes')})
        }
    except Exception as e:
        print(f"Error updating item: {e}")
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'message': 'Could not update item', 'error': str(e)})
        }

def delete_item(event):
    try:
        item_id = event['pathParameters']['proxy']
        table.delete_item(Key={'id': item_id})
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'message': 'Item deleted successfully', 'item_id': item_id})
        }
    except Exception as e:
        print(f"Error deleting item: {e}")
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'message': 'Could not delete item', 'error': str(e)})
        }


