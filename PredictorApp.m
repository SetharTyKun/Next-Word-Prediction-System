% ============================================
% PredictorApp.m
% Khmer Next Word Prediction - GUI App
% ============================================

function PredictorApp()

% ============================================
% Load Model
% ============================================
loaded          = load('Model.mat');
vocab           = loaded.vocab;
bigramProb      = loaded.bigramProb;
trigramProb     = loaded.trigramProb;
wordVectorsNorm = loaded.wordVectorsNorm;

% ============================================
% Colors
% ============================================
bgColor       = [245 245 247] / 255;   % #F5F5F7  light background
claudeOrange  = [217 119  87] / 255;   % #D97757  Claude primary
resultGreen   = [  5 150 105] / 255;   % #059669  prediction result
white         = [255 255 255] / 255;
titleColor    = [ 17  24  39] / 255;   % #111827  near-black
grayText      = [107 114 128] / 255;   % #6B7280  labels
cardColor     = [255 255 255] / 255;   % #FFFFFF  input / result card
disabledBg    = [229 231 235] / 255;   % #E5E7EB  disabled button bg
disabledFg    = [156 163 175] / 255;   % #9CA3AF  disabled button text
errorRed      = [220  38  38] / 255;   % #DC2626  error result text
warnYellow    = [217 119   0] / 255;   % #D97700  warning result text

% ============================================
% Main Window
% ============================================
figW = 500;  figH = 640;
pad  = 50;
iW   = figW - pad * 2;   % inner width = 400

fig = uifigure( ...
    'Name',     'Khmer Next Word Predictor', ...
    'Color',    bgColor, ...
    'Position', [400 150 figW figH], ...
    'Resize',   'off');

% ============================================
% Title
% ============================================
uilabel(fig, ...
    'Text',                'Next Word Prediction', ...
    'FontName',            'Khmer UI', ...
    'FontSize',            20, ...
    'FontWeight',          'bold', ...
    'FontColor',           titleColor, ...
    'BackgroundColor',     bgColor, ...
    'HorizontalAlignment', 'center', ...
    'Position',            [pad 572 iW 46]);

% ============================================
% Input Label
% ============================================
inputLabel = uilabel(fig, ...
    'Text',                'Enter a word (Khmer or English):', ...
    'FontName',            'Khmer UI', ...
    'FontSize',            13, ...
    'FontColor',           grayText, ...
    'BackgroundColor',     bgColor, ...
    'HorizontalAlignment', 'left', ...
    'Position',            [pad 526 iW 24]);

% ============================================
% Input Field
% ============================================
inputField = uieditfield(fig, 'text', ...
    'FontName',            'Khmer UI', ...
    'FontSize',            15, ...
    'FontColor',           titleColor, ...
    'BackgroundColor',     cardColor, ...
    'HorizontalAlignment', 'left', ...
    'Position',            [pad 478 iW 42]);

% ============================================
% Model Toggle Buttons   (centered, 18px below input field)
% Total buttons width = 3*120 + 2*8 = 376
% Center X = (figW - 376) / 2 = (500 - 376) / 2 = 62
% ============================================
btnW = 120;  btnH = 38;  gap = 8;
totalBtnW = 3*btnW + 2*gap;          % 376
btnStartX = (figW - totalBtnW) / 2;  % 62  — centered in window

btnBigram = uibutton(fig, ...
    'Text',            'Bigram', ...
    'FontName',        'Khmer UI', ...
    'FontSize',        12, ...
    'FontWeight',      'bold', ...
    'FontColor',       white, ...
    'BackgroundColor', claudeOrange, ...
    'Position',        [btnStartX 420 btnW btnH]);

btnTrigram = uibutton(fig, ...
    'Text',            'Trigram', ...
    'FontName',        'Khmer UI', ...
    'FontSize',        12, ...
    'FontWeight',      'bold', ...
    'FontColor',       grayText, ...
    'BackgroundColor', cardColor, ...
    'Position',        [btnStartX + btnW + gap 420 btnW btnH]);

btnVector = uibutton(fig, ...
    'Text',            'Vector', ...
    'FontName',        'Khmer UI', ...
    'FontSize',        12, ...
    'FontWeight',      'bold', ...
    'FontColor',       grayText, ...
    'BackgroundColor', cardColor, ...
    'Position',        [btnStartX + 2*(btnW + gap) 420 btnW btnH]);

btnBigram.ButtonPushedFcn  = @(~,~) selectModel(1);
btnTrigram.ButtonPushedFcn = @(~,~) selectModel(2);
btnVector.ButtonPushedFcn  = @(~,~) selectModel(3);

selectedModel = 1;

