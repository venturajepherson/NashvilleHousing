SELECT *
FROM [Portfolio Project - Covid]..nashvilleHousing

--Standardize Date Format remove the hours, keep only yyyy/mm/dd


SELECT saleDate, Convert (date,Saledate) 
FROM [Portfolio Project - Covid]..nashvilleHousing

-- the above game me the standard format

--below i updated the column using the new date standard

UPDATE Nashvillehousing
SET saledate = Convert (date,Saledate)

-- there s a glitch that doesnt change the date format so i'm going to add a new column and add the new format.

Alter Table Nashvillehousing
add SaleDateConverted Date; -- adding Date for formatting purposes similar to addimg column with int

Update Nashvillehousing
SET SaleDateConverted = Convert(date,saledate)

-----------------

--Update Property address data

--the parcelID is the same as Property address

SELECT *
FROM [Portfolio Project - Covid]..nashvilleHousing
WHERE propertyaddress is null
Order by parcelid,propertyaddress


--the parcelID is the same as Property address, filling out the null address w right data
-- need to do a SelfJoin in order to update the null data with the data that already exsit
--ISNULL is used to specify a value if the expression is null.

SELECT a.parcelid,a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(A.propertyaddress, B.propertyaddress)
FROM [Portfolio Project - Covid]..nashvilleHousing A
JOIN [Portfolio Project - Covid]..nashvilleHousing B
	On a.parcelid = b.parcelid
	AND a.uniqueid <> b.uniqueid -- since unique id are unique then, we want to establish this first
where a.propertyaddress is null


--updated table a(original from joined table), and replace the null property address with the b.property address that we identified using patterns in the parcelID and address
UPDATE A
SET propertyaddress = ISNULL(A.propertyaddress, B.propertyaddress)
FROM [Portfolio Project - Covid]..nashvilleHousing A
JOIN [Portfolio Project - Covid]..nashvilleHousing B
	On a.parcelid = b.parcelid
	AND a.uniqueid <> b.uniqueid -- since unique id are unique then, we want to establish this first
where a.propertyaddress is null

---------------------

--Breaking out address into individual columns (address, City, State)
--theres only a column after ave, st, dr, etc
--using a sbstring

Select propertyaddress, parcelid
from [Portfolio Project - Covid].dbo.NashvilleHousing
Order by parcelid

SELECT
Substring(Propertyaddress, 1, charindex(',', Propertyaddress)-1) as Street -- using charindex to know at what position the ',' is located, 
																		--added a (-1) to remove the comma
,substring (Propertyaddress, charindex(',', Propertyaddress)+1, Len(propertyaddress)) as City -- added a plus 1 as I wanted the substring to start 1 space after the ',', in order to get the City 

FROM [Portfolio Project - Covid].dbo.NashvilleHousing


-- now that we have both Streeth and Town name, we need to create 2 seperate columns 

--Property Street
Alter Table dbo.nashvilleHousing
ADD PropertyStreet nvarchar(255);

Update dbo.nashvillehousing
SET PropertyStreet = Substring(Propertyaddress, 1, charindex(',', Propertyaddress)-1) 

--Property City
Alter Table NashvilelHousing
ADD Property City nvarchar(255);

Update Nashvillehousing
SET PropertyCity = substring (Propertyaddress, charindex(',', Propertyaddress)+1, Len(propertyaddress))



-----Cleaning up data for OwnerAddress that has address, city and state initial in one string
-- will not be using substring function, will be using ParseName

Select *
from dbo.nashvillehousing
Order by UniqueID

Select Parsename(replace(owneraddress,',', '.'), 3) 
, Parsename(replace(owneraddress,',', '.'), 2)
, Parsename(replace(owneraddress,',', '.'), 1)
from dbo.nashvillehousing

--Property Street
Alter Table dbo.nashvilleHousing
ADD OwnerStreet nvarchar(255);

Update dbo.nashvillehousing
SET OwnerStreet = Parsename(replace(owneraddress,',', '.'), 3)

--Property City
Alter Table NashvilleHousing
ADD OwnerCity nvarchar(255);

Update Nashvillehousing
SET OwnerCity = Parsename(replace(owneraddress,',', '.'), 2)

--property State
Alter Table NashvilleHousing
ADD OwnerState nvarchar(255);

Update Nashvillehousing
SET ownerstate = Parsename(replace(owneraddress,',', '.'), 1)



--- Change Y and N to Yes and No in "sold as Vacant" Field



Select Distinct(soldAsvacant), Count (soldasvacant)
From [Portfolio Project - Covid]..nashvillehousing
Group by soldasvacant

Select Soldasvacant -- created Case statement first to see if it works
, Case
WHEN Soldasvacant = 'Y' THEN 'Yes'
When soldasvacant = 'N' THEN 'No'
Else Soldasvacant
END
FROM [Portfolio Project - Covid]..nashvillehousing


Update nashvillehousing -- applied case statement 
SET soldasvacant =  Case
WHEN Soldasvacant = 'Y' THEN 'Yes'
When soldasvacant = 'N' THEN 'No'
Else Soldasvacant
END
FROM [Portfolio Project - Covid]..nashvillehousing


--- remove duplicates

Select *
FROM [Portfolio Project - Covid]..nashvillehousing

Select *
		, row_number () Over (
		Partition by ParcelID
					,Propertyaddress
					,SaleDate
					,LegalReference
		Order by UniqueID
		) row_num
FROM [Portfolio Project - Covid]..nashvillehousing


-- its hard to see where all the duplicates are in raw data so will be creating a CTE using the query above
-- you're unable to us Where statement in a Windows Function, thats why CTE are helpful

WITH RowNumCTE AS (
Select *
		, row_number () Over (
		Partition by ParcelID
					,Propertyaddress
					,SaleDate
					,LegalReference
		Order by UniqueID
		) row_num
FROM [Portfolio Project - Covid]..nashvillehousing
)

Select* -- with Select* we found all the duplicates, so now adding Delete function
From RowNumCTE
WHERE row_num > 1
--Order by Propertyaddress


----------------------

--Delete Unused columns

Select *
FROM [Portfolio Project - Covid]..nashvillehousing 

-- deleting columns we don't need
Alter Table [Portfolio Project - Covid]..nashvillehousing 
DROP COLUMN OwnerAddress, TaxDsitrict,PropertyAddress

Alter Table [Portfolio Project - Covid]..nashvillehousing 
DROP COLUMN SaleDate

