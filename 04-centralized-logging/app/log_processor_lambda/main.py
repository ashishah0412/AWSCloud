import json
import base64
import gzip

def handler(event, context):
    output = []

    for record in event["Records"]:
        # Kinesis Firehose delivers base64 encoded and gzipped data
        payload = base64.b64decode(record["data"])
        decompressed_payload = gzip.decompress(payload)
        data = json.loads(decompressed_payload)

        # CloudWatch Logs data format is a bit nested
        # The actual log events are in data["logEvents"]
        for log_event in data["logEvents"]:
            # Example: Add a new field to each log event
            log_event["processed_by_lambda"] = True
            log_event["source_log_group"] = data["logGroup"]
            log_event["source_log_stream"] = data["logStream"]

            # You can add more complex logic here, e.g., parsing log messages,
            # enriching with external data, filtering sensitive info, etc.

            output.append({
                "data": base64.b64encode(json.dumps(log_event).encode("utf-8")).decode("utf-8"),
                "result": "Ok",
                "recordId": record["recordId"]
            })

    print(f"Successfully processed {len(output)} records.")
    return {"records": output}


