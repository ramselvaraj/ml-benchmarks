import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.svm import LinearSVC
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
    ConfusionMatrixDisplay
)

train_url = "https://raw.githubusercontent.com/ramselvaraj/ml-benchmarks/main/_datasets/har/har_train.csv"
test_url  = "https://raw.githubusercontent.com/ramselvaraj/ml-benchmarks/main/_datasets/har/har_test.csv"

train_df = pd.read_csv(train_url, sep=';')
test_df  = pd.read_csv(test_url, sep=';')

print("Train shape:", train_df.shape)
print("Test shape :", test_df.shape)

print("\nColumns:")
print(train_df.columns.tolist())

print("\nFirst 3 rows:")
display(train_df.head(3))

print("Column dtypes:\n")
print(train_df.dtypes)

print("\nUnique values in object columns:\n")
for col in train_df.columns:
    if train_df[col].dtype == 'object':
        print(f"{col}:")
        print(train_df[col].head(10).tolist())
        print()

# Detect label column automatically
# Prefer common activity/label names if present
possible_label_cols = ["activity", "Activity", "label", "Label", "class", "Class", "target", "Target"]

label_col = None
for col in possible_label_cols:
    if col in train_df.columns:
        label_col = col
        break

# If not found, use the last object column as label
if label_col is None:
    object_cols = train_df.select_dtypes(include=['object']).columns.tolist()
    if len(object_cols) > 0:
        label_col = object_cols[-1]
    else:
        label_col = train_df.columns[-1]

print("Detected label column:", label_col)

# Keep ONLY numeric columns as features
numeric_cols = train_df.select_dtypes(include=[np.number]).columns.tolist()

# Remove label column if it somehow appears in numeric columns
if label_col in numeric_cols:
    numeric_cols.remove(label_col)

X_train_df = train_df[numeric_cols].copy()
X_test_df  = test_df[numeric_cols].copy()

y_train_raw = train_df[label_col].astype(str).copy()
y_test_raw  = test_df[label_col].astype(str).copy()

print("Number of numeric feature columns:", len(numeric_cols))
print("First 10 feature columns:", numeric_cols[:10])

print("\nX_train shape:", X_train_df.shape)
print("X_test shape :", X_test_df.shape)
print("y_train shape:", y_train_raw.shape)
print("y_test shape :", y_test_raw.shape)

print("\nSample labels:")
print(y_train_raw.head(10).tolist())

print("Any missing values in X_train?", X_train_df.isnull().sum().sum())
print("Any missing values in X_test ?", X_test_df.isnull().sum().sum())
print("Any missing values in y_train?", y_train_raw.isnull().sum())
print("Any missing values in y_test ?", y_test_raw.isnull().sum())

print("\nClass distribution in train:")
print(y_train_raw.value_counts())

print("\nClass distribution in test:")
print(y_test_raw.value_counts())

# Encode labels
label_encoder = LabelEncoder()
y_train = label_encoder.fit_transform(y_train_raw)
y_test = label_encoder.transform(y_test_raw)

print("Class names:", list(label_encoder.classes_))
print("Encoded labels:", list(range(len(label_encoder.classes_))))

# Standardize numeric features using TRAIN stats only
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train_df.values.astype(np.float64))
X_test  = scaler.transform(X_test_df.values.astype(np.float64))

print("Scaled X_train shape:", X_train.shape)
print("Scaled X_test shape :", X_test.shape)

print("\nFirst 5 feature means after scaling:")
print(np.round(X_train.mean(axis=0)[:5], 4))

print("\nFirst 5 feature stds after scaling:")
print(np.round(X_train.std(axis=0)[:5], 4))

num_samples_train, num_features = X_train.shape
num_samples_test = X_test.shape[0]
num_classes = len(label_encoder.classes_)

print("\nSummary:")
print("Train samples :", num_samples_train)
print("Test samples  :", num_samples_test)
print("Num features  :", num_features)
print("Num classes   :", num_classes)

# FPGA-friendly model: linear multiclass SVM
svm_model = LinearSVC(
    C=1.0,
    multi_class="ovr",
    dual=False,
    max_iter=5000,
    random_state=42
)

svm_model.fit(X_train, y_train)

y_pred = svm_model.predict(X_test)

acc = accuracy_score(y_test, y_pred)

print("Test Accuracy:", round(acc, 6))
print("\nClassification Report:")
print(classification_report(y_test, y_pred, target_names=label_encoder.classes_))

W = svm_model.coef_
b = svm_model.intercept_

print("Weight matrix shape:", W.shape)
print("Bias vector shape  :", b.shape)

print("\nFirst class weights (first 10):")
print(np.round(W[0][:10], 6))

print("\nBiases:")
print(np.round(b, 6))

cm = confusion_matrix(y_test, y_pred)

fig, ax = plt.subplots(figsize=(8, 6))
disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=label_encoder.classes_)
disp.plot(ax=ax, xticks_rotation=45, colorbar=False)
plt.title("HAR Linear SVM Confusion Matrix")
plt.show()

cm = confusion_matrix(y_test, y_pred)

fig, ax = plt.subplots(figsize=(8, 6))
disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=label_encoder.classes_)
disp.plot(ax=ax, xticks_rotation=45, colorbar=False)
plt.title("HAR Linear SVM Confusion Matrix")
plt.show()

