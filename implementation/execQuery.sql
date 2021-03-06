USE [myProjectDB_JB]
GO
/****** Object:  StoredProcedure [dbo].[execQuery]    Script Date: 2020-11-27 오전 9:56:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[execQuery]
as

	DECLARE @queryStartFlag AS NVARCHAR(255);
	DECLARE @queryName AS NVARCHAR(255);
	DECLARE @sourceDB AS NVARCHAR(255);
	DECLARE @sql AS NVARCHAR(255);

	select @queryStartFlag=[param3] 
	from dbo.tblTranQueryParameters 
	where [column]='query';

	select @queryName=[param1] 
	from dbo.tblTranQueryParameters 
	where [column]='query';

	select @sourceDB=[param2] 
	from dbo.tblTranQueryParameters 
	where [column]='query';

	if @queryStartFlag = '1' AND (@queryName + @sourceDB) is not null
	begin
		set @sql = 'EXEC ' + @queryName + ' @sourceDB=[' + @sourceDB + ']';
		exec sp_executesql @stmt=@sql;
	end