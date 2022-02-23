--*************************************************************************--
-- Title: Assignment06
-- Author: Andrew Palmer
-- Desc: This file demonstrates how to use Views
-- Change Log: 2022-02-21, APalmer, Update
-- 2022-02-20,Andrew Palmer,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_AndrewPalmer')
	 Begin 
	  Alter Database [Assignment06DB_AndrewPalmer] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_AndrewPalmer;
	 End
	Create Database Assignment06DB_AndrewPalmer;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_AndrewPalmer;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		    3) Use SchemaBinding to protect the views from being orphaned!

GO
CREATE VIEW vCategories
 WITH SCHEMABINDING
  AS
   SELECT
    CategoryID,
	  CategoryName
   FROM dbo.Categories
GO
CREATE VIEW vProducts
 WITH SCHEMABINDING
  AS 
   SELECT
    ProductID,
    ProductName,
    CategoryID,
    UnitPrice
   FROM dbo.Products
GO
CREATE VIEW vEmployees
 WITH SCHEMABINDING
  AS 
   SELECT
    EmployeeID,
    EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName, 
    ManagerID
   FROM dbo.Employees
GO
CREATE VIEW vInventories
 WITH SCHEMABINDING
  AS 
   SELECT
    InventoryID,
    InventoryDate,
    EmployeeID,
    ProductID,
    [Count]
   FROM dbo.Inventories
GO
SELECT * FROM vCategories
GO
SELECT * FROM vProducts
GO
SELECT * FROM vEmployees
GO
SELECT * FROM vInventories
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

DENY SELECT ON Categories TO PUBLIC
GO
DENY SELECT ON Emplopyees TO PUBLIC 
GO
DENY SELECT ON Products TO PUBLIC
GO
Deny SELECT ON Inventories TO PUBLIC
GO
GRANT SELECT ON vCategories TO PUBLIC
GO
GRANT SELECT on vEmployees TO PUBLIC
GO
GRANT SELECT ON vProducts TO PUBLIC
GO
GRANT SELECT ON vInventories TO PUBLIC
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

GO
 CREATE VIEW vCategoryNamePrice 
  AS 
   SELECT TOP 100000
    c.CategoryName, 
    p.ProductName, 
    p.UnitPrice
   FROM dbo.Categories AS c 
    JOIN dbo.Products AS p 
     ON c.CategoryID = p.ProductID 
      ORDER BY CategoryName, ProductName
GO
SELECT * FROM vCategoryNamePrice 
GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

GO
CREATE VIEW vPruductsAndInventoryCountsByDate 
 AS
  SELECT TOP 100000
   p.ProductName, 
   i.InventoryDate, 
   i.[COUNT]
  FROM Products as p
   INNER JOIN Inventories as i
    ON p.ProductID = i.ProductID
     ORDER BY ProductName, InventoryDate, [Count]
GO 
SELECT * FROM vPruductsAndInventoryCountsByDate
GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

GO
CREATE VIEW vInventoryDatesbyEmployeeCount
 AS 
  SELECT TOP 10000
   i.InventoryDate, 
   e.EmployeeFirstName + ' ' + EmployeeLastName as Employee
  FROM Inventories AS i 
   INNER JOIN Employees AS e 
    ON i.EmployeeID = e.EmployeeID
GO
SELECT * FROM vInventoryDatesbyEmployeeCount
GO

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

GO
CREATE VIEW vCategoriesProductsDateandCount
 AS
  SELECT TOP 10000
   c.CategoryName, 
   p.ProductName, 
   i.InventoryDate, 
   i.[Count]
  FROM Categories AS c 
   INNER JOIN Products AS p 
    ON c.CategoryID = productID 
   INNER JOIN inventories AS i 
    ON p.productid = i.productid
     ORDER BY CategoryName, ProductName, InventoryDate, [Count]
GO
SELECT * FROM vCategoriesProductsDateandCount
GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

GO
CREATE VIEW vCategoriesProductsDateandCountByEmployee
 AS
  SELECT TOP 100 
   c.CategoryName, 
   p.ProductName, 
   i.InventoryDate, 
   i.[COUNT], 
   e.EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName 
  FROM Inventories AS i 
   INNER JOIN Employees AS e 
    ON i.EmployeeID = e.EmployeeID  
   INNER JOIN Products AS p 
    ON i.productid = p.productid 
   INNER JOIN Categories AS c 
    ON p.CategoryID = c.CategoryID
     ORDER BY Inventorydate, CategoryName, ProductName, EmployeeName
GO
SELECT * FROM vCategoriesProductsDateandCountByEmployee
GO

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

GO
 CREATE VIEW vChaiChangeEmployeeCountByDate
  AS
   SELECT 
    c.CategoryName, 
    p.ProductName, 
    i.InventoryDate, 
    i.[Count], 
    e.EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName 
   FROM Inventories AS i 
    INNER JOIN Employees AS e 
     ON i.EmployeeID = e.EmployeeID
    INNER JOIN Products AS p 
     ON I.ProductID = P.ProductID
    INNER JOIN Categories AS c 
     ON p.CategoryID = c.CategoryID
     WHERE i.ProductID IN (SELECT ProductID FROM Products 
	 WHERE ProductName IN ('Chai', 'Chang'))
GO
SELECT * from vChaiChangeEmployeeCountByDate
GO

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

GO
 CREATE VIEW vEmployeesandtheirManagers
  AS
   SELECT TOP 100
    m.EmployeeFirstName + ' ' + m.EmployeeLastName AS Manager,
    e.EmployeeFirstName + ' ' + e.EmployeeLastName AS Employee
   FROM Employees AS e 
    INNER JOIN Employees AS m 
     ON e.ManagerID = m.EmployeeID
      ORDER BY Manager
GO
SELECT * FROM vEmployeesandtheirManagers
GO

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

GO
CREATE VIEW vAllBasicViewData
 AS
  SELECT
   c.CategoryID,
   c.CategoryName, 
   p.ProductID, 
   p.ProductName,
   p.UnitPrice, 
   i.InventoryID, 
   i.InventoryDate,
   i.[Count],
   e.EmployeeID,
   e.EmployeeFirstName + ' ' + e.EmployeeLastName AS EmployeeName,
   e.ManagerID,
   m.EmployeeFirstName + ' ' + m.EmployeeLastName AS ManagerName
  FROM Categories AS c 
   JOIN Products AS p 
    ON c.CategoryID = p.CategoryID
   JOIN Inventories AS i  
    ON p.ProductID = i.ProductID
   JOIN Employees AS e
    ON i.EmployeeID = e.EmployeeID
   JOIN Employees AS m 
    ON e.ManagerID = m.EmployeeID
GO
SELECT * FROM vAllBasicViewData;
GO

/***************************************************************************************/