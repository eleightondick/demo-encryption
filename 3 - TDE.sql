USE [master];
GO

IF NOT EXISTS (SELECT 'x' FROM sys.symmetric_keys WHERE [name] = '##MS_DatabaseMasterKey##')
	CREATE MASTER KEY
		ENCRYPTION BY PASSWORD = '9bzci^x9';
GO

CREATE CERTIFICATE cerTDEDemo
	WITH SUBJECT = 'TDE Demo Certificate';
GO

BACKUP CERTIFICATE cerTDEDemo
	TO FILE = 'c:\temp\cerTDEDemo.cer'
	WITH PRIVATE KEY (FILE = 'c:\temp\cerTDEDemo.pvk',
					  ENCRYPTION BY PASSWORD = 'vUAjQ46^');
GO

USE [EncryptionDemo];
GO

CREATE DATABASE ENCRYPTION KEY
	WITH ALGORITHM = AES_256
	ENCRYPTION BY SERVER CERTIFICATE cerTDEDemo;
GO

-- Run the next three batches together
SELECT DB_NAME(database_id), *
	FROM sys.dm_database_encryption_keys;
GO

ALTER DATABASE [EncryptionDemo]
	SET ENCRYPTION ON;
GO

SELECT DB_NAME(database_id), *
	FROM sys.dm_database_encryption_keys;
WAITFOR DELAY '00:00:00.1';
GO 10
