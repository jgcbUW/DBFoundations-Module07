--*************************************************************************--
-- Title: Assignment07
-- Author: JBauer
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,JBauer,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_JBauer')
	 Begin 
	  Alter Database [Assignment07DB_JBauer] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_JBauer;
	 End
	Create Database Assignment07DB_JBauer;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_JBauer;

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
,[UnitPrice] [money] NOT NULL
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
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
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
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

Select 
	ProductName, 
	[UnitPrice] = Concat('$', UnitPrice)
From 
	vProducts
	Order BY
		ProductName;
go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

Select
	CategoryName,
	ProductName,
	[UnitPrice] = Concat('$', UnitPrice)
From vCategories
	Join vProducts on 
		vCategories.CategoryID = vProducts.CategoryID
	Order BY
		CategoryName, ProductName;
go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

Select 
	ProductName,
	[Date] = Concat(Datename(mm, InventoryDate), ', ', YEAR(InventoryDate)), 
	[Count]
From
	vProducts
	Join vInventories on 
		vProducts.ProductID = vInventories.ProductID
	Order by 
		1, InventoryDate;
go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

Create or Alter -- Drop 
View vProductInventories
As
	Select top 1000000
		ProductName,
		[Date] = CONCAT(Datename(mm, InventoryDate), ', ', Year(InventoryDate)),
		[Count]
	From
		vProducts
		Join vInventories on
			vProducts.ProductID = vInventories.ProductID
	Order by 
		1, InventoryDate;
go

Select * From vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

Create or Alter -- Drop 
View vCategoryInventories
As
	Select Top 1000000
		CategoryName, 
		Concat(DateName(mm, InventoryDate), ', ', Year(InventoryDate)) as [Date], 
		Sum([Count]) as Total
	From
		vCategories
		Join vProducts on
			vCategories.CategoryID = vProducts.CategoryID
		Join vInventories on
			vProducts.ProductID = vInventories.ProductID
	Group By CategoryName, InventoryDate
	Order By 1, InventoryDate;
go

Select * From vCategoryInventories;
go


-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

/*	**** WORK *****
Select Top 10000000
		P.ProductName,
		[Date] = Concat(DateName(mm, I.InventoryDate), ', ', Year(I.InventoryDate)),
		[InventoryCount] = IsNull(I.Count, 0),
		[Last Month] = (Select PrevMonth.Count From I Where Month(I.InventoryDate) = Month(PrevMonth.InventoryDate))
	From vProducts as P
	Join vInventories as I
		on P.ProductID = I.ProductID
	Join vInventories as PrevMonth
		on 

	Group by 
		ProductName, InventoryDate
	Order By 
		1, InventoryDate


Select I1.ProductID, I1.[Count], I1.InventoryDate, [PreviousMonth] = IsNull(I2.[Count],0), I2.InventoryDate From vInventories as I1
	Left Join vInventories as I2
		on I1.ProductID = I2.ProductID AND Month(I1.InventoryDate)-1= Month(I2.InventoryDate)
	Order By 1, 3;
go

Select I1.ProductID, I1.[Count], I1.InventoryDate, [PreviousMonth] = IsNull(I2.[Count],0), I2.InventoryDate From vInventories as I1
	Left Join vInventories as I2
	on I1.ProductID = I2.ProductID AND Month(I1.InventoryDate)-1= Month(I2.InventoryDate)
	Order By 1, 3;
go

Create or Alter View vProductInventoriesWithPreviousMonthCounts
As
	Select Top 10000000
		ProdInv.ProductName,
		ProdInv.Date,
		ProdInv.Count,
		[Last Month] = IsNull(PrevMonth.Count, 0)
	From vProductInventories
		as ProdInv
	Left Join vProductInventories
		as PrevMonth
		On Month(Convert(Date, ProdInv.Date))-1 = Month(PrevMonth.InventoryDate)
	Group by 
		ProductName, [Date]
	Order By 
		1, [ProdInv.Date]
;
go
;    *** END WORK*** */


/* ***** SOLUTION WITH OUTER JOIN *****
GO
Create or Alter View vProductInventoriesWithPreviousMonthCounts
As
	Select TOP 1000000 
		PI1.ProductName, 
		PI1.[Date], 
		PI1.Count, 
		[Previous Month Count] = IsNull(PI2.Count,0)
	From vProductInventories as PI1
		Left Join vProductInventories as PI2
			on PI1.ProductName = PI2.ProductName 
			AND Month(PI1.Date) - 1 = Month(PI2.Date)
	Order By 1, Month(PI1.[Date]);
go*/

-- ***** SOLUTION WITH FUNCTIONS ONLY *****
GO
Create or Alter -- Drop 
View vProductInventoriesWithPreviousMonthCounts
As
	Select TOP 1000000 
		P.ProductName, 
		P.[Date], 
		P.Count, 
		[PreviousMonthCount] = IIF(Month(P.Date) = 1, 0, Lag(P.count) Over(Order by P.[ProductName]))
	From vProductInventories as P
	--Order By 1, Month(P.[Date]);
;
go

Select * From vProductInventoriesWithPreviousMonthCounts;
go


-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

Create OR Alter -- Drop 
View vProductInventoriesWithPreviousMonthCountsWithKPIs
As
	Select Top 10000000
		P.ProductName,
		P.Date,
		P.Count,
		P.PreviousMonthCount,
		[CountVsPreviousCountKPI] = Case
			When P.PreviousMonthCount > P.Count Then -1
			When P.PreviousMonthCount = P.Count Then 0
			When P.PreviousMonthCount < P.Count Then 1
			End
	From vProductInventoriesWithPreviousMonthCounts as P
	--Order By 1, Month(P.Date);
;
go

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

Create or Alter --Drop
Function fProductInventoriesWithPreviousMonthCountsWithKPIs (
	@KPI int
)
Returns Table
As
	Return (
	Select Top 10000000
		P.ProductName,
		P.Date,
		P.Count,
		P.PreviousMonthCount,
		P.CountVsPreviousCountKPI	
	From vProductInventoriesWithPreviousMonthCountsWithKPIs as P
	Where P.CountVsPreviousCountKPI = @KPI
	-- Order By 1, Month(P.Date)
	)
;
go

/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go

/***************************************************************************************/



