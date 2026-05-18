% ============================================
% Part 1 :  Data Preparation
% ============================================

% Read & Filter
text = fileread('data.txt');                                         % read file                                     text = 'ប្រពៃណី ការអប់រំ  នៅ ប្រទេស កម្ពុជា ... ការអប់រំ'
words = strsplit(text);                                             % Split word by ONE space             words = {'ប្រពៃណី', 'ការអប់រំ', '', 'នៅ', 'ប្រទេស', '', 'កម្ពុជា', ... , 'ការអប់រំ'}
words = words(~cellfun('isempty', words));               ​​​​% Filter out empty cell                     words = {'ប្រពៃណី', 'ការអប់រំ', 'នៅ', 'ប្រទេស', 'កម្ពុជា', ..., 'ការអប់រំ'}

% Build Vocabulary Mapper
vocab = unique(words);                                         % Only unique word + sort              vocab = {'កម្ពុជា', 'ការអប់រំ', 'នៅ', 'ប្រទេស', 'ប្រពៃណី', ...}
vocabSize = numel(vocab);

% Split words: 80% For Training & 20% For Testing
N = numel(words);
trainSize = floor(0.8 * N);
trainWords = words(1: trainSize);
testWords = words(trainSize + 1 : end);

% ============================================
% Part 2 : N-gram Model: Bigram, Trigram, Vector
% ============================================

% ===============
% Bigram Model
% ===============

bigramCount = zeros(vocabSize, vocabSize);
for i = 1:numel(trainWords)-1
    word1 = trainWords{i};
    word2 = trainWords{i+1};
    idx1 = find(strcmp(vocab, word1));
    idx2 = find(strcmp(vocab, word2));
    bigramCount(idx1, idx2) = bigramCount(idx1, idx2) + 1;
end










