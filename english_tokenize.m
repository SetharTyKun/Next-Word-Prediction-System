% Read raw English text
fileReader = fopen('english_raw.txt', 'r', 'n', 'UTF-8');
rawText = fscanf(fileReader, '%c');
fclose(fileReader);

% Lowercase everything
cleanText = lower(rawText);

% Remove punctuation (keep only letters, digits, spaces, newlines)
cleanText = regexprep(cleanText, '[^a-z0-9\s]', ' ');

% Replace all whitespace (newlines, tabs, multiple spaces) with single space
cleanText = regexprep(cleanText, '\s+', ' ');

% Trim leading/trailing spaces
cleanText = strtrim(cleanText);

% Write to english_data.txt
fileWriter = fopen('english_data.txt', 'w', 'n', 'UTF-8');
fprintf(fileWriter, '%s', cleanText);
fclose(fileWriter);

wordList = strsplit(cleanText);
fprintf('Total English words: %d\n', numel(wordList));