from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import joblib
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Load your XGBoost model
MODEL_PATH = os.path.join(os.getcwd(), 'C:/Users/User/Desktop/loan prediction/backend/model/xgboost_model.pkl')
model = joblib.load(MODEL_PATH)

@app.route('/')
def index():
    return jsonify({"message": "Loan Prediction API is running!"})

@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.get_json(force=True)

        expected_fields = [
            'no_of_dependents', 'education', 'self_employed',
            'income_annum', 'loan_amount', 'loan_term', 'cibil_score',
            'residential_assets_value', 'commercial_assets_value',
            'luxury_assets_value', 'bank_asset_value'
        ]

        # Ensure all required fields are present
        if not all(field in data for field in expected_fields):
            return jsonify({'error': 'Missing required fields'}), 400

        # Convert values to a list in correct order
        features = [float(data[field]) for field in expected_fields]
        prediction = model.predict(np.array([features]))[0]

        result = "Approved" if prediction == 1 else "Rejected"
        return jsonify({'loan_status': result})

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    # Allow connections from Flutter and Postman
    app.run(host='0.0.0.0', port=5000, debug=True)
