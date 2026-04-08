import pandas as pd
from sklearn.linear_model import Perceptron
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import joblib
import time
import os

# Get the project root directory
project_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Load datasets
train_data = pd.read_csv(os.path.join(project_root, '_datasets/iris/iris_train.csv'))
test_data = pd.read_csv(os.path.join(project_root, '_datasets/iris/iris_test.csv'))

# Separate features and labels
X_train = train_data[['sepal.length', 'sepal.width', 'petal.length', 'petal.width']]
y_train = train_data['variety']

X_test = test_data[['sepal.length', 'sepal.width', 'petal.length', 'petal.width']]
y_test = test_data['variety']

# Encode labels
label_encoder = LabelEncoder()
y_train_encoded = label_encoder.fit_transform(y_train)
y_test_encoded = label_encoder.transform(y_test)

# Train perceptron model
print("Training Perceptron model...")
start_time = time.time()

perceptron = Perceptron(max_iter=1000, random_state=42)
perceptron.fit(X_train, y_train_encoded)

train_time = time.time() - start_time

# Save model and label encoder
model_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'perceptron_iris_model.joblib')
encoder_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'label_encoder.joblib')
joblib.dump(perceptron, model_path)
joblib.dump(label_encoder, encoder_path)
print(f"Model saved to: {model_path}")
print(f"Label encoder saved to: {encoder_path}")

# Make predictions
print("Making predictions...")
start_time = time.time()

y_pred = perceptron.predict(X_test)

pred_time = time.time() - start_time

# Evaluate model
accuracy = accuracy_score(y_test_encoded, y_pred)

print("\n" + "="*50)
print("Perceptron Model Results (Iris Dataset)")
print("="*50)
print(f"Training Time: {train_time:.4f} seconds")
print(f"Prediction Time: {pred_time:.4f} seconds")
print(f"Test Accuracy: {accuracy:.4f}")
print("\nClassification Report:")
print(classification_report(y_test_encoded, y_pred, target_names=label_encoder.classes_))
print("\nConfusion Matrix:")
print(confusion_matrix(y_test_encoded, y_pred))
