USE [myProjectDB_JB]
GO
/****** Object:  StoredProcedure [dbo].[UpdateKeyTables]    Script Date: 2020-11-27 오전 9:19:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[UpdateKeyTables]
	@sourceDB AS NVARCHAR(255)
AS
	DECLARE @sql AS NVARCHAR(2048);

IF OBJECT_ID('tblDistricts', 'U') IS NULL
BEGIN
	IF OBJECT_ID('tblDistricts', 'U') IS NOT NULL 
		DROP TABLE tblDistricts;
	IF OBJECT_ID('tblComplex', 'U') IS NOT NULL 
		DROP TABLE dbo.tblComplex;
	IF OBJECT_ID('tblExclusive', 'U') IS NOT NULL 
		DROP TABLE dbo.tblExclusive;
	IF OBJECT_ID('tblStreets', 'U') IS NOT NULL 
		DROP TABLE dbo.tblStreets;

	CREATE TABLE tblDistricts 
	(id BIGINT IDENTITY(1,1) PRIMARY KEY, [시군구] NVARCHAR(255) NULL);

	CREATE TABLE tblComplex 
	(id BIGINT IDENTITY(1,1) PRIMARY KEY, [단지명] NVARCHAR(255) NULL);

	CREATE TABLE tblExclusive 
	(id BIGINT IDENTITY(1,1) PRIMARY KEY, [전용면적(㎡)] INT NULL);

	CREATE TABLE tblStreets 
	(id BIGINT IDENTITY(1,1) PRIMARY KEY, [도로명] NVARCHAR(255) NULL);

	SET @sql = 'select distinct [시군구] into #temp1 
				from [' + @sourceDB + '];';
	SET @sql = @sql + 'insert into dbo.tblDistricts ([시군구]) 
				select [시군구] 
				from #temp1; ';
	SET @sql = @sql + 'select distinct [단지명] into #temp2 
				from [' + @sourceDB	+ ']; ';
	SET @sql = @sql + 'insert into dbo.tblComplex ([단지명]) 
			select [단지명] 
			from #temp2; ';
	SET @sql = @sql + 'select distinct [전용면적(㎡)] into #temp3 
						from [' + 	@sourceDB + ']; ';
	SET @sql = @sql + 'insert into dbo.tblExclusive ([전용면적(㎡)]) 
					select [전용면적(㎡)] from #temp3; ';
	SET @sql = @sql + 'select distinct [도로명] into #temp4 
					from [' + @sourceDB	+ ']; ';
	SET @sql = @sql + 'insert into dbo.tblStreets ([도로명]) 
					select [도로명]	from #temp4; ';
	EXEC sp_executesql @stmt=@sql;
END

ELSE
BEGIN
	SET @sql = 'MERGE INTO dbo.tblDistricts AS TGT '
			+ 'USING [' + @sourceDB + '] AS SRC '
			+ 'ON ( TGT.[시군구] = SRC.[시군구]) '
			+ 'WHEN NOT MATCHED THEN '
			+ 'INSERT ([시군구]) '
			+ 'VALUES (SRC.[시군구]);';
	EXEC sp_executesql @stmt=@sql;

	SET @sql = 'MERGE INTO dbo.tblComplex AS TGT '
			+ 'USING [' + @sourceDB + '] AS SRC '
			+ 'ON ( TGT.[단지명] = SRC.[단지명]) '
			+ 'WHEN NOT MATCHED THEN '
			+ 'INSERT ([단지명]) '
			+ 'VALUES (SRC.[단지명]);';
	EXEC sp_executesql @stmt=@sql;

	SET @sql = 'MERGE INTO dbo.tblExclusive AS TGT '
			+ 'USING [' + @sourceDB + '] AS SRC '
			+ 'ON ( TGT.[전용면적(㎡)] = SRC.[전용면적(㎡)]) '
			+ 'WHEN NOT MATCHED THEN '
			+ 'INSERT ([전용면적(㎡)]) '
			+ 'VALUES (SRC.[전용면적(㎡)]);';
	EXEC sp_executesql @stmt=@sql;

	SET @sql = 'MERGE INTO dbo.tblStreets AS TGT '
			+ 'USING [' + @sourceDB + '] AS SRC '
			+ 'ON ( TGT.[도로명] = SRC.[도로명]) '
			+ 'WHEN NOT MATCHED THEN '
			+ 'INSERT ([도로명]) '
			+ 'VALUES ([도로명]);';
	EXEC sp_executesql @stmt=@sql;
END