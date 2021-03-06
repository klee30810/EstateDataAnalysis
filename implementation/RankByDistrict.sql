USE [myProjectDB_JB]
GO
/****** Object:  StoredProcedure [dbo].[RankByDistrict]    Script Date: 2020-11-27 오전 9:54:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER proc [dbo].[RankByDistrict]
@sourceDB AS NVARCHAR(255)
AS

declare @locationParam1 as nvarchar(50);
declare @locationParam2 as nvarchar(50);
declare @locationParam3 as nvarchar(50);
declare @locationPredicate as nvarchar(512);
declare @complex as nvarchar(50);
declare @byComplex as bit;
declare @areaMin as real;
declare @areaMax as real;
declare @floorMin as int;
declare @floorMax as int;
declare @priceMin as real;
declare @priceMax as real;
declare @tranDateMin as date;
declare @tranDateMax as date;
declare @tranDatePeriod as nvarchar(50);
declare @recentPeriod as int;

declare @sql as nvarchar(1024);

select @locationParam1=[param1] 
from dbo.tblTranQueryParameters 
where [column] ='시군구';

select @locationParam2=[param2] 
from dbo.tblTranQueryParameters 
where [column] ='시군구';

select @locationParam3=[param3] 
from dbo.tblTranQueryParameters 
where [column] ='시군구';

select @complex=[param1] 
from dbo.tblTranQueryParameters 
where [column]='단지명';

select @byComplex=cast([param1] as bit) 
from dbo.tblTranQueryParameters 
where [column]='단지별';

select @areaMin=cast(ISNULL([param1],'50') as real) 
from dbo.tblTranQueryParameters 
where [column]='전용면적(㎡)';

select @areaMax=cast(ISNULL([param2],'150') as real) 
from dbo.tblTranQueryParameters 
where [column]='전용면적(㎡)';

select @floorMin=cast(ISNULL([param1],'3') as int) 
from dbo.tblTranQueryParameters 
where [column]='층수';

select @floorMax=cast(ISNULL([param2],'25') as int) 
from dbo.tblTranQueryParameters 
where [column]='층수';

select @priceMin=cast(ISNULL([param1],'30000') as real) 
from dbo.tblTranQueryParameters 
where [column]='거래금액(만원)';

select @priceMax=cast(ISNULL([param2],'1000000') as real) 
from dbo.tblTranQueryParameters 
where [column]='거래금액(만원)';

select @tranDatePeriod=[param3] 
from dbo.tblTranQueryParameters 
where [column] ='계약년월일';

if @tranDatePeriod is null
begin
	select @tranDateMin=cast(ISNULL([param1],DATEADD(month,-6,GETDATE())) as date)
	from dbo.tblTranQueryParameters 
	where [column]='계약년월일';

	select @tranDateMax=cast(ISNULL([param2],GETDATE()) as date) 
	from dbo.tblTranQueryParameters 
	where [column]='계약년월일';
end

else
begin
	select @tranDateMin=DATEADD(month,-1*CAST(@tranDatePeriod AS int),GETDATE());
	select @tranDateMax=GETDATE();
end

set @recentPeriod=DATEDIFF(month, @tranDateMin, @tranDateMax);

if (@locationParam1 IS NOT NULL OR @locationParam2 IS NOT NULL OR @locationParam3 IS NOT NULL)
begin
	set @locationPredicate= ' (D.[시군구] LIKE N''%';
	if @locationParam1 is not null 
		set @locationPredicate= @locationPredicate+RTRIM(LTRIM(@locationParam1)) + '%'' ';

	if @locationParam2 is not null 
		set @locationPredicate= @locationPredicate+'AND D.[시군구] LIKE N''%' + RTRIM(LTRIM(@locationParam2)) + '%'' ';
	if @locationParam3 is not null 
		set @locationPredicate= @locationPredicate+'AND D.[시군구] LIKE N''%' + RTRIM(LTRIM(@locationParam3)) + '%''';
	set @locationPredicate= @locationPredicate+ ') ';

	set @sql =
	'select D.[시군구], COUNT(*) AS [거래량], AVG(T.[거래금액(만원)]) AS [최근 '+ CAST(@recentPeriod AS nvarchar(10)) + '개월 평균거래가격(만원)]
	from ' + dbo.targetJoinQuery(@sourceDB) 
	+ 
	'where' + @locationPredicate 
	+ 
	'AND ((T.[계약년월일] >= @tranDateMin) AND (T.[계약년월일] <=@tranDateMax))
	AND ((T.[층] >= @floorMin) AND (T.[층] <= @floorMax))
	AND ((E.[전용면적(㎡)] >= @areaMin) AND (E.[전용면적(㎡)] <= @areaMax))
	group by D.[시군구]
	having ((AVG(T.[거래금액(만원)]) >= @priceMin) AND (AVG(T.[거래금액(만원)])<= @priceMax))
	order by AVG(T.[거래금액(만원)]) DESC, D.[시군구]';

	EXEC sp_executesql @stmt=@sql,
						@params=N'@tranDateMin as date, @tranDateMax as date,
								@floorMin as int, @floorMax as int,
								@areaMin as real, @areaMax as real,
								@priceMin as real, @priceMax as real',
						@tranDateMin=@tranDateMin, @tranDateMax=@tranDateMax,@floorMin=@floorMin, @floorMax=@floorMax,
						@areaMin=@areaMin, @areaMax=@areaMax,
						@priceMin=@priceMin, @priceMax=@priceMax;
end
else
	print 'dbo.TranQueryParameters 테이블에서 시군구 param1, param2, param3 값들과 단지명 param1 값이 모두 NULL로 되어 있습니다.'