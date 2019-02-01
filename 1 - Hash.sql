USE [EncryptionDemo];
GO

CREATE PROCEDURE CreateUser (@username varchar(20), @password varchar(20))
AS BEGIN
	INSERT INTO [Users] (UserName, Password, PasswordHash)
		VALUES (@username, @password, 
				HASHBYTES('SHA2_512', @password));
END;
GO

EXECUTE CreateUser 'Boss', 'password';
GO

SELECT *
	FROM [Users];
GO

EXECUTE CreateUser 'CEO', 'password';
EXECUTE CreateUser 'Dogbert', 'IRuleEverything';
EXECUTE CreateUser 'Alice', 'fist';
GO

SELECT *
	FROM [Users];
GO

-- Each phrase generated a different hash
-- Same phrase, same hash
-- Rainbow tables

-- Mocked-up sample of a rainbow table
SELECT 'A' AS password, HASHBYTES('SHA2_512', 'A') AS password_hash
UNION ALL
SELECT 'B', HASHBYTES('SHA2_512', 'B')
UNION ALL
SELECT 'C', HASHBYTES('SHA2_512', 'C')
UNION ALL
SELECT 'D', HASHBYTES('SHA2_512', 'D')
UNION ALL
SELECT 'E', HASHBYTES('SHA2_512', 'E')
UNION ALL
SELECT 'F', HASHBYTES('SHA2_512', 'F')
UNION ALL
SELECT 'G', HASHBYTES('SHA2_512', 'G');
GO

-- Salting a hash
ALTER PROCEDURE CreateUser (@username varchar(20), @password varchar(20))
AS BEGIN
	INSERT INTO [Users] (UserName, Password)
		VALUES (@username, @password);

	UPDATE [Users]
		SET PasswordHash = 
			HASHBYTES('SHA2_512', 
					  @password + CAST([ID] AS varchar))
		WHERE UserName = @username;
END;
GO

EXECUTE CreateUser 'Bob', 'password';
EXECUTE CreateUser 'Garbageman', 'password';

SELECT *
	FROM [Users]
	WHERE password = 'password';
GO

-- "Retrieving" a password
-- Never reveal too much about what is/is not correct when checking a login!
CREATE FUNCTION IsValidPassword(@username varchar(20), @password varchar(20))
	RETURNS bit
AS BEGIN
	RETURN ISNULL((SELECT 1 FROM [Users] 
					WHERE UserName = @username AND [PasswordHash] = HASHBYTES('SHA2_512', @password)), 0);
END;
GO

IF dbo.IsValidPassword('Dogbert', 'IRuleEverything') = 1
	PRINT 'Correct';
ELSE
	PRINT 'Incorrect';
GO

IF dbo.IsValidPassword('Alice', 'foo') = 1
	PRINT 'Correct';
ELSE
	PRINT 'Incorrect';
GO

-- Using PWDCOMPARE to check SQL Server logins
CREATE LOGIN [Dilbert] WITH PASSWORD = 'engineer', CHECK_POLICY = OFF;
CREATE LOGIN [Wally] WITH PASSWORD = '', CHECK_POLICY = OFF;
CREATE LOGIN [Asok] WITH PASSWORD = 'password', CHECK_POLICY = OFF;
GO

SELECT [name]
	FROM sys.sql_logins
	WHERE PWDCOMPARE('', password_hash) = 1;
SELECT [name]
	FROM sys.sql_logins
	WHERE PWDCOMPARE('password', password_hash) = 1;
GO