def manual_linear_svm_scores(x, W, b):
    return W @ x + b

sample_idx = 0
x_sample = X_test[sample_idx]

scores = manual_linear_svm_scores(x_sample, W, b)
pred_manual = int(np.argmax(scores))
pred_model = int(y_pred[sample_idx])
true_label = int(y_test[sample_idx])

print("Sample index:", sample_idx)
print("Scores per class:")
for i, s in enumerate(scores):
    print(f"class {i} ({label_encoder.classes_[i]}): {s:.6f}")

print("\nManual prediction:", pred_manual, label_encoder.classes_[pred_manual])
print("Model prediction :", pred_model, label_encoder.classes_[pred_model])
print("True label       :", true_label, label_encoder.classes_[true_label])

FRAC_BITS = 8
SCALE = 2 ** FRAC_BITS

X_test_q = np.round(X_test * SCALE).astype(np.int16)
W_q = np.round(W * SCALE).astype(np.int16)
b_q = np.round(b * SCALE).astype(np.int32)

print("Quantized X_test shape:", X_test_q.shape, X_test_q.dtype)
print("Quantized W shape     :", W_q.shape, W_q.dtype)
print("Quantized b shape     :", b_q.shape, b_q.dtype)

print("\nExample quantized feature vector (first sample, first 10 features):")
print(X_test_q[0][:10])

print("\nExample quantized weights for class 0 (first 10):")
print(W_q[0][:10])

print("\nQuantized biases:")
print(b_q)

def quantized_svm_predict(Xq, Wq, bq, frac_bits=8):
    preds = []
    scores_all = []

    for i in range(Xq.shape[0]):
        x = Xq[i].astype(np.int32)
        class_scores = []

        for c in range(Wq.shape[0]):
            w = Wq[c].astype(np.int32)

            acc = np.sum(w * x, dtype=np.int64)
            acc += (np.int64(bq[c]) << frac_bits)

            class_scores.append(acc)

        class_scores = np.array(class_scores, dtype=np.int64)
        pred = int(np.argmax(class_scores))

        preds.append(pred)
        scores_all.append(class_scores)

    return np.array(preds), np.array(scores_all)

y_pred_q, scores_q = quantized_svm_predict(X_test_q, W_q, b_q, frac_bits=FRAC_BITS)

acc_q = accuracy_score(y_test, y_pred_q)

print("Floating-point accuracy :", round(acc, 6))
print("Quantized-int accuracy  :", round(acc_q, 6))
print("Prediction match rate   :", round(np.mean(y_pred == y_pred_q), 6))

sample_idx = 0

plt.figure(figsize=(8, 4))
plt.bar(range(num_classes), scores_q[sample_idx])
plt.xticks(range(num_classes), label_encoder.classes_, rotation=45)
plt.ylabel("Quantized class score")
plt.title(f"Quantized class scores for test sample {sample_idx}")
plt.show()

os.makedirs("fpga_exports", exist_ok=True)

np.save("fpga_exports/X_test_q.npy", X_test_q)
np.save("fpga_exports/W_q.npy", W_q)
np.save("fpga_exports/b_q.npy", b_q)
np.save("fpga_exports/y_test.npy", y_test)
np.save("fpga_exports/y_pred_float.npy", y_pred)
np.save("fpga_exports/y_pred_quantized.npy", y_pred_q)

np.savetxt("fpga_exports/har_test_x_q.txt", X_test_q, fmt="%d", delimiter=",")
np.savetxt("fpga_exports/har_test_y.txt", y_test, fmt="%d")
np.savetxt("fpga_exports/har_test_pred_q.txt", y_pred_q, fmt="%d")

W_q_flat = W_q.reshape(-1)
np.savetxt("fpga_exports/har_svm_weights_q.txt", W_q_flat, fmt="%d")
np.savetxt("fpga_exports/har_svm_bias_q.txt", b_q, fmt="%d")

print("Exported files:")
for f in sorted(os.listdir("fpga_exports")):
    print("-", f)

print("FINAL FPGA-RELEVANT SUMMARY")
print("---------------------------")
print("Number of classes :", num_classes)
print("Number of features:", num_features)
print("Weight matrix     :", W_q.shape)
print("Bias vector       :", b_q.shape)
print("Test vectors      :", X_test_q.shape)
print("Float accuracy    :", round(acc, 6))
print("Quantized accuracy:", round(acc_q, 6))

print("num_features =", num_features)
print("num_classes =", num_classes)
print("W_q shape =", W_q.shape)
print("b_q shape =", b_q.shape)
print("X_test_q shape =", X_test_q.shape)
print("float accuracy =", acc)
print("quantized accuracy =", acc_q)

print("Feature min/max after quantization:")
print("X_test_q min =", X_test_q.min(), "X_test_q max =", X_test_q.max())

print("Weight min/max after quantization:")
print("W_q min =", W_q.min(), "W_q max =", W_q.max())

print("Bias min/max after quantization:")
print("b_q min =", b_q.min(), "b_q max =", b_q.max())

import numpy as np
import os

os.makedirs("fpga_exports", exist_ok=True)

np.savetxt("fpga_exports/har_test_x_q.txt", X_test_q, fmt="%d", delimiter=",")
print("Saved: fpga_exports/har_test_x_q.txt")
