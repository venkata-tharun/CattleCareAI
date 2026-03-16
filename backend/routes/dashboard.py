from flask import Blueprint, jsonify, session
from models.db import get_connection
from datetime import date

dashboard_bp = Blueprint("dashboard", __name__, url_prefix="/api/dashboard")

def require_login():
    if "user_id" not in session:
        return jsonify({"error": "Not logged in"}), 401

@dashboard_bp.route("/stats", methods=["GET"])
def get_stats():
    err = require_login()
    if err: return err
    
    uid = session["user_id"]
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            # 1. Total Animals
            cur.execute("SELECT COUNT(*) as count FROM animals WHERE user_id=%s", (uid,))
            total_animals = cur.fetchone()["count"]
            
            # 2. Milk Today (Sum of AM, Noon, PM for today's date)
            today = date.today().strftime('%Y-%m-%d')
            cur.execute(
                "SELECT SUM(am + noon + pm) as total FROM milk_entries WHERE user_id=%s AND date=%s",
                (uid, today)
            )
            milk_today_res = cur.fetchone()["total"]
            milk_today = f"{float(milk_today_res or 0):.1f}L"
            
            # 3. Recent Activity (Latest logs)
            cur.execute(
                "SELECT * FROM farm_logs WHERE user_id=%s ORDER BY date DESC, id DESC LIMIT 5",
                (uid,)
            )
            recent_logs = cur.fetchall()
            for l in recent_logs:
                if l.get("date"): l["date"] = str(l["date"])

    finally:
        conn.close()
        
    return jsonify({
        "totalAnimals": total_animals,
        "milkToday": milk_today,
        "recentLogs": recent_logs
    }), 200
