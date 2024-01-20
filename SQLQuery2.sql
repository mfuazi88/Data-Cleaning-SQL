/*
CLEANING DATA In SQL
-convert datatype function
-Join function
- Substring Function
- Parsename Function
- Update String data
- Partition function
- case statement
- Common Table Expressions (CTE) function
- Alter and Delete Column
*/

Select*
FROM PortfolioProject..NashvilleHousing

--Standardize Date Format

Select SalesDateConverted,convert(date,SaleDate)
From PortfolioProject..NashvilleHousing

alter table NashvilleHousing
Add SalesDateConverted Date

update NashvilleHousing
SET SalesDateConverted=Convert(date,SaleDate)

--Populate Property Address Data

Select*
From PortfolioProject..NashvilleHousing
where PropertyAddress is null



Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

update a
set propertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

--Breakin Out Address Into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing
--where PropertyAddress is null
Order by ParcelID


Select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , len(PropertyAddress)) as Address2
From PortfolioProject..NashvilleHousing

alter table NashvilleHousing
Add PropertyAddress1 Nvarchar(255);

update NashvilleHousing
SET PropertyAddress1=SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


alter table NashvilleHousing
Add PropertyAddress2 Nvarchar(255);

update NashvilleHousing
SET PropertyAddress2=SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , len(PropertyAddress))


Select*
From PortfolioProject..NashvilleHousing
Order by ParcelID

Select OwnerAddress
From PortfolioProject..NashvilleHousing

-- delimiter using parsename--

Select 
parsename(replace(OwnerAddress,',','.'),3)
,parsename(replace(OwnerAddress,',','.'),2)
,parsename(replace(OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleHousing


Select*
From PortfolioProject..NashvilleHousing
--where PropertyAddress is null
Order by ParcelID


ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress1 Nvarchar(255);

update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress1=parsename(replace(OwnerAddress,',','.'),3)

alter table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress2 Nvarchar(255);

update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress2=parsename(replace(OwnerAddress,',','.'),2)

alter table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress3 Nvarchar(255);

update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress3=parsename(replace(OwnerAddress,',','.'),1)


Select OwnerSplitAddress1, OwnerSplitAddress2, OwnerSplitAddress3
From PortfolioProject..NashvilleHousing
Order by ParcelID

--Change Y and N to YES and No in "Sold as Vacant" field

Select SoldAsVacant
From PortfolioProject..NashvilleHousing
Where SoldAsVacant<>'Yes' AND 
	SoldAsVacant<>'No' 

select Distinct(SoldAsvacant),
COUNT(SoldAsVacant) OVER ( PARTITION BY SoldAsVacant) AS Total
From PortfolioProject..NashvilleHousing


Select SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	 WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 END
	 AS Adjusted
From PortfolioProject..NashvilleHousing


update PortfolioProject..NashvilleHousing
SET SoldAsVacant=
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	 WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 END


	 -- Remove Duplicates

WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
PARTITION BY parcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
			UniqueID
			) row_num
From PortfolioProject..NashvilleHousing
)
/*
Select *
FROM RowNumCTE 
WHERE row_num > 1
order by PropertyAddress
-- everything check out as duplicate */

DELETE 
FROM RowNumCTE
WHERE row_num > 1


-- DELETE UNUSED COLUMN

Select*
From PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
