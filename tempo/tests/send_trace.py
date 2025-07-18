"""
Run with the following command from the terraform project root once resources have been applied:

```sh
docker run --rm --network=hosting_network -v "$(pwd)":/app -w /app python:3.9-slim sh -c "pip install -q requests && python tests/send_trace.py"
```
"""

import requests
import time
import secrets
import os

def generate_hex_id(byte_length):
    return secrets.token_hex(byte_length)

def send_test_trace():
    tempo_host = os.environ.get("TEMPO_HOST", "tempo_container")
    trace_id = generate_hex_id(16)
    span_id = generate_hex_id(8)
    start_time = int(time.time() * 1e9)
    end_time = start_time + 1_000_000_000  # 1 second later

    payload = {
        "resource_spans": [
            {
                "resource": {
                    "attributes": [
                        {
                            "key": "service.name",
                            "value": {"stringValue": "manual-test-script"},
                        }
                    ]
                },
                "instrumentation_library_spans": [
                    {
                        "spans": [
                            {
                                "trace_id": trace_id,
                                "span_id": span_id,
                                "name": "manual-verification.span",
                                "kind": "SPAN_KIND_INTERNAL",
                                "start_time_unix_nano": str(start_time),
                                "end_time_unix_nano": str(end_time),
                                "attributes": [
                                    {
                                        "key": "test.run.id",
                                        "value": {"stringValue": generate_hex_id(4)},
                                    }
                                ],
                            }
                        ]
                    }
                ],
            }
        ]
    }

    url = f"http://{tempo_host}:4318/v1/traces"
    try:
        response = requests.post(
            url, json=payload, headers={"Content-Type": "application/json"}
        )
        response.raise_for_status()
        print(f"Trace sent successfully!\nTrace ID: {trace_id}")
        print(f"Find it in Grafana by searching for this Trace ID.")
    except requests.exceptions.RequestException as e:
        print(f"Error sending trace to {url}: {e}")


if __name__ == "__main__":
    send_test_trace()
