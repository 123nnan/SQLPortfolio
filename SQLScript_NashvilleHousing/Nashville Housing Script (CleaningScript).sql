/* Cleaning Data in SQL Queries */
Select * From PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
Select SaleDate, Convert(date, SaleDate), SaleDateConverted From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET Saledate = Convert(date, SaleDate)
/* I dont know why it's not updating to the table */

	--Try Altering the table by adding a new column
Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(date, SaleDate)

-------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data
/* Checking if there are nulls to populate */

Select * From PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID	
	-- By checking some fields in PropertyAddress are same and ParcelID 
	--therefore if PropertyAddress is null but same ParcelID most likely the PropertyAddress is the same too

/* Using Self Join to populate the PropertyAddress */
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] != b.[UniqueID]
Where a.PropertyAddress is null

	--Updating the PropertyAddress
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] != b.[UniqueID]
Where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject..NashvilleHousing

/* We can seperate by using a delimeter to create new column */
--Using Substring
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, Len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255),
	PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress));


Select * From PortfolioProject..NashvilleHousing


/* Splitting again but using ParseName */
Select OwnerAddress From PortfolioProject..NashvilleHousing

	--By Parsename is striclty on "."
Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing


--Adding the new columns
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255),
	OwnerSplitCity Nvarchar(255),
	OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
	OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
	OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1);

Select * From PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by SoldAsVacant

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END

-------------------------------------------------------------------------------------------------------------

-- Removing Duplicates
/* Finding where there are duplicate values by using window functions */
Select *, 
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID
				 ) row_num
From PortfolioProject..NashvilleHousing

/* By creating CTE, we can use Where and Order By*/
With RowNumCTE as (
Select *, 
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID
				 ) row_num
From PortfolioProject..NashvilleHousing
)
Select * 
From RowNumCTE
Where row_num > 1
Order By ParcelID

--Deleting The duplicates with Row_num > 1
With RowNumCTE as (
Select *, 
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID
				 ) row_num
From PortfolioProject..NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1
/* 104 rows affected */
--Checking if there are still duplicate
With RowNumCTE as (
Select *, 
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID
				 ) row_num
From PortfolioProject..NashvilleHousing
)
Select * 
From RowNumCTE
Where row_num > 1
Order By ParcelID


-------------------------------------------------------------------------------------------------------------

-- Deleting Unused Columns
	--PropertyAddress, TaxDistrict, OwnerAddress, SaleDate
ALTER Table PortfolioProject..NashvilleHousing
DROP Column PropertyAddress, TaxDistrict, OwnerAddress, SaleDate

Select * 
From PortfolioProject..NashvilleHousing