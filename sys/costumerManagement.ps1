function Add-Customer {
    param (
        [string]$tenantId,
        [string]$costumerName
    )

    $insertQuery = @"
    INSERT OR REPLACE INTO costumerData (tenantId, costumerName) 
    VALUES ('$tenantId', '$costumerName');
"@
    sqlite3 $databasePath $insertQuery
}
function Edit-Costumer {

    param (
        [string]$tenantId,
        [string]$costumerName
    )

}
function Delete-Costumer {
    param (
        [string]$tenantId
    )
    $deleteQuery = @"
    DELETE from costumerData WHERE tenantId = '$tenantId';
"@

    sqlite3 $databasePath $deleteQuery
}
function Get-Customers {
    $selectQuery = @"
    SELECT tenantId, costumerName FROM costumerData;
"@
    $result = sqlite3 $databasePath $selectQuery

    if ($result) {
        $customerTable = $result | Format-Table -AutoSize
        return $customerTable
    } else {
        Write-Output "No customers found in the database."
    }
}

# Path to the database
$databasePath = "./db/data.db"

Write-Host "#####################################" -ForegroundColor Green
Write-Host "######## Costumer Management ########" -ForegroundColor Green
Write-Host "#####################################" -ForegroundColor Green

# Create a menu to ask for user input
while ($true) {
    Write-Host "-------------------------------------"
    Write-Host "Menu:"
    Write-Host "1. Create a customer"
    Write-Host "2. List all customers"
    Write-Host "3. Modify a customer"
    Write-Host "4. Delete a customer"
    Write-Host "5. Exit"
    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        1 {
            $tenantId = Read-Host "Enter the tenant ID"
            $costumerName = Read-Host "Enter the customer name"
            Add-Customer -tenantId $tenantId -costumerName $costumerName
            Write-Output "Customer $costumerName with tenant ID $tenantId has been added to the database."
        }
        2 {
            Get-Customers
        }
        3 {
            $tenantId = Read-Host "Enter the tenant ID of the customer to modify"
            $newCostumerName = Read-Host "Enter the new customer name"
            Edit-Costumer -tenantId $tenantId -costumerName $newCostumerName
            Write-Output "Customer with tenant ID $tenantId has been modified."
        }
        4 {
            $tenantId = Read-Host "Enter the tenant ID of the customer to delete"
            Delete-Costumer -tenantId $tenantId
            Write-Output "Customer with tenant ID $tenantId has been deleted from the database."
        }
        5 {
            break
        }
        default {
            Write-Host "Invalid choice. Please try again."
        }
    }
}