#!/usr/bin/env python3
"""Entry point for the Artemis backend server."""

import uvicorn
from src.artemis.api import create_app

app = create_app()

if __name__ == "__main__":
    uvicorn.run(
        "run_server:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
    )
