#!/usr/bin/env bash
# ==============================================================================
# AI Vision Studio - Model Weight Download Script (SIH PS 26090)
# Pre-downloads and verifies ONNX model weights (u2net and u2netp) for 100% offline use.
# ==============================================================================

set -euo pipefail

echo "========================================================================"
echo "AI Vision Studio: Pre-downloading ONNX Model Weights for Offline Inference"
echo "========================================================================"

python -c "
import sys
from rembg import new_session

print('[1/2] Pre-downloading & initializing u2net (Balanced / High quality profile)...')
try:
    s1 = new_session(model_name='u2net', providers=['CPUExecutionProvider'])
    print('      u2net ready.')
except Exception as e:
    print(f'      Failed to initialize u2net: {e}', file=sys.stderr)
    sys.exit(1)

print('[2/2] Pre-downloading & initializing u2netp (Fast quality profile)...')
try:
    s2 = new_session(model_name='u2netp', providers=['CPUExecutionProvider'])
    print('      u2netp ready.')
except Exception as e:
    print(f'      Failed to initialize u2netp: {e}', file=sys.stderr)
    sys.exit(1)

print('------------------------------------------------------------------------')
print('SUCCESS: All required ONNX model weights are cached for offline operation.')
print('========================================================================')
"
