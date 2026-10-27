#!/usr/bin/env bash
# ref-section.sh — print one section of a reference file: the load a core
# pointer of the form `references/x.md` ("Heading") asks for.
#
# Usage:
#   bash scripts/ref-section.sh <file> "<heading>"
#
#   <file>     a reference file: a path that exists is used as given (a
#              bridged copy run from .bin/ passes the full path); otherwise
#              its last segment resolves to references/ beside this
#              script's directory, so a bare name and a pointer's
#              `references/x.md` both work from any directory. The path may
#              contain spaces.
#   <heading>  the heading text as written after its `#` marks, backticks
#              dropped: inside double quotes the shell runs a backticked word.
#
# The heading matches as the bundle check matches a pointer: the whole text,
# or the text up to its ` — ` qualifier, whitespace runs read as one space,
# backticks ignored on both sides. A fence closes only on its own character,
# at least as long, as in the bundle check: a looser rule cuts a section short.
#
# Prints the heading line and everything under it up to the next heading of
# the same or a higher level, child headings included. Lines inside fenced
# code blocks are never headings. Bold text that reads like a heading is
# not one, so such a section runs on to the next real heading: a read can
# come out longer than the episode, never shorter.
#
# Exit status:
#   0  the section was printed
#   1  NO SECTION — no heading has that text; AMBIGUOUS — more than one
#      does. Nothing of the file is printed: a guessed section is a rule
#      silently skipped. Load the whole file instead and say why
#   2  refused: missing arguments, or the file does not exist
#
# Why a script: a reader that loads a whole reference to use one section
# pays for every other section in every session, and a model finding the
# section's end by eye stops short at the first child heading or a fenced
# `##` line. This is the boundary rule, once.
#
# bash 3.2-compatible (stock macOS).

set -u

file="${1:-}"
heading="${2:-}"

if [ -z "$file" ] || [ -z "$heading" ]; then
  echo "usage: bash ref-section.sh <file> \"<heading>\"" >&2; exit 2
fi
[ -f "$file" ] || file="$(cd "$(dirname "$0")/.." && pwd)/references/${file##*/}"
[ -f "$file" ] || { echo "no such reference file: $file — pass its full path, or load the whole file" >&2; exit 2; }

# One awk program, two modes: count the headings that match, or print the
# section. Both read headings the same way, so the count is the print's guard.
section() {
  want="$heading" LC_ALL=C awk -v mode="$1" '
    function norm(s) {gsub(/`/, "", s); gsub(/[ \t\r\n]+/, " ", s); sub(/^ /, "", s); sub(/ $/, "", s); return s}
    BEGIN {want = norm(ENVIRON["want"])}
    {line = $0; sub(/\r$/, "", line)}
    fence != "" {t = line; gsub(/[ \t]/, "", t)
      if (substr(t, 1, 1) == substr(fence, 1, 1) && length(t) >= length(fence) && t ~ /^(```+|~~~+)$/) fence = ""
      if (on) print; next}
    match(line, /^[ \t]*(```+|~~~+)/) {fence = substr(line, RSTART, RLENGTH); gsub(/[ \t]/, "", fence); if (on) print; next}
    line ~ /^#+[ \t]/ {
      hashes = line; sub(/[ \t].*/, "", hashes); level = length(hashes)
      text = norm(substr(line, level + 1))
      if (on && level <= lvl) exit
      if (text == want || index(text, want " — ") == 1) {n++; if (mode == "print") {on = 1; lvl = level}}
    }
    on
    END {if (mode == "count") print n + 0}' "$file"
}

hits=$(section count)
case "$hits" in (''|*[!0-9]*) echo "COUNT FAILED — the heading count did not run; load the whole file" >&2; exit 2 ;; esac
if [ "$hits" -eq 0 ]; then
  echo "NO SECTION — no heading reads \"$heading\" in $file; load the whole file and say why" >&2; exit 1
fi
if [ "$hits" -gt 1 ]; then
  echo "AMBIGUOUS — $hits headings read \"$heading\" in $file; load the whole file and say why" >&2; exit 1
fi
section print
