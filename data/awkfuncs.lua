
awkfuncs = {
    --mathematical functions: exp,log,sqrt,sin,cos,atan2,rand,srand,int.
    ['exp'] = [[(e) Exponential of e.]],
    ['log'] = [[(e) Natural logarithm of e.]],
    ['sqrt'] = [[(e) Square root of e.]],
    ['sin'] = [[(e) Sine of e.]],
    ['cos'] = [[(e) Cosine of e.]],
    ['atan2'] = [[(y,x) Arctangent of y/x.]],
    ['rand'] = [[() Random number on (0,1).]],
    ['srand'] = [[([e]) Sets seed for rand and returns the previous seed. Uses time in seconds if no seed is provided.]],
    ['int'] = [[(e) Truncate to integer.]],

    --string functions: index,length,match,split,sub,gsub,sprintf,substr,tolower,toupper,utf.
    ['index'] = [[(s, t) The position in s where the string t occurs, or 0 if it does not.]],
    ['length'] = [[() Return length of string or array. If no argument is supplied, return length of $0.]],
    ['match'] = [[(s, r) The position in s where the regular expression r occurs, or 0 if it does not. The variables RSTART and RLENGTH are set to the position and length of the matched string.]],
    ['split'] = [[(s, a, fs) Splits the string s into array elements a[1], a[2], ..., a[n], and returns n. The separation is done with the regular expression fs or with the field separator FS if fs is not given. An empty string as field separator splits the string into one array element per character.]],
    ['sub'] = [[(r, t, s) Substitutes t for the first occurrence of the regular expression r in the string s. If s is not given, $0 is used.]],
    ['gsub'] = [[(r, t, s) Substitutes t for all occurences of the regular expression r in the string s. If s is not given, $0 is used.]],
    ['sprintf'] = [[(fmt, exprs) The string resulting from formatting expressions  according to the printf format fmt.]],
    ['substr'] = [[(s, m, n) The n-character substring of s that begins at position m counted from 1.]],
    ['tolower'] = [[(str) Return a copy of str with all upper-case characters translated to their corresponding lower-case equivalents.]],
    ['toupper'] = [[(str) Return a copy of str with all lower-case characters translated to their corresponding upper-case equivalents.]],
    ['utf'] = [[(e) Converts its numerical argument, a character number, to a UTF string. GAWK doesn't have this function.]],

    --other functions: close,fflush,print,printf,system.
    ['close'] = [[(file) Close file or pipe.]],
    ['fflush'] = [[([file]) Flush buffers of open output file or pipe. Without [file] flush all open output files and pipes.]],
    ['print'] = [[([e]) Print the current record or the proceeding expressions. Brackets are optional.]],
    ['printf'] = [[(fmt,exprs) Format and print expressions.]],
    ['system'] = [[(cmd) Executes cmd and returns its exit status. Not really just a string function.]],
}

return awkfuncs
