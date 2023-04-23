/*
CLEANING DATA IN SQL QUERIES
*/

select * from NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- STANDARDIZE DATE FORMAT

select SaleDate, convert(date, SaleDate) from NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

--------------------------------------------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS DATA

select * 
from NashvilleHousing
where PropertyAddress is null

select * 
from NashvilleHousing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress) 
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

select PropertyAddress
from NashvilleHousing

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as PropertySplitAddress,
substring(PropertyAddress, charindex(',', PropertyAddress) +2 , len(PropertyAddress)) as PropertySplitCity
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +2 , len(PropertyAddress))

select OwnerAddress
from NashvilleHousing

select
parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------------------------------------

-- CHANGE Y AND N TO Yes AND No IN "SoldAsVacant" FIELD

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = 
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- REMOVE DUPLICATES

with RowNumCTE as (
select *,
	row_number() over (partition by ParcelID,
									PropertyAddress,
									SaleDate,
									SalePrice,
									LegalReference 
									order by UniqueID) row_num
from NashvilleHousing
)
delete
from RowNumCTE
where row_num > 1

---------------------------------------------------------------------------------------------------------

-- DELETE UNUSED COLUMNS

alter table NashvilleHousing
drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict