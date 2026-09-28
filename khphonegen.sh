#!/usr/bin/env bash

set -o pipefail
# Prefix
declare -A SMART=( [010]=6 [015]=6 [016]=6 [069]=6 [070]=6 [081]=6 [086]=6 [087]=6 [093]=6 [098]=6 [096]=7 )
declare -A CELLCARD=( [011]=6 [012]=6 [017]=6 [061]=6 [076]=7 [077]=6 [078]=6 [079]=6 [085]=6 [089]=6 [092]=6 [095]=6 [099]=6 )
declare -A METFONE=( [031]=7 [060]=6 [066]=6 [067]=6 [068]=6 [071]=7 [088]=7 [090]=6 [097]=7 )
declare -A QB=( [013]=6 [080]=6 [083]=6 [084]=6 )
declare -A COOLTEL=( [038]=7 )
declare -A SEATEL=( [018]=7 )

CARRIER="all"
OUTDIR="."
USE_INTL=0

cleanup() {
    printf "\n\n[!] Script interrupted by user. Exiting cleanly.\n" >&2
    exit 130
}
trap cleanup SIGINT SIGTERM

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Khmer Mobile Number Wordlist Generator in Bash.

Options:
  -c, --carrier CARRIER   Target operator: smart, cellcard, metfone, qb, cooltel, seatel, all (default: all)
  -o, --outdir DIR        Directory to save wordlists (default: .)
  -i, --intl              Use international +855 format instead of leading 0
  -h, --help              Show this help menu and exit

Supported Operators & Prefixes:
  smart     : 010, 015, 016, 069, 070, 081, 086, 087, 093, 098, 096 (7 digits)
  cellcard  : 011, 012, 017, 061, 076 (7 digits), 077, 078, 079, 085, 089, 092, 095, 099
  metfone   : 031 (7 digits), 060, 066, 067, 068, 071 (7 digits), 088 (7 digits), 090, 097 (7 digits)
  qb        : 013, 080, 083, 084
  cooltel   : 038 (7 digits)
  seatel    : 018 (7 digits)

Examples:
  $(basename "$0") -c smart
  $(basename "$0") -c cellcard -i -o ./output
  $(basename "$0") --carrier all
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--carrier)
            CARRIER="${2,,}"
            shift 2
            ;;
        -o|--outdir)
            OUTDIR="$2"
            shift 2
            ;;
        -i|--intl)
            USE_INTL=1
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "[!] Unknown option: $1" >&2
            show_help
            exit 1
            ;;
    esac
done

mkdir -p "$OUTDIR"

generate_carrier() {
    local name="$1"
    local -n prefix_map="$2"
    local outfile="${OUTDIR}/${name}_wordlist.txt"

    echo "[*] Generating: $name -> $outfile"
    > "$outfile"

    for prefix in "${!prefix_map[@]}"; do
        local len="${prefix_map[$prefix]}"
        local max=$(( 10**len - 1 ))
        local pfx="$prefix"

        if [[ "$USE_INTL" -eq 1 ]]; then
            pfx="+855${prefix#0}"
        fi

        printf "  -> Prefix %s (%d digits, %'d numbers)...\n" "$prefix" "$len" "$((max + 1))"
        seq -f "${pfx}%0${len}.0f" 0 "$max" >> "$outfile"
    done

    echo "[+] Finished $name ($(wc -l < "$outfile") numbers written)."
}

case "$CARRIER" in
    smart)
        generate_carrier "smart" SMART
        ;;
    cellcard)
        generate_carrier "cellcard" CELLCARD
        ;;
    metfone)
        generate_carrier "metfone" METFONE
        ;;
    qb)
        generate_carrier "qb" QB
        ;;
    cooltel)
        generate_carrier "cooltel" COOLTEL
        ;;
    seatel)
        generate_carrier "seatel" SEATEL
        ;;
    all)
        generate_carrier "smart" SMART
        generate_carrier "cellcard" CELLCARD
        generate_carrier "metfone" METFONE
        generate_carrier "qb" QB
        generate_carrier "cooltel" COOLTEL
        generate_carrier "seatel" SEATEL
        ;;
    *)
        echo "[!] Invalid carrier specified: $CARRIER" >&2
        show_help
        exit 1
        ;;
esac

echo "[+] Done."
