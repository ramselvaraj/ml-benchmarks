import pandas as pd
from sklearn.svm import SVC
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import joblib
import time
import os

# Get the project root directory
project_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Load datasets
print("Loading HAR datasets...")
train_data = pd.read_csv(os.path.join(project_root, '_datasets/har/har_train.csv'), sep=';')
test_data = pd.read_csv(os.path.join(project_root, '_datasets/har/har_test.csv'), sep=';')

# Convert comma decimals to dots for numeric columns and handle invalid data
numeric_cols = ['age', 'how_tall_in_meters', 'weight', 'body_mass_index'] + [f'{axis}{i}' for i in range(1,5) for axis in ['x','y','z']]
for col in numeric_cols:
    if col in train_data.columns:
        train_data[col] = pd.to_numeric(train_data[col].astype(str).str.replace(',', '.'), errors='coerce')
        test_data[col] = pd.to_numeric(test_data[col].astype(str).str.replace(',', '.'), errors='coerce')

# Drop rows with NaN values
train_data = train_data.dropna()
test_data = test_data.dropna()

# Separate features and labels
# Drop non-numeric columns for features
feature_cols = [col for col in train_data.columns if col not in ['user', 'gender', 'class']]
X_train = train_data[feature_cols]
y_train = train_data['class']

X_test = test_data[feature_cols]
y_test = test_data['class']

# Encode labels
label_encoder = LabelEncoder()
y_train_encoded = label_encoder.fit_transform(y_train)
y_test_encoded = label_encoder.transform(y_test)

# Scale features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Train SVM model
print("Training SVM model...")
start_time = time.time()

svm = SVC(kernel='rbf', C=1.0, gamma='scale', random_state=42)
svm.fit(X_train_scaled, y_train_encoded)

train_time = time.time() - start_time

# Save model, scaler, and label encoder
model_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'svm_har_model.joblib')
scaler_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'scaler.joblib')
encoder_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'label_encoder.joblib')

joblib.dump(svm, model_path)
joblib.dump(scaler, scaler_path)
joblib.dump(label_encoder, encoder_path)

print(f"Model saved to: {model_path}")
print(f"Scaler saved to: {scaler_path}")
print(f"Label encoder saved to: {encoder_path}")

# Make predictions
print("Making predictions...")
start_time = time.time()

y_pred = svm.predict(X_test_scaled)

inference_time = time.time() - start_time

# Calculate metrics
accuracy = accuracy_score(y_test_encoded, y_pred)
print(f"Accuracy: {accuracy}")
print("Classification Report:")
print(classification_report(y_test_encoded, y_pred, target_names=label_encoder.classes_))
print("Confusion Matrix:")
print(confusion_matrix(y_test_encoded, y_pred))

# Print timing information
print(f"Training time: {train_time:.2f} seconds")
print(f"Inference time: {inference_time:.2f} seconds")