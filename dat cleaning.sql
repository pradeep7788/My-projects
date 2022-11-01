/*
Cleaning Data
*/

Select * 
from [Portfolio Project]..NashvilleHousing
--------------------------------------------------------------------
--Standardize date format
Select SaleDate, CONVERT(Date,SaleDate) 
from [Portfolio Project]..NashvilleHousing

Update [Portfolio Project]..NashvilleHousing
set SaleDate = CONVERT(date,SaleDate)
--Update here didn't changed anything for me
Select * 
from [Portfolio Project]..NashvilleHousing

Alter Table NashvilleHousing
Add saleDateConverted Date;

Update [Portfolio Project]..NashvilleHousing
set saleDateConverted = CONVERT(DATE, SaleDate)
-----------------------------------------------------------------
---------------------------------------------------------------
--Populate Poperty Address Data

Select * 
from [Portfolio Project]..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

--Observation - same parcelId for Same Addresses
Select a.ParcelID, a.PropertyAddress, b.ParcelID , b. PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Portfolio Project]..NashvilleHousing as a
Join [Portfolio Project]..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is Null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Portfolio Project]..NashvilleHousing as a
Join [Portfolio Project]..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is Null

-----------------------------------------------------------------
--Breaking Address into multiple columns of Unique House No., Street, city, state
Select PropertyAddress
from [Portfolio Project]..NashvilleHousing

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from [Portfolio Project]..NashvilleHousing

Alter Table [Portfolio Project]..NashvilleHousing
Add PropertyAddressSplit nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
set PropertyAddressSplit = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter Table [Portfolio Project]..NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select PropertySplitCity, PropertyAddressSplit
from [Portfolio Project]..NashvilleHousing

--OwnerAddress
Select OwnerAddress
from [Portfolio Project]..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from [Portfolio Project]..NashvilleHousing

Alter Table [Portfolio Project]..NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table [Portfolio Project]..NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table [Portfolio Project]..NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From [Portfolio Project]..NashvilleHousing
-------------------------------------------------------------------------------------------------------
--Change Y or N to Yes and No in "SoldAsVacant"
Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
from [Portfolio Project]..NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
	WHEN SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
from [Portfolio Project]..NashvilleHousing

UPDATE [Portfolio Project]..NashvilleHousing
SET SoldAsVacant = (CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
	WHEN SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End)
------------------------------------------------------------------------------------------------------------
--Remove Duplicates
Select *
from [Portfolio Project]..NashvilleHousing


WITH RowNumCTE as(
Select * ,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				ORDER BY
					UniqueID) row_num
from [Portfolio Project]..NashvilleHousing
)
Select *
from RowNumCTE
where row_num  > 1
order by ParcelID

--DELETEING
WITH RowNumCTE as(
Select * ,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				ORDER BY
					UniqueID) row_num
from [Portfolio Project]..NashvilleHousing
)
DELETE
from RowNumCTE
where row_num  > 1
---------------------------------------------------------------------------------------------------------------
--Deleting Unused Columns

Select *
from [Portfolio Project]..NashvilleHousing

Alter Table [Portfolio Project]..NashvilleHousing
Drop column OwnerAddress, PropertyAddress, TaxDistrict

Alter Table [Portfolio Project]..NashvilleHousing
Drop column SaleDate