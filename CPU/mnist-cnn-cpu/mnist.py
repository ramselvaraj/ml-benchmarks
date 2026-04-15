import tensorflow as tf
from tensorflow.keras import layers, models
from tensorflow.keras.datasets import mnist
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import numpy as np
import time
import os

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
    layers.Conv2D(32, (3, 3), activation='relu', input_shape=(28, 28, 1)),
    layers.MaxPooling2D((2, 2)),
    layers.Conv2D(64, (3, 3), activation='relu'),
    layers.MaxPooling2D((2, 2)),
    layers.Conv2D(64, (3, 3), activation='relu'),
    layers.Flatten(),
    layers.Dense(64, activation='relu'),
    layers.Dense(10, activation='softmax')
])

# Compile the model
model.compile(optimizer='adam',
              loss='categorical_crossentropy',
              metrics=['accuracy'])

# Train the model
print("Training CNN model...")
start_time = time.time()

history = model.fit(X_train, y_train, epochs=5, batch_size=64, validation_split=0.1)

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
print(f"Accuracy: {accuracy}")
print("Classification Report:")
print(classification_report(y_test_labels, y_pred))
print("Confusion Matrix:")
print(confusion_matrix(y_test_labels, y_pred))

# Print timing information
print(f"Training time: {train_time:.2f} seconds")
print(f"Inference time: {inference_time:.2f} seconds")