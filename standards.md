# ML FPGA Project Standards
# Purpose

This document defines the **hardware-agnostic project standard** for the benchmark implementations derived from the current CUDA reference code:

  

1. **Iris binary perceptron** (`iris_perceptron.cu`)

2. **MNIST tiny CNN** (`mnist_cnn.cu`)

  

The goal is to make CPU, CUDA, and FPGA implementations directly comparable in terms of:

- model correctness

- dataset handling

- preprocessing

- training behavior

- evaluation behavior

- latency and throughput reporting

- CSV outputs for later analysis and plotting

  

This standard is intentionally **hardware-agnostic**. Device-specific details may be reported in extra columns, but the required metrics and semantics below must stay consistent across all implementations.

  

---

  

# 1. Required benchmark workloads

  

### Workload A: Iris binary perceptron

- **Dataset file:** `iris.csv`

- **Task:** binary classification

- **Input features:** 4 real-valued features per sample

- **Output:** class in `{-1, +1}`

- **Reference implementation source:** `iris_perceptron.cu`

  

### Workload B: MNIST tiny CNN

- **Dataset files:** `mnist_train.csv`, `mnist_test.csv`

- **Task:** 10-class classification

- **Input features:** 28 x 28 grayscale image flattened to 784 values in CSV

- **Output:** class in `{0,1,2,3,4,5,6,7,8,9}`

- **Reference implementation source:** `mnist_cnn.cu`

  

---

  

# 2. Cross-implementation rules

  

All CPU, CUDA, and FPGA implementations must follow these rules.

  

### 2.1 Model semantics must match

Optimizations are allowed, but they must not change:

- the dataset split

- label mapping

- preprocessing

- model architecture

- loss definition

- prediction rule

- update rule

- reported metric definitions

  

### 2.2 Units and numeric conventions

- All time values must be reported in **milliseconds**.

- Throughput must be reported in **samples_per_sec**.

- Accuracy, precision, recall, and F1 must be stored in CSV as **fractions in [0,1]**, not percentages.

- Loss values must be reported as **mean loss per sample**.

- Memory values must be reported in **bytes**.

  

### 2.3 What timing must include

The required runtime metrics must:

- include only the benchmarked runtime path

- exclude source compilation

- exclude FPGA synthesis / bitstream generation

- exclude model initialization unless explicitly reported as an optional deployment metric

- exclude dataset file loading and CSV parsing from training/inference timing

- exclude report CSV writing

  

### 2.4 Reproducibility metadata

Each run must report:

- dataset names / files used

- seeds used

- hyperparameters used

- implementation name

- device class (`cpu`, `cuda`, `fpga`)

- device name

- code version or git commit if available

  

### 2.5 Common timing vocabulary

To stay hardware-agnostic, use these common stage names:

- `input_staging_ms`

- `forward_ms`

- `loss_metric_ms`

- `backward_ms`

- `update_ms`

  

Interpretation by platform:

- **CUDA:** `input_staging_ms` usually includes host-to-device transfer and any staging copies

- **FPGA:** `input_staging_ms` usually includes DMA/input buffering/host-accelerator transfer

- **CPU:** `input_staging_ms` is usually `0` or the time spent copying/repacking batch input into the compute buffer

  

Device-specific extra breakdowns are allowed, but the common fields above are mandatory.

  

### 2.6 Percentile convention

For latency percentiles, use the same convention everywhere:

- sort the observed samples

- compute percentile by linear interpolation between neighboring ranks

- report at minimum **p50** and **p95**

  

This matches the behavior used in the CUDA reference files.

  

---

  

# 3. Workload standard: Iris binary perceptron

  

## 3.1 Dataset standard

- Input file: `iris.csv`

- Expected row content: 4 numeric feature values and 1 label field

- Feature count: **4**

- Total original Iris classes: **3**

- Classes used for this workload: **exactly 2**

### 3.1.1 Fixed class mapping

The current CUDA loader keeps the first two classes encountered and discards the third. That is too ambiguous for a multi-team project.

  

**Project standard:** the class mapping must be fixed explicitly.

  

Use:

- **negative class (`-1`)** = `Iris-setosa` or equivalent canonical setosa label

- **positive class (`+1`)** = `Iris-versicolor` or equivalent canonical versicolor label

- discard `Iris-virginica`

  

If the file uses slightly different strings such as `setosa`, `versicolor`, `virginica`, the loader may normalize them, but the final mapping must still match the standard above.

  

