--*************************************************************************--
-- Title: Assignment06
-- Author: MKawano
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2023-02-20,MKawano,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_MKawano')
	 Begin 
	  Alter Database [Assignment06DB_MKawano] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_MKawano;
	 End
	Create Database Assignment06DB_MKawano;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_MKawano;

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
--		  3) Use SchemaBinding to protect the views from being orphaned!

--1.Categories
Create View dbo.vCategories
With Schemabinding
As Select CategoryID,CategoryName
From dbo.Categories;
Go

--2.Products
Create View dbo.vProducts
With Schemabinding
As Select ProductName, CategoryID, UnitPrice
From dbo.Products;
Go

 --3.Employee
Create View dbo.vEmployees
With Schemabinding
As Select EmployeeID,EmployeeFirstName,EmployeeLastName,ManagerID
From dbo.Employees;
go

--4.Inventories
Create View dbo.vInventories
With Schemabinding
As Select InventoryID,InventoryDate, EmployeeID, ProductID, [Count]
From dbo.Inventories;
go

Select * From dbo.vCategories;
Select * From dbo.vProducts;
Select * From dbo.vEmployees;
Select * From dbo.vInventories;
go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select on Categories to Public;
Grant Select on dbo.vCategories to Public;

Deny Select on Products to Public;
Grant Select on dbo.vProducts to Public;

Deny Select on Employees to Public;
Grant Select on dbo.vEmployees to Public;

Deny Select on Inventories to Public;
Grant Select on dbo.vInventories to Public;


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create View dbo.vProductsByCategories

As 
Select C.CategoryName, P.ProductName, P.UnitPrice
From Categories as C
Join Products as P
on C.CategoryID = P.CategoryID;
go

Select * From dbo.vProductsByCategories Order By CategoryName, ProductName;
go


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create View dbo.vInventoriesByProductsByDates

As
Select P.ProductName, I.InventoryDate, I.[Count]
From Products as P
Join Inventories as I
on P.ProductID = I.ProductID;
go

Select * from dbo.vInventoriesByProductsByDates Order By ProductName, InventoryDate, [Count]


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

Create View dbo.vInventoriesByEmployeesByDates
As
Select Distinct I.InventoryDate,[EmployeeName] = E.EmployeeFirstName+' '+E.EmployeeLastName
From Inventories as I
Join Employees as E
on I.EmployeeID = E.EmployeeID;
go

Select * from dbo.vInventoriesByEmployeesByDates Order By InventoryDate;
go


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create View dbo.vInventoriesByProductsByCategories
As
Select C.CategoryName, P.ProductName, I.InventoryDate,I.[COUNT]
From Categories as C
Join Products as P
on C.CategoryID = P.CategoryID
Join Inventories as I
on P.ProductID = I.ProductID;
go

Select * from dbo.vInventoriesByProductsByCategories
Order By CategoryName, ProductName, InventoryDate, [Count];
go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create View dbo.vInventoriesByProductsByEmployees
As
Select C.CategoryName
     , P.ProductName
	 , I.InventoryDate
	 , I.[Count]
	 , [EmployeeName] = E.EmployeeFirstName+' '+E.EmployeeLastName
From Categories as C
Join Products as P
on C.CategoryID = P.CategoryID
join Inventories as I
on P.ProductID = I.ProductID
join Employees as E
on I.EmployeeID = E.EmployeeID;
go

Select * From dbo.vInventoriesByProductsByEmployees
Order By InventoryDate, CategoryName, ProductName,EmployeeName;
go


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create View  dbo.vInventoriesForChaiAndChangByEmployees
As
Select C.CategoryName
     , P.ProductName 
	 , I.InventoryDate
	 , I.[Count]
	 , [EmployeeName] = E.EmployeeFirstName+' '+E.EmployeeLastName
From Categories as C
Join Products as P
on C.CategoryID = P.CategoryID
join Inventories as I
on P.ProductID = I.ProductID
join Employees as E
on I.EmployeeID = E.EmployeeID
Where P.ProductName in ('Chai', 'Chang');
go

Select * From dbo.vInventoriesForChaiAndChangByEmployees
go


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
Create View dbo.vEmployeesByManager
As
Select 
 [Manager] = M.EmployeeFirstName+' '+M.EmployeeLastName
,[Employee] = E.EmployeeFirstName+' '+E.EmployeeLastName
From Employees as E
join Employees as M
on E.ManagerID = M.EmployeeID;

Select * From dbo.vEmployeesByManager
Order By Manager, Employee;
go


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

Create View dbo.vInventoriesByProductsByCategoriesByEmployees
As
Select C.CategoryID,C.CategoryName
      ,P.ProductID,P.ProductName,P.UnitPrice
	  ,I.InventoryID,I.InventoryDate,[Count]
	  ,E.EmployeeID
      ,[Employee] = E.EmployeeFirstName+' '+E.EmployeeLastName
	  ,[Manager] = M.EmployeeFirstName+' '+M.EmployeeLastName
From Categories as C
Join Products as P
On C.CategoryID = P.CategoryID
join Inventories as I
On P.ProductID = I.ProductID
Join Employees as E
On I.EmployeeID = E.EmployeeID
join Employees as M
on E.ManagerID = M.EmployeeID;

Select * From dbo.vInventoriesByProductsByCategoriesByEmployees
Order By CategoryName, ProductID, InventoryID, Employee;

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/