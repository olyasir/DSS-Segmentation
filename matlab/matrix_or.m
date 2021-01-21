function res = matrix_or(a,b)
if islogical(a) && islogical(b)
    res = a | b;
else
    error('Inputs a & b must be logical.');
end