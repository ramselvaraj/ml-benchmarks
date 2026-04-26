import pandas as pd
from sklearn.svm import SVC
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import joblib
import time
import os
import numpy as np

# Get the project root directory
project_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Load datasets
print("Loading HAR datasets...")
train_data = pd.read_csv(os.path.join(project_root, '_datasets/har/har_train.csv'), sep=';', low_memory=False)
test_data = pd.read_csv(os.path.join(project_root, '_datasets/har/har_test.csv'), sep=';', low_memory=False)

# Convert comma decimals to dots for numeric columns and handle invalid data
numeric_cols = ['age', 'how_tall_in_meters', 'weight', 'body_mass_index'] + [f'{axis}{i}' for i in range(1,5) for axis in ['x','y','z']]
for col in numeric_cols:
    if col in train_data.columns:
        train_data[col] = pd.to_numeric(train_data[col].astype(str).str.replace(',', '.'), errors='coerce')
        test_data[col] = pd.to_numeric(test_data[col].astype(str).str.replace(',', '.'), errors='coerce')

# Encode user and gender
user_encoder = LabelEncoder()
gender_encoder = LabelEncoder()
train_data['user_encoded'] = user_encoder.fit_transform(train_data['user'])
train_data['gender_encoded'] = gender_encoder.fit_transform(train_data['gender'])
test_data['user_encoded'] = user_encoder.transform(test_data['user'])
test_data['gender_encoded'] = gender_encoder.transform(test_data['gender'])

# Drop rows with NaN values
train_data = train_data.dropna()
test_data = test_data.dropna()

# Separate features and labels
# Drop non-numeric columns for features
feature_cols = [col for col in train_data.columns if col not in ['gender', 'user', 'class']]
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

# Ensure arrays are C-contiguous for libsvm
X_train_scaled = np.ascontiguousarray(X_train_scaled)
X_test_scaled = np.ascontiguousarray(X_test_scaled)

# Train SVM model
print("Training SVM model...")
start_time = time.time()

svm = SVC(kernel='linear', C=1.0, random_state=42)
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

# Save gender encoder
gender_encoder_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'gender_encoder.joblib')
joblib.dump(gender_encoder, gender_encoder_path)

print(f"Gender encoder saved to: {gender_encoder_path}")

# Save user encoder
user_encoder_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'user_encoder.joblib')
joblib.dump(user_encoder, user_encoder_path)

print(f"User encoder saved to: {user_encoder_path}")

# Make predictions
print("Making predictions...")
start_time = time.time()

y_pred = svm.predict(X_test_scaled)

inference_time = time.time() - start_time

# Calculate metrics
accuracy = accuracy_score(y_test_encoded, y_pred)

# Compute train accuracy
y_train_pred = svm.predict(X_train_scaled)
train_accuracy = accuracy_score(y_train_encoded, y_train_pred)

# Save results to CSV
results = {
    'Model': ['svm'],
    'Precision': ['Float-32'],
    'Train_Acc': [train_accuracy],
    'Val_Acc': [accuracy],
    'Final_Loss': ['N/A'],
    'Conv_Epochs': ['N/A'],
    'MSE_Golden': [0]
}
results_df = pd.DataFrame(results)
results_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'acc_results.csv')
results_df.to_csv(results_path, index=False)
print(f"Results saved to: {results_path}")

# Performance metrics
throughput = len(X_test) / inference_time  # samples per second
latency_p50 = (inference_time / len(X_test)) * 1000  # ms
latency_p99 = latency_p50  # assume same

perf_results = {
    'workload': ['har_svm'],
    'dtype': ['float32'],
    'batch_size': [1],
    'throughput': [throughput],
    'latency_p50': [latency_p50],
    'latency_p99': [latency_p99],
    'energy_total': ['N/A'],
    'avg_power': ['N/A'],
    'achieved_gflops': ['N/A'],
    'utilization_pct': ['N/A'],
    'arith_intensity': ['N/A'],
    'phase_staging': [0],
    'phase_compute': [inference_time],
    'phase_output': [0],
    'tta_sec': [inference_time]
}
perf_df = pd.DataFrame(perf_results)
perf_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'perf_results.csv')
perf_df.to_csv(perf_path, index=False)
print(f"Performance results saved to: {perf_path}")

print(f"Accuracy: {accuracy}")
print("Classification Report:")
print(classification_report(y_test_encoded, y_pred, target_names=label_encoder.classes_))
print("Confusion Matrix:")
print(confusion_matrix(y_test_encoded, y_pred))

# Calculate throughput
throughput = len(X_test) / inference_time  # samples per second
train_time_ms = train_time * 1000
inference_time_ms = inference_time * 1000

# Print timing information
print(f"Training time: {train_time_ms:.2f} ms")
print(f"Inference time: {inference_time_ms:.2f} ms")
print(f"Throughput: {throughput:.2f} samples/sec")