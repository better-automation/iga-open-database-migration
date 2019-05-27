module.exports = function getValuesFromPropertyMap(propertyMap, input) {
    if (Array.isArray(input)) {
        return input.map(inputItem => getValuesFromPropertyMap(propertyMap, inputItem)).flat();
    }

    if (propertyMap.length === 0) {
        return [input];
    }

    if (!input) {
        return undefined;
    }

    return getValuesFromPropertyMap(propertyMap.slice(1), input[propertyMap[0]]);
}