% ============================================
% Predict Button   (32px gap below toggles: 420 - 38 - 32 = 350)
% ============================================
uibutton(fig, ...
    'Text',            'Predict Next Word', ...
    'FontName',        'Khmer UI', ...
    'FontSize',        14, ...
    'FontWeight',      'bold', ...
    'FontColor',       white, ...
    'BackgroundColor', claudeOrange, ...
    'Position',        [pad 350 iW 48], ...
    'ButtonPushedFcn', @onPredict);

% ============================================
% Status / Error  (just below predict button)
% ============================================
statusLabel = uilabel(fig, ...
    'Text',                '', ...
    'FontName',            'Khmer UI', ...
    'FontSize',            11, ...
    'FontColor',           [220 38 38]/255, ...
    'BackgroundColor',     bgColor, ...
    'HorizontalAlignment', 'center', ...
    'Position',            [pad 318 iW 26]);

% ============================================
% Output Label
% ============================================
uilabel(fig, ...
    'Text',                'Output:', ...
    'FontName',            'Khmer UI', ...
    'FontSize',            13, ...
    'FontColor',           grayText, ...
    'BackgroundColor',     bgColor, ...
    'HorizontalAlignment', 'left', ...
    'Position',            [pad 255 iW 24]);

% ---- Result box: uihtml for border-radius support ----
resultHTML = uihtml(fig, ...
    'Position', [pad 80 iW 170], ...
    'HTMLSource', buildResultHTML('- - -', resultGreen));

% uilabel kept invisible — used only to pass text updates via buildResultHTML
resultLabel = uilabel(fig, ...
    'Text',            '- - -', ...
    'Visible',         'off', ...
    'Position',        [0 0 1 1]);

% ============================================
% Vocabulary Info at Bottom
% ============================================
uilabel(fig, ...
    'Text',                sprintf('Vocabulary: %d words', numel(vocab)), ...
    'FontName',            'Khmer UI', ...
    'FontSize',            11, ...
    'FontColor',           grayText, ...
    'BackgroundColor',     bgColor, ...
    'HorizontalAlignment', 'center', ...
    'Position',            [pad 30 iW 24]);

