require('./polyfills');
const deepEqual = require('deep-equal');
const fs = require('fs');
const getValuesFromPropertyMap = require('./get-values-from-property-map');
const mkdirp = require('mkdirp');
const path = require('path');

const inputFilePath = "./data/IGA-2016-v3.json";
const outputFileDirectory = "./output";
const outputFilename = "object-schema.json";
const outputFilePath = path.join(outputFileDirectory, outputFilename);

const root = require(inputFilePath);

const objectSchemas = [];

function generateObjectSchema(input, propertyMap = []) {
    const objectSchema = {};

    Object.keys(input).forEach(field => {
        objectSchema[field] = resolveType(propertyMap.concat(field));
    });

    return objectSchema;
}

function resolveType(propertyMap) {
    const propertyValues = getValuesFromPropertyMap(propertyMap, root).filter(propertyValue => propertyValue !== null && typeof propertyValue !== "undefined");

    if (propertyValues.length === 0) {
        return 'UNKNOWN';
    }

    const propertyValue = propertyValues[0];
    const propertyValueType = typeof propertyValue;

    if (propertyValueType === 'object') {
        const nestedObjectSchema = generateObjectSchema(propertyValue, propertyMap);
        return upsertObjectSchema(nestedObjectSchema, propertyMap);
    }

    return propertyValueType;
}

function upsertObjectSchema(objectSchema, propertyMap) {
    const index = objectSchemas.findIndex(schema => deepEqual(schema.schema, objectSchema));
    const objectPropertyMap = propertyMap.join('.');

    if (index === -1) {
        objectSchemas.push({
            schema: Object.assign({}, objectSchema),
            propertyMaps: [objectPropertyMap]
        });
        return objectSchemas.length - 1;
    }

    objectSchemas[index].propertyMaps.push(objectPropertyMap);

    return index;
}

const rootSchema = generateObjectSchema(root);

mkdirp.sync(outputFileDirectory);

fs.writeFileSync(outputFilePath, JSON.stringify({
    rootSchema,
    objectSchemas
}));

console.log(`File Created: ${outputFilePath}`);
