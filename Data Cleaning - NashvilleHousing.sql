select *
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
alter column SaleDate date

--Populate property address data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null


--Breaking out Property Addresses to individual columns

select PropertyAddress
from PortfolioProject..NashvilleHousing

select
PropertyAddress,
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as PropertyAdress_Split,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as PropertyAdress_City
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add PropertyAdress_Split nvarchar(255)

alter table NashvilleHousing
add PropertyAdress_City nvarchar(255)

update PortfolioProject..NashvilleHousing
set PropertyAdress_Split = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

update PortfolioProject..NashvilleHousing
set PropertyAdress_City = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))


--Breaking out Owner Addresses to individual columns

select 
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add OwnerAdress_Split nvarchar(255)

alter table NashvilleHousing
add OwnerAdress_City nvarchar(255)

alter table NashvilleHousing
add OwnerAdress_State nvarchar(255)

update PortfolioProject..NashvilleHousing
set OwnerAdress_Split = parsename(replace(OwnerAddress,',','.'),3)

update PortfolioProject..NashvilleHousing
set OwnerAdress_City = parsename(replace(OwnerAddress,',','.'),2)

update PortfolioProject..NashvilleHousing
set OwnerAdress_State = parsename(replace(OwnerAddress,',','.'),1)


--Change Y and N to Yes and No in SoldAsVacant

update NashvilleHousing
set SoldAsVacant =
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end


Select distinct(SoldAsVacant), count (SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant


--Remove duplicates

begin tran
commit

with RowNumCTE as(
select *,
	row_number() over (
	partition by ParcelID, PropertyAddress, SaleDate, LegalReference
	order by UniqueID 
	) as row_num

from PortfolioProject..NashvilleHousing
)

select *
from RowNumCTE
where row_num >1
order by PropertyAddress


--Delete Unused columns

begin tran
commit

alter table PortfolioProject..NashvilleHousing
drop column PropertyAddress, OwnerAddress, TaxDistrict




