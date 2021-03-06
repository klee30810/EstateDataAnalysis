USE [myProjectDB_JB]
GO
/****** Object:  StoredProcedure [dbo].[GenerateNormalizedTransactionTable]    Script Date: 2020-11-27 오전 9:22:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[GenerateNormalizedTransactionTable]
	@sourceDB AS NVARCHAR(255),
	@targetDB AS NVARCHAR(255) 
AS 

DECLARE @idc AS NVARCHAR(50);

SELECT @idc=COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME=@sourceDB AND COLUMN_NAME='id';

IF @idc IS NULL
BEGIN
	DECLARE @sql AS NVARCHAR(2048);

	SET @sql = 'IF OBJECT_ID(''' + @targetDB + ''') IS NOT NULL '
			+ 'DROP TABLE [' + @targetDB + ']';
	EXEC sp_executesql @stmt=@sql;

	SET @sql = 'CREATE TABLE [' + @targetDB + '] (
				[시군구] [nvarchar](255) NULL,
				[번지] [nvarchar](255) NULL,
				[본번] [nvarchar](255) NULL,
				[부번] [nvarchar](255) NULL,
				[단지명] [nvarchar](255) NULL,
				[전용면적(㎡)] [int] NULL,
				[계약년월일] [date] NULL,
				[거래금액(만원)] [int] NULL,
				[층] [int] NULL,
				[건축년도] [int] NULL,
				[도로명] [nvarchar](255) NULL,
				[id] [bigint] IDENTITY(1,1) PRIMARY KEY,
				[districtId] [bigint] NULL,
				[complexId] [bigint] NULL,
				[exclusiveId] [bigint] NULL,
				[streetId] [bigint] NULL
			)';
		EXEC sp_executesql @stmt=@sql;

		SET @sql = 'INSERT INTO [' + @targetDB + '] ( 
		[시군구],[번지],[본번],[부번],[단지명],[전용면적(㎡)],
		[계약년월일],[거래금액(만원)],[층],[건축년도],[도로명] ) ' 
		+ ' SELECT [시군구],[번지],[본번],[부번],[단지명],[전용면적(㎡)],
		[계약년월일],[거래금액(만원)],[층],[건축년도],[도로명] 
		FROM [' + @sourceDB + '] ';
		EXEC sp_executesql @stmt=@sql;

		DECLARE @pktName AS NVARCHAR(255);
		DECLARE @fkdName AS NVARCHAR(255), @fkcName AS NVARCHAR(255), 
				@fkeName AS NVARCHAR(255), @fksName AS NVARCHAR(255);
		DECLARE @fkd AS NVARCHAR(255), @fkc AS NVARCHAR(255), @fke AS NVARCHAR(255), @fks AS NVARCHAR(255);

		SET @pktName='PK_'+@targetDB+'Transactions';
		SET @fkdName='FK_'+@targetDB+'Districts';
		SET @fkcName='FK_'+@targetDB+'Complex';
		SET @fkeName='FK_'+@targetDB+'Exclusive';
		SET @fksName='FK_'+@targetDB+'Streets';

		SELECT @fkd=CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
		WHERE TABLE_NAME=@targetDB AND CONSTRAINT_NAME=@fkdName;

		SELECT @fkc=CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
		WHERE TABLE_NAME=@targetDB AND CONSTRAINT_NAME=@fkcName;

		SELECT @fke=CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
		WHERE TABLE_NAME=@targetDB AND CONSTRAINT_NAME=@fkeName;

		SELECT @fks=CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
		WHERE TABLE_NAME=@targetDB AND CONSTRAINT_NAME=@fksName;

		SET @sql = ' 
			IF @fkd IS NULL ALTER TABLE [' + @targetDB + '] 
			ADD CONSTRAINT ['+@fkdName+'] FOREIGN KEY (districtId) 
			REFERENCES dbo.tblDistricts(id);

			IF @fkc IS NULL ALTER TABLE [' + @targetDB + '] 
			ADD CONSTRAINT ['+@fkcName+'] FOREIGN KEY (complexId) 
			REFERENCES dbo.tblComplex(id);

			IF @fke IS NULL ALTER TABLE [' + @targetDB + '] 
			ADD CONSTRAINT ['+@fkeName+'] FOREIGN KEY (exclusiveId) 
			REFERENCES dbo.tblExclusive(id);

			IF @fks IS NULL ALTER TABLE [' + @targetDB + '] 
			ADD CONSTRAINT ['+@fksName+'] FOREIGN KEY (streetId) 
			REFERENCES dbo.tblStreets(id);

		UPDATE A 
		SET A.districtId=B.id, 
			A.complexId=C.id, 
			A.exclusiveId=D.id,
			A.streetId=E.id
		FROM [' + @targetDB + '] AS A
			JOIN dbo.tblDistricts AS B ON A.[시군구]=B.[시군구]
			JOIN dbo.tblComplex AS C ON A.[단지명]=C.[단지명]
			JOIN dbo.tblExclusive AS D ON A.[전용면적(㎡)]=D.[전용면적(㎡)]
			JOIN dbo.tblStreets AS E ON A.[도로명]=E.[도로명];
		';

		EXEC sp_executesql @stmt=@sql,
							@params=N'@fkc AS NVARCHAR(50), @fkd AS NVARCHAR(50), @fke AS NVARCHAR(50), @fks AS NVARCHAR(50)',
							@fkc=@fkc, @fkd=@fkd, @fke=@fke, @fks=@fks;
		SET @sql = 'ALTER TABLE [' + @targetDB + '] 
					DROP COLUMN [시군구], [단지명], [전용면적(㎡)], [도로명] ';
		EXEC sp_executesql @stmt=@sql;
	END