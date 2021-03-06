USE [myProjectDB_JB]
GO
/****** Object:  StoredProcedure [dbo].[UpdateDB]    Script Date: 2020-11-27 오전 9:29:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[UpdateDB]
		@sourceDB NVARCHAR(255),
		@targetDB NVARCHAR(255)
as

DECLARE @sql AS NVARCHAR(255);

IF OBJECT_ID('dbo.tempDB1') IS NOT NULL DROP TABLE dbo.tempDB1;
IF OBJECT_ID('dbo.tempDB2') IS NOT NULL DROP TABLE dbo.tempDB2;
IF OBJECT_ID('dbo.tempDB3') IS NOT NULL DROP TABLE dbo.tempDB3;

set @sql = 'exec PreConvertDB @sourceDB=[' + @sourceDB + '], @targetDB=[tempDB1]';
EXEC sp_executesql @stmt=@sql;

set @sql = 'exec UpdateKeyTables @sourceDB=[tempDB1]';
EXEC sp_executesql @stmt=@sql;

IF OBJECT_ID(@targetDB) IS NOT NULL
BEGIN
	set @sql = 'exec GenerateNormalizedTransactionTable @sourceDB=[tempDB1], @targetDB=[tempDB2]';
	EXEC sp_executesql @stmt=@sql;

	set @sql = 'exec MergeNormalizedDB @sourceDB=[tempDB2], @targetDB=[' + @targetDB + ']';
	EXEC sp_executesql @stmt=@sql;
END

ELSE
BEGIN
	set @sql = 'exec GenerateNormalizedTransactionTable @sourceDB=[tempDB1],@targetDB=[' + @targetDB + ']';
	EXEC sp_executesql @stmt=@sql;
END

IF OBJECT_ID('dbo.tempDB1') IS NOT NULL 
	DROP TABLE dbo.tempDB1;
IF OBJECT_ID('dbo.tempDB2') IS NOT NULL 
	DROP TABLE dbo.tempDB2;
IF OBJECT_ID('dbo.tempDB3') IS NOT NULL 
	DROP TABLE dbo.tempDB3;