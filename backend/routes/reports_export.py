from flask import Blueprint, request, jsonify, session, send_file, current_app
from models.db import get_connection
import os
import tempfile
from datetime import datetime, date

reports_export_bp = Blueprint("reports_export", __name__, url_prefix="/api/reports")

def require_login():
    if "user_id" not in session:
        return jsonify({"error": "Not logged in"}), 401

def safe_str(val):
    """Convert date/datetime objects to string safely."""
    if val is None:
        return ""
    if isinstance(val, (date, datetime)):
        return str(val)
    return val

# ── JSON Data Endpoint (used by iOS app to get real data for PDF generation) ────
@reports_export_bp.route("/data/<report_type>", methods=["GET"])
def get_report_data(report_type):
    """Return raw JSON data for the report type. Used by iOS to render PDFs."""
    err = require_login()
    if err: return err

    uid = session["user_id"]
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            if report_type == "milk":
                cur.execute(
                    "SELECT * FROM milk_entries WHERE user_id=%s ORDER BY date DESC",
                    (uid,)
                )
                rows = cur.fetchall()
                for r in rows:
                    r["date"] = safe_str(r.get("date"))
                    r["milk_type"] = r.get("milk_type", "Bulk Milk")
                    r["am"] = float(r.get("am") or 0)
                    r["noon"] = float(r.get("noon") or 0)
                    r["pm"] = float(r.get("pm") or 0)
                    r["total_used"] = float(r.get("total_used") or 0)
                    r["cow_milked_number"] = int(r.get("cow_milked_number") or 0)

            elif report_type == "animals":
                cur.execute("SELECT * FROM animals WHERE user_id=%s ORDER BY name", (uid,))
                rows = cur.fetchall()
                for r in rows:
                    r["created_at"] = safe_str(r.get("created_at"))

            elif report_type == "finance" or report_type == "transactions":
                cur.execute(
                    "SELECT * FROM transactions WHERE user_id=%s ORDER BY date DESC",
                    (uid,)
                )
                rows = cur.fetchall()
                for r in rows:
                    r["date"] = safe_str(r.get("date"))
                    r["amount"] = float(r.get("amount") or 0)
                    r["receipt_no"] = r.get("receipt_no", "")

            elif report_type == "feeding" or report_type == "feed":
                # Get both stock and recent activity
                cur.execute("SELECT * FROM feed_stock WHERE user_id=%s ORDER BY name", (uid,))
                stock = cur.fetchall()
                for r in stock:
                    r["quantity"] = float(r.get("quantity") or 0)
                    r["created_at"] = safe_str(r.get("created_at"))

                cur.execute(
                    "SELECT * FROM feed_activity WHERE user_id=%s ORDER BY date DESC LIMIT 50",
                    (uid,)
                )
                activity = cur.fetchall()
                for r in activity:
                    r["date"] = safe_str(r.get("date"))
                    r["amount_added"] = float(r.get("amount_added") or 0)

                return jsonify({"stock": stock, "activity": activity}), 200

            elif report_type == "visitors":
                cur.execute(
                    "SELECT * FROM visitors WHERE user_id=%s ORDER BY date DESC",
                    (uid,)
                )
                rows = cur.fetchall()
                for r in rows:
                    r["date"] = safe_str(r.get("date"))
                    r["entry_time"] = safe_str(r.get("entry_time"))
                    r["outgoing_time"] = safe_str(r.get("outgoing_time"))

            elif report_type == "ai" or report_type == "health":
                cur.execute(
                    "SELECT * FROM ai_predictions WHERE user_id=%s ORDER BY created_at DESC",
                    (uid,)
                )
                rows = cur.fetchall()
                for r in rows:
                    r["created_at"] = safe_str(r.get("created_at"))

            elif report_type == "logs":
                cur.execute(
                    "SELECT * FROM farm_logs WHERE user_id=%s ORDER BY date DESC",
                    (uid,)
                )
                rows = cur.fetchall()
                for r in rows:
                    r["date"] = safe_str(r.get("date"))

            else:
                return jsonify({"error": f"Unknown report type: {report_type}"}), 400

    finally:
        conn.close()

    return jsonify(rows), 200


