--DATA CLEANING 
--First thing to do is to properly formatt all columns in the dataset, make sure to clean out and retain only information useful for your exploration and analysis

--First I have to separate the date from the timestamp 


SELECT saleDate
FROM yuro..NashvilleHousing

ALTER TABLE yuro..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE yuro..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM yuro..NashvilleHousing

 --Formatting the property address by separating the actual address from the city 

 SELECT PropertyAddress
FROM yuro..NashvilleHousing

--In the query below, I am removing the NULL values from the property address column, I will be replacing the NULL values
--with the corresponding value in the owner address column. 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
, ISNULL(a.propertyaddress, b.PropertyAddress)
FROM yuro..NashvilleHousing a
JOIN yuro..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET propertyAddress =  ISNULL(a.propertyaddress, b.PropertyAddress)
FROM yuro..NashvilleHousing a
JOIN yuro..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--SEPARATING THE ADDRESS FROM CITIES

 SELECT 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
 FROM yuro..NashvilleHousing

 --PUTTING THE CITY IN A SEPAPRATE COLUMN

 SELECT 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM yuro..NashvilleHousing

--CREATING TWO NEW COLUMNS TO HOUSE THE CLEANED VERSIONS OF THE PROPERTY ADDRESS

ALTER TABLE yuro..NashvilleHousing
ADD CleanedPropertyAddress NVARCHAR(255)

UPDATE yuro..NashvilleHousing 
SET CleanedPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE yuro..NashvilleHousing
ADD CleanedPropertyCity NVARCHAR(255)

UPDATE yuro..NashvilleHousing 
SET CleanedPropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--FORMATTING THE OWNER ADDRESS TO SEPAPRATE FROM CITY, STATE
--DUE TO THE FACT THAT THE VALUES IN THIS COLUMN IS SEPAPRATED BY MULTIPLE DELIMITER, I WILL BE USING A DIFFERENT TECHNIQUES WITH THE PARSENAME FUNCTION

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM yuro..NashvilleHousing

--ADDING AND UPDATING NEW COLUMNS CREATED


ALTER TABLE yuro..NashvilleHousing
ADD CleanedOwnerAddress NVARCHAR(255)

UPDATE yuro..NashvilleHousing
SET CleanedOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE yuro..NashvilleHousing
ADD CleanedOwnerCity NVARCHAR(255)

UPDATE yuro..NashvilleHousing
SET CleanedOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)


ALTER TABLE yuro..NashvilleHousing
ADD CleanedOwnerState NVARCHAR(255)

UPDATE yuro..NashvilleHousing
SET CLeanedOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


--Cleaning the SoldAsVacant Column, replacing the Yand N to YES and NO

SELECT DISTINCT(SoldAsVacant)
FROM yuro..NashvilleHousing

--To find out the number of each value

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM yuro..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant)


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant END 
FROM yuro..NashvilleHousing

--Updating and creating the new cleaned column

UPDATE yuro..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant END 
FROM yuro..NashvilleHousing


-- Removing Duplicate Rows 


WITH RowNumCTE AS(
SELECT *,
 ROW_NUMBER() OVER (    
       PARTITION BY ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY UniqueID
					      ) Row_Num
FROM yuro..NashvilleHousing
)
DELETE
FROM RowNumCTE 
WHERE Row_Num  > 1

--To Confirm Successful removal of duplicates

WITH RowNumCTE AS(
SELECT *,
 ROW_NUMBER() OVER (    
       PARTITION BY ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY UniqueID
					      ) Row_Num
FROM yuro..NashvilleHousing
)
SELECT *
FROM RowNumCTE 
WHERE Row_Num  > 1


--DELETING UNUSED COLUMNS
--It is not advisable to delete anything from your raw data for obvious reasons, this is jsut for the purposeof practice

SELECT *
FROM yuro..NashvilleHousing

ALTER TABLE yuro..NashvilleHousing
DROP COLUMN  SaleDate, OwnerAddress, TaxDistrict, LegalReference

ALTER TABLE yuro..NashvilleHousing
DROP COLUMN PropertyAddress


