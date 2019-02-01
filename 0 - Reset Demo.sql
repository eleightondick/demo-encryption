-- Delete created files from c:\temp before running this script

USE [master];
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE [name] = 'EncryptionDemo')
	DROP DATABASE [EncryptionDemo];
GO

IF EXISTS (SELECT 1 FROM sys.sql_logins WHERE [name] IN ('Dilbert', 'Wally'))
BEGIN
	DROP LOGIN [Dilbert];
	DROP LOGIN [Wally];
	DROP LOGIN [Asok];
END;
GO

CREATE DATABASE [EncryptionDemo];
GO

USE [EncryptionDemo];
GO

-- Setup for Demo 1
CREATE TABLE [Users]
	([ID] int IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	 [UserName] varchar(20) NULL,
	 [Password] varchar(20) NULL,
	 [PasswordHash] varbinary(64) NULL);
GO

-- Setup for Demo 2

USE [master];
GO

IF NOT EXISTS (SELECT 'x' FROM sys.symmetric_keys WHERE [name] = '##MS_DatabaseMasterKey##')
	CREATE MASTER KEY
		ENCRYPTION BY PASSWORD = 'Q6^9oGsX';
	
CREATE CERTIFICATE cerDemo2
	WITH SUBJECT = 'Demo certificate - Imported',
		 EXPIRY_DATE = '12/31/2017';
BACKUP CERTIFICATE cerDemo2
	TO FILE = 'c:\temp\demo2.cer'
	WITH PRIVATE KEY (FILE = 'c:\temp\demo2.pvk',
					  ENCRYPTION BY PASSWORD = 'Bg92@ERF');
DROP CERTIFICATE cerDemo2;
GO

USE [EncryptionDemo];
GO

CREATE TABLE PaymentInfo
	([OrderID] int IDENTITY(1059,1) NOT NULL PRIMARY KEY CLUSTERED,
	 [CCType] char(1) NOT NULL,
	 [AccountNum_Encrypted] varbinary(8000) NULL,
	 [AccountNum_Last4] int NULL);
GO

-- Setup for Demo 3
USE [master];
IF EXISTS (SELECT 1 FROM sys.certificates WHERE [name] = 'cerTDEDemo')
	DROP CERTIFICATE cerTDEDemo;
GO

-- Setup for Demo 4
USE [master];
IF EXISTS (SELECT 1 FROM sys.certificates WHERE [name] = 'cerBackupEncryption')
	DROP CERTIFICATE cerBackupEncryption;
CREATE CERTIFICATE cerBackupEncryption
	WITH SUBJECT = 'Demo certificate - Backup';
GO