import sys
from pathlib import Path

# Make the repository root importable when pytest is launched directly.
# This keeps tests able to import the local `app` package without installing it first.
PROJECT_ROOT = Path(__file__).resolve().parents[1]

if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))
