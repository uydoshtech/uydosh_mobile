#!/usr/bin/env python3
"""
Extract localization strings from app_strings.dart and generate ARB files.
Run with: python3 scripts/extract_strings_to_arb.py
"""
import re
import json
from pathlib import Path


def extract_lang_map(content: str, lang: str) -> dict[str, str]:
    """Extract a language map from the Dart file."""
    # Find the lang block
    pattern = rf'"{lang}":\s*\{{'
    match = re.search(pattern, content)
    if not match:
        return {}

    start = match.end() - 1  # Include the {
    depth = 1
    i = start + 1

    while i < len(content) and depth > 0:
        if content[i] == '{':
            depth += 1
        elif content[i] == '}':
            depth -= 1
        i += 1

    block = content[start:i]

    # Parse key-value pairs
    result = {}
    # Match "key": "value" or "key": """value"""
    key_pattern = r'"([a-zA-Z0-9_]+)":\s*'
    pos = 0

    while True:
        key_match = re.search(key_pattern, block[pos:])
        if not key_match:
            break

        key = key_match.group(1)
        value_start = key_match.end() + pos

        # Skip comments
        while value_start < len(block) and block[value_start].isspace():
            value_start += 1
        pos = value_start

        if value_start >= len(block):
            break

        # Handle """multiline""" or "single"
        if block[value_start:value_start + 3] == '"""':
            # Multiline string
            end_marker = '"""'
            value_start += 3
            end_pos = block.find(end_marker, value_start)
            if end_pos == -1:
                break
            value = block[value_start:end_pos]
            pos = end_pos + 3
        else:
            # Single-line string
            if block[value_start] != '"':
                break
            value_start += 1
            value = ""
            i = value_start
            while i < len(block):
                if block[i] == '\\':
                    i += 1
                    if i < len(block):
                        if block[i] == 'n':
                            value += '\n'
                        elif block[i] == 't':
                            value += '\t'
                        elif block[i] == '"':
                            value += '"'
                        else:
                            value += block[i]
                        i += 1
                elif block[i] == '"':
                    break
                else:
                    value += block[i]
                    i += 1
            pos = i + 1

        # Fix invalid ARB keys (e.g. "loading..." -> "loadingEllipsis")
        arb_key = key
        if arb_key == "loading...":
            arb_key = "loadingEllipsis"

        result[arb_key] = value

    return result


def get_placeholders(text: str) -> dict[str, dict]:
    """Extract placeholders from a string for ARB @metadata."""
    placeholders = re.findall(r'\{([a-zA-Z_][a-zA-Z0-9_]*)\}', text)
    return {p: {"type": "String", "example": p} for p in placeholders}


def to_arb_string(s: str) -> str:
    """Escape string for JSON."""
    return json.dumps(s)[1:-1]  # Remove outer quotes


def main():
    project_root = Path(__file__).parent.parent
    app_strings_path = project_root / "lib" / "base" / "constants" / "app_strings.dart"
    l10n_dir = project_root / "l10n"

    content = app_strings_path.read_text(encoding="utf-8")

    for lang in ["en", "ru", "uz"]:
        strings = extract_lang_map(content, lang)
        if not strings:
            print(f"Warning: No strings found for {lang}")
            continue

        arb = {}
        if lang == "en":
            arb["@@locale"] = "en"
        else:
            arb["@@locale"] = lang

        for key, value in strings.items():
            arb[key] = value
            # Add placeholder metadata for strings with {param}
            placeholders = get_placeholders(value)
            if placeholders:
                arb[f"@{key}"] = {"placeholders": placeholders}

        arb_path = l10n_dir / f"app_{lang}.arb"
        arb_path.parent.mkdir(parents=True, exist_ok=True)

        with open(arb_path, "w", encoding="utf-8") as f:
            json.dump(arb, f, ensure_ascii=False, indent=2)

        print(f"Generated {arb_path} with {len(strings)} strings")


if __name__ == "__main__":
    main()
