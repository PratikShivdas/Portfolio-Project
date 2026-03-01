USE PortfolioProject
Go

/*
Cleaning Data in SQL Queries	
*/

SELECT * 
FROM PortfolioProject.dbo.[NashvilleHousing];


-- 1. Standardize Date Format :
SELECT SaleDateConverted /*SaleDate*/, CONVERT(Date, SaleDate) as Date  
FROM PortfolioProject..[NashvilleHousing];

UPDATE PortfolioProject..[NashvilleHousing]
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE PortfolioProject..[NashvilleHousing]
ADD SaleDateConverted Date;

UPDATE PortfolioProject..[NashvilleHousing]
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- 2. Populate property address data :
SELECT  * -- PropertyAddress
FROM PortfolioProject..[NashvilleHousing]
-- WHERE PropertyAddress IS  NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) -- In here ISNULL() takes a first thing as what we need to check if it is null and if it is then on the second it asks what we need to populate or fit in there , the exact value which is in the 2nd col.
FROM PortfolioProject.dbo.[NashvilleHousing] as a
JOIN PortfolioProject.dbo.[NashvilleHousing] as b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
-- WHERE a.PropertyAddress IS NULL -- after the UPDATE Query there will be no NULL statements

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.[NashvilleHousing] as a
JOIN PortfolioProject.dbo.[NashvilleHousing] as b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-- 3. Breaking out Address Into Individual Columns (Address, City, State) :
SELECT PropertyAddress
FROM PortfolioProject..[NashvilleHousing]

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address -- Here this CHARINDEX will display the Address till the position is satisfied i.e. ','
--CHARINDEX(',', PropertyAddress) -- It means that the ',' is at the 16 th position.
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress ) +1 , LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..[NashvilleHousing]
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject..[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE PortfolioProject..[NashvilleHousing]
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject..[NashvilleHousing]
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress ) +1 , LEN(PropertyAddress))


SELECT * FROM PortfolioProject..[NashvilleHousing] -- So, by this we will have new two columns there at the last. Named as PropertySplitAddress & PropertySplitCity. So, here by we Split the or breaked down the Address into two separate columns. And it is much more useful than the original or regular PropertyAddress.

-- Till now we've done it for PropertyAddres, now let's see how it works on OwnerAddres which is little more complicated. 

SELECT OwnerAddress FROM PortfolioProject..[NashvilleHousing] --  now in this column of OwnerAddres we have Address,city and state.
-- for this we'll use Parsename instead of SUBSTRING(), which is very useful for delimited stuff/values

SELECT  -- Now this will separate each, but in backward direction
 PARSENAME(REPLACE(OwnerAddress,',','.'), 3 ) Address --1) 
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2) City
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1) State --3)
FROM PortfolioProject..[NashvilleHousing]

-- Let's just add values

ALTER TABLE PortfolioProject..[NashvilleHousing]
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject..[NashvilleHousing]
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress,',','.'), 3 ) 

ALTER TABLE PortfolioProject..[NashvilleHousing]
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject..[NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE PortfolioProject..[NashvilleHousing]
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject..[NashvilleHousing] 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT * FROM PortfolioProject..[NashvilleHousing]

-- 4. Change Y and N to Yes and No in "SoldAsVacant" field :
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 1 THEN 'YES'
	 WHEN SoldAsVacant = 0 THEN 'NO'
	 ELSE NULL
END as SoldAsVacnatText
FROM PortfolioProject..[NashvilleHousing]

-- Or we can do this in this way :

ALTER TABLE PortfolioProject..[NashvilleHousing]
ALTER COLUMN SoldAsVacant VARCHAR(3);

UPDATE PortfolioProject..[NashvilleHousing]
SET SoldAsVacant =
    CASE
        WHEN SoldAsVacant = '1' THEN 'YES'
        WHEN SoldAsVacant = '0' THEN 'NO'
    END;

-- 5. Remove Duplicates :
WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num
FROM PortfolioProject..[NashvilleHousing] 
-- ORDER BY ParcelID
-- WHERE row_num > 1
) 

SELECT *
/*DELETE*/  
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



-- 6. Delete Unused Columns :

ALTER TABLE PortfolioProject..[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..[NashvilleHousing]
DROP COLUMN SaleDate

SELECT * FROM PortfolioProject..[NashvilleHousing]











