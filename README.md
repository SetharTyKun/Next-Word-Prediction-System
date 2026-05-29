# 🔮 Khmer Next Word Prediction System

A statistical next-word prediction system for the Khmer language, built in MATLAB. The system combines Bigram, Trigram (with bigram backoff), and Vector (co-occurrence) models, all trained on a pre-tokenized Khmer corpus.

---

## 📁 Project Structure

```
Next-Word-Prediction-System/
├── khmer_tokenize.py       # Python tokenizer using khmer-nltk
├── english_tokenize.m      # MATLAB tokenizer for English corpus
├── khmer_raw.txt           # Original raw Khmer text corpus
├── khmer_data.txt          # Pre-tokenized Khmer corpus (words separated by spaces, UTF-8)
├── english_raw.txt         # Original raw English text corpus
├── english_data.txt        # Pre-tokenized English corpus
├── WordPrediction.m        # MATLAB: model training, evaluation, and export
├── Model.mat               # Auto-generated model file (created by WordPrediction.m)
└── PredictorApp.m          # MATLAB: GUI prediction app
```

---

## ⚙️ Setup & Installation

Follow these steps in order to go from raw corpus to a running prediction app.

### Step 1 — Prerequisites

Make sure you have the following installed:

- **Python 3.8+** — [Download here](https://www.python.org/downloads/)
- **MATLAB R2021a or later** — with no additional toolboxes required
- **pip** (comes bundled with Python)

---

### Step 2 — Install Python Dependencies

Open a terminal and install the required Python package:

```bash
pip install khmer-nltk
```

> `khmer-nltk` provides the Khmer word segmentation used by `khmer_tokenize.py`.

---

### Step 3 — Tokenize the Khmer Corpus

Run the Python tokenizer to convert the raw Khmer text into a space-separated word corpus:

```bash
python khmer_tokenize.py
```

This reads `khmer_raw.txt` and outputs `khmer_data.txt` (words separated by spaces, UTF-8 encoded).

> If you also want to use the English corpus, open MATLAB and run `english_tokenize.m` — it will process `english_raw.txt` and produce `english_data.txt`.

---

### Step 4 — Train the Prediction Models

1. Open **MATLAB**.
2. Set your working directory to the project folder:
   ```matlab
   cd('path/to/Next-Word-Prediction-System')
   ```
3. Open and run `WordPrediction.m`:
   ```matlab
   run('WordPrediction.m')
   ```

This script will:
- Load `khmer_data.txt` (and/or `english_data.txt`)
- Build Bigram, Trigram, and Vector (co-occurrence) models
- Evaluate model performance
- Export all models to **`Model.mat`**

Wait for the script to finish — you should see evaluation metrics printed in the MATLAB console.

---

### Step 5 — Launch the Prediction App

Once `Model.mat` has been generated, open and run the GUI app:

```matlab
run('PredictorApp.m')
```

The **PredictorApp** window will open. Type a Khmer word or phrase into the input field, and the app will suggest the most likely next word(s) based on the trained models.

---

## 🧠 How It Works

| Model | Description |
|---|---|
| **Bigram** | Predicts the next word based on the single preceding word |
| **Trigram** | Predicts using the two preceding words, falls back to bigram if unseen |
| **Vector** | Uses a word co-occurrence matrix to find contextually similar predictions |

---

## 📝 Notes

- All corpus files must be saved in **UTF-8** encoding for Khmer text to be processed correctly.
- `Model.mat` is auto-generated and does not need to be committed to version control.
- Re-run `WordPrediction.m` any time you update the corpus to rebuild the models.
