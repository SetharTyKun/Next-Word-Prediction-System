% ============================================
% Part 1 :  Data Preparation
% ============================================

% Merge khmer_data.txt + english_data.txt → combined text
khmer_text   = fileread('khmer_data.txt');
english_text = fileread('english_data.txt');
text = [strtrim(khmer_text), ' ', strtrim(english_text)];           % text = "ប្រវត្តិសាស្ត្រ ខ្មែរ មាន អាយុ ... រីកចំរើន khmer history cambodian history spans ... prosperity"

% Read & Filter
% text is now the merged Khmer + English corpus
words = strsplit(text);                                                 % Split word by ONE space             words = {'ប្រពៃណី', 'ការអប់រំ', '', 'នៅ', 'ប្រទេស', '', 'កម្ពុជា', ... , 'ការអប់រំ'}
words = words(~cellfun('isempty', words));                  % Filter out empty cell                     words = {'ប្រពៃណី', 'ការអប់រំ', 'នៅ', 'ប្រទេស', 'កម្ពុជា', ..., 'ការអប់រំ'}

% Build Vocabulary Mapper
vocab = unique(words);                                              % Only unique word + sort              vocab = {'កម្ពុជា', 'ការអប់រំ', 'នៅ', 'ប្រទេស', 'ប្រពៃណី', ...}
vocabSize = numel(vocab);

fprintf('Vocabulary: %d\n', vocabSize);

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

% Bigram Frequency Matrix 
bigramCount = zeros(vocabSize, vocabSize);                  % Creates an empty matrix filled with zeros
for i = 1:numel(trainWords)-1                                           % Loops through every word except the last one              tranWords = {'ប្រពៃណី', 'ការអប់រំ', 'នៅ', 'ប្រទេស', 'កម្ពុជា', ...}
    word1 = trainWords{i};                                                % word1 = "ប្រពៃណី"
    word2 = trainWords{i+1};                                            % word2 = "ការអប់រំ"
    idx1 = find(strcmp(vocab, word1));                                          % idx1 = 1
    idx2 = find(strcmp(vocab, word2));                                          % idx2 = 2
    bigramCount(idx1, idx2) = bigramCount(idx1, idx2) + 1;            % Finds the cell at row idx1, column idx2 and increments it by 1
end

% Convert Counts to Probabilities
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

% ===============
% Trigram Model
% ===============

% Trigram Frequency Counter using containers.Map
trigramCount = containers.Map('KeyType', 'char', 'ValueType', 'any');
for i = 1:numel(trainWords)-2
    word1 = trainWords{i};
    word2 = trainWords{i+1};
    word3 = trainWords{i+2};
    key   = [word1, ' ', word2];
    idx3  = find(strcmp(vocab, word3));
    if ~isempty(idx3)
        if isKey(trigramCount, key)
            countVec = trigramCount(key);
        else
            countVec = zeros(1, vocabSize);
        end
        countVec(idx3) = countVec(idx3) + 1;
        trigramCount(key) = countVec;
    end
end

% Convert Counts to Probabilities
trigramProb  = containers.Map('KeyType', 'char', 'ValueType', 'any');
keys_list = keys(trigramCount);
for i = 1:numel(keys_list)
    k        = keys_list{i};
    countVec = trigramCount(k);
    rowSum   = sum(countVec);
    if rowSum > 0
        trigramProb(k) = countVec / rowSum;
    end
end

% Evaluate Trigram Model
correct3 = 0;
total3   = 0;
for i = 1:numel(testWords)-2
    inputWord1 = testWords{i};
    inputWord2 = testWords{i+1};
    actualNext = testWords{i+2};
    if any(strcmp(vocab, inputWord1)) && any(strcmp(vocab, inputWord2))
        predicted3 = predictTrigram(inputWord1, inputWord2, vocab, trigramProb);
        if ~strcmp(predicted3, '[unknown]')
            total3 = total3 + 1;
            if strcmp(predicted3, actualNext)
                correct3 = correct3 + 1;
            end
        end
    end