### 3.1.2 Train/test split

- Split method: **stratified split**

- Train ratio: **0.80**

- Test ratio: **0.20**

- Split seed: **42**

  

### 3.1.3 Preprocessing

- Compute feature-wise mean and standard deviation **on the training split only**

- Standardize both train and test using those training statistics

- If any standard deviation is below `1e-6`, replace it with `1.0`

  

### 3.1.4 Dataset metadata that must be reported

- total rows read

- total valid rows

- train sample count

- test sample count

- discarded rows from non-target class

- negative class label

- positive class label

- train negative count

- train positive count

- test negative count

- test positive count

  

## 3.2 Model architecture standard

Model must be a **binary perceptron**:

- input dimension: **4**

- trainable weights: **4**

- trainable bias: **1**

- total trainable parameters: **5**

  

Prediction:

- score = `w.x + b`

- predicted label = `+1` if score `>= 0`, else `-1`

  

Initialization:

- weights initialized to **0**

- bias initialized to **0**

  

## 3.3 Training rule standard

The training rule must match the CUDA reference semantics:

- compute predictions for the batch

- identify misclassified samples

- accumulate perceptron updates only from misclassified samples

- if `m` misclassified samples exist in the batch:

  - `w <- w + (lr / m) * sum(y_i * x_i)` over misclassified samples

  - `b <- b + (lr / m) * sum(y_i)` over misclassified samples

- if `m = 0`, perform no parameter update

  

Loss for reporting:

- perceptron loss per sample = `max(0, -y * score)`

- reported batch/epoch/test loss = mean of that value

  

Default hyperparameters from reference:

- epochs = **30**

- batch_size = **16**

- learning_rate = **0.10**

- shuffle seed = **42**

  

## 3.4 Evaluation metrics required for Iris

Because this is binary classification, all of the following are required:

- loss

- accuracy

- precision

- recall

- F1

- TP

- TN

- FP

- FN

- total inference time

- average batch latency

- average sample latency

- batch latency p50

- batch latency p95

- inference throughput

- single-sample latency mean/min/max/p50/p95

  

---

  

# 4. Workload standard: MNIST tiny CNN

## 4.1 Dataset standard

- Train file: `mnist_train.csv`

- Test file: `mnist_test.csv`

- Number of classes: **10**

- Input image size: **28 x 28**

- Channels: **1**

- Flattened CSV feature count per sample: **784**

  

Expected CSV format:

- first column = integer class label in `[0,9]`

- next 784 columns = pixel intensities in `[0,255]`

- optional header row may be present and should be skipped safely

  

## 4.2 Preprocessing

- convert pixels to floating point

- normalize each pixel by dividing by `255.0`

- no additional mean/std normalization

- no data augmentation

  

## 4.3 Model architecture standard

The architecture must match the reference exactly:

  

1. `Conv2D(1 -> 8, kernel=3x3, stride=1, padding=0)`

2. `ReLU`

3. `MaxPool2D(kernel=2x2, stride=2)`

4. `Conv2D(8 -> 16, kernel=3x3, stride=1, padding=0)`

5. `ReLU`

6. `MaxPool2D(kernel=2x2, stride=2)`

7. `Flatten`

8. `FullyConnected(400 -> 10)`

9. `Softmax + cross-entropy loss` for training/evaluation

  

Tensor shapes:

- input: `1 x 28 x 28`

- conv1 output: `8 x 26 x 26`

- pool1 output: `8 x 13 x 13`

- conv2 output: `16 x 11 x 11`

- pool2 output: `16 x 5 x 5`

- flatten: `400`

- logits: `10`

  

Trainable parameter count:

- conv1: `8*1*3*3 + 8 = 80`

- conv2: `16*8*3*3 + 16 = 1168`

- fc: `10*400 + 10 = 4010`

- total: **5258**

  

## 4.4 Initialization and optimization

Initialization:

- convolution and fully connected weights: **He initialization**

- all biases: **0**

- initialization seed: **42**

  

Optimization:

- SGD without momentum

- batch gradient averaged by batch size before update

  

Default hyperparameters from reference:

- epochs = **3**

- batch_size = **64**

- learning_rate = **0.02**

- shuffle seed = **123**

  

## 4.5 Evaluation metrics required for MNIST

Required:

- loss

- accuracy

- total inference time

- average batch latency

- average sample latency

- batch latency p50

- batch latency p95

- inference throughput

- single-sample latency mean/min/max/p50/p95

  

Not required for the baseline standard:

