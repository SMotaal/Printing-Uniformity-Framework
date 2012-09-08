if ~exist('x', 'var'), x = round(rand(10, 10).*100); end


values      = d(:)
numerals    = values(~isnan(values));

n           = numel(numerals);
s           = sum(numerals);
r           = [min(numerals) max(numerals)];
mu          = mean(numerals);

v           = var(numerals);
sigma       = sqrt(v);

f           = n-1;