end
accuracy3 = (correct3 / total3) * 100;
fprintf('\n============================================\n');
fprintf('Trigram Model Evaluation\n');
fprintf('============================================\n');
fprintf('Correct predictions : %d\n', correct3);
fprintf('Total predictions   : %d\n', total3);
fprintf('Accuracy            : %.2f%%\n', accuracy3);

% ===============
% Vector Model
% ===============

% Stage 1 — Co-occurrence Matrix (window = 2)
windowSize   = 2;
cooccurCount = zeros(vocabSize, vocabSize);
for i = 1:numel(trainWords)
    idx_center = find(strcmp(vocab, trainWords{i}));
    if isempty(idx_center), continue; end
    for j = max(1, i - windowSize) : min(numel(trainWords), i + windowSize)
        if j == i, continue; end
        idx_context = find(strcmp(vocab, trainWords{j}));
        if isempty(idx_context), continue; end
        cooccurCount(idx_center, idx_context) = cooccurCount(idx_center, idx_context) + 1;
    end
end

% Stage 2 — PPMI Weighting
totalCount  = sum(cooccurCount(:));
wordProb    = sum(cooccurCount, 2) / totalCount;   % vocabSize x 1
contextProb = sum(cooccurCount, 1) / totalCount;   % 1 x vocabSize
jointProb   = cooccurCount / totalCount;
expected    = wordProb * contextProb;              % outer product  vocabSize x vocabSize
pmiMatrix   = log2(jointProb ./ (expected + eps));
pmiMatrix(cooccurCount == 0) = 0;
ppmiMatrix  = max(0, pmiMatrix);

% Stage 3 — SVD Dimensionality Reduction (k = 50)
k           = 50;
[U, S, ~]   = svds(ppmiMatrix, k);
wordVectors = U * S;                               % vocabSize x k

% Stage 4 — Normalise vectors for cosine similarity
norms       = sqrt(sum(wordVectors .^ 2, 2)) + eps;
wordVectorsNorm = wordVectors ./ norms;

% Stage 5 — Evaluate Vector Model
correct_v = 0;
total_v   = 0;
for i = 1:numel(testWords)-1
    inputWord  = testWords{i};
    actualNext = testWords{i+1};
    if any(strcmp(vocab, inputWord))
        predicted_v = predictVector(inputWord, vocab, wordVectorsNorm);
        if ~strcmp(predicted_v, '[unknown]')
            total_v = total_v + 1;
            if strcmp(predicted_v, actualNext)
                correct_v = correct_v + 1;
            end
        end
    end
end
accuracy_v = (correct_v / total_v) * 100;
fprintf('\n============================================\n');
fprintf('Vector Model Evaluation\n');
fprintf('============================================\n');
fprintf('Correct predictions : %d\n', correct_v);
fprintf('Total predictions   : %d\n', total_v);
fprintf('Accuracy            : %.2f%%\n', accuracy_v);


% Save Model to Model.mat
save('Model.mat', 'bigramProb', 'vocab', 'vocabSize', 'trigramProb', 'wordVectorsNorm');

% Prediction Functions (must be at end)
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

function nextWord = predictVector(inputWord, vocab, wordVectorsNorm)
    idx = find(strcmp(vocab, inputWord));
    if isempty(idx)
        nextWord = '[unknown]';
        return;
    end
    queryVec     = wordVectorsNorm(idx, :);
    similarities = wordVectorsNorm * queryVec';    % cosine similarity for all words
    similarities(idx) = -inf;                      % exclude the word itself
    [~, maxIdx]  = max(similarities);
    nextWord     = vocab{maxIdx};
end

function nextWord = predictTrigram(word1, word2, vocab, trigramProb)
    key = [word1, ' ', word2];
    if ~isKey(trigramProb, key)
        nextWord = '[unknown]';
        return;
    end
    row = trigramProb(key);
    [~, maxIdx] = max(row);
    nextWord = vocab{maxIdx};
end






