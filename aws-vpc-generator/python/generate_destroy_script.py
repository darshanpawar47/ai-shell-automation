import requests
from pathlib import Path

PROMPT_FILE = "destroy_prompt.txt"
OUTPUT_FILE = "generated_destroy.sh"

OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL = "llama3.2:latest"


def load_prompt():
    """
    Load the prompt from destroy_prompt.txt
    """
    prompt_path = Path(PROMPT_FILE)

    if not prompt_path.exists():
        raise FileNotFoundError(f"{PROMPT_FILE} not found.")

    return prompt_path.read_text(encoding="utf-8")


def generate_script(prompt):
    """
    Send prompt to Ollama and return generated script.
    """

    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False
    }

    response = requests.post(OLLAMA_URL, json=payload)

    response.raise_for_status()

    data = response.json()

    return data["response"]


def save_script(script):
    """
    Save generated script.
    """

    Path(OUTPUT_FILE).write_text(script, encoding="utf-8")


def main():

    print("=" * 60)
    print("AI Destroy Script Generator")
    print("=" * 60)

    prompt = load_prompt()

    print("\nGenerating Bash script using Ollama...\n")

    script = generate_script(prompt)

    save_script(script)

    print("=" * 60)
    print("SUCCESS")
    print("=" * 60)

    print(f"Generated script saved as: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()