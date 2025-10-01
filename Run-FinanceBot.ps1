<#
.SYNOPSIS
    A personal finance bot to calculate remaining monthly spending money.
.DESCRIPTION
    This script monitors an 'inbox' folder for new payment files. When a file
    is detected, it reads the payment amount, calculates it against the income
    and recurring bills defined in config.json, and displays a summary.
.AUTHOR
    Seth Yang
#>

# --- INITIALIZATION ---
# Use $PSScriptRoot to make sure the script can find its files
# no matter where you run it from. This is a key best practice.
$scriptRoot = $PSScriptRoot
$configFile = Join-Path $scriptRoot "config.json"

# Clear the screen for a clean start
Clear-Host

# Check for the config file and load it
if (-not (Test-Path $configFile)) {
    Write-Host "FATAL: config.json not found in the script's directory!" -ForegroundColor Red
    Write-Host "Please make sure it exists before running." -ForegroundColor Red
    exit
}
$config = Get-Content $configFile | ConvertFrom-Json

# Define our working folders based on the script's location
$watchPath = Join-Path $scriptRoot $config.watchFolder
$processedPath = Join-Path $scriptRoot $config.processedFolder

# Create the folders if they don't exist
if (-not (Test-Path $watchPath)) { New-Item -ItemType Directory -Path $watchPath | Out-Null }
if (-not (Test-Path $processedPath)) { New-Item -ItemType Directory -Path $processedPath | Out-Null }

# --- Display a welcome message ---
Write-Host "-------------------------------------" -ForegroundColor Cyan
Write-Host "      SPEND-TRACKER-BOT ACTIVE       "
Write-Host "-------------------------------------" -ForegroundColor Cyan
Write-Host "Monitoring for new payments in: `"$($config.watchFolder)`""
Write-Host "Press CTRL+C to stop the bot."
Write-Host ""


# --- CORE LOGIC ---
# This set keeps track of files we've already seen to avoid reprocessing.
$processedFiles = New-Object System.Collections.Generic.HashSet[string]

# The main loop that watches for files.
while ($true) {
    # Get a list of any text files in our watch folder.
    $paymentFiles = Get-ChildItem -Path $watchPath -Filter "*.txt"

    foreach ($file in $paymentFiles) {
        # Only process files we haven't seen before.
        if (-not $processedFiles.Contains($file.FullName)) {

            Write-Host "[$(Get-Date -Format 'T')] New payment file detected: $($file.Name)" -ForegroundColor Yellow
            $processedFiles.Add($file.FullName) | Out-Null

            try {
                # Read the content of the file.
                $paymentAmountStr = Get-Content $file.FullName

                # Make sure the file isn't empty before trying to process it.
                if ([string]::IsNullOrWhiteSpace($paymentAmountStr)) {
                    throw "File is empty."
                }

                # Convert the text to a number.
                $creditCardPayment = [double]::Parse($paymentAmountStr)

                # --- All the Calculations ---
                $totalRecurring = ($config.recurringPayments.amount | Measure-Object -Sum).Sum
                $totalExpenses = $totalRecurring + $creditCardPayment
                $remainingBalance = $config.monthlyIncome - $totalExpenses

                # --- Display the Final Output ---
                Write-Host "-------------------------------------" -ForegroundColor Cyan
                Write-Host "          FINANCIAL SUMMARY          "
                Write-Host "-------------------------------------" -ForegroundColor Cyan
                Write-Host ("Monthly Income:".PadRight(25) + "$($config.monthlyIncome.ToString("C"))") -ForegroundColor Green
                Write-Host ""
                Write-Host ("Recurring Bills Total:".PadRight(25) + "$($totalRecurring.ToString("C"))") -ForegroundColor Red
                Write-Host ("This Credit Payment:".PadRight(25) + "$($creditCardPayment.ToString("C"))") -ForegroundColor Red
                Write-Host ("Total Monthly Expenses:".PadRight(25) + "$($totalExpenses.ToString("C"))") -ForegroundColor Red
                Write-Host ""
                Write-Host ("REMAINING FOR SPENDING:".PadRight(25) + "$($remainingBalance.ToString("C"))") -ForegroundColor Green
                Write-Host "-------------------------------------" -ForegroundColor Cyan
                Write-Host ""


                # Archive the file to prevent it from being counted again.
                Move-Item -Path $file.FullName -Destination $processedPath

            } catch {
                # A more helpful error message if something goes wrong.
                Write-Host "ERROR: Could not process file '$($file.Name)'. $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "Please ensure it contains only a valid number." -ForegroundColor Red
            }
        }
    }
    # Wait for 5 seconds before checking the folder again.
    Start-Sleep -Seconds 5
}