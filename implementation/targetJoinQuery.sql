USE [myProjectDB_JB]
GO
/****** Object:  UserDefinedFunction [dbo].[targetJoinQuery]    Script Date: 2020-11-27 오전 9:35:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[targetJoinQuery](@targetDB AS NVARCHAR(255))
RETURNS NVARCHAR(2048)
AS
BEGIN
	DECLARE  @query AS NVARCHAR(2048);
	SET @query = ' [' + @targetDB + '] AS T
				JOIN dbo.tblDistricts AS D ON T.districtId=D.id
				JOIN dbo.tblComplex AS C ON T.complexId=C.id
				JOIN dbo.tblExclusive AS E ON T.exclusiveId=E.id
				JOIN dbo.tblStreets AS S ON T.streetId=S.id
				';
	RETURN @query;
END