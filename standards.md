# Project Standards
## Scope
This file defines the common benchmark standard for the three project workloads so CPU, CUDA, and FPGA results are directly comparable.

Workloads covered:
1. `iris_perceptron`
2. `mnist_cnn`
3. `har_svm`

## Common rules
- Model behavior must match across devices. Hardware-specific optimizations are allowed, but not changes to dataset split, preprocessing, label mapping, prediction rule, loss, or update rule.
- Report all times in **ms**, throughput in **samples_per_sec**, memory in **bytes**, and quality metrics as fractions in **[0,1]**.
- Timings must **exclude** source compilation, FPGA synthesis/bitstream generation, CSV parsing/loading, and CSV writing.
- Use the same stage names in all implementations:
  - `input_staging_ms`
  - `forward_ms`
  - `loss_metric_ms`
  - `backward_ms`
  - `update_ms`
- Percentiles must use the same definition everywhere: sort values and use linear interpolation. Required percentiles: **p50** and **p95**.
- Every run must report: `run_id`, timestamp, workload, implementation name, device class (`cpu`/`cuda`/`fpga`), device name, train file, test file, seed, hyperparameters, parameter count, train sample count, and test sample count.

## Workload 1: Iris binary perceptron
**Dataset**
- File: `iris.csv`
- Use only two classes:
  - negative class `-1` = `setosa`
  - positive class `+1` = `versicolor`
- Drop `virginica` rows.
- Split: stratified **80/20**, seed **42**.
- Standardize features using **training-split mean/std only**.
- If stddev `< 1e-6`, replace with `1.0`.

**Model**
- Binary perceptron
- Input dimension: **4**
- Output: sign of `w.x + b`
- Parameters: **4 weights + 1 bias = 5 total**
- Initialization: all zeros

**Training standard**
- Epochs: **30**
- Batch size: **16**
- Learning rate: **0.10**
- Shuffle seed: **42**
- Update rule: average perceptron update over misclassified samples only
- Reporting loss: mean perceptron loss `max(0, -y * score)`

**Required quality metrics**
- loss, accuracy, precision, recall, F1
- TP, TN, FP, FN

## Workload 2: MNIST tiny CNN
**Dataset**
- Files: `mnist_train.csv`, `mnist_test.csv`
- First column = label in `[0..9]`
- Remaining **784** columns = flattened `28 x 28` grayscale image
- Normalize pixels by dividing by `255.0`
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

**Reference tensor shapes**
- input: `1 x 28 x 28`
- conv1: `8 x 26 x 26`
- pool1: `8 x 13 x 13`
- conv2: `16 x 11 x 11`
- pool2: `16 x 5 x 5`
- flatten: `400`
- logits: `10`

**Parameter count**
- Total trainable parameters: **5258**

**Training standard**
- Epochs: **3**
- Batch size: **64**
- Learning rate: **0.02**
- Initialization seed: **42**
- Weight initialization: He init
- Bias initialization: zero

**Required quality metrics**
- loss, accuracy
- macro precision, macro recall, macro F1
- confusion matrix

## Workload 3: HAR multiclass linear SVM
**Dataset**
- Files: `har_train.csv`, `har_test.csv`
- Label column: `class` (if not present, use the explicit label column agreed by the team and keep it identical across implementations)
- All non-label columns are features
- Train and test must use the same schema and delimiter
- Non-numeric feature columns must be encoded using a mapping fit on the **training set only**
- All features must then be standardized using **training-set mean/std only**
- If stddev `< 1e-6`, replace with `1.0`

**Model**
- Multiclass **linear one-vs-rest SVM**
- Input dimension: **D = number of feature columns**
- Output classes: **C = number of labels in the training set**
- Parameters: `C * D` weights + `C` biases
- Score: `score_c = w_c.x + b_c`
- Prediction: `argmax_c(score_c)`
- Weight init: random normal mean `0`, std `0.01`, seed `42`
- Bias init: zero

**Training standard**
- Epochs: **25**
- Batch size: **128**
- Learning rate: **0.01**
- Regularization: `reg_lambda = 1e-4`
- Shuffle seed: **42**
- Loss: one-vs-rest hinge loss with L2 regularization

**Required quality metrics**
- hinge loss, accuracy
- macro precision, macro recall, macro F1
- confusion matrix

## Required reporting files
Use these CSV files for every run.

### 1. `run_summary.csv` (one row per run)
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
- Use `NA` for metrics that do not apply to a workload.
- For Iris, `final_test_precision/recall/f1` are the binary metrics.
- For MNIST and HAR, use the `final_test_macro_*` fields.

### 2. `epoch_metrics.csv` (one row per epoch)
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

### 3. `latency_trace.csv` (one row per measured latency)
Required columns:
- `run_id`
- `workload_id`
- `trace_type` (`train_batch`, `infer_batch`, `single_sample`)
- `epoch`
- `batch_index`
- `sample_count`
- `latency_ms`

### 4. `confusion_matrix.csv` (required for MNIST and HAR, optional for Iris)
Required columns:
- `run_id`
- `workload_id`
- `true_class`
- `pred_class`
- `count`

## Final comparison rule
Cross-device comparisons must be done only when all three implementations use the same:
- dataset files
- split and preprocessing rules
- model definition
- hyperparameters
- metric definitions
- timing boundaries
