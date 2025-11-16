#!/bin/bash
# Coverage report generator for SDK modules

set -e

MODULE=${1:-"//sdk/..."}
OUTPUT_DIR=${2:-"coverage_html"}

echo "====== Collecting coverage for $MODULE ======"
bazel coverage "$MODULE" \
    --combined_report=lcov \
    --instrumentation_filter="//sdk/...[/:]"

echo ""
echo "====== Generating HTML report ======"
genhtml bazel-out/_coverage/_coverage_report.dat \
    -o "$OUTPUT_DIR" \
    --title "SDK Coverage Report"

echo ""
echo "====== Coverage report generated ======"
echo "Report location: $OUTPUT_DIR/index.html"
echo ""
echo "To view the report:"
echo "  explorer.exe $OUTPUT_DIR/index.html"
echo "  or open: file://$(pwd)/$OUTPUT_DIR/index.html"
