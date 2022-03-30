

Select *
from DataCleaningProject.dbo.NashvilleHousing

-- Standarize Date Format
Select SaleDateConverted, CONVERT(Date,SaleDate) 
from DataCleaningProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------

--- Populate Property Address data
Select *
from DataCleaningProject.dbo.NashvilleHousing
--where PropertyAddress is null 
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaningProject.dbo.NashvilleHousing a
JOIN DataCleaningProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaningProject.dbo.NashvilleHousing a
JOIN DataCleaningProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

select PropertyAddress from DataCleaningProject.dbo.NashvilleHousing
where PropertyAddress is null

------------------------------------------------------------------------

---- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From DataCleaningProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address,
CHARINDEX(',', PropertyAddress)--from charindex 1 to comma ',' 

From DataCleaningProject.dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address -- from comma until the end of the PropertyAddress

From DataCleaningProject.dbo.NashvilleHousing

-- Create two new columns
Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


Select * 
From DataCleaningProject.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE (OwnerAddress,',','.'),3)
,PARSENAME(REPLACE (OwnerAddress,',','.'),2)
,PARSENAME(REPLACE (OwnerAddress,',','.'),1)
From DataCleaningProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE (OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE (OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE (OwnerAddress,',','.'),1)


Select *
from DataCleaningProject.dbo.NashvilleHousing

----------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DataCleaningProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


UPDATE 
    NashvilleHousing
SET
    SoldAsVacant = REPLACE(SoldAsVacant, 'Y','Yes')
WHERE
    SoldAsVacant = 'Y';


UPDATE 
    NashvilleHousing
SET
    SoldAsVacant = REPLACE(SoldAsVacant, 'N','No')
WHERE
    SoldAsVacant = 'N';

----------------------------------------------------------
----- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num 

From DataCleaningProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
where row_num > 1
Order by PropertyAddress


