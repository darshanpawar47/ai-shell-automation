import requests

# Ollama Configuration
OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL = "llama3.2:latest"


def read_log_file(file_path):
    """
    Read the contents of a log file.
    """
    try:
        with open(file_path, "r", encoding="utf-8") as file:
            return file.read()
    except FileNotFoundError:
        print(f"❌ Log file '{file_path}' not found.")
        return None


def build_prompt(log_data):
    """
    Build the AI prompt for log analysis.
    """
    prompt = f"""
You are a Principal Site Reliability Engineer (SRE).

Analyze the following Linux application logs.

Return your response in the following format.

==================================================
AI LOG ANALYSIS REPORT
==================================================

Summary

Errors

Warnings

Root Cause

Recommended Fixes

Preventive Actions

Severity (Low/Medium/High)

==================================================

Logs:

{log_data}

Rules:
- Return plain text only.
- Do not use markdown.
- Keep the report concise.
"""

    return prompt


def analyze_logs(prompt):
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
            timeout=120
        )

        response.raise_for_status()

        result = response.json()

        return result.get("response", "No response received.")

    except requests.exceptions.ConnectionError:
        return "❌ Could not connect to Ollama."

    except requests.exceptions.Timeout:
        return "❌ Ollama request timed out."

    except Exception as error:
        return f"❌ Error: {error}"


def save_report(report):
    """
    Save AI analysis to a text file.
    """
    with open("analysis_report.txt", "w", encoding="utf-8") as file:
        file.write(report)

    print("\n✅ Analysis saved as analysis_report.txt")


def main():

    print("=" * 60)
    print(" AI Log Analyzer using Ollama")
    print("=" * 60)

    log_data = read_log_file("sample.log")

    if log_data is None:
        return

    print("\n⏳ Sending logs to Ollama...\n")

    prompt = build_prompt(log_data)

    report = analyze_logs(prompt)

    print("=" * 60)
    print(report)
    print("=" * 60)

    save_report(report)

    print("\n🎉 Log analysis completed successfully.")


if __name__ == "__main__":
    main()