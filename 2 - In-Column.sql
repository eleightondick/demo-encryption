USE [EncryptionDemo];
GO

CREATE MASTER KEY
	ENCRYPTION BY PASSWORD = 'kk+c23hQ';
GO

BACKUP MASTER KEY
	TO FILE = 'c:\temp\encryptiondemo_mk.cer'
	ENCRYPTION BY PASSWORD = '6TkpXo^2';
GO

CREATE CERTIFICATE cerDemo1
	WITH SUBJECT = 'Demo certificate - Created by user',
		 EXPIRY_DATE = '12/31/2017';
GO

CREATE SYMMETRIC KEY skPaymentData
	WITH ALGORITHM = AES_256
	ENCRYPTION BY CERTIFICATE cerDemo1;
GO

CREATE PROCEDURE SaveEncryptedPaymentData (@cctype char(1), @accountnum char(16))
AS BEGIN
	OPEN SYMMETRIC KEY skPaymentData
		DECRYPTION BY CERTIFICATE cerDemo1;

	INSERT INTO PaymentInfo (CCType, AccountNum_Encrypted, AccountNum_Last4)
		VALUES 
		(@cctype, 
		 ENCRYPTBYKEY(KEY_GUID('skPaymentData'), @accountnum),
		 RIGHT(RTRIM(@accountnum), 4));

	CLOSE SYMMETRIC KEY skPaymentData;
END;
GO

EXECUTE SaveEncryptedPaymentData 'V', '4539721299574585';
EXECUTE SaveEncryptedPaymentData 'M', '5381116007581871';
EXECUTE SaveEncryptedPaymentData 'M', '5578594556268863';
EXECUTE SaveEncryptedPaymentData 'V', '4715299778574315';
EXECUTE SaveEncryptedPaymentData 'A', '376005240846480';
EXECUTE SaveEncryptedPaymentData 'D', '6011683972304130';
GO

SELECT *
	FROM PaymentInfo;
GO

OPEN SYMMETRIC KEY skPaymentData
	DECRYPTION BY CERTIFICATE cerDemo1;
SELECT *, CONVERT(char(16), DECRYPTBYKEY(AccountNum_Encrypted))
	FROM PaymentInfo;
CLOSE SYMMETRIC KEY skPaymentData;
GO

-- Create a certificate from a file
CREATE CERTIFICATE cerDemo2
	FROM FILE = 'c:\temp\demo2.cer'
	WITH PRIVATE KEY (FILE = 'c:\temp\demo2.pvk',
					  DECRYPTION BY PASSWORD = 'Bg92@ERF');
GO

-- Simluate a restore to a different server
BACKUP DATABASE EncryptionDemo
	TO DISK = 'c:\temp\encryptiondemo-2.bak';

USE [master];
ALTER SERVICE MASTER KEY
	REGENERATE;
RESTORE DATABASE EncryptionDemo
	FROM DISK = 'c:\temp\encryptiondemo-2.bak'
	WITH REPLACE;
USE [EncryptionDemo];
ALTER MASTER KEY
	FORCE REGENERATE WITH ENCRYPTION BY PASSWORD = 'i9b7hr[F';
GO

OPEN SYMMETRIC KEY skPaymentData
	DECRYPTION BY CERTIFICATE cerDemo1;
SELECT *, CONVERT(char(16), DECRYPTBYKEY(AccountNum_Encrypted))
	FROM PaymentInfo;
CLOSE SYMMETRIC KEY skPaymentData;
GO

RESTORE MASTER KEY
	FROM FILE = 'c:\temp\encryptiondemo_mk.cer'
	DECRYPTION BY PASSWORD = '6TkpXo^2'
	ENCRYPTION BY PASSWORD = 'y6YD9R^N'
	FORCE;
GO

OPEN SYMMETRIC KEY skPaymentData
	DECRYPTION BY CERTIFICATE cerDemo1;
SELECT *, CONVERT(char(16), DECRYPTBYKEY(AccountNum_Encrypted))
	FROM PaymentInfo;
CLOSE SYMMETRIC KEY skPaymentData;
GO
