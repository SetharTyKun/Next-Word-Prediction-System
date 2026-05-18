🔮 Khmer Next Word Prediction System
A statistical next-word prediction system for the Khmer language, built in MATLAB. The system combines Bigram, Trigram (with bigram backoff), and Vector (co-occurrence) models, all trained on a pre-tokenized Khmer corpus.

📁 Project Structure
Next-Word-Prediction-System/

├── tokenization.py                 # Python tokenizer using khmer-nltk

├── raw.txt                         # Original raw Khmer text corpus

├── data.txt                        # Pre-tokenized corpus (words separated by spaces, UTF-8)

├── WordPrediction.m                # MATLAB: model training, evaluation, and export

├── Model.mat                       # Auto-generated model file (created by WordPrediction.m)

├── PredictorApp.m                  # MATLAB: GUI prediction app
