const generateObjectSchema = require('./generate-object-schema.js');



const data = require("./data/IGA-2016-v3.json");

function getDistinct(input, propertyMap)
{
    let values = {};

    input.forEach(element => {
        let propertyValues = getValuesFromPropertyMap(element, propertyMap);

        propertyValues.forEach(element => {
            values[element] = true;
        });
    });

    return Object.keys(values);
}

function getInstance(input, propertyMap, searchField, searchValue) {
    if (Array.isArray(input)) {
        for (let element of input) {
            let instance = getInstance(element, propertyMap, searchField, searchValue);

            if (isTargetInstance(instance, searchField, searchValue)) {
                return instance;
            }
        }
    } else if (propertyMap.length === 0) {
        if (isTargetInstance(input, searchField, searchValue)) {
            return input;
        }
    } else {
        return getInstance(input[propertyMap[0]], propertyMap.slice(1), searchField, searchValue);
    }
}

function isTargetInstance(instance, searchField, searchValue) {
    let type = typeof instance;

    switch (type) {
        case "undefined":
            return false;
        case "object":
            return !!(instance && instance[searchField] && (instance[searchField].trim() === searchValue));
        default:
            throw new Error(`ERROR: propertyMap resolves to ${type}. must be an object`);
    }
}

//console.log(getDistinct(data.data, ['bill_info', 'versions', 'enrolled']));

const result = 

const fs = require('fs');


console.log(JSON.stringify(generateObjectSchema(data), null, 4));