% ============================================
% Nested Functions
% ============================================

    function selectModel(k)
        selectedModel = k;
        buttons = [btnBigram, btnTrigram, btnVector];
        for m = 1:3
            if m == k
                buttons(m).FontColor       = white;
                buttons(m).BackgroundColor = claudeOrange;
            else
                buttons(m).FontColor       = grayText;
                buttons(m).BackgroundColor = cardColor;
            end
        end
        if k == 2
            inputLabel.Text = 'Enter two words (Khmer: no space | English: use space):';
        else
            inputLabel.Text = 'Enter a word (Khmer or English):';
        end
        inputField.Value      = '';
        resultHTML.HTMLSource = buildResultHTML('- - -', resultGreen);
        statusLabel.Text      = '';
    end

    function onPredict(~, ~)

        inputWord = strtrim(inputField.Value);
        % Normalize: lowercase English input (Khmer is unaffected by lower())
        inputWord = lower(inputWord);

        if isempty(inputWord)
            resultHTML.HTMLSource = buildResultHTML('Please enter a word.', errorRed);
            statusLabel.Text      = '';
            return;
        end

        switch selectedModel
            case 1   % Bigram
                if any(inputWord == ' ')
                    resultHTML.HTMLSource = buildResultHTML('Enter ONE word only.', errorRed);
                    statusLabel.Text      = '';
                    return;
                end
                idx = find(strcmp(vocab, inputWord));
                if isempty(idx)
                    resultHTML.HTMLSource = buildResultHTML('គ្មានពាក្យ / Word not found', errorRed);
                    statusLabel.Text      = '';
                    return;
                end
                row = bigramProb(idx, :);
                if max(row) == 0
                    resultHTML.HTMLSource = buildResultHTML('No prediction available.', errorRed);
                    statusLabel.Text      = '';
                    return;
                end
                nonZeroIdx             = find(row > 0);
                [sortedProbs, sortOrd] = sort(row(nonZeroIdx), 'descend');
                candidateWords         = vocab(nonZeroIdx(sortOrd));
                resultHTML.HTMLSource  = buildMultiResultHTML(candidateWords, sortedProbs, resultGreen);
                statusLabel.Text       = '';

            case 2   % Trigram
                word1 = '';
                word2 = '';
                found = false;
                if any(inputWord == ' ')
                    % English: split on space directly
                    parts = strsplit(inputWord);
                    if numel(parts) == 2 && any(strcmp(vocab, parts{1})) && any(strcmp(vocab, parts{2}))
                        word1 = parts{1};
                        word2 = parts{2};
                        found = true;
                    end
                else
                    % Khmer: scan every character split point
                    for s = 1:numel(inputWord)-1
                        candidate1 = inputWord(1:s);
                        candidate2 = inputWord(s+1:end);
                        if any(strcmp(vocab, candidate1)) && any(strcmp(vocab, candidate2))
                            word1 = candidate1;
                            word2 = candidate2;
                            found = true;
                            break;
                        end
                    end
                end
                if ~found
                    resultHTML.HTMLSource = buildResultHTML('សូមសរសេរពីរពាក្យ / Enter two valid words', warnYellow);
                    statusLabel.Text      = '';
                    return;
                end
                key = [word1, ' ', word2];
                if ~isKey(trigramProb, key)
                    resultHTML.HTMLSource = buildResultHTML('គ្មានពាក្យ / Word not found', errorRed);
                    statusLabel.Text      = '';
                    return;
                end
                row = trigramProb(key);
                if max(row) == 0
                    resultHTML.HTMLSource = buildResultHTML('No prediction available.', errorRed);
                    statusLabel.Text      = '';
                    return;
                end
                nonZeroIdx             = find(row > 0);
                [sortedProbs, sortOrd] = sort(row(nonZeroIdx), 'descend');
                candidateWords         = vocab(nonZeroIdx(sortOrd));
                resultHTML.HTMLSource  = buildMultiResultHTML(candidateWords, sortedProbs, resultGreen);
                statusLabel.Text       = '';

            case 3   % Vector
                if any(inputWord == ' ')
                    resultHTML.HTMLSource = buildResultHTML('Enter ONE word only.', errorRed);
                    statusLabel.Text      = '';
                    return;
                end
                idx = find(strcmp(vocab, inputWord));
                if isempty(idx)
                    resultHTML.HTMLSource = buildResultHTML('គ្មានពាក្យ / Word not found', errorRed);
                    statusLabel.Text      = '';
                    return;
                end
                queryVec              = wordVectorsNorm(idx, :);
                similarities          = wordVectorsNorm * queryVec';
                similarities(idx)     = -inf;                        % exclude the word itself
                posIdx                = find(similarities > 0);
                if isempty(posIdx)
                    resultHTML.HTMLSource = buildResultHTML('No prediction available.', errorRed);
                    statusLabel.Text      = '';
                    return;
                end
                [sortedSims, sortOrd] = sort(similarities(posIdx), 'descend');
                candidateWords        = vocab(posIdx(sortOrd));
                resultHTML.HTMLSource = buildMultiResultHTML(candidateWords, sortedSims, resultGreen);
                statusLabel.Text      = '';

            otherwise
                resultHTML.HTMLSource = buildResultHTML('Model not yet available.', errorRed);
                statusLabel.Text      = '';
        end
    end

end

% ============================================
% Helper: build multi-word card result HTML
% ============================================
function html = buildMultiResultHTML(candidateWords, sortedProbs, rgb)
    hex   = sprintf('#%02X%02X%02X', round(rgb(1)*255), round(rgb(2)*255), round(rgb(3)*255));
    cards = '';
    for i = 1:numel(candidateWords)
        pct   = sprintf('%.2f%%', sortedProbs(i) * 100);
        cards = [cards, ...
            '<div style="text-align:center;background:#F0FDF4;border:1.5px solid #86EFAC;' ...
            'border-radius:10px;padding:8px 12px;min-width:70px;margin:6px 4px;">' ...
            '<div style="font-size:20px;font-weight:bold;color:' hex ';line-height:1.3;">' candidateWords{i} '</div>' ...
            '<div style="font-size:11px;color:#6B7280;margin-top:3px;">' pct '</div>' ...
            '</div>'];
    end
    html = ['<div style="width:100%;height:100%;background:#ffffff;border:1.5px solid #D1D5DB;' ...
        'border-radius:12px;padding:12px;box-sizing:border-box;overflow-y:auto;">' ...
        '<div style="display:flex;gap:8px;justify-content:flex-start;flex-wrap:wrap;">' ...
        cards '</div></div>'];
end

% ============================================
% Helper: build rounded result box HTML
% ============================================
function html = buildResultHTML(txt, rgb)
    hex = sprintf('#%02X%02X%02X', round(rgb(1)*255), round(rgb(2)*255), round(rgb(3)*255));
    html = ['<div style="' ...
        'width:100%;height:100%;' ...
        'display:flex;align-items:center;justify-content:center;' ...
        'background:#ffffff;' ...
        'border:1.5px solid #D1D5DB;' ...
        'border-radius:12px;' ...
        'box-sizing:border-box;' ...
        'font-family:''Khmer UI'',Arial,sans-serif;' ...
        'font-size:32px;font-weight:bold;' ...
        'color:' hex ';' ...
        '">' txt '</div>'];
end