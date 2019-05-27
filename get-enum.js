require('./polyfills');
const getValuesFromPropertyMap = require('./get-values-from-property-map');

const inputFilePath = "./data/IGA-2016-v3.json";

const root = require(inputFilePath);

function getEnum(propertyMaps) {
    const enumValues = [];

    propertyMaps.forEach(propertyMap => {
        const values = getValuesFromPropertyMap(propertyMap, root);

        values.forEach(value => {
            if (!enumValues.includes(value)) {
                enumValues.push(value);
            }
        });
    });

    return enumValues;
}

function resolveEnums(propertyMaps, options, key) {
    let enumValues = getEnum(propertyMaps);

    if (enumValues.length === 0) {
        console.log("Nothing Found.")
        return [];
    }

    if (typeof enumValues[0] === 'object' && !Array.isArray(enumValues[0])) {
        if (options.trimKey) {
            enumValues = enumValues.map(enumValue => enumValue && Object.assign(enumValue, { [key]: enumValue[key].trim() }));
        }

        if (key) {
            enumValues.sort((a, b) => (a[key] > b[key]) ? 1 : -1);

            if (options.group) {
                const countProperty = `__${key}_count__`;
                enumValues = enumValues.reduce((result, currentValue) => {
                    if (!currentValue) {
                        return result;
                    }

                    if (result.length > 0) {
                        const previousValue = result[result.length - 1];

                        if (previousValue[key] === currentValue[key]) {
                            previousValue[countProperty]++;
                            return result;
                        }
                    }

                    currentValue[countProperty] = 1;
                    result.push(currentValue);
                    return result;
                }, []);

                enumValues.sort((a, b) => a[countProperty] - b[countProperty]);

                if (options.showCountOnly) {
                    enumValues = enumValues.map(enumValue => {
                        return {
                            [key]: enumValue[key],
                            [countProperty]: enumValue[countProperty]
                        }
                    });
                }
            }
        }

        console.table(enumValues);
    } else {
        if (options.group) {
            enumValues.sort();

            enumValues = enumValues.reduce((result, currentValue) => {
                if (result.length > 0) {
                    const previous = result[result.length - 1];

                    if (previous.value === currentValue) {
                        previous.count++;
                        return result;
                    }
                }

                result.push({
                    value: currentValue,
                    count: 1
                });

                return result;
            }, []);

            console.table(enumValues);
        } else {
            console.log(JSON.stringify(enumValues));
        }
    }
    
    return enumValues;
}

module.exports = getEnum;

if (require.main === module) {
    let key;
    let propertyMaps = [];
    let splitByPropertyMap;

    const options = {};

    for (let i = 2; i < process.argv.length; i++) {
        const arg = process.argv[i];

        if (arg === "-k") {
            i++;
            key = process.argv[i];
            continue;
        }

        if (arg === "-g") {
            options.group = true;
            continue;
        }

        if (arg === "-c") {
            options.showCountOnly = true;
            continue;
        }

        if (arg === "-s") {
            splitByPropertyMap = true;
            continue;
        }

        if (arg === "-t") {
            options.trimKey = true;
        }

        propertyMaps.push(arg.split('.'));
    }

    if (splitByPropertyMap) {
        let enums = [];        

        for (let propertyMap of propertyMaps) {
            console.log(propertyMap.join('.'));

            let enumValues = resolveEnums([propertyMap], options, key);

            enums.push(enumValues);
        }

        return enums;
    }

    return resolveEnums(propertyMaps, options, key);
}
