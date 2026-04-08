# Project Standards
## Scope
Common benchmark rules for CPU, CUDA, and FPGA implementations.

Workloads:
1. `iris_perceptron`
2. `mnist_cnn`
3. `har_svm`

## Common rules
- Same dataset split, preprocessing, label mapping, model behavior, and metric definitions across all devices.
- Report time in **ms**, throughput in **samples_per_sec**, memory in **bytes**, and quality metrics in **[0,1]**.
- Exclude compile time, synthesis/bitstream generation, file I/O, and CSV writing from benchmark timing.
- Use the same timing stage names everywhere:
  - `input_staging_ms`
  - `forward_ms`
  - `loss_metric_ms`
  - `backward_ms`
  - `update_ms`
- Required percentiles: **p50** and **p95**.
- Every run must include: `run_id`, timestamp, workload, implementation, device class, device name, train file, test file, seed, hyperparameters, parameter count, train sample count, and test sample count.

## Workload 1: Iris binary perceptron
**Dataset**
- Files: `iris_train.csv`, `iris_test.csv`
- `virginica` is already removed.
- Binary classes only:
  - `setosa -> -1`
  - `versicolor -> +1`
- No extra class filtering or train/test split step inside the implementation.
- Use all feature columns except label.
- Standardize features using **training-set mean/std only**.
- If stddev `< 1e-6`, replace with `1.0`.

**Model**
- Binary perceptron
- Input dimension: **4**
- Score: `w.x + b`
- Prediction: sign of score
- Parameters: **4 weights + 1 bias = 5**
- Initialize weights and bias to zero

**Training**
- Epochs: **30**
- Batch size: **16**
- Learning rate: **0.10**
- Shuffle seed: **42**
- Update rule: average perceptron update over misclassified samples only
- Reporting loss: mean perceptron loss `max(0, -y * score)`

**Required metrics**
- loss, accuracy, precision, recall, F1
- TP, TN, FP, FN

## Workload 2: MNIST tiny CNN
**Dataset**
- Files: `mnist_train.csv`, `mnist_test.csv`
- First column is label `[0..9]`
- Remaining **784** columns are flattened `28 x 28` grayscale pixels
- Normalize pixel values by `255.0`
- No augmentation

**Model**
1. `Conv2D(1 -> 8, 3x3, stride 1, no padding)`
2. `ReLU`
3. `MaxPool2D(2x2, stride 2)`
4. `Conv2D(8 -> 16, 3x3, stride 1, no padding)`
5. `ReLU`
6. `MaxPool2D(2x2, stride 2)`
7. `Flatten(400)`
8. `FullyConnected(400 -> 10)`
9. `Softmax + cross-entropy`

**Reference shapes**
- input: `1 x 28 x 28`
- conv1: `8 x 26 x 26`
- pool1: `8 x 13 x 13`
- conv2: `16 x 11 x 11`
- pool2: `16 x 5 x 5`
- flatten: `400`
- logits: `10`

**Training**
- Parameter count: **5258**
- Epochs: **3**
- Batch size: **64**
- Learning rate: **0.02**
- Init seed: **42**
- He init for weights, zero init for biases

**Required metrics**
- loss, accuracy
- macro precision, macro recall, macro F1
- confusion matrix

## Workload 3: HAR multiclass linear SVM
**Dataset**
- Files: `har_train.csv`, `har_test.csv`
- Label column: `class`
- All other columns are features
- Train and test must use the same schema
- Encode non-numeric feature columns using mappings fit on the **training set only**
- Standardize features using **training-set mean/std only**
- If stddev `< 1e-6`, replace with `1.0`

**Model**
- Multiclass **linear one-vs-rest SVM**
- Input dimension: number of feature columns
- Output classes: labels present in training set
- Parameters: `C * D` weights + `C` biases
- Score per class: `w_c.x + b_c`
- Prediction: `argmax(score_c)`
- Weight init: normal `(0, 0.01)`, seed `42`
- Bias init: zero

**Training**
- Epochs: **25**
- Batch size: **128**
- Learning rate: **0.01**
- `reg_lambda = 1e-4`
- Shuffle seed: **42**
- Loss: one-vs-rest hinge loss with L2 regularization

**Required metrics**
- hinge loss, accuracy
- macro precision, macro recall, macro F1
- confusion matrix

## Required reporting files
Use the same CSV schemas for every implementation.

### `run_summary.csv` (one row per run)
Required columns:
- `run_id`
- `timestamp_utc`
- `workload_id`
- `model_name`
- `implementation_name`
- `device_class`
- `device_name`
- `train_file`
- `test_file`
- `seed`
- `epochs`
- `batch_size`
- `learning_rate`
- `reg_lambda`
- `train_samples`
- `test_samples`
- `input_dim`
- `num_classes`
- `param_count`
- `total_training_wall_ms`
- `avg_epoch_ms`
- `avg_train_batch_ms`
- `train_throughput_samples_per_sec`
- `input_staging_ms`
- `forward_ms`
- `loss_metric_ms`
- `backward_ms`
- `update_ms`
- `final_train_loss`
- `final_train_accuracy`
- `final_test_loss`
- `final_test_accuracy`
- `final_test_precision`
- `final_test_recall`
- `final_test_f1`
- `final_test_macro_precision`
- `final_test_macro_recall`
- `final_test_macro_f1`
- `total_infer_ms`
- `avg_infer_batch_ms`
- `avg_infer_sample_ms`
- `infer_batch_p50_ms`
- `infer_batch_p95_ms`
- `infer_throughput_samples_per_sec`
- `single_sample_mean_ms`
- `single_sample_min_ms`
- `single_sample_max_ms`
- `single_sample_p50_ms`
- `single_sample_p95_ms`
- `tp`
- `tn`
- `fp`
- `fn`

Rules:
- Use `NA` for metrics not applicable to a workload.
- Iris uses `final_test_precision`, `final_test_recall`, `final_test_f1`.
- MNIST and HAR use `final_test_macro_precision`, `final_test_macro_recall`, `final_test_macro_f1`.

### `epoch_metrics.csv` (one row per epoch)
Required columns:
- `run_id`
- `epoch`
- `train_loss`
- `train_accuracy`
- `test_loss`
- `test_accuracy`
- `test_precision`
- `test_recall`
- `test_f1`
- `test_macro_precision`
- `test_macro_recall`
- `test_macro_f1`
- `epoch_time_ms`
- `epoch_throughput_samples_per_sec`

### `latency_trace.csv` (one row per latency sample)
Required columns:
- `run_id`
- `workload_id`
- `trace_type` (`train_batch`, `infer_batch`, `single_sample`)
- `epoch`
- `batch_index`
- `sample_count`
- `latency_ms`