# ── PDF Export Endpoint (requires wkhtmltopdf installed) ───────────────────────
@reports_export_bp.route("/export/<report_type>", methods=["GET"])
def export_report(report_type):
    err = require_login()
    if err: return err

    uid = session["user_id"]
    conn = get_connection()
    data = []
    html_content = ""

    try:
        with conn.cursor() as cur:
            if report_type == "milk":
                cur.execute("SELECT * FROM milk_entries WHERE user_id=%s ORDER BY date DESC", (uid,))
                data = cur.fetchall()
                for r in data:
                    r["date"] = safe_str(r.get("date"))
                html_content = generate_milk_html(data)

            elif report_type == "animals":
                cur.execute("SELECT * FROM animals WHERE user_id=%s ORDER BY name", (uid,))
                data = cur.fetchall()
                html_content = generate_animals_html(data)

            elif report_type == "finance":
                cur.execute("SELECT * FROM transactions WHERE user_id=%s ORDER BY date DESC", (uid,))
                data = cur.fetchall()
                for r in data:
                    r["date"] = safe_str(r.get("date"))
                    r["amount"] = float(r.get("amount") or 0)
                html_content = generate_finance_html(data)

            elif report_type == "feeding":
                cur.execute("SELECT * FROM feed_stock WHERE user_id=%s ORDER BY name", (uid,))
                stock = cur.fetchall()
                for r in stock:
                    r["quantity"] = float(r.get("quantity") or 0)
                cur.execute("SELECT * FROM feed_activity WHERE user_id=%s ORDER BY date DESC LIMIT 30", (uid,))
                activity = cur.fetchall()
                for r in activity:
                    r["date"] = safe_str(r.get("date"))
                    r["amount_added"] = float(r.get("amount_added") or 0)
                html_content = generate_feeding_html(stock, activity)

            elif report_type == "visitors":
                cur.execute("SELECT * FROM visitors WHERE user_id=%s ORDER BY date DESC", (uid,))
                data = cur.fetchall()
                for r in data:
                    r["date"] = safe_str(r.get("date"))
                    r["entry_time"] = safe_str(r.get("entry_time"))
                    r["outgoing_time"] = safe_str(r.get("outgoing_time"))
                html_content = generate_visitors_html(data)

            elif report_type == "ai":
                cur.execute("SELECT * FROM ai_predictions WHERE user_id=%s ORDER BY created_at DESC", (uid,))
                data = cur.fetchall()
                for r in data:
                    r["created_at"] = safe_str(r.get("created_at"))
                html_content = generate_ai_html(data)

            else:
                return jsonify({"error": f"Report type {report_type} not supported"}), 400
    finally:
        conn.close()

    # Try to generate PDF; fall back to HTML if pdfkit/wkhtmltopdf not available
    try:
        import pdfkit
        options = {
            'page-size': 'A4',
            'margin-top': '0.75in',
            'margin-right': '0.75in',
            'margin-bottom': '0.75in',
            'margin-left': '0.75in',
            'encoding': "UTF-8",
        }
        pdf_file = tempfile.NamedTemporaryFile(suffix=".pdf", delete=False)
        pdfkit.from_string(html_content, pdf_file.name, options=options)

        return send_file(
            pdf_file.name,
            as_attachment=True,
            download_name=f"PashuCare_{report_type}_Report_{datetime.now().strftime('%Y%m%d')}.pdf",
            mimetype='application/pdf'
        )
    except Exception as e:
        print(f"PDF Generation Error (pdfkit): {e}")
        # Fall back to sending HTML for debugging
        return html_content, 200, {"Content-Type": "text/html"}


# ── HTML Generators ────────────────────────────────────────────────────────────

def _base_style(accent="#2e7d32"):
    return f"""
    <style>
        body {{ font-family: Arial, sans-serif; color: #333; }}
        h1 {{ color: {accent}; margin-bottom: 4px; }}
        .subtitle {{ color: #888; font-size: 13px; margin-bottom: 20px; }}
        table {{ width: 100%; border-collapse: collapse; margin-top: 10px; }}
        th, td {{ border: 1px solid #ddd; padding: 9px 12px; text-align: left; font-size: 13px; }}
        th {{ background-color: {accent}20; color: {accent}; font-weight: bold; }}
        tr:nth-child(even) {{ background-color: #fafafa; }}
        .summary {{ display: flex; gap: 16px; margin-bottom: 18px; flex-wrap: wrap; }}
        .card {{ background: {accent}10; border-radius: 8px; padding: 12px 18px; min-width: 120px; }}
        .card-label {{ font-size: 11px; color: {accent}; text-transform: uppercase; }}
        .card-value {{ font-size: 24px; font-weight: bold; }}
    </style>
    """

def generate_milk_html(data):
    total = sum(float(r.get("am", 0)) + float(r.get("noon", 0)) + float(r.get("pm", 0)) for r in data)
    rows = ""
    for r in data:
        am = float(r.get("am", 0))
        noon = float(r.get("noon", 0))
        pm = float(r.get("pm", 0))
        rows += f"<tr><td>{r.get('date','')}</td><td>{r.get('milk_type','')}</td><td>{am}L</td><td>{noon}L</td><td>{pm}L</td><td><b>{am+noon+pm:.1f}L</b></td></tr>"

    return f"""<html><head>{_base_style("#1565c0")}</head><body>
        <h1>🥛 Milk Production Report</h1>
        <p class="subtitle">PashuCare — Generated {datetime.now().strftime('%d %b %Y, %H:%M')}</p>
        <div class="summary">
            <div class="card"><div class="card-label">Total Production</div><div class="card-value">{total:.1f}L</div></div>
            <div class="card"><div class="card-label">Records</div><div class="card-value">{len(data)}</div></div>
        </div>
        <table><tr><th>Date</th><th>Type</th><th>AM</th><th>Noon</th><th>PM</th><th>Total</th></tr>{rows}</table>
    </body></html>"""

