#!/usr/bin/env python3
"""Helper script used by the vim Concise rewrite plugin."""

from __future__ import annotations

import argparse
import json
import os
import sys
import textwrap
import urllib.error
import urllib.request


def build_prompt(ratio: float) -> str:
    target = int(ratio * 100)
    return textwrap.dedent(
        f"""
        Rewrite the provided text so it is roughly {target}% of the original length (25-30% shorter).
        Keep the tone neutral and ensure the meaning stays intact.
        Return only the revised text without commentary or code fences.
        """
    ).strip()


def call_openai(*, api_key: str, endpoint: str, model: str, prompt: str, text: str) -> str:
    payload = {
        "model": model,
        "messages": [
            {
                "role": "system",
                "content": "You are a concise editor that trims redundant words without losing nuance.",
            },
            {
                "role": "user",
                "content": f"{prompt}\n\n---\n{text.strip()}\n---",
            },
        ],
        "temperature": 0.2,
    }
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        endpoint,
        data=data,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            body = resp.read().decode("utf-8")
    except urllib.error.HTTPError as exc:
        error_body = exc.read().decode("utf-8", errors="ignore")
        raise RuntimeError(f"OpenAI API error {exc.code}: {error_body}") from exc
    except urllib.error.URLError as exc:
        raise RuntimeError(f"Failed to reach OpenAI API: {exc}") from exc

    document = json.loads(body)
    try:
        message = document["choices"][0]["message"]["content"]
    except (KeyError, IndexError, TypeError) as exc:
        raise RuntimeError(f"Unexpected API response: {body}") from exc
    return message.strip()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Shorten text with OpenAI")
    parser.add_argument(
        "--model",
        default=os.environ.get("CONCISE_OPENAI_MODEL", "gpt-4o-mini"),
        help="OpenAI model name",
    )
    parser.add_argument(
        "--endpoint",
        default=os.environ.get("CONCISE_OPENAI_ENDPOINT", "https://api.openai.com/v1/chat/completions"),
        help="OpenAI API endpoint",
    )
    parser.add_argument(
        "--ratio",
        type=float,
        default=0.75,
        help="Target length ratio relative to the original text",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    api_key = os.environ.get("OPEN_AI_KEY")
    if not api_key:
        raise SystemExit("OPEN_AI_KEY is not set")

    source_text = sys.stdin.read().strip()
    if not source_text:
        raise SystemExit("No input text received")

    prompt = build_prompt(args.ratio)
    revised = call_openai(
        api_key=api_key,
        endpoint=args.endpoint,
        model=args.model,
        prompt=prompt,
        text=source_text,
    )
    sys.stdout.write(revised)


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:  # pragma: no cover
        print(str(exc), file=sys.stderr)
        sys.exit(1)
