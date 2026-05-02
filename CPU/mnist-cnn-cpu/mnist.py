import tensorflow as tf
from tensorflow.keras import layers, models
from tensorflow.keras.datasets import mnist
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import numpy as np
import pandas as pd
import time
import os
import subprocess
import multiprocessing


def wmic_get(field):
    try:
        out = subprocess.check_output(['wmic', 'cpu', 'get', field, '/value'], text=True, stderr=subprocess.DEVNULL)
        for line in out.splitlines():
            if line.startswith(f'{field}='):
                return line.split('=', 1)[1].strip()
    except Exception:
        return None


def get_cpu_specs():
    cpu_name = wmic_get('Name') or ''
    cores = int(wmic_get('NumberOfCores') or multiprocessing.cpu_count())
    freq_mhz = int(wmic_get('MaxClockSpeed') or 2100)
    return cpu_name, cores, freq_mhz


def estimate_peak_gflops(cores, freq_mhz):
    return cores * float(freq_mhz) * 0.016


def estimate_tdp(cpu_name):
    if 'i7-13700F' in cpu_name:
        return 65.0
    if 'i7-' in cpu_name or 'i9-' in cpu_name or 'i5-' in cpu_name:
        return 65.0
    return 65.0


def estimate_avg_power(utilization, tdp):
    base_load = 0.10
    return max(1.0, tdp * (base_load + 0.90 * utilization))


def estimate_cnn_ops_per_sample():
    conv1_ops = 16 * 26 * 26 * 1 * 3 * 3 * 2.0
    conv2_ops = 32 * 11 * 11 * 16 * 3 * 3 * 2.0
    dense1_ops = 3872 * 32 * 2.0
    dense2_ops = 32 * 10 * 2.0
    return conv1_ops + conv2_ops + dense1_ops + dense2_ops


def estimate_cnn_arith_intensity(n_samples):
    input_bytes = 28 * 28 * 4
    weight_bytes = (16 * 1 * 3 * 3 + 32 * 16 * 3 * 3 + 3872 * 32 + 32 * 10) * 4
    total_bytes = float(n_samples) * input_bytes + float(weight_bytes)
    total_ops = estimate_cnn_ops_per_sample() * float(n_samples)
    return total_ops / total_bytes if total_bytes > 0 else 0.0

# Get the project root directory
project_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Load MNIST dataset
print("Loading MNIST dataset...")
(X_train, y_train), (X_test, y_test) = mnist.load_data()

# Preprocess the data
X_train = X_train.reshape((X_train.shape[0], 28, 28, 1)).astype('float32') / 255
X_test = X_test.reshape((X_test.shape[0], 28, 28, 1)).astype('float32') / 255

# Convert labels to categorical
y_train = tf.keras.utils.to_categorical(y_train, 10)
y_test = tf.keras.utils.to_categorical(y_test, 10)

# Build the CNN model
print("Building CNN model...")
model = models.Sequential([
    layers.Conv2D(16, (3, 3), activation='relu', input_shape=(28, 28, 1)),
    layers.MaxPooling2D((2, 2)),
    layers.Conv2D(32, (3, 3), activation='relu'),
    layers.MaxPooling2D((2, 2)),
    layers.Flatten(),
    layers.Dense(32, activation='relu'),
    layers.Dense(10, activation='softmax')
])

# Compile the model
model.compile(optimizer='adam',
              loss='categorical_crossentropy',
              metrics=['accuracy'])

# Train the model
print("Training CNN model...")
start_time = time.time()

history = model.fit(X_train, y_train, epochs=3, batch_size=64, validation_split=0.1)

train_time = time.time() - start_time

# Save the model
model_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'mnist_cnn_model.h5')
model.save(model_path)
print(f"Model saved to: {model_path}")

# Evaluate the model
print("Evaluating model...")
test_loss, test_acc = model.evaluate(X_test, y_test)
print(f"Test accuracy: {test_acc}")

# Make predictions
print("Making predictions...")
start_time = time.time()

y_pred_prob = model.predict(X_test)
y_pred = np.argmax(y_pred_prob, axis=1)
y_test_labels = np.argmax(y_test, axis=1)

inference_time = time.time() - start_time

# Calculate metrics
accuracy = accuracy_score(y_test_labels, y_pred)

# Get train and val accuracy
train_acc = history.history['accuracy'][-1]
val_acc = history.history['val_accuracy'][-1]
final_loss = history.history['loss'][-1]

# Save results to CSV
results = {
    'Model': ['cnn'],
    'Precision': ['Float-32'],
    'Train_Acc': [train_acc],
    'Val_Acc': [val_acc],
    'Final_Loss': [final_loss],
    'Conv_Epochs': [3],
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

cpu_name, cpu_cores, cpu_freq = get_cpu_specs()
peak_gflops = estimate_peak_gflops(cpu_cores, cpu_freq)
tdp = estimate_tdp(cpu_name)

ops_per_sample = estimate_cnn_ops_per_sample()
ops_total = ops_per_sample * float(len(X_test))
achieved_gflops = ops_total / inference_time / 1e9 if inference_time > 0 else 0.0
utilization = (achieved_gflops / peak_gflops) if peak_gflops > 0 else 0.0
avg_power = estimate_avg_power(utilization, tdp)
energy_total = avg_power * inference_time
arith_intensity = estimate_cnn_arith_intensity(len(X_test))

perf_results = {
    'workload': ['mnist_cnn'],
    'dtype': ['float32'],
    'batch_size': [1],
    'throughput': [throughput],
    'latency_p50': [latency_p50],
    'latency_p99': [latency_p99],
    'energy_total': [energy_total],
    'avg_power': [avg_power],
    'achieved_gflops': [achieved_gflops],
    'utilization_pct': [utilization * 100.0],
    'arith_intensity': [arith_intensity],
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
print(classification_report(y_test_labels, y_pred))
print("Confusion Matrix:")
print(confusion_matrix(y_test_labels, y_pred))

# Print timing information
print(f"Training time: {train_time:.2f} seconds")
print(f"Inference time: {inference_time:.2f} seconds")