- precision/recall/F1

- per-class confusion matrix

  

Those may be added later in an optional validation extension, but they are not mandatory because the current CUDA reference does not compute them.

  

---

  

# 5. Common metrics to compare across CPU, CUDA, and FPGA

  

These are the **shared comparison metrics** that every implementation must report wherever applicable.

  

## 5.1 Run metadata

- `run_id`

- `timestamp_utc`

- `project_name`

- `workload_name`

- `model_name`

- `task_type`

- `implementation_name`

- `device_class`

- `device_name`

- `code_version`

- `dataset_name`

- `train_file`

- `test_file`

- `numeric_precision`

- `epochs`

- `batch_size`

- `learning_rate`

- `seed_split`

- `seed_init`

- `seed_shuffle`

  

## 5.2 Dataset/model metadata

- `num_train_samples`

- `num_test_samples`

- `num_input_features`

- `num_output_classes`

- `num_classes_used`

- `discarded_samples`

- `parameter_count`

- `parameter_bytes`

- `activation_bytes_per_batch_est`

  

## 5.3 Training performance metrics

- `train_total_wall_ms`

- `train_measured_ms`

- `train_avg_epoch_ms`

- `train_total_batches`

- `train_avg_batch_ms`

- `train_throughput_samples_per_sec`

- `input_staging_ms`

- `forward_ms`

- `loss_metric_ms`

- `backward_ms`

- `update_ms`

- `forward_share_pct`

- `backward_share_pct`

- `update_share_pct`

- `final_train_loss`

- `final_train_accuracy`

  

Definitions:

- `train_measured_ms = input_staging_ms + forward_ms + loss_metric_ms + backward_ms + update_ms`

- `train_avg_batch_ms = train_measured_ms / train_total_batches`

- `train_throughput_samples_per_sec = total_training_samples_processed / (train_measured_ms / 1000)`

- `total_training_samples_processed = num_train_samples * epochs`

  

## 5.4 Inference performance metrics

- `final_test_loss`

- `final_test_accuracy`

- `eval_total_infer_ms`

- `eval_avg_batch_ms`

- `eval_avg_sample_ms`

- `eval_batch_p50_ms`

- `eval_batch_p95_ms`

- `eval_throughput_samples_per_sec`

  

Definitions:

- `eval_avg_batch_ms = eval_total_infer_ms / eval_num_batches`

- `eval_avg_sample_ms = eval_total_infer_ms / num_test_samples`

- `eval_throughput_samples_per_sec = num_test_samples / (eval_total_infer_ms / 1000)`

  

## 5.5 Task-specific quality metrics

For **binary classification workloads** such as Iris, also report:

- `final_test_precision`

- `final_test_recall`

- `final_test_f1`

- `final_test_tp`

- `final_test_tn`

- `final_test_fp`

- `final_test_fn`

  

For **multiclass workloads** such as baseline MNIST tiny CNN, these fields may be left blank.

  

## 5.6 Single-sample latency benchmark

All implementations must run the same microbenchmark style used by the reference code:

- warmup iterations = **20**

- measured repetitions = **200**

- batch size = **1**

- use a fixed test sample index for reproducibility; baseline standard = **test sample 0**

  

Required outputs:

- `single_warmup_runs`

- `single_measurement_runs`

- `single_mean_ms`

- `single_min_ms`

- `single_max_ms`

- `single_p50_ms`

- `single_p95_ms`

  

This is separate from full-test-set inference timing. Both are required because they answer different questions:

- full-test-set inference measures realistic throughput and batched latency

- single-sample benchmark measures micro-latency and jitter

  

---

  

# 6. CSV reporting standard

  

A single summary row is not enough to support the analysis and plotting this project will need. Therefore the project standard uses **three CSV files**.

  

## 6.1 Mandatory file 1: `run_summary.csv`

One row per benchmark run.

  

### Required columns

