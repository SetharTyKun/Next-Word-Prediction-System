% ============================================
% Part 1 :  Data Preparation
% ============================================

% Read & Filter
text = fileread('data.txt');                                            % read file                                     text = 'ប្រពៃណី ការអប់រំ  នៅ ប្រទេស កម្ពុជា ... ការអប់រំ'
words = strsplit(text);                                                 % Split word by ONE space             words = {'ប្រពៃណី', 'ការអប់រំ', '', 'នៅ', 'ប្រទេស', '', 'កម្ពុជា', ... , 'ការអប់រំ'}
words = words(~cellfun('isempty', words));                  % Filter out empty cell                     words = {'ប្រពៃណី', 'ការអប់រំ', 'នៅ', 'ប្រទេស', 'កម្ពុជា', ..., 'ការអប់រំ'}

% Build Vocabulary Mapper
vocab = unique(words);                                              % Only unique word + sort              vocab = {'កម្ពុជា', 'ការអប់រំ', 'នៅ', 'ប្រទេស', 'ប្រពៃណី', ...}
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

%
bigramCount = zeros(vocabSize, vocabSize);
for i = 1:numel(trainWords)-1
    word1 = trainWords{i};
    word2 = trainWords{i+1};
    idx1 = find(strcmp(vocab, word1));
    idx2 = find(strcmp(vocab, word2));
    bigramCount(idx1, idx2) = bigramCount(idx1, idx2) + 1;
end

bigramProb = zeros(vocabSize, vocabSize);
for i = 1:vocabSize
    rowSum = sum(bigramCount(i, :));
    if rowSum > 0
        bigramProb(i, :) = bigramCount(i, :) / rowSum;
    end
end

% Evaluate Bigram Model
correct = 0;
total = 0;
for i = 1:numel(testWords)-1
    inputWord  = testWords{i};
    actualNext = testWords{i+1};
    if any(strcmp(vocab, inputWord))
        predicted = predictBigram(inputWord, vocab, bigramProb);
        total = total + 1;
        if strcmp(predicted, actualNext)
            correct = correct + 1;
        end
    end
end
accuracy = (correct / total) * 100;
fprintf('\n============================================\n');
fprintf('Bigram Model Evaluation\n');
fprintf('============================================\n');
fprintf('Correct predictions : %d\n', correct);
fprintf('Total predictions   : %d\n', total);
fprintf('Accuracy            : %.2f%%\n', accuracy);
fprintf('============================================\n');

% Save Model to Model.mat
save('Model.mat', 'bigramProb', 'vocab', 'vocabSize');

% Prediction Function (must be at end)
function nextWord = predictBigram(inputWord, vocab, bigramProb)
    idx = find(strcmp(vocab, inputWord));
    if isempty(idx)
        nextWord = '[unknown]';
        return;
    end
    row = bigramProb(idx, :);
    [~, maxIdx] = max(row);
    nextWord = vocab{maxIdx};
end






