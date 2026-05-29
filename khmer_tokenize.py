from khmernltk import word_tokenize
import re

with open('khmer_raw.txt', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('\u17D4', '')  # Strip Khmer period (U+17D4) before tokenizing

words = word_tokenize(text)

# Keep only pure Khmer words (Khmer unicode range: U+1780-U+17FF)
khmer_words = [w for w in words if re.fullmatch(r'[\u1780-\u17FF]+', w)]

with open('khmer_data.txt', 'w', encoding='utf-8') as f:
    f.write(' '.join(khmer_words))

print(f'Total Khmer words: {len(khmer_words)}')
