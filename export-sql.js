const data = require('./data/IGA-2016-v3.json');
const queries = require('./queries');
const sql = require('mssql/msnodesqlv8');
 
const config = {
    server: 'FUNKENHOUSE\\SQLEXPRESS', 
    database: 'IGA-2016-v3',
    driver: "msnodesqlv8",
    options: {
        trustedConnection: true
    }
};

const bills = data.legislation;

function logError(error, query) {
    console.log('=========== ERROR ===========');
    console.log(JSON.stringify(error), '--------End Error--------');
    console.log(query);
}

// https://hackernoon.com/functional-javascript-resolving-promises-sequentially-7aac18c4431e
function runSync(promiseFactories) {
    return promiseFactories.reduce((promise, factory) =>
        promise.then(result => factory().then(Array.prototype.concat.bind(result)))
        , Promise.resolve([]));
}

sql.connect(config).then(pool => {

    function exists(query) {
        return new Promise((resolve, reject) => {
            pool.request().query(query, (err, result) => {
                if (err) {
                    logError(err, query);
                    reject(err);
                } else {
                    resolve(result.recordset.length ? result.recordset[0].Id : null);
                }
            });
        });
    }
            
    function insert(query) {
        return new Promise((resolve, reject) => {
            pool.request().query(query, (err, result) => {
                if (err) {
                    logError(err, query);
                    reject(err);
                } else {
                    resolve(result.recordset[0]['']);
                }
            });
        }); 
    }

    function insertIfNew(existsQuery, insertQuery) {
        return exists(existsQuery)
            .then(existingId => (existingId === null) ? insert(insertQuery) : Promise.resolve(existingId));
    }

    runSync(bills.map(bill => 
        () => insert(queries.insertBill(bill))
            .then(billId => 
                runSync(bill.actions.items.map(action => 
                    () => insert(queries.insertAction(billId, action))
                ))
                .then(() => 
                    runSync(bill.bill_info.advisors.map(advisor => 
                        () => insertIfNew(queries.doesLegislatorExist(advisor), queries.insertLegislator(advisor))
                                .then(legislatorId => 
                                    insert(queries.insertBillAdvisor(billId, legislatorId)))
                )))
                .then(() =>
                    runSync(bill.bill_info.sponsors.map(sponsor =>
                        () => insertIfNew(queries.doesLegislatorExist(sponsor), queries.insertLegislator(sponsor))
                                .then(legislatorId => 
                                    insert(queries.insertBillSponsor(billId, legislatorId)))
                    )))
                .then(() =>
                    runSync(bill.bill_info.coauthors.map(coauthor => 
                        () => insertIfNew(queries.doesLegislatorExist(coauthor), queries.insertLegislator(coauthor))
                                .then(legislatorId => 
                                    insert(queries.insertBillCoauthor(billId, legislatorId)))
                    )))
                .then(() =>
                    runSync(bill.bill_info.authors.map(author =>
                        () => insertIfNew(queries.doesLegislatorExist(author), queries.insertLegislator(author))
                                .then(legislatorId => 
                                    insert(queries.insertBillAuthor(billId, legislatorId)))
                    )))
                .then(() =>
                    runSync(bill.bill_info.cosponsors.map(cosponsor => 
                        () => insertIfNew(queries.doesLegislatorExist(cosponsor), queries.insertLegislator(cosponsor))
                                .then(legislatorId => 
                                    insert(queries.insertBillCosponsor(billId, legislatorId)))
                    )))
                .then(() =>
                    runSync(bill.bill_info.versions.map(version => 
                        () => insert(queries.insertBillVersion(billId, version))
                    )))
                .then(() =>
                    runSync(bill.versions.items.map(item =>
                        () => insert(queries.insertBillVersionItem(billId, item))
                                .then(billVersionItemId =>
                                    runSync(item['committee-reports'].map(report =>
                                        () => insert(queries.insertCommitteeReport(billVersionItemId, report))
                                    ))
                                    .then(() => 
                                        runSync(item.advisors.map(advisor =>
                                            () => insertIfNew(queries.doesLegislatorExist(advisor), queries.insertLegislator(advisor))
                                                    .then(legislatorId => 
                                                        insert(queries.insertBillVersionItemAdvisor(billVersionItemId, legislatorId)))
                                        )))
                                    .then(() => 
                                        runSync(item.cmte_amendments.map(amendment =>
                                            () => insertIfNew(queries.doesLegislatorExist(amendment.author), queries.insertLegislator(amendment.author))
                                                    .then(legislatorId =>
                                                        insert(queries.insertAmendment(billVersionItemId, legislatorId, amendment, 'Committee')))
                                        )))
                                    .then(() => 
                                        runSync(item.floor_amendments.map(amendment =>
                                            () => insertIfNew(queries.doesLegislatorExist(amendment.author), queries.insertLegislator(amendment.author))
                                                    .then(legislatorId =>
                                                        insert(queries.insertAmendment(billVersionItemId, legislatorId, amendment, 'Floor')))
                                        )))
                                    .then(() => 
                                        runSync(item.subjects.map(subject =>
                                            () => insertIfNew(queries.doesSubjectExist(subject), queries.insertSubject(subject))
                                                    .then(subjectId =>
                                                        insert(queries.insertBillVersionItemSubject(billVersionItemId, subjectId)))
                                        )))
                                    .then(() => 
                                        runSync(item.sponsors.map(sponsor =>
                                            () => insertIfNew(queries.doesLegislatorExist(sponsor), queries.insertLegislator(sponsor))
                                                    .then(legislatorId => 
                                                        insert(queries.insertBillVersionItemSponsor(billVersionItemId, legislatorId)))
                                        )))
                                    .then(() => 
                                        runSync(item.rollcalls.map(rollCall =>
                                            () => insert(queries.insertRollCall(rollCall))
                                                    .then(rollCallId =>
                                                        insert(queries.insertBillVersionItemRollCall(billVersionItemId, rollCallId)))
                                        )))
                                    .then(() => 
                                        runSync(item.authors.map(author =>
                                            () => insertIfNew(queries.doesLegislatorExist(author), queries.insertLegislator(author))
                                                    .then(legislatorId => 
                                                        insert(queries.insertBillVersionItemAuthor(billVersionItemId, legislatorId)))
                                        )))
                                    .then(() => 
                                        runSync(item.coauthors.map(coauthor =>
                                            () => insertIfNew(queries.doesLegislatorExist(coauthor), queries.insertLegislator(coauthor))
                                                    .then(legislatorId => 
                                                        insert(queries.insertBillVersionItemCoauthor(billVersionItemId, legislatorId)))
                                        )))
                                    .then(() => 
                                        runSync(item.cosponsors.map(cosponsor =>
                                            () => insertIfNew(queries.doesLegislatorExist(cosponsor), queries.insertLegislator(cosponsor))
                                                    .then(legislatorId => 
                                                        insert(queries.insertBillVersionItemCosponsor(billVersionItemId, legislatorId)))
                                        )))
                                )
                    )))
                .then(() =>
                    runSync(bill.bill_info.motions.map(motion => 
                        () => insertIfNew(queries.doesLegislatorExist(motion.author[0]), queries.insertLegislator(motion.author[0]))
                                .then(legislatorId =>  
                                    insert(queries.insertMotion(billId, legislatorId, motion)))
                                .then(motionId =>
                                    runSync(motion.rollcalls.map(rollCall =>
                                        () => insert(queries.insertRollCall(rollCall))
                                                .then(rollCallId =>
                                                    insert(queries.insertMotionRollCall(motionId, rollCallId))),
                                    )))
                    )))
            )
        ))
        .then(() => {
            console.log('Complete');
        });
});

