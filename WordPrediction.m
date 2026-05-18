% ============================================
% STEP 1: Read and Tokenize Data
% ============================================
text = fileread('data.txt');
words = strsplit(text);
words = words(~cellfun('isempty', words));
fprintf('Total words: %d\n', numel(words));
fprintf('First word: %s\n', words{1});
fprintf('Last word: %s\n', words{end});

% ============================================
% STEP 2: Build Vocabulary Mapper
% ============================================
vocab = unique(words);
vocabSize = numel(vocab);
fprintf('\nVocabulary size: %d unique words\n', vocabSize);

% ============================================
% STEP 3: Train/Test Split + Scan Word Pairs
% ============================================
N = numel(words);
trainSize = floor(0.8 * N);
trainWords = words(1:trainSize);
testWords  = words(trainSize+1:end);
fprintf('\nTraining words: %d\n', trainSize);
fprintf('Test words: %d\n', numel(testWords));

% ============================================
% STEP 4: Count Bigram Frequencies
% ============================================
bigramCount = zeros(vocabSize, vocabSize);
for i = 1:numel(trainWords)-1
    word1 = trainWords{i};
    word2 = trainWords{i+1};
    idx1 = find(strcmp(vocab, word1));
    idx2 = find(strcmp(vocab, word2));
    bigramCount(idx1, idx2) = bigramCount(idx1, idx2) + 1;
end
fprintf('\nBigram frequency matrix built! (%dx%d)\n', vocabSize, vocabSize);

% ============================================
% STEP 5: Convert Counts to Probabilities
% ============================================
bigramProb = zeros(vocabSize, vocabSize);
for i = 1:vocabSize
    rowSum = sum(bigramCount(i, :));
    if rowSum > 0
        bigramProb(i, :) = bigramCount(i, :) / rowSum;
    end
end
fprintf('Bigram probability matrix built!\n');

% Show top 3 predictions for a test word
testWord = 'ការអប់រំ';
idx = find(strcmp(vocab, testWord));
if ~isempty(idx)
    row = bigramProb(idx, :);
    [sortedProbs, sortedIdx] = sort(row, 'descend');
    fprintf('\nTop 3 next words after "%s":\n', testWord);
    for i = 1:3
        if sortedProbs(i) > 0
            fprintf('  %s : %.3f\n', vocab{sortedIdx(i)}, sortedProbs(i));
        end
    end
end

% ============================================
% STEP 7: Evaluate Model Accuracy
% ============================================
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

% ============================================
% STEP 8: Save Model to Model.mat
% ============================================
save('Model.mat', 'bigramProb', 'vocab', 'vocabSize');
fprintf('\nModel saved to Model.mat successfully!\n');

% ============================================
% STEP 6: Prediction Function (must be at end)
% ============================================
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