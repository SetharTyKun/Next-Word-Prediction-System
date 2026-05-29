% ============================================
% english_tokenize.m
% Tokenize English raw text → english_data.txt
% ============================================

% Read raw English text
fid = fopen('english_raw.txt', 'r', 'n', 'UTF-8');
raw = fscanf(fid, '%c');
fclose(fid);

% Lowercase
raw = lower(raw);

% Remove punctuation (keep only letters, digits, spaces, newlines)
raw = regexprep(raw, '[^a-z0-9\s]', ' ');

% Replace all whitespace (newlines, tabs, multiple spaces) with single space
raw = regexprep(raw, '\s+', ' ');

% Trim leading/trailing spaces
raw = strtrim(raw);

% Write to english_data.txt
fid = fopen('english_data.txt', 'w', 'n', 'UTF-8');
fprintf(fid, '%s', raw);
fclose(fid);

% Count tokens for feedback
tokens = strsplit(raw);
fprintf('Total English tokens: %d\n', numel(tokens));
fprintf('Done. Output saved to english_data.txt\n');
