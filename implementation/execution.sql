EXEC dbo.PreConvertDB @sourceDB=[2020_01], @targetDB=[2020_01_converted];
EXEC dbo.UpdateKeyTables @sourceDB=[2020_01_converted];
EXEC dbo.GenerateNormalizedTransactionTable @sourceDB=[2020_01_converted], @targetDB=[2020_01_normalized];
EXEC dbo.GenerateNormalizedTransactionTable @sourceDB=[2020_01_normalized], @targetDB=[tblMain];
EXEC dbo.UpdateDB @sourceDB=[2020_01], @targetDB=[tblMain];

EXEC dbo.PreConvertDB @sourceDB=[2020_08], @targetDB=[2020_08_converted];
EXEC dbo.UpdateKeyTables @sourceDB=[2020_08_converted];
EXEC dbo.GenerateNormalizedTransactionTable @sourceDB=[2020_08_converted], @targetDB=[2020_08_normalized];
EXEC dbo.GenerateNormalizedTransactionTable @sourceDB=[2020_08_normalized], @targetDB=[tblMain];
EXEC dbo.UpdateDB @sourceDB=[2020_08], @targetDB=[tblMain];

EXEC dbo.PreConvertDB @sourceDB=[2020_09], @targetDB=[2020_09_converted];
EXEC dbo.UpdateKeyTables @sourceDB=[2020_09_converted];
EXEC dbo.GenerateNormalizedTransactionTable @sourceDB=[2020_09_converted], @targetDB=[2020_09_normalized];
EXEC dbo.GenerateNormalizedTransactionTable @sourceDB=[2020_09_normalized], @targetDB=[tblMain];
EXEC dbo.UpdateDB @sourceDB=[2020_09], @targetDB=[tblMain];

EXEC dbo.PreConvertDB @sourceDB=[2020_10], @targetDB=[2020_10_converted];
EXEC dbo.UpdateKeyTables @sourceDB=[2020_10_converted];
EXEC dbo.GenerateNormalizedTransactionTable @sourceDB=[2020_10_converted], @targetDB=[2020_10_normalized];
EXEC dbo.GenerateNormalizedTransactionTable @sourceDB=[2020_10_normalized], @targetDB=[tblMain];
EXEC dbo.UpdateDB @sourceDB=[2020_10], @targetDB=[tblMain];

EXEC dbo.execQuery;