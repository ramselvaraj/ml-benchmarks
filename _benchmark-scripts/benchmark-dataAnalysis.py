from pathlib import Path
import argparse
import re
import pandas as pd
import matplotlib.pyplot as plt


def split_dataset_modeltype(name):
    parts = name.split("_")
    if len(parts) < 2:
        return name, "unknown"
    return "_".join(parts[:-1]), parts[-1]


def normalize_arch_name(name):
    name = name.lower()
    replacements = {
        "gpu_cuda": "GPU CUDA",
        "gpu": "GPU",
        "fpga": "FPGA",
        "fpga_hls": "FPGA HLS",
        "cpu": "CPU",
        "cpu_sklearn": "CPU sklearn",
        "cuda": "CUDA",
        "hls": "HLS",
    }
    return replacements.get(name, name.replace("_", " ").upper())


def load_results(root):
    root = Path(root)
    acc_rows = []
    perf_rows = []

    for arch_dir in root.iterdir():
        if not arch_dir.is_dir():
            continue

        arch = normalize_arch_name(arch_dir.name)

        for experiment_dir in arch_dir.iterdir():
            if not experiment_dir.is_dir():
                continue

            dataset, model_type = split_dataset_modeltype(experiment_dir.name)

            acc_path = experiment_dir / "acc_results.csv"
            perf_path = experiment_dir / "perf_results.csv"

            if acc_path.exists():
                acc = pd.read_csv(acc_path)
                acc["dataset"] = dataset
                acc["model_type"] = model_type
                acc["architecture"] = arch
                acc["experiment"] = experiment_dir.name
                acc_rows.append(acc)

            if perf_path.exists():
                perf = pd.read_csv(perf_path)
                perf["dataset"] = dataset
                perf["model_type"] = model_type
                perf["architecture"] = arch
                perf["experiment"] = experiment_dir.name
                perf_rows.append(perf)

    acc_df = pd.concat(acc_rows, ignore_index=True) if acc_rows else pd.DataFrame()
    perf_df = pd.concat(perf_rows, ignore_index=True) if perf_rows else pd.DataFrame()

    return acc_df, perf_df


def safe_numeric(df, cols):
    for col in cols:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce")
    return df


def save_bar_plot(df, x, y, title, ylabel, out_path, group_col="architecture"):
    if df.empty or y not in df.columns:
        return

    plot_df = df.dropna(subset=[y]).copy()
    if plot_df.empty:
        return

    labels = sorted(plot_df[x].unique())
    groups = sorted(plot_df[group_col].unique())

    width = 0.8 / max(len(groups), 1)
    positions = range(len(labels))

    fig, ax = plt.subplots(figsize=(10, 5.5))

    for i, group in enumerate(groups):
        values = []
        for label in labels:
            subset = plot_df[(plot_df[x] == label) & (plot_df[group_col] == group)]
            values.append(subset[y].mean() if not subset.empty else None)

        offset = (i - (len(groups) - 1) / 2) * width
        ax.bar([p + offset for p in positions], values, width=width, label=group)

    ax.set_title(title, fontsize=14, fontweight="bold")
    ax.set_xlabel("")
    ax.set_ylabel(ylabel)
    ax.set_xticks(list(positions))
    ax.set_xticklabels(labels, rotation=25, ha="right")
    ax.grid(axis="y", alpha=0.25)
    ax.legend(title="Architecture")
    fig.tight_layout()
    fig.savefig(out_path, dpi=180)
    plt.close(fig)


def save_line_or_bar(df, y, title, ylabel, out_path):
    if df.empty or y not in df.columns:
        return

    plot_df = df.dropna(subset=[y]).copy()
    if plot_df.empty:
        return

    plot_df["label"] = plot_df["architecture"] + "\n" + plot_df["dtype"].astype(str) + "\nbs=" + plot_df["batch_size"].astype(str)

    grouped = (
        plot_df
        .groupby("label", as_index=False)[y]
        .mean()
        .sort_values(y, ascending=False)
    )

    fig, ax = plt.subplots(figsize=(11, 5.5))
    ax.bar(grouped["label"], grouped[y])
    ax.set_title(title, fontsize=14, fontweight="bold")
    ax.set_ylabel(ylabel)
    ax.set_xlabel("")
    ax.grid(axis="y", alpha=0.25)
    ax.tick_params(axis="x", rotation=25)
    fig.tight_layout()
    fig.savefig(out_path, dpi=180)
    plt.close(fig)


