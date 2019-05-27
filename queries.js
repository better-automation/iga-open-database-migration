function convertDate(dateString) {
    if (!dateString) {
        return 'NULL';
    } else {
        return `CONVERT(datetime, '${dateString}')`;
    }
}

function cleanString(input) {
    if (typeof input === 'undefined' || input === null) {
        return 'NULL';
    } else {
        return `'${input.replace(new RegExp("'", 'g'), "''").trim()}'`
    }
}

function optional(obj, propertyName) {
    return (obj && obj[propertyName] && `'${obj[propertyName]}'`) || 'NULL';
}

module.exports = {

    doesLegislatorExist: (legislator) =>
`       SELECT TOP 1 Id 
        FROM Legislators 
        WHERE FullName = ${cleanString(legislator.fullName)}
`,

    doesSubjectExist: (subject) =>
`       SELECT TOP 1 Id
        FROM Subjects
        WHERE Link = ${cleanString(subject.link)}
`,

    insertAction: (billId, action) => 
`
        INSERT INTO [dbo].[Actions]
        (
            [BillId]
            ,[Description]
            ,[Sequence]
            ,[Chamber]
            ,[Link]
            ,[CommitteeLink]
            ,[Date]
            ,[Day]
        )
        VALUES
        (
            ${billId}
            ,${cleanString(action.description)}
            ,${cleanString(action.sequence)}
            ,${optional(action.chamber, 'name')}
            ,${cleanString(action.link)}
            ,${optional(action.committee, 'link')}
            ,${convertDate(action.date)}
            ,${cleanString(action.day)}
        );

        SELECT SCOPE_IDENTITY()
`,

    insertAmendment: (billVersionItemId, authorLegislatorId, amendment, amendmentType) =>
`
        INSERT INTO [dbo].[Amendments]
        (
            [BillVersionItemId]
            ,[AmendmentType]
            ,[Name]
            ,[AuthorLegislatorId]
            ,[PublishTime]
            ,[State]
            ,[Link]
            ,[BillVersionLink]
            ,[Description]
        )
        VALUES
        (
            ${billVersionItemId}
           ,${cleanString(amendmentType)}
           ,${cleanString(amendment.name)}
           ,${authorLegislatorId}
           ,${convertDate(amendment.publishtime)}
           ,${cleanString(amendment.state)}
           ,${cleanString(amendment.link)}
           ,${optional(amendment.billVersion, 'link')}
           ,${cleanString(amendment.description)}
        );

        SELECT SCOPE_IDENTITY()
`,

    insertBill: (bill) =>
`       INSERT INTO [dbo].[Bills]
        (
            [OriginChamber]
           ,[BillName]
           ,[Link]
           ,[Type]
           ,[Number]
           ,[CurrentChamber]
           ,[Year]
           ,[Title]
           ,[Status]
           ,[Description]
           ,[CommitteeStatus]
           ,[Stage]
        )
        VALUES
        (
            ${optional(bill.originChamber, 'name')}
           ,${cleanString(bill.billName)}
           ,${cleanString(bill.link)}
           ,${cleanString(bill.type)}
           ,${bill.bill_info.number}
           ,${cleanString(bill.bill_info.currentChamber)}
           ,${cleanString(bill.bill_info.year)}
           ,${cleanString(bill.bill_info.title)}
           ,${cleanString(bill.bill_info.status)}
           ,${cleanString(bill.bill_info.description)}
           ,${cleanString(bill.bill_info.committeeStatus)}
           ,${cleanString(bill.bill_info.stage)}
        );

        SELECT SCOPE_IDENTITY()`,

    insertBillAdvisor: (billId, legislatorId) =>
`       INSERT INTO BillAdvisors
            ( BillId, LegislatorId )
        VALUES
            ( ${billId}, ${legislatorId});
    
        SELECT SCOPE_IDENTITY()
`,

    insertBillAuthor: (billId, legislatorId) =>
`       INSERT INTO BillAuthors (BillId, LegislatorId)
        VALUES (${billId}, ${legislatorId});

        SELECT SCOPE_IDENTITY()
`,

    insertBillCoauthor: (billId, legislatorId) =>
`       INSERT INTO BillCoauthors (BillId, LegislatorId)
        VALUES (${billId}, ${legislatorId});

        SELECT SCOPE_IDENTITY()
`,

    insertBillCosponsor: (billId, legislatorId) => 
`       INSERT INTO BillCosponsors (BillId, LegislatorId)
        VALUES (${billId}, ${legislatorId});

        SELECT SCOPE_IDENTITY()
`,

    insertBillSponsor: (billId, legislatorId) => 
`       INSERT INTO BillSponsors (BillId, LegislatorId)
        VALUES (${billId}, ${legislatorId});

        SELECT SCOPE_IDENTITY()
`,

    insertBillVersion: (billId, version) => 
`       INSERT INTO [dbo].[BillVersions]
        (
            [BillId]
            ,[Stage]
            ,[Updated]
            ,[Created]
            ,[Title]
            ,[Year]
            ,[LongDescription]
            ,[Link]
            ,[Printed]
            ,[PrintVersionName]
            ,[Filed]
            ,[Introduced]
            ,[ShortDescription]
            ,[Digest]
            ,[PrintVersion]
        )
        VALUES
        (
            ${billId}
            ,${cleanString(version.stage)}
            ,${convertDate(version.updated)}
            ,${convertDate(version.created)}
            ,${cleanString(version.title)}
            ,${cleanString(version.year)}
            ,${cleanString(version.longDescription)}
            ,${cleanString(version.link)}
            ,${convertDate(version.printed)}
            ,${cleanString(version.printVersionName)}
            ,${convertDate(version.filed)}
            ,${convertDate(version.introduced)}
            ,${cleanString(version.shortDescription)}
            ,'${version.digest}'
            ,${version.printVersion}
        );

        SELECT SCOPE_IDENTITY()
`,
    insertBillVersionItem: (billId, item) => 
`       INSERT INTO [dbo].[BillVersionItems]
        (
            [BillId]
           ,[Year]
           ,[ShortDescription]
           ,[Digest]
           ,[Title]
           ,[PrintVersion]
           ,[Updated]
           ,[LongDescription]
           ,[Link]
           ,[Printed]
           ,[StageVerbose]
           ,[Stage]
           ,[Created]
           ,[Filed]
           ,[PrintVersionName]
           ,[Introduced]
           ,[FiscalNotesLink]
        )
        VALUES
        (  
            ${billId} 
           ,${cleanString(item.year)}
           ,${cleanString(item.shortDescription)}
           ,'${item.digest}'
           ,${cleanString(item.title)}
           ,${item.printVersion}
           ,${convertDate(item.updated)}
           ,${cleanString(item.longDescription)}
           ,${cleanString(item.link)}
           ,${convertDate(item.printed)}
           ,${cleanString(item.stageVerbose)}
           ,${cleanString(item.stage)}
           ,${convertDate(item.created)}
           ,${convertDate(item.filed)}
           ,${cleanString(item.printVersionName)}
           ,${convertDate(item.introduced)}
           ,${cleanString(item['fiscal-notes'].link)}
        );

        SELECT SCOPE_IDENTITY()
`,

    insertBillVersionItemAdvisor: (billVersionItemId, legislatorId) =>
`       INSERT INTO BillVersionItemAdvisors (BillVersionItemId, LegislatorId)
        VALUES (${billVersionItemId}, ${legislatorId});

        SELECT SCOPE_IDENTITY()
`,

    insertBillVersionItemAuthor: (billVersionItemId, legislatorId) =>
`       INSERT INTO BillVersionItemAuthors (BillVersionItemId, LegislatorId)
        VALUES (${billVersionItemId}, ${legislatorId});

        SELECT SCOPE_IDENTITY()
`,

    insertBillVersionItemCoauthor: (billVersionItemId, legislatorId) =>
`       INSERT INTO BillVersionItemCoauthors (BillVersionItemId, LegislatorId)
        VALUES (${billVersionItemId}, ${legislatorId});

        SELECT SCOPE_IDENTITY()
`,

    insertBillVersionItemCosponsor: (billVersionItemId, legislatorId) =>
`       INSERT INTO BillVersionItemCosponsors (BillVersionItemId, LegislatorId)
        VALUES (${billVersionItemId}, ${legislatorId});

        SELECT SCOPE_IDENTITY()
`,

    insertBillVersionItemRollCall: (billVersionItemId, rollCallId) =>
`       INSERT INTO BillVersionItemRollCalls (BillVersionItemId, RollCallId)
        VALUES (${billVersionItemId}, ${rollCallId});

        SELECT SCOPE_IDENTITY()
`,

    insertBillVersionItemSponsor: (billVersionItemId, legislatorId) =>
`       INSERT INTO BillVersionItemSponsors (BillVersionItemId, LegislatorId)
        VALUES (${billVersionItemId}, ${legislatorId});

        SELECT SCOPE_IDENTITY()
`,

    insertBillVersionItemSubject: (billVersionItemId, subjectId) =>
`       INSERT INTO BillVersionItemSubjects (BillVersionItemId, SubjectId)
        VALUES (${billVersionItemId}, ${subjectId});

        SELECT SCOPE_IDENTITY()
`,

    insertCommitteeReport: (billVersionItemId, report) =>
`
        INSERT INTO [dbo].[CommitteeReports]
        (
            [BillVersionItemId]
           ,[Type]
           ,[State]
           ,[Link]
           ,[Name]
        )
        VALUES
        (
            ${billVersionItemId}
           ,${cleanString(report.type)}
           ,${cleanString(report.state)}
           ,${cleanString(report.link)}
           ,${cleanString(report.name)}
        );

        SELECT SCOPE_IDENTITY()
`,

    insertLegislator: (legislator) =>
`       INSERT INTO [dbo].[Legislators]
        (
            [FirstName]
            ,[LastName]
            ,[Link]
            ,[PositionTitle]
            ,[Party]
            ,[FullName]
        )
        VALUES
        (
            ${cleanString(legislator.firstName)}
            ,${cleanString(legislator.lastName)}
            ,${cleanString(legislator.link)}
            ,${cleanString(legislator.position_title)}
            ,${cleanString(legislator.party)}
            ,${cleanString(legislator.fullName)}
        );

        SELECT SCOPE_IDENTITY()
`,
    
    insertMotion: (billId, authorLegislatorId, motion) => 
`       INSERT INTO [dbo].[Motions]
        (
            [BillId]
            ,[Name]
            ,[AuthorLegislatorId]
            ,[State]
            ,[Link]
            ,[Filed]
            ,[Type]
            ,[BillNum]
        )
        VALUES
        (
            ${billId}
            ,${cleanString(motion.name)}
            ,${authorLegislatorId}
            ,${cleanString(motion.state)}
            ,${cleanString(motion.link)}
            ,${convertDate(motion.filed)}
            ,${cleanString(motion.type)}
            ,${cleanString(motion.billnum)}
        );

        SELECT SCOPE_IDENTITY()
`,

    insertMotionRollCall: (motionId, rollCallId) =>
`       INSERT INTO MotionRollCalls (MotionId, RollCallId)
        VALUES (${motionId}, ${rollCallId});

        SELECT SCOPE_IDENTITY()
`,

    insertRollCall: (rollCall) =>
`       INSERT INTO [dbo].[RollCalls]
        (
            [Chamber]
            ,[Link]
            ,[Target]
            ,[Yea]
            ,[Nay]
        )
        VALUES
        (
            ${optional(rollCall.chamber, 'name')}
            ,${cleanString(rollCall.link)}
            ,${cleanString(rollCall.target)}
            ,${rollCall.results.yea}
            ,${rollCall.results.nay}
        );

        SELECT SCOPE_IDENTITY()
`,

    insertSubject: (subject) =>
`
        INSERT INTO Subjects
        (
            [Name],
            [Link]
        )
        VALUES
        (
            ${cleanString(subject.entry)}
            ,${cleanString(subject.link)}
        );

        SELECT SCOPE_IDENTITY()
`
};