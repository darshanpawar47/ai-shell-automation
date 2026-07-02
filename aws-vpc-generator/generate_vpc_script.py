from pathlib import Path
import requests

PROMPT_FILE = "prompt.txt"
OUTPUT_FILE = "create_vpc.sh"
OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL = "llama3.2:latest"


def load_prompt():
    """
    Load the base prompt from prompt.txt
    """
    prompt_path = Path(PROMPT_FILE)

    if not prompt_path.exists():
        raise FileNotFoundError(f"{PROMPT_FILE} not found.")

    return prompt_path.read_text(encoding="utf-8")


def collect_user_inputs():
    """
    Collect AWS configuration from the user.
    """

    print("\nEnter AWS Configuration\n")

    region = input("AWS Region [us-east-1]: ").strip() or "us-east-1"
    vpc_cidr = input("VPC CIDR [10.0.0.0/16]: ").strip() or "10.0.0.0/16"
    public_subnet = input("Public Subnet CIDR [10.0.1.0/24]: ").strip() or "10.0.1.0/24"
    private_subnet = input("Private Subnet CIDR [10.0.2.0/24]: ").strip() or "10.0.2.0/24"

    return {
        "region": region,
        "vpc_cidr": vpc_cidr,
        "public_subnet": public_subnet,
        "private_subnet": private_subnet,
    }


def build_final_prompt(base_prompt, config):
    """
    Combine the prompt with user inputs.
    """

    return f"""
{base_prompt}

AWS Configuration

Region: {config['region']}

VPC CIDR: {config['vpc_cidr']}

Public Subnet CIDR: {config['public_subnet']}

Private Subnet CIDR: {config['private_subnet']}

Generate the complete production-ready Bash script.
"""


def generate_script(prompt):
    """
    Send the prompt to Ollama.
    """

    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False
    }

    try:

        response = requests.post(
            OLLAMA_URL,
            json=payload,
            timeout=300
        )

        response.raise_for_status()

        data = response.json()

        return data["response"]

    except requests.exceptions.ConnectionError:
        print("\nCould not connect to Ollama.")
        print("Make sure Ollama is running.")
        return None

    except Exception as e:
        print(f"\nUnexpected Error: {e}")
        return None


def save_script(script):
    """
    Save generated Bash script.
    """

    Path(OUTPUT_FILE).write_text(script, encoding="utf-8")

    print("\nScript saved successfully.")

    print(f"Location: {OUTPUT_FILE}")


def main():

    print("=" * 60)
    print("AI Powered AWS VPC Script Generator")
    print("=" * 60)

    base_prompt = load_prompt()

    config = collect_user_inputs()

    final_prompt = build_final_prompt(base_prompt, config)

    print("\nGenerating Bash script using Ollama...\n")

    script = generate_script(final_prompt)

    if script is None:
        return

    print("=" * 60)
    print("Generated Bash Script")
    print("=" * 60)

    print(script)

    save_script(script)


if __name__ == "__main__":
    main()