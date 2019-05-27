USE [IGA-2016-v3]

GO

CREATE FUNCTION BillSubjects()
RETURNS @BillSubjectsTable TABLE
(
	BillId INT,
	SubjectId INT
)
BEGIN
	INSERT INTO @BillSubjectsTable
	SELECT BillVersionItems.BillId, BillVersionItemSubjects.SubjectId
	FROM BillVersionItemSubjects
	INNER JOIN BillVersionItems ON BillVersionItems.Id = BillVersionItemSubjects.BillVersionItemId
	GROUP BY BillVersionItems.BillId, BillVersionItemSubjects.SubjectId

	RETURN
END

GO

CREATE FUNCTION LatestActionDescription(@BillId INT)
RETURNS NVARCHAR(MAX)
BEGIN
	DECLARE @Description NVARCHAR(MAX)

	SELECT TOP 1 @Description = Description
	FROM Actions
	WHERE BillId = @BillId
	ORDER BY Date Desc

	RETURN @Description
END

GO

CREATE FUNCTION SubjectAdvisor()
RETURNS @SubjectAdvisorTable TABLE
(
	[Subject] NVARCHAR(MAX), 
	advisor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN

	INSERT INTO @SubjectAdvisorTable
	SELECT Subjects.Name [Subject], advisors.FullName advisor_FullName, COUNT(*) [count]
	FROM Legislators advisors
	INNER JOIN BillAdvisors ON BillAdvisors.LegislatorId = advisors.Id
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillAdvisors.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	GROUP BY Subjects.Name, advisors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END
GO

CREATE FUNCTION SubjectAdvisorAdvisor()
RETURNS @SubjectAdvisorAdvisorTable TABLE
(
	[Subject] NVARCHAR(MAX),
	advisor_FullName NVARCHAR(MAX),
	advisor2_FullName NVARCHAR(MAX),
	[count] INT
) 
BEGIN
	INSERT INTO @SubjectAdvisorAdvisorTable 
	SELECT Subjects.Name [Subject], advisors.FullName advisor_FullName, advisors2.FullName advisor2_FullName, COUNT(*) [count] 
	FROM Legislators advisors
	INNER JOIN BillAdvisors ON BillAdvisors.LegislatorId = advisors.Id
	INNER JOIN BillAdvisors BillAdvisors2 ON BillAdvisors2.BillId = BillAdvisors.BillId
	INNER JOIN Legislators advisors2 ON advisors2.Id = BillAdvisors2.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillAdvisors.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	WHERE advisors.Id != advisors2.Id
	GROUP BY Subjects.Name, advisors.FullName, advisors2.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectAuthor()
RETURNS @SubjectAuthorTable TABLE
(
	[Subject] NVARCHAR(MAX),
	author_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectAuthorTable
	SELECT Subjects.Name [Subject], authors.FullName author_FullName, COUNT(*) [count]
	FROM Legislators authors
	INNER JOIN BillAuthors ON BillAuthors.LegislatorId = authors.Id
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillAuthors.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	GROUP BY Subjects.Name, authors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectAuthorAdvisor()
RETURNS @SubjectAuthorAdvisorTable TABLE
(
	[Subject] NVARCHAR(MAX),
	author_FullName NVARCHAR(MAX),
	advisor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectAuthorAdvisorTable
	SELECT Subjects.Name [Subject], authors.FullName author_FullName, advisors.FullName advisor_FullName, COUNT(*) [count] 
	FROM Legislators authors
	INNER JOIN BillAuthors ON BillAuthors.LegislatorId = authors.Id
	INNER JOIN BillAdvisors ON BillAdvisors.BillId = BillAuthors.BillId
	INNER JOIN Legislators advisors ON advisors.Id = BillAdvisors.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillAuthors.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	GROUP BY Subjects.Name, authors.FullName, advisors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO 

CREATE FUNCTION SubjectAuthorAuthor()
RETURNS @SubjectAuthorAuthorTable TABLE
(
	Subject NVARCHAR(MAX),
	author_FullName NVARCHAR(MAX),
	author2_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectAuthorAuthorTable
	SELECT Subjects.Name [Subject], authors.FullName author_FullName, authors2.FullName author2_FullName, COUNT(*) [count] 
	FROM Legislators authors
	INNER JOIN BillAuthors ON BillAuthors.LegislatorId = authors.Id
	INNER JOIN BillAuthors BillAuthors2 ON BillAuthors2.BillId = BillAuthors.BillId
	INNER JOIN Legislators authors2 ON authors2.Id = BillAuthors2.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillAuthors.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	WHERE authors.Id != authors2.Id
	GROUP BY authors.FullName, authors2.FullName, Subjects.Name
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectAuthorCoauthor()
RETURNS @SubjectAuthorCoauthorTable TABLE
(
	Subject NVARCHAR(MAX),
	author_FullName NVARCHAR(MAX),
	coauthor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectAuthorCoauthorTable
	SELECT Subjects.Name [Subject], authors.FullName author_FullName, coauthors.FullName coauthor_FullName, COUNT(*) [count] 
	FROM Legislators authors
	INNER JOIN BillAuthors ON BillAuthors.LegislatorId = authors.Id
	INNER JOIN BillCoauthors ON BillCoauthors.BillId = BillAuthors.BillId
	INNER JOIN Legislators coauthors ON coauthors.Id = BillCoauthors.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillAuthors.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	GROUP BY Subjects.Name, authors.FullName, coauthors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectAuthorCosponsor()
RETURNS @SubjectAuthorCosponsorTable TABLE
(
	Subject NVARCHAR(MAX),
	author_FullName NVARCHAR(MAX),
	cosponsor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectAuthorCosponsorTable
	SELECT Subjects.Name [Subject], authors.FullName author_FullName, cosponsors.FullName cosponsor_FullName, COUNT(*) [count] 
	FROM Legislators authors
	INNER JOIN BillAuthors ON BillAuthors.LegislatorId = authors.Id
	INNER JOIN BillCosponsors ON BillCosponsors.BillId = BillAuthors.BillId
	INNER JOIN Legislators cosponsors ON cosponsors.Id = BillCosponsors.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillAuthors.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	GROUP BY Subjects.Name, authors.FullName, cosponsors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectAuthorSponsor()
RETURNS @SubjectAuthorSponsorTable TABLE
(
	Subject NVARCHAR(MAX),
	author_FullName NVARCHAR(MAX),
	sponsor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectAuthorSponsorTable
	SELECT Subjects.Name [Subject], authors.FullName author_FullName, sponsors.FullName sponsor_FullName, COUNT(*) [count] 
	FROM Legislators authors
	INNER JOIN BillAuthors ON BillAuthors.LegislatorId = authors.Id
	INNER JOIN BillSponsors ON BillSponsors.BillId = BillAuthors.BillId
	INNER JOIN Legislators sponsors ON sponsors.Id = BillSponsors.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillAuthors.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	GROUP BY Subjects.Name, authors.FullName, sponsors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectCoauthor()
RETURNS @SubjectCoauthorTable TABLE
(
	Subject NVARCHAR(MAX),
	coauthor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectCoauthorTable
	SELECT Subjects.Name [Subject], coauthors.FullName coauthor_FullName, COUNT(*) [count]
	FROM Legislators coauthors
	INNER JOIN BillCoauthors ON BillCoauthors.LegislatorId = coauthors.Id
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillCoauthors.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	GROUP BY Subjects.Name, coauthors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectCoauthorAdvisor()
RETURNS @SubjectCoauthorAdvisorTable TABLE
(
	Subject NVARCHAR(MAX),
	coauthor_FullName NVARCHAR(MAX),
	advisor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectCoauthorAdvisorTable
	SELECT Subjects.Name [Subject], coauthors.FullName coauthor_FullName, advisors.FullName advisor_FullName, COUNT(*) [count] 
	FROM Legislators coauthors
	INNER JOIN BillCoauthors ON BillCoauthors.LegislatorId = coauthors.Id
	INNER JOIN BillAdvisors ON BillAdvisors.BillId = BillCoauthors.BillId
	INNER JOIN Legislators advisors ON advisors.Id = BillAdvisors.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillCoauthors.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	GROUP BY Subjects.Name, coauthors.FullName, advisors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectCoauthorCoauthor()
RETURNS @SubjectCoauthorCoauthorTable TABLE
(
	Subject NVARCHAR(MAX),
	coauthor_FullName NVARCHAR(MAX),
	coauthor2_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectCoauthorCoauthorTable
	SELECT Subjects.Name [Subject], coauthors.FullName coauthor_FullName, coauthors2.FullName coauthor2_FullName, COUNT(*) [count] 
	FROM Legislators coauthors
	INNER JOIN BillCoauthors ON BillCoauthors.LegislatorId = coauthors.Id
	INNER JOIN BillCoauthors BillCoauthors2 ON BillCoauthors2.BillId = BillCoauthors.BillId
	INNER JOIN Legislators coauthors2 ON coauthors2.Id = BillCoauthors2.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillCoauthors.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	WHERE coauthors.Id != coauthors2.Id
	GROUP BY Subjects.Name, coauthors.FullName, coauthors2.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectCoauthorCosponsor()
RETURNS @SubjectCoauthorCosponsorTable TABLE
(
	Subject NVARCHAR(MAX),
	coauthor_FullName NVARCHAR(MAX),
	cosponsors_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectCoauthorCosponsorTable
	SELECT Subjects.Name [Subject], coauthors.FullName coauthor_FullName, cosponsors.FullName cosponsor_FullName, COUNT(*) [count] 
	FROM Legislators coauthors
	INNER JOIN BillCoauthors ON BillCoauthors.LegislatorId = coauthors.Id
	INNER JOIN BillCosponsors ON BillCosponsors.BillId = BillCoauthors.BillId
	INNER JOIN Legislators cosponsors ON cosponsors.Id = BillCosponsors.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillCoauthors.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	GROUP BY Subjects.Name, coauthors.FullName, cosponsors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectCoauthorSponsor()
RETURNS @SubjectCoauthorSponsorTable TABLE
(
	Subject NVARCHAR(MAX),
	coauthor_FulName NVARCHAR(MAX),
	sponsor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectCoauthorSponsorTable
	SELECT Subjects.Name [Subject], coauthors.FullName coauthor_FullName, sponsors.FullName sponsor_FullName, COUNT(*) [count] 
	FROM Legislators coauthors
	INNER JOIN BillCoauthors ON BillCoauthors.LegislatorId = coauthors.Id
	INNER JOIN BillSponsors ON BillSponsors.BillId = BillCoauthors.BillId
	INNER JOIN Legislators sponsors ON sponsors.Id = BillSponsors.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillCoauthors.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	GROUP BY Subjects.Name, coauthors.FullName, sponsors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectCosponsor()
RETURNS @SubjectCosponsorTable TABLE
(
	Subject NVARCHAR(MAX),
	cosponsor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectCosponsorTable
	SELECT Subjects.Name [Subject], cosponsors.FullName cosponsor_FullName, COUNT(*) [count]
	FROM Legislators cosponsors
	INNER JOIN BillCosponsors ON BillCosponsors.LegislatorId = cosponsors.Id
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillCosponsors.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	GROUP BY Subjects.Name, cosponsors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectCosponsorCosponsor()
RETURNS @SubjectCosponsorCosponsorTable TABLE
(
	Subject NVARCHAR(MAX),
	cosponsor_FullName NVARCHAR(MAX),
	cosponsor2_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectCosponsorCosponsorTable
	SELECT Subjects.Name [Subject], cosponsors.FullName cosponsor_FullName, cosponsors2.FullName cosponsor2_FullName, COUNT(*) [count] 
	FROM Legislators cosponsors
	INNER JOIN BillCosponsors ON BillCosponsors.LegislatorId = cosponsors.Id
	INNER JOIN BillCosponsors BillCosponsors2 ON BillCosponsors2.BillId = BillCosponsors.BillId
	INNER JOIN Legislators cosponsors2 ON cosponsors2.Id = BillCosponsors2.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillCosponsors.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	WHERE cosponsors.Id != cosponsors2.Id
	GROUP BY Subjects.Name, cosponsors.FullName, cosponsors2.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectSponsorCosponsor()
RETURNS @SubjectSponsorCosponsorTable TABLE
(
	Subject NVARCHAR(MAX),
	sponsor_FulName NVARCHAR(MAX),
	cosponsor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectSponsorCosponsorTable
	SELECT Subjects.Name [Subject], sponsors.FullName sponsor_FullName, cosponsors.FullName cosponsor_FullName, COUNT(*) [count] 
	FROM Legislators sponsors
	INNER JOIN BillSponsors ON BillSponsors.LegislatorId = sponsors.Id
	INNER JOIN BillCosponsors ON BillCosponsors.BillId = BillSponsors.BillId
	INNER JOIN Legislators cosponsors ON sponsors.Id = BillSponsors.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillCosponsors.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	GROUP BY Subjects.Name, cosponsors.FullName, sponsors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectSponsor()
RETURNS @SubjectSponsorTable TABLE
(
	Subject NVARCHAR(MAX),
	sponsor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectSponsorTable
	SELECT Subjects.Name [Subject], sponsors.FullName sponsor_FullName, COUNT(*) [count]
	FROM Legislators sponsors
	INNER JOIN BillSponsors ON BillSponsors.LegislatorId = sponsors.Id
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillSponsors.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	GROUP BY Subjects.Name, sponsors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectSponsorSponsor()
RETURNS @SubjectSponsorSponsorTable TABLE
(
	Subject NVARCHAR(MAX),
	sponsor_FullName NVARCHAR(MAX),
	sponsor2_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectSponsorSponsorTable
	SELECT Subjects.Name [Subject], sponsors.FullName sponsor_FullName, sponsors2.FullName sponsor2_FullName, COUNT(*) [count] 
	FROM Legislators sponsors
	INNER JOIN BillSponsors ON BillSponsors.LegislatorId = sponsors.Id
	INNER JOIN BillSponsors BillSponsors2 ON BillSponsors2.BillId = BillSponsors.BillId
	INNER JOIN Legislators sponsors2 ON sponsors.Id = BillSponsors.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillSponsors2.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	WHERE sponsors.Id != sponsors2.Id
	GROUP BY Subjects.Name, sponsors.FullName, sponsors2.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectActionAdvisor()
RETURNS @SubjectActionAdvisorTable TABLE
(
	Action NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	advisor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectActionAdvisorTable
	SELECT Actions.Description Action, Subjects.Name [Subject], advisors.FullName advisor_FullName, COUNT(*)
	FROM Legislators advisors
	INNER JOIN BillAdvisors ON BillAdvisors.LegislatorId = advisors.Id
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillAdvisors.BillId
	INNER JOIN Bills ON Bills.Id = BillSubjects.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	INNER JOIN Actions ON Actions.BillId = Bills.Id
	GROUP BY Actions.Description, Subjects.Name, advisors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectActionAuthor()
RETURNS @SubjectActionAuthorTable TABLE
(
	Action NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	author_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectActionAuthorTable
	SELECT Actions.Description Action, Subjects.Name [Subject], authors.FullName author_FullName, COUNT(*)
	FROM Legislators authors
	INNER JOIN BillAuthors ON BillAuthors.LegislatorId = authors.Id
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillAuthors.BillId
	INNER JOIN Bills ON Bills.Id = BillSubjects.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	INNER JOIN Actions ON Actions.BillId = Bills.Id
	GROUP BY Actions.Description, Subjects.Name, authors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectActionCoauthor()
RETURNS @SubjectActionCoauthorTable TABLE
(
	Action NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	coauthor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectActionCoauthorTable
	SELECT Actions.Description Action, Subjects.Name [Subject], coauthors.FullName coauthor_FullName, COUNT(*)
	FROM Legislators coauthors
	INNER JOIN BillCoauthors ON BillCoauthors.LegislatorId = coauthors.Id
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillCoauthors.BillId
	INNER JOIN Bills ON Bills.Id = BillSubjects.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	INNER JOIN Actions ON Actions.BillId = Bills.Id
	GROUP BY Actions.Description, Subjects.Name, coauthors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectActionCosponsor()
RETURNS @SubjectActionCosponsorTable TABLE
(
	Action NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	cosponsor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectActionCosponsorTable
	SELECT Actions.Description Action, Subjects.Name [Subject], cosponsors.FullName cosponsor_FullName, COUNT(*)
	FROM Legislators cosponsors
	INNER JOIN BillCosponsors ON BillCosponsors.LegislatorId = cosponsors.Id
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillCosponsors.BillId
	INNER JOIN Bills ON Bills.Id = BillSubjects.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	INNER JOIN Actions ON Actions.BillId = Bills.Id
	GROUP BY Actions.Description, Subjects.Name, cosponsors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectActionSponsor()
RETURNS @SubjectActionSponsorTable TABLE
(
	Action NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	sponsor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectActionSponsorTable
	SELECT Actions.Description Action, Subjects.Name [Subject], sponsors.FullName sponsor_FullName, COUNT(*)
	FROM Legislators sponsors
	INNER JOIN BillSponsors ON BillSponsors.LegislatorId = sponsors.Id
	INNER JOIN BillSubjects() ON BillSubjects.BillId = BillSponsors.BillId
	INNER JOIN Bills ON Bills.Id = BillSubjects.BillId
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	INNER JOIN Actions ON Actions.BillId = Bills.Id
	GROUP BY Actions.Description, Subjects.Name, sponsors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectActionAuthorAuthor()
RETURNS @SubjectActionAuthorAuthorTable TABLE
(
	Action NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	author_FullName NVARCHAR(MAX),
	author2_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectActionAuthorAuthorTable
	SELECT Actions.Description Action, Subjects.Name [Subject], authors.FullName author_FullName, authors2.FullName author2_FullName, COUNT(*)
	FROM Legislators authors
	INNER JOIN BillAuthors ON BillAuthors.LegislatorId = authors.Id
	INNER JOIN Bills ON Bills.Id = BillAuthors.BillId
	INNER JOIN BillAuthors BillAuthors2 on BillAuthors2.BillId = BillAuthors.BillId
	INNER JOIN Legislators authors2 ON authors2.Id = BillAuthors2.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = Bills.Id
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	INNER JOIN Actions ON Actions.BillId = Bills.Id
	WHERE authors.Id != authors2.Id
	GROUP BY Actions.Description, Subjects.Name, authors.FullName, authors2.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectActionAuthorCoauthor()
RETURNS @SubjectActionAuthorCoauthorTable TABLE
(
	Action NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	author_FullName NVARCHAR(MAX),
	coauthor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectActionAuthorCoauthorTable
	SELECT Actions.Description Action, Subjects.Name [Subject], authors.FullName author_FullName, coauthors.FullName coauthor_FullName, COUNT(*)
	FROM Legislators authors
	INNER JOIN BillAuthors ON BillAuthors.LegislatorId = authors.Id
	INNER JOIN Bills ON Bills.Id = BillAuthors.BillId
	INNER JOIN BillCoauthors on BillCoauthors.BillId = Bills.Id
	INNER JOIN Legislators coauthors ON coauthors.Id = BillCoauthors.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = Bills.Id
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	INNER JOIN Actions ON Actions.BillId = Bills.Id
	GROUP BY Actions.Description, Subjects.Name, authors.FullName, coauthors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectActionAuthorCosponsor()
RETURNS @SubjectActionAuthorCosponsorTable TABLE
(
	Action NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	author_FullName NVARCHAR(MAX),
	cosponsor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectActionAuthorCosponsorTable
	SELECT Actions.Description Action, Subjects.Name [Subject], authors.FullName author_FullName, cosponsors.FullName cosponsor_FullName, COUNT(*)
	FROM Legislators authors
	INNER JOIN BillAuthors ON BillAuthors.LegislatorId = authors.Id
	INNER JOIN Bills ON Bills.Id = BillAuthors.BillId
	INNER JOIN BillCosponsors on BillCosponsors.BillId = Bills.Id
	INNER JOIN Legislators cosponsors ON cosponsors.Id = BillCosponsors.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = Bills.Id
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	INNER JOIN Actions ON Actions.BillId = Bills.Id
	GROUP BY Actions.Description, Subjects.Name, authors.FullName, cosponsors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectActionAuthorSponsor()
RETURNS @SubjectActionAuthorSponsorTable TABLE
(
	Action NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	author_FullName NVARCHAR(MAX),
	sponsor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectActionAuthorSponsorTable
	SELECT Actions.Description Action, Subjects.Name [Subject], authors.FullName author_FullName, sponsors.FullName sponsor_FullName, COUNT(*)
	FROM Legislators authors
	INNER JOIN BillAuthors ON BillAuthors.LegislatorId = authors.Id
	INNER JOIN Bills ON Bills.Id = BillAuthors.BillId
	INNER JOIN BillSponsors on BillSponsors.BillId = Bills.Id
	INNER JOIN Legislators sponsors ON sponsors.Id = BillSponsors.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = Bills.Id
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	INNER JOIN Actions ON Actions.BillId = Bills.Id
	GROUP BY Actions.Description, Subjects.Name, authors.FullName, sponsors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectActionCoauthorCoauthor()
RETURNS @SubjectActionCoauthorCoauthorTable TABLE
(
	Action NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	coauthor_FullName NVARCHAR(MAX),
	coauthor2_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectActionCoauthorCoauthorTable
	SELECT Actions.Description Action, Subjects.Name [Subject], coauthors.FullName coauthor_FullName, coauthors2.FullName coauthor2_FullName, COUNT(*)
	FROM Legislators coauthors
	INNER JOIN BillCoauthors ON BillCoauthors.LegislatorId = coauthors.Id
	INNER JOIN Bills ON Bills.Id = BillCoauthors.BillId
	INNER JOIN BillCoauthors BillCoauthors2 on BillCoauthors2.BillId = Bills.Id
	INNER JOIN Legislators coauthors2 ON coauthors2.Id = BillCoauthors2.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = Bills.Id
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	INNER JOIN Actions ON Actions.BillId = Bills.Id
	WHERE coauthors.Id != coauthors2.Id
	GROUP BY Actions.Description, Subjects.Name, coauthors.FullName, coauthors2.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectActionCoauthorCosponsor()
RETURNS @SubjectActionCoauthorCosponsorTable TABLE
(
	Action NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	coauthor_FullName NVARCHAR(MAX),
	cosponsor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectActionCoauthorCosponsorTable
	SELECT Actions.Description Action, Subjects.Name [Subject], coauthors.FullName coauthor_FullName, cosponsors.FullName cosponsor_FullName, COUNT(*)
	FROM Legislators coauthors
	INNER JOIN BillCoauthors ON BillCoauthors.LegislatorId = coauthors.Id
	INNER JOIN Bills ON Bills.Id = BillCoauthors.BillId
	INNER JOIN BillCosponsors on BillCosponsors.BillId = Bills.Id
	INNER JOIN Legislators cosponsors ON cosponsors.Id = BillCosponsors.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = Bills.Id
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	INNER JOIN Actions ON Actions.BillId = Bills.Id
	GROUP BY Actions.Description, Subjects.Name, coauthors.FullName, cosponsors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectActionCoauthorSponsor()
RETURNS @SubjectActionCoauthorSponsorTable TABLE
(
	Action NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	coauthor_FullName NVARCHAR(MAX),
	sponsor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectActionCoauthorSponsorTable
	SELECT Actions.Description Action, Subjects.Name [Subject], coauthors.FullName coauthor_FullName, sponsors.FullName sponsor_FullName, COUNT(*)
	FROM Legislators coauthors
	INNER JOIN BillCoauthors ON BillCoauthors.LegislatorId = coauthors.Id
	INNER JOIN Bills ON Bills.Id = BillCoauthors.BillId
	INNER JOIN BillSponsors on BillSponsors.BillId = Bills.Id
	INNER JOIN Legislators sponsors ON sponsors.Id = BillSponsors.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = Bills.Id
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	INNER JOIN Actions ON Actions.BillId = Bills.Id
	GROUP BY Actions.Description, Subjects.Name, coauthors.FullName, sponsors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectActionCosponsorCosponsor()
RETURNS @SubjectActionCosponsorCosponsorTable TABLE
(
	Action NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	cosponsor_FullName NVARCHAR(MAX),
	cosponsor2_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectActionCosponsorCosponsorTable
	SELECT Actions.Description Action, Subjects.Name [Subject], cosponsors.FullName cosponsor_FullName, cosponsors2.FullName cosponsor2_FullName, COUNT(*)
	FROM Legislators cosponsors
	INNER JOIN BillCosponsors ON BillCosponsors.LegislatorId = cosponsors.Id
	INNER JOIN Bills ON Bills.Id = BillCosponsors.BillId
	INNER JOIN BillCosponsors BillCosponsors2 on BillCosponsors2.BillId = Bills.Id
	INNER JOIN Legislators cosponsors2 ON cosponsors2.Id = BillCosponsors2.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = Bills.Id
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	INNER JOIN Actions ON Actions.BillId = Bills.Id
	GROUP BY Actions.Description, Subjects.Name, cosponsors.FullName, cosponsors2.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectActionSponsorCosponsor()
RETURNS @SubjectActionSponsorCosponsorTable TABLE
(
	Action NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	sponsor_FullName NVARCHAR(MAX),
	cosponsor_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectActionSponsorCosponsorTable
	SELECT Actions.Description Action, Subjects.Name [Subject], sponsors.FullName sponsor_FullName, cosponsors.FullName cosponsor_FullName, COUNT(*)
	FROM Legislators sponsors
	INNER JOIN BillSponsors ON BillSponsors.LegislatorId = sponsors.Id
	INNER JOIN Bills ON Bills.Id = BillSponsors.BillId
	INNER JOIN BillCosponsors on BillCosponsors.BillId = Bills.Id
	INNER JOIN Legislators cosponsors ON cosponsors.Id = BillCosponsors.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = Bills.Id
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	INNER JOIN Actions ON Actions.BillId = Bills.Id
	GROUP BY Actions.Description, Subjects.Name, sponsors.FullName, cosponsors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectActionSponsorSponsor()
RETURNS @SubjectActionSponsorSponsorTable TABLE
(
	Action NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	sponsor_FullName NVARCHAR(MAX),
	sponsor2_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectActionSponsorSponsorTable
	SELECT Actions.Description Action, Subjects.Name [Subject], sponsors.FullName sponsor_FullName, sponsors2.FullName sponsor2_FullName, COUNT(*)
	FROM Legislators sponsors
	INNER JOIN BillSponsors ON BillSponsors.LegislatorId = sponsors.Id
	INNER JOIN Bills ON Bills.Id = BillSponsors.BillId
	INNER JOIN BillSponsors BillSponsors2 on BillSponsors2.BillId = Bills.Id
	INNER JOIN Legislators sponsors2 ON sponsors2.Id = BillSponsors2.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = Bills.Id
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	INNER JOIN Actions ON Actions.BillId = Bills.Id
	GROUP BY Actions.Description, Subjects.Name, sponsors.FullName, sponsors2.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION BillTypeAuthorSubject()
RETURNS @BillTypeAuthorSubjectTable TABLE
(
	BillType NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	author_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @BillTypeAuthorSubjectTable
	SELECT Bills.Type BillType, Subjects.Name [Subject], authors.FullName author_FullName, COUNT(*)
	FROM Bills
	INNER JOIN BillSubjects() ON BillSubjects.BillId = Bills.Id
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	INNER JOIN BillAuthors ON BillAuthors.BillId = Bills.Id
	INNER JOIN Legislators authors ON authors.Id = BillAuthors.LegislatorId
	GROUP BY Bills.Type, Subjects.Name, authors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectChamberParty()
RETURNS @SubjectChamberPartyTable TABLE
(
	Subject NVARCHAR(MAX),
	OriginChamber NVARCHAR(MAX),
	AuthorParty NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectChamberPartyTable
	SELECT Subjects.Name [Subject], Bills.OriginChamber, authors.Party AuthorParty, COUNT(*)
	FROM Bills
	INNER JOIN BillSubjects() ON BillSubjects.BillId = Bills.Id
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	INNER JOIN BillAuthors ON BillAuthors.BillId = Bills.Id
	INNER JOIN Legislators authors ON authors.Id = BillAuthors.LegislatorId
	GROUP BY Subjects.Name, Bills.OriginChamber, authors.Party
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION AmendmentAuthorState()
RETURNS @AmendmentAuthorStateTable TABLE
(
	author_FullName NVARCHAR(MAX),
	AmendmentState NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @AmendmentAuthorStateTable
	SELECT authors.FullName author_FullName, Amendments.State AmendmentState, COUNT(*)
	FROM Amendments
	INNER JOIN BillVersionItemAuthors ON BillVersionItemAuthors.BillVersionItemId = Amendments.BillVersionItemId
	INNER JOIN Legislators authors ON authors.Id = BillVersionItemAuthors.LegislatorId
	GROUP BY authors.FullName, Amendments.State
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION AmendmentStateSubject()
RETURNS @AmendmentStateSubjectTable TABLE
(
	AmendmentState NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @AmendmentStateSubjectTable
	SELECT Amendments.State AmendmentState, Subjects.Name [Subject], COUNT(*)
	FROM Amendments
	INNER JOIN BillVersionItemSubjects ON BillVersionItemSubjects.BillVersionItemId = Amendments.BillVersionItemId
	INNER JOIN Subjects ON Subjects.Id = BillVersionItemSubjects.SubjectId
	GROUP BY Amendments.State, Subjects.Name
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION ActionSubjectSpeed()
RETURNS @ActionSubjectSpeedTable TABLE
(
	BillName NVARCHAR(MAX),
	FirstActionDate DATETIME,
	LatestActionDate DATETIME,
	LatestActionDescription NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	days INT
)
BEGIN
	INSERT INTO @ActionSubjectSpeedTable
	SELECT 
		Bills.BillName,
		MIN(Actions.Date) FirstActionDate, 
		MAX(Actions.Date) LatestActionDate,
		dbo.LatestActionDescription(Bills.Id) LatestActionDescription,
		Subjects.Name Subject,
		DATEDIFF(DAY, MIN(Actions.Date), MAX(Actions.Date)) [days]
	FROM Bills
	INNER JOIN Actions Actions ON Actions.BillId = Bills.Id
	INNER JOIN BillSubjects() ON BillSubjects.BillId = Bills.Id
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	GROUP BY Bills.Id, Bills.BillName, Subjects.Name
	ORDER BY Bills.BillName

	RETURN
END

GO

CREATE FUNCTION AuthorBillLifespan()
RETURNS @AuthorBillLifespanTable TABLE
(
	BillName NVARCHAR(MAX),
	FirstActionDate DATETIME,
	LatestActionDate DATETIME,
	LatestActionDescription NVARCHAR(MAX),
	author_FullName NVARCHAR(MAX),
	[days] INT

)
BEGIN
	INSERT INTO @AuthorBillLifespanTable
	SELECT 
		Bills.BillName,
		MIN(Actions.Date) FirstActionDate, 
		MAX(Actions.Date) LatestActionDate,
		dbo.LatestActionDescription(Bills.Id) LatestActionDescription,
		authors.FullName author_FullName,
		DATEDIFF(DAY, MIN(Actions.Date), MAX(Actions.Date)) [days]
	FROM Bills
	INNER JOIN Actions Actions ON Actions.BillId = Bills.Id
	INNER JOIN BillAuthors ON BillAuthors.BillId = Bills.Id
	INNER JOIN Legislators authors ON authors.Id = BillAuthors.LegislatorId
	GROUP BY Bills.Id, Bills.BillName, authors.FullName
	ORDER BY Bills.BillName, authors.FullName

	RETURN
	
END

GO

CREATE FUNCTION ActionSubjectSequence()
RETURNS @ActionSubjectSequenceTable TABLE
(
	Subject NVARCHAR(MAX),
	Sequence NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @ActionSubjectSequenceTable
	SELECT Subjects.Name Subject, Actions.Sequence, COUNT(*)
	FROM Actions
	INNER JOIN BillVersionItems ON BillVersionItems.BillId = Actions.BillId
	INNER JOIN BillVersionItemSubjects ON BillVersionItemSubjects.BillVersionItemId = BillVersionItems.Id
	INNER JOIN Subjects ON Subjects.Id = BillVersionItemSubjects.SubjectId
	GROUP BY Subjects.Name, Actions.Sequence
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION BillActionSequenceCountByAuthor()
RETURNS @BillActionSequenceCountByAuthorTable TABLE
(
	BillName NVARCHAR(MAX),
	Sequence NVARCHAR(MAX),
	author_FullName NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @BillActionSequenceCountByAuthorTable
	SELECT Bills.BillName, Actions.Sequence, authors.FullName, COUNT(*)
	FROM Bills
	INNER JOIN Actions ON Actions.BillId = Bills.Id
	INNER JOIN BillAuthors ON BillAuthors.BillId = Bills.Id
	INNER JOIN Legislators authors ON authors.Id = BillAuthors.LegislatorId
	GROUP BY Bills.Id, Bills.BillName, Actions.Sequence, authors.FullName

	RETURN
END

GO

CREATE FUNCTION BillActionCountByAuthor()
RETURNS @BillActionCountByAuthor TABLE
(
	BillName NVARCHAR(MAX),
	author_FullName NVARCHAR(MAX),
	action_count INT
)
BEGIN
	INSERT INTO @BillActionCountByAuthor
	SELECT Bills.BillName, authors.FullName, COUNT(*)
	FROM Bills
	INNER JOIN Actions ON Actions.BillId = Bills.Id
	INNER JOIN BillAuthors ON BillAuthors.BillId = Bills.Id
	INNER JOIN Legislators authors ON authors.Id = BillAuthors.LegislatorId
	GROUP BY Bills.Id, Bills.BillName, authors.FullName
	ORDER BY COUNT(*) DESC

	RETURN
END

GO

CREATE FUNCTION SubjectTypeAuthor()
RETURNS @SubjectTypeAuthorTable TABLE
(
	BillType NVARCHAR(MAX),
	author_FullName NVARCHAR(MAX),
	Subject NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectTypeAuthorTable
	SELECT Bills.Type, authors.FullName author_FullName, Subjects.Name Subject, COUNT(*)
	FROM Bills
	INNER JOIN BillAuthors ON BillAuthors.BillId = Bills.Id
	INNER JOIN Legislators authors ON authors.Id = BillAuthors.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = Bills.Id
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.SubjectId
	GROUP BY Bills.Type, authors.FullName, Subjects.Name
	
	RETURN
END

GO

CREATE FUNCTION SubjectChamberPartyAuthor()
RETURNS @SubjectChamberPartyAuthorTable TABLE
(
	Subject NVARCHAR(MAX),
	Chamber NVARCHAR(MAX),
	Party NVARCHAR(MAX),
	[count] INT
)
BEGIN
	INSERT INTO @SubjectChamberPartyAuthorTable
	SELECT Subjects.Name Subject, authors.PositionTitle Chamber, authors.Party, COUNT(*)
	FROM Bills
	INNER JOIN BillAuthors ON BillAuthors.BillId = Bills.Id
	INNER JOIN Legislators authors ON authors.Id = BillAuthors.LegislatorId
	INNER JOIN BillSubjects() ON BillSubjects.BillId = Bills.Id
	INNER JOIN Subjects ON Subjects.Id = BillSubjects.BillId
	GROUP BY Subjects.Name, authors.PositionTitle, authors.Party

	RETURN
END