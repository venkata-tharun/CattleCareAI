from flask import Blueprint, request, jsonify, session
from models.db import get_connection

feed_bp = Blueprint("feed", __name__, url_prefix="/api/feed")


def require_login():
    if "user_id" not in session:
        return jsonify({"error": "Not logged in"}), 401


@feed_bp.route("/stock", methods=["GET"])
def list_stock():
    err = require_login()
    if err:
        return err
    uid = session["user_id"]
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM feed_stock WHERE user_id=%s ORDER BY name", (uid,))
            rows = cur.fetchall()
            for r in rows:
                if "quantity" in r:
                    r["quantity"] = float(r["quantity"])
    finally:
        conn.close()
    return jsonify(rows), 200


@feed_bp.route("/stock", methods=["POST"])
def add_or_update_stock():
    """Add stock to an existing item or create it."""
    err = require_login()
    if err:
        print(f"DEBUG STOCK: require_login failed")
        return err
    uid  = session["user_id"]
    data = request.get_json()
    name     = data.get("name", data.get("itemName", "")).strip()
    qty_add  = float(data.get("amountAdded", data.get("amount_added", 0)))
    
    print(f"DEBUG STOCK: User {uid} attempting to add {qty_add} to '{name}'")

    if not name:
        print(f"DEBUG STOCK: Item name is empty")
        return jsonify({"error": "name required"}), 400

    conn = get_connection()
    try:
        with conn.cursor() as cur:
            # Check if item exists for this user
            cur.execute("SELECT id, quantity FROM feed_stock WHERE user_id=%s AND name=%s", (uid, name))
            row = cur.fetchone()
            if row:
                new_qty = float(row["quantity"]) + qty_add
                status  = "Good" if new_qty >= 1000 else ("Medium" if new_qty >= 200 else "Low")
                cur.execute(
                    "UPDATE feed_stock SET quantity=%s, status=%s WHERE id=%s",
                    (new_qty, status, row["id"])
                )
                print(f"DEBUG STOCK: Updated existing item {row['id']} to {new_qty}")
            else:
                status = "Good" if qty_add >= 1000 else ("Medium" if qty_add >= 200 else "Low")
                cur.execute(
                    "INSERT INTO feed_stock (user_id, name, quantity, status) VALUES (%s,%s,%s,%s)",
                    (uid, name, qty_add, status)
                )
                print(f"DEBUG STOCK: Inserted new item '{name}' with {qty_add}")

            # Log activity
            cur.execute(
                "INSERT INTO feed_activity (user_id, item_name, amount_added) VALUES (%s,%s,%s)",
                (uid, name, qty_add)
            )
            affected = cur.rowcount
            conn.commit()
            print(f"DEBUG STOCK: Transaction committed. Affected rows: {affected}")
    except Exception as e:
        print(f"DEBUG STOCK ERROR: {str(e)}")
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()
    return jsonify({"message": "Stock updated"}), 200


@feed_bp.route("/activity", methods=["GET"])
def list_activity():
    err = require_login()
    if err:
        return err
    uid = session["user_id"]
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM feed_activity WHERE user_id=%s ORDER BY date DESC LIMIT 50", (uid,))
            rows = cur.fetchall()
            for r in rows:
                if r.get("date"):
                    r["date"] = str(r["date"])
                if "amount_added" in r:
                    r["amountAdded"] = float(r.pop("amount_added"))
                else:
                    r["amountAdded"] = float(r.get("amountAdded", 0))
                r["itemName"] = r.pop("item_name", r.get("itemName", ""))
    finally:
        conn.close()
    return jsonify(rows), 200


@feed_bp.route("/entries", methods=["POST"])
def add_feed_entry():
    """Record a feeding event."""
    err = require_login()
    if err:
        return err
    uid  = session["user_id"]
    data = request.get_json()
    date      = data.get("date", "").strip()
    feed_time = data.get("feedTime", data.get("feed_time", "")).strip()
    feed_type = data.get("feedType", data.get("feed_type", "")).strip()
    quantity  = float(data.get("quantity", 0))
    notes     = data.get("notes", "")

    if not date:
        return jsonify({"error": "date required"}), 400

    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO feed_entries (user_id, date, feed_time, feed_type, quantity, notes) VALUES (%s,%s,%s,%s,%s,%s)",
                (uid, date, feed_time, feed_type, quantity, notes)
            )
            conn.commit()
            eid = cur.lastrowid
    finally:
        conn.close()
    return jsonify({"id": eid, "message": "Feeding entry saved"}), 201


@feed_bp.route("/entries", methods=["GET"])
def list_feed_entries():
    err = require_login()
    if err:
        return err
    uid = session["user_id"]
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT * FROM feed_entries WHERE user_id=%s ORDER BY date DESC, id DESC LIMIT 50",
                (uid,)
            )
            rows = cur.fetchall()
            for r in rows:
                if r.get("date"):
                    r["date"] = str(r["date"])
                r["feedTime"] = r.pop("feed_time", "")
                r["feedType"] = r.pop("feed_type", "")
    finally:
        conn.close()
    return jsonify(rows), 200
