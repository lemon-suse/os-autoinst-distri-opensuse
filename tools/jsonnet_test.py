import _jsonnet
import json
import sys

def process_jsonnet_snippet(jsonnet_code):
    """Evaluates a Jsonnet code snippet."""
    try:
        json_str = _jsonnet.evaluate_snippet("snippet", jsonnet_code)
        return json.loads(json_str)
    except RuntimeError as e:
        print(f"Error evaluating Jsonnet: {e}", file=sys.stderr)
        return None

def process_jsonnet_file(filename):
    """Evaluates a Jsonnet file."""
    try:
        json_str = _jsonnet.evaluate_file(filename)
        return json.loads(json_str)
    except RuntimeError as e:
        print(f"Error evaluating Jsonnet file {filename}: {e}", file=sys.stderr)
        return None

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 run_jsonnet.py <jsonnet_file_or_snippet> [--snippet]", file=sys.stderr)
        sys.exit(1)

    jsonnet_input = sys.argv[1]
    is_snippet = False

    if len(sys.argv) > 2 and sys.argv[2] == "--snippet":
        is_snippet = True

    if is_snippet:
        result = process_jsonnet_snippet(jsonnet_input)
    else:
        result = process_jsonnet_file(jsonnet_input)

    if result:
        print(json.dumps(result, indent=2))
