#!/usr/bin/env python3
"""Write embedded lyrics to .lrc sidecar files next to audio files."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import mutagen

AUDIO_EXTENSIONS = {
    ".aac",
    ".aif",
    ".aiff",
    ".ape",
    ".flac",
    ".m4a",
    ".mp3",
    ".mp4",
    ".mpc",
    ".oga",
    ".ogg",
    ".opus",
    ".wav",
    ".wma",
    ".wv",
}

LYRIC_KEYS = {
    "lyrics",
    "lyric",
    "unsyncedlyrics",
    "unsynced lyrics",
    "unsynced_lyrics",
    "\xa9lyr",
    "wm/lyrics",
}


def as_text(value: object) -> str:
    if isinstance(value, (list, tuple)):
        return "\n".join(str(part) for part in value)
    return "" if value is None else str(value)


def extract_lyrics(path: Path) -> str | None:
    try:
        audio = mutagen.File(path)
    except Exception as exc:
        raise RuntimeError(f"cannot read metadata: {exc}") from exc

    if audio is None or audio.tags is None:
        return None

    tags = audio.tags
    getall = getattr(tags, "getall", None)

    if callable(getall):
        try:
            frames = getall("USLT")
        except (KeyError, ValueError):
            frames = []
        for frame in frames:
            text = as_text(getattr(frame, "text", None))
            if text.strip():
                return text

    try:
        items = tags.items()
    except AttributeError:
        items = []
    for key, value in items:
        if str(key).strip().lower() in LYRIC_KEYS:
            text = as_text(value)
            if text.strip():
                return text

    if callable(getall):
        try:
            frames = getall("TXXX")
        except (KeyError, ValueError):
            frames = []
        for frame in frames:
            if "lyric" in str(getattr(frame, "desc", "")).lower():
                text = as_text(getattr(frame, "text", None))
                if text.strip():
                    return text

    return None


def find_lrc(path: Path) -> Path | None:
    lrc_path = path.with_suffix(".lrc")
    if lrc_path.exists():
        return lrc_path

    try:
        for entry in path.parent.iterdir():
            if entry.is_file() and entry.stem == path.stem and entry.suffix.lower() == ".lrc":
                return entry
    except OSError:
        pass

    return None


def audio_files(directory: Path, recursive: bool):
    entries = directory.rglob("*") if recursive else directory.glob("*")
    for entry in sorted(entries):
        if entry.is_file() and entry.suffix.lower() in AUDIO_EXTENSIONS:
            yield entry


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Write embedded song lyrics to .lrc files next to audio files.",
    )
    parser.add_argument("directory", type=Path, help="directory containing audio files")
    parser.add_argument(
        "-r",
        "--recursive",
        action="store_true",
        help="also process subdirectories",
    )
    args = parser.parse_args(argv)

    if not args.directory.is_dir():
        parser.error(f"not a directory: {args.directory}")

    written = skipped = missing = failed = 0

    for audio_path in audio_files(args.directory, args.recursive):
        if find_lrc(audio_path):
            skipped += 1
            continue

        try:
            lyrics = extract_lyrics(audio_path)
        except RuntimeError as exc:
            print(f"error: {audio_path}: {exc}", file=sys.stderr)
            failed += 1
            continue

        if not lyrics or not lyrics.strip():
            missing += 1
            continue

        lrc_path = audio_path.with_suffix(".lrc")
        try:
            lrc_path.write_text(lyrics.rstrip("\r\n") + "\n", encoding="utf-8")
        except OSError as exc:
            print(f"error: {audio_path}: {exc}", file=sys.stderr)
            failed += 1
            continue

        print(f"wrote {lrc_path}")
        written += 1

    print(
        f"done: {written} written, {skipped} already had .lrc, "
        f"{missing} without lyrics, {failed} failed",
        file=sys.stderr if failed else sys.stdout,
    )
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
