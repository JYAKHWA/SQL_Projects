/* NASHVILLE HOUSING DATA CLEANING

*/

USE Nashville_Housing_DataCleaning;
SELECT * FROM Nashville;



--SATANDARIZE DATE FORMAT, REMOVE THE OLD COLUMN---


SELECT SaleDate, CONVERT (date, SaleDate) AS 'SaleDate_Converted' FROM Nashville;		/* time in the end has no purpose, lets remove it */

ALTER TABLE Nashville
ADD SaleDateConverted Date;

UPDATE Nashville
SET SaleDateConverted = CONVERT (date, SaleDate);

SELECT SaleDateConverted FROM Nashville;

ALTER TABLE Nashville				/* delete SaleDate */
DROP COLUMN SaleDate;

SELECT * FROM Nashville;



---POPULATE ADDRESS DATA USING COMMON VALUES----

SELECT PropertyAddress FROM Nashville
WHERE PropertyAddress IS NULL;				/* see if there are null values   */

SELECT * FROM Nashville
WHERE PropertyAddress IS NULL;	

SELECT * FROM Nashville						/* lets see if we can match null property address with parcel IDs & fill up if it does*/
ORDER BY ParcelID;		

/* There exists, same parcel ids with null and filled up Property Address. Let's populate the null values from ParcelID.
 The reason being Owner Address might chnage, but PropertyAddress remains the same.  */
SELECT prev.ParcelID, prev.PropertyAddress, nxt.ParcelID, nxt.PropertyAddress
FROM Nashville prev
JOIN Nashville nxt
ON prev.ParcelID = nxt.ParcelID
AND prev.[UniqueID ] <> nxt.[UniqueID ]			/* unique ID is never same, but parcelID is same here */
WHERE prev.PropertyAddress IS NULL;

/* From this query, we see same parcelID having null and filled in Property Address. Lets fill up.  */
SELECT prev.ParcelID, prev.PropertyAddress, nxt.ParcelID, nxt.PropertyAddress, ISNULL (prev.PropertyAddress, nxt.PropertyAddress)
FROM Nashville prev
JOIN Nashville nxt
ON prev.ParcelID = nxt.ParcelID
AND prev.[UniqueID ] <> nxt.[UniqueID ]			
WHERE prev.PropertyAddress IS NULL;



/* Lets update the Address now  */
/*convert used as it threw the error, cannot convert into float */
UPDATE prev
SET PropertyAddress = ISNULL (CONVERT (nvarchar, prev.PropertyAddress), CONVERT (nvarchar, nxt.PropertyAddress))
FROM Nashville prev
JOIN Nashville nxt
ON CONVERT(nvarchar, prev.ParcelID) = CONVERT (nvarchar, nxt.ParcelID)
AND CONVERT (nvarchar, prev.[UniqueID ]) <> CONVERT (nvarchar, nxt.ParcelID)
WHERE CONVERT (nvarchar, prev.PropertyAddress) IS NULL;



---BREAKING ADDRESS INTO INDIVIDUAL COLUMNS---

SELECT PropertyAddress FROM Nashville;

SELECT
	SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1) AS 'Address',			--going before , --
	SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1 , LEN (PropertyAddress) ) AS 'City'		--going after ,--
FROM Nashville;

/* Now, lets  seperate Address values in two new columns using the previous substring*/
/*  Address  */
ALTER TABLE Nashville
ADD Property_Split_Address NVARCHAR (255);

UPDATE Nashville
SET Property_Split_Address = SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1);

/*  City  */
ALTER TABLE Nashville
ADD Property_Split_City NVARCHAR (255);

UPDATE Nashville
SET Property_Split_City = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) +1 , LEN (PropertyAddress) );

SELECT * FROM Nashville;


/* Lets split the Owner Adresss similarly. This time using ParceName instead of substring  */
SELECT OwnerAddress FROM Nashville;

SELECT PARSENAME (REPLACE (OwnerAddress, ',', '.'), 3),  /* ParseName needs to have a period, i.e. '.'  the order is 3,2,1 as it works backwards.  */ 
		PARSENAME (REPLACE (OwnerAddress, ',', '.'), 2),
		PARSENAME (REPLACE (OwnerAddress, ',', '.'), 1)
FROM Nashville

/* Now, lets add the columns as previously with substring  */
/*  Address  */
ALTER TABLE Nashville
ADD Owner_Split_Address NVARCHAR (255);

UPDATE Nashville
SET Owner_Split_Address = PARSENAME (REPLACE (OwnerAddress, ',', '.'), 3);

/*  City  */
ALTER TABLE Nashville
ADD Owner_Split_City NVARCHAR (255);

UPDATE Nashville
SET Owner_Split_City = PARSENAME (REPLACE (OwnerAddress, ',', '.'), 2);

/*  State  */
ALTER TABLE Nashville
ADD Owner_Split_State NVARCHAR (255);

UPDATE Nashville
SET Owner_Split_State = PARSENAME (REPLACE (OwnerAddress, ',', '.'), 1);

SELECT * FROM Nashville;


--- CHANGE Y and N to Yes and No from SoldAsVacant fields as it has Yes, Y, No & N ---

/* See Distinct value count for SoldAsVacant field  */
SELECT DISTINCT (SoldAsVacant), COUNT (SoldAsVacant) AS 'Total Values'
FROM Nashville
GROUP BY SoldAsVacant
ORDER BY 2;

/* Convert all to Yes and No using case statement */
SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM Nashville;

UPDATE Nashville
SET SoldAsVacant = 	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					WHEN SoldAsVacant = 'N' THEN 'No'
					ELSE SoldAsVacant
					END;  /* Updated all to Yes and No. */



----             REMOVE DUPLICATES      -----


SELECT * FROM Nashville;

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDateConverted,
				LegalReference
				ORDER BY UniqueID
	) row_num
FROM Nashville
)
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress; /* This generates all duplicates  using CTE */

/* Delete them.  */
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDateConverted,
				LegalReference
				ORDER BY UniqueID
	) row_num
FROM Nashville
)
DELETE FROM RowNumCTE
WHERE row_num > 1; 

/* Use the last CTE to see if there are any more duplicates, it shows none.. */


------------- DELETE UNUSED COLUMNS  --------------------

ALTER TABLE Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

SELECT * FROM Nashville;



------------ In a nutshell, this SQL Data Cleaning for Nashville Property I applied:
--	1. Standarized Date Format using CONVERT
--	2. Populated missing PropertyAddress using unique same ParcelID for Adress and not equal UniqueID. Also converted float to NVARCHAR. Applied JOINS
--	3. Broke down PropertyAddress and OwnerAddress to more usable columns using substring and ParceName & Replace
--	4. Applied Case statements to change filed data of Y and N to Yes and No
--	5. Removed duplicates using CTE, ROW_NUMBER and WINDOWS FUNCTION (PARTITION BY)
--	6. Deleted unused columns. ALtered tables, updated columns, Added New Columns, Dropped Columns 