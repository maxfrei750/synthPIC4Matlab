function array = removenans(array)
    array(isnan(array)) = [];
end