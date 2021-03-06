USE [myProjectDB_JB]
GO
/****** Object:  StoredProcedure [dbo].[MergeNormalizedDB]    Script Date: 2020-11-27 오전 9:27:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[MergeNormalizedDB] 
	@sourceDB AS NVARCHAR(255),
	@targetDB AS NVARCHAR(255)

AS
BEGIN
	DECLARE @sql AS NVARCHAR(1024);
	DECLARE @qparam1 AS NVARCHAR(512);
	DECLARE @qparam2 AS NVARCHAR(512);
	DECLARE @qparam3 AS NVARCHAR(512);

	SELECT @qparam1=QueryParam1, @qparam2=QueryParam2, @qparam3=QueryParam3
	FROM dbo.tblDbMgtSpParameters 
	WHERE QueryName='MergeNormalizedDB';

	SET @sql = 'MERGE INTO [' + @targetDB + '] AS TGT '
				+ 'USING [' + @sourceDB + '] AS SRC '
				+ 'ON (' + @qparam1 + ') '
				+ 'WHEN NOT MATCHED THEN '
				+ 'INSERT (' + @qparam2 + ') '
				+ 'VALUES (' + @qparam3 + ');';
	EXEC sp_executesql @stmt=@sql;
END