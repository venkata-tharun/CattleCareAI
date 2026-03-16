# PashuCare Backend

This is the Python (Flask) backend API for the PashuCare iOS application. It uses PyMySQL for database interactions and Flask-Session strictly for managing authenticated user sessions.

## Features Let The iOS Know
- **Session Auth**: Stores user ID, Profile, and Farm context to seamlessly retrieve throughout API requests using browser/UrlSession native cookies (`flask_session` file-system backed).
- **CRUD Operations**: Complete endpoints for Animals, Milk tracking, Calving, Feed, Visitors, and Finance (Transactions).

## Prerequisites
- **Python 3.10+**
- **MySQL Server** (Make sure the MySQL daemon is running locally)

## Installation & Setup

1. **Activate the Virtual Environment**
   ```bash
   source venv/bin/activate
   ```

2. **Install Python Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Database Configuration**
   - First, create a database named `pashucare` via your MySQL client:
     ```sql
     CREATE DATABASE pashucare;
     ```
   - Import the completely predefined schema:
     ```bash
     mysql -u root -p pashucare < schema.sql
     ```
   - *Note*: You might need to change the configured user/password in `config.py` (or through the `.env` file) to match your local MySQL credentials. The default is `root` / `<empty-password>` on port `3306`.

4. **Running the API Server**
   ```bash
   python app.py
   ```
   *The server will start locally at `http://localhost:5000` or `http://0.0.0.0:5000`.*

---

*Note: The "Alerts" feature has been permanently dropped from both iOS & Backend designs.*



#steps to activate and run python server(make sure to switch on the manager-osx(xampp) server too)
#to activate venv
#source venv/bin/activate

#run this command to switch on the python server
#python app.py

 <!-- * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000(this is the localhost ip to be kept on networkmanager.swift)
 * Running on http://172.25.89.81:5000(this is to be used to test in real iphone devices) -->

#to switch off the server press ctrl+c

#to deactivate venv type  "deactivate"