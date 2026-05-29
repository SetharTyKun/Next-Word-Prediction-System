from khmercut import tokenize, seg_kcc
import re

# ── Khmer seed wordlist ────────────────────────────────────────────────────────
# Common Khmer words that may not appear standalone in the source text but are
# valid components of compound words.  Extend this list as needed.
SEED_WORDS = {
    # verbs / verb roots
    'ឆ្លង','កាត់','ឆ្លុះ','ឆ្លាត','វៃ','យល់','ដឹង','អប់','រំ','ចូល',
    'ចេញ','ទៅ','មក','ឡើង','ចុះ','ហើរ','ដើរ','ដាំ','ដំ','ស្ត','ថែ',
    'រក','ស្វែង','រក្សា','ការពារ','ជួយ','ទទួល','ផ្ដល','ផ្ដើម','ចាប់',
    'ចប់','បញ្ចប់','ចាំ','ដឹកនាំ','គ្រប','ត្រូវ','ប្រើ','ប្រាស','ប្រឹង',
    'ប្រែ','ផ្លាស','ផ្ដ','ទទួល','ខុស','ស្ថាប','រៀន','បង្រៀន','ណែ','នាំ',
    'ជំ','រុញ','ជំ','រះ','លើក','ទឹក','ចិត','ស្ថាប','នា','ឡើង','វិញ',
    'ការ','ពារ','សង','ត','ខំ','ប្រើ','ប្រាស','ក','ហ','ញ','ស','ម',
    'ចែក','រំ','លែ','ជំ','នួញ','ចំ','ណ','ណ','ណ',
    # nouns / noun roots
    'អាយុ','កាល','ខ្ពង','ខ្ពង់','ខ្ពស','ខ្ពស់','ជិត','ខាង','ទឹក',
    'ភ្លៀង','ភ្លើង','ផ្លូវ','ផ្ទះ','ដី','ព្រៃ','ភ្នំ','ទន្លេ','ស្ទឹង',
    'ជ','ន','ជន','ធម','ភាព','ចំណ','ដំណ','ទំ','ណ','ណ',
    'ស្ត','ម','ភ','ទ','ល','ស','ប','ន','ម','យ','រ','វ','ហ','អ','ព',
    'ថ','ខ','ឃ','គ','ជ','ឆ','ច','ដ','ឌ','ណ','ត','ថ','ទ','ធ',
    'ប','ផ','ភ','ម','យ','រ','ល','វ','ស','ហ','ឡ','អ',
    'ស្រ','ប','ក','ត','ញ','ន','ង','ម','យ','ស','ហ','វ',
    'ឯករាជ','ជ','ន','ម','ត','ស','ប','ក',
    # common 2-syllable words often used as components
    'ជំ','ន','នៃ','ដ','ត','ស','ប','ន','ម','យ','រ','វ',
    'ចំ','ណ','ព','ល','ស','ហ','អ','ដ','ត','ក','ឃ',
    'ឯក','រាជ','សា','មគ','គី','ដំ','ណ','ការ','ណ',
    'ស','ន','តិ','ភាព','យូ','ណ','ស','កូ','ចំ','ណ',
    'ប្រ','ជា','ជន','ស','ហ','គ','ម','ន','ជ',
    # reduplication components
    'ខ្ពង','ខ','ពង','ខ','ពស','ស',
    # words that appear in compounds but not standalone
    'ចាប','ព','ន','ក','ហ','ណ','ស','ម',
    'ហ','ន','ក','ត','ស','ម','ជ','ន',
}

# ── Build vocabulary ───────────────────────────────────────────────────────────
def build_vocab(text):
    """Run CRF tokenizer and collect all pure-Khmer tokens as vocab."""
    khmer_re = re.compile(r'^[ក-៿]+$')
    tokens = tokenize(text)
    vocab = set(w for w in tokens if khmer_re.match(w))
    # keep only 'atomic' words (≤ 3 KCCs) so we don't include compounds
    atomic = set(w for w in vocab if len(seg_kcc(w)) <= 3)
    atomic.update(SEED_WORDS)
    return atomic

# ── Maximum matching ───────────────────────────────────────────────────────────
def forward_max_match(word, dictionary, max_kcc=5):
    """
    Try to split `word` into sub-words found in `dictionary`.
    Uses KCC count as the length unit (more linguistically appropriate than chars).
    Returns list of sub-words, or [word] if no split found.
    """
    kccs = seg_kcc(word)
    n = len(kccs)
    if n <= 3:          # short enough — keep as-is
        return [word]

    result = []
    i = 0
    while i < n:
        matched = False
        for end in range(min(i + max_kcc, n), i, -1):
            candidate = ''.join(kccs[i:end])
            if candidate in dictionary:
                result.append(candidate)
                i = end
                matched = True
                break
        if not matched:
            # No match: consume one KCC and continue
            result.append(kccs[i])
            i += 1
    # Only accept the split if ALL parts are real words; otherwise return original
    if all(p in dictionary for p in result) and len(result) > 1:
        return result
    return [word]

# ── Main pipeline ──────────────────────────────────────────────────────────────
with open('khmer_raw.txt', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('។', '')   # strip Khmer period

# Build vocab from the full text
vocab = build_vocab(text)

# CRF tokenize
crf_words = tokenize(text)

khmer_re = re.compile(r'^[ក-៿]+$')
final_words = []
for w in crf_words:
    if khmer_re.match(w):
        final_words.extend(forward_max_match(w, vocab))
    # skip non-Khmer tokens (spaces, punctuation, numbers)

with open('khmer_data.txt', 'w', encoding='utf-8') as f:
    f.write(' '.join(final_words))

print(f"Total Khmer words: {len(final_words)}")
