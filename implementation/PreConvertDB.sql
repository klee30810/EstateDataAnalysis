USE [myProjectDB_JB]
GO
/****** Object:  StoredProcedure [dbo].[PreConvertDB]    Script Date: 2020-11-27 오전 9:18:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[PreConvertDB]	-- 문자열을 각 속성에 맞게 변환시켜주는 저장프로시저.
	@sourceDB AS NVARCHAR(255),
	@targetDB AS NVARCHAR(255)
AS

DECLARE @yearmonth AS NVARCHAR(10);
DECLARE @qparam1 AS NVARCHAR(512);
DECLARE @sql AS NVARCHAR(512);

SET @sql = 'SELECT @yearmonth=[계약년월] FROM [' + @sourceDB + ']';
EXEC sp_executesql	@stmt=@sql,
					@params=N'@yearmonth AS NVARCHAR(6) OUTPUT',
					@yearmonth=@yearmonth OUTPUT;

IF (@yearmonth IS NOT NULL) AND (LEN(@yearmonth) = 6)
BEGIN
	--@destinationDB가 이미 있을 경우에는 delete
	IF OBJECT_ID(@targetDB, 'U') IS NOT NULL -- targetDB변수 내에 테이블(U=테이블)이 공백이 아니면
	BEGIN
		SET @sql = 'DROP TABLE [' + @targetDB + ']';
		EXEC sp_executesql @stmt=@sql;
	END

	SELECT @qparam1=QueryParam1 
	FROM dbo.tblDbMgtSpParameters 
	WHERE QueryName='PreConvertDB';

	SET @sql = 'SELECT ' + @qparam1 + 'INTO [' + @targetDB + '] FROM [' +@sourceDB + ']';
	EXEC sp_executesql @stmt=@sql;
END

ELSE
	PRINT 'sourceDB에 실거래가 원본 DB 이름을 입력해주세요!';