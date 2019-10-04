import json
import random

def lambda_handler(event, context):
    print(json.dumps(event))

    return {
      "statusCode": 200,
      "body": json.dumps({
        "luckyNumber": random.randint(0,100)
      })
    }

if __name__ == '__main__':
    main()