def generate_animals_html(data):
    rows = ""
    for r in data:
        rows += f"<tr><td>{r.get('tag','')}</td><td>{r.get('name','')}</td><td>{r.get('breed','')}</td><td>{r.get('gender','')}</td><td>{r.get('status','')}</td></tr>"

    return f"""<html><head>{_base_style("#e65100")}</head><body>
        <h1>🐄 Animals Directory</h1>
        <p class="subtitle">PashuCare — Generated {datetime.now().strftime('%d %b %Y, %H:%M')} — Total: {len(data)} animals</p>
        <table><tr><th>Tag</th><th>Name</th><th>Breed</th><th>Gender</th><th>Status</th></tr>{rows}</table>
    </body></html>"""

def generate_finance_html(data):
    income = sum(float(r.get("amount", 0)) for r in data if r.get("category") == "Income")
    expense = sum(float(r.get("amount", 0)) for r in data if r.get("category") == "Expense")
    rows = ""
    for r in data:
        amt = float(r.get("amount", 0))
        cat = r.get("category", "")
        color = "#2e7d32" if cat == "Income" else "#c62828"
        sign = "+" if cat == "Income" else "-"
        rows += f"<tr><td>{r.get('date','')}</td><td>{cat}</td><td>{r.get('type','')}</td><td style='color:{color};font-weight:bold'>{sign}₹{amt:.2f}</td><td>{r.get('receipt_no','')}</td><td>{r.get('note','')}</td></tr>"

    return f"""<html><head>{_base_style("#00695c")}</head><body>
        <h1>💰 Finance Summary Report</h1>
        <p class="subtitle">PashuCare — Generated {datetime.now().strftime('%d %b %Y, %H:%M')}</p>
        <div class="summary">
            <div class="card"><div class="card-label">Total Income</div><div class="card-value" style="color:#2e7d32">₹{income:.2f}</div></div>
            <div class="card"><div class="card-label">Total Expense</div><div class="card-value" style="color:#c62828">₹{expense:.2f}</div></div>
            <div class="card"><div class="card-label">Balance</div><div class="card-value">₹{income-expense:.2f}</div></div>
            <div class="card"><div class="card-label">Transactions</div><div class="card-value">{len(data)}</div></div>
        </div>
        <table><tr><th>Date</th><th>Category</th><th>Type</th><th>Amount</th><th>Receipt No</th><th>Note</th></tr>{rows}</table>
    </body></html>"""

def generate_feeding_html(stock, activity):
    total_stock = sum(r.get("quantity", 0) for r in stock)
    stock_rows = ""
    for r in stock:
        stock_rows += f"<tr><td>{r.get('name','')}</td><td>{r.get('quantity',0):.1f} kg</td><td>{r.get('status','')}</td></tr>"

    activity_rows = ""
    for r in activity:
        activity_rows += f"<tr><td>{r.get('date','')}</td><td>{r.get('item_name','')}</td><td>{r.get('amount_added',0):.1f} kg</td></tr>"

    return f"""<html><head>{_base_style("#e65100")}</head><body>
        <h1>🌾 Feeding & Stock Report</h1>
        <p class="subtitle">PashuCare — Generated {datetime.now().strftime('%d %b %Y, %H:%M')}</p>
        <div class="summary">
            <div class="card"><div class="card-label">Total Stock</div><div class="card-value">{total_stock:.0f} kg</div></div>
            <div class="card"><div class="card-label">Feed Items</div><div class="card-value">{len(stock)}</div></div>
        </div>
        <h3 style="color:#e65100">Feed Stock</h3>
        <table><tr><th>Item</th><th>Quantity</th><th>Status</th></tr>{stock_rows}</table>
        <h3 style="color:#e65100;margin-top:20px">Recent Activity</h3>
        <table><tr><th>Date</th><th>Item</th><th>Amount Added</th></tr>{activity_rows}</table>
    </body></html>"""

def generate_visitors_html(data):
    rows = ""
    for r in data:
        rows += f"<tr><td>{r.get('date','')}</td><td>{r.get('name','')}</td><td>{r.get('phone','')}</td><td>{r.get('purpose','')}</td><td>{r.get('status','')}</td></tr>"

    return f"""<html><head>{_base_style("#4527a0")}</head><body>
        <h1>👥 Visitor Log Report</h1>
        <p class="subtitle">PashuCare — Generated {datetime.now().strftime('%d %b %Y, %H:%M')} — Total: {len(data)} visitors</p>
        <table><tr><th>Date</th><th>Name</th><th>Phone</th><th>Purpose</th><th>Status</th></tr>{rows}</table>
    </body></html>"""

def generate_ai_html(data):
    rows = ""
    for r in data:
        rows += f"<tr><td>{r.get('created_at','')}</td><td>{r.get('disease_name','')}</td><td>{r.get('confidence','')}</td><td>{r.get('status','')}</td></tr>"

    return f"""<html><head>{_base_style("#b71c1c")}</head><body>
        <h1>🔬 AI Disease Analysis Report</h1>
        <p class="subtitle">PashuCare — Generated {datetime.now().strftime('%d %b %Y, %H:%M')} — Scans: {len(data)}</p>
        <table><tr><th>Date</th><th>Disease</th><th>Confidence</th><th>Status</th></tr>{rows}</table>
    </body></html>"""
