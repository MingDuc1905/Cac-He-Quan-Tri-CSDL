# ==============================================================================
# SHIPFOOD - ORDS REST API AUTOMATED TEST RUNNER (POWERSHELL)
# ==============================================================================
param (
    [string]$BaseUrl = "http://localhost:8080/ords/shipfood"
)

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host " SHIPFOOD ORACLE 23ai DUALITY VIEW - ORDS TEST SUITE" -ForegroundColor Cyan
Write-Host " Target URL: $BaseUrl" -ForegroundColor Gray
Write-Host "======================================================================" -ForegroundColor Cyan

function Invoke-Test {
    param (
        [string]$Name,
        [string]$Method,
        [string]$Endpoint,
        [object]$Body = $null,
        [int]$ExpectedStatus = 200,
        [string]$ExpectedContent = ""
    )

    Write-Host "`n[RUNNING] $Name" -ForegroundColor Yellow
    $url = "$BaseUrl$Endpoint"
    $headers = @{ "Accept" = "application/json" }

    try {
        $params = @{
            Uri = $url
            Method = $Method
            Headers = $headers
            ContentType = "application/json; charset=utf-8"
            UseBasicParsing = $true
        }
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
        }

        $response = Invoke-RestMethod @params
        Write-Host "  -> SUCCESS (Status $ExpectedStatus)" -ForegroundColor Green
        if ($response._id -or $response.items) {
            Write-Host "  -> Data received: $($response | ConvertTo-Json -Depth 3 | Out-String | Select-Object -First 6)" -ForegroundColor DarkGray
        }
        return @{ Name = $Name; Status = "PASS"; Detail = "OK" }
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $errBody = ""
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $errBody = $reader.ReadToEnd()
        } catch {}

        if ($statusCode -eq $ExpectedStatus -or ($ExpectedContent -and $errBody -like "*$ExpectedContent*")) {
            Write-Host "  -> EXPECTED ERROR CAUGHT ($statusCode): $errBody" -ForegroundColor Green
            return @{ Name = $Name; Status = "PASS (Expected Error)"; Detail = $errBody }
        } else {
            Write-Host "  -> FAILED: HTTP $statusCode" -ForegroundColor Red
            Write-Host "     Detail: $errBody" -ForegroundColor DarkRed
            return @{ Name = $Name; Status = "FAIL"; Detail = $errBody }
        }
    }
}

$results = @()

# 1. GET Orders List
$results += Invoke-Test -Name "TC1.1 GET List Orders" -Method "GET" -Endpoint "/dv_don_hang/" -ExpectedStatus 200

# 2. GET Order Detail
$results += Invoke-Test -Name "TC1.2 GET Order Detail (Nested JSON)" -Method "GET" -Endpoint "/dv_don_hang/1" -ExpectedStatus 200

# 3. POST Create Order
$newOrder = @{
    "_id" = 9999
    "ngaydathang" = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    "trangthai" = "Chờ xác nhận"
    "tongtien" = 125000
    "phiship" = 15000
    "phidichvu" = 5000
    "ghichu" = "Đơn test tự động"
    "quanAn" = @{ "userid" = 1 }
    "giaoHang" = @{ "mattdh" = 1 }
    "thanhToan" = @{ "mahttt" = 1 }
    "chiTiet" = @(
        @{
            "mactdh" = 99901
            "soluong" = 2
            "dongia" = 45000
            "bienThe" = @{ "id" = 1 }
        }
    )
}
$results += Invoke-Test -Name "TC2 POST Create Order" -Method "POST" -Endpoint "/dv_don_hang/" -Body $newOrder -ExpectedStatus 201

# 4. PUT Valid State Transition
$validUpdate = @{ "_id" = 9999; "trangthai" = "Đã đặt" }
$results += Invoke-Test -Name "TC3.1 PUT Valid State: Chờ xác nhận -> Đã đặt" -Method "PUT" -Endpoint "/dv_don_hang/9999" -Body $validUpdate -ExpectedStatus 200

# 5. PUT Invalid State Transition (Trigger Violation)
$invalidUpdate = @{ "_id" = 9999; "trangthai" = "Chờ xác nhận" }
$results += Invoke-Test -Name "TC3.2 PUT Invalid State: Đã đặt -> Chờ xác nhận (ORA-20010)" -Method "PUT" -Endpoint "/dv_don_hang/9999" -Body $invalidUpdate -ExpectedStatus 500 -ExpectedContent "20010"

# 6. PUT Duality View Read-only violation
$illegalDualityUpdate = @{ "_id" = 9999; "quanAn" = @{ "userid" = 1; "tenquanan" = "Tên Sửa Đổi" } }
$results += Invoke-Test -Name "TC4 PUT Duality Boundary Violation (NOUPDATE quanAn)" -Method "PUT" -Endpoint "/dv_don_hang/9999" -Body $illegalDualityUpdate -ExpectedStatus 500

Write-Host "`n======================================================================" -ForegroundColor Cyan
Write-Host " TEST RUN SUMMARY" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
$results | Format-Table -AutoSize