```csv

run_id,timestamp_utc,project_name,workload_name,model_name,task_type,implementation_name,device_class,device_name,code_version,dataset_name,train_file,test_file,numeric_precision,target_classes,num_train_samples,num_test_samples,num_input_features,num_output_classes,num_classes_used,discarded_samples,negative_class_label,positive_class_label,train_split_ratio,stratified_split,standardization_applied,normalization_applied,seed_split,seed_init,seed_shuffle,epochs,batch_size,learning_rate,parameter_count,parameter_bytes,activation_bytes_per_batch_est,train_total_wall_ms,train_measured_ms,train_avg_epoch_ms,train_total_batches,train_avg_batch_ms,train_throughput_samples_per_sec,input_staging_ms,forward_ms,loss_metric_ms,backward_ms,update_ms,forward_share_pct,backward_share_pct,update_share_pct,final_train_loss,final_train_accuracy,final_test_loss,final_test_accuracy,final_test_precision,final_test_recall,final_test_f1,final_test_tp,final_test_tn,final_test_fp,final_test_fn,eval_total_infer_ms,eval_avg_batch_ms,eval_avg_sample_ms,eval_batch_p50_ms,eval_batch_p95_ms,eval_throughput_samples_per_sec,single_warmup_runs,single_measurement_runs,single_mean_ms,single_min_ms,single_max_ms,single_p50_ms,single_p95_ms,notes

```

  

### Rules

- Use one row per execution of a benchmark configuration.

- Leave non-applicable fields blank rather than inventing values.

- `target_classes` may be a text field such as `setosa|versicolor` or `0|1|...|9`.

- `notes` is optional and may contain things like `fp32_baseline`, `fixed16_variant`, or `timing excludes DMA setup`.

  

## 6.2 Mandatory file 2: `epoch_metrics.csv`

One row per epoch.

  

### Required columns

```csv

run_id,epoch_index,train_samples_seen,train_loss,train_accuracy,epoch_measured_ms,epoch_throughput_samples_per_sec,input_staging_ms,forward_ms,loss_metric_ms,backward_ms,update_ms,test_loss,test_accuracy,test_precision,test_recall,test_f1,test_tp,test_tn,test_fp,test_fn,eval_avg_batch_ms

```

  

### Why this file is mandatory

This file enables:

- training loss curves

- training accuracy curves

- generalization curves

- epoch time plots

- throughput-over-epoch plots

- stage breakdown over training

  

## 6.3 Mandatory file 3: `latency_trace.csv`

One row per measured latency sample.

  

### Required columns

```csv

run_id,benchmark_type,rep_index,batch_index,batch_size,sample_count,latency_ms,is_warmup

```

  

### Allowed values for `benchmark_type`

- `eval_batch`

- `single_sample`

  

### Rules

- For `eval_batch`, record one row per evaluation batch latency with `is_warmup=0`.

- For `single_sample`, record all warmup and measured repetitions.

- Warmup rows are useful because they let the team verify that warmup was excluded from final summary statistics.

  

### Why this file is mandatory

This file enables:

- latency histograms

- box plots

- jitter analysis

- percentile recomputation

- cross-device latency distribution comparisons

  

---

  

# 7. Optional hardware-specific extension columns

  

Extra columns are allowed, but they must not replace the common columns.

  

Recommended naming:

- CUDA-specific: prefix with `cuda_`

- CPU-specific: prefix with `cpu_`

- FPGA-specific: prefix with `fpga_`

  

Examples:

- `cuda_h2d_ms`

- `cuda_d2h_ms`

- `fpga_dma_in_ms`

- `fpga_dma_out_ms`

- `fpga_kernel_pipeline_fill_ms`

- `cpu_preprocess_copy_ms`

  

These are useful, but the shared comparison must still be based on the common fields defined in Sections 5 and 6.

  

---

  

# 8. Baseline run settings to be used by all teams

  

Unless a sweep is being run, the baseline comparison settings are:

  

### Iris perceptron baseline

- dataset = `iris.csv`

- classes = `setosa` vs `versicolor`

- split = stratified 80/20

- standardization = train-only mean/std

- epochs = 30

- batch_size = 16

- learning_rate = 0.10

- parameter init = zeros

  

### MNIST tiny CNN baseline

- train dataset = `mnist_train.csv`

- test dataset = `mnist_test.csv`

- normalization = divide by 255

- architecture = fixed tiny CNN from Section 4

- epochs = 3

- batch_size = 64

- learning_rate = 0.02

- initialization = He weights, zero bias

  

---

  
# 9. Minimum acceptance checklist for each implementation

  

A CPU, CUDA, or FPGA implementation is considered compliant only if it:

- uses the correct dataset files

- uses the correct preprocessing

- uses the correct model architecture/update rule

- uses the correct seeds and baseline hyperparameters unless the run is explicitly marked as a sweep/variant

- produces `run_summary.csv`

- produces `epoch_metrics.csv`

- produces `latency_trace.csv`

- reports all required shared metrics in the correct units

- leaves non-applicable fields blank instead of fabricating values