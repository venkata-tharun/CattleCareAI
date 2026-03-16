import json
from decimal import Decimal

def test_json():
    # Simulate DB rows with Decimal
    rows = [
        {'id': 1, 'name': 'Concentrate', 'quantity': Decimal('150.00'), 'status': 'Low'},
        {'id': 2, 'name': 'Silage', 'quantity': Decimal('100.00'), 'status': 'Low'}
    ]
    
    # Simulate the fix applied
    for r in rows:
        if "quantity" in r:
            r["quantity"] = float(r["quantity"])
    
    try:
        json_out = json.dumps(rows)
        print("✅ JSON Serialization successful")
        print(json_out)
    except Exception as e:
        print(f"❌ JSON Serialization failed: {e}")

if __name__ == "__main__":
    test_json()
