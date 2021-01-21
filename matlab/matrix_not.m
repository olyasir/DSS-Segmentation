function res = matrix_not(a)
if islogical(a)
    res = ~a;
else
    error('Input a must be logical.');
end