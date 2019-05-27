USE [IGA-2016-v3]

CREATE TABLE Bills
(
    Id INT IDENTITY(1,1),
    OriginChamber NVARCHAR(MAX),
    BillName NVARCHAR(MAX),
    Link NVARCHAR(MAX),
    [Type] NVARCHAR(MAX),
    [Number] INT,
    CurrentChamber NVARCHAR(MAX),
    [Year] NVARCHAR(MAX),
    Title NVARCHAR(MAX),
    [Status] NVARCHAR(MAX),
    [Description] NVARCHAR(MAX),
    CommitteeStatus NVARCHAR(MAX),
    Stage NVARCHAR(MAX)
)

CREATE TABLE BillAdvisors
(
    BillId INT,
    LegislatorId INT
)

CREATE TABLE BillSponsors
(
    BillId INT,
    LegislatorId INT
)

CREATE TABLE BillCoauthors
(
    BillId INT,
    LegislatorId INT
)

CREATE TABLE BillAuthors
(
    BillId INT,
    LegislatorId INT
)

CREATE TABLE BillCosponsors
(
    BillId INT,
    LegislatorId INT
)

CREATE TABLE BillVersions
(
    Id INT IDENTITY(1,1),
    BillId INT,
    Stage NVARCHAR(MAX),
    Updated datetime,
    Created datetime,
    Title NVARCHAR(MAX),
    [Year] NVARCHAR(MAX),
    LongDescription NVARCHAR(MAX),
    Link NVARCHAR(MAX),
    Printed datetime,
    PrintVersionName NVARCHAR(MAX),
    Filed datetime,
    StageVerbose NVARCHAR(MAX),
    Introduced datetime,
    ShortDescription NVARCHAR(MAX),
    [Digest] NVARCHAR(MAX),
    PrintVersion INT
)

CREATE TABLE BillVersionItems
(
    Id INT IDENTITY(1,1),
	BillId INT,
    [Year] NVARCHAR(MAX),
    ShortDescription NVARCHAR(MAX),
    [Digest] NVARCHAR(MAX),
    Title NVARCHAR(MAX),
    PrintVersion INT,
    Updated datetime,
    LongDescription NVARCHAR(MAX),
    Link NVARCHAR(MAX),
    Printed datetime,
    StageVerbose NVARCHAR(MAX),
    Stage NVARCHAR(MAX),
    Created datetime,
    Filed datetime,
    PrintVersionName NVARCHAR(MAX),
    Introduced datetime,
    FiscalNotesLink NVARCHAR(MAX)
)

CREATE TABLE BillVersionItemAdvisors
(
    BillVersionItemId INT,
    LegislatorId INT
)

CREATE TABLE BillVersionItemSponsors
(
    BillVersionItemId INT,
    LegislatorId INT
)

CREATE TABLE BillVersionItemAuthors
(
    BillVersionItemId INT,
    LegislatorId INT
)

CREATE TABLE BillVersionItemCoauthors
(
    BillVersionItemId INT,
    LegislatorId INT
)

CREATE TABLE BillVersionItemCosponsors
(
    BillVersionItemId INT,
    LegislatorId INT
)

CREATE TABLE BillVersionItemRollCalls
(
    BillVersionItemId INT,
    RollCallId INT
)

CREATE TABLE BillVersionItemSubjects
(
    BillVersionItemId INT,
    SubjectId INT
)

CREATE TABLE Motions
(
    Id INT IDENTITY(1,1),
	BillId INT,
    [Name] NVARCHAR(MAX),
    AuthorLegislatorId INT,
    [State] NVARCHAR(MAX),
    Link NVARCHAR(MAX),
    Filed datetime,
    [Type] NVARCHAR(MAX),
    BillNum NVARCHAR(MAX)
)

CREATE TABLE MotionRollCalls
(
    MotionId INT,
    RollCallId INT
)

CREATE TABLE RollCalls
(
    Id INT IDENTITY(1,1),
    Chamber NVARCHAR(MAX),
    Link NVARCHAR(MAX),
    [Target] NVARCHAR(MAX),
    Yea INT,
    Nay INT
)

CREATE TABLE Actions
(
    Id INT IDENTITY(1,1),
    BillId INT,
    [Description] NVARCHAR(MAX),
    [Sequence] NVARCHAR(MAX),
    Chamber NVARCHAR(MAX),
    Link NVARCHAR(MAX),
    CommitteeLink NVARCHAR(MAX),
    [Date] datetime,
    [Day] NVARCHAR(MAX)
)

CREATE TABLE Amendments
(
    Id INT IDENTITY(1,1),
    BillVersionItemId INT,
    AmendmentType NVARCHAR(MAX),
    [Name] NVARCHAR(MAX),
    AuthorLegislatorId INT,
    PublishTime datetime,
    [State] NVARCHAR(MAX),
    Link NVARCHAR(MAX),
    BillVersionLink NVARCHAR(MAX),
    [Description] NVARCHAR(MAX)
)

CREATE TABLE Legislators
(
    Id INT IDENTITY(1,1),
    FirstName NVARCHAR(MAX),
    LastName NVARCHAR(MAX),
    Link NVARCHAR(MAX),
    PositionTitle NVARCHAR(MAX),
    Party NVARCHAR(MAX),
    FullName NVARCHAR(MAX)
)

CREATE TABLE CommitteeReports
(
    Id INT IDENTITY(1,1),
    BillVersionItemId int,
    [Type] NVARCHAR(MAX),
    [State] NVARCHAR(MAX),
    Link NVARCHAR(MAX),
    [Name] NVARCHAR(MAX)
)

CREATE TABLE Subjects
(
    Id INT IDENTITY(1,1),
    [Name] NVARCHAR(MAX),
    Link NVARCHAR(MAX)
)