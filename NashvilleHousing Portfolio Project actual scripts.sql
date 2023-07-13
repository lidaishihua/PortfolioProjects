--Cleaning data in SQL queries
select *
from PortfolioProject.dbo.NashvilleHousing

--Standardize date fortmat
select SaleDateConverted, Convert(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = convert(Date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;
update NashvilleHousing
set SaleDateConverted = convert(Date, SaleDate)


--Populated property addredd data
select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out address into individual colums (address, city, state)
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select 
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))as Address
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select 
Parsename(replace(OwnerAddress, ',', '.'), 3),
Parsename(replace(OwnerAddress, ',', '.'), 2),
Parsename(replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = Parsename(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = Parsename(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = Parsename(replace(OwnerAddress, ',', '.'), 1)

select *
from PortfolioProject.dbo.NashvilleHousing


--Change Y and N to Yes and No in 'Sold as Vacant' Field
select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End

--Remove Duplicates
with RowNumCTE as(
select *,
ROW_NUMBER() over (
partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by 
			 UniqueID
			 ) row_num
from PortfolioProject.dbo.NashvilleHousing
)
Select *
from RowNumCTE
where row_num > 1


--Delete Unused columns
Select *
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
