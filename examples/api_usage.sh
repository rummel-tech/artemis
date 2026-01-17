#!/bin/bash
# Example usage script for Artemis Personal OS API

BASE_URL="http://localhost:8000"

echo "=== Artemis Personal OS API Examples ==="
echo

echo "1. Check API Health"
curl -s "$BASE_URL/health" | python -m json.tool
echo

echo "2. List All Modules"
curl -s "$BASE_URL/modules" | python -m json.tool
echo

echo "3. Get All Modules Status"
curl -s "$BASE_URL/modules/status" | python -m json.tool
echo

echo "4. Create a Work Task"
curl -s -X POST "$BASE_URL/modules/work/action" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "create_task",
    "data": {
      "title": "Complete project documentation",
      "description": "Write comprehensive docs for the new feature",
      "priority": "high"
    }
  }' | python -m json.tool
echo

echo "5. Log a Fitness Workout"
curl -s -X POST "$BASE_URL/modules/fitness/action" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "log_workout",
    "data": {
      "type": "Running",
      "duration_minutes": 30,
      "distance_km": 5.0,
      "date": "2026-01-17"
    }
  }' | python -m json.tool
echo

echo "=== Examples Complete ==="