def save_accuracy_plot(acc_df, out_dir):
    needed = ["Train_Acc", "Val_Acc"]
    if acc_df.empty or not all(col in acc_df.columns for col in needed):
        return

    acc_df = safe_numeric(acc_df, ["Train_Acc", "Val_Acc", "Final_Loss", "Conv_Epochs"])

    for (dataset, model_type), group in acc_df.groupby(["dataset", "model_type"]):
        melted = group.melt(
            id_vars=["architecture", "Precision", "Batch_Size"],
            value_vars=["Train_Acc", "Val_Acc"],
            var_name="metric",
            value_name="accuracy",
        )

        melted["label"] = (
            melted["architecture"]
            + "\n"
            + melted["Precision"].astype(str)
            + "\nbs="
            + melted["Batch_Size"].astype(str)
        )

        fig, ax = plt.subplots(figsize=(11, 5.5))

        labels = list(melted["label"].unique())
        metrics = ["Train_Acc", "Val_Acc"]
        width = 0.35
        positions = range(len(labels))

        for i, metric in enumerate(metrics):
            values = []
            for label in labels:
                subset = melted[(melted["label"] == label) & (melted["metric"] == metric)]
                values.append(subset["accuracy"].mean() if not subset.empty else None)

            offset = (i - 0.5) * width
            ax.bar([p + offset for p in positions], values, width=width, label=metric.replace("_", " "))

        ax.set_title(f"{dataset.upper()} - {model_type.upper()} accuracy by architecture", fontsize=14, fontweight="bold")
        ax.set_ylabel("Accuracy")
        ax.set_ylim(0, 1.05)
        ax.set_xticks(list(positions))
        ax.set_xticklabels(labels, rotation=25, ha="right")
        ax.grid(axis="y", alpha=0.25)
        ax.legend()
        fig.tight_layout()

        filename = f"{dataset}_{model_type}_accuracy.png"
        fig.savefig(out_dir / filename, dpi=180)
        plt.close(fig)


def save_performance_plots(perf_df, out_dir):
    if perf_df.empty:
        return

    perf_df = safe_numeric(
        perf_df,
        [
            "throughput",
            "latency_p50",
            "latency_p99",
            "energy_total",
            "avg_power",
            "achieved_gflops",
            "utilization_pct",
            "arith_intensity",
            "batch_size",
        ],
    )

    metrics = [
        ("throughput", "Throughput", "Samples / second"),
        ("latency_p50", "Median latency", "Latency p50"),
        ("latency_p99", "Tail latency", "Latency p99"),
        ("energy_total", "Total energy", "Energy"),
        ("avg_power", "Average power", "Power"),
        ("achieved_gflops", "Achieved GFLOPS", "GFLOPS"),
        ("utilization_pct", "Utilization", "Utilization %"),
    ]

    for (dataset, model_type), group in perf_df.groupby(["dataset", "model_type"]):
        for metric, title, ylabel in metrics:
            filename = f"{dataset}_{model_type}_{metric}.png"
            save_line_or_bar(
                group,
                metric,
                f"{dataset.upper()} - {model_type.upper()} {title} by architecture",
                ylabel,
                out_dir / filename,
            )


def save_summary_plots(acc_df, perf_df, out_dir):
    if not acc_df.empty and "Val_Acc" in acc_df.columns:
        acc_df = safe_numeric(acc_df, ["Val_Acc"])
        acc_df["dataset_model"] = acc_df["dataset"] + "_" + acc_df["model_type"]
        save_bar_plot(
            acc_df,
            x="dataset_model",
            y="Val_Acc",
            title="Validation accuracy across datasets and models",
            ylabel="Validation accuracy",
            out_path=out_dir / "summary_validation_accuracy.png",
        )

    if not perf_df.empty and "throughput" in perf_df.columns:
        perf_df = safe_numeric(perf_df, ["throughput"])
        perf_df["dataset_model"] = perf_df["dataset"] + "_" + perf_df["model_type"]
        save_bar_plot(
            perf_df,
            x="dataset_model",
            y="throughput",
            title="Throughput across datasets and models",
            ylabel="Samples / second",
            out_path=out_dir / "summary_throughput.png",
        )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default="_results", help="Root folder containing architecture folders")
    parser.add_argument("--out", default="plots", help="Output folder for generated plots")
    args = parser.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    acc_df, perf_df = load_results(args.root)

    if acc_df.empty and perf_df.empty:
        raise RuntimeError("No acc_results.csv or perf_results.csv files found.")

    save_accuracy_plot(acc_df, out_dir)
    save_performance_plots(perf_df, out_dir)
    save_summary_plots(acc_df, perf_df, out_dir)

    if not acc_df.empty:
        acc_df.to_csv(out_dir / "combined_accuracy_results.csv", index=False)

    if not perf_df.empty:
        perf_df.to_csv(out_dir / "combined_performance_results.csv", index=False)

    print(f"Saved plots to: {out_dir.resolve()}")


if __name__ == "__main__":
    main()